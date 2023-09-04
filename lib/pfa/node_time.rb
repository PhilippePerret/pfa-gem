#
# Class PFA::NodeTime
# -------------------
# Pour la gestion des temps dans le paradigme de Field
# On ne passera plus par la class Time, trop compliquée
# 
module PFA
class NodeTime

  # \Integer Nombre de secondes pour ce temps
  attr_reader :secondes

  # \Integer Nombre de secondes du zéro
  attr_reader :zero_offset

  # On peut initialiser un NodeTime avec :
  #   - \Integer  Des secondes
  #   - \Time     Un temps
  #   - \String   Une horloge
  # 
  # @param \Integer zero_offset   Décalage du temps avec zéro
  # 
  def initialize(foo, zero_offset)
    @zero_offset = zero_offset
    case foo
    when Integer  then @secondes = foo
    when Time     then @secondes = foo.to_i
    when String   then @secondes = PFA.h2s(foo)
    else raise PFAFatalError.new(53, {value: "#{foo}::#{foo.class}"})  
    end
  end


  def to_horloge
    @horloge ||= PFA.s2h(secondes)
  end

  def to_i
    @secondes
  end

  def on_120
    @on_120 ||= 120.to_f / (120 * 60).to_f / (secondes - zero_offset)
  end

  # @return \PFA::NodeTime du temps exact (hors zéro)
  def exact
    @exact ||= NodeTime.new(secondes - zero_offset, 0)
  end

  # --- Comparison Methods ---

  def <(nodetime)
    @secondes < nodetime.to_i
  end

end #/class NodeTime
end #/module PFA
