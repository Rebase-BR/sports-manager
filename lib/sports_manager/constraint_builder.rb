# frozen_string_literal: true

module SportsManager
  class ConstraintBuilder
    attr_reader :tournament, :constraints

    DEFAULT_CONSTRAINTS = [
      Constraints::AllDifferentConstraint,
      Constraints::NoOverlappingConstraint,
      Constraints::MatchConstraint,
      Constraints::MultiCategoryConstraint,
      Constraints::NextRoundConstraint
    ].freeze

    def self.build(tournament:, csp:, constraints: nil)
      new(tournament: tournament, constraints: constraints).build(csp)
    end

    def initialize(tournament:, constraints: nil)
      @tournament = tournament
      @constraints = constraints || DEFAULT_CONSTRAINTS
    end

    def build(csp)
      constraints.map do |constraint|
        constraint.for_tournament(tournament: tournament, csp: csp)
      end
    end
  end
end
