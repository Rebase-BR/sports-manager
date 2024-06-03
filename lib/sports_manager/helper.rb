# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/ModuleLength
module SportsManager
  # Public: Predefined payloads for validation
  module Helper
    module_function

    def minimal
      {
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
    end

    def simple
      {
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
    end

    def simple_multi_court
      simple.merge(courts: 2)
    end

    def simple_odd_matches
      {
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
    end

    def complete
      {
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
    end

    def complex
      {
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
    end

    def duplicate
      {
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
    end

    def no_solution
      {
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
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/ModuleLength
