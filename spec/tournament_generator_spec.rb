# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::TournamentGenerator do
  describe '.example' do
    it 'runs an example for a tournament scheduling' do
      params = {
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

      instance = double('SportsManager', call: true)

      allow(described_class)
        .to receive(:new)
        .with(params, format: :cli)
        .and_return(instance)

      described_class.example

      expect(instance).to have_received(:call)
    end

    context 'when receives a type' do
      it 'runs the example based on type' do
        instance = double('SportsManager', call: true)

        allow(SportsManager::Helper)
          .to receive(:public_send)
          .with(:complex)
          .and_return({ a: 1 })

        allow(described_class).to receive(:new).and_return(instance)

        described_class.example(:complex)

        expect(instance).to have_received(:call)
      end
    end

    context 'when type does not exists' do
      it 'raises an error' do
        expect { described_class.example(:unknown) }
          .to raise_error NoMethodError
      end
    end
  end

  describe '.call' do
    it 'instantiate and invokes the call method' do
      instance = double('SportsManager', call: true)

      allow(described_class)
        .to receive(:new)
        .with({ a: 1 }, format: :cli)
        .and_return(instance)

      described_class.call({ a: 1 })

      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    before do
      allow($stdout).to receive(:puts)
    end

    it 'returns a scheduling solution for tournament' do
      params = {
        when: { '2023-09-09': { start: 9, end: 10 } },
        courts: 1,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },
            { id: 5, name: 'Carlos' }
          ]
        },
        matches: { mixed_single: [[1, 5]] }
      }

      tournament_solution = described_class.new(params).call

      solution, = tournament_solution.solutions

      expect(tournament_solution).to be_a SportsManager::TournamentSolution
      expect(solution.fixtures).to match_array [
        have_attributes(
          class: SportsManager::TournamentSolution::Fixture,
          match: have_attributes(
            class: SportsManager::Match,
            category: :mixed_single,
            id: 1,
            round: 0,
            depends_on: [],
            team1: have_attributes(
              class: SportsManager::SingleTeam,
              category: :mixed_single,
              participants: [
                have_attributes(class: SportsManager::Participant, id: 1, name: 'João')
              ]
            ),
            team2: have_attributes(
              class: SportsManager::SingleTeam,
              category: :mixed_single,
              participants: [
                have_attributes(class: SportsManager::Participant, id: 5, name: 'Carlos')
              ]
            )
          ),
          timeslot: have_attributes(
            class: SportsManager::Timeslot,
            court: 0,
            slot: Time.parse('2023-09-09T09:00:00'),
            date: have_attributes(
              class: SportsManager::TournamentDay,
              date: '2023-09-09',
              start_hour: 9,
              end_hour: 10
            )
          )
        )
      ]
    end

    it 'calls a drawer with the tournament solution' do
      params = {
        when: { '2023-09-09': { start: 9, end: 10 } },
        courts: 1,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: false,
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },
            { id: 5, name: 'Carlos' }
          ]
        },
        matches: { mixed_single: [[1, 5]] }
      }
      drawer_class = SportsManager::SolutionDrawer
      drawer = instance_double(drawer_class, cli: true)

      allow(drawer_class).to receive(:new).and_return(drawer)

      tournament_solution = described_class.new(params).call

      expect(drawer_class).to have_received(:new).with(tournament_solution)
      expect(drawer).to have_received(:cli)
    end

    context 'when there is no solution' do
      it 'returns empty solution' do
        params = {
          when: { '2023-09-09': { start: 9, end: 9 } },
          courts: 1,
          game_length: 60,
          rest_brake: 30,
          single_day_matches: false,
          subscriptions: {
            mixed_single: [
              { id: 1, name: 'João' },
              { id: 5, name: 'Carlos' },
              { id: 17, name: 'Laura' },
              { id: 18, name: 'Karina' }
            ]
          },
          matches: { mixed_single: [[1, 5], [17, 18]] }
        }

        tournament_solution = described_class.new(params).call

        expect(tournament_solution.solutions).to be_empty
      end
    end

    context 'when problem has multiple categories' do
      it 'returns a scheduling solution for tournament' do
        params = {
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
              { id: 15, name: 'Bruno' },    { id: 16, name: 'Fábio' }
            ],
            womens_double: [
              [{ id: 17, name: 'Laura' },    { id: 18, name: 'Karina' }],
              [{ id: 31, name: 'Jéssica' },  { id: 32, name: 'Daniela' }]
            ],
            mixed_single: [
              { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
              { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
            ]
          },
          matches: {
            mens_single: [[1, 16], [2, 15]],
            womens_double: [[[17, 18], [31, 32]]],
            mixed_single: [[1, 34], [5, 33]]
          }
        }

        tournament_solution = described_class.new(params).call

        json = tournament_solution.as_json.deep_symbolize_keys

        expect(json).to eq(
          {
            tournament: {
              settings: {
                match_time: 60,
                break_time: 30,
                courts: [0, 1],
                single_day_matches: false
              },
              groups: [
                {
                  category: 'mens_single',
                  matches: [
                    { id: 1, round: 0, playing: 'João vs. Fábio' },
                    { id: 2, round: 0, playing: 'Marcelo vs. Bruno' },
                    { id: 3, round: 1, playing: 'M1 vs. M2' }
                  ]
                },
                {
                  category: 'womens_double',
                  matches: [
                    { id: 1, round: 0, playing: 'Laura e Karina vs. Jéssica e Daniela' }
                  ]
                },
                {
                  category: 'mixed_single',
                  matches: [
                    { id: 1, round: 0, playing: 'João vs. Cleber' },
                    { id: 2, round: 0, playing: 'Carlos vs. Erica' },
                    { id: 3, round: 1, playing: 'M1 vs. M2' }
                  ]
                }
              ],
              participants: [
                { id: 1, name: 'João' },
                { id: 2, name: 'Marcelo' },
                { id: 5, name: 'Carlos' },
                { id: 15, name: 'Bruno' },
                { id: 16, name: 'Fábio' },
                { id: 17, name: 'Laura' },
                { id: 18, name: 'Karina' },
                { id: 31, name: 'Jéssica' },
                { id: 32, name: 'Daniela' },
                { id: 33, name: 'Erica' },
                { id: 34, name: 'Cleber' }
              ]
            },
            solutions: [
              {
                fixtures: [
                  {
                    match: {
                      id: 1,
                      title: 'João vs. Fábio',
                      category: 'mens_single'
                    },
                    timeslot: {
                      court: 0,
                      slot: '2023-09-09T09:00:00.000-03:00'
                    }
                  },
                  {
                    match: {
                      id: 1,
                      title: 'João vs. Cleber',
                      category: 'mixed_single'
                    },
                    timeslot: {
                      court: 0,
                      slot: '2023-09-09T10:30:00.000-03:00'
                    }
                  },
                  {
                    match: {
                      id: 2,
                      title: 'Marcelo vs. Bruno',
                      category: 'mens_single'
                    },
                    timeslot: {
                      court: 1,
                      slot: '2023-09-09T09:00:00.000-03:00'
                    }
                  },
                  {
                    match: {
                      id: 2,
                      title: 'Carlos vs. Erica',
                      category: 'mixed_single'
                    },
                    timeslot: {
                      court: 1,
                      slot: '2023-09-09T10:00:00.000-03:00'
                    }
                  },
                  {
                    match: {
                      id: 1,
                      title: 'Laura e Karina vs. Jéssica e Daniela',
                      category: 'womens_double'
                    },
                    timeslot: {
                      court: 1,
                      slot: '2023-09-09T11:00:00.000-03:00'
                    }
                  },
                  {
                    match: {
                      id: 3,
                      title: 'M1 vs. M2',
                      category: 'mens_single'
                    },
                    timeslot: {
                      court: 0,
                      slot: '2023-09-09T11:30:00.000-03:00'
                    }
                  },
                  {
                    match: {
                      id: 3,
                      title: 'M1 vs. M2',
                      category: 'mixed_single'
                    },
                    timeslot: {
                      court: 1,
                      slot: '2023-09-09T12:00:00.000-03:00'
                    }
                  }
                ]
              }
            ]
          }
        )
      end
    end
  end
end
