#
# Module inclus dans la classe RelativePFA::Node
# 
# @note
# 
#   On le met en module pour avoir toutes les méthodes séparées
#   du module principal.
# 
module MagickPFA


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
      pfa_width: 5976, pfa_height: 3882, pfa_left_margin: 0, pfa_right_margin:0,
      font_size: 15
    },
    test: {
      pfa_width: 4000, pfa_height: 2598, pfa_left_margin: 20, pfa_right_margin:20,
      font_size: 15
    },
    default: {
      pfa_width: 4000, pfa_height: 2598, pfa_left_margin: 20, pfa_right_margin:20,
      font_size: 15
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
    when Hash
      #
      # Table fournie
      # (dans ce cas, il faut vérifier les valeurs et mettre les
      #  valeurs par défaut des valeurs manquantes)
      # 
      params = key_thing
      DIMS_CONSTANTS_PER_THING[:default].each do |key, value|
        params.key?(key) || params.merge!(key => value)
      end
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
    MagickPFA.const_set('VOFFSET_REL_PFA', 6 * MagickPFA::LINE_HEIGHT)

    #
    # Position verticale des éléments en fonction de leur nature
    # 
    rem_const_if_exists('ABS_TOPS') # tests
    MagickPFA.const_set('ABS_TOPS', {
        part:         0,      
        sequence:     3 * LINE_HEIGHT,       
        noeud:        3 * LINE_HEIGHT,
        top_horloge:  LINE_HEIGHT - 10
    })
    rem_const_if_exists('ABS_BOTTOMS') # tests
    MagickPFA.const_set('ABS_BOTTOMS', {
      part:         ABS_TOPS[:part]     + VOFFSET_REL_PFA - LINE_HEIGHT,
      sequence:     ABS_TOPS[:sequence] + VOFFSET_REL_PFA,
      noeud:        ABS_TOPS[:noeud]    + VOFFSET_REL_PFA,
    })
    rem_const_if_exists('TOPS') # tests
    MagickPFA.const_set('TOPS', {
      part:         ABS_BOTTOMS[:part],
      sequence:     ABS_TOPS[:sequence]     + VOFFSET_REL_PFA,  
      noeud:        ABS_TOPS[:noeud]        + VOFFSET_REL_PFA,
      top_horloge:  ABS_TOPS[:top_horloge]  + VOFFSET_REL_PFA,
    })
    rem_const_if_exists('BOTTOMS') # tests
    MagickPFA.const_set('BOTTOMS', {
      part:       ABS_BOTTOMS[:part]      + VOFFSET_REL_PFA,
      sequence:   ABS_BOTTOMS[:sequence]  + VOFFSET_REL_PFA,
      noeud:      ABS_BOTTOMS[:noeud]     + VOFFSET_REL_PFA,
    })
    #
    # Hauteur en fonction du type des éléments 
    # 
    rem_const_if_exists('HEIGHTS') # tests
    MagickPFA.const_set('HEIGHTS', { 
      part:     PFA_HEIGHT / 1.4,
      sequence: 50, # PFA::LINE_HEIGHT (dans fichier relatif)
      noeud:    50  # idem
    })

    #
    # Taille de fonte de base. Elle correspond à la grosseur
    # des séquences
    # 
    # @todo
    #   Plus tard, on pourra modifier aussi les proportions de
    #   chaque taille de partie
    # 
    rem_const_if_exists('BASE_FONTSIZE') # tests
    MagickPFA.const_set('BASE_FONTSIZE', params[:font_size])

  end # define_dims_constants


  # -- Commande ImageMagick --
  
  CONVERT_CMD = 'convert' # /usr/local/bin/convert si pas d'alias

  # Le début du code de la commande convert
  def self.code_for_intro
    <<~CMD.strip + "\n"
    #{CONVERT_CMD} -size #{PFA_WIDTH}x#{PFA_HEIGHT} xc:white 
    -units PixelsPerInch
    -density 300
    -background transparent
    -set colorspace sRGB
    CMD
  end

  #
  # Pour écrire le titre du paradigme
  CODE_TITRE_PARADIGME = <<~CMD.strip.freeze
    -pointsize 25
    -draw "text %{lf},%{tp} '%{titre}'"
  CMD

  CODE_BOITE_ACTE = <<~CMD.strip.freeze
    -stroke black
    -strokewidth 3
    -background transparent
    -fill transparent
    -draw "rectangle %{lf},%{tp} %{rg},%{bt}"
  CMD


  # [BashString] Code pour dessiner le noeud, quand c'est un acte,
  # dans l'image.
  def abs_act_box_code
    # @note : Le + LINE_HEIGHT servira à écrire le titre "PARADIGME RÉEL/IDÉAL DU FILM"
    CODE_BOITE_ACTE % {
      lf: abs_left, tp: abs_top + LINE_HEIGHT, rg: abs_right, bt: abs_bottom
    }
  end
  def titre_abs_pfa
    CODE_TITRE_PARADIGME % {lf: 20, tp: abs_top + LINE_HEIGHT - 20, titre: "PARADIGME IDÉAL DU FILM"}
  end

  def titre_real_pfa
    CODE_TITRE_PARADIGME % {lf: 20, tp: top + LINE_HEIGHT - 20, titre: "PARADIGME (RÉEL) DU FILM"}
  end
  # [BashString] Code pour dessiner le noeud, quand c'est un acte,
  # dans l'image.
  def act_box_code
    # @note : Le + LINE_HEIGHT servira à écrire le titre "PARADIGME RÉEL/IDÉAL DU FILM"
    CODE_BOITE_ACTE % {lf: left, tp: top + LINE_HEIGHT, rg: right, bt: bottom}
  end

  # @return [Array<BashString>] le code Image Magick pour construire 
  # le noeud courant, ligne à ligne
  # Cette méthode est appelée par tous les types de noeud et permet
  # de générer le code qui les dessinera sur l'image.
  # 
  # @note
  # 
  #   Ce code retourne le code pour le paradigme absolu comme pour
  #   le paradigme relatif. À l'avenir, il serait possible de n'en
  #   obtenir qu'un seul. D'où le paramètre +options+ qui est 
  #   inutilisé pour le moment
  # 
  #   On concerve les lignes pour pouvoir localiser facilement les
  #   erreurs éventuelles.
  # 
  def full_code_image_magick(**options)
    code_image_magick << "\n" + full_abs_code_image_magick
    # code_image_magick << "\n" + full_real_code_image_magick
  end

  #
  # 
  # L'ordre est important
  # ---------------------
  #   label:"LABEL" -gravity Center
  #   # => Place le texte au nord-ouest (s'il n'y a aucune indication avant)
  #   -gravity Center label:"LABEL"
  #   # => Place le texte au centre horizontal et vertical
  # 
  # 

  # @return [Array<BashString>] Les lignes pour construire le noeud,
  # en version absolue (i.e. PFA idéal en fonction de la durée du film)
  def full_abs_code_image_magick
    co = COLORS[type]
    fw = ABS_FONTWEIGHTS[type]
    fs = abs_font_size
    # is = img_abs_surface
    is = '1494x200'
    mk = mark
    al = abs_left
    <<~CMD.strip
    #{send("img_lines_for_abs_#{type}".to_sym)}
    \\( -background red -stroke #{co} -strokewidth #{fw} -pointsize #{fs} -size #{is} -trim -extent #{is} -gravity Center label:"#{mk}" \\)
    -gravity NorthWest -geometry +0+#{abs_bottom - demiheight} -composite
    #{abs_start.as_img_horloge_code(self, **{pfa_type: :ideal, gravity:'northwest'})}
    CMD
  end
  #     -gravity #{GRAVITIES[type]}
  # -background none

  def full_real_code_image_magick
    <<~CMD.strip + "\n" + code_image_magick_labels_real
    #{send("img_lines_for_real_#{type}".to_sym)}
    CMD
  end
  def code_image_magick_labels_real
    <<~CMD.strip.tap { |c| dbg("-> code_image_magick_labels_real\n#{c}".orange) }
    -pointsize #{font_size}
    -strokewidth #{FONTWEIGHTS[type]}
    -gravity Center
    -draw "text #{left},200 '#{mark}'"
    #{start_at.as_img_horloge_code(self, **{pfa_type: :real, abs_time: abs_start, gravity:'northwest'})}
    CMD
  end
  # -annotate +#{left + width / 2}+#{demiheight} "#{mark}" (fonctionne pour mettre le label)
  def OLD_code_image_magick_labels_real
    <<~CMD.strip.tap { |c| dbg("-> code_image_magick_labels_real\n#{c}".orange) }
    \\(
    -stroke #{COLORS[type]}
    -fill #{COLORS[type]}
    -strokewidth #{FONTWEIGHTS[type]}
    -pointsize #{font_size}
    -annotate +10+100 '#{mark}'
    -background transparent
    -size #{img_surface}
    -trim
    -gravity #{GRAVITIES[type]}
    \\)
    -gravity Center
    -geometry +#{left}+1000
    -composite
    #{start_at.as_img_horloge_code(self, **{pfa_type: :real, abs_time: abs_start, gravity:'northwest'})}
    CMD
  end
    # label:"#{mark}"   # attention : pas de "-" (tiret)
  #   -size #{img_surface}
  #   -extent #{img_surface}
    # -extent 500x500


  # La marque pour une partie absolue (un rectangle)
  def img_lines_for_abs_part
    # La boite de l'acte idéal
    <<~CMD.strip#.tap { |c| dbg("-> img_lines_for_abs_part :\n#{c}".orange) }
    -background transparent
    -stroke #{DARKERS[:part]}
    -fill white
    -strokewidth #{ABS_BORDERS[:part]}
    -draw "rectangle #{abs_left},#{abs_top} #{abs_right},#{abs_bottom}"
    CMD
  end

  # La boite de l'acte du paradigme réel (et seulement la boite)
  def img_lines_for_real_part
    <<~CMD.strip#.tap {|s| dbg("img_lines_for_real_part :\n#{s}".bleu) }
    -background transparent
    -stroke #{DARKERS[:part]}
    -fill transparent
    -strokewidth #{ABS_BORDERS[:part]}
    -draw "rectangle #{left},#{top} #{right},#{bottom}"
    CMD
  end



  # La marque pour une séquence (un crochet allongé)
  def img_lines_for_real_sequence
    <<~CMD
    -strokewidth #{AnyBuilder::BORDERS[:seq]}
    -stroke #{AnyBuilder::COLORS[:seq]}
    -fill white
    -draw "polyline #{left+4},#{top+demiheight} #{left+4},#{bottom} #{right-4},#{bottom} #{right-4},#{top+demiheight}"
    #{mark_horloge}
    CMD
  end

  # La marque pour un nœud (un rond/point)
  def img_lines_for_real_noeud
    <<~CMD
    -strokewidth #{AnyBuilder::BORDERS[:noeud]}
    -stroke #{AnyBuilder::COLORS[:noeud]}
    -fill white
    -draw "roundrectangle #{left},#{top} #{right},#{bottom} 10,10"
    #{mark_horloge}
    CMD
  end

  RECTIFS = {
    part:         50, 
    sequence:     0, 
    noeud:        0
  }

  #
  # Taille de police en fonction du type de l'élément
  # (c'est un type proportionnel en fonction de la taille fournie
  #  cela permet d'ajuster les choses)
  # 
  ABS_FONTSIZES = {
    part:     2.4,
    sequence: 1.5,
    noeud:    1
  }
  FONTSIZES = {
    part:     1.5,
    sequence: 1.5,
    noeud:    1
  }
  HORLOGE_FONT_SIZES = {
    part:     0.81,
    sequence: 0.81,
    noeud:    0.81,
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

end
