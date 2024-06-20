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
      subscriptions = {
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
      }

      matches = described_class.call(subscriptions)

      expect(matches).to match(a_hash_including(
                                 mens_single: [
                                   [1, 16], [2, 15], [3, 14], [4, 13],
                                   [5, 12], [6, 11], [7, 10], [8, 9]
                                 ]
                               ))
    end

    context 'when participants is even but not power of 2' do
      it 'generates an odd number of matches' do
        subscriptions = {
          mens_single: [
            { id: 1, name: 'João' },      { id: 2, name: 'Marcelo' },
            { id: 3, name: 'José' },      { id: 4, name: 'Pedro' },
            { id: 5, name: 'Carlos' },    { id: 6, name: 'Leandro' },
            { id: 7, name: 'Leonardo' },  { id: 8, name: 'Cláudio' },
            { id: 9, name: 'Alexandre' }, { id: 10, name: 'Daniel' }
          ]
        }


        matches = described_class.call(subscriptions)

        expect(matches).to match(a_hash_including(
                                    mens_single: [
                                      [1, 10], [2, 9],
                                      [3, 8], [4, 7], [5, 6]
                                    ]
                                  ))
      end
    end

    context 'when participants is odd' do
      it 'generates matches and byes (match with one subscriber)' do

        subscriptions = {
          mens_single: [
            { id: 1, name: 'João' },      { id: 2, name: 'Marcelo' },
            { id: 3, name: 'José' },      { id: 4, name: 'Pedro' },
            { id: 5, name: 'Carlos' }
          ]
        }


        matches = described_class.call(subscriptions)

        expect(matches).to match(a_hash_including(
                                   mens_single: [
                                     [1, 5],
                                     [2, 4],
                                     [3]
                                   ]
                                 ))
      end
    end

    context 'when double' do
      it 'generates even matches for subscribers' do
        subscriptions = {
          mens_double: [
            [{ id: 1, name: 'João' },    { id: 2, name: 'Marcelo' }],
            [{ id: 3, name: 'José' },    { id: 4, name: 'Pedro' }],
            [{ id: 5, name: 'Carlos' },  { id: 6, name: 'Leandro' }],
            [{ id: 7, name: 'Leonardo' }, { id: 8, name: 'Cláudio' }],
            [{ id: 9, name: 'Alexandre' }, { id: 10, name: 'Daniel' }],
            [{ id: 11, name: 'Marcos' }, { id: 12, name: 'Henrique' }],
            [{ id: 13, name: 'Joaquim' }, { id: 14, name: 'Alex' }],
            [{ id: 15, name: 'Bruno' }, { id: 16, name: 'Fábio' }]
          ]
        }

        matches = described_class.call(subscriptions)

        expect(matches).to match(a_hash_including(
                                   mens_double: [
                                     [[1, 2], [15, 16]],
                                     [[3, 4], [13, 14]],
                                     [[5, 6], [11, 12]],
                                     [[7, 8], [9, 10]]
                                   ]
                                 ))
      end
    end

    it 'generates matches for the subscribers' do
      subscriptions = {
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
        mens_double: [
          [{ id: 1, name: 'João' },    { id: 2, name: 'Marcelo' }],
          [{ id: 3, name: 'José' },    { id: 4, name: 'Pedro' }],
          [{ id: 5, name: 'Carlos' },  { id: 6, name: 'Leandro' }],
          [{ id: 7, name: 'Leonardo' }, { id: 8, name: 'Cláudio' }],
          [{ id: 9, name: 'Alexandre' }, { id: 10, name: 'Daniel' }],
          [{ id: 11, name: 'Marcos' }, { id: 12, name: 'Henrique' }],
          [{ id: 13, name: 'Joaquim' }, { id: 14, name: 'Alex' }],
          [{ id: 15, name: 'Bruno' }, { id: 16, name: 'Fábio' }]
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
        womens_single: [
          { id: 17, name: 'Laura' },    { id: 18, name: 'Karina' },
          { id: 19, name: 'Camila' },   { id: 20, name: 'Bruna' },
          { id: 21, name: 'Aline' },    { id: 22, name: 'Cintia' },
          { id: 23, name: 'Maria' },    { id: 24, name: 'Elis' },
          { id: 25, name: 'Joana' },    { id: 26, name: 'Izadora' },
          { id: 27, name: 'Claudia' },  { id: 28, name: 'Marina' },
          { id: 29, name: 'Carolina' }, { id: 30, name: 'Patricia' },
          { id: 31, name: 'Jéssica' },  { id: 32, name: 'Daniela' }
        ],
        mixed_single: [
          { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
          { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
          { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
          { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
        ],
        mixed_double: [
          [{ id: 1, name: 'João' },      { id: 2, name: 'Laura' }],
          [{ id: 3, name: 'José' },      { id: 4, name: 'Carolina' }],
          [{ id: 5, name: 'Erica' },     { id: 6, name: 'Leandro' }],
          [{ id: 7, name: 'Leonardo' },  { id: 8, name: 'Joana' }],
          [{ id: 9, name: 'Alexandre' }, { id: 10, name: 'Daniel' }],
          [{ id: 11, name: 'Marcos' },   { id: 12, name: 'Rafaela' }],
          [{ id: 13, name: 'Joaquim' },  { id: 14, name: 'Alex' }],
          [{ id: 15, name: 'Bruno' },    { id: 16, name: 'Fábio' }]
        ]
      }

      matches = described_class.call(subscriptions)

      expect(matches)
        .to match(a_hash_including(
                    mens_single: [[1, 16], [2, 15], [3, 14], [4, 13], [5, 12], [6, 11], [7, 10], [8, 9]],
                    womens_double: [[[17, 18], [31, 32]], [[19, 20], [29, 30]], [[21, 22], [27, 28]],
                                    [[23, 24], [25, 26]]],
                    womens_single: [[17, 32], [18, 31], [19, 30], [20, 29], [21, 28], [22, 27], [23, 26], [24, 25]],
                    mixed_single: [[1, 34], [5, 33], [10, 29], [17, 25]],
                    mens_double: [[[1, 2], [15, 16]], [[3, 4], [13, 14]], [[5, 6], [11, 12]], [[7, 8], [9, 10]]],
                    mixed_double: [[[1, 2], [15, 16]], [[3, 4], [13, 14]], [[5, 6], [11, 12]], [[7, 8], [9, 10]]]
                  ))
    end

    it 'generates matches for the subscribers but the number of participants or doubles are even' do
      subscriptions = {
        mens_single: [
          { id: 1, name: 'João' },      { id: 2, name: 'Marcelo' },
          { id: 3, name: 'José' },      { id: 4, name: 'Pedro' },
          { id: 5, name: 'Carlos' },    { id: 6, name: 'Leandro' },
          { id: 7, name: 'Leonardo' },  { id: 8, name: 'Cláudio' },
          { id: 9, name: 'Alexandre' }, { id: 10, name: 'Daniel' },
          { id: 11, name: 'Marcos' },   { id: 12, name: 'Henrique' },
          { id: 13, name: 'Joaquim' },  { id: 14, name: 'Alex' },
          { id: 15, name: 'Bruno' }
        ],
        mens_double: [
          [{ id: 1, name: 'João' },    { id: 2, name: 'Marcelo' }],
          [{ id: 3, name: 'José' },    { id: 4, name: 'Pedro' }],
          [{ id: 5, name: 'Carlos' },  { id: 6, name: 'Leandro' }],
          [{ id: 7, name: 'Leonardo' }, { id: 8, name: 'Cláudio' }],
          [{ id: 9, name: 'Alexandre' }, { id: 10, name: 'Daniel' }],
          [{ id: 11, name: 'Marcos' }, { id: 12, name: 'Henrique' }],
          [{ id: 13, name: 'Joaquim' }, { id: 14, name: 'Alex' }]
        ],
        womens_double: [
          [{ id: 17, name: 'Laura' },    { id: 18, name: 'Karina' }],
          [{ id: 19, name: 'Camila' },   { id: 20, name: 'Bruna' }],
          [{ id: 21, name: 'Aline' },    { id: 22, name: 'Cintia' }],
          [{ id: 23, name: 'Maria' },    { id: 24, name: 'Elis' }],
          [{ id: 25, name: 'Joana' },    { id: 26, name: 'Izadora' }],
          [{ id: 27, name: 'Claudia' },  { id: 28, name: 'Marina' }],
          [{ id: 29, name: 'Carolina' }, { id: 30, name: 'Patricia' }]
        ],
        womens_single: [
          { id: 17, name: 'Laura' },    { id: 18, name: 'Karina' },
          { id: 19, name: 'Camila' },   { id: 20, name: 'Bruna' },
          { id: 21, name: 'Aline' },    { id: 22, name: 'Cintia' },
          { id: 23, name: 'Maria' },    { id: 24, name: 'Elis' },
          { id: 25, name: 'Joana' },    { id: 26, name: 'Izadora' },
          { id: 27, name: 'Claudia' },  { id: 28, name: 'Marina' },
          { id: 29, name: 'Carolina' }, { id: 30, name: 'Patricia' },
          { id: 31, name: 'Jéssica' }
        ],
        mixed_single: [
          { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
          { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
          { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
          { id: 33, name: 'Erica' }
        ],
        mixed_double: [
          [{ id: 1, name: 'João' },      { id: 2, name: 'Laura' }],
          [{ id: 3, name: 'José' },      { id: 4, name: 'Carolina' }],
          [{ id: 5, name: 'Erica' },     { id: 6, name: 'Leandro' }],
          [{ id: 7, name: 'Leonardo' },  { id: 8, name: 'Joana' }],
          [{ id: 9, name: 'Alexandre' }, { id: 10, name: 'Daniel' }],
          [{ id: 11, name: 'Marcos' },   { id: 12, name: 'Rafaela' }],
          [{ id: 13, name: 'Joaquim' },  { id: 14, name: 'Alex' }]
        ]
      }


      matches = described_class.call(subscriptions)

      expect(matches)
        .to match(a_hash_including(
                    mens_single: [[1, 15], [2, 14], [3, 13], [4, 12], [5, 11], [6, 10], [7, 9], [8]],
                    womens_double: [[[17, 18], [29, 30]], [[19, 20], [27, 28]], [[21, 22], [25, 26]],
                                    [[23, 24]]],
                    womens_single: [[17, 31], [18, 30], [19, 29], [20, 28], [21, 27], [22, 26], [23, 25], [24]],
                    mixed_single: [[1, 33], [5, 29], [10, 25], [17]],
                    mens_double: [[[1, 2], [13, 14]], [[3, 4], [11, 12]], [[5, 6], [9, 10]], [[7, 8]]],
                    mixed_double: [[[1, 2], [13, 14]], [[3, 4], [11, 12]], [[5, 6], [9, 10]], [[7, 8]]]
                  ))
    end
  end
end
