# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::SolutionDrawer::CLI::Table do
  describe '.draw' do
    it 'initialize and call draw' do
      data = spy
      instance = instance_double(described_class, draw: '123')

      allow(described_class)
        .to receive(:new)
        .with(data)
        .and_return instance

      table = described_class.draw(data)

      expect(table).to eq '123'
      expect(instance).to have_received(:draw)
    end
  end

  describe '#draw' do
    it 'returns data formatted as table' do
      data = [
        { a: 1, b: 10_000, c: 'ABCDEFGHIJKLMNOP' },
        { a: 3, b: 20_000_000, c: 'QRSTUVWXYZ' }
      ]

      table_output = <<~TABLE.chomp
        a |    b     |        c#{'        '}
        --|----------|-----------------
        1 | 10000    | ABCDEFGHIJKLMNOP
        3 | 20000000 | QRSTUVWXYZ#{'      '}
      TABLE

      table = described_class.new(data)

      expect(table.draw).to eq table_output
    end

    context 'when a field is a list' do
      it 'joins the content separating them by comma' do
        data = [
          { a: [1, 2, 3], b: 10_000, c: 'ABCDEFGHIJKLMNOP' },
          { a: [4, 5, 6, 7], b: 20_000_000, c: 'QRSTUVWXYZ' }
        ]

        table_output = <<~TABLE.chomp
               a       |    b     |        c#{'        '}
          -------------|----------|-----------------
          1, 2, 3      | 10000    | ABCDEFGHIJKLMNOP
          4, 5, 6, 7   | 20000000 | QRSTUVWXYZ#{'      '}
        TABLE

        table = described_class.new(data)

        expect(table.draw).to eq table_output
      end
    end
  end
end
