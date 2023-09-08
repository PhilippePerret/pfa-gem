require_relative 'pfa_element_module'
module PFA
class RelativePFA
class DataTime

  include PFAElementModule

  attr_reader :pfa, :key

  def initialize(pfa, key, value = nil)
    @pfa        = pfa
    @key        = key
    @raw_value  = value
  end

  def time
    @time ||= PFA::NTime.new(@raw_value, 0)
  end
  alias :start_at :time

  # Pour la compatibilité quand on boucle sur tous les éléments
  # des données du paradigme relatif
  def type; nil end

end #/class DataTime
end #/class RelativePFA
end #/module PFA
