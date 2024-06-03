# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::ConstraintBuilder do
  describe '.build' do
    it 'instantiate and calls build with csp' do
      tournament = instance_double(Tennis::Tournament)
      csp = instance_double(CSP::Problem)
      constraint = instance_double('Constraint')
      constraints = [constraint]
      builder = spy

      allow(described_class)
        .to receive(:new)
        .with(tournament: tournament, constraints: constraints)
        .and_return builder

      described_class.build(tournament: tournament, csp: csp, constraints: constraints)

      expect(builder).to have_received(:build).with(csp)
    end
  end

  describe '#build' do
    it 'adds constraints to a csp' do
      tournament = instance_double(Tennis::Tournament)
      csp = instance_double(CSP::Problem)
      constraint = instance_double('Constraint', for_tournament: true)
      constraints = [constraint]

      allow(constraint).to receive(:for_tournament)

      builder = described_class.new(tournament: tournament, constraints: constraints)

      builder.build(csp)

      expect(constraint)
        .to have_received(:for_tournament)
        .with(tournament: tournament, csp: csp)
    end

    context 'when no constraint is passed' do
      it 'uses default constraints' do
        tournament = instance_double(Tennis::Tournament)
        csp = instance_double(CSP::Problem)
        constraints = [
          CSP::Constraints::AllDifferentConstraint,
          CSP::Constraints::NoOverlappingConstraint,
          CSP::Constraints::MatchConstraint,
          CSP::Constraints::MultiCategoryConstraint,
          CSP::Constraints::NextRoundConstraint
        ]

        constraints.each do |constraint|
          allow(constraint).to receive(:for_tournament)
        end

        builder = described_class.new(tournament: tournament)

        builder.build(csp)

        constraints.each do |constraint|
          expect(constraint)
            .to have_received(:for_tournament)
            .with(tournament: tournament, csp: csp)
        end
      end
    end
  end
end
