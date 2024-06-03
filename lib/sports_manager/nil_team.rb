# frozen_string_literal: true

module SportsManager
  # Public: A representation of no Team used by next round matches that don't
  # have a winner set yet.
  class NilTeam
    attr_reader :category, :participants

    def initialize(category:)
      @category = category
      @participants = []
    end

    def name
      ''
    end

    def ==(other)
      return false unless instance_of? other.class

      category == other.category
    end
  end
end
