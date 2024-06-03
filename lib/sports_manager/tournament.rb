# frozen_string_literal: true

module SportsManager
  # Public: A tennis tournament with different categories matches
  class Tournament
    extend Forwardable

    attr_reader :settings, :groups

    def_delegators :settings, :match_time, :break_time, :courts, :timeslots,
                   :single_day_matches, :tournament_days

    def initialize(settings: nil, groups: nil)
      @settings = settings
      @groups = groups
    end

    def ==(other)
      settings == other.settings && groups == other.groups
    end

    def categories
      @categories ||= groups.map(&:category)
    end

    def matches
      @matches ||= groups.each_with_object({}) do |group, category_matches|
        category_matches[group.category] = group.matches
      end
    end

    def first_round_matches
      categories.each_with_object({}) do |category, first_rounds|
        first_rounds[category] = find_matches(category: category, round: 0)
      end
    end

    def find_matches(category:, round:)
      category_matches = groups
        .find { |group| group.category == category }
        &.find_matches(round)

      category_matches || []
    end

    def total_matches
      matches.values.map(&:size).sum
    end

    def participants
      @participants ||= all_participants.uniq(&:id)
    end

    def multi_tournament_participants
      @multi_tournament_participants ||= participants
        .select { |participant| all_participants.count(participant) > 1 }
    end

    def find_participant_matches(participant)
      groups.flat_map { |group| group.find_participant_matches(participant) }
    end

    private

    def all_participants
      @all_participants ||= groups.map(&:participants).flatten
    end
  end
end
