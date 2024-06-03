# frozen_string_literal: true

module SportsManager
  class TournamentSolution
    # NOTE: Maybe temporary? should each object override as_json?
    class Serializer
      require 'json'
      require 'forwardable'
      require 'sports_manager/json_helper'
      include JsonHelper
      extend Forwardable

      attr_reader :tournament_solution

      def initialize(tournament_solution)
        @tournament_solution = tournament_solution
        @tournament = tournament_solution.tournament
        @solutions = tournament_solution.solutions
      end

      def as_json(*)
        {
          tournament: tournament,
          solutions: solutions
        }.as_json
      end

      private

      def tournament
        {
          settings: settings,
          groups: groups,
          participants: participants
        }.as_json
      end

      def solutions
        @solutions
          .map(&method(:build_solution))
          .as_json
      end

      def settings
        setting = @tournament.settings

        params = {
          match_time: setting.match_time,
          break_time: setting.break_time,
          courts: setting.court_list,
          single_day_matches: setting.single_day_matches
        }

        params.as_json
      end

      def groups
        @tournament.groups.map do |group|
          {
            category: group.category,
            matches: build_matches(group)
          }
        end
      end

      def participants
        @tournament
          .participants
          .sort_by(&:id)
          .as_json
      end

      def build_solution(solution)
        fixtures = solution
          .fixtures
          .map(&method(:build_fixture))

        { fixtures: fixtures }
      end

      def build_fixture(fixture)
        {
          match: {
            id: fixture.match_id,
            title: fixture.title,
            category: fixture.category
          },
          timeslot: {
            court: fixture.court,
            slot: fixture.slot
          }
        }
      end

      def build_matches(group)
        matches = group
          .all_matches
          .sort_by { |match| [match.round, match.id] }

        matches.map do |match|
          {
            id: match.id,
            round: match.round,
            playing: match.title
          }
        end
      end
    end
  end
end
