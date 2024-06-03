# frozen_string_literal: true

# spec/sports_manager/helper_spec.rb

require 'spec_helper'

RSpec.describe SportsManager::Helper do
  describe '.minimal' do
    it 'returns the minimal payload' do
      expected_payload = {
        when: {
          '2023-09-09': { start: 9, end: 20 }
        },
        courts: 1,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mixed_single: [{ id: 1, name: 'João' }, { id: 34, name: 'Cleber' }]
        },
        matches: {
          mixed_single: [[1, 34]]
        }
      }

      expect(SportsManager::Helper.minimal).to eq(expected_payload)
    end
  end

  describe '.simple' do
    it 'returns the simple payload' do
      expected_payload = {
        when: {
          '2023-09-09': { start: 9, end: 20 }
        },
        courts: 1,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
            { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
            { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
            { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
          ]
        },
        matches: {
          mixed_single: [[1, 34], [5, 33], [10, 29], [17, 25]]
        }
      }

      expect(SportsManager::Helper.simple).to eq(expected_payload)
    end
  end

  describe '.simple_multi_court' do
    it 'returns the simple payload with multiple courts' do
      expected_payload = {
        when: {
          '2023-09-09': { start: 9, end: 20 }
        },
        courts: 2,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
            { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
            { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
            { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
          ]
        },
        matches: {
          mixed_single: [[1, 34], [5, 33], [10, 29], [17, 25]]
        }
      }

      expect(SportsManager::Helper.simple_multi_court).to eq(expected_payload)
    end
  end

  describe '.simple_odd_matches' do
    it 'returns the simple payload with odd matches' do
      expected_payload = {
        when: {
          '2023-09-09': { start: 9, end: 20 }
        },
        courts: 2,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
            { id: 10, name: 'Daniel' }, { id: 29, name: 'Carolina' },
            { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
          ]
        },
        matches: {
          mixed_single: [[1], [5, 34], [10, 29], [33]]
        }
      }

      expect(SportsManager::Helper.simple_odd_matches).to eq(expected_payload)
    end
  end

  describe '.complete' do
    it 'returns the complete payload' do
      expected_payload = {
        when: {
          '2023-09-09': { start: 9, end: 20 },
          '2023-09-10': { start: 9, end: 13 }
        },
        courts: 2,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mens_single: [
            { id: 1, name: 'João' },      { id: 2, name: 'Marcelo' },
            { id: 3, name: 'José' },      { id: 4, name: 'Pedro' },
            { id: 5, name: 'Carlos' },    { id: 6, name: 'Leandro' },
            { id: 7, name: 'Leonardo' },  { id: 8, name: 'Cláudio' },
            { id: 9, name: 'Alexandre' }, { id: 10, name: 'Daniel' },
            { id: 11, name: 'Marcos' },   { id: 12, name: 'Henrique' },
            { id: 13, name: 'Joaquim' },  { id: 14, name: 'Alex' },
            { id: 15, name: 'Bruno' },    { id: 16, name: 'Fábio' }
          ]
        },
        matches: {
          mens_single: [
            [1, 16],
            [2, 15],
            [3, 14],
            [4, 13],
            [5, 12],
            [6, 11],
            [7, 10],
            [8, 9]
          ]
        }
      }

      expect(SportsManager::Helper.complete).to eq(expected_payload)
    end
  end

  describe '.complex' do
    it 'returns the complex payload' do
      expected_payload = {
        when: {
          '2023-09-09': { start: 9, end: 20 },
          '2023-09-10': { start: 9, end: 13 }
        },
        courts: 2,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mens_single: [
            { id: 1, name: 'João' },      { id: 2, name: 'Marcelo' },
            { id: 3, name: 'José' },      { id: 4, name: 'Pedro' },
            { id: 5, name: 'Carlos' },    { id: 6, name: 'Leandro' },
            { id: 7, name: 'Leonardo' },  { id: 8, name: 'Cláudio' },
            { id: 9, name: 'Alexandre' }, { id: 10, name: 'Daniel' },
            { id: 11, name: 'Marcos' },   { id: 12, name: 'Henrique' },
            { id: 13, name: 'Joaquim' },  { id: 14, name: 'Alex' },
            { id: 15, name: 'Bruno' },    { id: 16, name: 'Fábio' }
          ],
          womens_double: [
            [{ id: 17, name: 'Laura' },    { id: 18, name: 'Karina' }],
            [{ id: 19, name: 'Camila' },   { id: 20, name: 'Bruna' }],
            [{ id: 21, name: 'Aline' },    { id: 22, name: 'Cintia' }],
            [{ id: 23, name: 'Maria' },    { id: 24, name: 'Elis' }],
            [{ id: 25, name: 'Joana' },    { id: 26, name: 'Izadora' }],
            [{ id: 27, name: 'Claudia' },  { id: 28, name: 'Marina' }],
            [{ id: 29, name: 'Carolina' }, { id: 30, name: 'Patricia' }],
            [{ id: 31, name: 'Jéssica' },  { id: 32, name: 'Daniela' }]
          ],
          mixed_single: [
            { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
            { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
            { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
            { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
          ]
        },
        matches: {
          mens_single: [
            [1, 16],
            [2, 15],
            [3, 14],
            [4, 13],
            [5, 12],
            [6, 11],
            [7, 10],
            [8, 9]
          ],
          womens_double: [
            [[17, 18], [31, 32]],
            [[19, 20], [29, 30]],
            [[21, 22], [27, 28]],
            [[23, 24], [25, 26]]
          ],
          mixed_single: [
            [1, 34],
            [5, 33],
            [10, 29],
            [17, 25]
          ]
        }
      }

      expect(SportsManager::Helper.complex).to eq(expected_payload)
    end
  end

  describe '.duplicate' do
    it 'returns the duplicate payload' do
      expected_payload = {
        when: { '2023-09-09': { start: 9, end: 20 } },
        courts: 1,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mens_single: [
            { id: 1, name: 'João' },
            { id: 2, name: 'Marcelo' }
          ],
          mixed_single: [
            { id: 1, name: 'João' },
            { id: 5, name: 'Carlos' },
            { id: 10, name: 'Daniel' },
            { id: 17, name: 'Laura' }
          ]
        },
        matches: {
          mens_single: [[1, 2]],
          mixed_single: [[1, 10], [5, 17]]
        }
      }

      expect(SportsManager::Helper.duplicate).to eq(expected_payload)
    end
  end

  describe '.no_solution' do
    it 'returns the no_solution payload' do
      expected_payload = {
        when: {
          '2023-09-09': { start: 9, end: 10 }
        },
        courts: 1,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
            { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
            { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
            { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
          ]
        },
        matches: {
          mixed_single: [[1, 34], [5, 33], [10, 29], [17, 25]]
        }
      }

      expect(SportsManager::Helper.no_solution).to eq(expected_payload)
    end
  end
end
