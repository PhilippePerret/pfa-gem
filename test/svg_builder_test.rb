require "test_helper"

#
# À DUPLIQUER
# 

class SVGBuilderTests < Minitest::Test

  def setup
    super
    @pfa = nil
    @builder = nil
  end
  def teardown
  end

  def define_bon_pfa
    pfa.add :zero, '0+0+20'
    pfa.add :end_time, '2,0,0'
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,15,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :cle_de_voute, {t: '0,60,0', d:'Cette clé de voute', duree: 11*60}
    pfa.add :developpement_part2, {t: '0,70,0', d:'Ce Dev part II'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
  end

  def pfa
    @pfa ||= PFA.new
  end
  def builder
    @builder ||= PFA::RelativePFA::SVGBuilder.new(pfa)
  end

  def test_if_builder_exists
    assert defined?(PFA::RelativePFA::SVGBuilder)
  end

  def test_if_respond_to_build
    assert_respond_to pfa, :to_svg 
  end

  def test_the_builder_methods
    assert_respond_to builder, :build
  end


  def test_builder_succeeds_with_bonne_data
    define_bon_pfa
    assert_silent { builder.build }
  end

end #/Minitest::Test
