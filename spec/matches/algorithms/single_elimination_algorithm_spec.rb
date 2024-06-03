# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Matches::Algorithms::SingleEliminationAlgorithm do
  describe '#next_matches' do
    it 'returns all the remaining matches' do
      category = :mixed_single
      match1 = instance_double(SportsManager::Match, round: 0, depends_on: [])
      match2 = instance_double(SportsManager::Match, round: 0, depends_on: [])
      round_match = described_class.new(category: category, matches: [match1, match2])

      nil_team = SportsManager::NilTeam.new(category: category)
      match_class = SportsManager::Match

      expect(round_match.next_matches).to match_array [
        have_attributes(
          class: match_class,
          team1: nil_team,
          team2: nil_team,
          depends_on: [match1, match2]
        )
      ]
    end

    it 'returns all the remaining matches with incremental round' do
      category = :mixed_single
      match1 = instance_double(SportsManager::Match, round: 0, depends_on: [])
      match2 = instance_double(SportsManager::Match, round: 0, depends_on: [])
      match3 = instance_double(SportsManager::Match, round: 0, depends_on: [])
      match4 = instance_double(SportsManager::Match, round: 0, depends_on: [])

      round_match = described_class.new(
        category: category,
        matches: [match1, match2, match3, match4]
      )

      nil_team = SportsManager::NilTeam.new(category: category)
      match_class = SportsManager::Match

      expect(round_match.next_matches).to match_array [
        have_attributes(
          class: match_class,
          round: 1,
          team1: nil_team,
          team2: nil_team,
          depends_on: [match1, match2]
        ),
        have_attributes(
          class: match_class,
          round: 1,
          team1: nil_team,
          team2: nil_team,
          depends_on: [match3, match4]
        ),
        have_attributes(
          class: match_class,
          round: 2,
          team1: nil_team,
          team2: nil_team,
          depends_on: [
            have_attributes(
              class: match_class,
              round: 1,
              team1: nil_team,
              team2: nil_team,
              depends_on: [match1, match2]
            ),
            have_attributes(
              class: match_class,
              round: 1,
              team1: nil_team,
              team2: nil_team,
              depends_on: [match3, match4]
            )
          ]
        )
      ]
    end
  end

  describe '#needs_bye?' do
    context 'when number is a power of two' do
      it 'returns false' do
        category = :mixed_single
        power_of_two = [1, 2, 4, 8, 16, 32, 64, 128]

        power_of_two.each do |count|
          matches = [double] * count

          algorithm = described_class.new(category: category, matches: matches)

          expect(algorithm.needs_bye?).to eq false
        end
      end
    end

    context 'when number is not a power of two' do
      it 'returns true' do
        category = :mixed_single
        power_of_two = [1, 2, 4, 8, 16, 32, 64, 128]
        numbers = (1..200).to_a - power_of_two

        numbers.each do |count|
          matches = [double] * count

          algorithm = described_class.new(category: category, matches: matches)

          expect(algorithm.needs_bye?).to eq true
        end
      end
    end
  end

  describe '#total_matches' do
    it 'returns the number of total matches to be played (N-1 players)' do
      category = :mixed_single

      (2..32).each do |number_of_opening_matches|
        matches = [double] * number_of_opening_matches
        number_of_matches = (number_of_opening_matches * 2) - 1

        algorithm = described_class.new(category: category, matches: matches)

        expect(algorithm.total_matches).to eq(number_of_matches)
      end
    end

    context 'when matches size is one' do
      it 'returns one' do
        category = :mixed_single
        matches = [double]

        algorithm = described_class.new(category: category, matches: matches)

        expect(algorithm.total_matches).to eq 1
      end
    end

    context 'when matches size is zero' do
      it 'returns zero' do
        category = :mixed_single
        matches = []

        algorithm = described_class.new(category: category, matches: matches)

        expect(algorithm.total_matches).to be_zero
      end
    end
  end

  describe '#total_rounds' do
    it 'returns the number of rounds necessary for competition' do
      category = :mixed_single
      matches_ranges = {
        (1..1) => 1,
        (2..2) => 2,
        (3..4) => 3,
        (5..8) => 4,
        (9..16) => 5,
        (17..32) => 6,
        (33..64) => 7
      }

      matches_ranges.each do |(range, rounds)|
        range.each do |size|
          matches = [double] * size

          algorithm = described_class.new(category: category, matches: matches)

          expect(algorithm.total_rounds).to eq rounds
        end
      end
    end

    context 'when matches size is zero' do
      it 'returns zero' do
        category = :mixed_single
        matches = []

        algorithm = described_class.new(category: category, matches: matches)

        expect(algorithm.total_rounds).to be_zero
      end
    end
  end

  describe '#round_for_match' do
    it 'returns the corresponding round for a match' do
      category = :mixed_single
      round_match = described_class.new(
        category: category,
        matches: [double, double, double, double]
      )

      expect(round_match.round_for_match(1)).to eq 1
      expect(round_match.round_for_match(2)).to eq 1
      expect(round_match.round_for_match(3)).to eq 1
      expect(round_match.round_for_match(4)).to eq 1
      expect(round_match.round_for_match(5)).to eq 2
      expect(round_match.round_for_match(6)).to eq 2
      expect(round_match.round_for_match(7)).to eq 3
    end

    it 'returns the corresponding round for a match' do
      category = :mixed_single
      round_match = described_class.new(
        category: category,
        matches: [
          double, double, double, double,
          double, double, double, double
        ]
      )

      expect(round_match.round_for_match(1)).to eq 1
      expect(round_match.round_for_match(2)).to eq 1
      expect(round_match.round_for_match(3)).to eq 1
      expect(round_match.round_for_match(4)).to eq 1
      expect(round_match.round_for_match(5)).to eq 1
      expect(round_match.round_for_match(6)).to eq 1
      expect(round_match.round_for_match(7)).to eq 1
      expect(round_match.round_for_match(8)).to eq 1
      expect(round_match.round_for_match(9)).to eq 2
      expect(round_match.round_for_match(10)).to eq 2
      expect(round_match.round_for_match(11)).to eq 2
      expect(round_match.round_for_match(12)).to eq 2
      expect(round_match.round_for_match(13)).to eq 3
      expect(round_match.round_for_match(14)).to eq 3
      expect(round_match.round_for_match(15)).to eq 4
    end
  end
end
