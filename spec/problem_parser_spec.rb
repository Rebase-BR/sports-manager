# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::ProblemParser do
  describe '.call' do
    it 'instantiate the object with params and invokes call method' do
      instance = instance_double(SportsManager::ProblemParser, call: true)

      allow(described_class)
        .to receive(:new)
        .with({ a: 1 })
        .and_return(instance)

      described_class.call({ a: 1 })

      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    it 'formats the input to a tournament' do
      params = {
        when: { '2023-09-09': { start: 9, end: 10 } },
        courts: 2,
        game_length: 60,
        rest_brake: 30,
        single_day_matches: true,
        subscriptions: {
          mixed_single: [
            { id: 1, name: 'João' },    { id: 5, name: 'Carlos' },
            { id: 10, name: 'Daniel' }, { id: 17, name: 'Laura' },
            { id: 25, name: 'Joana' },  { id: 29, name: 'Carolina' },
            { id: 33, name: 'Erica' },  { id: 34, name: 'Cleber' }
          ]
        },
        matches: {
          mixed_single: [
            [1, 34],
            [5, 33],
            [10, 29],
            [17, 25]
          ]
        }
      }

      match_class = SportsManager::Match
      participant_class = SportsManager::Participant

      tournament = described_class.new(params).call

      expect(tournament.match_time).to eq 60
      expect(tournament.break_time).to eq 30
      expect(tournament.courts).to eq 2
      expect(tournament.single_day_matches).to eq true
      expect(tournament.categories).to eq %i[mixed_single]
      expect(tournament.tournament_days).to eq [
        SportsManager::TournamentDay.new(
          date: '2023-09-09',
          start_hour: 9,
          end_hour: 10
        )
      ]
      expect(tournament.first_round_matches).to match(
        a_hash_including(
          mixed_single: a_collection_including(
            have_attributes(
              class: match_class,
              participants: [
                have_attributes(class: participant_class, id: 1, name: 'João'),
                have_attributes(class: participant_class, id: 34, name: 'Cleber')
              ]
            ),
            have_attributes(
              class: match_class,
              participants: [
                have_attributes(class: participant_class, id: 5, name: 'Carlos'),
                have_attributes(class: participant_class, id: 33, name: 'Erica')
              ]
            ),
            have_attributes(
              class: match_class,
              participants: [
                have_attributes(class: participant_class, id: 10, name: 'Daniel'),
                have_attributes(class: participant_class, id: 29, name: 'Carolina')
              ]
            ),
            have_attributes(
              class: match_class,
              participants: [
                have_attributes(class: participant_class, id: 17, name: 'Laura'),
                have_attributes(class: participant_class, id: 25, name: 'Joana')
              ]
            )
          )
        )
      )
    end

    context 'when multiple tournaments and days to schedule' do
      it 'formats the input to a tournament' do
        params = {
          when: {
            '2023-09-09': { start: 9, end: 20 },
            '2023-09-10': { start: 9, end: 13 }
          },
          courts: 2,
          game_length: 60, # minutos
          rest_brake: 30, # minutos,
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

        team_class = SportsManager::SingleTeam
        double_team_class = SportsManager::DoubleTeam
        match_class = SportsManager::Match
        participant_class = SportsManager::Participant

        tournament = described_class.new(params).call

        expect(tournament.match_time).to eq 60
        expect(tournament.break_time).to eq 30
        expect(tournament.courts).to eq 2
        expect(tournament.single_day_matches).to eq false
        expect(tournament.categories).to eq %i[mens_single womens_double mixed_single]
        expect(tournament.tournament_days).to eq [
          SportsManager::TournamentDay.new(
            date: '2023-09-09',
            start_hour: 9,
            end_hour: 20
          ),
          SportsManager::TournamentDay.new(
            date: '2023-09-10',
            start_hour: 9,
            end_hour: 13
          )

        ]

        expect(tournament.first_round_matches).to match(
          a_hash_including(
            mens_single: a_collection_including(
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 1, name: 'João')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 16, name: 'Fábio')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 1, name: 'João'),
                  have_attributes(class: participant_class, id: 16, name: 'Fábio')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 2, name: 'Marcelo')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 15, name: 'Bruno')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 2, name: 'Marcelo'),
                  have_attributes(class: participant_class, id: 15, name: 'Bruno')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 3, name: 'José')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 14, name: 'Alex')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 3, name: 'José'),
                  have_attributes(class: participant_class, id: 14, name: 'Alex')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 4, name: 'Pedro')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 13, name: 'Joaquim')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 4, name: 'Pedro'),
                  have_attributes(class: participant_class, id: 13, name: 'Joaquim')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 5, name: 'Carlos')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 12, name: 'Henrique')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 5, name: 'Carlos'),
                  have_attributes(class: participant_class, id: 12, name: 'Henrique')
                ]
              ),
              have_attributes(
                class: match_class,
                participants: [
                  have_attributes(class: participant_class, id: 6, name: 'Leandro'),
                  have_attributes(class: participant_class, id: 11, name: 'Marcos')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 7, name: 'Leonardo')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 10, name: 'Daniel')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 7, name: 'Leonardo'),
                  have_attributes(class: participant_class, id: 10, name: 'Daniel')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 8, name: 'Cláudio')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 9, name: 'Alexandre')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 8, name: 'Cláudio'),
                  have_attributes(class: participant_class, id: 9, name: 'Alexandre')
                ]
              )
            ),
            womens_double: a_collection_including(
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: double_team_class,
                  participants: [
                    have_attributes(class: participant_class, id: 17, name: 'Laura'),
                    have_attributes(class: participant_class, id: 18, name: 'Karina')
                  ]
                ),
                team2: have_attributes(
                  class: double_team_class,
                  participants: [
                    have_attributes(class: participant_class, id: 31, name: 'Jéssica'),
                    have_attributes(class: participant_class, id: 32, name: 'Daniela')
                  ]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 17, name: 'Laura'),
                  have_attributes(class: participant_class, id: 18, name: 'Karina'),
                  have_attributes(class: participant_class, id: 31, name: 'Jéssica'),
                  have_attributes(class: participant_class, id: 32, name: 'Daniela')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: double_team_class,
                  participants: [
                    have_attributes(class: participant_class, id: 19, name: 'Camila'),
                    have_attributes(class: participant_class, id: 20, name: 'Bruna')
                  ]
                ),
                team2: have_attributes(
                  class: double_team_class,
                  participants: [
                    have_attributes(class: participant_class, id: 29, name: 'Carolina'),
                    have_attributes(class: participant_class, id: 30, name: 'Patricia')
                  ]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 19, name: 'Camila'),
                  have_attributes(class: participant_class, id: 20, name: 'Bruna'),
                  have_attributes(class: participant_class, id: 29, name: 'Carolina'),
                  have_attributes(class: participant_class, id: 30, name: 'Patricia')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: double_team_class,
                  participants: [
                    have_attributes(class: participant_class, id: 21, name: 'Aline'),
                    have_attributes(class: participant_class, id: 22, name: 'Cintia')
                  ]
                ),
                team2: have_attributes(
                  class: double_team_class,
                  participants: [
                    have_attributes(class: participant_class, id: 27, name: 'Claudia'),
                    have_attributes(class: participant_class, id: 28, name: 'Marina')
                  ]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 21, name: 'Aline'),
                  have_attributes(class: participant_class, id: 22, name: 'Cintia'),
                  have_attributes(class: participant_class, id: 27, name: 'Claudia'),
                  have_attributes(class: participant_class, id: 28, name: 'Marina')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: double_team_class,
                  participants: [
                    have_attributes(class: participant_class, id: 23, name: 'Maria'),
                    have_attributes(class: participant_class, id: 24, name: 'Elis')
                  ]
                ),
                team2: have_attributes(
                  class: double_team_class,
                  participants: [
                    have_attributes(class: participant_class, id: 25, name: 'Joana'),
                    have_attributes(class: participant_class, id: 26, name: 'Izadora')
                  ]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 23, name: 'Maria'),
                  have_attributes(class: participant_class, id: 24, name: 'Elis'),
                  have_attributes(class: participant_class, id: 25, name: 'Joana'),
                  have_attributes(class: participant_class, id: 26, name: 'Izadora')
                ]
              )
            ),
            mixed_single: a_collection_including(
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 1, name: 'João')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 34, name: 'Cleber')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 1, name: 'João'),
                  have_attributes(class: participant_class, id: 34, name: 'Cleber')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 5, name: 'Carlos')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 33, name: 'Erica')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 5, name: 'Carlos'),
                  have_attributes(class: participant_class, id: 33, name: 'Erica')
                ]
              ),
              have_attributes(
                class: match_class,
                team1: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 10, name: 'Daniel')]
                ),
                team2: have_attributes(
                  class: team_class,
                  participants: [have_attributes(class: participant_class, id: 29, name: 'Carolina')]
                ),
                participants: [
                  have_attributes(class: participant_class, id: 10, name: 'Daniel'),
                  have_attributes(class: participant_class, id: 29, name: 'Carolina')
                ]
              ),
              have_attributes(
                class: match_class,
                participants: [
                  have_attributes(class: participant_class, id: 17, name: 'Laura'),
                  have_attributes(class: participant_class, id: 25, name: 'Joana')
                ]
              )
            )
          )
        )
      end
    end
    context 'when matches are not present in the payload' do
      it 'builds automatically' do
        params = {
          when: { '2023-09-09': { start: 9, end: 10 } },
          courts: 2,
          game_length: 60,
          rest_brake: 30,
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

        match_class = SportsManager::Match
        participant_class = SportsManager::Participant

        tournament = described_class.new(params).call

        expect(tournament.match_time).to eq 60
        expect(tournament.break_time).to eq 30
        expect(tournament.courts).to eq 2
        expect(tournament.single_day_matches).to eq true
        expect(tournament.categories).to eq %i[mixed_single]
        expect(tournament.tournament_days).to eq [
          SportsManager::TournamentDay.new(
            date: '2023-09-09',
            start_hour: 9,
            end_hour: 10
          )
        ]
        expect(tournament.first_round_matches).to match(
          a_hash_including(
            mixed_single: a_collection_including(
              have_attributes(
                class: match_class,
                participants: [
                  have_attributes(class: participant_class, id: 1, name: 'João'),
                  have_attributes(class: participant_class, id: 34, name: 'Cleber')
                ]
              ),
              have_attributes(
                class: match_class,
                participants: [
                  have_attributes(class: participant_class, id: 5, name: 'Carlos'),
                  have_attributes(class: participant_class, id: 33, name: 'Erica')
                ]
              ),
              have_attributes(
                class: match_class,
                participants: [
                  have_attributes(class: participant_class, id: 10, name: 'Daniel'),
                  have_attributes(class: participant_class, id: 29, name: 'Carolina')
                ]
              ),
              have_attributes(
                class: match_class,
                participants: [
                  have_attributes(class: participant_class, id: 17, name: 'Laura'),
                  have_attributes(class: participant_class, id: 25, name: 'Joana')
                ]
              )
            )
          )
        )
      end
    end
  end
end
