# frozen_string_literal: true

module SportsManager
  # Public: A tournament with its possible solutions containing the
  # fixtures for each solution
  #
  # Note: Fixture is a schedule for the participating teams.
  class TournamentSolution
    attr_reader :tournament, :tournament_solutions

    def initialize(tournament:, solutions:)
      @tournament = tournament
      @tournament_solutions = solutions
    end

    def solutions
      @solutions ||= tournament_solutions
        .map { |fixtures| Fixture.build_fixtures(fixtures) }
        .map { |fixtures| Solution.new(fixtures) }
    end

    def solved?
      solutions && !solutions.empty?
    end

    def total_solutions
      solutions.size
    end

    def as_json(options = nil)
      Serializer.new(self).as_json(options)
    end
  end
end
