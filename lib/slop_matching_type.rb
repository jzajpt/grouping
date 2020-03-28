require_relative "./errors"
require_relative "./matchers"

module Slop
  class MatchingTypeOption < Option
    def call(value)
      unless Grouping::Matcher::TYPES.include?(value)
        raise Matcher::UnknownMatcherTypeError.new
      end
      type = value.split("_").collect(&:capitalize).join
      Grouping.const_get("#{type}MatchingType")
    end
  end
end
