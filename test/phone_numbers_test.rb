require "test_helper"

class PhoneNumbersTest < Minitest::Test
  def test_removed_non_digits
    assert_equal "5551234567",
      Grouping.normalize_us_phone_number("(555) 123-4567")
    assert_equal "4441234567",
      Grouping.normalize_us_phone_number("444-123-4567")
  end

  def test_removes_us_country_code
    assert_equal "4441234567",
      Grouping.normalize_us_phone_number("1-444-123-4567")
    assert_equal "3331234567",
      Grouping.normalize_us_phone_number("13331234567")
  end
end


