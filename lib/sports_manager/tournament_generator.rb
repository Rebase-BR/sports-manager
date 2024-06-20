# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
module SportsManager
  # Public:Tournament Solver
  #               _TEAM A______
  #      MATCH 1               \_TEAM B______
  #               _TEAM B______/             \
  #                                MATCH 5    \_TEAM B___
  #               _TEAM C______               /          \
  #      MATCH 2               \_TEAM C______/            \
  #               _TEAM D______/                           \
  #                                             MATCH 7     \__TEAM E__
  #               _TEAM E______                             /
  #      MATCH 3               \_TEAM E______              /
  #               _TEAM F______/             \            /
  #                                MATCH 6    \_TEAM E___/
  #               _TEAM G______               /
  #      MATCH 4               \_TEAM G______/
  #               _TEAM H______/
  class TournamentGenerator
    extend Forwardable

    attr_reader :format, :tournament, :variables, :domains,
                :ordering, :filtering, :csp

    attr_accessor :params

    def_delegators :tournament, :match_time, :timeslots, :matches

    def self.example(type = :simple, format: :cli)
      params = Helper.public_send(type)

      new(format: format)
        .add_days(params[:when])
        .add_subscriptions(params[:subscriptions])
        .add_matches(params[:matches])
        .add_courts(params[:courts])
        .add_game_length(params[:game_length])
        .add_rest_break(params[:rest_break])
        .set_single_day_matches(params[:single_day_matches])
        .call
    end

    def initialize(format: :cli)
      @params = {}
      @format = format
      @ordering = Algorithms::Ordering::MultipleMatchesParticipant
      @filtering = Algorithms::Filtering::NoOverlap
    end

    def add_day(day, start, finish)
      params[:when] ||= {}
      params[:when][day.to_sym] = { start: start, end: finish }
      self
    end

    def add_days(days)
      days.each do |day, time_hash|
        add_day(day, time_hash[:start], time_hash[:end])
      end
      self
    end

    def add_subscription(category, subscription)
      params[:subscriptions] ||= {}
      params[:subscriptions][category] ||= []
      params[:subscriptions][category] << subscription
      self
    end

    def add_subscriptions_per_category(category, subscriptions)
      subscriptions.each { |subscription| add_subscription(category, subscription) }
      self
    end

    def add_subscriptions(subscriptions)
      subscriptions.each do |category, subscriptions|
        add_subscriptions_per_category(category, subscriptions)
      end
      self
    end

    def add_match(category, match)
      params[:matches] ||= {}
      params[:matches][category] ||= []
      params[:matches][category] << match
      self
    end

    def add_matches_per_category(category, matches)
      matches.each { |match| add_match(category, match) }
      self
    end

    def add_matches(matches)
      matches.each do |category, matches|
        add_matches_per_category(category, matches)
      end
      self
    end

    def add_courts(number_of_courts)
      params[:courts] = number_of_courts
      self
    end

    def add_game_length(game_length)
      params[:game_length] = game_length
      self
    end

    def add_rest_break(rest_break)
      params[:rest_break] = rest_break
      self
    end

    def set_single_day_matches(single_day_matches)
      params[:single_day_matches] = single_day_matches
      self
    end

    def call
      setup

      solutions = csp.solve

      TournamentSolution
        .new(tournament: tournament, solutions: solutions)
        .tap(&method(:print_solution))
    end

    private

    def setup
      @tournament = build_tournament

      @variables = @tournament.matches.values.flat_map(&:itself)

      @domains = @variables.each_with_object({}) do |variable, domains|
        domains[variable] = timeslots.sort_by(&:slot)
      end

      # TODO: Add a ordering specific for domains
      @csp = TournamentProblemBuilder
        .new(tournament)
        .add_variables(variables)
        .add_domains(domains)
        .add_ordering(ordering)
        .add_filtering(filtering)
        .add_constraint(Constraints::AllDifferentConstraint)
        .add_constraint(Constraints::NoOverlappingConstraint)
        .add_constraint(Constraints::MatchConstraint)
        .add_constraint(Constraints::MultiCategoryConstraint)
        .add_constraint(Constraints::NextRoundConstraint)
        .build
    end

    def build_tournament
      TournamentBuilder
        .new
        .add_matches(matches)
        .add_subscriptions(params[:subscriptions])
        .add_schedule(params[:when])
        .add_configuration(key: :courts, value: params[:courts])
        .add_configuration(key: :match_time, value: params[:game_length])
        .add_configuration(key: :break_time, value: params[:rest_break])
        .add_configuration(key: :single_day_matches, value: params[:single_day_matches])
        .build
    end

    def matches
      return params[:matches] if params[:matches] && !params[:matches].empty?

      MatchesGenerator.call(@params)
    end

    def print_solution(tournament_solution)
      SolutionDrawer.new(tournament_solution).public_send(format)
    end
  end
end
# rubocop:enable Metrics/AbcSize
