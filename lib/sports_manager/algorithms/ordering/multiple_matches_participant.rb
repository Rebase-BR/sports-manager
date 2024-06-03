# frozen_string_literal: true

module SportsManager
  module Algorithms
    module Ordering
      class MultipleMatchesParticipant
        attr_reader :tournament

        def self.for(dependency:, problem: nil) # rubocop:disable Lint/UnusedMethodArgument
          new(dependency)
        end

        def initialize(tournament)
          @tournament = tournament
        end

        def call(variables)
          variables.sort_by(&method(:sort))
        end

        private

        def sort(variable)
          participants = variable.participants

          multi_matches = boolean_to_integer multi_matches?(participants)

          duplicate_ids = sorted_duplicates(participants)
          duplicate_ids_size = minimum(duplicate_ids.size)
          number_of_participants = minimum(participants.size)

          [
            multi_matches,
            duplicate_ids_size,
            duplicate_ids,
            number_of_participants,
            variable.id
          ]
        end

        def multi_matches?(participants)
          !(multiple_participants & participants).empty?
        end

        def sorted_duplicates(participants)
          participants
            .select { |participant| multiple_participants.include? participant }
            .map(&:id)
            .sort
        end

        def multiple_participants
          tournament.multi_tournament_participants
        end

        # Internal: Gives preference for positive finite values over zero
        # or infinity values when ordering.
        def minimum(number)
          values = [number, Float::INFINITY]

          values.min_by do |value|
            [
              boolean_to_integer(value.positive?),
              boolean_to_integer(value.finite?)
            ]
          end
        end

        # TODO: permit set as ascending or descending and swap -1 and 1
        # Internal: Truthy values should have a precedence over falsey in
        # ascending order
        def boolean_to_integer(truthyness)
          truthyness ? -1 : 1
        end
      end
    end
  end
end
