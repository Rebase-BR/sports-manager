# frozen_string_literal: true

module SportsManager
  # Public: Participants in a team for a tournament category
  class Team
    attr_reader :category, :participants

    def self.for(participants:, category:)
      klass = case participants.size
              when 1 then SingleTeam
              when 2 then DoubleTeam
              else raise StandardError,
                         "Participants #{participants} is not " \
                         'between 1 and 2'
      end

      klass.new(participants: participants, category: category)
    end

    def initialize(participants:, category: nil)
      @category = category
      @participants = participants
    end

    def name
      participants
        .flat_map(&:name)
        .join(' e ')
    end

    def find_participant(id)
      participants.find { |participant| participant.id == id }
    end

    def find_participants(ids)
      unique_ids = ids.uniq
      found_participants = unique_ids.map(&method(:find_participant)).compact
      found_participants if found_participants.size == unique_ids.size
    end

    def ==(other)
      instance_of?(other.class) &&
        category == other.category &&
        participants == other.participants
    end
  end
end
