require "digest"
require "securerandom"
require_relative "./errors"
require_relative "./utils"

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
      build_counter_map
      identify_matching_rows
    end

    # Returns the ID for the row with given row index.
    def [](idx)
      call if @row_ids.empty?
      @row_ids[idx]
    end

    def columns
      @column_names
    end

    private

    # Find duplicates by building a "counter map" in linear, O(n) time.
    def build_counter_map
      rows.each do |row|
        columns.each do |col|
          value = normalize_value(row[col])
          next unless value
          @map[value] = (@map[value] || 0) + 1
        end
      end
    end

    # Identify the matching rows by checking if the identifiable columns that
    # are specified by matching type (strategy) have any duplicates. If so,
    # use the same ID for all duplicates.
    def identify_matching_rows
      @row_ids = []
      rows.each_with_index do |row, idx|
        id_cols = columns.select do |col|
          value = normalize_value(row[col])
          value && @map[value] > 1
        end
        new_id = SecureRandom.hex(5)
        id_cols.each do |id_col|
          value = normalize_value(row[id_col])
          if @id_map[value]
            new_id = @id_map[value]
          else
            @id_map[value] = new_id
          end
        end
        @row_ids[idx] = new_id
      end
    end

    def normalize_value(value)
      value
    end
  end

  class SameEmailMatchingType < BaseMatchingType
    def columns
      @columns ||= Grouping::Utils.select_matching_columns(column_names,
                                                           /\Aemail/i)
    end
  end

  class SamePhoneMatchingType < BaseMatchingType
    def columns
      @columns ||= Grouping::Utils.select_matching_columns(column_names,
                                                           /\Aphone/i)
    end

    private

    def normalize_value(value)
      Grouping::Utils.normalize_us_phone_number(value)
    end
  end

  class SameEmailOrPhoneMatchingType < BaseMatchingType
    def columns
      @columns ||= Grouping::Utils.select_matching_columns(column_names,
                                                           /\A(email|phone)/i)
    end

    private

    def normalize_value(value)
      if value&.include?("@")
        value
      else
        Grouping::Utils.normalize_us_phone_number(value)
      end
    end
  end
end
