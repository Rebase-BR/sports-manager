# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::TournamentDay::Validator do
  describe '#valid?' do
    it 'returns true' do
      tournament_day = instance_double(
        SportsManager::TournamentDay,
        start_hour: 0,
        end_hour: 23,
        date: '2023-01-01'
      )
      validator = described_class.new(tournament_day)

      expect(validator.valid?).to eq true
    end

    context 'when start is under 0' do
      it 'returns false' do
        tournament_day = instance_double(
          SportsManager::TournamentDay,
          start_hour: -1,
          end_hour: 23,
          date: '2023-01-01'
        )
        validator = described_class.new(tournament_day)

        expect(validator.valid?).to eq false
      end
    end

    context 'when end hour is under 0' do
      it 'returns false' do
        tournament_day = instance_double(
          SportsManager::TournamentDay,
          start_hour: 15,
          end_hour: -1,
          date: '2023-01-01'
        )

        validator = described_class.new(tournament_day)

        expect(validator.valid?).to eq false
      end
    end

    context 'when it is not possible to parse date' do
      it 'returns false' do
        tournament_day = instance_double(
          SportsManager::TournamentDay,
          start_hour: 0,
          end_hour: 23,
          date: '2023-15-15'
        )

        validator = described_class.new(tournament_day)

        expect(validator.valid?).to eq false
      end
    end
  end

  describe '#validate!' do
    it 'returns true' do
      tournament_day = instance_double(
        SportsManager::TournamentDay,
        start_hour: 0,
        end_hour: 23,
        date: '2023-01-01'
      )

      validator = described_class.new(tournament_day)

      expect(validator.validate!).to eq true
    end

    context 'when cannot parse date' do
      it 'raises an error' do
        tournament_day = instance_double(
          SportsManager::TournamentDay,
          start_hour: 20,
          end_hour: 23,
          date: '2023-15-15'
        )

        validator = described_class.new(tournament_day)

        expect { validator.validate! }.to raise_error(
          described_class::DateParsingError,
          'It is not possible to parse Date: 2023-15-15'
        )
      end
    end

    context 'when date has wrong format' do
      it 'raises an error' do
        tournament_day = instance_double(
          SportsManager::TournamentDay,
          start_hour: 20,
          end_hour: 23,
          date: '2023/10/10'
        )

        validator = described_class.new(tournament_day)

        expect { validator.validate! }.to raise_error(
          described_class::DateParsingError,
          'It is not possible to parse Date: 2023/10/10'
        )
      end
    end

    context "when hours are not in a day's range" do
      it 'raises an error' do
        tournament_day = instance_double(
          SportsManager::TournamentDay,
          start_hour: -1,
          end_hour: 23,
          date: '2023-01-01'
        )

        validator = described_class.new(tournament_day)

        expect { validator.validate! }.to raise_error(
          described_class::InvalidHour,
          'start_hour and end_hour must be between 0 and 23. ' \
          'start_hour: -1, end_hour: 23'
        )
      end
    end
  end
end
