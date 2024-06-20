# frozen_string_literal: true

module SportsManager
  class MatchesGenerator
    def self.call(subscriptions)
      new(subscriptions).call
    end

    def initialize(subscriptions)
      @subscriptions = subscriptions
    end

    def call
      @subscriptions.transform_values do |subscriptions|
        generate_matches(subscriptions)
      end
    end

    private

    attr_reader :subscriptions

    def generate_matches(subscriptions)
      list = subscriptions.dup
      size = subscriptions.size
      number_of_matches = size.even? ? (size / 2) : ((size / 2) + 1)

      match_subscriptions = number_of_matches.times.map do
        match = [list.shift, list.pop].compact
        match unless match.empty?
      end.compact

      as_ids(match_subscriptions)
    end

    def as_ids(match_subscriptions)
      if double?(match_subscriptions.first)
        match_subscriptions.map { |match| double_fetch_ids(match) }
      else
        match_subscriptions.map { |match| single_fetch_ids(match) }
      end
    end

    def single_fetch_ids(match)
      match.map { |team| team[:id] }
    end

    def double_fetch_ids(match)
      match.map { |team| team.map { |player| player[:id] } }
    end

    def double?(match)
      match.all? { |team| team.is_a?(Array) }
    end
  end
end
