# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Constraints::MatchConstraint do
  describe '.for_tournament' do
    it 'sets constraint for next rounds matches' do
      params = { category: 'mixed_single', round: 0, depends_on: [] }

      match1, match2, match3 = matches = [
        SportsManager::Match.new(**params.merge(id: 1)),
        SportsManager::Match.new(**params.merge(id: 2)),
        SportsManager::Match.new(**params.merge(id: 3))
      ]
      target_match = SportsManager::Match.new(**params.merge(id: 4, depends_on: matches))

      tournament = instance_double(
        SportsManager::Tournament,
        matches: { mixed_single: [target_match] }
      )

      csp = CSP::Problem.new.add_variables(
        matches + [target_match], domains: [spy]
      )

      allow(csp).to receive(:add_constraint)
      allow(described_class).to receive(:new).and_call_original

      described_class.for_tournament(tournament: tournament, csp: csp)

      expect(csp).to have_received(:add_constraint).thrice
      expect(described_class).to have_received(:new).with(target_match: target_match, matches: [match1])
      expect(described_class).to have_received(:new).with(target_match: target_match, matches: [match2])
      expect(described_class).to have_received(:new).with(target_match: target_match, matches: [match3])
    end
  end

  describe '#satisfies?' do
    context 'when all variables are assigned' do
      context 'and target match has a later time from related matches' do
        it 'returns true' do
          match_a = instance_double(SportsManager::Match)
          match_b = instance_double(SportsManager::Match)
          matches = [match_a, match_b]

          target_match = instance_double(SportsManager::Match, depends_on: matches)

          slot_a = Time.parse('2023-10-10T10:00:00')
          slot_b = Time.parse('2023-10-10T11:00:00')
          slot_c = Time.parse('2023-10-10T12:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)
          timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b,
            target_match => timeslot_c
          }

          constraint = described_class.new(target_match: target_match, matches: matches)

          expect(constraint.satisfies?(assignment)).to eq true
        end
      end

      context 'and target match has a earlier time from related matches' do
        it 'retuns false' do
          match_a = instance_double(SportsManager::Match)
          match_b = instance_double(SportsManager::Match)
          matches = [match_a, match_b]
          target_match = instance_double(SportsManager::Match, depends_on: matches)

          slot_a = Time.parse('2023-10-10T12:00:00')
          slot_b = Time.parse('2023-10-10T11:00:00')
          slot_c = Time.parse('2023-10-10T10:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)
          timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b,
            target_match => timeslot_c
          }

          constraint = described_class.new(target_match: target_match, matches: matches)

          expect(constraint.satisfies?(assignment)).to eq false
        end
      end

      context 'and target match has a time between two related matches' do
        it 'returns false' do
          match_a = instance_double(SportsManager::Match)
          match_b = instance_double(SportsManager::Match)
          matches = [match_a, match_b]
          target_match = instance_double(SportsManager::Match, depends_on: matches)

          slot_a = Time.parse('2023-10-10T12:00:00')
          slot_b = Time.parse('2023-10-10T10:00:00')
          slot_c = Time.parse('2023-10-10T11:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)
          timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b,
            target_match => timeslot_c
          }

          constraint = described_class.new(target_match: target_match, matches: matches)

          expect(constraint.satisfies?(assignment)).to eq false
        end
      end

      context 'and target match has a equal time from related matches' do
        it 'retuns false' do
          match_a = instance_double(SportsManager::Match)
          match_b = instance_double(SportsManager::Match)
          matches = [match_a, match_b]
          target_match = instance_double(SportsManager::Match, depends_on: matches)

          slot_a = Time.parse('2023-10-10T12:00:00')
          slot_b = Time.parse('2023-10-10T10:00:00')
          slot_c = Time.parse('2023-10-10T12:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)
          timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b,
            target_match => timeslot_c
          }

          constraint = described_class.new(target_match: target_match, matches: matches)

          expect(constraint.satisfies?(assignment)).to eq false
        end
      end

      context 'and target match has a equal time in an after date' do
        it 'retuns true' do
          match_a = instance_double(SportsManager::Match)
          match_b = instance_double(SportsManager::Match)
          matches = [match_a, match_b]
          target_match = instance_double(SportsManager::Match, depends_on: matches)

          slot_a = Time.parse('2023-10-10T12:00:00')
          slot_b = Time.parse('2023-10-10T10:00:00')
          slot_c = Time.parse('2023-11-11T10:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)
          timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b,
            target_match => timeslot_c
          }

          constraint = described_class.new(target_match: target_match, matches: matches)

          expect(constraint.satisfies?(assignment)).to eq true
        end
      end
    end

    context 'when not all matches are assigned' do
      it 'retuns true' do
        match_a = instance_double(SportsManager::Match)
        match_b = instance_double(SportsManager::Match)
        matches = [match_a, match_b]
        target_match = instance_double(SportsManager::Match, depends_on: matches)

        assignment = { target_match => double }

        constraint = described_class.new(target_match: target_match, matches: matches)

        satisfies = constraint.satisfies?(assignment)

        expect(satisfies).to eq true
      end
    end
  end
end
