module Grouping
  module Utils
    # Normalize phone number to digits only and exclude US country code (1)
    # if present.
    def self.normalize_us_phone_number(phone_number)
      digits = phone_number&.gsub(/\D/, "")
      if digits && digits.size == 11 && digits[0] == "1"
        digits[1..-1]
      else
        digits
      end
    end

    # Returns indexes of column names matching the given regexp.
    def self.select_matching_columns(column_names, regexp)
      column_names.each_index
        .select { |key| column_names[key].match(regexp) }
    end
  end
end
