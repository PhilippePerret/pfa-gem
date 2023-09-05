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
  def initialize(foo, zero_offset)
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


  def to_horloge
    @horloge ||= PFA.s2h(secondes)
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
