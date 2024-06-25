# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::MatchBuilder do
  describe '#build' do
    context 'when matches has already generated matches structure' do
      it 'returns a list of matches for a category' do
        category = :mixed_single
        matches = [
          { id: 1, participants: [1, 2] }
        ]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
        teams = [team1, team2]

        matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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

        matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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

        matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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

        matches_result = described_class.new(category: category, matches: matches, teams: teams).build

        expect(matches_result[2].depends_on).to match_array [matches_result[0], matches_result[1]]
        expect(matches_result[3].depends_on).to match_array [matches_result[2]]
      end

      context 'when multiple matches ids' do
        it 'returns a list of matches' do
          category = :mixed_single
          matches = [
            { id: 1, participants: [1, 34] },
            { id: 2, participants: [2, 33] }
          ]
          participant1 = SportsManager::Participant.new(id: 1, name: 'João')
          participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
          participant3 = SportsManager::Participant.new(id: 33, name: 'Erica')
          participant4 = SportsManager::Participant.new(id: 34, name: 'Cleber')

          team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
          team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
          team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
          team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)

          teams = [team1, team2, team3, team4]

          matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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
            )
          ]
        end
      end

      context 'when double matches ids' do
        it 'returns a list of matches' do
          category = :mixed_single
          matches = [
            { id: 1, participants: [[17, 18], [31, 32]] }
          ]
          participant1 = SportsManager::Participant.new(id: 17, name: 'Laura')
          participant2 = SportsManager::Participant.new(id: 18, name: 'Karina')
          participant3 = SportsManager::Participant.new(id: 31, name: 'Jéssica')
          participant4 = SportsManager::Participant.new(id: 32, name: 'Daniela')

          team1 = SportsManager::DoubleTeam.new(participants: [participant1, participant2], category: category)
          team2 = SportsManager::DoubleTeam.new(participants: [participant3, participant4], category: category)
          teams = [team1, team2]

          matches_result = described_class.new(category: category, matches: matches, teams: teams).build

          expect(matches_result).to match_array [
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
          matches = [
            { id: 1, participants: [1, 2] },
            { id: 2, participants: [3] }
          ]

          participant1 = SportsManager::Participant.new(id: 1, name: 'João')
          participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
          participant3 = SportsManager::Participant.new(id: 3, name: 'José')

          team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
          team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
          team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
          teams = [team1, team2, team3]

          matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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
              team2: SportsManager::NilTeam.new(category: category)
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

          matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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
            )
          ]
        end
      end
    end

    context 'when matches has not already generated matches structure' do
      it 'returns a list of matches for a category' do
        category = :mixed_single
        matches = [[1, 2]]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
        teams = [team1, team2]

        matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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

      context 'when multiple matches ids' do
        it 'returns a list of matches' do
          category = :mixed_single
          matches = [[1, 34], [2, 33]]
          participant1 = SportsManager::Participant.new(id: 1, name: 'João')
          participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
          participant3 = SportsManager::Participant.new(id: 33, name: 'Erica')
          participant4 = SportsManager::Participant.new(id: 34, name: 'Cleber')

          team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
          team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
          team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
          team4 = SportsManager::SingleTeam.new(participants: [participant4], category: category)

          teams = [team1, team2, team3, team4]

          matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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
            )
          ]
        end
      end

      context 'when double matches ids' do
        it 'returns a list of matches' do
          category = :mixed_single
          matches = [[[17, 18], [31, 32]]]
          participant1 = SportsManager::Participant.new(id: 17, name: 'Laura')
          participant2 = SportsManager::Participant.new(id: 18, name: 'Karina')
          participant3 = SportsManager::Participant.new(id: 31, name: 'Jéssica')
          participant4 = SportsManager::Participant.new(id: 32, name: 'Daniela')

          team1 = SportsManager::DoubleTeam.new(participants: [participant1, participant2], category: category)
          team2 = SportsManager::DoubleTeam.new(participants: [participant3, participant4], category: category)
          teams = [team1, team2]

          matches_result = described_class.new(category: category, matches: matches, teams: teams).build

          expect(matches_result).to match_array [
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
          matches = [[1, 2], [3]]

          participant1 = SportsManager::Participant.new(id: 1, name: 'João')
          participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
          participant3 = SportsManager::Participant.new(id: 3, name: 'José')

          team1 = SportsManager::SingleTeam.new(participants: [participant1], category: category)
          team2 = SportsManager::SingleTeam.new(participants: [participant2], category: category)
          team3 = SportsManager::SingleTeam.new(participants: [participant3], category: category)
          teams = [team1, team2, team3]

          matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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
              team2: SportsManager::NilTeam.new(category: category)
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

          matches_result = described_class.new(category: category, matches: matches, teams: teams).build

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
            )
          ]
        end
      end
    end
  end
  describe '#extract_participant_ids' do
    context 'when matches has already generated matches structure' do
      context 'single matches' do
        it 'returns a list of participant ids' do
          matches = [
            { id: 1, participants: [1, 2] },
            { id: 2, participants: [3, 4] }
          ]

          participant_ids = described_class.new(category: :mixed_single, matches: matches, teams: []).send(:extract_participant_ids)

          expect(participant_ids).to match_array [[1, 2], [3, 4]]
        end
      end

      context 'double matches' do
        it 'returns a list of participant ids' do
          matches = [
            { id: 1, participants: [[1, 2], [3, 4]] }
          ]

          participant_ids = described_class.new(category: :mixed_single, matches: matches, teams: []).send(:extract_participant_ids)

          expect(participant_ids).to match_array [[[1, 2], [3, 4]]]
        end
      end
    end

    context 'when matches has not already generated matches structure' do
      it 'returns a list of participant ids' do
        matches = [[1, 2], [3, 4]]

        participant_ids = described_class.new(category: :mixed_single, matches: matches, teams: []).send(:extract_participant_ids)

        expect(participant_ids).to match_array [[1, 2], [3, 4]]
      end
    end
  end
  describe '#matches_has_already_generated_matches_structure?' do
    context 'when matches has already generated matches structure' do
      it 'returns true' do
        matches = [{ id: 1, participants: [1, 2] }]

        result = described_class.new(category: :mixed_single, matches: matches, teams: []).send(:matches_has_already_generated_matches_structure?)

        expect(result).to be_truthy
      end
    end

    context 'when matches has not already generated matches structure' do
      it 'returns false' do
        matches = [[1, 2]]

        result = described_class.new(category: :mixed_single, matches: matches, teams: []).send(:matches_has_already_generated_matches_structure?)

        expect(result).to be_falsey
      end
    end
  end
  describe '#build_already_generated_matches' do
    context 'single matches' do
      it 'returns a list of matches' do
        matches = [
          { id: 1, participants: [1, 2] },
          { id: 2, participants: [3, 4] }
        ]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 3, name: 'José')
        participant4 = SportsManager::Participant.new(id: 4, name: 'Pedro')

        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: :mixed_single)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: :mixed_single)
        team3 = SportsManager::SingleTeam.new(participants: [participant3], category: :mixed_single)
        team4 = SportsManager::SingleTeam.new(participants: [participant4], category: :mixed_single)

        teams = [team1, team2, team3, team4]

        matches_result = described_class.new(category: :mixed_single, matches: matches, teams: teams).send(:build_already_generated_matches, matches)

        expect(matches_result).to match_array [
          have_attributes(
            class: SportsManager::Match,
            id: 1,
            team1: team1,
            team2: team2
          ),
          have_attributes(
            class: SportsManager::Match,
            id: 2,
            team1: team3,
            team2: team4
          )
        ]
      end
    end

    context 'single matches with byes' do
      it 'returns a list of matches' do
        matches = [
          { id: 1, participants: [1, 2] },
          { id: 2, participants: [3] }
        ]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 3, name: 'José')

        team1 = SportsManager::SingleTeam.new(participants: [participant1], category: :mixed_single)
        team2 = SportsManager::SingleTeam.new(participants: [participant2], category: :mixed_single)
        team3 = SportsManager::SingleTeam.new(participants: [participant3], category: :mixed_single)

        teams = [team1, team2, team3]

        matches_result = described_class.new(category: :mixed_single, matches: matches, teams: teams).send(:build_already_generated_matches, matches)

        expect(matches_result).to match_array [
          have_attributes(
            class: SportsManager::Match,
            id: 1,
            team1: team1,
            team2: team2
          ),
          have_attributes(
            class: SportsManager::ByeMatch,
            id: 2,
            team1: team3,
            team2: SportsManager::NilTeam.new(category: :mixed_single)
          )
        ]
      end
    end

    context 'double matches' do
      it 'returns a list of matches' do
        matches = [
          { id: 1, participants: [[1, 2], [3, 4]] },
          { id: 2, participants: [[5, 6], [7, 8]] }
        ]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 3, name: 'José')
        participant4 = SportsManager::Participant.new(id: 4, name: 'Pedro')
        participant5 = SportsManager::Participant.new(id: 5, name: 'Laura')
        participant6 = SportsManager::Participant.new(id: 6, name: 'Karina')
        participant7 = SportsManager::Participant.new(id: 7, name: 'Jéssica')
        participant8 = SportsManager::Participant.new(id: 8, name: 'Daniela')

        team1 = SportsManager::DoubleTeam.new(participants: [participant1, participant2], category: :mixed_single)
        team2 = SportsManager::DoubleTeam.new(participants: [participant3, participant4], category: :mixed_single)
        team3 = SportsManager::DoubleTeam.new(participants: [participant5, participant6], category: :mixed_single)
        team4 = SportsManager::DoubleTeam.new(participants: [participant7, participant8], category: :mixed_single)

        teams = [team1, team2, team3, team4]

        matches_result = described_class.new(category: :mixed_single, matches: matches, teams: teams).send(:build_already_generated_matches, matches)

        expect(matches_result).to match_array [
          have_attributes(
            class: SportsManager::Match,
            id: 1,
            team1: team1,
            team2: team2
          ),
          have_attributes(
            class: SportsManager::Match,
            id: 2,
            team1: team3,
            team2: team4
          ),
        ]
      end
    end

    context 'double matches with byes' do
      it 'returns a list of matches' do
        matches = [
          { id: 1, participants: [[1, 2], [3, 4]] },
          { id: 2, participants: [[5, 6]] }
        ]
        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 2, name: 'Marcelo')
        participant3 = SportsManager::Participant.new(id: 3, name: 'José')
        participant4 = SportsManager::Participant.new(id: 4, name: 'Pedro')
        participant5 = SportsManager::Participant.new(id: 5, name: 'Laura')
        participant6 = SportsManager::Participant.new(id: 6, name: 'Karina')

        team1 = SportsManager::DoubleTeam.new(participants: [participant1, participant2], category: :mixed_single)
        team2 = SportsManager::DoubleTeam.new(participants: [participant3, participant4], category: :mixed_single)
        team3 = SportsManager::DoubleTeam.new(participants: [participant5, participant6], category: :mixed_single)

        nil_team = SportsManager::NilTeam.new(category: :mixed_single)

        teams = [team1, team2, team3]

        matches_result = described_class.new(category: :mixed_single, matches: matches, teams: teams).send(:build_already_generated_matches, matches)

        expect(matches_result).to match_array [
          have_attributes(
            class: SportsManager::Match,
            id: 1,
            team1: team1,
            team2: team2
          ),
          have_attributes(
            class: SportsManager::ByeMatch,
            id: 2,
            team1: team3,
            team2: nil_team
          )
        ]
      end
    end
  end
end
