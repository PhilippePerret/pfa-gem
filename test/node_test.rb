require "test_helper"

#
# Test d'un noeud de paradigme de Field augmenté

class NodeTests < Minitest::Test

  def setup
    super
  end
  def teardown
  end

  def test_class_exists
    assert defined?(PFA::RelativePFA::Node), "La classe PFA::RelativePFA::Node devrait exister."
  end

  def test_un_noeud_possed_toutes_les_proprieres_temporelles_requises
    pfa = PFAForTest.define_good_simple_pfa

    cdv = pfa.cle_de_voute
    assert_instance_of PFA::RelativePFA::Node, cdv

    # -- Les temps relatifs --

    have_good_time_and_horloge(cdv, :start_at, 2 * 3600, '2:00:00')
    have_good_time_and_horloge(cdv, :end_at, 2 * 3600 + 180, '2:03:00')
    have_good_time_and_horloge(cdv, :duration, 180, nil)

    # -- Les temps absolus --

    assert_equal '1/2 - 1/48', cdv.abs_data[:abs_start]
    expected = (4*3600 * eval('1/2 - 1/48'.gsub(/\//,'.0/'))).to_i
    have_good_time_and_horloge(cdv, :abs_start, expected, PFA::NTime.new(expected,0).to_horloge)
    
    assert_equal  '1/24', cdv.abs_data[:abs_duration]
    expected = (4*3600 * eval('1/24'.gsub(/\//,'.0/'))).to_i
    have_good_time_and_horloge(cdv, :abs_duration, expected, PFA::NTime.new(expected,0).to_horloge)

    expected = (4*3600 * eval('1/2 - 1/48 + 1/24'.gsub(/\//,'.0/'))).to_i
    have_good_time_and_horloge(cdv, :abs_end, expected, PFA::NTime.new(expected,0).to_horloge)
    
  end

  def test_noeud_possede_toutes_les_methodes_de_dimensions
    #
    # On prend un PFA simple
    # (c'est un film qui fait 4 heures — 4 * 3600)
    # 
    pfa = PFAForTest.define_good_simple_pfa

    #
    # On aura besoin de la largeur en pixels
    # 
    pfa_width = PFA::RelativePFA::AnyBuilder::PFA_WIDTH
    # puts "\npfa_width = #{pfa_width}".bleu
    coef_pixels = pfa.img_builder.coef_pixels
    # puts "coef_pixels = #{coef_pixels}".bleu

    # 
    # On teste avec la clé de voûte
    # 
    cdv = pfa.cle_de_voute
    assert_instance_of PFA::RelativePFA::Node, cdv
    
    # -- Dimensions horizontales --
    have_good_dimensions(cdv, :left, 2000)
    have_good_dimensions(cdv, :abs_left, 1916)
    have_good_dimensions(cdv, :width, (180 * coef_pixels).to_i)
    have_good_dimensions(cdv, :abs_width, (10 * 60 * coef_pixels).to_i)
    have_good_dimensions(cdv, :right, 2000 + (180 * coef_pixels).to_i)
    have_good_dimensions(cdv, :abs_right, 1916 + (10 * 60 * coef_pixels).to_i)

    # -- Dimensions verticales --
    have_good_dimensions(cdv, :top,     PFA::RelativePFA::AnyBuilder::TOPS[:noeud])
    have_good_dimensions(cdv, :abs_top, PFA::RelativePFA::AnyBuilder::ABS_TOPS[:noeud])
    have_good_dimensions(cdv, :height,  PFA::RelativePFA::AnyBuilder::HEIGHTS[:noeud])

  end



  def have_good_dimensions(sujet, key, expected)
    assert_respond_to(sujet, key, "Le noeud #{sujet.mark} devrait répondre à la méthode :#{key}…")
    actual = sujet.send(key)
    assert_instance_of(Integer, actual, "La dimensions de :#{key} du noeud #{sujet.mark} devrait être un entier. C'est un #{actual.class}…")
    assert_equal(expected, actual, "La dimensions de :#{key} du noeud #{sujet.mark} devrait être #{expected}. Elle vaut #{actual}…")
  end

  def have_good_time_and_horloge(sujet, key, expected, expected_horloge)
    assert_respond_to(sujet, key, "Le noeud #{sujet.mark} devrait répondre à la méthode :#{key}")
    actual = sujet.send(key).to_i
    assert_instance_of(PFA::NTime, sujet.send(key), "La propriété @#{key} du noeud #{sujet.mark} devrait être un PFA::NTime. C'est un #{actual.class}…")
    assert_equal(expected, actual, "Le temps @#{key} du nœud #{sujet.mark} devrait être #{expected}. Mais il vaut #{actual}…")
  
    if expected_horloge
      actual = sujet.send(key).to_horloge
      assert_equal(expected_horloge, actual, "Le temps @#{key} du nœud #{sujet.mark} devrait avoir l'horloge #{expected_horloge}. Son horloge est #{actual}…")
    end
  end

end #/Minitest::Test
