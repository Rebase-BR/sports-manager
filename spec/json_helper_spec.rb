# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::JsonHelper do
  let(:dummy_class) do
    Class.new do
      include SportsManager::JsonHelper

      attr_accessor :attr1, :attr2

      def initialize(attr1, attr2)
        @attr1 = attr1
        @attr2 = attr2
      end
    end
  end

  let(:custom_object) do
    Class.new do
      def to_sym
        raise StandardError, 'Cannot convert to symbol'
      end
    end
  end

  describe '#as_json' do
    context 'when object has attributes' do
      it 'returns a hash representation of the object' do
        obj = dummy_class.new('value1', 123)
        expect(obj.as_json).to eq({ attr1: 'value1', attr2: 123 })
      end
    end

    context 'when object does not have attributes' do
      it 'returns an empty hash' do
        obj = dummy_class.new(nil, nil)
        expect(obj.as_json).to eq({ attr1: nil, attr2: nil })
      end
    end
  end

  describe '.deep_symbolize_keys' do
    it 'symbolizes keys of a hash' do
      hash = { 'key1' => 'value1', 'key2' => { 'key3' => 'value3' } }
      expect(SportsManager::JsonHelper.deep_symbolize_keys(hash)).to eq({ key1: 'value1', key2: { key3: 'value3' } })
    end

    it 'symbolizes keys of an array of hashes' do
      array = [{ 'key1' => 'value1' }, { 'key2' => 'value2' }]
      expect(SportsManager::JsonHelper.deep_symbolize_keys(array)).to eq([{ key1: 'value1' }, { key2: 'value2' }])
    end

    it 'returns the original value if it is neither a hash nor an array' do
      value = 'string'
      expect(SportsManager::JsonHelper.deep_symbolize_keys(value)).to eq('string')
    end

    it 'returns the original key if to_sym raises an exception' do
      hash = { custom_object.new => 'value1' }
      expect(SportsManager::JsonHelper.deep_symbolize_keys(hash)).to eq(hash)
    end
  end

  describe '.convert_value' do
    it 'converts hash keys to symbols and values recursively' do
      hash = { 'key1' => 'value1', 'key2' => { 'key3' => 'value3' } }
      expect(SportsManager::JsonHelper.convert_value(hash)).to eq({ key1: 'value1', key2: { key3: 'value3' } })
    end

    it 'converts array values recursively' do
      array = [{ 'key1' => 'value1' }, { 'key2' => 'value2' }]
      expect(SportsManager::JsonHelper.convert_value(array)).to eq([{ key1: 'value1' }, { key2: 'value2' }])
    end

    it 'returns the value if it does not respond to as_json' do
      value = 123
      expect(SportsManager::JsonHelper.convert_value(value)).to eq(123)
    end
  end

  describe '.convert_custom_object' do
    it 'converts instance variables to hash with symbolized keys' do
      obj = dummy_class.new('value1', 123)
      expect(SportsManager::JsonHelper.convert_custom_object(obj)).to eq({ attr1: 'value1', attr2: 123 })
    end
  end
end

RSpec.describe Hash do
  describe '#as_json' do
    it 'returns hash with string keys and as_json values' do
      hash = { key1: 'value1', key2: 123 }
      expect(hash.as_json).to eq({ 'key1' => 'value1', 'key2' => 123 })
    end
  end

  describe '#deep_symbolize_keys' do
    it 'symbolizes keys of the hash' do
      hash = { 'key1' => 'value1', 'key2' => { 'key3' => 'value3' } }
      expect(hash.deep_symbolize_keys).to eq({ key1: 'value1', key2: { key3: 'value3' } })
    end
  end
end

RSpec.describe Array do
  describe '#as_json' do
    it 'returns array with as_json values' do
      array = ['value1', 123]
      expect(array.as_json).to eq(['value1', 123])
    end
  end

  describe '#deep_symbolize_keys' do
    it 'symbolizes keys of each hash in the array' do
      array = [{ 'key1' => 'value1' }, { 'key2' => 'value2' }]
      expect(array.deep_symbolize_keys).to eq([{ key1: 'value1' }, { key2: 'value2' }])
    end
  end
end

RSpec.describe Symbol do
  describe '#as_json' do
    it 'returns the symbol as a string' do
      expect(:symbol.as_json).to eq('symbol')
    end
  end
end

RSpec.describe Numeric do
  describe '#as_json' do
    it 'returns the numeric value itself' do
      expect(123.as_json).to eq(123)
    end
  end
end

RSpec.describe String do
  describe '#as_json' do
    it 'returns the string itself' do
      expect('string'.as_json).to eq('string')
    end
  end
end

RSpec.describe TrueClass do
  describe '#as_json' do
    it 'returns true' do
      expect(true.as_json).to eq(true)
    end
  end
end

RSpec.describe FalseClass do
  describe '#as_json' do
    it 'returns false' do
      expect(false.as_json).to eq(false)
    end
  end
end

RSpec.describe NilClass do
  describe '#as_json' do
    it 'returns nil' do
      expect(nil.as_json).to eq(nil)
    end
  end
end

RSpec.describe Time do
  describe '#as_json' do
    it 'returns the time in ISO 8601 format' do
      time = Time.now
      expect(time.as_json).to eq(time.xmlschema(3))
    end
  end
end

RSpec.describe Object do
  describe '#as_json' do
    context 'when object has attributes' do
      it 'returns a hash representation of the object' do
        obj = double('object', attributes: { key1: 'value1', key2: 123 })
        expect(obj.as_json).to eq({ 'key1' => 'value1', 'key2' => 123 })
      end
    end

    context 'when object does not have attributes' do
      it 'returns a hash with instance variables' do
        obj = double('object')
        allow(obj).to receive(:instance_variables).and_return(%i[@var1 @var2])
        allow(obj).to receive(:instance_variable_get).with(:@var1).and_return('value1')
        allow(obj).to receive(:instance_variable_get).with(:@var2).and_return(123)
        expect(obj.as_json).to eq({ var1: 'value1', var2: 123 })
      end
    end
  end
end
