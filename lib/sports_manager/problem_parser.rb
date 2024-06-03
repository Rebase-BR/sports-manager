# frozen_string_literal: true

module SportsManager
  # Public: Converts payload to a tournament
  class ProblemParser
    extend Forwardable

    ATTRIBUTES = %i[
      matches
      subscriptions
      courts
      game_length
      rest_brake
      single_day_matches
      when
    ].freeze

    NEW_ATTRIBUTES = {
      rest_brake: :rest_break,
      when: :tournament_days
    }.freeze

    attr_reader :params

    def_delegators :params, :courts,
                   :game_length, :rest_break,
                   :subscriptions, :matches,
                   :single_day_matches, :tournament_days

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      attributes = params
        .slice(*ATTRIBUTES)
        .transform_keys { |key| NEW_ATTRIBUTES[key] || key }

      @params = OpenStruct.new(attributes)
    end

    def call
      TournamentBuilder
        .new
        .add_matches(matches)
        .add_subscriptions(subscriptions)
        .add_schedule(tournament_days)
        .add_configuration(key: :courts, value: courts)
        .add_configuration(key: :match_time, value: game_length)
        .add_configuration(key: :break_time, value: rest_break)
        .add_configuration(key: :single_day_matches, value: single_day_matches)
        .build
    end

    def matches
      return params.matches if params.matches && !params.matches.empty?

      MatchesGenerator.call(@params)
    end
  end
end
