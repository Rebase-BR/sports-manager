# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Match do
  describe '.build_next_match' do
    it 'returns a match representing a next round match' do
      category = :mixed_single
      id = 100
      round = 1
      depends_on = [double, double]

      match = described_class.build_next_match(
        id: id,
        category: category,
        depends_on: depends_on,
        round: round
      )

      expect(match).to have_attributes(
        class: described_class,
        category: category,
        depends_on: depends_on,
        round: round,
        id: id,
        team1: have_attributes(
          class: SportsManager::NilTeam,
          category: category
        ),
        team2: have_attributes(
          class: SportsManager::NilTeam,
          category: category
        )
      )
    end
  end

  describe '#==' do
    context 'when id, category, and round are the same' do
      it 'returns true' do
        params = {
          id: 1,
          category: :mixed_single,
          team1: spy,
          team2: spy,
          round: 1
        }

        match1 = described_class.new(**params)
        match2 = described_class.new(**params)

        expect(match1 == match2).to eq true
      end
    end

    context 'when id is different' do
      it 'returns false' do
        params = {
          id: 1,
          category: :mixed_single,
          team1: spy,
          team2: spy,
          round: 1
        }

        match1 = described_class.new(**params)
        match2 = described_class.new(**params, id: 2)

        expect(match1 == match2).to eq false
      end
    end

    context 'when category is different' do
      it 'returns false' do
        params = {
          id: 1,
          category: :mixed_single,
          team1: spy,
          team2: spy,
          round: 1
        }

        match1 = described_class.new(**params)
        match2 = described_class.new(**params, category: :mixed_double)

        expect(match1 == match2).to eq false
      end
    end

    context 'when round is different' do
      it 'returns false' do
        params = {
          id: 1,
          category: :mixed_single,
          team1: spy,
          team2: spy,
          round: 1
        }

        match1 = described_class.new(**params)
        match2 = described_class.new(**params, round: 3)

        expect(match1 == match2).to eq false
      end
    end
  end

  describe '#participants' do
    it "returns all team's participants" do
      participant1 = double(SportsManager::Participant)
      participant2 = double(SportsManager::Participant)
      participant3 = double(SportsManager::Participant)
      participant4 = double(SportsManager::Participant)

      team1 = double(participants: [participant1, participant2])
      team2 = double(participants: [participant3, participant4])

      match = described_class.new(category: :mixed_single, team1: team1, team2: team2)

      expect(match.participants).to eq [
        participant1,
        participant2,
        participant3,
        participant4
      ]
    end
  end

  describe '#dependencies' do
    it 'returns all match dependencies' do
      params = { id: spy, category: spy, team1: spy, team2: spy, round: spy }

      match1 = described_class.new(**params, depends_on: [])
      match2 = described_class.new(**params, depends_on: [])
      match3 = described_class.new(**params, depends_on: [])
      match4 = described_class.new(**params, depends_on: [])
      match5 = described_class.new(**params, depends_on: [match1, match2])
      match6 = described_class.new(**params, depends_on: [match3, match4])
      match7 = described_class.new(**params, depends_on: [match5, match6])

      expect(match1.dependencies).to eq []
      expect(match2.dependencies).to eq []
      expect(match3.dependencies).to eq []
      expect(match4.dependencies).to eq []
      expect(match5.dependencies).to eq [match1, match2]
      expect(match6.dependencies).to eq [match3, match4]
      expect(match7.dependencies).to eq [
        match1, match2, match3,
        match4, match5, match6
      ]
    end

    context 'when it has byes' do
      it 'returns all matches and byes dependencies' do
        params = { id: spy, category: spy, team1: spy, team2: spy, round: spy }

        match1 = described_class.new(**params, depends_on: [])
        match2 = SportsManager::ByeMatch.new(**params, depends_on: [])
        match3 = described_class.new(**params, depends_on: [])
        match4 = SportsManager::ByeMatch.new(**params, depends_on: [])
        match5 = described_class.new(**params, depends_on: [match1, match2])
        match6 = described_class.new(**params, depends_on: [match3, match4])
        match7 = described_class.new(**params, depends_on: [match5, match6])

        expect(match1.dependencies).to eq []
        expect(match3.dependencies).to eq []
        expect(match5.dependencies).to eq [match1, match2]
        expect(match6.dependencies).to eq [match3, match4]
        expect(match7.dependencies).to match_array [
          match1, match2, match3,
          match4, match5, match6
        ]
      end
    end
  end

  describe '#dependencies?' do
    context 'when match has dependencies' do
      it 'returns true' do
        match = described_class.new(
          category: :mixed_single,
          depends_on: [double]
        )
        expect(match).to be_dependencies
      end
    end

    context 'when match has no dependencies' do
      it 'returns false' do
        match = described_class.new(category: :mixed_single)
        expect(match).to_not be_dependencies
      end
    end
  end

  describe '#playable_dependencies' do
    it 'returns only dependent matches that are playable' do
      params = {
        id: spy,
        category: spy,
        team1: spy,
        team2: spy,
        round: spy
      }

      match1 = described_class.new(**params, depends_on: [])
      match2 = SportsManager::ByeMatch.new(**params, depends_on: [])
      match3 = described_class.new(**params, depends_on: [])
      match4 = SportsManager::ByeMatch.new(**params, depends_on: [])
      match5 = described_class.new(**params, depends_on: [match1, match2])
      match6 = described_class.new(**params, depends_on: [match3, match4])
      match7 = described_class.new(**params, depends_on: [match5, match6])

      expect(match1.playable_dependencies).to eq []
      expect(match2.playable_dependencies).to eq []
      expect(match3.playable_dependencies).to eq []
      expect(match4.playable_dependencies).to eq []
      expect(match5.playable_dependencies).to eq [match1]
      expect(match6.playable_dependencies).to eq [match3]
      expect(match7.playable_dependencies).to eq [match5, match6]
    end
  end

  describe '#previous_matches' do
    it 'returns all dependent matches that are playable' do
      params = {
        id: spy,
        category: spy,
        team1: spy,
        team2: spy,
        round: spy
      }

      match1 = described_class.new(**params, depends_on: [])
      match2 = SportsManager::ByeMatch.new(**params, depends_on: [])
      match3 = described_class.new(**params, depends_on: [])
      match4 = SportsManager::ByeMatch.new(**params, depends_on: [])
      match5 = described_class.new(**params, depends_on: [match1, match2])
      match6 = described_class.new(**params, depends_on: [match3, match4])
      match7 = described_class.new(**params, depends_on: [match5, match6])

      expect(match1.previous_matches).to eq []
      expect(match3.previous_matches).to eq []
      expect(match5.previous_matches).to eq [match1]
      expect(match6.previous_matches).to eq [match3]
      expect(match7.previous_matches).to match_array [
        match1, match3, match5, match6
      ]
    end
  end

  describe '#previous_matches?' do
    context 'when match has dependencies' do
      it 'returns true' do
        params = {
          id: spy,
          category: spy,
          team1: spy,
          team2: spy,
          round: spy
        }

        match1 = described_class.new(**params, depends_on: [])
        match2 = described_class.new(**params, depends_on: [match1])

        expect(match2).to be_previous_matches
      end
    end

    context 'when match has no dependencies' do
      it 'returns false' do
        params = {
          id: spy,
          category: spy,
          team1: spy,
          team2: spy,
          round: spy
        }

        match = described_class.new(**params, depends_on: [])

        expect(match).to_not be_previous_matches
      end
    end

    context 'when match has only bye dependencies' do
      it 'returns false' do
        params = {
          id: spy,
          category: spy,
          team1: spy,
          team2: spy,
          round: spy
        }

        bye1 = SportsManager::ByeMatch.new(**params, depends_on: [])
        match = described_class.new(**params, depends_on: [bye1])

        expect(match).to_not be_previous_matches
      end
    end
  end

  describe '#title' do
    it 'returns the players of each team' do
      team1 = instance_double(SportsManager::Team, name: 'João')
      team2 = instance_double(SportsManager::Team, name: 'Marcelo')

      match = described_class.new(
        category: spy,
        id: spy,
        round: spy,
        team1: team1,
        team2: team2
      )

      expect(match.title).to eq 'João vs. Marcelo'
    end

    context 'when it has previous matches' do
      it 'uses the matches ids' do
        attributes = {
          category: spy,
          id: spy,
          round: spy,
          team1: spy,
          team2: spy,
          depends_on: []
        }

        match1 = described_class.new(**attributes, id: 1)
        match2 = described_class.new(**attributes, id: 2)
        match = described_class.new(**attributes, depends_on: [match1, match2])

        expect(match.title).to eq 'M1 vs. M2'
      end
    end

    context 'when has byes in dependencies' do
      it 'uses the matches ids' do
        team1 = instance_double(SportsManager::Team, name: 'João')
        attributes = {
          category: spy,
          id: spy,
          round: spy,
          team1: spy,
          team2: spy,
          depends_on: []
        }

        match = described_class.new(**attributes, id: 1)
        bye_match = SportsManager::ByeMatch.new(**attributes, id: 2, team1: team1)

        next_match = described_class.new(
          **attributes,
          depends_on: [match, bye_match]
        )

        expect(next_match.title).to eq 'M1 vs. João'
      end
    end
  end
end
