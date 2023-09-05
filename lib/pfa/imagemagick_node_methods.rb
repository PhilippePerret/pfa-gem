#
# Module inclus dans la classe RelativePFA::Node
# 
# @note
# 
#   On le met en module pour avoir toutes les méthodes séparées
#   du module principal.
# 
require_relative 'any_builder'
module ImageMagicNodesMethodes

  AnyBUILDER = PFA::RelativePFA::AnyBuilder


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
    -stroke #{AnyBUILDER::COLORS[type]}
    -strokewidth #{AnyBUILDER::ABS_FONTWEIGHTS[type]}
    -pointsize #{AnyBUILDER::ABS_FONTSIZES[type]}
    -size #{img_abs_surface}
    label:"#{mark}"
    -background none
    -trim
    -gravity #{AnyBUILDER::GRAVITIES[type]}
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
    -draw "line #{left},#{top-AnyBUILDER::LINE_HEIGHT/2} #{left+1},#{bottom+4*AnyBUILDER::LINE_HEIGHT}"
    \\(
    -background white
    -stroke #{AnyBUILDER::COLORS[type]}
    -fill #{AnyBUILDER::COLORS[type]}
    -strokewidth #{AnyBUILDER::FONTWEIGHTS[type]}
    -pointsize #{AnyBUILDER::FONTSIZES[type]}
    label:"#{mark}"
    -size #{img_surface}
    -trim
    -gravity #{AnyBUILDER::GRAVITIES[type]}
    -extent #{img_surface}
    \\)
    -gravity northwest
    -geometry +#{left+2-AnyBUILDER::RECTIFS[:part]}+#{top+2}
    -composite
    #{start_at.as_img_horloge_code(self)}
    CMD
  end


  # La marque pour une partie absolue (un rectangle)
  def img_lines_for_abs_part
    # La boite de l'acte idéal
    <<~CMD.strip
    -background transparent
    -stroke #{AnyBUILDER::DARKERS[:part]}
    -fill white
    -strokewidth #{AnyBUILDER::ABS_BORDERS[:part]}
    -draw "rectangle #{abs_left},#{abs_top} #{abs_right},#{abs_bottom}"
    CMD
  end

  def img_lines_for_rel_part
    # La boite de l'acte réel
    <<~CMD.strip
    -background transparent
    -stroke #{AnyBUILDER::DARKERS[:part]}
    -fill white
    -strokewidth #{AnyBUILDER::ABS_BORDERS[:part]}
    -draw "rectangle #{left},#{top} #{right},#{bottom}"
    CMD
  end

end
