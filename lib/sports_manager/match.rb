# frozen_string_literal: true

module SportsManager
  # Public: A category's match with teams, which rounds is ocurring and which
  # matches its depends on before happening.
  class Match
    attr_reader :id, :category, :team1, :team2, :round, :teams, :depends_on

    def self.build_next_match(category:, depends_on:, id: nil, round: 0)
      new(
        id: id,
        category: category,
        round: round,
        depends_on: depends_on,
        team1: NilTeam.new(category: category),
        team2: NilTeam.new(category: category)
      )
    end

    def initialize(category:, id: nil, team1: nil, team2: nil, round: 0, depends_on: []) # rubocop:disable Metrics/ParameterLists
      @id = id
      @category = category
      @team1 = team1
      @team2 = team2
      @round = round
      @teams = [team1, team2].compact
      @depends_on = depends_on
    end

    def playable?
      true
    end

    def participants
      @participants ||= teams.map(&:participants).flatten
    end

    def dependencies?
      depends_on && !depends_on.empty?
    end

    def dependencies
      @dependencies ||= depends_on
        .flat_map { |match| [match, *match.depends_on] }
    end

    def playable_dependencies
      depends_on.select(&:playable?)
    end

    def previous_matches?
      previous_matches && !previous_matches.empty?
    end

    def previous_matches
      playable_dependencies.flat_map { |match| [match, *match.previous_matches] }
    end

    def title(title_format: 'M%<id>s')
      match_participants = if previous_matches?
        depends_on_names(title_format)
      else
        teams_names
      end

      match_participants.join(' vs. ')
    end

    def teams_names
      teams.map(&:name)
    end

    def ==(other)
      return false unless instance_of?(other.class)

      id == other.id && category == other.category && round == other.round
    end

    private

    def depends_on_names(title_format)
      depends_on.map do |match|
        if match.playable?
          format(title_format, id: match.id)
        else
          match.teams_names.join(' vs.')
        end
      end
    end
  end
end
