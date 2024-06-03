# frozen_string_literal: true

module SportsManager
  module Matches
    module Algorithms
      # TODO: implement
      # Public: Algorithm for building the rounds and matches in a
      # Single Elimination Tournament. This format is also known as Knockout
      class SingleEliminationAlgorithm
        attr_reader :category, :opening_round_matches, :opening_round_size

        def initialize(category:, matches:)
          @category = category
          @opening_round_matches = matches
          @opening_round_size = matches.size
        end

        # TODO: BYE, odd matches
        def next_matches
          return @next_matches if defined? @next_matches

          matches = opening_round_matches.dup

          remaining_matches.times.reduce(0) do |count, _|
            team1 = count
            team2 = team1 + 1

            matches << build_next_match(matches[team1], matches[team2], matches.size + 1)

            team2 + 1
          end

          @next_matches = matches - opening_round_matches
        end

        # TODO: make use of it later
        def needs_bye?
          !power_of_two?
        end

        # Internal: The number of matches required to find a winner, without a
        # third place match, is the number of players/teams minus one.
        def total_matches
          return 0 if teams_size.zero?

          teams_size - 1
        end

        # Internal: The number of rounds is the closest Log2N for N players.
        def total_rounds
          return 0 if teams_size.zero?

          Math.log2(teams_size).ceil
        end

        def round_for_match(match_number)
          return 0 if match_number.zero? || opening_round_size.zero?

          rounds = total_rounds

          (1..rounds).each do |round|
            matches_in_round = 2**(rounds - round)

            return round if match_number <= matches_in_round

            match_number -= matches_in_round
          end
        end

        private

        def teams_size
          @teams_size ||= opening_round_size * 2
        end

        def power_of_two?
          opening_round_size.to_s(2).count('1') == 1
        end

        def remaining_matches
          total_matches - opening_round_size
        end

        def build_next_match(match1, match2, id)
          depends_on = [match1, match2]
          dependencies = depends_on.map(&:depends_on).flatten
          round = dependencies && !dependencies.empty? ? (dependencies.size / 2) : 1

          Match.build_next_match(category: category, depends_on: depends_on, round: round, id: id)
        end
      end
    end
  end
end
