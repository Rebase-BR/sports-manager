# frozen_string_literal: true

module SportsManager
  class TeamBuilder
    attr_reader :category, :subscriptions, :participants

    def initialize(category:, subscriptions:)
      @category = category
      @subscriptions = subscriptions
      @participants = subscriptions.flatten
    end

    def build
      subscriptions.map(&method(:build_team))
    end

    private

    def build_team(team)
      team_participants = Utils::Array
        .wrap(team)
        .map { |participant| build_participant(participant) }

      Team.for(category: category, participants: team_participants)
    end

    def build_participant(participant)
      Participant.new(**participant)
    end
  end
end
