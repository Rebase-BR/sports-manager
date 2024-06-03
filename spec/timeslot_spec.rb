# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Timeslot do
  describe '#datetime' do
    it 'returns the date time parsed' do
      timeslot = described_class.new(court: 1, date: '2023-10-10', slot: 5)

      expect(timeslot.datetime).to eq DateTime.new(2023, 10, 10, 5, 0, 0)
    end

    context 'when slot is a time object' do
      it 'returns the slot' do
        date = instance_double(SportsManager::TournamentDay)
        slot = Time.new(2023, 9, 9, 9)

        timeslot = described_class.new(court: 0, date: date, slot: slot)

        expect(timeslot.datetime).to eq slot
      end
    end
  end

  describe '#==' do
    context 'when timeslots are in the same court and at the same time' do
      it 'returns true' do
        court = 1
        date = '2023-10-15'
        slot = 20
        timeslot = described_class.new(court: court, date: date, slot: slot)
        timeslot2 = described_class.new(court: court, date: date, slot: slot)

        expect(timeslot == timeslot2).to eq true
      end
    end

    context 'when timeslots are in the same court but at different times' do
      it 'returns false' do
        court = 1
        date = '2023-10-15'
        timeslot = described_class.new(court: court, date: date, slot: 20)
        timeslot2 = described_class.new(court: court, date: date, slot: 21)

        expect(timeslot == timeslot2).to eq false
      end
    end

    context 'when timeslots are in the same court, at same time, in different dates' do
      it 'returns false' do
        court = 1
        slot = 20
        timeslot = described_class.new(court: court, date: '2023-10-15', slot: slot)
        timeslot2 = described_class.new(court: court, date: '2023-10-16', slot: slot)

        expect(timeslot == timeslot2).to eq false
      end
    end

    context 'when timeslots are in different courts at same time' do
      it 'returns false' do
        date = '2023-10-15'
        slot = 20
        timeslot = described_class.new(court: 1, date: date, slot: slot)
        timeslot2 = described_class.new(court: 2, date: date, slot: slot)

        expect(timeslot == timeslot2).to eq false
      end
    end
  end

  describe '#<=>' do
    context 'when timeslot is at the same time' do
      it 'returns zero' do
        court = 1
        date = '2023-10-15'
        slot = 20
        timeslot = described_class.new(court: court, date: date, slot: slot)
        timeslot2 = described_class.new(court: court, date: date, slot: slot)

        expect(timeslot <=> timeslot2).to eq 0
      end
    end

    context 'when timeslot time is earlier than the other' do
      it 'returns -1' do
        court = 1
        date = '2023-10-15'
        timeslot = described_class.new(court: court, date: date, slot: 10)
        timeslot2 = described_class.new(court: court, date: date, slot: 20)

        expect(timeslot <=> timeslot2).to eq(-1)
      end
    end

    context 'when timeslot time is later than the other' do
      it 'returns 1' do
        court = 1
        date = '2023-10-15'
        timeslot = described_class.new(court: court, date: date, slot: 21)
        timeslot2 = described_class.new(court: court, date: date, slot: 20)

        expect(timeslot <=> timeslot2).to eq 1
      end
    end

    context 'when timeslot date is earlier than the other' do
      it 'returns -1' do
        court = 1
        slot = 10
        timeslot = described_class.new(court: court, date: '2023-10-15', slot: slot)
        timeslot2 = described_class.new(court: court, date: '2023-10-16', slot: slot)

        expect(timeslot <=> timeslot2).to eq(-1)
      end
    end

    context 'when timeslot date is later than the other' do
      it 'returns 1' do
        court = 1
        slot = 10
        timeslot = described_class.new(court: court, date: '2023-10-16', slot: slot)
        timeslot2 = described_class.new(court: court, date: '2023-10-15', slot: slot)

        expect(timeslot <=> timeslot2).to eq 1
      end
    end
  end
end
