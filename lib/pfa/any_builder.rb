module PFA
class RelativePFA
class AnyBuilder

  #
  # Largeur totale du graphique
  # (noter que les dimensions sont les mêmes pour l'image JPG et 
  # l'image HTML)
  #  
  PFA_WIDTH   = 4000 # 4000px (en 300dpi)

  # 
  # Hauteur du graphique
  # 
  PFA_HEIGHT  = PFA_WIDTH / 4

  #
  # Marge gauche
  # 
  # PFA_LEFT_MARGIN   = 150
  PFA_LEFT_MARGIN   = 0

  #
  # Marge droite du graphique
  # 
  # PFA_RIGHT_MARGIN  = 150
  PFA_RIGHT_MARGIN  = 0

  #
  # Hauteur d'une "ligne"
  # (une ligne est considérée comme une grille de référence, large)
  # 
  LINE_HEIGHT = (PFA_HEIGHT.to_f / 15).to_i

  #
  # Différence en hauteur du paradigme réel par rapport au paradigme
  # idéal
  # 
  VOFFSET_REL_PFA = 9 * LINE_HEIGHT

  #
  # Position verticale des éléments en fonction de leur nature
  # 
  ABS_TOPS = {
    part:         1 * LINE_HEIGHT,      
    sequence:     3 * LINE_HEIGHT,       
    noeud:        3 * LINE_HEIGHT,
    top_horloge:  LINE_HEIGHT - 10
  }
  ABS_BOTTOMS = {
    part:         ABS_TOPS[:part]     + 6 * LINE_HEIGHT,
    sequence:     ABS_TOPS[:sequence] + 6 * LINE_HEIGHT,
    noeud:        ABS_TOPS[:noeud]    + 6 * LINE_HEIGHT,
  }

  TOPS = {
    part:         ABS_BOTTOMS[:part],
    sequence:     ABS_TOPS[:sequence]     + VOFFSET_REL_PFA,  
    noeud:        ABS_TOPS[:noeud]        + VOFFSET_REL_PFA,
    top_horloge:  ABS_TOPS[:top_horloge]  + VOFFSET_REL_PFA,
  }
  
  BOTTOMS = {
    part:       ABS_BOTTOMS[:part] + VOFFSET_REL_PFA,
    sequence:   ABS_BOTTOMS[:sequence] + VOFFSET_REL_PFA,
    noeud:      ABS_BOTTOMS[:noeud] + VOFFSET_REL_PFA,
  }

  RECTIFS = {
    part:         50, 
    sequence:     0, 
    noeud:        0
  }

  #
  # Hauteur en fonction du type des éléments 
  # 
  HEIGHTS = { 
    part:     PFA_HEIGHT / 1.4,
    sequence: 50, # PFA::LINE_HEIGHT (dans fichier relatif)
    noeud:    50  # idem
  }

  #
  # Taille de police en fonction du type de l'élément
  # 
  ABS_FONTSIZES = {
    part:     10,
    sequence: 8,
    noeud:    7
  }
  FONTSIZES = {
    part:     7, 
    sequence: 7, 
    noeud:    7
  }

  #
  # Graisse de la police en fonction du type de l'élément
  # 
  ABS_FONTWEIGHTS = {
    part:     3,
    sequence: 2,
    noeud:    1
  }
  FONTWEIGHTS = { 
    part:     1,
    sequence: 1, 
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
  ABS_BORDERS = {
    part:     3,
    sequence: 2,
    noeud:    1
  }
  BORDERS = {
    part:     1,
    sequence: 1, 
    noeud:    1
  }

  #
  # Les nœuds minimums pour pouvoir construire un PFA
  # 
  REQUIRED_NODES_FOR_BUILDING = [
    :exposition,
    :incident_declencheur,
    :pivot1,
    :developpement_part1,
    :developpement_part2,
    :pivot2,
    :denouement,
    :climax,
  ]

  # Instance \PFA::RelativePFA du paradigme de Field augmenté
  attr_reader :pfa

  def initialize(pfa)
    @pfa = pfa
  end
  
end #/class AnyBuilder
end #/class RelativePFA
end #/module PFA
