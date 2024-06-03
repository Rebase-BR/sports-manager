# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    # Public: draws the tournament solution to mermaid's charts
    class Mermaid
      extend Forwardable

      attr_reader :tournament_solution

      def_delegators :tournament_solution, :solutions,
                     :total_solutions, :solved?

      NO_SOLUTION = 'No solution found'

      def self.draw(tournament_solution)
        new(tournament_solution).draw
      end

      def initialize(tournament_solution)
        @tournament_solution = tournament_solution
      end

      def draw
        no_solution || draw_solution
      end

      private

      def no_solution
        return false if solved?

        puts NO_SOLUTION

        true
      end

      def draw_solution
        puts 'Solutions:'
        solutions.map.with_index(1, &method(:draw_all))
        puts "Total solutions: #{total_solutions}"
      end

      def draw_all(solution, index)
        puts '-' * 80
        puts "Solutions #{index}"

        puts 'Gantt:'
        puts gantt(solution)

        puts 'Graph:'
        puts graph(solution)
        puts '-' * 80
      end

      def gantt(solution)
        SolutionGantt.new(solution).draw
      end

      def graph(solution)
        SolutionGraph.new(solution).draw
      end
    end
  end
end
