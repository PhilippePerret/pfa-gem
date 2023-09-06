#
# Class PFA::NTime
# -------------------
# Pour la gestion des temps dans le paradigme de Field
# On ne passera plus par la class Time, trop compliquée
# 
module PFA
class NTime

  # \Integer Nombre de secondes pour ce temps
  attr_reader :secondes

  # \Integer Nombre de secondes du zéro
  attr_reader :zero_offset

  # On peut initialiser un NTime avec :
  #   - [Integer]     Des secondes
  #   - [Time]        Un temps
  #   - [String]      Une horloge
  #   - [PFA::NTime]  Une instance PFA::NTime (comme celle-ci)
  # 
  # @param \Integer zero_offset   Décalage du temps avec zéro
  # 
  def initialize(foo, zero_offset = 0)
    @zero_offset = zero_offset
    case foo
    when Integer    then @secondes = foo
    when Float      then @secondes = foo.to_i
    when PFA::NTime then @secondes = foo.to_i
    when Time       then @secondes = foo.to_i
    when String     then @secondes = PFA.h2s(foo)
    else raise PFAFatalError.new(53, {value: "#{foo}", classe:"#{foo.class}"})  
    end
    @secondes -= zero_offset
  end


  def as_horloge
    @to_horloge ||= PFA.s2h(secondes)
  end
  alias :to_horloge :as_horloge

  def as_duree
    @as_duree ||= PFA.s2h(secondes, **{as: :duree})
  end

  # @return [String] Une horloge qui indique le décalage avec 
  # la valeur idéale (seulement pour les noeuds relatifs).
  # 
  # @param abs_time [PFA::NTime] Le temps absolu
  # 
  def as_horloge_with_offset(abs_time)
    @as_horloge_with_offset ||= begin
      if self.to_i == abs_time.to_i
        self.as_horloge
      else
        signe   = self > abs_time ? '+' : '-'
        offset  = self.class.new((abs_time.to_i - self.to_i).abs)
        "#{self.as_horloge} (#{signe}#{offset.as_duree})" 
      end
    end
  end

  def to_i
    @secondes
  end

  # Retourne la valeur en pixels pour le temps courant (ou la durée)
  def to_px(pfa)
    (self.to_i * pfa.img_builder.coef_pixels).to_i
  end

  # [PFA::NTime] Le temps relatif (à l'écran)
  def relative
    @relative ||= NTime.new(secondes + zero_offset, 0)
  end

  # --- Helpers Methods ---

  # @retour [BashString] Le code pour écrire l'horloge dans une 
  # image avec ImageMagick pour le noeud +node+
  # 
  # @param [PFA::RelativePFA::Node] node Le nœud de l'horloge
  # @param [Hash] options 
  #     Plus tard, pourra redéfinir :bg_color et :color
  # 
  def as_img_horloge_code(node, **options)
    for_real = options[:pfa_type] == :real
    <<~CMD.strip
    \\(
    -background #{options[:bg_color]||'transparent'}
    -stroke #{options[:color]||'gray20'}
    -fill #{options[:color]||'gray20'}
    -strokewidth 1
    -pointsize #{MagickPFA::BASE_FONTSIZE * MagickPFA::HORLOGE_FONT_SIZES[node.type]}
    -size #{surface}
    -gravity #{options[:gravity]||'Center'}
    label:"#{for_real ? self.as_horloge_with_offset(options[:abs_time]) : as_horloge}"
    -extent #{surface}
    \\)
    -gravity northwest
    -geometry +#{node.send(for_real ? :left : :abs_left) + 24}+#{node.send(for_real ? :top : :abs_top) + 8}
    -composite
    CMD
  end

  def surface
    @surface ||= "#{MagickPFA::PFA_WIDTH/10}x50"
  end

  # --- Operation Methods ---

  # Addition
  # 
  # @param secondes \PFA::NTime ou \Integer
  # 
  def +(secs)
    secs = secs.to_i if secs.is_a?(PFA::NTime)
    return PFA::NTime.new(secs + @secondes, 0)
  end

  def <(nodetime)
    @secondes < nodetime.to_i
  end

  def >(nodetime)
    @secondes > nodetime.to_i
  end

end #/class NTime
end #/module PFA
