module PFA
class RelativePFA
class Node

  attr_reader :pfa, :key

  attr_reader :start_at
  attr_reader :description

  def initialize(pfa, key, value = nil)
    # puts "\nInstanciation d'un noeud avec #{key.inspect} / #{value.inspect}".orange
    @pfa        = pfa
    @key        = key
    parse_raw_value(value)
  end

  def parse_raw_value(value)
    @raw_value = value 
    if value.is_a?(Hash)
      @start_at     = PFA.h2t(value[:t]||value[:time]||value[:start_at])
      @description  = value[:d]||value[:description]
    end
  end

  def horloge
    @horloge ||= PFA.t2h(start_at)
  end


  # @return \Bool true si le nœud courant est après le nœud 
  # \RelativePFA::Node +node+
  def after?(node)
    return start_at > node.start_at
  end

end #/class Node
end #/class RelativePFA
end #/module PFA
