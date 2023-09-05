#
# Module de construction de l'image CVG
# 
require_relative 'any_builder'
module PFA
class RelativePFA
class ImgBuilder < AnyBuilder


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
  # Construction de l'image du paradigme
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
      cmd << acte.img_draw_command
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
    
    STDOUT.write "\n\nCommande finale\n#{cmd}\n".bleu

    #
    # *** EXÉCUTION DE LA COMMANDE ***
    # 
    res_err = `#{cmd} 2>&1`

    unless res_err.nil? || res_err.empty?
      raise PFAFatalError.new(5001, *{error: res_err})
      # STDOUT.write  "res : #{res.inspect}\n".rouge
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
    (PFA_WIDTH - PFA_LEFT_MARGIN - PFA_RIGHT_MARGIN).to_f / pfa.duree.to_i
  end


end #/class ImgBuilder
end #/class RelativePFA
end #/module PFA
