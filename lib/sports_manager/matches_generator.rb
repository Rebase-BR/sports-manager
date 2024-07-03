# frozen_string_literal: true

module SportsManager
  class MatchesGenerator
    def self.call(subscriptions_ids)
      new(subscriptions_ids).call
    end

    def initialize(subscriptions_ids)
      @subscriptions_ids = subscriptions_ids
    end

    def call
      generate_matches(@subscriptions_ids)
    end

    private

    attr_reader :subscriptions

    def generate_matches(subscriptions_ids)
      list = subscriptions_ids.dup
      size = subscriptions_ids.size

      number_of_matches = size.even? ? (size / 2) : ((size / 2) + 1)

      number_of_matches.times.map do
        match = [list.shift, list.pop].compact
        match unless match.empty?
      end.compact
    end
  end
end
