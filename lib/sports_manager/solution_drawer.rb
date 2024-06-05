# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    attr_reader :tournament_solution

    def initialize(tournament_solution)
      @tournament_solution = tournament_solution
    end

    def none; end

    def mermaid
      Mermaid.draw(tournament_solution)
    end

    def cli
      CLI.draw(tournament_solution)
    end

    # TODO: create json method | create class | move serialize class too
  end
end
