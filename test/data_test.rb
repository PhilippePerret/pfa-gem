require "test_helper"


class PFADataTests < Minitest::Test

  def setup
    super
  end
  def teardown
  end

  def test_file_data_exists
    assert defined?(PFA::ABSOLUTE_DATA_PATH), "Constant PFA::ABSOLUTE_DATA_PATH should be defined."
    assert File.exist?(PFA::ABSOLUTE_DATA_PATH), "Data file #{PFA::ABSOLUTE_DATA_PATH} should exist."
  end

end #/Minitest::Test
