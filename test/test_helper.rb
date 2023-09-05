$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "pfa"

require "minitest/autorun"

require 'minitest/reporters'

reporter_options = { 
  color: true,          # pour utiliser les couleurs
  slow_threshold: true, # pour signaler les tests trop longs
}
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

class PFAForTest
class << self

  # @return un bon PFA \PFA::RelativePFA
  def define_good_simple_pfa
    pfa = PFA::RelativePFA.new()
    design_pfa(pfa)
    return pfa
  end

  def design_pfa(pfa)
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '4:00:20'
    pfa.add :exposition, {t: '0+0+20', d:"C'est l'exposition"}
    pfa.add :incident_declencheur, {t:'0,20,20', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,45,20', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '1,00,20', d:'Ce Dev part 1'}
    pfa.add :cle_de_voute, {t: '2,00,20', d:'Cette clé de voute', duree: 180}
    pfa.add :developpement_part2, {t: '2,04,0', d:'Ce Dev part II'}
    pfa.add :pivot2, {t: '2,45,20', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '3,00,20', d:'Ce dénouement'}
    pfa.add :climax, {t: '3,40,20', d:'Ce climax'}
  end


end #/<< self
end #/class PFAForTest
