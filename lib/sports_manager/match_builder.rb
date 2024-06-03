# frozen_string_literal: true

module SportsManager
  # Public: Build matches objects from category, teams, and list of matches.
  class MatchBuilder
    attr_reader :category, :matches_ids, :teams, :participant_ids

    INITIAL_ID = 1
    DEFAULT_MATCH_CLASS = Match
    BYE_MATCH_CLASS = ByeMatch
    NIL_TEAM = NilTeam

    def initialize(category:, matches_ids:, teams:)
      @category = category
      @matches_ids = matches_ids
      @participant_ids = matches_ids
      @teams = teams
    end

    def build
      matches_ids.map.with_index(INITIAL_ID) do |participant_ids, match_id|
        build_match(match_id: match_id, participant_ids: participant_ids)
      end
    end

    private

    def build_match(match_id:, participant_ids:)
      participant_ids
        .map { |id| Array(id) }
        .map { |id_array| find_team(id_array) }
        .yield_self { |team1, team2| initialize_match(match_id: match_id, teams: [team1, team2]) }
    end

    def find_team(participant_ids)
      teams.find do |team|
        team.find_participants(participant_ids)
      end
    end

    def initialize_match(match_id:, teams:)
      klass = match_class(teams: teams)
      team1, team2 = teams.map { |team| team || NIL_TEAM.new(category: category) }

      klass.new(category: category, team1: team1, team2: team2, id: match_id)
    end

    def match_class(teams:)
      return BYE_MATCH_CLASS if teams.any?(&:nil?)

      DEFAULT_MATCH_CLASS
    end
  end
end
