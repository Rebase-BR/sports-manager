# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Tournament::Setting do
  describe 'attributes' do
    it 'sets up attributes on initialization' do
      settings = described_class.new(
        match_time: 120,
        break_time: 30,
        courts: 1,
        single_day_matches: false,
        tournament_days: [
          SportsManager::TournamentDay.new(
            date: '2023-10-10',
            start_hour: '9',
            end_hour: '10'
          )
        ]
      )

      expect(settings).to have_attributes(
        {
          match_time: 120,
          break_time: 30,
          courts: 1,
          single_day_matches: false,
          tournament_days: [
            SportsManager::TournamentDay.new(
              date: '2023-10-10',
              start_hour: '9',
              end_hour: '10'
            )
          ]
        }
      )
    end
  end

  describe '#==' do
    it 'compares all attributes of two settings' do
      attributes = {
        match_time: 120,
        break_time: 30,
        courts: 1,
        single_day_matches: false,
        tournament_days: SportsManager::TournamentDay.new(date: '2023-10-10', start_hour: '9', end_hour: '10')
      }
      settings = described_class.new(**attributes)
      other_settings = described_class.new(**attributes)

      expect(settings == other_settings).to eq true
    end

    context 'when objects are different' do
      it 'returns false' do
        attributes = {
          match_time: 120,
          break_time: 30,
          courts: 1,
          single_day_matches: false,
          tournament_days: SportsManager::TournamentDay.new(date: '2023-10-10', start_hour: '9', end_hour: '10')
        }

        diff_attributes = {
          match_time: 121,
          break_time: 31,
          courts: 2,
          single_day_matches: true,
          tournament_days: SportsManager::TournamentDay.new(date: '2023-10-11', start_hour: '9', end_hour: '10')
        }

        settings = described_class.new(**attributes)

        diff_attributes.each do |attribute, value|
          param = attributes.merge(attribute => value)
          other_settings = described_class.new(**param)

          expect(settings == other_settings).to eq false
        end
      end
    end

    context 'when object compared is not a setting' do
      it 'returns false' do
        settings = described_class.new(
          match_time: 120,
          break_time: 30,
          courts: 1,
          single_day_matches: false,
          tournament_days: SportsManager::TournamentDay.new(
            date: '2023-10-10',
            start_hour: '9',
            end_hour: '10'
          )
        )
        other = Object.new

        expect(settings == other).to eq false
      end
    end
  end

  describe '#timeslots' do
    it 'returns available timeslots based on courts and dates' do
      tournament_day1, tournament_day2 = tournament_days = [
        SportsManager::TournamentDay.new(
          date: '2023-01-01',
          start_hour: 10,
          end_hour: 11
        ),
        SportsManager::TournamentDay.new(
          date: '2023-01-02',
          start_hour: 10,
          end_hour: 10
        )
      ]

      day1_court0_slot10 = Time.parse('2023-01-01T10:00:00')
      day1_court1_slot10 = Time.parse('2023-01-01T10:00:00')

      day1_court0_slot11 = Time.parse('2023-01-01T11:00:00')
      day1_court1_slot11 = Time.parse('2023-01-01T11:00:00')

      day2_court0_slot10 = Time.parse('2023-01-02T10:00:00')
      day2_court1_slot10 = Time.parse('2023-01-02T10:00:00')

      settings = described_class.new(
        tournament_days: tournament_days,
        match_time: 60,
        break_time: 60,
        courts: 2,
        single_day_matches: true
      )

      expect(settings.timeslots).to match_array [
        SportsManager::Timeslot.new(court: 0, date: tournament_day1, slot: day1_court0_slot10),
        SportsManager::Timeslot.new(court: 1, date: tournament_day1, slot: day1_court1_slot10),
        SportsManager::Timeslot.new(court: 0, date: tournament_day1, slot: day1_court0_slot11),
        SportsManager::Timeslot.new(court: 1, date: tournament_day1, slot: day1_court1_slot11),
        SportsManager::Timeslot.new(court: 0, date: tournament_day2, slot: day2_court0_slot10),
        SportsManager::Timeslot.new(court: 1, date: tournament_day2, slot: day2_court1_slot10)
      ]
    end
  end
end
