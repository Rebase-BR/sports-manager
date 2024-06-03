# frozen_string_literal: true

module SportsManager
  module Constraints
    require 'csp-resolver'
    class NextRoundConstraint < ::CSP::Constraint
      attr_reader :target_match, :matches,
                  :match_time, :break_time, :minimum_match_gap

      MINUTE = 60

      def self.for_tournament(tournament:, csp:)
        tournament
          .matches.values.flatten
          .select(&:previous_matches?)
          .each do |match|
            csp.add_constraint new(
              target_match: match,
              matches: match.previous_matches,
              match_time: tournament.match_time,
              break_time: tournament.break_time
            )
          end
      end

      def initialize(target_match:, matches:, match_time:, break_time:)
        super([target_match] + matches)
        @target_match = target_match
        @matches = matches
        @match_time = match_time
        @break_time = break_time
        @minimum_match_gap = match_time + break_time
      end

      def satisfies?(assignment)
        return true unless variables.all? { |variable| assignment.key?(variable) }

        match_time = assignment[target_match].slot
        matches_timeslots = assignment.slice(*matches).values.map(&:slot)

        matches_timeslots.all? do |timeslot|
          diff_in_minutes = (timeslot - match_time).abs / MINUTE

          diff_in_minutes >= minimum_match_gap
        end
      end
    end
  end
end
