require "test_helper"

#
# À DUPLIQUER
# 

class RelativePFATests < Minitest::Test

  def setup
    super
    @pfa = nil
  end
  def teardown
  end

  def pfa
    @pfa ||= PFA::RelativePFA.new()
  end

  def test_class_relative_pfa_exist
    assert defined?(PFA::RelativePFA), "La classe PFA::RelativePFA devrait exister."
  end

  def test_instance_respond_to_methods
    [
      :valid?, :add, :to_html, :to_svg,
    ].each do |methode|
      assert_respond_to(pfa, methode, "L'instance RelativePFA devrait répondre à la méthode ##{methode}…" )
    end
  end

  def test_add_permet_dajouter_des_donnees
    @pfa = nil
    assert_nil pfa.zero
    pfa.add :zero, '0+0+20'
    refute_nil pfa.zero
    refute_instance_of PFA::RelativePFA::DataTime, pfa.zero
    assert_instance_of Time, pfa.zero
    assert_equal Time.at(20), pfa.zero
  end

  def test_add_permet_dajouter_par_cle
    assert_nil pfa.incident_declencheur
    pfa.add( :incident_declencheur, **{t:'0+9+56', d: "C'est l'incident déclencheur"})
    assert_equal (Time.at(9*60+56)), pfa.data[:incident_declencheur].start_at
  end


  def test_to_html_produit_le_bon_code
    skip "Implémenter le test de #to_html"
    @pfa = nil
  end

  def test_to_svg_produit_la_bonne_image
    skip "Implémenter le test de #to_svg"
  end
end #/Minitest::Test
