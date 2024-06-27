# frozen_string_literal: true

module SportsManager
  # Public: Build matches objects from category, teams, and list of matches.
  class MatchBuilder
    attr_reader :category, :matches, :teams, :builded_matches, :tournament_type

    INITIAL_ID = 1
    DEFAULT_MATCH_CLASS = Match
    BYE_MATCH_CLASS = ByeMatch
    NIL_TEAM = NilTeam

    def initialize(category:, matches:, teams:, tournament_type:, subscriptions:)
      @category = category
      @matches = matches_completer(matches, subscriptions)
      @builded_matches = []
      @tournament_type = tournament_type
      @teams = teams
    end

    def build
      return build_already_generated_matches if generated_matches_structure?

      build_matches
    end

    private

    def participant_ids
      return matches unless generated_matches_structure?

      matches.map do |match|
        match[:participants]
      end
    end

    def generated_matches_structure?
      matches&.first.is_a?(Hash)
    end

    def build_already_generated_matches
      matches.each do |match|
        builded_matches << build_match(match_id: match[:id],
                                       participant_ids: match[:participants],
                                       round: match[:round] || 0,
                                       depends_on: match[:depends_on] || [])
      end
      builded_matches
    end

    def build_matches
      initial_matches | future_matches
    end

    def initial_matches
      @initial_matches ||= participant_ids.map.with_index(INITIAL_ID) do |participant_ids, match_id|
        build_match(match_id: match_id, participant_ids: participant_ids)
      end
    end

    def build_match(match_id:, participant_ids:, round: 0, depends_on: [])
      participant_ids
        .map { |id| Array(id) }
        .map { |id_array| find_team(id_array) }
        .yield_self do |team1, team2|
        initialize_match(match_id: match_id, teams: [team1, team2], round: round,
                         depends_on: depends_on, participant_ids: participant_ids)
      end
    end

    def find_team(participant_ids)
      teams.find do |team|
        team.find_participants(participant_ids)
      end
    end

    def initialize_match(match_id:, teams:, round:, depends_on: [], participant_ids: [])
      klass = match_class(teams: teams, participant_ids: participant_ids)
      team1, team2 = teams.map { |team| team || NIL_TEAM.new(category: category) }

      depends_on_matches = builded_matches.map do |match|
        depends_on.include?(match.id) ? match : nil
      end.compact

      klass.new(category: category, team1: team1, team2: team2, id: match_id, round: round,
                depends_on: depends_on_matches)
    end

    def match_class(teams:, participant_ids:)
      return BYE_MATCH_CLASS if teams.any?(&:nil?) && participant_ids.size == 1

      DEFAULT_MATCH_CLASS
    end

    def future_matches
      Matches::NextRound
        .new(category: category, base_matches: initial_matches, algorithm: tournament_type)
        .next_matches
    end

    def matches_completer(matches, subscriptions)
      return MatchesGenerator.call({ category => subscriptions }).values.first if matches.nil? || matches.empty?

      matches
    end
  end
end
