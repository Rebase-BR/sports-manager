# frozen_string_literal: true

module SportsManager
  module Matches
    # Public: Determinates the next rounds and their dependencies
    class NextRound
      attr_reader :category, :base_matches, :match_maker

      # NOTE: maybe move logic to class method and just return the algorithm
      # NOTE: maybe keep it if mixing multiple formats and put decision logic in here
      # TODO: implement round-robin
      # TODO: implement to consider: start w round-robin followed by knockout
      DEFAULT_ALGORITHM = Algorithms::SingleEliminationAlgorithm

      def initialize(category:, base_matches:, algorithm: DEFAULT_ALGORITHM)
        @category = category
        @base_matches = base_matches
        @match_maker = algorithm.new(category: category, matches: base_matches)
      end

      def next_matches
        match_maker.next_matches
      end

      def total_matches
        match_maker.total_matches
      end

      def total_rounds
        match_maker.total_rounds
      end

      def round_for_match(match_number)
        match_maker.round_for_match(match_number)
      end
    end
  end
end
