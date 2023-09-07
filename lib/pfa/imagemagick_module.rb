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

    rem_const_if_exists('QUART_LINE_HEIGHT') # tests
    MagickPFA.const_set('QUART_LINE_HEIGHT', LINE_HEIGHT / 4)

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

    # Taille de fonte des horloges par partie
    rem_const_if_exists('FontSize_Horloges') # tests
    MagickPFA.const_set('FontSize_Horloges', {
      part:     1.0 * BASE_FONTSIZE,
      sequence: 0.9 * BASE_FONTSIZE,
      noeud:    0.8 * BASE_FONTSIZE,
    })
    rem_const_if_exists('Horloge_Width') # tests
    MagickPFA.const_set('Horloge_Width', {
      part:     250,
      sequence: 200,
      noeud:    200
    })
    rem_const_if_exists('Horloge_Height') # tests
    MagickPFA.const_set('Horloge_Height', {
      part:     80,
      sequence: 50,
      noeud:    50
    })

  end # define_dims_constants


  # -- Commande ImageMagick --
  
  CONVERT_CMD = 'convert' # /usr/local/bin/convert si pas d'alias

  # Le début du code de la commande convert
  def self.code_for_intro
    <<~CMD.strip
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

  CODE_PART_NAME = <<~CMD.strip.freeze
    \\( -extent %{w}x%{h} -stroke black -strokewidth 1 -background transparent -pointsize %{fs} -gravity Center label:"%{n}" \\) -geometry +%{gh}+%{gv} -gravity NorthWest -composite
  CMD
  # {
  #   w: width, h: font_height + 20, n: mark, fs: font_size, 
  #   gh: left,               # pour la géométrie, décalage par rapport au Nord-Ouest
  #   gv: top + LINE_HEIGHT,  # pour la géométrie, décalage vertical
  # }

  # --- HORLOGES ---

  # Code ImageMagick de l'horloge pour les parties
  # 
  CODE_HORLOGE_PART = <<~CMD.strip.freeze
    -pointsize %{fs}
    -stroke gray20
    -strokewidth 1
    -fill gray20
    -background transparent
    -gravity NorthWest
    -draw "text %{l},%{t} '%{mk}'"
    CMD
  CODE_HORLOGE_FIN = <<~CMD.strip.freeze
    -pointsize %{fs}
    -stroke gray20
    -strokewidth 1
    -fill gray20
    -background transparent
    -gravity NorthEast
    -draw "text 30,%{t} '%{mk}'"
    CMD
  # Code ImageMagick pour indiquer le décalage entre le temps réel
  # et le temps absolu.
  CODE_OFFSET = <<~CMD.strip.freeze
    \\( -extent %{wo}x%{ho} -pointsize %{fso} -background %{bgo}
    -fill %{fgo} -stroke %{fgo} -strokewidth 1 -gravity Center 
    label:"%{mko}" \\) -geometry +%{lo}+%{to} -gravity NorthWest -composite    
    CMD
  # Code ImageMagick de l'horloge pour les autres choses
  # 
  CODE_HORLOGE_AUTRES = <<~CMD.strip.freeze
    \\( -pointsize %{fs} \\)
    CMD
  CODE_HORLOGE_PER_TYPE = {
    part:     CODE_HORLOGE_PART,
    sequence: CODE_HORLOGE_AUTRES, 
    noeud:    CODE_HORLOGE_AUTRES, 
  }
  def horloge_code(real_pfa)
    start_ntime = real_pfa ? start_at : abs_start
    #
    # Si c'est le noeud réel, il faut calculer son décalage avec le
    # noeud absolu
    # 
    start_at.calc_offset(abs_start) if real_pfa
    #
    # Les données template en fonction du pfa absolu ou réel
    # 
    data_template = {
      w:    Horloge_Width[type],  # largeur (sauf pour actes)
      # h:    30, # hauteur de l'horloge (surtout pour décalage)
      l:    (real_pfa ? left : abs_left) + 40,  # left de l'horloge
      t:    (real_pfa ? top : abs_top) + 500,  # top de l'horloge (et du décalage)
      fs:   FontSize_Horloges[type], # Font size
      mk:   start_ntime.to_horloge, # Horloge
    }
    #
    # On ajoute les valeurs pour le pfa réel
    # 
    data_template.merge!({
      wo:   Horloge_Width[type] - 50,  # largeur (sauf pour actes)
      ho:   Horloge_Height[type],
      lo:   (real_pfa ? left : abs_left) + Horloge_Width[type] + 10, # left de la marque de décalage
      to:   data_template[:t] -20,  # top du décalage
      fso:  FontSize_Horloges[type] - 2, # Font size pour le décalage
      mko:  start_ntime.offset_as_horloge(abs_start), # marque du décalage
            # @note
            #   Il faut impérativement appeler offset_as_horloge avant
            #   le reste ci-dessous, 
      bgo:  start_ntime.background_per_offset, # background du décalage 
      fgo:  start_ntime.foreground_per_offset, # couleur du décalage      
    }) if real_pfa

    code =  CODE_HORLOGE_PER_TYPE[type]
    code += ' ' + CODE_OFFSET if real_pfa
    code % data_template
  end
  
  # [BashCode] Code ImageMagick pour le titre des paradigmes
  def titre_abs_pfa
    CODE_TITRE_PARADIGME % {lf: 20, tp: abs_top + LINE_HEIGHT - 20, titre: "PARADIGME IDÉAL DU FILM"}
  end
  def titre_real_pfa
    CODE_TITRE_PARADIGME % {lf: 20, tp: top + LINE_HEIGHT - 20, titre: "PARADIGME RÉEL DU FILM"}
  end

  # [BashString] Code pour dessiner le noeud, quand c'est un acte,
  # dans l'image.
  def act_box_code(real_pfa)
    # @note : Le + LINE_HEIGHT sert à laisser la place pour écrire 
    # le titre "PARADIGME RÉEL/IDÉAL DU FILM"
    CODE_BOITE_ACTE % {
      lf: real_pfa ? left : abs_left, 
      tp: (real_pfa ? top : abs_top) + LINE_HEIGHT, 
      rg: real_pfa ? right : abs_right, 
      bt: real_pfa ? bottom : abs_bottom
    }
  end

  # [BashString] Code pour dessiner les noms des parties (actes)
  # 
  def abs_act_name_code
    CODE_PART_NAME % {
      w: abs_width, h: abs_font_size + 100, n: mark, fs: abs_font_size, 
      gh: abs_left,               # pour la géométrie, décalage par rapport au Nord-Ouest
      gv: abs_top + LINE_HEIGHT + QUART_LINE_HEIGHT,  # pour la géométrie, décalage vertical
    }
  end
  def act_name_code
    CODE_PART_NAME % {
      w: width, h: font_size + 100, n: mark, fs: font_size, 
      gh: left,               # pour la géométrie, décalage par rapport au Nord-Ouest
      gv: top + LINE_HEIGHT + QUART_LINE_HEIGHT,  # pour la géométrie, décalage vertical
    }
  end

  def horloge_fin(real_pfa)
    CODE_HORLOGE_FIN % {
      w:    Horloge_Width[type],  # largeur (sauf pour actes)
      l:    PFA_WIDTH - Horloge_Width[type],  # left de l'horloge
      t:    (real_pfa ? top : abs_top) + 500,  # top de l'horloge (et du décalage)
      fs:   FontSize_Horloges[type], # Font size
      mk:   pfa.duration.as_horloge
    }
  end


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


  # La marque pour une séquence (un crochet allongé)
  # 
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
