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
    "\n" + img_draw_command_abs_pfa + "\n" + img_draw_command_real_pfa
  end

  # @return [Array<BashString>] Les lignes pour construire le noeud,
  # en version absolue (i.e. PFA idéal en fonction de la durée du film)
  def img_draw_command_abs_pfa
    <<~CMD.strip
    #{send("img_lines_for_abs_#{type}".to_sym)}
    \\(
    -stroke #{COLORS[type]}
    -strokewidth #{ABS_FONTWEIGHTS[type]}
    -pointsize #{abs_font_size}
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
    #{abs_start.as_img_horloge_code(self, **{pfa_type: :ideal})}
    CMD
  end
  # -geometry +#{abs_left}+#{abs_top}

  # @return [Array<BashString>] Les lignes pour construire le noeud,
  # en version relative (i.e. PFA du film)
  def img_draw_command_real_pfa
    <<~CMD.strip
    #{send("img_lines_for_real_#{type}".to_sym)}
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
    -pointsize #{font_size}
    label:"#{mark}"
    -size #{img_surface}
    -trim
    -gravity #{GRAVITIES[type]}
    -extent #{img_surface}
    \\)
    -gravity northwest
    -geometry +#{left+2-RECTIFS[:part]}+#{top+2}
    -composite
    #{start_at.as_img_horloge_code(self, **{pfa_type: :real, abs_time: abs_start})}
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

  def img_lines_for_real_part
    # La boite de l'acte réel
    <<~CMD.strip
    -background transparent
    -stroke #{DARKERS[:part]}
    -fill white
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
