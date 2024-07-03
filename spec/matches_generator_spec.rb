# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::MatchesGenerator do
  describe '.call' do
    it 'instantiate the object with params and invokes call method' do
      instance = instance_double(SportsManager::MatchesGenerator, call: true)

      allow(described_class)
        .to receive(:new)
        .with({ a: 1 })
        .and_return(instance)

      described_class.call({ a: 1 })

      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    it 'generates an even number of matches for subscribers' do
      subscriptions = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16
      ]

      matches = described_class.call(subscriptions)

      expect(matches).to match([[1, 16], [2, 15], [3, 14], [4, 13],
                                [5, 12], [6, 11], [7, 10], [8, 9]])
    end

    context 'when participants is even but not power of 2' do
      it 'generates an odd number of matches' do
        subscriptions = [
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10
        ]

        matches = described_class.call(subscriptions)

        expect(matches).to match([
          [1, 10], [2, 9],
          [3, 8], [4, 7], [5, 6]
        ])
      end
    end

    context 'when participants is odd' do
      it 'generates matches and byes (match with one subscriber)' do
        subscriptions = [
          1, 2, 3, 4, 5
        ]

        matches = described_class.call(subscriptions)

        expect(matches).to match([
          [1, 5],
          [2, 4],
          [3]
        ])
      end
    end

    context 'when double' do
      it 'generates even matches for subscribers' do
        subscriptions = [
          [1, 2],
          [3, 4],
          [5, 6],
          [7, 8],
          [9, 10],
          [11, 12],
          [13, 14],
          [15, 16]

        ]

        matches = described_class.call(subscriptions)

        expect(matches).to match([
          [[1, 2], [15, 16]],
          [[3, 4], [13, 14]],
          [[5, 6], [11, 12]],
          [[7, 8], [9, 10]]
        ])
      end
    end
  end
end
