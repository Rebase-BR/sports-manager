# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Constraints::AllDifferentConstraint do
  describe '.for_tournament' do
    it 'sets constraint to tournament matches' do
      csp = spy
      matches1 = [double, double]
      matches2 = [double, double, double]
      tournament = instance_double(
        SportsManager::Tournament,
        matches: {
          mixed_single: matches1,
          mixed_double: matches2
        }
      )
      constraint = instance_double(described_class)

      allow(described_class)
        .to receive(:new)
        .with(matches1 + matches2)
        .and_return constraint

      described_class.for_tournament(tournament: tournament, csp: csp)

      expect(csp).to have_received(:add_constraint).with(constraint)
    end
  end

  describe '#satisfies?' do
    context 'when all assignments are different' do
      it 'retuns true' do
        constraint = described_class.new([])

        satisfies = constraint.satisfies?({ a: 1, b: 2, c: 3 })

        expect(satisfies).to eq true
      end
    end

    context 'when any two assignments are equal' do
      it 'retuns false' do
        constraint = described_class.new([])

        satisfies = constraint.satisfies?({ a: 1, b: 2, c: 1 })

        expect(satisfies).to eq false
      end
    end
  end
end
