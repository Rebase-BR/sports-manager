# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Tournament do
  describe '#==' do
    context 'when tournaments have the same attributes' do
      it 'returns true' do
        settings = SportsManager::Tournament::Setting.new(
          courts: 1,
          match_time: 60,
          break_time: 10,
          single_day_matches: false,
          tournament_days: []
        )
        tournament = SportsManager::Tournament.new(settings: settings, groups: [])
        tournament2 = SportsManager::Tournament.new(settings: settings, groups: [])

        expect(tournament == tournament2).to eq true
      end

      it 'returns true' do
        category = :mixed_single

        settings = SportsManager::Tournament::Setting.new(
          courts: 1,
          match_time: 60,
          break_time: 10,
          single_day_matches: false,
          tournament_days: []
        )

        participants = [
          SportsManager::Participant.new(id: 1, name: 'João'),
          SportsManager::Participant.new(id: 34, name: 'Cleber'),
          SportsManager::Participant.new(id: 5,  name: 'Carlos'),
          SportsManager::Participant.new(id: 33, name: 'Erica')
        ]

        teams = participants.map do |participant|
          SportsManager::SingleTeam.new(
            category: category,
            participants: [participant]
          )
        end

        matches = teams.each_slice(2).map do |team1, team2|
          SportsManager::Match.new(category: category, team1: team1, team2: team2)
        end

        groups = [
          SportsManager::Group.new(category: category, teams: teams, matches: matches)
        ]

        tournament1 = SportsManager::Tournament.new(settings: settings, groups: groups)
        tournament2 = SportsManager::Tournament.new(settings: settings, groups: groups)

        expect(tournament1 == tournament2).to eq true
      end
    end

    context 'when tournament has different settings' do
      it 'returns false' do
        settings = SportsManager::Tournament::Setting.new(
          courts: 1,
          match_time: 60,
          break_time: 10,
          single_day_matches: false,
          tournament_days: [
            SportsManager::TournamentDay.new(
              date: '2023-01-01',
              start_hour: 10,
              end_hour: 20
            )
          ]
        )
        settings2 = SportsManager::Tournament::Setting.new(
          courts: 2,
          match_time: 90,
          break_time: 20,
          single_day_matches: true,
          tournament_days: [
            SportsManager::TournamentDay.new(
              date: '2023-01-02',
              start_hour: 10,
              end_hour: 20
            )
          ]
        )

        tournament = SportsManager::Tournament.new(settings: settings)
        tournament2 = SportsManager::Tournament.new(settings: settings2)

        expect(tournament == tournament2).to eq false
      end
    end

    context 'when tournament has different groups' do
      it 'returns false' do
        category = :mixed_single
        category2 = :solo

        settings = SportsManager::Tournament::Setting.new(
          courts: 1,
          match_time: 60,
          break_time: 10,
          single_day_matches: false,
          tournament_days: []
        )

        participants = [
          SportsManager::Participant.new(id: 1, name: 'João'),
          SportsManager::Participant.new(id: 34, name: 'Cleber'),
          SportsManager::Participant.new(id: 5,  name: 'Carlos'),
          SportsManager::Participant.new(id: 33, name: 'Erica')
        ]

        teams = participants.map do |participant|
          SportsManager::SingleTeam.new(
            category: category,
            participants: [participant]
          )
        end

        teams2 = participants.map do |participant|
          SportsManager::SingleTeam.new(
            category: category2,
            participants: [participant]
          )
        end

        matches = teams.each_slice(2).map do |team1, team2|
          SportsManager::Match.new(category: category, team1: team1, team2: team2)
        end

        matches2 = teams2.each_slice(2).map do |team1, team2|
          SportsManager::Match.new(category: category2, team1: team1, team2: team2)
        end

        groups = [
          SportsManager::Group.new(category: category, teams: teams, matches: matches)
        ]
        groups2 = [
          SportsManager::Group.new(
            category: category2,
            teams: teams2,
            matches: matches2
          )
        ]

        tournament1 = SportsManager::Tournament.new(settings: settings, groups: groups)
        tournament2 = SportsManager::Tournament.new(settings: settings, groups: groups2)

        expect(tournament1 == tournament2).to eq false
      end
    end
  end

  describe '#matches' do
    it 'returns all matches from each group' do
      matches_x = [instance_double(SportsManager::Match, depends_on: [])]
      matches_y = [instance_double(SportsManager::Match, depends_on: [])]
      groups = [
        instance_double(SportsManager::Group, category: :x, matches: matches_x, initial_matches: matches_x),
        instance_double(SportsManager::Group, category: :y, matches: matches_y, initial_matches: matches_y)
      ]

      tournament = described_class.new(settings: spy, groups: groups)

      expect(tournament.matches).to eq({ x: matches_x, y: matches_y })
    end
  end

  describe '#total_matches' do
    it 'returns total number of matches from all groups' do
      matches_x = [
        instance_double(SportsManager::Match, depends_on: []),
        instance_double(SportsManager::Match, depends_on: [])
      ]
      matches_y = [
        instance_double(SportsManager::Match, depends_on: []),
        instance_double(SportsManager::Match, depends_on: []),
        instance_double(SportsManager::Match, depends_on: [])
      ]
      groups = [
        instance_double(SportsManager::Group, category: :x, matches: matches_x, initial_matches: matches_x),
        instance_double(SportsManager::Group, category: :y, matches: matches_y, initial_matches: matches_y)
      ]

      tournament = described_class.new(settings: spy, groups: groups)

      expect(tournament.total_matches).to eq 5
    end
  end

  describe '#categories' do
    it 'returns all groups categories' do
      groups = [
        instance_double(SportsManager::Group, category: :x),
        instance_double(SportsManager::Group, category: :y)
      ]

      tournament = described_class.new(settings: spy, groups: groups)

      expect(tournament.categories).to eq %i[x y]
    end
  end

  describe '#find_matches' do
    it "returns category's round matches" do
      match = instance_double(SportsManager::Match)
      match2 = instance_double(SportsManager::Match)
      groups = [
        instance_double(SportsManager::Group, category: :x, find_matches: [match]),
        instance_double(SportsManager::Group, category: :y, find_matches: [match2])
      ]

      tournament = described_class.new(settings: spy, groups: groups)

      matches = tournament.find_matches(category: :x, round: 0)

      expect(matches).to eq [match]
    end

    it 'returns different matches based on round' do
      match = instance_double(SportsManager::Match)
      match2 = instance_double(SportsManager::Match)
      group1 = instance_double(SportsManager::Group, category: :x)

      allow(group1).to receive(:find_matches).with(0).and_return([match])
      allow(group1).to receive(:find_matches).with(1).and_return([match2])

      tournament = described_class.new(settings: spy, groups: [group1])

      round0_matches = tournament.find_matches(category: :x, round: 0)
      round1_matches = tournament.find_matches(category: :x, round: 1)

      expect(round0_matches).to eq [match]
      expect(round1_matches).to eq [match2]
    end

    context 'when no group is found' do
      it 'returns an empty list' do
        tournament = described_class.new(settings: spy, groups: [])

        matches = tournament.find_matches(category: :x, round: 0)

        expect(matches).to eq []
      end
    end
  end

  describe '#first_round_matches' do
    it "returns groups' first round matches" do
      match = instance_double(SportsManager::Match)
      match2 = instance_double(SportsManager::Match)
      match3 = instance_double(SportsManager::Match)
      group1 = instance_double(SportsManager::Group, category: :x)
      group2 = instance_double(SportsManager::Group, category: :y)

      allow(group1).to receive(:find_matches).with(0).and_return([match])
      allow(group1).to receive(:find_matches).with(1).and_return([match2])
      allow(group2).to receive(:find_matches).with(0).and_return([match3])

      tournament = described_class.new(settings: spy, groups: [group1, group2])

      matches = tournament.first_round_matches

      expect(matches).to eq({ x: [match], y: [match3] })
    end
  end

  describe '#participants' do
    it 'returns all unique participants' do
      participants_x = [
        instance_double(SportsManager::Participant, id: 1),
        instance_double(SportsManager::Participant, id: 2)
      ]
      participants_y = [
        instance_double(SportsManager::Participant, id: 3),
        instance_double(SportsManager::Participant, id: 4)
      ]
      groups = [
        instance_double(SportsManager::Group, category: :x, participants: participants_x),
        instance_double(SportsManager::Group, category: :y, participants: participants_y)
      ]

      tournament = described_class.new(settings: spy, groups: groups)

      expect(tournament.participants).to eq [
        *participants_x,
        *participants_y
      ]
    end
  end

  describe '#multi_tournament_participants' do
    it 'returns participants subscribed in more than one category' do
      duplicate1 = instance_double(SportsManager::Participant, id: 1)
      duplicate2 = instance_double(SportsManager::Participant, id: 4)
      participants_x = [duplicate1, instance_double(SportsManager::Participant, id: 2)]
      participants_y = [instance_double(SportsManager::Participant, id: 3), duplicate2]
      participants_z = [duplicate1, duplicate2]

      group_x = instance_double(SportsManager::Group, category: :x, participants: participants_x)
      group_y = instance_double(SportsManager::Group, category: :y, participants: participants_y)
      group_z = instance_double(SportsManager::Group, category: :z, participants: participants_z)
      groups = [group_x, group_y, group_z]

      tournament = described_class.new(settings: spy, groups: groups)

      expect(tournament.multi_tournament_participants).to eq [
        duplicate1,
        duplicate2
      ]
    end

    context 'when every participants is subscribed to only one category' do
      it 'returns an empty list' do
        participants_x = [
          instance_double(SportsManager::Participant, id: 1),
          instance_double(SportsManager::Participant, id: 2)
        ]
        participants_y = [
          instance_double(SportsManager::Participant, id: 3),
          instance_double(SportsManager::Participant, id: 4)
        ]
        groups = [
          instance_double(SportsManager::Group, category: :x, participants: participants_x),
          instance_double(SportsManager::Group, category: :y, participants: participants_y)
        ]

        tournament = described_class.new(settings: spy, groups: groups)

        expect(tournament.multi_tournament_participants).to eq []
      end
    end
  end

  describe '#find_participant_matches' do
    it 'returns all matches where participant is a member' do
      category = :mixed_single
      category2 = :mixed_single2

      participant1 = instance_double(SportsManager::Participant, id: 1, name: 'João')
      participant2 = instance_double(SportsManager::Participant, id: 2, name: 'Maria')

      attributes = { depends_on: [], playable?: true }

      match1 = instance_double(SportsManager::Match, **attributes, participants: [participant1])
      match2 = instance_double(SportsManager::Match, **attributes, participants: [participant2])
      match3 = instance_double(SportsManager::Match, **attributes, participants: [participant1, participant2])
      match4 = instance_double(SportsManager::Match, **attributes, participants: [participant2])
      match5 = instance_double(SportsManager::Match, **attributes, participants: [participant1])

      matches = [match1, match2, match3]
      matches2 = [match4, match5]

      group = SportsManager::Group.new(category: category, matches: matches, teams: spy)
      group2 = SportsManager::Group.new(category: category2, matches: matches2, teams: spy)

      tournament = described_class.new(settings: spy, groups: [group, group2])

      participant_matches = tournament.find_participant_matches(participant1)

      expect(participant_matches).to eq [match1, match3, match5]
    end

    context 'when participant is not in any match' do
      it 'returns an empty list' do
        category = :mixed_single

        participant1 = instance_double(SportsManager::Participant, id: 1, name: 'João')
        matches = [
          instance_double(
            SportsManager::Match,
            depends_on: [],
            participants: [spy],
            playable?: true
          )
        ]

        group = SportsManager::Group.new(category: category, matches: matches, teams: spy)

        tournament = described_class.new(settings: spy, groups: [group])

        participant_matches = tournament.find_participant_matches(participant1)

        expect(participant_matches).to be_empty
      end
    end
  end
end
