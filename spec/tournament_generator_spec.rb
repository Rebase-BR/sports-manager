# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::TournamentGenerator do
  it 'adds all configs, matches and subscriptions' do
    params = {
      when: { '2023-09-09': { start: 9, end: 20 } },
      courts: 1,
      game_length: 60,
      rest_break: 30,
      single_day_matches: false,
      subscriptions: {
        mixed_single: [
          { id: 1, name: 'João' },
          { id: 34, name: 'Cleber' },
          { id: 5, name: 'Carlos' },
          { id: 10, name: 'Daniel' },
          { id: 17, name: 'Laura' },
          { id: 25, name: 'Joana' }
        ],
        womens_double: [
          [{ id: 21, name: 'Laura' }, { id: 22, name: 'Karina' }],
          [{ id: 23, name: 'Jéssica' }, { id: 24, name: 'Daniela' }],
          [{ id: 19, name: 'Laura' }, { id: 20, name: 'Karina' }],
          [{ id: 33, name: 'Jéssica' }, { id: 34, name: 'Daniela' }]
        ],
        mens_single: [
          { id: 50, name: 'João' },
          { id: 51, name: 'Marcelo' },
          { id: 52, name: 'Bruno' },
          { id: 55, name: 'Fábio' },
          { id: 59, name: 'Rodrigo' },
          { id: 60, name: 'Carlos' }
        ],
        womens_single: [
          { id: 25, name: 'Joana' },
          { id: 2, name: 'Maria' },
          { id: 15, name: 'Bruna' },
          { id: 16, name: 'Fernanda' },
          { id: 60, name: 'Rosa' },
          { id: 18, name: 'Carla' }
        ]
      },
      matches: {
        mixed_single: [[1, 34], [5, 25], [10, 17]],
        womens_double: [
          [[21, 22], [23, 24]],
          [[19, 20], [33, 34]]
        ],
        mens_single: [[50, 51], [52, 55], [59, 60]],
        womens_single: [[25, 2], [15, 16], [60, 18]]
      }
    }

    tournament_generator =
      described_class.new
        .add_day('2023-09-09', 9, 20)
        .add_subscription(:mixed_single, { id: 1, name: 'João' })
        .add_subscription(:mixed_single, { id: 34, name: 'Cleber' })
        .add_subscription(:mixed_single, { id: 5, name: 'Carlos' })
        .add_subscription(:mixed_single, { id: 10, name: 'Daniel' })
        .add_subscription(:mixed_single, { id: 17, name: 'Laura' })
        .add_subscription(:mixed_single, { id: 25, name: 'Joana' })
        .add_subscriptions_per_category(:womens_double, [
          [{ id: 21, name: 'Laura' }, { id: 22, name: 'Karina' }],
          [{ id: 23, name: 'Jéssica' }, { id: 24, name: 'Daniela' }],
          [{ id: 19, name: 'Laura' }, { id: 20, name: 'Karina' }],
          [{ id: 33, name: 'Jéssica' }, { id: 34, name: 'Daniela' }]
        ])
        .add_subscriptions(
          mens_single: [
            { id: 50, name: 'João' },
            { id: 51, name: 'Marcelo' },
            { id: 52, name: 'Bruno' },
            { id: 55, name: 'Fábio' },
            { id: 59, name: 'Rodrigo' },
            { id: 60, name: 'Carlos' }
          ],
          womens_single: [
            { id: 25, name: 'Joana' },
            { id: 2, name: 'Maria' },
            { id: 15, name: 'Bruna' },
            { id: 16, name: 'Fernanda' },
            { id: 60, name: 'Rosa' },
            { id: 18, name: 'Carla' }
          ]
        )
        .add_match(:mixed_single, [1, 34])
        .add_match(:mixed_single, [5, 25])
        .add_match(:mixed_single, [10, 17])
        .add_matches_per_category(:womens_double,
                                  [
                                    [[21, 22], [23, 24]],
                                    [[19, 20], [33, 34]]
                                  ])
        .add_matches(
          {
            mens_single: [[50, 51], [52, 55], [59, 60]],
            womens_single: [[25, 2], [15, 16], [60, 18]]
          }
        )
        .add_courts(1)
        .add_game_length(60)
        .add_rest_break(30)
        .enable_single_day_matches(false)

    expect(tournament_generator.days).to eq(params[:when])
    expect(tournament_generator.subscriptions).to eq(params[:subscriptions])
    expect(tournament_generator.matches).to eq(params[:matches])
    expect(tournament_generator.courts).to eq(params[:courts])
    expect(tournament_generator.game_length).to eq(params[:game_length])
    expect(tournament_generator.rest_break).to eq(params[:rest_break])
    expect(tournament_generator.single_day_matches).to eq(params[:single_day_matches])
  end

  describe '#add_day' do
    it 'adds a day to the tournament' do
      params = {
        when: { '2023-09-09': { start: 9, end: 20 } }
      }

      tournament_generator =
        described_class.new
          .add_day('2023-09-09', 9, 20)

      expect(tournament_generator.days).to eq(params[:when])
    end
  end

  describe '#add_days' do
    it 'adds multiple days to the tournament' do
      params = {
        when: {
          '2023-09-09': { start: 9, end: 20 },
          '2023-09-10': { start: 9, end: 13 }
        }
      }

      tournament_generator =
        described_class.new
          .add_days(
            {
              '2023-09-09': { start: 9, end: 20 },
              '2023-09-10': { start: 9, end: 13 }
            }
          )

      expect(tournament_generator.days).to eq(params[:when])
    end
  end

  describe '#add_subscription' do
    it 'adds a subscription to the tournament' do
      params = {
        subscriptions: {
          mixed_single: [{ id: 1, name: 'João' }]
        }
      }

      tournament_generator =
        described_class.new
          .add_subscription(:mixed_single, { id: 1, name: 'João' })

      expect(tournament_generator.subscriptions).to eq(params[:subscriptions])
    end
  end

  describe '#add_subscriptions_per_category' do
    it 'adds multiple subscriptions to the tournament' do
      params = {
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },
            { id: 5, name: 'Carlos' }
          ]
        }
      }

      tournament_generator =
        described_class.new
          .add_subscriptions_per_category(:mixed_single, [
            { id: 1, name: 'João' },
            { id: 5, name: 'Carlos' }
          ])

      expect(tournament_generator.subscriptions).to eq(params[:subscriptions])
    end
  end

  describe '#add_subscriptions' do
    it 'adds multiple subscriptions to the tournament' do
      params = {
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },
            { id: 5, name: 'Carlos' }
          ],
          womens_single: [
            { id: 10, name: 'Laura' },
            { id: 17, name: 'Karina' }
          ]
        }
      }

      tournament_generator =
        described_class.new
          .add_subscriptions(
            mixed_single: [
              { id: 1, name: 'João' },
              { id: 5, name: 'Carlos' }
            ],
            womens_single: [
              { id: 10, name: 'Laura' },
              { id: 17, name: 'Karina' }
            ]
          )

      expect(tournament_generator.subscriptions).to eq(params[:subscriptions])
    end
  end

  describe '#add_match' do
    it 'adds a match to the tournament' do
      params = {
        matches: {
          mixed_single: [[1, 5]]
        }
      }

      tournament_generator =
        described_class.new
          .add_match(:mixed_single, [1, 5])

      expect(tournament_generator.matches).to eq(params[:matches])
    end
  end

  describe '#add_matches_per_category' do
    it 'adds multiple matches to the tournament' do
      params = {
        matches: {
          mixed_single: [[1, 5], [10, 17]]
        }
      }

      tournament_generator =
        described_class.new
          .add_matches_per_category(:mixed_single, [[1, 5], [10, 17]])

      expect(tournament_generator.matches).to eq(params[:matches])
    end
  end

  describe '#add_matches' do
    it 'adds multiple matches to the tournament' do
      params = {
        matches: {
          mixed_single: [[1, 5], [10, 17]],
          womens_single: [[25, 2], [15, 16]]
        }
      }

      tournament_generator =
        described_class.new
          .add_matches(
            mixed_single: [[1, 5], [10, 17]],
            womens_single: [[25, 2], [15, 16]]
          )

      expect(tournament_generator.matches).to eq(params[:matches])
    end
  end

  describe '#add_courts' do
    it 'adds number of courts to the tournament' do
      params = { courts: 2 }

      tournament_generator =
        described_class.new
          .add_courts(2)

      expect(tournament_generator.courts).to eq(params[:courts])
    end
  end

  describe '#add_game_length' do
    it 'adds game length to the tournament' do
      params = { game_length: 60 }

      tournament_generator =
        described_class.new
          .add_game_length(60)

      expect(tournament_generator.game_length).to eq(params[:game_length])
    end
  end

  describe '#add_rest_break' do
    it 'adds rest break to the tournament' do
      params = { rest_break: 30 }

      tournament_generator =
        described_class.new
          .add_rest_break(30)

      expect(tournament_generator.rest_break).to eq(params[:rest_break])
    end
  end

  describe '#enable_single_day_matches' do
    it 'sets single day matches to the tournament' do
      params = { single_day_matches: true }

      tournament_generator =
        described_class.new
          .enable_single_day_matches(true)

      expect(tournament_generator.single_day_matches).to eq(params[:single_day_matches])
    end
  end

  describe '.example' do
    it 'runs an example for a tournament scheduling' do
      instance = instance_double('SportsManager::TournamentGenerator')
      allow(instance).to receive(:call)
      allow(instance).to receive(:add_days).and_return(instance)
      allow(instance).to receive(:add_subscriptions).and_return(instance)
      allow(instance).to receive(:add_matches).and_return(instance)
      allow(instance).to receive(:add_courts).and_return(instance)
      allow(instance).to receive(:add_game_length).and_return(instance)
      allow(instance).to receive(:add_rest_break).and_return(instance)
      allow(instance).to receive(:enable_single_day_matches).and_return(instance)

      expect(described_class).to receive(:new)
        .with(format: :cli)
        .and_return(instance)

      expect(instance).to receive(:call)

      described_class.example
    end

    context 'when receives a type' do
      it 'runs the example based on type' do
        allow(SportsManager::Helper)
          .to receive(:public_send)
          .with(:complex)
          .and_return({ a: 1 })

        instance = instance_double('SportsManager::TournamentGenerator')
        allow(instance).to receive(:call)
        allow(instance).to receive(:add_days).and_return(instance)
        allow(instance).to receive(:add_subscriptions).and_return(instance)
        allow(instance).to receive(:add_matches).and_return(instance)
        allow(instance).to receive(:add_courts).and_return(instance)
        allow(instance).to receive(:add_game_length).and_return(instance)
        allow(instance).to receive(:add_rest_break).and_return(instance)
        allow(instance).to receive(:enable_single_day_matches).and_return(instance)

        expect(described_class).to receive(:new)
          .with(format: :cli)
          .and_return(instance)

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

  describe '#call' do
    before do
      allow($stdout).to receive(:puts)
    end

    context 'when already generated matches are passed' do
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
              { id: 3, name: 'João' }, { id: 6, name: 'Marcelo' }
            ]
          },
          matches: {
            mens_single: [
              { id: 100, participants: [3, 6] }
            ]
          }
        }

        tournament_solution =
          described_class.new
            .add_days(params[:when])
            .add_subscriptions(params[:subscriptions])
            .add_matches(params[:matches])
            .add_courts(params[:courts])
            .add_game_length(params[:game_length])
            .add_rest_break(params[:rest_break])
            .enable_single_day_matches(params[:single_day_matches])
            .call

        solution, = tournament_solution.solutions

        expect(tournament_solution).to be_a SportsManager::TournamentSolution
        expect(solution.fixtures).to match_array [
          have_attributes(
            class: SportsManager::TournamentSolution::Fixture,
            match: have_attributes(
              class: SportsManager::Match,
              category: :mens_single,
              id: 100,
              round: 0,
              depends_on: [],
              team1: have_attributes(
                class: SportsManager::SingleTeam,
                category: :mens_single,
                participants: [
                  have_attributes(class: SportsManager::Participant, id: 3, name: 'João')
                ]
              ),
              team2: have_attributes(
                class: SportsManager::SingleTeam,
                category: :mens_single,
                participants: [
                  have_attributes(class: SportsManager::Participant, id: 6, name: 'Marcelo')
                ]
              )
            ),
            timeslot: have_attributes(
              class: SportsManager::Timeslot,
              court: 0,
              slot: Time.parse('2023-09-09T09:00:00')
            )
          )
        ]
      end
    end

    it 'returns a scheduling solution for tournament' do
      params = {
        when: { '2023-09-09': { start: 9, end: 10 } },
        courts: 1,
        game_length: 60,
        rest_break: 30,
        single_day_matches: false,
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },
            { id: 5, name: 'Carlos' }
          ]
        },
        matches: { mixed_single: [[1, 5]] }
      }

      tournament_solution =
        described_class.new
          .add_days(params[:when])
          .add_subscriptions(params[:subscriptions])
          .add_matches(params[:matches])
          .add_game_length(params[:game_length])
          .add_rest_break(params[:rest_break])
          .add_courts(params[:courts])
          .enable_single_day_matches(params[:single_day_matches])
          .call

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
      drawer_class = SportsManager::SolutionDrawer
      drawer = instance_double(drawer_class, cli: true)

      allow(drawer_class).to receive(:new).and_return(drawer)

      tournament_solution =
        described_class.new
          .add_day('2023-09-09', 9, 10)
          .add_subscriptions(
            {
              mixed_single: [
                { id: 1, name: 'João' },
                { id: 5, name: 'Carlos' }
              ]
            }
          )
          .add_match(:mixed_single, [1, 5])
          .add_game_length(60)
          .add_rest_break(30)
          .add_courts(1)
          .enable_single_day_matches(false)
          .call

      expect(drawer_class).to have_received(:new).with(tournament_solution)
      expect(drawer).to have_received(:cli)
    end

    context 'when there is no solution' do
      it 'returns empty solution' do
        params = {
          when: { '2023-09-09': { start: 9, end: 9 } },
          courts: 1,
          game_length: 60,
          rest_break: 30,
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

        tournament_solution =
          described_class.new
            .add_days(
              params[:when]
            )
            .add_subscriptions(params[:subscriptions])
            .add_matches(params[:matches])
            .add_game_length(params[:game_length])
            .add_rest_break(params[:rest_break])
            .add_courts(params[:courts])
            .enable_single_day_matches(params[:single_day_matches])
            .call

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
          rest_break: 30,
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

        tournament_solution =
          described_class.new
            .add_days(params[:when])
            .add_subscriptions(
              params[:subscriptions]
            )
            .add_matches(params[:matches])
            .add_courts(params[:courts])
            .add_game_length(params[:game_length])
            .add_rest_break(params[:rest_break])
            .enable_single_day_matches(params[:single_day_matches])
            .call

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

    it 'generates matches automatically when no matches are provided' do
      params = {
        when: { '2023-09-09': { start: 9, end: 20 } },
        courts: 2,
        game_length: 60,
        rest_break: 30,
        single_day_matches: true,
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
            { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
            { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
            { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
          ]
        }
      }

      generated_matches = {
        mixed_single: [[1, 34], [5, 33], [10, 29], [17, 25]]
      }
      allow(SportsManager::MatchesGenerator).to receive(:call).and_return(generated_matches)

      tournament_solution = described_class.new
        .add_days(params[:when])
        .add_subscriptions(params[:subscriptions])
        .add_courts(params[:courts])
        .add_game_length(params[:game_length])
        .add_rest_break(params[:rest_break])
        .enable_single_day_matches(params[:single_day_matches])
        .call

      expect(SportsManager::MatchesGenerator).to have_received(:call)

      expect(tournament_solution.tournament.matches[:mixed_single]).to include(
        have_attributes(
          category: :mixed_single,
          participants: [
            have_attributes(id: 1, name: 'João'),
            have_attributes(id: 34, name: 'Cleber')
          ]
        ),
        have_attributes(
          category: :mixed_single,
          participants: [
            have_attributes(id: 5, name: 'Carlos'),
            have_attributes(id: 33, name: 'Erica')
          ]
        ),
        have_attributes(
          category: :mixed_single,
          participants: [
            have_attributes(id: 10, name: 'Daniel'),
            have_attributes(id: 29, name: 'Carolina')
          ]
        ),
        have_attributes(
          category: :mixed_single,
          participants: [
            have_attributes(id: 17, name: 'Laura'),
            have_attributes(id: 25, name: 'Joana')
          ]
        )
      )
    end
  end
  describe '#matches_generator' do
    it 'generates matches when no matches are provided' do
      generator = described_class.new
      generator.subscriptions = {
        mixed_single: [
          { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
          { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
          { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
          { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
        ]
      }

      generated_matches = {
        mixed_single: [[1, 34], [5, 33], [10, 29], [17, 25]]
      }
      allow(SportsManager::MatchesGenerator).to receive(:call).and_return(generated_matches)

      result = generator.send(:matches_generator)

      expect(SportsManager::MatchesGenerator).to have_received(:call).with(generator.subscriptions)

      expect(result).to eq(generated_matches)
    end

    it 'generate matches only for the categories that do not have matches' do
      generator = described_class.new
      generator.subscriptions = {
        mixed_single: [
          { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
          { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
          { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
          { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
        ],
        womens_single: [
          { id: 2, name: 'Maria' }, { id: 15, name: 'Bruna' },
          { id: 16, name: 'Fernanda' }, { id: 18, name: 'Carla' }
        ]
      }
      generator.matches = {
        mixed_single: [[1, 34], [5, 33], [10, 29], [17, 25]]
      }

      generated_matches = {
        womens_single: [[2, 18], [15, 16]]
      }
      allow(SportsManager::MatchesGenerator).to receive(:call).and_return(generated_matches)

      result = generator.send(:matches_generator)

      expect(SportsManager::MatchesGenerator).to have_received(:call).with(
        womens_single: [
          { id: 2, name: 'Maria' },
          { id: 15, name: 'Bruna' },
          { id: 16, name: 'Fernanda' },
          { id: 18, name: 'Carla' }
        ]
      )

      expect(result).to eq(
        mixed_single: [[1, 34], [5, 33], [10, 29], [17, 25]],
        womens_single: [[2, 18], [15, 16]]
      )
    end

    it 'returns provided matches when matches are present' do
      allow(SportsManager::MatchesGenerator).to receive(:call)

      generator = described_class.new
      provided_matches = {
        mixed_single: [[1, 34], [5, 33], [10, 29], [17, 25]]
      }
      generator.matches = provided_matches
      result = generator.send(:matches)

      expect(SportsManager::MatchesGenerator).not_to have_received(:call)

      expect(result).to eq(provided_matches)
    end
  end
end
