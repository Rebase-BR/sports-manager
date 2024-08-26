# frozen_string_literal: true

module SportsManager
  module Constraints
    # Public: Restrict match to be set only after the previous matches
    # it depends on are scheduled.
    class MatchConstraint < ::CSP::Constraint
      attr_reader :target_match, :matches

      def self.for_tournament(tournament:, csp:)
        tournament.matches.each do |(_category, matches)|
          matches.select(&:previous_matches?).each do |match|
            match.previous_matches.each do |previous_match|
              csp.add_constraint(
                new(target_match: match, matches: [previous_match])
              )
            end
          end
        end
      end

      def initialize(target_match:, matches:)
        super([target_match] + matches)
        @target_match = target_match
        @matches = matches
      end

      def satisfies?(assignment)
        return true unless variables.all? { |variable| assignment.key?(variable) }

        target_time = assignment[target_match]

        matches
          .map { |match| assignment[match] }
          .all? { |time| time < target_time }
      end
    end
  end
end
