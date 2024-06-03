# frozen_string_literal: true

module SportsManager
  # Public: a Match where it has only one team.
  # This match is a placeholder used to create the next rounds.
  # The team in this match will automatically play on the next round.
  class ByeMatch
    attr_reader :id, :category, :team1, :team2, :round, :teams, :depends_on

    def initialize(category:, id: nil, team1: nil, team2: nil, round: 0, depends_on: [])
      @id = id
      @category = category
      @team1 = team1
      @team2 = team2
      @round = round
      @teams = [team1, team2].compact
      @depends_on = []
    end

    def playable?
      false
    end

    def participants
      @participants ||= teams.map(&:participants).flatten
    end

    def dependencies?
      false
    end

    def dependencies
      []
    end

    def playable_dependencies
      []
    end

    def previous_matches?
      false
    end

    def previous_matches
      []
    end

    def title
      teams_names.join.concat(' | BYE')
    end

    def teams_names
      teams.map(&:name).reject(&:empty?)
    end

    def ==(other)
      return false unless instance_of?(other.class)

      id == other.id && category == other.category && round == other.round
    end
  end
end
