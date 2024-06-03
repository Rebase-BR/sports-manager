# frozen_string_literal: true

require 'spec_helper'
require_relative '../../shared/algorithms/filtering'

RSpec.describe SportsManager::Algorithms::Filtering::NoOverlap do
  it_behaves_like 'filter algorithm initializes with dependency'

  describe '#call' do
    it 'returns the values that are not overlapping with assignment values' do
      date = instance_double(SportsManager::TournamentDay)

      slot_date = '2023-10-10'
      slot1 = Time.parse("#{slot_date}T10:00:00")
      slot2 = Time.parse("#{slot_date}T10:30:00")
      slot3 = Time.parse("#{slot_date}T11:00:00")
      slot4 = Time.parse("#{slot_date}T11:30:00")
      slot5 = Time.parse("#{slot_date}T12:00:00")
      slot6 = Time.parse("#{slot_date}T12:30:00")
      slot7 = Time.parse("#{slot_date}T13:00:00")
      slot8 = Time.parse("#{slot_date}T13:30:00")

      timeslot1 = SportsManager::Timeslot.new(slot: slot1, court: 1, date: date)
      timeslot2 = SportsManager::Timeslot.new(slot: slot2, court: 1, date: date)
      timeslot3 = SportsManager::Timeslot.new(slot: slot3, court: 1, date: date)
      timeslot4 = SportsManager::Timeslot.new(slot: slot4, court: 1, date: date)
      timeslot5 = SportsManager::Timeslot.new(slot: slot5, court: 1, date: date)
      timeslot6 = SportsManager::Timeslot.new(slot: slot6, court: 1, date: date)
      timeslot7 = SportsManager::Timeslot.new(slot: slot7, court: 1, date: date)
      timeslot8 = SportsManager::Timeslot.new(slot: slot8, court: 1, date: date)

      tournament = instance_double(SportsManager::Tournament, match_time: 60)
      values = [
        timeslot1, timeslot2, timeslot3, timeslot4,
        timeslot5, timeslot6, timeslot7, timeslot8
      ]
      assignment_values = [timeslot3, timeslot6]

      filter_algorithm = described_class.new(tournament)

      new_values = filter_algorithm.call(values: values, assignment_values: assignment_values)

      expect(new_values).to eq [timeslot1, timeslot8]
    end

    context 'when different courts' do
      it 'returns the values that dont overlap in same court' do
        date = instance_double(SportsManager::TournamentDay)

        slot_date = '2023-10-10'
        slot1 = Time.parse("#{slot_date}T10:00:00")
        slot2 = Time.parse("#{slot_date}T11:00:00")
        slot3 = Time.parse("#{slot_date}T11:30:00")
        slot4 = Time.parse("#{slot_date}T12:30:00")

        slot5 = Time.parse("#{slot_date}T10:00:00")
        slot6 = Time.parse("#{slot_date}T11:00:00")
        slot7 = Time.parse("#{slot_date}T11:30:00")
        slot8 = Time.parse("#{slot_date}T12:30:00")

        timeslot1 = SportsManager::Timeslot.new(slot: slot1, court: 1, date: date)
        timeslot2 = SportsManager::Timeslot.new(slot: slot2, court: 1, date: date)
        timeslot3 = SportsManager::Timeslot.new(slot: slot3, court: 1, date: date)
        timeslot4 = SportsManager::Timeslot.new(slot: slot4, court: 1, date: date)

        timeslot5 = SportsManager::Timeslot.new(slot: slot5, court: 2, date: date)
        timeslot6 = SportsManager::Timeslot.new(slot: slot6, court: 2, date: date)
        timeslot7 = SportsManager::Timeslot.new(slot: slot7, court: 2, date: date)
        timeslot8 = SportsManager::Timeslot.new(slot: slot8, court: 2, date: date)

        tournament = instance_double(SportsManager::Tournament, match_time: 60)
        values = [
          timeslot1, timeslot2, timeslot3,
          timeslot4, timeslot5, timeslot6,
          timeslot7, timeslot8
        ]

        assignment_values = [timeslot1]

        filter_algorithm = described_class.new(tournament)

        new_values = filter_algorithm.call(values: values, assignment_values: assignment_values)

        expect(new_values).to eq [
          timeslot2, timeslot3, timeslot4, timeslot5,
          timeslot6, timeslot7, timeslot8
        ]
      end

      context 'when assignments are in both courts' do
        it 'returns the values that dont overlap in same court' do
          date = instance_double(SportsManager::TournamentDay)

          slot_date = '2023-10-10'
          slot1 = Time.parse("#{slot_date}T10:00:00")
          slot2 = Time.parse("#{slot_date}T11:00:00")
          slot3 = Time.parse("#{slot_date}T11:30:00")
          slot4 = Time.parse("#{slot_date}T12:30:00")

          slot5 = Time.parse("#{slot_date}T10:00:00")
          slot6 = Time.parse("#{slot_date}T11:00:00")
          slot7 = Time.parse("#{slot_date}T11:30:00")
          slot8 = Time.parse("#{slot_date}T12:30:00")
          slot9 = Time.parse("#{slot_date}T09:00:00")

          timeslot1 = SportsManager::Timeslot.new(slot: slot1, court: 1, date: date)
          timeslot2 = SportsManager::Timeslot.new(slot: slot2, court: 1, date: date)
          timeslot3 = SportsManager::Timeslot.new(slot: slot3, court: 1, date: date)
          timeslot4 = SportsManager::Timeslot.new(slot: slot4, court: 1, date: date)

          timeslot5 = SportsManager::Timeslot.new(slot: slot5, court: 2, date: date)
          timeslot6 = SportsManager::Timeslot.new(slot: slot6, court: 2, date: date)
          timeslot7 = SportsManager::Timeslot.new(slot: slot7, court: 2, date: date)
          timeslot8 = SportsManager::Timeslot.new(slot: slot8, court: 2, date: date)
          timeslot9 = SportsManager::Timeslot.new(slot: slot9, court: 2, date: date)

          tournament = instance_double(SportsManager::Tournament, match_time: 60)
          values = [
            timeslot1, timeslot2, timeslot3,
            timeslot4, timeslot5, timeslot6,
            timeslot7, timeslot8, timeslot9
          ]

          assignment_values = [timeslot3, timeslot6]

          filter_algorithm = described_class.new(tournament)

          new_values = filter_algorithm.call(values: values, assignment_values: assignment_values)

          expect(new_values).to eq [
            timeslot1, timeslot4, timeslot5,
            timeslot8, timeslot9
          ]
        end
      end
    end

    context 'when all values overlap' do
      it 'returns an empty list' do
        date = instance_double(SportsManager::TournamentDay)

        slot_date = '2023-10-10'
        slot1 = Time.parse("#{slot_date}T11:00:00")
        slot2 = Time.parse("#{slot_date}T11:30:00")
        slot3 = Time.parse("#{slot_date}T11:45:00")

        timeslot1 = SportsManager::Timeslot.new(slot: slot1, court: 1, date: date)
        timeslot2 = SportsManager::Timeslot.new(slot: slot2, court: 1, date: date)
        timeslot3 = SportsManager::Timeslot.new(slot: slot3, court: 1, date: date)

        tournament = instance_double(SportsManager::Tournament, match_time: 60)
        values = [timeslot1, timeslot2, timeslot3]
        assignment_values = [timeslot3]

        filter_algorithm = described_class.new(tournament)

        new_values = filter_algorithm.call(values: values, assignment_values: assignment_values)

        expect(new_values).to eq []
      end
    end

    context 'when no assignment values are passed' do
      it 'returns all the values' do
        date = instance_double(SportsManager::TournamentDay)

        slot_date = '2023-10-10'
        slot1 = Time.parse("#{slot_date}T10:00:00")
        slot2 = Time.parse("#{slot_date}T11:00:00")
        slot3 = Time.parse("#{slot_date}T11:30:00")
        slot4 = Time.parse("#{slot_date}T12:00:00")

        timeslot1 = SportsManager::Timeslot.new(slot: slot1, court: 1, date: date)
        timeslot2 = SportsManager::Timeslot.new(slot: slot2, court: 1, date: date)
        timeslot3 = SportsManager::Timeslot.new(slot: slot3, court: 1, date: date)
        timeslot4 = SportsManager::Timeslot.new(slot: slot4, court: 1, date: date)

        tournament = instance_double(SportsManager::Tournament, match_time: 60)
        values = [timeslot1, timeslot2, timeslot3, timeslot4]

        filter_algorithm = described_class.new(tournament)

        new_values = filter_algorithm.call(values: values)

        expect(new_values).to eq values
      end
    end
  end
end
