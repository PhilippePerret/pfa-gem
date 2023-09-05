#
# Module inclus dans la classe RelativePFA::Node
# 
# @note
# 
#   On le met en module pour avoir toutes les méthodes séparées
#   du module principal.
# 
require_relative 'img_builder'
module MagickPFA

  # -- Commande ImageMagick --
  
  CONVERT_CMD = 'convert' # /usr/local/bin/convert si pas d'alias

  AnyBUILDER = PFA::RelativePFA::AnyBuilder
  ImgBUILDER = PFA::RelativePFA::ImgBuilder


  # Le début du code de la commande convert
  def self.code_for_intro
    <<~CMD.strip
    #{CONVERT_CMD}
    -size #{PFA_WIDTH}x#{PFA_HEIGHT}
    xc:white
    -units PixelsPerInch
    -density 300
    -background transparent 
    -stroke black
    CMD
  end

  # @return [Array<BashString>] le code Image Magick pour construire 
  # le noeud courant, ligne à ligne
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
  def img_draw_command(**options)
    "\n" + img_draw_command_abs_pfa + "\n" + img_draw_command_rel_pfa
  end

  # @return [Array<BashString>] Les lignes pour construire le noeud,
  # en version absolue (i.e. PFA idéal en fonction de la durée du film)
  def img_draw_command_abs_pfa
    <<~CMD.strip
    #{send("img_lines_for_abs_#{type}".to_sym)}
    \\(
    -stroke #{COLORS[type]}
    -strokewidth #{ABS_FONTWEIGHTS[type]}
    -pointsize #{ABS_FONTSIZES[type]}
    -size #{img_abs_surface}
    label:"#{mark}"
    -background none
    -trim
    -gravity #{GRAVITIES[type]}
    -extent #{img_abs_surface}
    \\)
    -gravity northwest
    -geometry +#{abs_left}-100
    -composite
    CMD
  end
  # -geometry +#{abs_left}+#{abs_top}

  # @return [Array<BashString>] Les lignes pour construire le noeud,
  # en version relative (i.e. PFA du film)
  def img_draw_command_rel_pfa
    <<~CMD.strip
    #{send("img_lines_for_rel_#{type}".to_sym)}
    -stroke black
    -strokewidth 3
    -fill black
    -background white
    -draw "line #{left},#{top-LINE_HEIGHT/2} #{left+1},#{bottom+4*LINE_HEIGHT}"
    \\(
    -background white
    -stroke #{COLORS[type]}
    -fill #{COLORS[type]}
    -strokewidth #{FONTWEIGHTS[type]}
    -pointsize #{FONTSIZES[type]}
    label:"#{mark}"
    -size #{img_surface}
    -trim
    -gravity #{GRAVITIES[type]}
    -extent #{img_surface}
    \\)
    -gravity northwest
    -geometry +#{left+2-RECTIFS[:part]}+#{top+2}
    -composite
    #{start_at.as_img_horloge_code(self)}
    CMD
  end


  # La marque pour une partie absolue (un rectangle)
  def img_lines_for_abs_part
    # La boite de l'acte idéal
    <<~CMD.strip
    -background transparent
    -stroke #{DARKERS[:part]}
    -fill white
    -strokewidth #{ABS_BORDERS[:part]}
    -draw "rectangle #{abs_left},#{abs_top} #{abs_right},#{abs_bottom}"
    CMD
  end

  def img_lines_for_rel_part
    # La boite de l'acte réel
    <<~CMD.strip
    -background transparent
    -stroke #{DARKERS[:part]}
    -fill white
    -strokewidth #{ABS_BORDERS[:part]}
    -draw "rectangle #{left},#{top} #{right},#{bottom}"
    CMD
  end


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

end
