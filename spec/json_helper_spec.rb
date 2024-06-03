# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::JsonHelper do
  describe '#as_json' do
    context 'with a simple object' do
      let(:object) { { id: 1, name: 'João' } }

      it 'converts the object to JSON' do
        expect(object.as_json).to match(
          a_hash_including(
            'id' => object[:id],
            'name' => object[:name]
          )
        )
      end
    end

    context 'with an array of simple objects' do
      let(:objects) { [{ id: 1, name: 'João' }, { id: 2, name: 'Maria' }] }

      it 'converts the array to JSON' do
        expect(objects.as_json).to match([
          a_hash_including(
            'id' => objects.first[:id],
            'name' => objects.first[:name]
          ),
          a_hash_including(
            'id' => objects.last[:id],
            'name' => objects.last[:name]
          )
        ])
      end
    end

    context 'with a hash of simple objects' do
      let(:objects) { { player1: { id: 1, name: 'João' }, player2: { id: 2, name: 'Maria' } } }

      it 'converts the hash to JSON' do
        expect(objects.as_json).to match(
          a_hash_including(
            'player1' => a_hash_including(
              'id' => objects[:player1][:id],
              'name' => objects[:player1][:name]
            ),
            'player2' => a_hash_including(
              'id' => objects[:player2][:id],
              'name' => objects[:player2][:name]
            )
          )
        )
      end
    end

    context 'with nested objects' do
      let(:participant) { { id: 1, name: 'João' } }
      let(:data) { { participant: participant, time: Time.new(2023, 9, 9, 9, 0, 0, '-03:00') } }

      it 'handles nested objects correctly' do
        expect(data.as_json).to match(
          a_hash_including(
            'participant' => a_hash_including(
              'id' => participant[:id],
              'name' => participant[:name]
            ),
            'time' => '2023-09-09T09:00:00.000-03:00'
          )
        )
      end
    end
  end

  describe '#deep_symbolize_keys' do
    context 'with a hash' do
      let(:hash) { { 'a' => 1, 'b' => { 'c' => 2 } } }
      let(:expected_hash) { { a: 1, b: { c: 2 } } }

      it 'converts all keys to symbols' do
        expect(SportsManager::JsonHelper.deep_symbolize_keys(hash)).to eq(expected_hash)
      end
    end

    context 'with an array of hashes' do
      let(:array) { [{ 'a' => 1 }, { 'b' => { 'c' => 2 } }] }
      let(:expected_array) { [{ a: 1 }, { b: { c: 2 } }] }

      it 'converts all keys to symbols in each hash' do
        expect(SportsManager::JsonHelper.deep_symbolize_keys(array)).to eq(expected_array)
      end
    end
  end
end
