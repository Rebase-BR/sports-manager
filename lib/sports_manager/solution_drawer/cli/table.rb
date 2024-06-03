# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    class CLI
      # Public: creates a table based on a list of hashes containing the
      # name of the columns and their values
      #
      # Example:
      # data = [
      #   { a: [1, 2, 3],    b: 10_000,     c: 'ABCDEFGHIJKLMNOP' },
      #   { a: [4, 5, 6, 7], b: 20_000_000, c: 'QRSTUVWXYZ' }
      # ]
      #
      #       a       |    b     |        c
      #  -------------|----------|-----------------
      #  1, 2, 3      | 10000    | ABCDEFGHIJKLMNOP
      #  4, 5, 6, 7   | 20000000 | QRSTUVWXYZ
      class Table
        attr_reader :data

        SECTION_SEPARATOR = '-|-'
        COLUMN_SEPARATOR = ' | '
        ROW_SEPARATOR = '-'

        def self.draw(data)
          new(data).draw
        end

        def initialize(data)
          @data = data
        end

        def draw
          [header_row, separator, *content_rows].join("\n")
        end

        private

        def header
          @header ||= data.flat_map(&:keys).uniq
        end

        def header_row
          header
            .map { |column| column.to_s.center(widths[column]) }
            .join(COLUMN_SEPARATOR)
        end

        def separator
          header
            .map { |column| ROW_SEPARATOR * widths[column] }
            .join(SECTION_SEPARATOR)
        end

        def content_rows
          data
            .map(&method(:row_content))
            .map { |row| row.join(COLUMN_SEPARATOR) }
        end

        def row_content(row)
          row.map do |(column, value)|
            column_padding = widths[column]

            Array(value)
              .join(', ')
              .ljust(column_padding)
          end
        end

        # Internal: sets the longest width for each column
        def widths
          @widths ||= data
            .flat_map(&:to_a)
            .each_with_object(headers_width) do |(key, value), columns_width|
            column_size = columns_width[key].to_i
            value_size = value.to_s.size

            columns_width[key] = [column_size, value_size].max
          end
        end

        # Internal: sets the starting width for each column based on
        # their names
        def headers_width
          header.each_with_object({}) do |column, width|
            width[column.to_sym] = column.to_s.size
          end
        end
      end
    end
  end
end
