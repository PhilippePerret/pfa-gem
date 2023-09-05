require "test_helper"


# Pour simplifier les écriture
SVGBUILDER = PFA::RelativePFA::SVGBuilder

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
    pfa.add :exposition, {t: '0+0+20', d:"C'est l'exposition"}
    pfa.add :incident_declencheur, {t:'0,10,0', d:"Cet ID"}
    pfa.add :pivot1, {t: '0,15,0', d:'Ce pivot', duree: 136}
    pfa.add :developpement_part1, {t: '0,30,0', d:'Ce Dev part 1'}
    pfa.add :cle_de_voute, {t: '0,60,0', d:'Cette clé de voute', duree: 120}
    pfa.add :developpement_part2, {t: '0,70,0', d:'Ce Dev part II'}
    pfa.add :pivot2, {t: '0,80,0', d:'Ce pivot', duree: 11*60}
    pfa.add :denouement, {t: '0,90,0', d:'Ce dénouement'}
    pfa.add :climax, {t: '0,110,0', d:'Ce climax'}
  end

  def pfa
    @pfa ||= PFA.new
  end
  def builder
    @builder ||= pfa.svg_builder
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

  def test_calcul_de_la_duree_du_film
    define_bon_pfa
    assert_respond_to pfa, :duree
    assert_instance_of PFA::NTime, pfa.duree
    expected = 2 * 3600 - 20
    actual   = pfa.duree.to_i
    assert_equal expected, actual, "La durée du film devrait valoir #{expected}. Elle vaut #{actual}…"
  end

  def test_calcul_du_coefficiant_pixels
    define_bon_pfa
    actual = builder.calc_coefficient_pixels
    expected = 0.5153203342618384
    assert_equal expected, actual, "Le coefficiant-pixels devrait valoir #{expected}. Il vaut #{actual}…"
  end


  def test_calcul_du_start_et_du_end
    define_bon_pfa
    cdv = pfa.cle_de_voute
    assert_instance_of PFA::NTime, cdv.start_at
    expected = '0:59:40'
    actual   = cdv.start_at.exact.to_horloge
    assert_equal(expected, actual, "La valeur de cdv.start_at.to_real.to_horloge devrait être #{expected}. Elle vaut #{actual}…")
  end

  def test_methode_calcul_to_px
    define_bon_pfa
    cdv = pfa.cle_de_voute
    builder.init
    assert_respond_to cdv.start_at, :to_px
    expected  = 3580 * ((SVGBUILDER::PFA_WIDTH - SVGBUILDER::PFA_LEFT_MARGIN - SVGBUILDER::PFA_RIGHT_MARGIN).to_f / (2 * 3600 - 20))
    actual    = cdv.start_at.to_px
    assert_equal(expected, actual, "La valeur de cdv.to_px devrait être de #{expected}. Elle vaut #{actual}…")
  end
end #/Minitest::Test
