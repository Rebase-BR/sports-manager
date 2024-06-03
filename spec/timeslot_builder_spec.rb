# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::TimeslotBuilder do
  describe '.build' do
    it 'builds the timeslots for a tournament day' do
      date = '2023-10-10'
      start_hour = 12
      end_hour = 15
      interval = 60
      tournament_day = SportsManager::TournamentDay.new(date: date, start_hour: start_hour, end_hour: end_hour)

      builder = described_class.new(tournament_day: tournament_day, interval: interval)

      expect(builder.build).to eq [
        Time.parse("#{date}T12:00:00"),
        Time.parse("#{date}T13:00:00"),
        Time.parse("#{date}T14:00:00"),
        Time.parse("#{date}T15:00:00")
      ]
    end

    context 'when interval is under an hour' do
      it 'builds the timeslots for a tournament day' do
        date = '2023-10-10'
        start_hour = 12
        end_hour = 15
        interval = 30
        tournament_day = SportsManager::TournamentDay.new(date: date, start_hour: start_hour, end_hour: end_hour)

        builder = described_class.new(tournament_day: tournament_day, interval: interval)

        expect(builder.build).to eq [
          Time.parse("#{date}T12:00:00"),
          Time.parse("#{date}T12:30:00"),
          Time.parse("#{date}T13:00:00"),
          Time.parse("#{date}T13:30:00"),
          Time.parse("#{date}T14:00:00"),
          Time.parse("#{date}T14:30:00"),
          Time.parse("#{date}T15:00:00")
        ]
      end
    end

    context 'when interval is above an hour' do
      it 'builds the timeslots for a tournament day' do
        date = '2023-10-10'
        start_hour = 12
        end_hour = 15
        interval = 90
        tournament_day = SportsManager::TournamentDay.new(date: date, start_hour: start_hour, end_hour: end_hour)

        builder = described_class.new(tournament_day: tournament_day, interval: interval)

        expect(builder.build).to eq [
          Time.parse("#{date}T12:00:00"),
          Time.parse("#{date}T13:30:00"),
          Time.parse("#{date}T15:00:00")
        ]
      end
    end
  end
end
