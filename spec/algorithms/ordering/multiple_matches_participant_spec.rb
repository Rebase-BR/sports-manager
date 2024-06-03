# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Algorithms::Ordering::MultipleMatchesParticipant do
  it_behaves_like 'filter algorithm initializes with dependency'

  describe '#call' do
    it 'returns variables ordered by participants in multiple matches' do
      participant1 = instance_double(SportsManager::Participant, id: 1, name: 'João')
      participant2 = instance_double(SportsManager::Participant, id: 2, name: 'Maria')

      variable1 = instance_double(SportsManager::Match, id: 1, participants: [participant1])
      variable2 = instance_double(SportsManager::Match, id: 2, participants: [participant2])

      multi_tournament_participants = [participant2]

      tournament = instance_double(SportsManager::Tournament,
                                   multi_tournament_participants: multi_tournament_participants)

      variables = [variable1, variable2]

      sorted_variables = described_class.new(tournament).call(variables)

      expect(sorted_variables).to eq [variable2, variable1]
    end

    context 'when tie in being in multiple matches' do
      it 'order by number of duplicates in variable in ascending order' do
        participant1 = instance_double(SportsManager::Participant, id: 1, name: 'João')
        participant2 = instance_double(SportsManager::Participant, id: 2, name: 'Maria')
        participant3 = instance_double(SportsManager::Participant, id: 3, name: 'José')
        participant4 = instance_double(SportsManager::Participant, id: 4, name: 'Laura')

        variable1 = instance_double(SportsManager::Match, id: 1, participants: [participant1, participant3])
        variable2 = instance_double(SportsManager::Match, id: 2, participants: [participant2])
        variable3 = instance_double(SportsManager::Match, id: 3, participants: [participant4])

        multi_tournament_participants = [participant1, participant2, participant3]

        tournament = instance_double(SportsManager::Tournament,
                                     multi_tournament_participants: multi_tournament_participants)

        variables = [variable1, variable2, variable3]

        sorted_variables = described_class.new(tournament).call(variables)

        expect(sorted_variables).to eq [variable2, variable1, variable3]
      end
    end

    context 'when tie in number of duplicates' do
      it 'order by ids of duplicates in ascending order' do
        participant1 = instance_double(SportsManager::Participant, id: 100, name: 'João')
        participant2 = instance_double(SportsManager::Participant, id: 20, name: 'Maria')

        variable1 = instance_double(SportsManager::Match, id: 1, participants: [participant1])
        variable2 = instance_double(SportsManager::Match, id: 2, participants: [participant2])

        multi_tournament_participants = [participant1, participant2]

        tournament = instance_double(SportsManager::Tournament,
                                     multi_tournament_participants: multi_tournament_participants)

        variables = [variable1, variable2]

        sorted_variables = described_class.new(tournament).call(variables)

        expect(sorted_variables).to eq [variable2, variable1]
      end
    end

    context 'when tie in ids of duplicates' do
      it 'order by the number of participants in ascending order' do
        participant1 = instance_double(SportsManager::Participant, id: 1, name: 'João')
        participant2 = instance_double(SportsManager::Participant, id: 2, name: 'Maria')

        variable1 = instance_double(SportsManager::Match, id: 1, participants: [participant2])
        variable2 = instance_double(SportsManager::Match, id: 2, participants: [participant2, participant1])

        multi_tournament_participants = [participant2]

        tournament = instance_double(SportsManager::Tournament,
                                     multi_tournament_participants: multi_tournament_participants)

        variables = [variable1, variable2]

        sorted_variables = described_class.new(tournament).call(variables)

        expect(sorted_variables).to eq [variable1, variable2]
      end
    end

    context 'when tie in number of participants' do
      it 'order by the match id in ascending order' do
        participant1 = instance_double(SportsManager::Participant, id: 1, name: 'João')
        participant2 = instance_double(SportsManager::Participant, id: 2, name: 'Maria')

        variable1 = instance_double(SportsManager::Match, id: 10, participants: [participant1, participant2])
        variable2 = instance_double(SportsManager::Match, id: 1, participants: [participant2, participant1])
        variable3 = instance_double(SportsManager::Match, id: 2, participants: [participant2, participant1])

        multi_tournament_participants = [participant1, participant2]

        tournament = instance_double(SportsManager::Tournament,
                                     multi_tournament_participants: multi_tournament_participants)

        variables = [variable1, variable2, variable3]

        sorted_variables = described_class.new(tournament).call(variables)

        expect(sorted_variables).to eq [variable2, variable3, variable1]
      end
    end
  end
end
