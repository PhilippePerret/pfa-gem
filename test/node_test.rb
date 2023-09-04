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

end #/Minitest::Test
