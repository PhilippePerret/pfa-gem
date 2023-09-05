module PFA
class RelativePFA
class AnyBuilder

  #
  # Largeur totale du graphique
  # (noter que les dimensions sont les mêmes pour l'image JPG et 
  # l'image HTML)
  # 
  # @note
  #   Les tailles sont calculées pour un livre de 
  #   5.25 po (1334 mm) x 8 po (2032 mm)
  #   avec des marges de 20 mm
  #   Donc une surface utilisable de :
  #       1334 - 2 * 20 = 1334 - 40 = 1294
  #     x 2032 - 2 * 20 = 2032 - 40 = 1992
  # 
  #   Comme l'image sera mise "de travers" dans la page, sa largeur
  #   sera de 1992 et sa hauteur 1294. On triple pour obtenir une 
  #   bonne taille pour l'imprimerie.
  #   Donc :
  #     3 x 1992 = 5976 px en largeur (PFA_WIDTH)
  #     3 x 1294 = 3882 px en hauteur (PFA_HEIGHT)
  # 
  #   Soit un rapport de  5976 / 3882 = 1,5394
  # 
  #   Pour les tests, on utilise les valeurs
  #   4000 px x 2598 px (4000 / 1,5394)
  #
  DIMS_CONSTANTS_PER_THING = {
    real_book: {
      pfa_width: 5976, pfa_height: 3882, pfa_left_margin: 0, pfa_right_margin:0
    },
    test: {
      pfa_width: 4000, pfa_height: 2598, pfa_left_margin: 20, pfa_right_margin:20
    },
  }

  def self.rem_const_if_exists(const_name)
    if AnyBuilder.const_defined?(const_name)
      # dbg "Je dois détruire la constante #{key.to_s.upcase}".orange
      Object.send(:remove_const, const_name)
    end
  end
  # Définition des dimensions
  # 
  # @param params [Symbol|Hash]
  #         Soit la clé dans la table DIMS_CONSTANTS_PER_THING
  #         Soit une table définissant :pfa_width, :pfa_height,
  #         :pfa_left_margin, pfa_right_margin
  # 
  def self.define_dims_constants(key_thing)

    params = nil
    case key_thing
    when Symbol then params = DIMS_CONSTANTS_PER_THING[key_thing]
    when Hash   then params = key_thing
    else raise PFAFatalError.new(101)
    end

    params.each do |key, value|
      const_name = key.to_s.upcase
      rem_const_if_exists(const_name)
      Object.const_set(const_name, value)
    end

    #
    # Définition de la hauteur de ligne 
    # 
    rem_const_if_exists('LINE_HEIGHT') # tests
    Object.const_set('LINE_HEIGHT', (PFA_HEIGHT.to_f / 15).to_i)

    #
    # Différence en hauteur du paradigme réel par rapport au paradigme
    # idéal
    # 
    rem_const_if_exists('VOFFSET_REL_PFA') # tests
    Object.const_set('VOFFSET_REL_PFA', 9 * LINE_HEIGHT)

    #
    # Position verticale des éléments en fonction de leur nature
    # 
    rem_const_if_exists('ABS_TOPS') # tests
    Object.const_set('ABS_TOPS', {
        part:         1 * LINE_HEIGHT,      
        sequence:     3 * LINE_HEIGHT,       
        noeud:        3 * LINE_HEIGHT,
        top_horloge:  LINE_HEIGHT - 10
    })
    rem_const_if_exists('ABS_BOTTOMS') # tests
    Object.const_set('ABS_BOTTOMS', {
      part:         ABS_TOPS[:part]     + 6 * LINE_HEIGHT,
      sequence:     ABS_TOPS[:sequence] + 6 * LINE_HEIGHT,
      noeud:        ABS_TOPS[:noeud]    + 6 * LINE_HEIGHT,
    })
    rem_const_if_exists('TOPS') # tests
    Object.const_set('TOPS', {
      part:         ABS_BOTTOMS[:part],
      sequence:     ABS_TOPS[:sequence]     + VOFFSET_REL_PFA,  
      noeud:        ABS_TOPS[:noeud]        + VOFFSET_REL_PFA,
      top_horloge:  ABS_TOPS[:top_horloge]  + VOFFSET_REL_PFA,
    })
    rem_const_if_exists('BOTTOMS') # tests
    Object.const_set('BOTTOMS', {
      part:       ABS_BOTTOMS[:part] + VOFFSET_REL_PFA,
      sequence:   ABS_BOTTOMS[:sequence] + VOFFSET_REL_PFA,
      noeud:      ABS_BOTTOMS[:noeud] + VOFFSET_REL_PFA,
    })
    #
    # Hauteur en fonction du type des éléments 
    # 
    rem_const_if_exists('HEIGHTS') # tests
    Object.const_set('HEIGHTS', { 
      part:     PFA_HEIGHT / 1.4,
      sequence: 50, # PFA::LINE_HEIGHT (dans fichier relatif)
      noeud:    50  # idem
    })

  end # define_dims_constants

  RECTIFS = {
    part:         50, 
    sequence:     0, 
    noeud:        0
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
