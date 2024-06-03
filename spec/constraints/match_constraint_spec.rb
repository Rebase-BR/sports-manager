# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Constraints::MatchConstraint do
  describe '.for_tournament' do
    it 'sets constraint for next rounds matches' do
      csp = spy
      constraint = instance_double(described_class)
      matches = [double, double, double]
      target_match = instance_double(
        SportsManager::Match,
        previous_matches?: true,
        previous_matches: matches
      )
      tournament = instance_double(
        SportsManager::Tournament,
        matches: { mixed_single: [target_match] }
      )

      allow(described_class)
        .to receive(:new)
        .with(target_match: target_match, matches: matches)
        .and_return constraint

      described_class.for_tournament(tournament: tournament, csp: csp)

      expect(csp).to have_received(:add_constraint).with(constraint)
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
