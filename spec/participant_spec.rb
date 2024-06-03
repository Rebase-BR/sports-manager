# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Participant do
  describe '#<=>' do
    it "compares with another participant's id" do
      participant = described_class.new(id: 5, name: 'João')
      participant2 = described_class.new(id: 5, name: 'Maria')
      participant3 = described_class.new(id: 4, name: 'João')
      participant4 = described_class.new(id: 6, name: 'João')
      participant5 = Object.new

      expect(participant <=> participant2).to be_zero
      expect(participant <=> participant3).to eq(1)
      expect(participant <=> participant4).to eq(-1)
      expect(participant <=> participant5).to be_nil
    end
  end
end
