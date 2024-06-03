# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::TournamentDay do
  describe 'validation' do
    context 'when valid' do
      it 'returns instance' do
        params = { start_hour: 0, end_hour: 23, date: '2023-01-01' }

        expect { described_class.new(**params) }.to_not raise_error
      end
    end

    context 'when cannot parse date' do
      it 'raises an error' do
        params = { start_hour: 20, end_hour: 23, date: '2023-15-15' }

        expect { described_class.new(**params) }
          .to raise_error(
            described_class::Validator::DateParsingError,
            'It is not possible to parse Date: 2023-15-15'
          )
      end
    end

    context "when hours are not in a day's range" do
      it 'raises an error' do
        params = { start_hour: -1, end_hour: 23, date: '2023-01-01' }

        expect { described_class.new(**params) }
          .to raise_error(
            described_class::Validator::InvalidHour,
            'start_hour and end_hour must be between 0 and 23. ' \
            'start_hour: -1, end_hour: 23'
          )
      end
    end
  end

  describe '.for' do
    it 'returns a new, validated, object' do
      tournament_day = described_class.for(
        date: '2023-01-01',
        start_hour: 0,
        end_hour: 23
      )

      expect(tournament_day).to be_a described_class
      expect(tournament_day).to have_attributes(
        start_hour: 0,
        end_hour: 23,
        date: '2023-01-01'
      )
    end

    context 'when it is date invalid' do
      it 'raises an error' do
        params = { date: '2023-15-15', start_hour: 20, end_hour: 23 }

        expect { described_class.for(**params) }
          .to raise_error(
            described_class::Validator::DateParsingError,
            'It is not possible to parse Date: 2023-15-15'
          )
      end
    end

    context 'when it is start_hour invalid' do
      it 'raises an error' do
        params = { date: '2023-10-10', start_hour: -1, end_hour: 23 }

        expect { described_class.for(**params) }
          .to raise_error(
            described_class::Validator::InvalidHour,
            'start_hour and end_hour must be between 0 and 23. ' \
            'start_hour: -1, end_hour: 23'
          )
      end

      it 'raises an error' do
        params = { date: '2023-10-10', start_hour: 24, end_hour: 23 }

        expect { described_class.for(**params) }
          .to raise_error(
            described_class::Validator::InvalidHour,
            'start_hour and end_hour must be between 0 and 23. ' \
            'start_hour: 24, end_hour: 23'
          )
      end
    end

    context 'when it is end_hour invalid' do
      it 'raises an error' do
        params = { date: '2023-10-10', start_hour: 1, end_hour: -23 }

        expect { described_class.for(**params) }
          .to raise_error(
            described_class::Validator::InvalidHour,
            'start_hour and end_hour must be between 0 and 23. ' \
            'start_hour: 1, end_hour: -23'
          )
      end

      it 'raises an error' do
        params = { date: '2023-10-10', start_hour: 20, end_hour: 24 }

        expect { described_class.for(**params) }
          .to raise_error(
            described_class::Validator::InvalidHour,
            'start_hour and end_hour must be between 0 and 23. ' \
            'start_hour: 20, end_hour: 24'
          )
      end
    end
  end

  describe '#timeslots' do
    it 'returns a list of available timeslots' do
      tournament_day = described_class.new(
        start_hour: 10,
        end_hour: 15,
        date: '2023-01-01'
      )

      timeslots = tournament_day.timeslots

      expect(timeslots).to eq([
        Time.parse('2023-01-01T10:00:00'),
        Time.parse('2023-01-01T11:00:00'),
        Time.parse('2023-01-01T12:00:00'),
        Time.parse('2023-01-01T13:00:00'),
        Time.parse('2023-01-01T14:00:00'),
        Time.parse('2023-01-01T15:00:00')
      ])
    end

    context 'when passing a interval in minutes' do
      it 'returns a list of available timeslots for the interval' do
        tournament_day = described_class.new(
          start_hour: 10,
          end_hour: 15,
          date: '2023-01-01'
        )
        interval = 120

        timeslots = tournament_day.timeslots(interval: interval)

        expect(timeslots).to eq([
          Time.parse('2023-01-01T10:00:00'),
          Time.parse('2023-01-01T12:00:00'),
          Time.parse('2023-01-01T14:00:00')
        ])
      end
    end
  end

  describe '#total_time' do
    it 'returns the total number of hours from start to end' do
      tournament_day = described_class.new(
        start_hour: 10,
        end_hour: 15,
        date: '2023-01-01'
      )

      expect(tournament_day.total_time).to eq 5
    end
  end

  describe '#<=>' do
    context "when object's date, start_hour, and end_hour are equal" do
      it 'returns zero' do
        tournament_day1 = described_class.new(
          start_hour: 0,
          end_hour: 23,
          date: '2023-01-01'
        )
        tournament_day2 = described_class.new(
          start_hour: 0,
          end_hour: 23,
          date: '2023-01-01'
        )

        expect(tournament_day1 <=> tournament_day2).to be_zero
      end
    end

    context "when object's date is different" do
      it 'returns date comparison' do
        hours = { start_hour: 0, end_hour: 23 }

        tournament_day1 = described_class.new(date: '2023-01-10', **hours)
        tournament_day2 = described_class.new(date: '2023-01-11', **hours)
        tournament_day3 = described_class.new(date: '2023-01-09', **hours)

        expect(tournament_day1 <=> tournament_day2).to eq(-1)
        expect(tournament_day1 <=> tournament_day3).to eq(1)
      end
    end

    context "when object's start_hour is different" do
      it 'returns start_hour comparison' do
        params = { date: '2023-01-11', end_hour: 23 }

        tournament_day1 = described_class.new(start_hour: '10', **params)
        tournament_day2 = described_class.new(start_hour: '11', **params)
        tournament_day3 = described_class.new(start_hour: '9', **params)

        expect(tournament_day1 <=> tournament_day2).to eq(-1)
        expect(tournament_day1 <=> tournament_day3).to eq(1)
      end
    end

    context "when object's end_hour is different" do
      it 'returns end_hour comparison' do
        params = { date: '2023-01-11', start_hour: 5 }

        tournament_day1 = described_class.new(end_hour: '10', **params)
        tournament_day2 = described_class.new(end_hour: '11', **params)
        tournament_day3 = described_class.new(end_hour: '9', **params)

        expect(tournament_day1 <=> tournament_day2).to eq(-1)
        expect(tournament_day1 <=> tournament_day3).to eq(1)
      end
    end
  end
end
