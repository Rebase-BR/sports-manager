# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Constraints::NextRoundConstraint do
  describe '.for_tournament' do
    it 'sets constraint for next round matches with dependencies' do
      params = {
        category: spy,
        team1: spy,
        team2: spy,
        round: spy
      }

      match1 = SportsManager::Match.new(**params, id: 1, depends_on: [])
      match2 = SportsManager::Match.new(**params, id: 2, depends_on: [])
      match3 = SportsManager::Match.new(**params, id: 3, depends_on: [match1, match2])

      tournament = instance_double(
        SportsManager::Tournament,
        match_time: 60,
        break_time: 10,
        matches: { mixed_single: [match1, match2, match3] }
      )

      csp = CSP::Problem.new.add_variables([match1, match2, match3], domains: [spy])

      allow(csp).to receive(:add_constraint)
      allow(described_class).to receive(:new).and_call_original

      described_class.for_tournament(tournament: tournament, csp: csp)

      expect(csp).to have_received(:add_constraint).twice
      expect(described_class).to have_received(:new).with(
        target_match: match3,
        matches: [match1],
        match_time: 60,
        break_time: 10
      )
      expect(described_class).to have_received(:new).with(
        target_match: match3,
        matches: [match2],
        match_time: 60,
        break_time: 10
      )
    end

    context 'when it has byes' do
      it 'sets constraint for next round matches with playable matches' do
        csp = spy
        params = {
          id: spy,
          category: spy,
          team1: spy,
          team2: spy,
          round: spy
        }

        match1 = SportsManager::Match.new(**params, depends_on: [])
        match2 = SportsManager::ByeMatch.new(**params, depends_on: [])
        match3 = SportsManager::Match.new(**params, depends_on: [match1, match2])

        tournament = instance_double(
          SportsManager::Tournament,
          match_time: 60,
          break_time: 10,
          matches: { mixed_single: [match1, match2, match3] }
        )

        constraint = instance_double(described_class)

        allow(described_class)
          .to receive(:new)
          .with(
            target_match: match3,
            matches: [match1],
            match_time: 60,
            break_time: 10
          ).and_return constraint

        described_class.for_tournament(tournament: tournament, csp: csp)

        expect(csp).to have_received(:add_constraint).with(constraint)
      end
    end
  end

  describe '#satisfies?' do
    context 'when all variables are assigned' do
      context 'and target is later than matches including break time' do
        it 'returns true' do
          match1 = instance_double(SportsManager::Match, depends_on: [])
          match2 = instance_double(SportsManager::Match, depends_on: [])
          match3 = instance_double(SportsManager::Match, depends_on: [match1, match2])

          slot_a = Time.parse('2023-10-10T10:00:00')
          slot_b = Time.parse('2023-10-10T10:30:00')
          slot_c = Time.parse('2023-10-10T12:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)
          timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: spy, date: spy)

          assignment = {
            match1 => timeslot_a,
            match2 => timeslot_b,
            match3 => timeslot_c
          }

          satisfies = described_class.new(
            matches: [match1, match2],
            target_match: match3,
            match_time: 60,
            break_time: 30
          ).satisfies?(assignment)

          expect(satisfies).to eq true
        end
      end

      context 'and target is later than matches without break time' do
        it 'returns false' do
          match1 = instance_double(SportsManager::Match, depends_on: [])
          match2 = instance_double(SportsManager::Match, depends_on: [])
          match3 = instance_double(SportsManager::Match, depends_on: [match1, match2])

          slot_a = Time.parse('2023-10-10T10:00:00')
          slot_b = Time.parse('2023-10-10T10:00:00')
          slot_c = Time.parse('2023-10-10T11:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)
          timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: spy, date: spy)

          assignment = {
            match1 => timeslot_a,
            match2 => timeslot_b,
            match3 => timeslot_c
          }

          satisfies = described_class.new(
            matches: [match1, match2],
            target_match: match3,
            match_time: 60,
            break_time: 30
          ).satisfies?(assignment)

          expect(satisfies).to eq false
        end
      end
    end

    context 'when not all variables are set' do
      it 'returns true' do
        satisfies = described_class.new(
          matches: [double],
          target_match: double,
          match_time: 60,
          break_time: 10
        ).satisfies?({})

        expect(satisfies).to eq true
      end
    end
  end
end
