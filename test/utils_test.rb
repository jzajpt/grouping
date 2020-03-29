require "test_helper"

class UtilsTest < Minitest::Test
  def test_removed_non_digits
    assert_equal "5551234567",
      Grouping::Utils.normalize_us_phone_number("(555) 123-4567")
    assert_equal "4441234567",
      Grouping::Utils.normalize_us_phone_number("444-123-4567")
  end

  def test_removes_us_country_code
    assert_equal "4441234567",
      Grouping::Utils.normalize_us_phone_number("1-444-123-4567")
    assert_equal "3331234567",
      Grouping::Utils.normalize_us_phone_number("13331234567")
  end

  def test_select_matching_columns_returns_array_of_indexes
    column_names = %w[name email email2 phone address]
    indexes = Grouping::Utils.select_matching_columns(column_names, /\Aemail/i)
    assert_equal [1, 2], indexes
  end

  def test_select_matching_columns_returns_empty_array_if_none_found
    column_names = %w[name phone address]
    indexes = Grouping::Utils.select_matching_columns(column_names, /\Aemail/i)
    assert_equal [], indexes
  end
end
