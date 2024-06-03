# frozen_string_literal: true

module SportsManager
  # Public: A team's player in a tournament
  class Participant
    include Comparable

    attr_reader :id, :name

    alias eql? <=>

    def initialize(id:, name:)
      @id = id
      @name = name
    end

    def <=>(other)
      return unless instance_of?(other.class)

      id <=> other.id
    end
  end
end
