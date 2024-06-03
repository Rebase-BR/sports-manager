# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
module SportsManager
  # Public: Tenis Tournament Solver
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

    attr_reader :params, :format, :tournament, :variables, :domains,
                :ordering, :filtering, :csp

    def_delegators :tournament, :match_time, :timeslots, :matches

    def self.example(type = :simple, format: :cli)
      params = Helper.public_send(type)

      new(params, format: format).call
    end

    def self.call(params, format: :cli)
      new(params, format: format).call
    end

    def initialize(params, format: :cli)
      @params = params
      @format = format
      @ordering = Algorithms::Ordering::MultipleMatchesParticipant
      @filtering = Algorithms::Filtering::NoOverlap
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
      @tournament = ProblemParser.call(params)

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

    def print_solution(tournament_solution)
      SolutionDrawer.new(tournament_solution).public_send(format)
    end
  end
end
# rubocop:enable Metrics/AbcSize

# # frozen_string_literal: true

#
# module SportsManager
#     class TournamentGenerator
#       require "forwardable"
#       require "csp-resolver"
#       require "sports_manager/helper"
#       require "sports_manager/algorithms/ordering/multiple_matches_participant"
#       require "sports_manager/algorithms/filtering/no_overlap"
#       require "sports_manager/problem_parser"
#       require "sports_manager/constraints/all_different_constraint"
#       require "sports_manager/constraints/no_overlapping_constraint"
#       require "sports_manager/constraints/match_constraint"
#       require "sports_manager/constraints/multi_category_constraint"
#       require "sports_manager/constraints/next_round_constraint"
#       require "sports_manager/tournament_problem_builder"

#       extend Forwardable

#       attr_reader :params, :format, :tournament, :variables, :domains,
#                   :ordering, :filtering, :csp

#       def_delegators :tournament, :match_time, :timeslots, :matches

#       def self.example(type = :simple, format: :cli)
#         params = Helper.public_send(type)

#         new(params, format: format).call
#       end

#       def self.call(params, format: :cli)
#         new(params, format: format).call
#       end

#       def initialize(params = nil, format: :cli)
#         @params = params
#         @format = format
#         @ordering = Algorithms::Ordering::MultipleMatchesParticipant
#         @filtering = Algorithms::Filtering::NoOverlap
#       end

#       def call
#         setup

#         solutions = csp.solve

#         p @solutions
#       end

#       private

#       def setup
#         @tournament = ProblemParser.call(params)
#         @variables = @tournament.matches.values.flat_map(&:itself)

#         @domains = @variables.each_with_object({}) do |variable, domains|
#           domains[variable] = timeslots.sort_by(&:slot)
#         end

#         @csp = TournamentProblemBuilder
#           .new(tournament)
#           .add_variables(variables)
#           .add_domains(domains)
#           .add_ordering(ordering)
#           .add_filtering(filtering)
#           .add_constraint(Constraints::AllDifferentConstraint)
#           .add_constraint(Constraints::NoOverlappingConstraint)
#           .add_constraint(Constraints::MatchConstraint)
#           .add_constraint(Constraints::MultiCategoryConstraint)
#           .add_constraint(Constraints::NextRoundConstraint)
#           .build
#       end
#     end
# end
#
