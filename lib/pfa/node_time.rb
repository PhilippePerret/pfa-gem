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

  # -- Méthodes de décalage --
   
  def calc_offset(abs_time)
    offset_secondes = (abs_time.to_i - self.to_i).abs
    @offset     = self.class.new(offset_secondes)
    @hasoffset  = offset > 30
  end

  # @return [String] Une horloge qui indique le décalage avec 
  # la valeur idéale (seulement pour les noeuds relatifs) si ce
  # décalage existe.
  # 
  # @param abs_time [PFA::NTime] Le temps absolu
  # 
  def as_horloge_with_offset(abs_time)
    @as_horloge_with_offset ||= begin
      if offset?
        signe   = self > abs_time ? '+' : '-'
        "#{self.as_horloge} (#{signe}#{offset.as_duree})" 
      else
        self.as_horloge
      end
    end
  end

  # @return true s'il y a un décalage trop important avec le 
  # temps absolu
  # @noter que cette méthode existe aussi pour le temps absolu
  def offset?
    @hasoffset === true
  end

  def offset_as_horloge(abs_time)
    @offset_as_horloge ||= begin
      if @hasoffset
        signe   = self > abs_time ? '+' : '-'
        " (#{signe}#{offset.as_duree})" 
      else
        " "
      end
    end
  end

  def background_per_offset
    @background_per_offset ||= begin
      if offset > 120
        'gray40' # offset trop grand
      else
        'transparent'
      end
    end
  end
  def foreground_per_offset
    @foreground_per_offset ||= begin
      if offset < 60
        'gray60'
      elsif offset < 120
        'gray20'
      else
        'white'
      end
    end
  end

  # [PFA::NTime] Décalage entre le temps absolu et le temps réel
  def offset
    @offset
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
    return PFA::NTime.new(secs + @secondes)
  end

  def -(secs)
    secs = secs.to_i if secs.is_a?(PFA::NTime)
    return PFA::NTime.new(@secondes - secs)
  end

  def <(nodetime)
    @secondes < nodetime.to_i
  end

  def >(nodetime)
    @secondes > nodetime.to_i
  end

end #/class NTime
end #/module PFA
