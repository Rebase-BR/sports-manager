# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::MatchBuilder do
  describe '#build' do
    context 'when matches has a generated matches structure' do
      it 'match id should be the same as the one in the matches structure' do
        category = :mixed_single
        matches = [
          { id: 23, participants: [1, 2] },
          { id: 1024, participants: [3, 4] }
        ]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 3, name: 'José')
        participant4 = SportsManager::Participant.new(id: 4, name: 'Pedro')

        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
        team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
        team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)

        teams = [team1, team2, team3, team4]
        tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
        subscriptions = [
          { id: 1, name: 'João' },
          { id: 2, name: 'Marcelo' },
          { id: 3, name: 'José' },
          { id: 4, name: 'Pedro' }
        ]

        matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                             tournament_type: tournament_type, subscriptions: subscriptions).build

        expect(matches_result.first.id).to eq 23
        expect(matches_result.last.id).to eq 1024
      end

      it 'round should be the same as the one in the matches structure' do
        category = :mixed_single
        matches = [
          { id: 23, participants: [1, 2], round: 1 },
          { id: 1024, participants: [3, 4], round: 2 }
        ]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 3, name: 'José')
        participant4 = SportsManager::Participant.new(id: 4, name: 'Pedro')

        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
        team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
        team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)

        teams = [team1, team2, team3, team4]
        tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
        subscriptions = [
          { id: 1, name: 'João' },
          { id: 2, name: 'Marcelo' },
          { id: 3, name: 'José' },
          { id: 4, name: 'Pedro' }
        ]

        matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                             tournament_type: tournament_type, subscriptions: subscriptions).build

        expect(matches_result.first.round).to eq 1
        expect(matches_result.last.round).to eq 2
      end

      it 'depends_on should be the same as the one in the matches structure' do
        category = :mixed_single
        matches = [
          { id: 1, participants: [1, 2] },
          { id: 2, participants: [3, 4] },
          { id: 23, participants: [], depends_on: [1, 2] },
          { id: 1024, participants: [], depends_on: [23] }
        ]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 3, name: 'José')
        participant4 = SportsManager::Participant.new(id: 4, name: 'Pedro')

        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
        team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
        team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)

        teams = [team1, team2, team3, team4]
        tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
        subscriptions = [
          { id: 1, name: 'João' },
          { id: 2, name: 'Marcelo' },
          { id: 3, name: 'José' },
          { id: 4, name: 'Pedro' }
        ]

        matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                             tournament_type: tournament_type, subscriptions: subscriptions).build

        expect(matches_result[2].depends_on).to match_array [matches_result[0], matches_result[1]]
        expect(matches_result[3].depends_on).to match_array [matches_result[2]]
      end

      context 'when multiple matches ids' do
        it 'returns a list of matches' do
          category = :mixed_single
          matches = [
            { id: 1, participants: [1, 34] },
            { id: 2, participants: [2, 33] },
            { id: 3, participants: [35, 36] },
            { id: 4, participants: [37, 38] },
            { id: 5, participants: [], depends_on: [1, 2], round: 1 },
            { id: 6, participants: [], depends_on: [3, 4], round: 1 },
            { id: 7, participants: [], depends_on: [5, 6], round: 2 }
          ]
          participant1 = SportsManager::Participant.new(id: 1, name: 'João')
          participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
          participant3 = SportsManager::Participant.new(id: 33, name: 'Erica')
          participant4 = SportsManager::Participant.new(id: 34, name: 'Cleber')
          participant5 = SportsManager::Participant.new(id: 35, name: 'Jéssica')
          participant6 = SportsManager::Participant.new(id: 36, name: 'Daniela')
          participant7 = SportsManager::Participant.new(id: 37, name: 'Reyna')
          participant8 = SportsManager::Participant.new(id: 38, name: 'Larissa')

          team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
          team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
          team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
          team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)
          team5 = SportsManager::SingleTeam.new(participants: [participant5], category: category)
          team6 = SportsManager::SingleTeam.new(participants: [participant6], category: category)
          team7 = SportsManager::SingleTeam.new(participants: [participant7], category: category)
          team8 = SportsManager::SingleTeam.new(participants: [participant8], category: category)

          teams = [team1, team2, team3, team4, team5, team6, team7, team8]
          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            { id: 1, name: 'João' },
            { id: 2, name: 'Marcelo' },
            { id: 33, name: 'Erica' },
            { id: 34, name: 'Cleber' },
            { id: 35, name: 'Jéssica' },
            { id: 36, name: 'Daniela' },
            { id: 37, name: 'Reyna' },
            { id: 38, name: 'Larissa' }
          ]
          nil_team = SportsManager::NilTeam.new(category: category)

          matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                               tournament_type: tournament_type, subscriptions: subscriptions).build

          expect(matches_result).to match_array [
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
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 3,
              category: category,
              team1: team5,
              team2: team6
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 4,
              category: category,
              team1: team7,
              team2: team8
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 5,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[0], matches_result[1]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 6,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[2], matches_result[3]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 7,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 2,
              depends_on: [matches_result[4], matches_result[5]]
            )
          ]
        end
      end

      context 'when double matches ids' do
        it 'returns a list of matches' do
          category = :mixed_single
          matches = [
            { id: 1, participants: [[17, 18], [19, 20]] },
            { id: 2, participants: [[31, 32], [33, 34]] },
            { id: 3, participants: [[35, 36], [37, 38]] },
            { id: 4, participants: [[39, 40], [41, 42]] },
            { id: 5, participants: [], depends_on: [1, 2], round: 1 },
            { id: 6, participants: [], depends_on: [3, 4], round: 1 },
            { id: 7, participants: [], depends_on: [5, 6], round: 2 }
          ]
          participant1 = SportsManager::Participant.new(id: 17, name: 'Laura')
          participant2 = SportsManager::Participant.new(id: 18, name: 'Karina')
          participant3 = SportsManager::Participant.new(id: 19, name: 'Manoela')
          participant4 = SportsManager::Participant.new(id: 20, name: 'Alessandra')
          participant5 = SportsManager::Participant.new(id: 31, name: 'Reyna')
          participant6 = SportsManager::Participant.new(id: 32, name: 'Larissa')
          participant7 = SportsManager::Participant.new(id: 33, name: 'Jéssica')
          participant8 = SportsManager::Participant.new(id: 34, name: 'Daniela')
          participant9 = SportsManager::Participant.new(id: 35, name: 'Amanda')
          participant10 = SportsManager::Participant.new(id: 36, name: 'Roxele')
          participant11 = SportsManager::Participant.new(id: 37, name: 'Rozangela')
          participant12 = SportsManager::Participant.new(id: 38, name: 'Rozilda')
          participant13 = SportsManager::Participant.new(id: 39, name: 'Rozilene')
          participant14 = SportsManager::Participant.new(id: 40, name: 'Rozimeire')
          participant15 = SportsManager::Participant.new(id: 41, name: 'Elisangela')
          participant16 = SportsManager::Participant.new(id: 42, name: 'Elisabete')

          team1 = SportsManager::DoubleTeam.new(participants: [participant1, participant2], category: category)
          team2 = SportsManager::DoubleTeam.new(participants: [participant3, participant4], category: category)
          team3 = SportsManager::DoubleTeam.new(participants: [participant5, participant6], category: category)
          team4 = SportsManager::DoubleTeam.new(participants: [participant7, participant8], category: category)
          team5 = SportsManager::DoubleTeam.new(participants: [participant9, participant10], category: category)
          team6 = SportsManager::DoubleTeam.new(participants: [participant11, participant12], category: category)
          team7 = SportsManager::DoubleTeam.new(participants: [participant13, participant14], category: category)
          team8 = SportsManager::DoubleTeam.new(participants: [participant15, participant16], category: category)

          teams = [team1, team2, team3, team4, team5, team6, team7, team8]
          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            [{ id: 17, name: 'Laura' }, { id: 18, name: 'Karina' }],
            [{ id: 19, name: 'Manoela' }, { id: 20, name: 'Alessandra' }],
            [{ id: 31, name: 'Reyna' }, { id: 32, name: 'Larissa' }],
            [{ id: 33, name: 'Jéssica' }, { id: 34, name: 'Daniela' }],
            [{ id: 35, name: 'Amanda' }, { id: 36, name: 'Roxele' }],
            [{ id: 37, name: 'Rozangela' }, { id: 38, name: 'Rozilda' }],
            [{ id: 39, name: 'Rozilene' }, { id: 40, name: 'Rozimeire' }],
            [{ id: 41, name: 'Elisangela' }, { id: 42, name: 'Elisabete' }]
          ]
          nil_team = SportsManager::NilTeam.new(category: category)

          matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                               tournament_type: tournament_type, subscriptions: subscriptions).build

          expect(matches_result).to match_array [
            have_attributes(
              class: SportsManager::Match,
              id: 1,
              category: category,
              team1: team1,
              team2: team2
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 2,
              category: category,
              team1: team3,
              team2: team4
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 3,
              category: category,
              team1: team5,
              team2: team6
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 4,
              category: category,
              team1: team7,
              team2: team8
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 5,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[0], matches_result[1]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 6,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[2], matches_result[3]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 7,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 2,
              depends_on: [matches_result[4], matches_result[5]]
            )
          ]
        end
      end

      context 'when number of teams is odd' do
        it 'sets extra matches with byes' do
          category = :mixed_single
          matches = [
            { id: 1, participants: [1, 2] },
            { id: 2, participants: [3] },
            { id: 3, participants: [], depends_on: [1, 2] }
          ]

          participant1 = SportsManager::Participant.new(id: 1, name: 'João')
          participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
          participant3 = SportsManager::Participant.new(id: 3, name: 'José')

          team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
          team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
          team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
          teams = [team1, team2, team3]
          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            { id: 1, name: 'João' },
            { id: 2, name: 'Marcelo' },
            { id: 3, name: 'José' }
          ]
          nil_team = SportsManager::NilTeam.new(category: category)
          matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                               tournament_type: tournament_type, subscriptions: subscriptions).build

          expect(matches_result).to match_array [
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
              team2: nil_team
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 3,
              category: category,
              team1: nil_team,
              team2: nil_team,
              depends_on: [matches_result[0], matches_result[1]]
            )
          ]
        end
      end

      context 'when number of teams is even but not power of 2' do
        it 'sets extra matches with byes' do
          category = :mixed_single
          matches = [
            { id: 1, participants: [1] },
            { id: 2, participants: [2, 3] },
            { id: 3, participants: [4, 5] },
            { id: 4, participants: [6] },
            { id: 5, participants: [], depends_on: [1, 2], round: 1 },
            { id: 6, participants: [], depends_on: [3, 4], round: 1 },
            { id: 7, participants: [], depends_on: [5, 6], round: 2 }
          ]

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
          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            { id: 1, name: 'João' },
            { id: 2, name: 'Marcelo' },
            { id: 3, name: 'José' },
            { id: 4, name: 'Pedro' },
            { id: 5, name: 'Carlos' },
            { id: 6, name: 'Leandro' }
          ]

          matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                               tournament_type: tournament_type, subscriptions: subscriptions).build

          expect(matches_result).to match_array [
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
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 5,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[0], matches_result[1]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 6,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[2], matches_result[3]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 7,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 2,
              depends_on: [matches_result[4], matches_result[5]]
            )
          ]
        end
      end
    end

    context 'when matches has not a generated matches structure' do
      it 'returns a list of matches for a category' do
        category = :mixed_single
        matches = [[1, 2]]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
        teams = [team1, team2]
        tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
        subscriptions = [
          { id: 1, name: 'João' },
          { id: 2, name: 'Marcelo' }
        ]

        matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                             tournament_type: tournament_type, subscriptions: subscriptions).build

        expect(matches_result).to match_array(
          have_attributes(
            class: SportsManager::Match,
            id: 1,
            category: category,
            team1: team1,
            team2: team2
          )
        )
      end

      context 'when matches are not passed' do
        context 'single' do
          it 'generate matches and returns a list of matches for a category' do
            category = :mixed_single
            matches = []
            participant1 = SportsManager::Participant.new(id: 1, name: 'João')
            participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
            participant3 = SportsManager::Participant.new(id: 3, name: 'José')
            participant4 = SportsManager::Participant.new(id: 4, name: 'Pedro')
            team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
            team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
            team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
            team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)
            teams = [team1, team2, team3, team4]
            tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
            subscriptions = [
              { id: 1, name: 'João' },
              { id: 2, name: 'Marcelo' },
              { id: 3, name: 'José' },
              { id: 4, name: 'Pedro' }
            ]
            nil_team = SportsManager::NilTeam.new(category: category)

            matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                                 tournament_type: tournament_type, subscriptions: subscriptions).build

            expect(matches_result).to match_array [
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
              ),
              have_attributes(
                class: SportsManager::Match,
                id: 3,
                category: category,
                team1: nil_team,
                team2: nil_team,
                round: 1,
                depends_on: [matches_result[0], matches_result[1]]
              )
            ]
          end
        end

        context 'double' do
          it 'generate matches and returns a list of matches for a category' do
            category = :mixed_double
            matches = []
            participant1 = SportsManager::Participant.new(id: 1, name: 'João')
            participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
            participant3 = SportsManager::Participant.new(id: 3, name: 'José')
            participant4 = SportsManager::Participant.new(id: 4, name: 'Pedro')
            participant5 = SportsManager::Participant.new(id: 5, name: 'Carlos')
            participant6 = SportsManager::Participant.new(id: 6, name: 'Leandro')
            participant7 = SportsManager::Participant.new(id: 7, name: 'Ricardo')
            participant8 = SportsManager::Participant.new(id: 8, name: 'Rafael')
            team1 = SportsManager::DoubleTeam.new(participants: [participant1, participant2], category: category)
            team2 = SportsManager::DoubleTeam.new(participants: [participant3, participant4], category: category)
            team3 = SportsManager::DoubleTeam.new(participants: [participant5, participant6], category: category)
            team4 = SportsManager::DoubleTeam.new(participants: [participant7, participant8], category: category)
            teams = [team1, team2, team3, team4]
            tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
            subscriptions = [
              [{ id: 1, name: 'João' }, { id: 2, name: 'Marcelo' }],
              [{ id: 3, name: 'José' }, { id: 4, name: 'Pedro' }],
              [{ id: 5, name: 'Carlos' }, { id: 6, name: 'Leandro' }],
              [{ id: 7, name: 'Ricardo' }, { id: 8, name: 'Rafael' }]
            ]
            nil_team = SportsManager::NilTeam.new(category: category)

            matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                                 tournament_type: tournament_type, subscriptions: subscriptions).build

            expect(matches_result).to match_array [
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
              ),
              have_attributes(
                class: SportsManager::Match,
                id: 3,
                category: category,
                team1: nil_team,
                team2: nil_team,
                round: 1,
                depends_on: [matches_result[0], matches_result[1]]
              )
            ]
          end
        end
      end

      context 'when multiple matches ids' do
        it 'returns a list of matches' do
          category = :mixed_single
          matches = [[1, 34], [2, 33], [35, 36], [37, 38]]
          participant1 = SportsManager::Participant.new(id: 1, name: 'João')
          participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
          participant3 = SportsManager::Participant.new(id: 33, name: 'Erica')
          participant4 = SportsManager::Participant.new(id: 34, name: 'Cleber')
          participant5 = SportsManager::Participant.new(id: 35, name: 'Jéssica')
          participant6 = SportsManager::Participant.new(id: 36, name: 'Daniela')
          participant7 = SportsManager::Participant.new(id: 37, name: 'Reyna')
          participant8 = SportsManager::Participant.new(id: 38, name: 'Larissa')

          team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
          team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
          team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
          team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)
          team5 = SportsManager::SingleTeam.new(participants: [participant5], category: category)
          team6 = SportsManager::SingleTeam.new(participants: [participant6], category: category)
          team7 = SportsManager::SingleTeam.new(participants: [participant7], category: category)
          team8 = SportsManager::SingleTeam.new(participants: [participant8], category: category)

          nil_team = SportsManager::NilTeam.new(category: category)
          teams = [team1, team2, team3, team4, team5, team6, team7, team8]
          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            { id: 1, name: 'João' },
            { id: 2, name: 'Marcelo' },
            { id: 33, name: 'Erica' },
            { id: 34, name: 'Cleber' },
            { id: 35, name: 'Jéssica' },
            { id: 36, name: 'Daniela' },
            { id: 37, name: 'Reyna' },
            { id: 38, name: 'Larissa' }
          ]

          matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                               tournament_type: tournament_type, subscriptions: subscriptions).build

          expect(matches_result).to match_array [
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
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 3,
              category: category,
              team1: team5,
              team2: team6
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 4,
              category: category,
              team1: team7,
              team2: team8
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 5,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[0], matches_result[1]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 6,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[2], matches_result[3]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 7,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 2,
              depends_on: [matches_result[4], matches_result[5]]
            )
          ]
        end
      end

      context 'when double matches ids' do
        it 'returns a list of matches' do
          category = :mixed_single
          matches =
            [[[17, 18], [19, 20]],
             [[31, 32], [33, 34]],
             [[35, 36], [37, 38]],
             [[39, 40], [41, 42]]]
          participant1 = SportsManager::Participant.new(id: 17, name: 'Laura')
          participant2 = SportsManager::Participant.new(id: 18, name: 'Karina')
          participant3 = SportsManager::Participant.new(id: 19, name: 'Manoela')
          participant4 = SportsManager::Participant.new(id: 20, name: 'Alessandra')
          participant5 = SportsManager::Participant.new(id: 31, name: 'Reyna')
          participant6 = SportsManager::Participant.new(id: 32, name: 'Larissa')
          participant7 = SportsManager::Participant.new(id: 33, name: 'Jéssica')
          participant8 = SportsManager::Participant.new(id: 34, name: 'Daniela')
          participant9 = SportsManager::Participant.new(id: 35, name: 'Amanda')
          participant10 = SportsManager::Participant.new(id: 36, name: 'Roxele')
          participant11 = SportsManager::Participant.new(id: 37, name: 'Rozangela')
          participant12 = SportsManager::Participant.new(id: 38, name: 'Rozilda')
          participant13 = SportsManager::Participant.new(id: 39, name: 'Rozilene')
          participant14 = SportsManager::Participant.new(id: 40, name: 'Rozimeire')
          participant15 = SportsManager::Participant.new(id: 41, name: 'Elisangela')
          participant16 = SportsManager::Participant.new(id: 42, name: 'Elisabete')

          team1 = SportsManager::DoubleTeam.new(participants: [participant1, participant2], category: category)
          team2 = SportsManager::DoubleTeam.new(participants: [participant3, participant4], category: category)
          team3 = SportsManager::DoubleTeam.new(participants: [participant5, participant6], category: category)
          team4 = SportsManager::DoubleTeam.new(participants: [participant7, participant8], category: category)
          team5 = SportsManager::DoubleTeam.new(participants: [participant9, participant10], category: category)
          team6 = SportsManager::DoubleTeam.new(participants: [participant11, participant12], category: category)
          team7 = SportsManager::DoubleTeam.new(participants: [participant13, participant14], category: category)
          team8 = SportsManager::DoubleTeam.new(participants: [participant15, participant16], category: category)

          teams = [team1, team2, team3, team4, team5, team6, team7, team8]
          nil_team = SportsManager::NilTeam.new(category: category)

          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            [{ id: 17, name: 'Laura' }, { id: 18, name: 'Karina' }],
            [{ id: 19, name: 'Manoela' }, { id: 20, name: 'Alessandra' }],
            [{ id: 31, name: 'Reyna' }, { id: 32, name: 'Larissa' }],
            [{ id: 33, name: 'Jéssica' }, { id: 34, name: 'Daniela' }],
            [{ id: 35, name: 'Amanda' }, { id: 36, name: 'Roxele' }],
            [{ id: 37, name: 'Rozangela' }, { id: 38, name: 'Rozilda' }],
            [{ id: 39, name: 'Rozilene' }, { id: 40, name: 'Rozimeire' }],
            [{ id: 41, name: 'Elisangela' }, { id: 42, name: 'Elisabete' }]
          ]

          matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                               tournament_type: tournament_type, subscriptions: subscriptions).build

          expect(matches_result).to match_array [
            have_attributes(
              class: SportsManager::Match,
              id: 1,
              category: category,
              team1: team1,
              team2: team2
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 2,
              category: category,
              team1: team3,
              team2: team4
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 3,
              category: category,
              team1: team5,
              team2: team6
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 4,
              category: category,
              team1: team7,
              team2: team8
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 5,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[0], matches_result[1]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 6,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[2], matches_result[3]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 7,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 2,
              depends_on: [matches_result[4], matches_result[5]]
            )
          ]
        end
      end

      context 'when number of teams is odd' do
        it 'sets extra matches with byes' do
          category = :mixed_single
          matches = [[1, 2], [3]]

          participant1 = SportsManager::Participant.new(id: 1, name: 'João')
          participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
          participant3 = SportsManager::Participant.new(id: 3, name: 'José')

          team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
          team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
          team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
          teams = [team1, team2, team3]
          nil_team = SportsManager::NilTeam.new(category: category)

          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            { id: 1, name: 'João' },
            { id: 2, name: 'Marcelo' },
            { id: 3, name: 'José' }
          ]

          matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                               tournament_type: tournament_type, subscriptions: subscriptions).build

          expect(matches_result).to match_array [
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
              team2: nil_team
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 3,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[0], matches_result[1]]
            )
          ]
        end
      end

      context 'when number of teams is even but not power of 2' do
        it 'sets extra matches with byes' do
          category = :mixed_single
          matches = [[1], [2, 3], [4, 5], [6]]

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
          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            { id: 1, name: 'João' },
            { id: 2, name: 'Marcelo' },
            { id: 3, name: 'José' },
            { id: 4, name: 'Pedro' },
            { id: 5, name: 'Carlos' },
            { id: 6, name: 'Leandro' }
          ]

          matches_result = described_class.new(category: category, matches: matches, teams: teams,
                                               tournament_type: tournament_type, subscriptions: subscriptions).build

          expect(matches_result).to match_array [
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
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 5,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[0], matches_result[1]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 6,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 1,
              depends_on: [matches_result[2], matches_result[3]]
            ),
            have_attributes(
              class: SportsManager::Match,
              id: 7,
              category: category,
              team1: nil_team,
              team2: nil_team,
              round: 2,
              depends_on: [matches_result[4], matches_result[5]]
            )
          ]
        end
      end
    end
  end

  describe '#participant_ids' do
    context 'when matches has generated matches structure' do
      context 'single matches' do
        it 'returns a list of participant ids' do
          matches = [
            { id: 1, participants: [1, 2] },
            { id: 2, participants: [3, 4] }
          ]

          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            { id: 1, name: 'João' },
            { id: 2, name: 'Marcelo' },
            { id: 3, name: 'José' },
            { id: 4, name: 'Pedro' }
          ]
          participant_ids = described_class.new(category: :mixed_single,
                                                matches: matches,
                                                tournament_type: tournament_type,
                                                subscriptions: subscriptions,
                                                teams: []).send(:participant_ids)

          expect(participant_ids).to match_array [[1, 2], [3, 4]]
        end
      end

      context 'double matches' do
        it 'returns a list of participant ids' do
          matches = [
            { id: 1, participants: [[1, 2], [3, 4]] }
          ]

          tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
          subscriptions = [
            [{ id: 1, name: 'João' }, { id: 2, name: 'Marcelo' }],
            [{ id: 3, name: 'José' }, { id: 4, name: 'Pedro' }]
          ]
          participant_ids = described_class.new(category: :mixed_single,
                                                matches: matches,
                                                tournament_type: tournament_type,
                                                subscriptions: subscriptions,
                                                teams: []).send(:participant_ids)

          expect(participant_ids).to match_array [[[1, 2], [3, 4]]]
        end
      end
    end

    context 'when matches has not generated matches structure' do
      it 'returns a list of participant ids' do
        matches = [[1, 2], [3, 4]]

        tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
        subscriptions = [
          { id: 1, name: 'João' },
          { id: 2, name: 'Marcelo' },
          { id: 3, name: 'José' },
          { id: 4, name: 'Pedro' }
        ]
        participant_ids = described_class.new(category: :mixed_single,
                                              matches: matches,
                                              tournament_type: tournament_type,
                                              subscriptions: subscriptions,
                                              teams: []).send(:participant_ids)

        expect(participant_ids).to match_array [[1, 2], [3, 4]]
      end
    end
  end

  describe '#matches_structure?' do
    context 'when matches has generated matches structure' do
      it 'returns true' do
        matches = [{ id: 1, participants: [1, 2] }]

        tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
        subscriptions = [
          { id: 1, name: 'João' },
          { id: 2, name: 'Marcelo' }
        ]
        result = described_class.new(category: :mixed_single, matches: matches,
                                     tournament_type: tournament_type,
                                     subscriptions: subscriptions,
                                     teams: []).send(:generated_matches_structure?)

        expect(result).to be_truthy
      end
    end

    context 'when matches has not generated matches structure' do
      it 'returns false' do
        matches = [[1, 2]]

        tournament_type = SportsManager::Matches::Algorithms::SingleEliminationAlgorithm
        subscriptions = [
          { id: 1, name: 'João' },
          { id: 2, name: 'Marcelo' }
        ]
        result = described_class.new(category: :mixed_single,
                                     matches: matches,
                                     tournament_type: tournament_type,
                                     subscriptions: subscriptions,
                                     teams: []).send(:generated_matches_structure?)

        expect(result).to be_falsey
      end
    end
  end
end
