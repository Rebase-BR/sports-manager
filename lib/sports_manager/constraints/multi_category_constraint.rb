# frozen_string_literal: true

module SportsManager
  module Constraints
    class MultiCategoryConstraint < ::CSP::Constraint
      attr_reader :target_participant, :matches,
                  :match_time, :break_time, :minimum_match_gap

      MINUTE = 60
      IN_PAIRS = 2

      def self.for_tournament(tournament:, csp:)
        tournament.multi_tournament_participants.each do |participant|
          matches = tournament.find_participant_matches(participant)

          matches.combination(IN_PAIRS) do |match1, match2|
            constraint = new(
              target_participant: participant,
              matches: [match1, match2],
              match_time: tournament.match_time,
              break_time: tournament.break_time
            )

            csp.add_constraint(constraint)
          end
        end
      end

      def initialize(target_participant:, matches:, match_time:, break_time:)
        super(matches)
        @target_participant = target_participant
        @matches = matches
        @match_time = match_time
        @break_time = break_time
        @minimum_match_gap = match_time + break_time
      end

      # TODO: See if needs review in case of solution of split timeslots under match_time
      def satisfies?(assignment)
        return true unless variables.all? { |variable| assignment.key?(variable) }

        timeslots = assignment.slice(*variables).values.map(&:slot)

        timeslots.combination(2).all? do |timeslot1, timeslot2|
          diff_in_minutes = (timeslot1 - timeslot2).abs / MINUTE

          diff_in_minutes >= minimum_match_gap
        end
      end
    end
  end
end
