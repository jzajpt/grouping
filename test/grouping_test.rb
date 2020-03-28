require 'test_helper'

class GroupingTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Grouping::VERSION
  end

  def test_it_requires_input_option
    assert_raises Slop::MissingRequiredOption do
      Grouping::App.start([''])
    end
  end

  def test_it_reads_input1
    Grouping::App.start(['-i', 'data/input1.csv'])
  end

  def test_it_applies_matching_type_same_email
    Grouping::App.start(['-i', 'data/input1.csv', '-m', 'same_email'])
    assert_exists 'output.csv'
  end

  def test_it_applies_matching_type_same_phone
    Grouping::App.start(['-i', 'data/input1.csv', '-m', 'same_phone'])
    assert_exists 'output.csv'
  end

  def test_it_applies_matching_type_same_email_or_phone
    Grouping::App.start(['-i', 'data/input1.csv', '-m', 'same_email_or_phone'])
    assert_exists 'output.csv'
  end
end
