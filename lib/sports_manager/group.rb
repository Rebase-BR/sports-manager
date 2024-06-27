# frozen_string_literal: true

module SportsManager
  # TODO: change the name Group. In terms of sports tournament it means something else.
  # Public: A category with teams and matches between them
  class Group
    attr_reader :category, :all_matches, :teams

    def self.for(category:, subscriptions:, matches:, tournament_type:)
      GroupBuilder.new(category: category, subscriptions: subscriptions, matches: matches,
                       tournament_type: tournament_type).build
    end

    def initialize(category: nil, matches: nil, teams: nil)
      @category = category
      @all_matches = matches
      @teams = teams
    end

    def participants
      @participants ||= teams.map(&:participants).flatten
    end

    def matches
      @matches ||= all_matches.select(&:playable?)
    end

    def first_round_matches
      find_matches(0)
    end

    def find_matches(round_number)
      matches.select { |match| match.round == round_number }
    end

    def find_participant_matches(participant)
      matches.select do |match|
        match.participants.include? participant
      end
    end
  end
end
