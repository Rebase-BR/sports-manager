# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::MatchBuilder do
  describe '#build' do
    it 'returns a list of matches for a category' do
      category = :mixed_single
      matches_ids = [[1, 2]]
      participant1 = SportsManager::Participant.new(id: 1, name: 'João')
      participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
      team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
      team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
      teams = [team1, team2]

      matches = described_class.new(category: category, matches_ids: matches_ids, teams: teams).build

      expect(matches).to match_array(
        have_attributes(
          class: SportsManager::Match,
          id: 1,
          category: category,
          team1: team1,
          team2: team2
        )
      )
    end

    context 'when multiple matches ids' do
      it 'returns a list of matches' do
        category = :mixed_single
        matches_ids = [[1, 34], [2, 33]]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 33, name: 'Erica')
        participant4 = SportsManager::Participant.new(id: 34, name: 'Cleber')

        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
        team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
        team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)

        teams = [team1, team2, team3, team4]

        matches = described_class.new(category: category, matches_ids: matches_ids, teams: teams).build

        expect(matches).to match_array [
          have_attributes(
            class: SportsManager::Match,
            id: 1,
            category: category,
            team1: team1,
            team2: team4
          ),
          have_attributes(
            class: SportsManager::Match,
            id: 2,
            category: category,
            team1: team2,
            team2: team3
          )
        ]
      end
    end

    context 'when double matches ids' do
      it 'returns a list of matches' do
        category = :mixed_single
        matches_ids = [[[17, 18], [31, 32]]]
        participant1 = SportsManager::Participant.new(id: 17, name: 'Laura')
        participant2 = SportsManager::Participant.new(id: 18, name: 'Karina')
        participant3 = SportsManager::Participant.new(id: 31, name: 'Jéssica')
        participant4 = SportsManager::Participant.new(id: 32, name: 'Daniela')

        team1 = SportsManager::DoubleTeam.new(participants: [participant1, participant2], category: category)
        team2 = SportsManager::DoubleTeam.new(participants: [participant3, participant4], category: category)
        teams = [team1, team2]

        matches = described_class.new(category: category, matches_ids: matches_ids, teams: teams).build

        expect(matches).to match_array [
          have_attributes(
            class: SportsManager::Match,
            id: 1,
            category: category,
            team1: team1,
            team2: team2
          )
        ]
      end
    end

    context 'when number of teams is odd' do
      it 'sets extra matches with byes' do
        category = :mixed_single
        matches_ids = [[1, 2], [3]]

        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 3, name: 'José')

        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
        team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
        teams = [team1, team2, team3]

        matches = described_class.new(category: category, matches_ids: matches_ids, teams: teams).build

        expect(matches).to match_array [
          have_attributes(
            class: SportsManager::Match,
            id: 1,
            category: category,
            team1: team1,
            team2: team2
          ),
          have_attributes(
            class: SportsManager::ByeMatch,
            id: 2,
            category: category,
            team1: team3,
            team2: SportsManager::NilTeam.new(category: category)
          )
        ]
      end
    end

    context 'when number of teams is even but not power of 2' do
      it 'sets extra matches with byes' do
        category = :mixed_single
        matches_ids = [[1], [2, 3], [4, 5], [6]]

        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 3, name: 'José')
        participant4 = SportsManager::Participant.new(id: 4, name: 'Pedro')
        participant5 = SportsManager::Participant.new(id: 5, name: 'Carlos')
        participant6 = SportsManager::Participant.new(id: 6, name: 'Leandro')

        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
        team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
        team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)
        team5 = SportsManager::SingleTeam.new(participants: [participant5], category: category)
        team6 = SportsManager::SingleTeam.new(participants: [participant6], category: category)

        nil_team = SportsManager::NilTeam.new(category: category)

        teams = [team1, team2, team3, team4, team5, team6]

        matches = described_class.new(category: category, matches_ids: matches_ids, teams: teams).build

        expect(matches).to match_array [
          have_attributes(
            class: SportsManager::ByeMatch,
            id: 1,
            category: category,
            team1: team1,
            team2: nil_team
          ),
          have_attributes(
            class: SportsManager::Match,
            id: 2,
            category: category,
            team1: team2,
            team2: team3
          ),
          have_attributes(
            class: SportsManager::Match,
            id: 3,
            category: category,
            team1: team4,
            team2: team5
          ),
          have_attributes(
            class: SportsManager::ByeMatch,
            id: 4,
            category: category,
            team1: team6,
            team2: nil_team
          )
        ]
      end
    end
  end
end
