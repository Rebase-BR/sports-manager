# frozen_string_literal: true

module SportsManager
  class TournamentSolution
    # Public: A placeholder fixture for byes.
    class ByeFixture
      extend Forwardable

      attr_reader :match, :category

      def_delegator :match, :id, :match_id
      def_delegators :match, :title, :depends_on, :playable?,
                     :dependencies, :dependencies?

      def initialize(match)
        @match = match
        @category = match.category
      end
    end
  end
end
