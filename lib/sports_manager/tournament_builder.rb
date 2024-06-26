# frozen_string_literal: true

module SportsManager
  # Public: A step-by-step tournament constructor (Builder Pattern)
  class TournamentBuilder
    attr_reader :matches, :subscriptions,
                :categories, :configurations,
                :tournament_days, :tournament

    DEFAULT_CONFIGURATIONS = {
      courts: 1,
      match_time: 60,
      break_time: 10,
      single_day_matches: false,
      tournament_type: Matches::Algorithms::SingleEliminationAlgorithm
    }.freeze

    def initialize
      @matches = {}
      @subscriptions = {}
      @categories = []
      @tournament_days = []
      @configurations = DEFAULT_CONFIGURATIONS
    end

    def build
      Tournament.new(settings: settings, groups: groups)
    end

    def add_matches(matches)
      matches.each do |category, category_matches|
        add_match(category: category, category_matches: category_matches)
      end

      self
    end

    def add_match(category:, category_matches:)
      return self if [category, category_matches].any?(nil)

      @matches.merge!(category => category_matches)

      self
    end

    def add_subscription(category:, participants:)
      @subscriptions.merge!(category => participants)

      self
    end

    def add_subscriptions(subscriptions)
      subscriptions.each do |category, participants|
        add_subscription(category: category, participants: participants)
      end

      self
    end

    def add_configuration(key:, value:)
      return self if [key, value].any?(nil)

      @configurations = @configurations.merge(key.to_sym => value)

      self
    end

    def add_configurations(params)
      params.each { |key, value| add_configuration(key: key, value: value) }

      self
    end

    def add_schedule(tournament_days)
      tournament_days.each do |date, period|
        add_date(
          date: date,
          start_hour: period[:start],
          end_hour: period[:end]
        )
      end
      self
    end

    def add_date(date:, start_hour:, end_hour:)
      @tournament_days << TournamentDay.for(
        date: date,
        start_hour: start_hour,
        end_hour: end_hour
      )

      self
    end

    private

    def groups
      categories = subscriptions.keys

      categories.map do |category|
        category_subscriptions = subscriptions[category]
        category_matches = matches[category]

        Group.for(
          category: category,
          subscriptions: category_subscriptions,
          matches: category_matches,
          tournament_type: configurations[:tournament_type]
        )
      end
    end

    def settings
      Tournament::Setting.new(
        tournament_days: tournament_days,
        match_time: configurations[:match_time],
        break_time: configurations[:break_time],
        courts: configurations[:courts],
        single_day_matches: configurations[:single_day_matches]
      )
    end
  end
end
