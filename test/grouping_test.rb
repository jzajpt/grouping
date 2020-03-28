require "test_helper"

class GroupingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Grouping::VERSION
  end

  def test_it_requires_input_option
    assert_raises Slop::MissingRequiredOption do
      Grouping::App.start([""])
    end
  end

  def test_it_prepends_id_to_output
    Grouping::App.start(["-i", "data/input1.csv"])
    header, *csv = CSV.read("output.csv")
    assert_equal "ID", header[0]
    assert csv.size > 0
  end

  def test_it_applies_matching_type_same_email
    Grouping::App.start(["-i", "data/input1.csv", "-m", "same_email"])
    assert_exists "output.csv"
  end

  def test_it_applies_matching_type_same_phone
    Grouping::App.start(["-i", "data/input1.csv", "-m", "same_phone"])
    assert_exists "output.csv"
  end

  def test_it_applies_matching_type_same_email_or_phone
    Grouping::App.start(["-i", "data/input1.csv", "-m", "same_email_or_phone"])
    assert_exists "output.csv"
  end
end
