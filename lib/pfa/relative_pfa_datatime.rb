module PFA
class RelativePFA
class DataTime

  attr_reader :pfa, :key

  def initialize(pfa, key, value = nil)
    @pfa        = pfa
    @key        = key
    @raw_value  = value
  end

  def time
    @time ||= PFA.time_from(@raw_value)
  end

end #/class DataTime
end #/class RelativePFA
end #/module PFA
