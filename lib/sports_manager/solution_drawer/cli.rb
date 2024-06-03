# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    # Public: Outputs the tournament's timetable solutions to stdout
    # TODO: allow to pass which stdout will be used. puts|Logger|other
    class CLI
      extend Forwardable

      attr_reader :tournament_solution

      def_delegators :tournament_solution, :solutions,
                     :total_solutions, :solved?

      NO_SOLUTION = 'No solution found'
      START_NUMBER = 1

      def self.draw(tournament_solution)
        new(tournament_solution).draw
      end

      def initialize(tournament_solution)
        @tournament_solution = tournament_solution
      end

      def draw
        no_solution || draw_solutions
      end

      private

      def no_solution
        return false if solved?

        puts NO_SOLUTION

        true
      end

      def draw_solutions
        puts(
          output_header,
          output_solutions,
          output_footer
        )
      end

      def output_header
        "Tournament Timetable:\n\n"
      end

      def output_solutions
        solutions_tables.join("\n")
      end

      def output_footer
        "Total solutions: #{total_solutions}"
      end

      def solutions_tables
        solutions.map.with_index(START_NUMBER, &method(:draw_solution))
      end

      def draw_solution(solution, number)
        table_data = SolutionTable.new(solution).draw

        <<~MESSAGE
          Solution #{number}
          #{table_data}

        MESSAGE
      end
    end
  end
end
