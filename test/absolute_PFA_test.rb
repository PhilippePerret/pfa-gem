require "test_helper"

#
# À DUPLIQUER
# 

class AbsolutePFATests < Minitest::Test

  def setup
    super
  end
  def teardown
  end

  def test_it_exists
    assert defined?(PFA::AbsolutePFA), "PFA::AbsolutePFA devrait exister."
  end

  def test_it_responds_to_methods
    [
      :data
    ].each do |methode|
      assert_respond_to PFA::AbsolutePFA, methode, "Le PFA:AbsolutePFA devrait répondre à la méthode ##{methode}…"
    end
  end

  def test_donnees_absolues
    data = PFA::AbsolutePFA.data
    [
      :times, :nodes
    ].each do |key|
      assert( data.key?(key), "Les données absolues devraient connaitre la clé #{key.inspect}")
      assert_instance_of Hash, data[key]
    end

    # clés pour les temps
    [
      :zero, :end_time
    ].each do |key|
      assert(data[:times].key?(key), "AbsolutePFA.data[:times] devrait connaitre la clé #{key.inspect}…")
    end

    # Clés pour les nœuds
    # 
    [
      :exposition, :developpement_part1, :developpement_part2, :denouement
    ].each do |key|
      assert(data[:nodes].key?(key), "AbsolutePFA.data[:nodes] devrait connaitre la clé #{key.inspect}…")
    end
  end

end #/Minitest::Test
