# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::TournamentProblemBuilder do
  it 'initializes with default values' do
    tournament = instance_double(SportsManager::Tournament)
    builder = described_class.new(tournament)

    expect(builder).to have_attributes(
      constraints: [],
      variables: [],
      domains: {},
      filtering_algorithm: nil,
      ordering_algorithm: nil,
      max_solutions: 1,
      tournament: tournament
    )
  end

  describe '#build' do
    it 'builds a new CSP with variables, domains, and constraints' do
      variable = instance_double(SportsManager::Match)
      timeslot = instance_double(SportsManager::Timeslot)

      variables = [variable]
      domains = { variable => [timeslot] }
      max_solutions = 2

      constraint = SportsManager::Constraints::AllDifferentConstraint
      filtering_algorithm = CSP::Algorithms::Filtering::NoFilter
      ordering_algorithm = CSP::Algorithms::Ordering::NoOrder

      tournament = instance_double(
        SportsManager::Tournament,
        matches: { mixed_single: variables }
      )

      csp = described_class
        .new(tournament)
        .add_variables(variables)
        .add_domains(domains)
        .add_constraint(constraint)
        .add_max_solutions(max_solutions)
        .add_filtering(filtering_algorithm)
        .add_ordering(ordering_algorithm)
        .build

      expect(csp).to have_attributes(
        variables: variables,
        domains: domains,
        max_solutions: max_solutions,
        ordering_algorithm: have_attributes(class: ordering_algorithm, problem: csp),
        filtering_algorithm: have_attributes(class: filtering_algorithm, problem: csp),
        constraints: match(
          variable => match_array([
            have_attributes(class: constraint, matches: variables, variables: variables)
          ])
        )
      )
    end

    context "when using algorithms that don't depend on csp but in another property" do
      it 'pass the property as dependency to algorithm' do
        filtering_algorithm = SportsManager::Algorithms::Filtering::NoOverlap
        ordering_algorithm = SportsManager::Algorithms::Ordering::MultipleMatchesParticipant

        tournament = instance_double(SportsManager::Tournament)

        csp = described_class
          .new(tournament)
          .add_filtering(filtering_algorithm)
          .add_ordering(ordering_algorithm)
          .build

        expect(csp).to have_attributes(
          ordering_algorithm: have_attributes(
            class: ordering_algorithm,
            tournament: tournament
          ),
          filtering_algorithm: have_attributes(
            class: filtering_algorithm,
            tournament: tournament
          )
        )
      end
    end
  end

  describe '#add_variables' do
    it 'adds variables to builder' do
      variables = [double]
      tournament = instance_double(SportsManager::Tournament)
      builder = described_class.new(tournament)

      builder.add_variables(variables)

      expect(builder).to have_attributes(variables: variables)
    end

    context 'when calling more than once' do
      it 'overrides variables' do
        variables = [double]
        variables2 = [double, double]
        tournament = instance_double(SportsManager::Tournament)
        builder = described_class.new(tournament)

        builder
          .add_variables(variables)
          .add_variables(variables2)

        expect(builder).to have_attributes(variables: variables2)
      end
    end
  end

  describe '#add_domains' do
    it 'adds domains to builder' do
      domains = { double => [1, 2, 3] }
      tournament = instance_double(SportsManager::Tournament)
      builder = described_class.new(tournament)

      builder.add_domains(domains)

      expect(builder).to have_attributes(domains: domains)
    end

    context 'when calling more than once' do
      it 'overrides domains' do
        domains = { double => [1, 2, 3] }
        domains2 = { double => [1, 2, 3], double => [4, 5, 6] }
        tournament = instance_double(SportsManager::Tournament)
        builder = described_class.new(tournament)

        builder
          .add_domains(domains)
          .add_domains(domains2)

        expect(builder).to have_attributes(domains: domains2)
      end
    end
  end

  describe '#add_ordering' do
    it 'adds ordering algorithm to builder' do
      ordering_algorithm = instance_double(CSP::Algorithms::Ordering::NoOrder)
      tournament = instance_double(SportsManager::Tournament)
      builder = described_class.new(tournament)

      builder.add_ordering(ordering_algorithm)

      expect(builder).to have_attributes(ordering_algorithm: ordering_algorithm)
    end

    context 'when calling more than once' do
      it 'overrides ordering algorithm' do
        ordering_algorithm = instance_double(CSP::Algorithms::Ordering::NoOrder)
        ordering_algorithm2 = instance_double(CSP::Algorithms::Ordering::NoOrder)
        tournament = instance_double(SportsManager::Tournament)
        builder = described_class.new(tournament)

        builder
          .add_ordering(ordering_algorithm)
          .add_ordering(ordering_algorithm2)

        expect(builder).to have_attributes(ordering_algorithm: ordering_algorithm2)
      end
    end
  end

  describe '#add_filtering' do
    it 'adds filtering algorithm to builder' do
      filtering_algorithm = instance_double(CSP::Algorithms::Filtering::NoFilter)
      tournament = instance_double(SportsManager::Tournament)
      builder = described_class.new(tournament)

      builder.add_filtering(filtering_algorithm)

      expect(builder).to have_attributes(filtering_algorithm: filtering_algorithm)
    end

    context 'when calling more than once' do
      it 'overrides filtering algorithm' do
        filtering_algorithm = instance_double(CSP::Algorithms::Filtering::NoFilter)
        filtering_algorithm2 = instance_double(CSP::Algorithms::Filtering::NoFilter)
        tournament = instance_double(SportsManager::Tournament)
        builder = described_class.new(tournament)

        builder
          .add_filtering(filtering_algorithm)
          .add_filtering(filtering_algorithm2)

        expect(builder).to have_attributes(filtering_algorithm: filtering_algorithm2)
      end
    end
  end

  describe '#add_max_solutions' do
    it 'sets the number of max solutions' do
      max_solutions = 5
      tournament = instance_double(SportsManager::Tournament)
      builder = described_class.new(tournament)

      builder.add_max_solutions(max_solutions)

      expect(builder).to have_attributes(max_solutions: max_solutions)
    end

    context 'when calling more than once' do
      it 'overrides max solutions number' do
        max_solutions = 5
        max_solutions2 = 7
        tournament = instance_double(SportsManager::Tournament)
        builder = described_class.new(tournament)

        builder
          .add_max_solutions(max_solutions)
          .add_max_solutions(max_solutions2)

        expect(builder).to have_attributes(max_solutions: max_solutions2)
      end
    end

    context 'when passing a negative number' do
      it 'sets back to minimum number of solutions' do
        max_solutions = 5
        max_solutions2 = -7
        tournament = instance_double(SportsManager::Tournament)
        builder = described_class.new(tournament)

        builder
          .add_max_solutions(max_solutions)
          .add_max_solutions(max_solutions2)

        expect(builder).to have_attributes(max_solutions: 1)
      end
    end
  end

  describe '#add_constraint' do
    it 'adds constraint to builder' do
      constraint = CSP::Constraint
      tournament = instance_double(SportsManager::Tournament)
      builder = described_class.new(tournament)

      builder.add_constraint(constraint)

      expect(builder).to have_attributes(constraints: [constraint])
    end

    context 'when passing a list of constraints' do
      it 'adds them to constraints list' do
        constraint1 = CSP::Constraint
        constraint2 = SportsManager::Constraints::MatchConstraint
        tournament = instance_double(SportsManager::Tournament)
        builder = described_class.new(tournament)

        builder.add_constraint([constraint1, constraint2])

        expect(builder).to have_attributes(constraints: [constraint1, constraint2])
      end
    end

    context 'when calling more than once' do
      it 'appends to constraints list' do
        constraint1 = CSP::Constraint
        constraint2 = SportsManager::Constraints::MatchConstraint
        tournament = instance_double(SportsManager::Tournament)
        builder = described_class.new(tournament)

        builder
          .add_constraint(constraint1)
          .add_constraint(constraint2)

        expect(builder).to have_attributes(constraints: [constraint1, constraint2])
      end

      context 'and it is the same constraint' do
        it 'keeps only one' do
          constraint = CSP::Constraint
          constraint2 = CSP::Constraint
          tournament = instance_double(SportsManager::Tournament)
          builder = described_class.new(tournament)

          builder
            .add_constraint(constraint)
            .add_constraint(constraint2)

          expect(builder).to have_attributes(constraints: [constraint])
        end
      end

      context 'and passing a list of constraints' do
        it 'adds them to constraints list and keeps only one of each' do
          constraint1 = CSP::Constraint
          constraint2 = SportsManager::Constraints::MatchConstraint
          tournament = instance_double(SportsManager::Tournament)
          builder = described_class.new(tournament)

          builder
            .add_constraint(constraint1)
            .add_constraint(constraint2)
            .add_constraint([constraint1, constraint2])

          expect(builder).to have_attributes(constraints: [constraint1, constraint2])
        end
      end
    end
  end
end
