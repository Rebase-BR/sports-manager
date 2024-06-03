# frozen_string_literal: true

module SportsManager
  module Constraints
    # Public: Constraint to all timeslot assignments be different for
    # each match
    require 'csp-resolver'
    class AllDifferentConstraint < ::CSP::Constraint
      attr_reader :matches

      def self.for_tournament(tournament:, csp:)
        csp.add_constraint(new(tournament.matches.values.flatten))
      end

      def initialize(matches)
        super
        @matches = matches
      end

      def satisfies?(assignment)
        assignment.values == assignment.values.uniq
      end
    end
  end
end
