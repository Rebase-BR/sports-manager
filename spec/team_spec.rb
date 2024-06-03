# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Team do
  describe '.for' do
    context 'when participants is one' do
      it 'builds for a team of one' do
        participants = [double]

        allow(SportsManager::SingleTeam).to receive(:new)

        described_class.for(participants: participants, category: :x)

        expect(SportsManager::SingleTeam)
          .to have_received(:new)
          .with(participants: participants, category: :x)
      end
    end

    context 'when participants is two' do
      it 'builds for a team of two' do
        participants = [double, double]

        allow(SportsManager::DoubleTeam).to receive(:new)

        described_class.for(participants: participants, category: :x)

        expect(SportsManager::DoubleTeam)
          .to have_received(:new)
          .with(participants: participants, category: :x)
      end
    end

    context 'when participants is higher than two' do
      it 'raises an error' do
        participants = [double, double, double]

        expect { described_class.for(participants: participants, category: :x) }
          .to raise_error StandardError,
                          "Participants #{participants} is not between 1 and 2"
      end
    end

    context 'when there is no participant' do
      it 'raises an error' do
        expect { described_class.for(participants: [], category: :x) }
          .to raise_error StandardError,
                          'Participants [] is not between 1 and 2'
      end
    end
  end

  describe '#==' do
    it "compares with another team's category and participants" do
      participants = [double]

      team1 = described_class.new(participants: participants, category: :x)
      team2 = described_class.new(participants: participants, category: :x)

      expect(team1 == team2).to eq true
    end

    context 'when category is different' do
      it 'returns false' do
        participants = [double]

        team1 = described_class.new(participants: participants, category: :x)
        team2 = described_class.new(participants: participants, category: :y)

        expect(team1 == team2).to eq false
      end
    end

    context 'when participants are different' do
      it 'returns false' do
        participants = [double]
        participants2 = [double]

        team1 = described_class.new(participants: participants, category: :x)
        team2 = described_class.new(participants: participants2, category: :x)

        expect(team1 == team2).to eq false
      end
    end
  end
end
