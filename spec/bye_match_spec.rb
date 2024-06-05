# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::ByeMatch do
  describe '#participants' do
    it "returns all team's participants" do
      category = :mixed_single
      participant1 = double
      participant2 = double
      team1 = instance_double(SportsManager::Team, participants: [participant1])
      team2 = instance_double(SportsManager::Team, participants: [participant2])

      bye = described_class.new(category: category, team1: team1, team2: team2)

      expect(bye.participants).to eq [participant1, participant2]
    end
  end

  describe '#dependencies?' do
    it 'returns false' do
      bye = described_class.new(category: :mixed_single)

      expect(bye).to_not be_dependencies
    end
  end

  describe '#dependencies' do
    it 'returns false' do
      bye = described_class.new(category: :mixed_single)

      expect(bye.dependencies).to be_empty
    end
  end

  describe '#playable_dependencies' do
    it 'returns false' do
      bye = described_class.new(category: :mixed_single)

      expect(bye.playable_dependencies).to be_empty
    end
  end

  describe '#previous_matches?' do
    it 'returns false' do
      bye = described_class.new(category: :mixed_single)

      expect(bye).to_not be_previous_matches
    end
  end

  describe '#previous_matches' do
    it 'returns false' do
      bye = described_class.new(category: :mixed_single)

      expect(bye.previous_matches).to be_empty
    end
  end

  describe '#title' do
    it 'returns the team names with BYE' do
      team1 = instance_double(SportsManager::Team, name: 'Team 1')
      team2 = instance_double(SportsManager::Team, name: 'Team 2')

      bye = described_class.new(category: :mixed_single, team1: team1, team2: team2)

      expect(bye.title).to eq 'Team 1Team 2 | BYE'
    end
  end

  describe '#==' do
    context 'when id, category, and round are the same' do
      it 'returns true' do
        attributes = { category: :mixed_single, id: 1, round: 0 }
        bye1 = described_class.new(**attributes)
        bye2 = described_class.new(**attributes)

        expect(bye1 == bye2).to eq true
      end
    end

    context 'when id, category, or round are not the same' do
      it 'returns false' do
        attributes = { category: :mixed_single, id: 1, round: 0 }
        attributes_diff = { category: :men_single, id: 2, round: 1 }

        bye1 = described_class.new(**attributes)

        attributes_diff.each do |attribute, value|
          bye2 = described_class.new(**attributes, attribute => value)

          expect(bye1 == bye2).to eq false
        end
      end
    end
  end
end
