require "test_helper"

class MatchersTest < Minitest::Test
  def test_same_email_identify_returns_unique_id_for_diff_emails
    columns = ["Email"]
    rows = [["joe.doe@gmail.com"],
            ["jane.doe@gmail.com"]]
    matcher = Grouping::SameEmailMatchingType.new(columns, rows)
    refute_equal matcher[0], matcher[1]
  end

  def test_same_email_identify_returns_same_id_for_same_emails
    columns = ["Email"]
    row1 = ["joe.doe@gmail.com"]
    rows = [row1, row1.dup]
    matcher = Grouping::SameEmailMatchingType.new(columns, rows)
    assert_equal matcher[0], matcher[1]
  end

  def test_same_email_identify_returns_same_id_for_same_emails_in_multiple_cols
    columns = %w[Email1 Email2]
    rows = [["joe.doe@gmail.com", "jane.doe@gmail.com"],
            ["jane.doe@gmail.com", ""],
            ["bob.doe@gmail.com", "robert.doe@gmail.com"]]
    matcher = Grouping::SameEmailMatchingType.new(columns, rows)
    assert_equal matcher[0], matcher[1]
    refute_equal matcher[0], matcher[2]
    refute_equal matcher[1], matcher[2]
  end

  def test_same_phone_identify_returns_unique_id_for_diff_phone
    columns = ["Phone"]
    rows = [["(555) 123-4567"],
            ["(555) 543-3211"]]
    matcher = Grouping::SamePhoneMatchingType.new(columns, rows)
    refute_equal matcher[0], matcher[1]
  end

  def test_same_phone_identify_returns_same_id_for_same_phone
    columns = ["Phone"]
    rows = [["(555) 123-4567"],
            ["(555) 123-4567"],
            ["(444) 321-7655"]]
    matcher = Grouping::SamePhoneMatchingType.new(columns, rows)
    assert_equal matcher[0], matcher[1]
    refute_equal matcher[2], matcher[1]
    refute_equal matcher[2], matcher[0]
  end

  def test_same_phone_identify_returns_same_id_for_same_phone_syntax
    columns = ["Phone"]
    rows = [["(555) 123-4567"],
            ["555-123-4567"]]
    matcher = Grouping::SamePhoneMatchingType.new(columns, rows)
    assert_equal matcher[0], matcher[1]
  end

  def test_same_phone_or_email_identify_matches_emails_and_phones_separately
    columns = %w[Phone Email]
    rows = [["(555) 123-4567", "joe@doe.com"],
            ["444-123-4567", "jane@doe.com"],
            ["333-123-4567", "joe@doe.com"],
            ["444 123-4567", "janis@doe.com"],
            ["666 321 7654", "john@gmail.com"]]
    matcher = Grouping::SameEmailOrPhoneMatchingType.new(columns, rows)
    assert_equal matcher[0], matcher[2]
    assert_equal matcher[1], matcher[3]
    refute_equal matcher[0], matcher[1]
    refute_equal matcher[4], matcher[0]
    refute_equal matcher[4], matcher[1]
  end

  def test_same_phone_or_email_identify_matches_emails_and_phones_transiently
    columns = %w[Phone Email]
    rows = [["(555) 123-4567", "joe@doe.com"],
            ["555-123-4567", "jane@doe.com"],
            ["333-123-4567", "jack@gmail.com"],
            ["666 123-4567", "jane@doe.com"]]
    matcher = Grouping::SameEmailOrPhoneMatchingType.new(columns, rows)
    assert_equal matcher[0], matcher[1]
    assert_equal matcher[0], matcher[3]
  end
end
