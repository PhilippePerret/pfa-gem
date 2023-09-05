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
    if MagickPFA.const_defined?(const_name)
      # dbg "Je dois détruire la constante #{key.to_s.upcase}".orange
      MagickPFA.send(:remove_const, const_name)
    end
    if MagickPFA.const_defined?(const_name)
      MagickPFA.send(:remove_const, const_name)
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
      # Object.const_set(const_name, value)
      # self.class.const_set(const_name, value)
      MagickPFA.const_set(const_name, value)
    end

    #
    # Définition de la hauteur de ligne 
    # 
    rem_const_if_exists('LINE_HEIGHT') # tests
    MagickPFA.const_set('LINE_HEIGHT', (MagickPFA::PFA_HEIGHT.to_f / 15).to_i)

    #
    # Différence en hauteur du paradigme réel par rapport au paradigme
    # idéal
    # 
    rem_const_if_exists('VOFFSET_REL_PFA') # tests
    MagickPFA.const_set('VOFFSET_REL_PFA', 9 * MagickPFA::LINE_HEIGHT)

    #
    # Position verticale des éléments en fonction de leur nature
    # 
    rem_const_if_exists('ABS_TOPS') # tests
    MagickPFA.const_set('ABS_TOPS', {
        part:         1 * MagickPFA::LINE_HEIGHT,      
        sequence:     3 * MagickPFA::LINE_HEIGHT,       
        noeud:        3 * MagickPFA::LINE_HEIGHT,
        top_horloge:  MagickPFA::LINE_HEIGHT - 10
    })
    rem_const_if_exists('ABS_BOTTOMS') # tests
    MagickPFA.const_set('ABS_BOTTOMS', {
      part:         MagickPFA::ABS_TOPS[:part]     + 6 * MagickPFA::LINE_HEIGHT,
      sequence:     MagickPFA::ABS_TOPS[:sequence] + 6 * MagickPFA::LINE_HEIGHT,
      noeud:        MagickPFA::ABS_TOPS[:noeud]    + 6 * MagickPFA::LINE_HEIGHT,
    })
    rem_const_if_exists('TOPS') # tests
    MagickPFA.const_set('TOPS', {
      part:         MagickPFA::ABS_BOTTOMS[:part],
      sequence:     MagickPFA::ABS_TOPS[:sequence]     + MagickPFA::VOFFSET_REL_PFA,  
      noeud:        MagickPFA::ABS_TOPS[:noeud]        + MagickPFA::VOFFSET_REL_PFA,
      top_horloge:  MagickPFA::ABS_TOPS[:top_horloge]  + MagickPFA::VOFFSET_REL_PFA,
    })
    rem_const_if_exists('BOTTOMS') # tests
    MagickPFA.const_set('BOTTOMS', {
      part:       MagickPFA::ABS_BOTTOMS[:part]      + MagickPFA::VOFFSET_REL_PFA,
      sequence:   MagickPFA::ABS_BOTTOMS[:sequence]  + MagickPFA::VOFFSET_REL_PFA,
      noeud:      MagickPFA::ABS_BOTTOMS[:noeud]     + MagickPFA::VOFFSET_REL_PFA,
    })
    #
    # Hauteur en fonction du type des éléments 
    # 
    rem_const_if_exists('HEIGHTS') # tests
    MagickPFA.const_set('HEIGHTS', { 
      part:     MagickPFA::PFA_HEIGHT / 1.4,
      sequence: 50, # PFA::LINE_HEIGHT (dans fichier relatif)
      noeud:    50  # idem
    })

  end # define_dims_constants

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
