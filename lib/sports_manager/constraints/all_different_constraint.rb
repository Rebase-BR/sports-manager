# frozen_string_literal: true

module SportsManager
  module Constraints
    # Public: Constraint to all timeslot assignments be different for
    # each match
    class AllDifferentConstraint < ::CSP::Constraint
      attr_reader :matches

      def self.for_tournament(tournament:, csp:)
        matches = tournament.matches.values.flatten

        csp.add_constraint(new(matches))
      end

      def initialize(matches)
        super
        @matches = matches
      end

      def arity
        2
      end

      def satisfies?(assignment)
        assignment.values == assignment.values.uniq
      end
    end
  end
end
