require 'digest'
require 'securerandom'
require_relative './errors'

module Grouping
  NORMALIZE_PHONE = ->(str) { str.gsub(/\D/, '') }

  class Matcher
    TYPES = %w[null same_email same_phone same_email_or_phone]

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

    def call
      rows.each do |row|
        columns.each do |col|
          value = normalize(col, row)
          next unless value
          @map[value] = (@map[value] || 0) + 1
          if @map[value] > 1
            @id_map[value] = SecureRandom.hex(20)
          end
        end
      end
      rows.map do |row|
        col = columns.find do |col|
          value = normalize(col, row)
          next unless value
          @map[value] > 1
        end
        if col
          value = normalize(col, row)
          id = @id_map[value]
        else
          id = SecureRandom.hex(5) unless id
        end
        @row_ids.push(id)
      end
    end

    def [](idx)
      call if @row_ids.empty?
      @row_ids[idx]
    end

    def columns
      @column_names
    end

    def normalize(col, row)
      value = row[col]
      column = column_names[col]
      if value
        normalize_value(column, value)
      end
    end

    def normalize_value(col, value)
      value
    end
  end

  class SameEmailMatchingType < BaseMatchingType
    def columns
      @columns ||= begin
                     column_names.each_index
                       .select { |key| column_names[key].match /\Aemail/i }
                   end
    end
  end

  class SamePhoneMatchingType < BaseMatchingType
    def columns
      @columns ||= begin
                     column_names.each_index
                       .select { |key| column_names[key].match /\Aphone/i }
                   end
    end

    def normalize_value(_, value)
      NORMALIZE_PHONE.(value)
    end
  end

  class OrMatchingType
    attr_accessor :rows, :column_names, :rows

    def initialize(column_names, rows, matcher_a_class, matcher_b_class)
      @column_names = column_names
      @rows = rows
      @matcher_a = matcher_a_class.new(column_names, rows)
      @matcher_b = matcher_b_class.new(column_names, rows)
      @id_pairs, @id_map = [], {}
      @map_a, @map_b = {}, {}
    end

    def call
      @id_pairs = []
      (0...rows.size).each do |i|
        id_a = @matcher_a[i]
        @map_a[id_a] = (@map_a[id_a] || 0) + 1
        id_b = @matcher_b[i]
        @map_b[id_b] = (@map_b[id_b] || 0) + 1
        @id_pairs.push([id_a, id_b])
      end
    end

    def [](idx)
      call if @id_pairs.empty?
      id_a, id_b = @id_pairs[idx]
      if @map_a[id_a] > 1 || @map_b[id_b] > 1
        id = @id_map[id_a] || @id_map[id_b]
        id ||= SecureRandom.hex(20)
        @id_map[id_a] = id
        @id_map[id_b] = id
        id
      else
        SecureRandom.hex(20)
      end
    end
  end

  class SameEmailOrPhoneMatchingType < OrMatchingType
    def initialize(column_names, rows)
      super(column_names, rows, SameEmailMatchingType, SamePhoneMatchingType)
    end
  end

end
