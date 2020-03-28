require "csv"
require "slop"
require "grouping/version"
require_relative "./matchers"
require_relative "./errors"
require_relative "./slop_matching_type"

module Grouping
  class App
    attr_accessor :output

    def self.start(args = ARGV)
      instance = new(args)
      instance.call
      instance
    end

    def initialize(args)
      @args = args
    end

    def call
      csv = CSV.read(opts[:input], headers: true)
      headers, *body = csv.to_a
      self.output = Matcher.new(headers, body, opts[:matching_type]).call
      save_output_csv(headers, output) unless output.empty?
    end

    private

    def save_output_csv(headers, output)
      CSV.open(opts[:output], "w") do |csv|
        csv << ["ID"] + headers
        output.each { |row| csv << row }
      end
    end

    def opts
      @opts ||= Slop.parse(@args) do |o|
        o.string "-i", "--input", "input CSV file", required: true
        o.string "-o", "--output", "output CSV file", default: "output.csv"
        o.matching_type "-m", "--matching-type", "A matching algorithm",
          default: SameEmailMatchingType
      end
    end
  end
end
