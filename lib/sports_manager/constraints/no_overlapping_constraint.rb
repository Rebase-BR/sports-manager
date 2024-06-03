# frozen_string_literal: true

module SportsManager
  module Constraints
    class NoOverlappingConstraint < ::CSP::Constraint
      attr_reader :matches, :match_time

      def self.for_tournament(tournament:, csp:)
        csp.add_constraint(
          new(
            matches: tournament.matches.values.flatten,
            match_time: tournament.match_time
          )
        )
      end

      def initialize(matches:, match_time:)
        super(matches)
        @matches = matches
        @match_time = match_time
      end

      def satisfies?(assignment)
        return true unless variables.all? { |variable| assignment.key?(variable) }

        variables
          .map { |variable| assignment[variable] }
          .group_by(&:court)
          .none? { |_, timeslots| timeslots_overlap?(timeslots: timeslots) }
      end

      private

      def timeslots_overlap?(timeslots:)
        timeslots
          .map(&:slot)
          .map(&method(:to_range))
          .combination(2)
          .any?(&method(:overlap?))
      end

      def overlap?(*ranges)
        time_range1, time_range2 = ranges.flatten
        time_range1.cover?(time_range2.first) ||
          time_range2.cover?(time_range1.first)
      end

      def to_range(value)
        end_value = value + (match_time * 60)

        (value...end_value)
      end
    end
  end
end
