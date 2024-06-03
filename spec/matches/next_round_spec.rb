# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Matches::NextRound do
  describe '#next_matches' do
    it 'returns all the remaining matches' do
      category = :mixed_single
      match1 = instance_double(SportsManager::Match, round: 0, depends_on: [])
      match2 = instance_double(SportsManager::Match, round: 0, depends_on: [])
      round_match = described_class.new(
        category: category,
        base_matches: [match1, match2]
      )

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
        base_matches: [match1, match2, match3, match4]
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

  describe '#total_matches' do
    it 'returns the total number of matches to be played' do
      category = :mixed_single
      round_match0 = described_class.new(category: category, base_matches: [])
      round_match1 = described_class.new(category: category, base_matches: [
        double, double
      ])
      round_match2 = described_class.new(category: category, base_matches: [
        double, double, double, double
      ])
      round_match3 = described_class.new(category: category, base_matches: [
        double, double, double, double,
        double, double, double, double
      ])

      expect(round_match0.total_matches).to eq 0
      expect(round_match1.total_matches).to eq 3
      expect(round_match2.total_matches).to eq 7
      expect(round_match3.total_matches).to eq 15
    end
  end

  describe '#total_rounds' do
    it 'returns the number of rounds necessary for competition' do
      category = :mixed_single
      round_match0 = described_class.new(category: category, base_matches: [])
      round_match1 = described_class.new(category: category, base_matches: [
        double, double
      ])
      round_match2 = described_class.new(category: category, base_matches: [
        double, double, double, double
      ])
      round_match3 = described_class.new(category: category, base_matches: [
        double, double, double, double,
        double, double, double, double
      ])

      expect(round_match0.total_rounds).to eq 0
      expect(round_match1.total_rounds).to eq 2
      expect(round_match2.total_rounds).to eq 3
      expect(round_match3.total_rounds).to eq 4
    end
  end

  describe '#round_for_match' do
    it 'returns the corresponding round for a match' do
      category = :mixed_single
      round_match = described_class.new(
        category: category,
        base_matches: [double, double, double, double]
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
        base_matches: [
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
