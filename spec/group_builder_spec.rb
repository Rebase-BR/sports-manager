# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::GroupBuilder do
  describe '#build' do
    it 'returns a tournament group' do
      category = :mixed_single
      matches = [[1, 34]]
      subscriptions = [{ id: 1, name: 'João' }, { id: 34, name: 'Cleber' }]

      match_class = SportsManager::Match
      team_class = SportsManager::SingleTeam
      participant_class = SportsManager::Participant

      group = described_class.new(category: category, subscriptions: subscriptions, matches: matches).build

      expect(group.category).to eq :mixed_single
      expect(group.participants).to match_array [
        have_attributes(class: participant_class, id: 1, name: 'João'),
        have_attributes(class: participant_class, id: 34, name: 'Cleber')
      ]

      expect(group.teams).to match_array [
        have_attributes(
          class: team_class,
          participants: [
            have_attributes(class: participant_class, id: 1, name: 'João')
          ]
        ),
        have_attributes(
          class: team_class,
          participants: [
            have_attributes(class: participant_class, id: 34, name: 'Cleber')
          ]
        )
      ]

      expect(group.initial_matches).to match_array [
        have_attributes(
          class: match_class,
          category: category,
          participants: [
            have_attributes(class: participant_class, id: 1, name: 'João'),
            have_attributes(class: participant_class, id: 34, name: 'Cleber')
          ],
          teams: [
            have_attributes(
              class: team_class,
              participants: [
                have_attributes(class: participant_class, id: 1, name: 'João')
              ]
            ),
            have_attributes(
              class: team_class,
              participants: [
                have_attributes(class: participant_class, id: 34, name: 'Cleber')
              ]
            )
          ]
        )
      ]
    end

    context 'when multiple matches and subscriptions' do
      it 'returns a tournament group' do
        category = :mixed_single
        matches = [[1, 34], [5, 33]]
        subscriptions = [
          { id: 1, name: 'João' },
          { id: 5,  name: 'Carlos' },
          { id: 33, name: 'Erica' },
          { id: 34, name: 'Cleber' }
        ]

        match_class = SportsManager::Match
        team_class = SportsManager::SingleTeam
        participant_class = SportsManager::Participant

        group = described_class.new(category: category, subscriptions: subscriptions, matches: matches).build

        expect(group.category).to eq :mixed_single
        expect(group.participants).to match_array [
          have_attributes(class: participant_class, id: 1, name: 'João'),
          have_attributes(class: participant_class, id: 5, name: 'Carlos'),
          have_attributes(class: participant_class, id: 33, name: 'Erica'),
          have_attributes(class: participant_class, id: 34, name: 'Cleber')
        ]

        expect(group.teams).to match_array [
          have_attributes(
            class: team_class,
            participants: [
              have_attributes(class: participant_class, id: 1, name: 'João')
            ]
          ),
          have_attributes(
            class: team_class,
            participants: [
              have_attributes(class: participant_class, id: 5, name: 'Carlos')
            ]
          ),
          have_attributes(
            class: team_class,
            participants: [
              have_attributes(class: participant_class, id: 33, name: 'Erica')
            ]
          ),
          have_attributes(
            class: team_class,
            participants: [
              have_attributes(class: participant_class, id: 34, name: 'Cleber')
            ]
          )
        ]

        expect(group.initial_matches).to match_array [
          have_attributes(
            class: match_class,
            category: category,
            participants: [
              have_attributes(class: participant_class, id: 1, name: 'João'),
              have_attributes(class: participant_class, id: 34, name: 'Cleber')
            ],
            teams: [
              have_attributes(
                class: team_class,
                participants: [
                  have_attributes(class: participant_class, id: 1, name: 'João')
                ]
              ),
              have_attributes(
                class: team_class,
                participants: [
                  have_attributes(class: participant_class, id: 34, name: 'Cleber')
                ]
              )
            ]
          ),
          have_attributes(
            class: match_class,
            category: category,
            participants: [
              have_attributes(class: participant_class, id: 5, name: 'Carlos'),
              have_attributes(class: participant_class, id: 33, name: 'Erica')
            ],
            teams: [
              have_attributes(
                class: team_class,
                participants: [
                  have_attributes(class: participant_class, id: 5, name: 'Carlos')
                ]
              ),
              have_attributes(
                class: team_class,
                participants: [
                  have_attributes(class: participant_class, id: 33, name: 'Erica')
                ]
              )
            ]
          )
        ]
      end
    end

    context 'when teams are doubles' do
      it 'returns a tournament group' do
        category = :mixed_double
        matches = [
          [[1, 34], [5, 33]]
        ]
        subscriptions = [
          [{ id: 1, name: 'João' }, { id: 34, name: 'Cleber' }],
          [{ id: 5, name: 'Carlos' }, { id: 33, name: 'Erica' }]
        ]

        match_class = SportsManager::Match
        team_class = SportsManager::DoubleTeam
        participant_class = SportsManager::Participant

        group = described_class.new(category: category, subscriptions: subscriptions, matches: matches).build

        expect(group.category).to eq :mixed_double
        expect(group.participants).to match_array [
          have_attributes(class: participant_class, id: 1, name: 'João'),
          have_attributes(class: participant_class, id: 5, name: 'Carlos'),
          have_attributes(class: participant_class, id: 33, name: 'Erica'),
          have_attributes(class: participant_class, id: 34, name: 'Cleber')
        ]

        expect(group.teams).to match_array [
          have_attributes(
            class: team_class,
            participants: [
              have_attributes(class: participant_class, id: 1, name: 'João'),
              have_attributes(class: participant_class, id: 34, name: 'Cleber')
            ]
          ),
          have_attributes(
            class: team_class,
            participants: [
              have_attributes(class: participant_class, id: 5, name: 'Carlos'),
              have_attributes(class: participant_class, id: 33, name: 'Erica')
            ]
          )
        ]

        expect(group.initial_matches).to match_array [
          have_attributes(
            class: match_class,
            category: category,
            participants: [
              have_attributes(class: participant_class, id: 1, name: 'João'),
              have_attributes(class: participant_class, id: 34, name: 'Cleber'),
              have_attributes(class: participant_class, id: 5, name: 'Carlos'),
              have_attributes(class: participant_class, id: 33, name: 'Erica')
            ],
            teams: [
              have_attributes(
                class: team_class,
                participants: [
                  have_attributes(class: participant_class, id: 1, name: 'João'),
                  have_attributes(class: participant_class, id: 34, name: 'Cleber')
                ]
              ),
              have_attributes(
                class: team_class,
                participants: [
                  have_attributes(class: participant_class, id: 5, name: 'Carlos'),
                  have_attributes(class: participant_class, id: 33, name: 'Erica')
                ]
              )
            ]
          )
        ]
      end
    end
  end
end
