module PFA
class RelativePFA
class AnyBuilder

  REQUIRE_NODES_FOR_BUILDING = [
    :exposition,
    :incident_declencheur,
    :pivot1,
    :developpement_part1,
    :developpement_part2,
    :pivot2,
    :denouement,
    :climax,
  ]

  # Instance \PFA::RelativePFA du paradigme de Field augmenté
  attr_reader :pfa

  def initialize(pfa)
    @pfa = pfa
  end
  
end #/class AnyBuilder
end #/class RelativePFA
end #/module PFA
