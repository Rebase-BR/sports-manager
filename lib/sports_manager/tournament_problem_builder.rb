# frozen_string_literal: true

module SportsManager
  # TODO: better name this
  # Public: Builds a CSP for Tournament Scheduling.
  #
  # Usage example:
  # builder = ProblemBuilder.new(tournament)
  #
  # builder
  #   .add_variables(variables)
  #   .add_domains(domains)
  #   .add_ordering(NoOrder)
  #   .add_filtering(NoFilter)
  #
  # builder
  #   .add_constraint(AllDifferentConstraint)
  #   .add_constraint(NoOverlapping)
  #
  # csp = builder.build
  class TournamentProblemBuilder
    attr_reader :variables, :domains, :constraints, :max_solutions,
                :filtering_algorithm, :ordering_algorithm, :lookahead_algorithm,
                :tournament

    MINIMUM_SOLUTIONS = 1

    def initialize(tournament)
      @variables = []
      @domains = {}
      @constraints = []

      @filtering_algorithm = nil
      @ordering_algorithm = nil
      @lookahead_algorithm = nil

      @max_solutions = MINIMUM_SOLUTIONS

      @tournament = tournament
    end

    def add_variables(variables)
      @variables = variables

      self
    end

    def add_domains(domains)
      @domains = domains

      self
    end

    def add_ordering(ordering_algorithm_class)
      @ordering_algorithm = ordering_algorithm_class

      self
    end

    def add_filtering(filtering_algorithm_class)
      @filtering_algorithm = filtering_algorithm_class

      self
    end

    def add_lookahead(lookahead_algorithm_class)
      @lookahead_algorithm = lookahead_algorithm_class

      self
    end

    # TODO: change to pass symbol instead of class?
    def add_constraint(constraint_class)
      @constraints |= Utils::Array.wrap(constraint_class)

      self
    end

    def add_max_solutions(max_solutions)
      @max_solutions = [max_solutions, MINIMUM_SOLUTIONS].find(&:positive?)

      self
    end

    def build
      csp.tap do |problem|
        variables.each do |variable|
          problem.add_variable(variable, domains: domains[variable])
        end

        problem.add_ordering(ordering(problem))
        problem.add_filtering(filtering(problem))
        problem.add_lookahead(lookahead(problem))

        build_constraint(problem)
      end
    end

    private

    def csp
      CSP::Problem.new(max_solutions: max_solutions)
    end

    def ordering(problem)
      return if ordering_algorithm.nil?

      ordering_algorithm.for(problem: problem, dependency: tournament)
    end

    def filtering(problem)
      return if filtering_algorithm.nil?

      filtering_algorithm.for(problem: problem, dependency: tournament)
    end

    def lookahead(problem)
      return if lookahead_algorithm.nil?

      lookahead_algorithm.new(problem)
    end

    def build_constraint(csp)
      ConstraintBuilder.build(tournament: tournament, csp: csp, constraints: constraints)
    end
  end
end
