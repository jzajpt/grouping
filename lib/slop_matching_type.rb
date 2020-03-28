require_relative './errors'
require_relative './matchers'

module Slop
  class MatchingTypeOption < Option
    def call(value)
      if Grouping::Matcher::TYPES.include?(value)
        type = value.split('_').collect(&:capitalize).join
        Grouping.const_get("#{type}MatchingType")
      else
        raise Matcher::UnknownMatcherTypeError.new
      end
    end
  end
end
