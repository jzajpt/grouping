module Grouping
  def self.normalize_us_phone_number(phone_number)
    digits = phone_number&.gsub(/\D/, "")
    if digits && digits.size == 11 && digits[0] == "1"
      digits[1..-1]
    else
      digits
    end
  end
end
