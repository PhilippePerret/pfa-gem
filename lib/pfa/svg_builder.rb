#
# Module de construction de l'image CVG
# 
require_relative 'any_builder'
module PFA
class RelativePFA
class SVGBuilder < AnyBuilder

  # --- CONSTANTES POUR SVG ---

  #
  # Largeur totale du graphique
  #  
  PFA_WIDTH   = 4000 # 4000px (en 300dpi)

  # 
  # Hauteur du graphique
  # 
  PFA_HEIGHT  = PFA_WIDTH / 4

  #
  # Marge gauche
  # 
  PFA_LEFT_MARGIN   = 150

  #
  # Marge droite du graphique
  # 
  PFA_RIGHT_MARGIN  = 150

  #
  # Hauteur d'une "ligne"
  # 
  LINE_HEIGHT = (PFA_HEIGHT.to_f / 15).to_i


  #
  # Coefficiant pixel pour l'affichage
  # 
  # On multiplie le nombre de faux-pixels (120 par film) par ce nombre
  # pour obtenir la position ou la dimension des éléments dans l'image
  # SVG
  # 
  COEF_PIXELS = (PFA_WIDTH - PFA_LEFT_MARGIN - PFA_RIGHT_MARGIN).to_f / 120

  def self.realpos(val)
    (PFA_LEFT_MARGIN + realpx(val)).to_i
  end

  def self.realpx(val)
    (val * COEF_PIXELS).to_i
  end

  #
  # Position verticale des éléments en fonction de leur nature
  # 
  TOPS = {
    part:     1 * PFA_HEIGHT,      
    sequence: 3 * PFA_HEIGHT,       
    noeud:    3 * PFA_HEIGHT
  }

  #
  # Hauteur en fonction du type des éléments 
  # 
  HEIGHTS = { 
    part:     PFA_HEIGHT/1.4,
    sequence: 50,
    noeud:    50
  }

  #
  # Taille de police en fonction du type de l'élément
  # 
  FONTSIZES = {
    part:     10,
    sequence: 8,
    noeud:    7
  }

  #
  # Graisse de la police en fonction du type de l'élément
  # 
  FONTWEIGHTS = {
    part:     3,
    sequence: 2,
    noeud:    1
  }

  #
  # Couleur en fonction du type de l'élément
  # 
  COLORS = {
    part:     'gray75',
    sequence: 'gray55',
    noeud:    'gray55' 
  }

  #
  # Couleur plus sombre en fonction de l'élément
  # 
  DARKERS = {
    part:     'gray50',
    sequence: 'gray45',
    noeud:    'gray45' 
  }

  # 
  # Gravité en fonction du type de l'élément
  # 
  GRAVITIES = {
    part:     'Center',
    sequence: 'Center',
    noeud:    'Center'
  }

  #
  # Largeur des bords en fonction du type de l'élément
  # 
  BORDERS = {
    part:     3,
    sequence: 2,
    noeud:    1
  }

  # 
  # Positions et Dimensions du PFA RELATIF
  # 
  REL_PFA_MEASUREMENTS = {
  
    top:          7 * LINE_HEIGHT,
    top_horloge:  7 * LINE_HEIGHT + 10,
  
  }.freeze

  #
  # Positions et dimensions du PFA ABSOLU
  # 
  ABS_PFA_MEASUREMENTS = {
    
    top_horloge: REL_PFA_MEASUREMENTS[:top] - LINE_HEIGHT + 10

  }


  # -- Commande ImageMagick --
  
  CONVERT_CMD = 'convert' # /usr/local/bin/convert si pas d'alias



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
    # L'espace de couleur
    # 
    cmd << "-set colorspace sRGB"

    #
    # Chemin d'accès au fichier final
    # (en le protégeant)
    # 
    cmd << image_path.gsub(/ /, "\\ ")

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
    @image_path ||= File.expand_path(File.join('.','pfa.svg'))
  end

  private



end #/class SVGBuilder
end #/class RelativePFA
end #/module PFA
