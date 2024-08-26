# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Constraints::NoOverlappingConstraint do
  describe '.for_tournament' do
    it 'sets constraints with all matches' do
      params = { category: 'mixed_single', round: 0, depends_on: [] }

      match1, match2, match3 = matches = [
        SportsManager::Match.new(**params.merge(id: 1)),
        SportsManager::Match.new(**params.merge(id: 2)),
        SportsManager::Match.new(**params.merge(id: 3))
      ]

      csp = CSP::Problem.new.add_variables(matches, domains: [spy])

      tournament = instance_double(
        SportsManager::Tournament,
        match_time: 60,
        break_time: 30,
        matches: {
          mixed_single: [match1, match2],
          mens_single: [match3]
        }
      )

      allow(csp).to receive(:add_constraint)
      allow(described_class).to receive(:new).and_call_original

      described_class.for_tournament(tournament: tournament, csp: csp)

      expect(csp).to have_received(:add_constraint).thrice
      expect(described_class).to have_received(:new).with(matches: [match1, match2], match_time: 60)
      expect(described_class).to have_received(:new).with(matches: [match1, match3], match_time: 60)
      expect(described_class).to have_received(:new).with(matches: [match2, match3], match_time: 60)
    end
  end

  describe '#satisfies?' do
    context 'when no match overlaps with another' do
      it 'returns true' do
        match_a = instance_double(SportsManager::Match)
        match_b = instance_double(SportsManager::Match)
        match_c = instance_double(SportsManager::Match)
        matches = [match_a, match_b, match_c]

        date = instance_double(SportsManager::TournamentDay)

        slot_date = '2023-10-10'
        slot_a = Time.parse("#{slot_date}T10:00:00")
        slot_b = Time.parse("#{slot_date}T11:00:00")
        slot_c = Time.parse("#{slot_date}T12:00:00")

        timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: 1, date: date)
        timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: 1, date: date)
        timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: 1, date: date)

        assignment = {
          match_a => timeslot_a,
          match_b => timeslot_b,
          match_c => timeslot_c
        }

        satisfies = described_class
          .new(matches: matches, match_time: 60)
          .satisfies?(assignment)

        expect(satisfies).to eq true
      end
    end

    context 'when matches are overlapping' do
      it 'returns false' do
        match_a = instance_double(SportsManager::Match)
        match_b = instance_double(SportsManager::Match)
        match_c = instance_double(SportsManager::Match)
        matches = [match_a, match_b, match_c]

        date = instance_double(SportsManager::TournamentDay)

        slot_date = '2023-10-10'
        slot_a = Time.parse("#{slot_date}T10:10:00")
        slot_b = Time.parse("#{slot_date}T11:00:00")
        slot_c = Time.parse("#{slot_date}T11:50:00")

        timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: 1, date: date)
        timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: 1, date: date)
        timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: 1, date: date)

        assignment = {
          match_a => timeslot_a,
          match_b => timeslot_b,
          match_c => timeslot_c
        }

        satisfies = described_class
          .new(matches: matches, match_time: 60)
          .satisfies?(assignment)

        expect(satisfies).to eq false
      end
    end

    context 'when matches overlapping in time but in different courts' do
      it 'returns true' do
        match_a = instance_double(SportsManager::Match)
        match_b = instance_double(SportsManager::Match)
        match_c = instance_double(SportsManager::Match)
        match_d = instance_double(SportsManager::Match)
        matches = [match_a, match_b, match_c, match_d]

        date = instance_double(SportsManager::TournamentDay)

        slot_date = '2023-10-10'
        slot_a = Time.parse("#{slot_date}T11:00:00")
        slot_b = Time.parse("#{slot_date}T11:00:00")
        slot_c = Time.parse("#{slot_date}T12:00:00")
        slot_d = Time.parse("#{slot_date}T12:00:00")

        timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: 1, date: date)
        timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: 2, date: date)
        timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: 1, date: date)
        timeslot_d = SportsManager::Timeslot.new(slot: slot_d, court: 2, date: date)

        assignment = {
          match_a => timeslot_a,
          match_b => timeslot_b,
          match_c => timeslot_c,
          match_d => timeslot_d
        }

        satisfies = described_class
          .new(matches: matches, match_time: 60)
          .satisfies?(assignment)

        expect(satisfies).to eq true
      end
    end
  end
end
