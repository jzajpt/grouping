require "digest"
require "securerandom"
require_relative "./errors"

module Grouping
  class Matcher
    TYPES = %w[null same_email same_phone same_email_or_phone].freeze

    attr_accessor :column_names, :rows, :strategy

    def initialize(column_names, rows, strategy)
      @column_names = column_names
      @rows = rows
      @strategy = strategy.new(column_names, rows)
    end

    def call
      strategy.call
      rows.each_with_index.map do |row, idx|
        id = strategy[idx]
        [id] + row
      end
    end
  end

  class BaseMatchingType
    attr_accessor :column_names, :rows

    def initialize(column_names, rows)
      @column_names = column_names
      @rows = rows
      @map = {}
      @id_map = {}
      @row_ids = []
    end

    # Run the matching algorithm.
    def call
      rows.each do |row|
        columns.each do |col|
          value = normalize_value(row[col])
          next unless value
          @map[value] = (@map[value] || 0) + 1
          @id_map[value] = SecureRandom.hex(5) if @map[value] > 1
        end
      end
      @row_ids = []
      rows.each do |row|
        id_col = columns.find do |col|
          value = normalize_value(row[col])
          next unless value
          @map[value] > 1
        end
        if id_col
          value = normalize_value(row[id_col])
          id = @id_map[value]
        else
          id ||= SecureRandom.hex(5)
        end
        @row_ids.push(id)
      end
    end

    # Returns the ID for the row with given row index.
    def [](idx)
      call if @row_ids.empty?
      @row_ids[idx]
    end

    def columns
      @column_names
    end

    def normalize_value(value)
      value
    end
  end

  class SameEmailMatchingType < BaseMatchingType
    def columns
      @columns ||= begin
                     column_names.each_index
                       .select { |key| column_names[key].match(/\Aemail/i) }
                   end
    end
  end

  class SamePhoneMatchingType < BaseMatchingType
    def columns
      @columns ||= begin
                     column_names.each_index
                       .select { |key| column_names[key].match(/\Aphone/i) }
                   end
    end

    def normalize_value(value)
      value&.gsub(/\D/, "")
    end
  end

  class OrMatchingCombinator
    attr_accessor :rows, :column_names

    def initialize(column_names, rows, matcher_a_class, matcher_b_class)
      @column_names = column_names
      @rows = rows
      @matcher_a = matcher_a_class.new(column_names, rows)
      @matcher_b = matcher_b_class.new(column_names, rows)
      @row_id_pairs = []
      @id_map = {}
      @map_a = {}
      @map_b = {}
    end

    def call
      @row_id_pairs = []
      (0...rows.size).each do |i|
        id_a = @matcher_a[i]
        @map_a[id_a] = (@map_a[id_a] || 0) + 1
        id_b = @matcher_b[i]
        @map_b[id_b] = (@map_b[id_b] || 0) + 1
        @row_id_pairs.push([id_a, id_b])
      end
    end

    def [](idx)
      call if @row_id_pairs.empty?
      id_a, id_b = @row_id_pairs[idx]
      if @map_a[id_a] > 1 || @map_b[id_b] > 1
        id = @id_map[id_a] || @id_map[id_b]
        id ||= SecureRandom.hex(5)
        @id_map[id_a] = id
        @id_map[id_b] = id
        id
      else
        SecureRandom.hex(5)
      end
    end
  end

  class SameEmailOrPhoneMatchingType < OrMatchingCombinator
    def initialize(column_names, rows)
      super(column_names, rows, SameEmailMatchingType, SamePhoneMatchingType)
    end
  end
end
