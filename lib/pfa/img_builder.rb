#
# Module de construction de l'image CVG
# 
require_relative 'imagemagick_module'
require_relative 'any_builder'
module PFA
class RelativePFA
class ImgBuilder < AnyBuilder

  attr_reader :code_image_magick


  # Initialisation avant la construction
  # 
  # On définit notamment toutes les constants PFA_WIDTH etc.
  # 
  def init(**params)
    params[:as].is_a?(Symbol) || params[:as].is_a?(Hash) || raise(PFAFatalError.new(101))
    MagickPFA.define_dims_constants(params[:as])
  end

  def coef_pixels
    @coef_pixels ||= calc_coefficient_pixels
  end


  ##########################################
  ### MÉTHODE PRINCIPALE DE CONSTRUCTION ###
  ##########################################
  # Construction de l'image du paradigme
  # 
  # @param params [Hash]
  #     :as     La chose à construire, permettant de définir les
  #             dimensions de l'image et les dimensions principales. 
  #             Mettre :real_book ou :test pour des dimensions 
  #             différentes et connu.
  #             Cf. le fichier any_builder.rb pour voir les valeurs
  #             possible.
  # 
  def build(**params)
    #
    # Initialisation de la construction. On doit par exemple fournir
    # les dimensions à utiliser à l'aide options[:as]
    #
    init(**params)

    #
    # Le PFA doit être défini au minimum et ses données doivent être
    # valides.
    # 
    pfa.valid?

    #
    #
    # Détruire l'image si elle existe déjà
    # 
    File.delete(image_path) if File.exist?(image_path)

    # 
    # Construction du code pour Image Magick
    # (tous les codes seront injectés dans @code_image_magick)
    # 
    @code_image_magick = [MagickPFA.code_for_intro]

    #
    # Les titres des deux PFA
    # (on peut utiliser n'importe quel noeud pour les afficher)
    # 
    @code_image_magick << pfa.exposition.titre_pfa(false)
    @code_image_magick << pfa.exposition.titre_pfa(true)

    #
    # Le fond, avec les actes
    # 
    actes.each do |acte|
      # acte.full_code_image_magick
      # -- Cadre de la partie (acte) --
      @code_image_magick << acte.act_box_code(true)
      @code_image_magick << acte.act_box_code(false)
      # --- Nomde l'acte --
      @code_image_magick << acte.act_name_code(true)
      @code_image_magick << acte.act_name_code(false)
      # --- Horloge de l'acte ---
      @code_image_magick << acte.horloge_code(false, nil)
      @code_image_magick << acte.horloge_code(true, nil)
    end

    # --- Horloges de fin ---
    # 
    # @note
    #   Peu importe le noeud qui est appelé
    # 
    @code_image_magick << pfa.denouement.horloge_fin(false)
    @code_image_magick << pfa.denouement.horloge_fin(true)


    # --- IMPRESSION DES AUTRES NOEUDS/SÉQUENCES ---
    # 
    # On passe en revue tous les autres éléments du paradigme réel
    # et s'ils sont imprimable, on les ajoute.
    @last_abs_left = nil
    @last_left = nil
    pfa.data.values.each do |node|
      next if node.part? # déjà traité
      next unless node.drawnable? # pas imprimable
      # -- Mark et nom --
      @code_image_magick << node.image_magick_code(false, @last_abs_left)
      @code_image_magick << node.image_magick_code(true, @last_left)
      # -- Les horloges --
      @code_image_magick << node.horloge_code(false, @last_abs_left)
      @code_image_magick << node.horloge_code(true, @last_left)
      # 
      # On garde en mémoire les dimensions pour savoir si ça
      # va manger dessus (overlay)
      # 
      @last_abs_left  = node.abs_left + [ MagickPFA::Horloge_Width[node.type]/2, MagickPFA::Label_Width[node.type]/2 ].max
      @last_left      = node.left     + [ MagickPFA::Horloge_Width[node.type]/2, MagickPFA::Label_Width[node.type]/2 ].max
    end


    #
    # Chemin d'accès au fichier final
    # (en le protégeant)
    # 
    @code_image_magick << "\"#{image_path}\""

    # 
    # On transforme le code ImageMagick en ajoutant des retours
    # de chariot entre chaque section de code
    # 
    @code_image_magick = @code_image_magick.join("\n")

    # STDOUT.write "\n\ncmd à la fin =\n++++\n#{cmd}\n+++++\n".orange

    #
    # Mise de la commande sur une seule ligne
    # (je ne parviens pas à mettre la commande sur plusieurs lignes,
    #  même avec la contre-balance…)
    cmd_finale = @code_image_magick.split("\n").compact.join(" ")

    # gem 'log_in_file'
    logif("Command finale :\n<<<<<<<<<<\n#{cmd_finale}\n>>>>>>>>>>")
    
    
    # Pour débugger facilement, on met les numéros des lignes
    
    cmd_debug = cmd_finale.split("\n").collect.with_index do |line, idx|
      "#{idx + 1}: #{line.strip}"
    end.join("\n")
    # dbg "\n\nCommande finale\n#{cmd_debug}\n".bleu

    #
    # *** EXÉCUTION DE LA COMMANDE ***
    # 
    res_err = `#{cmd_finale} 2>&1`

    unless res_err.nil? || res_err.empty?
      raise PFAFatalError.new(5001, **{error: res_err})
    end

    #
    # L'image doit avoir été créée
    # 
    File.exist?(image_path) || raise(PFAFatalError.new(5000, **{path: image_path}))
    puts "Image #{image_path.inspect} produite avec succès.".vert

  end #/ build



  # @return \Array<Node> Liste des actes du paradigme
  # 
  def actes
    @actes ||= begin
      pfa.data.values.select do |node|
        node.part?
      end
    end
  end


  # @return \String Chemin d'accès au fichier de l'image finale
  def image_path
    @image_path ||= File.expand_path(File.join('.',"pfa#{"_#{pfa.pfa_id}" if pfa.pfa_id}.jpg"))
  end

  # @private

  # Calcule le coefficiant pixels qui permet de convertir un temps
  # quelconque en pixels en fonction de la durée du film analysé.
  # Produira la constant COEF_PIXELS
  # 
  def calc_coefficient_pixels
    (MagickPFA::PFA_WIDTH - MagickPFA::PFA_LEFT_MARGIN - MagickPFA::PFA_RIGHT_MARGIN).to_f / pfa.duration.to_i
  end


end #/class ImgBuilder
end #/class RelativePFA
end #/module PFA
