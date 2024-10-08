# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Group do
  describe '.for' do
    it 'delegates params to builder' do
      category = :mixed_single
      matches = [[1, 34], [5, 33], [10, 29], [17, 25]]
      subscriptions = [
        { id: 1, name: 'João' },
        { id: 5,  name: 'Carlos' },
        { id: 10, name: 'Daniel' },
        { id: 17, name: 'Laura' },
        { id: 25, name: 'Joana' },
        { id: 29, name: 'Carolina' },
        { id: 33, name: 'Erica' },
        { id: 34, name: 'Cleber' }
      ]
      tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm

      allow(SportsManager::GroupBuilder)
        .to receive(:new)
        .and_call_original

      described_class.for(category: category, subscriptions: subscriptions, matches: matches,
                          tournament_type: tournament_type)

      expect(SportsManager::GroupBuilder)
        .to have_received(:new)
        .with(category: category, subscriptions: subscriptions, matches: matches, tournament_type: tournament_type)
    end
  end

  describe '#participants' do
    it 'returns a list of participants from all teams' do
      category = :mixed_single
      matches = []
      teams = [
        instance_double(SportsManager::Team, participants: [double(id: 1, name: 'João')]),
        instance_double(SportsManager::Team, participants: [double(id: 2, name: 'Maria')])
      ]

      group = described_class.new(category: category, matches: matches, teams: teams)

      expect(group.participants).to match_array [
        have_attributes(id: 1, name: 'João'),
        have_attributes(id: 2, name: 'Maria')
      ]
    end

    context 'when is a list of doubles' do
      it 'returns a list of participants from all teams' do
        category = :mixed_double
        matches = []
        teams = [
          instance_double(SportsManager::Team, participants: [
            double(id: 1, name: 'João'),
            double(id: 2, name: 'Maria')
          ]),
          instance_double(SportsManager::Team, participants: [
            double(id: 3, name: 'Carlos'),
            double(id: 4, name: 'Erica')
          ])
        ]

        group = described_class.new(category: category, matches: matches, teams: teams)

        expect(group.participants).to match_array [
          have_attributes(id: 1, name: 'João'),
          have_attributes(id: 2, name: 'Maria'),
          have_attributes(id: 3, name: 'Carlos'),
          have_attributes(id: 4, name: 'Erica')
        ]
      end
    end
  end

  describe '#all_matches' do
    it 'returns all matches' do
      category = :mixed_single
      match_class = SportsManager::Match
      participant_class = SportsManager::Participant

      participants = [
        SportsManager::Participant.new(id: 1, name: 'João'),
        SportsManager::Participant.new(id: 34, name: 'Cleber'),
        SportsManager::Participant.new(id: 5,  name: 'Carlos'),
        SportsManager::Participant.new(id: 33, name: 'Erica')
      ]

      teams = participants.map do |participant|
        SportsManager::SingleTeam.new(category: category, participants: [participant])
      end

      team1, team2, team3, team4 = teams

      matches = [
        SportsManager::Match.new(category: category, team1: team1, team2: team2, id: 1),
        SportsManager::Match.new(category: category, team1: team3, team2: team4, id: 2)
      ]

      group = described_class.new(category: category, matches: matches, teams: teams)

      expect(group.all_matches.size).to eq 2
      expect(group.all_matches).to match_array [
        have_attributes(
          class: match_class,
          category: category,
          id: 1,
          team1: team1,
          team2: team2,
          participants: [
            have_attributes(class: participant_class, id: 1, name: 'João'),
            have_attributes(class: participant_class, id: 34, name: 'Cleber')
          ]
        ),
        have_attributes(
          class: match_class,
          category: category,
          id: 2,
          team1: team3,
          team2: team4,
          participants: [
            have_attributes(class: participant_class, id: 5, name: 'Carlos'),
            have_attributes(class: participant_class, id: 33, name: 'Erica')
          ]
        )
      ]
    end

    context 'when is double' do
      it 'returns all matches' do
        category = :womens_double

        match_class = SportsManager::Match
        participant_class = SportsManager::Participant

        participants = [
          [
            SportsManager::Participant.new(id: 17, name: 'Laura'),
            SportsManager::Participant.new(id: 18, name: 'Karina')
          ],
          [
            SportsManager::Participant.new(id: 23, name: 'Maria'),
            SportsManager::Participant.new(id: 24, name: 'Elis')
          ],
          [
            SportsManager::Participant.new(id: 19, name: 'Camila'),
            SportsManager::Participant.new(id: 20, name: 'Bruna')
          ],
          [
            SportsManager::Participant.new(id: 21, name: 'Aline'),
            SportsManager::Participant.new(id: 22, name: 'Cintia')
          ]
        ]

        teams = participants.map do |team_participants|
          SportsManager::DoubleTeam.new(category: category, participants: team_participants)
        end

        matches = teams.each_slice(2).map.with_index(1) do |(team1, team2), id|
          SportsManager::Match.new(category: category, team1: team1, team2: team2, id: id)
        end

        group = described_class.new(category: :womens_double, matches: matches, teams: teams)

        expect(group.all_matches.size).to eq 2
        expect(group.all_matches).to match_array [
          have_attributes(
            class: match_class,
            category: category,
            id: 1,
            team1: have_attributes(
              participants: [
                have_attributes(class: participant_class, id: 17),
                have_attributes(class: participant_class, id: 18)
              ]
            ),
            team2: have_attributes(
              participants: [
                have_attributes(class: participant_class, id: 23),
                have_attributes(class: participant_class, id: 24)
              ]
            ),
            participants: [
              have_attributes(class: participant_class, id: 17),
              have_attributes(class: participant_class, id: 18),
              have_attributes(class: participant_class, id: 23),
              have_attributes(class: participant_class, id: 24)
            ]
          ),
          have_attributes(
            class: match_class,
            category: category,
            id: 2,
            team1: have_attributes(
              participants: [
                have_attributes(class: participant_class, id: 19),
                have_attributes(class: participant_class, id: 20)
              ]
            ),
            team2: have_attributes(
              participants: [
                have_attributes(class: participant_class, id: 21),
                have_attributes(class: participant_class, id: 22)
              ]
            ),
            participants: [
              have_attributes(class: participant_class, id: 19),
              have_attributes(class: participant_class, id: 20),
              have_attributes(class: participant_class, id: 21),
              have_attributes(class: participant_class, id: 22)
            ]
          )
        ]
      end
    end
  end

  describe '#matches' do
    it 'returns matches that are playable' do
      category = :mixed_single
      nil_team = SportsManager::NilTeam
      match_class = SportsManager::Match
      participant_class = SportsManager::Participant

      participants = [
        SportsManager::Participant.new(id: 1, name: 'João'),
        SportsManager::Participant.new(id: 34, name: 'Cleber'),
        SportsManager::Participant.new(id: 5,  name: 'Carlos'),
        SportsManager::Participant.new(id: 33, name: 'Erica')
      ]

      teams = participants.map do |participant|
        SportsManager::SingleTeam.new(category: category, participants: [participant])
      end

      team1, team2, team3, team4 = teams

      match1 = SportsManager::Match.new(category: category, team1: team1, team2: team2, id: 1)
      match2 = SportsManager::Match.new(category: category, team1: team3, team2: team4, id: 2)
      match3 = SportsManager::ByeMatch.new(category: category, team1: nil_team, team2: nil_team, id: 3)

      matches = [
        match1,
        match2,
        match3
      ]

      group = described_class.new(category: category, matches: matches, teams: teams)

      expect(group.matches.size).to eq 2
      expect(group.matches).to match_array [
        have_attributes(
          class: match_class,
          category: :mixed_single,
          id: 1,
          team1: team1,
          team2: team2,
          participants: [
            have_attributes(class: participant_class, id: 1, name: 'João'),
            have_attributes(class: participant_class, id: 34, name: 'Cleber')
          ]
        ),
        have_attributes(
          class: match_class,
          category: :mixed_single,
          id: 2,
          team1: team3,
          team2: team4,
          participants: [
            have_attributes(class: participant_class, id: 5, name: 'Carlos'),
            have_attributes(class: participant_class, id: 33, name: 'Erica')
          ]
        )
      ]
    end
  end

  describe '#first_round_matches' do
    it 'returns initial matches' do
      matches = [instance_double(SportsManager::Match, round: 0, playable?: true, depends_on: [])]

      group = described_class.new(category: spy, teams: spy, matches: matches)

      expect(group.first_round_matches).to eq matches
    end
  end

  describe '#find_matches' do
    context 'when round is zero' do
      it 'returns initial_matches' do
        matches = [instance_double(SportsManager::Match, round: 0, playable?: true, depends_on: [])]

        group = described_class.new(category: spy, teams: spy, matches: matches)

        expect(group.find_matches(0)).to eq matches
      end
    end

    it 'returns matches with corresponding round' do
      attributes = { depends_on: [], playable?: true }
      match_round1 = instance_double(SportsManager::Match, round: 0, **attributes)
      match_round2 = instance_double(SportsManager::Match, round: 1, **attributes)
      match_round3 = instance_double(SportsManager::Match, round: 2, **attributes)
      matches = [match_round1, match_round2, match_round3]

      group = described_class.new(category: spy, teams: spy, matches: matches)

      expect(group.find_matches(1)).to eq [match_round2]
      expect(group.find_matches(2)).to eq [match_round3]
      expect(group.find_matches(3)).to be_empty
    end
  end

  describe '#find_participant_matches' do
    it 'returns all matches where participant is a member' do
      category = :mixed_single
      participant1 = instance_double(SportsManager::Participant, id: 1, name: 'João')
      participant2 = instance_double(SportsManager::Participant, id: 2, name: 'Maria')

      attributes = { depends_on: [], playable?: true }

      match1 = instance_double(SportsManager::Match, **attributes, participants: [participant1])
      match2 = instance_double(SportsManager::Match, **attributes, participants: [participant2])
      match3 = instance_double(SportsManager::Match, **attributes, participants: [participant1, participant2])
      matches = [match1, match2, match3]

      group = described_class.new(category: category, matches: matches, teams: spy)

      participant_matches = group.find_participant_matches(participant1)

      expect(participant_matches).to eq [match1, match3]
    end

    context 'when participant is not in any match' do
      it 'returns an empty list' do
        category = :mixed_single
        participant1 = instance_double(SportsManager::Participant, id: 1, name: 'João')
        participant2 = instance_double(SportsManager::Participant, id: 2, name: 'Maria')

        matches = [
          instance_double(
            SportsManager::Match,
            depends_on: [],
            participants: [participant2],
            playable?: true
          )
        ]

        group = described_class.new(category: category, matches: matches, teams: spy)

        participant_matches = group.find_participant_matches(participant1)

        expect(participant_matches).to be_empty
      end
    end
  end
end
