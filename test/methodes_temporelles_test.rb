require "test_helper"

class PFATemporalMethodsTests < Minitest::Test

  def setup
    super
  end
  def teardown
  end

  def test_it_respond_to_h2s
    assert_respond_to PFA, :h2s
  end

  def test_h2s_return_good_value
    [
      ['0,0,0', 0],
      ['0+0+0', 0],
      ['0:0:0', 0],
      ['0', 0],
      ['12', 12],
      ['0:0', 0],
      ['0:12', 12],
      ['0+12', 12],
      ['0,12', 12],
      ['0:0:12', 12],
      ['0+0+12', 12],
      ['0,0,12', 12],
      ['0:12:0', 12 * 60],
      ['0+12+0', 12 * 60],
      ['0,12,0', 12 * 60],
      ['12:0:0', 12 * 3600],
      ['12+0+0', 12 * 3600],
      ['12,0,0', 12 * 3600],
      ['2,13,255', 2 * 3600 + 13 * 60 + 255],
      ['2:13:255', 2 * 3600 + 13 * 60 + 255],
      ['2+13+255', 2 * 3600 + 13 * 60 + 255],
    ].each do |expression, expected|
      actual = PFA.h2s(expression)
      assert_equal(expected, actual, "L'expression PFA.h2s(\"#{expression}\") devrait retourner #{expected}. Elle retourne #{actual}…")
    end
  end

  def test_if_s2h_exists
    assert_respond_to PFA, :s2h
  end

  def test_s2h_raise_une_erreur_en_cas_de_mauvais_argument
    [
      nil, "string", :symbole, [1,2,3], Time.at(12), 1.23
    ].each do |vtype|
      assert_raises(PFA::PFAFatalError) { PFA.s2h(vtype) }
    end
  end

  def test_s2h_retourne_bonne_valeur
    
  end

  def test_if_t2h_exists
    assert_respond_to PFA, :t2h  
  end

  def test_if_raise_with_bad_data
    [nil, 12, "12", :douze].each do |vtype|
      assert_raises(PFA::PFAFatalError) { PFA.t2h(vtype) }
    end
  end

  def test_t2h_retourne_bonne_valeur
    [
      ['Time.at(0)', '0:00:00']
    ].each do |expression, expected|
      actual = PFA.t2h(eval(expression))
      assert_equal(expected, actual, "L'expression PFA.t2h(#{expression}) devrait retourner #{expected.inspect}. Elle retourne #{actual.inspect}…")
    end
  end


end #/Minitest::Test
