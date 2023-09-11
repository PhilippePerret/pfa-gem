require_relative 'pfa_element_module'
module PFA
class RelativePFA
class DataTime

  include PFAElementModule

  attr_reader :pfa, :key

  # @oaram pfa [PFA::RelativePFA]
  # 
  # @param key [Symbol] La clé structurelle (:zero ou :end_time)
  # 
  # 
  # @param value [String|Integer|Hash]
  #   Dans valeur de cette donnée temps. Ça peut être soit un temps,
  #   soit une table contenant le temps et la description.
  # 
  def initialize(pfa, key, value = nil)
    @pfa        = pfa
    @key        = key
    @ini_value  = value
    case value
    when Hash
      @horloge = value[:t]||value[:time]||value[:horloge]
      @description = value[:d]||value[:description]
    else
      @horloge  = value
    end
  end

  def time
    @time ||= PFA::NTime.new(@horloge, 0)
  end
  alias :start_at :time

  # Pour la compatibilité quand on boucle sur tous les éléments
  # des données du paradigme relatif
  def type; nil end

end #/class DataTime
end #/class RelativePFA
end #/module PFA
