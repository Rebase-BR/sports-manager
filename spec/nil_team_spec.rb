# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::NilTeam do
  describe '#==' do
    it 'compares with another team' do
      category = :mixed_single
      team1 = described_class.new(category: category)
      team2 = described_class.new(category: category)
      team3 = described_class.new(category: :mixed_double)
      team4 = instance_double(SportsManager::Team, category: category)

      expect(team1 == team2).to eq true
      expect(team1 == team3).to eq false
      expect(team1 == team4).to eq false
    end
  end
end
