#
# Module de construction de l'image CVG
# 
require_relative 'any_builder'
module PFA
class RelativePFA
class SVGBuilder < AnyBuilder

  # --- CONSTANTES POUR SVG ---


  #
  # Coefficiant pixel pour l'affichage
  # 
  # On multiplie le nombre de faux-pixels (120 par film) par ce nombre
  # pour obtenir la position ou la dimension des éléments dans l'image
  # SVG
  # 
  # COEF_PIXELS = (PFA_WIDTH - PFA_LEFT_MARGIN - PFA_RIGHT_MARGIN).to_f / (120 * 60)
  # NON : MAINTENANT ON LE CALCULE EN FONCTION DE LA DURÉE DU FILM

  def self.realpos(val)
    (PFA_LEFT_MARGIN + realpx(val)).to_i
  end

  # Return le nombre de pixels en fonction du nombre de secondes +secs+
  def self.s2px(secs)
    (secs * COEF_PIXELS).to_i
  end
  class << self
    alias :realpx :s2px
  end


  # -- Commande ImageMagick --
  
  CONVERT_CMD = 'convert' # /usr/local/bin/convert si pas d'alias


  # Initialisation avant la construction
  def init
    # COEF_PIXELS =  / (120 * 60)
  end

  def coef_pixels
    @coef_pixels ||= calc_coefficient_pixels
  end


  ##########################################
  ### MÉTHODE PRINCIPALE DE CONSTRUCTION ###
  ##########################################
  # Construction de l'image SVG du paradigme
  # 
  def build(**options)
    #
    # Le PFA doit être défini au minimum et ses données doivent être
    # valides.
    # 
    pfa.valid?

    #
    # On doit calculer le coefficient pixels par rapport à la durée
    # du film
    #
    init

    #
    #
    # Détruire l'image si elle existe déjà
    # 
    File.delete(image_path) if File.exist?(image_path)

    # 
    # Construction du code pour Image Magick
    # (dans cmd)
    # 
    cmd = []
    cmd << "#{CONVERT_CMD} -size #{PFA_WIDTH}x#{PFA_HEIGHT}"
    cmd << "xc:white"
    cmd << "-units PixelsPerInch -density 300"
    cmd << "-background white -stroke black"

    #
    # Le fond, avec les actes
    # 
    actes.each do |acte|
      puts "Traitement de l'acte #{acte.mark.inspect}"
      cmd << acte.svg_draw_command
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
    cmd << "-set colorspace sRGB"

    #
    # Chemin d'accès au fichier final
    # (en le protégeant)
    # 
    cmd << "\"#{image_path.gsub(/ /, "\\ ")}\""

    #
    # Mise de la commande sur une seule ligne
    # 
    cmd = cmd.join(' ')
    
    puts "\n\nCommande finale\n#{cmd}".bleu
    #
    # *** EXÉCUTION DE LA COMMANDE ***
    # 
    res = `#{cmd} 2>&1`

    puts "res : #{res.inspect}"

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
  end

  # @private

  # Calcule le coefficiant pixels qui permet de convertir un temps
  # quelconque en pixels en fonction de la durée du film analysé.
  # Produira la constant COEF_PIXELS
  # 
  def calc_coefficient_pixels
    (PFA_WIDTH - PFA_LEFT_MARGIN - PFA_RIGHT_MARGIN).to_f / pfa.duree.to_i
  end


end #/class SVGBuilder
end #/class RelativePFA
end #/module PFA
