#
# Module de construction de l'image CVG
# 
require_relative 'any_builder'
module PFA
class RelativePFA
class ImgBuilder < AnyBuilder


  # Initialisation avant la construction
  # 
  # On définit notamment toutes les constants PFA_WIDTH etc.
  # 
  def init(**params)
    params[:as].is_a?(Symbol) || params[:as].is_a?(Hash) || raise(PFAFatalError.new(101))
    RelativePFA::AnyBuilder.define_dims_constants(params[:as])
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
    # (dans cmd)
    # 
    # cmd = []
    # cmd << "#{CONVERT_CMD} -size #{PFA_WIDTH}x#{PFA_HEIGHT}"
    # cmd << "xc:white"
    # cmd << "-units PixelsPerInch -density 300"
    # cmd << "-background white -stroke black"
    cmd = MagickPFA.code_for_intro

    #
    # Le fond, avec les actes
    # 
    actes.each do |acte|
      cmd += acte.img_draw_command
    end

    # 
    # Pour essayer de recomprendre comment ça marche
    # 
    # cmd << "-background transparent"
    # cmd << "-stroke #{DARKERS[:part]}"
    # cmd << "-fill white"
    # cmd << "-strokewidth #{BORDERS[:part]}"
    # # original : -draw "rectangle #{left},#{top} #{right},#{box_bottom}"
    # cmd << "-draw \"rectangle 10,10 310,110\""

    # cmd << "\\( -stroke #{COLORS[:part]}"
    # cmd << "-strokewidth #{FONTWEIGHTS[:part]}"
    # cmd << "-pointsize #{FONTSIZES[:part]}"
    # # cmd << "-size #{surface}"
    # cmd << "-size 300x100"
    # cmd << "label:\"ESSAI\""
    # cmd << "-background none"
    # cmd << "-trim"
    # cmd << "-gravity #{GRAVITIES[:part]}"
    # # -extent #{surface}
    # cmd << "-extent 300x100 \\)"

    # cmd << "-gravity northwest"
    # # cmd << "-geometry +#{left}+#{top}"
    # cmd << "-geometry +10+10"
    # cmd << "-composite"

    #
    # L'espace de couleur
    # 
    cmd << "\n-set colorspace sRGB"

    #
    # Chemin d'accès au fichier final
    # (en le protégeant)
    # 
    cmd << " \"#{image_path.gsub(/ /, "\\ ")}\""

    # STDOUT.write "\n\ncmd à la fin =\n++++\n#{cmd}\n+++++\n".orange

    #
    # Mise de la commande sur une seule ligne
    # (je ne parviens pas à mettre la commande sur plusieurs lignes,
    #  même avec la contre-balance…)
    cmd_finale = cmd.split("\n").compact.join(" ")
    
    
    # Pour débugger facilement, on met les numéros des lignes
    
    cmd_debug = cmd_finale.split("\n").collect.with_index do |line, idx|
      "#{idx + 1}: #{line.strip}"
    end.join("\n")
    STDOUT.write "\n\nCommande finale\n#{cmd_debug}\n".bleu

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
    puts "Image #{image_path.inspect} produite avec succès."

  end #/ build



  # @return \Array<Node> Liste des actes du paradigme
  # 
  def actes
    @actes ||= begin
      pfa.data.values.select do |node|
        node.type == :part
      end
    end
  end


  # @return \String Chemin d'accès au fichier de l'image finale
  def image_path
    @image_path ||= File.expand_path(File.join('.','pfa.jpg'))
    # @image_path ||= File.expand_path(File.join('.','pfa.img'))
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