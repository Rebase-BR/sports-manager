# frozen_string_literal: true

module SportsManager
  class TournamentSolution
    # Public: A schedule for the participating teams.
    class Fixture
      require_relative 'bye_fixture'
      extend Forwardable

      attr_reader :match, :timeslot, :category

      def_delegator :match, :id, :match_id
      def_delegators :match, :title, :depends_on, :playable?,
                     :dependencies, :dependencies?, :round
      def_delegators :timeslot, :court, :slot

      def self.build_fixtures(fixtures)
        fixtures.map { |(match, timeslot)| new(match: match, timeslot: timeslot) }
      end

      def initialize(match:, timeslot:)
        @match = match
        @timeslot = timeslot
        @category = match.category
      end

      def depends_on?(fixture)
        depends_on
          .map(&:id)
          .include?(fixture.match_id)
      end

      def bye_dependencies
        depends_on
          .reject(&:playable?)
          .map { |bye| ByeFixture.new(bye) }
      end
    end
  end
end
