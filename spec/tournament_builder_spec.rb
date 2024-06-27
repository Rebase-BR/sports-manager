# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::TournamentBuilder do
  describe 'configurations' do
    it 'instantiate with default properties' do
      builder = described_class.new

      expect(builder.configurations).to include(
        {
          courts: 1,
          match_time: 60,
          break_time: 10,
          single_day_matches: false
        }
      )
    end
  end

  describe '#build' do
    it 'builds a tournament' do
      builder = described_class.new

      settings = SportsManager::Tournament::Setting.new(
        courts: 1,
        match_time: 60,
        break_time: 10,
        single_day_matches: false,
        tournament_days: []
      )

      tournament = SportsManager::Tournament.new(settings: settings, groups: [])

      expect(builder.build).to eq tournament
    end

    context 'when subscriptions, matches, and configurations are added' do
      it 'builds tournament with those properties' do
        tournament_class = SportsManager::Tournament
        settings_class = SportsManager::Tournament::Setting
        group_class = SportsManager::Group
        team_class = SportsManager::SingleTeam
        participant_class = SportsManager::Participant
        match_class = SportsManager::Match

        builder = described_class.new

        builder
          .add_matches({ mixed_single: [[1, 2]] })
          .add_subscriptions({
            mixed_single: [
              { id: 1, name: 'João' },
              { id: 2, name: 'Maria' }
            ]
          })
          .add_configurations({
            courts: 2,
            match_time: 90,
            break_time: 15,
            single_day_matches: true
          })
          .add_schedule({ '2023-10-10': { start: 10, end: 15 } })

        tournament = builder.build

        expect(tournament).to have_attributes(
          class: tournament_class,
          settings: have_attributes(
            class: settings_class,
            courts: 2,
            match_time: 90,
            break_time: 15,
            single_day_matches: true,
            tournament_days: match_array([
              have_attributes(date: '2023-10-10', start_hour: 10, end_hour: 15)
            ])
          )
        )
        expect(tournament).to have_attributes(
          groups: a_collection_including(
            have_attributes(
              class: group_class,
              category: :mixed_single,
              teams: a_collection_including(
                have_attributes(
                  class: team_class,
                  participants: a_collection_including(
                    have_attributes(
                      class: participant_class,
                      id: 1,
                      name: 'João'
                    )
                  )
                ),
                have_attributes(
                  class: team_class,
                  participants: a_collection_including(
                    have_attributes(
                      class: participant_class,
                      id: 2,
                      name: 'Maria'
                    )
                  )
                )
              ),
              all_matches: a_collection_including(
                have_attributes(
                  class: match_class,
                  team1: have_attributes(
                    class: team_class,
                    participants: a_collection_including(
                      have_attributes(
                        class: participant_class,
                        id: 1,
                        name: 'João'
                      )
                    )
                  ),
                  team2: have_attributes(
                    class: team_class,
                    participants: a_collection_including(
                      have_attributes(
                        class: participant_class,
                        id: 2,
                        name: 'Maria'
                      )
                    )
                  )
                )
              )
            )
          )
        )
      end

      context 'when is set for double matches' do
        it 'builds tournament with those properties' do
          tournament_class = SportsManager::Tournament
          settings_class = SportsManager::Tournament::Setting
          group_class = SportsManager::Group
          team_class = SportsManager::DoubleTeam
          participant_class = SportsManager::Participant
          match_class = SportsManager::Match

          builder = described_class.new

          builder
            .add_matches({ mixed_double: [[[1, 34], [5, 33]]] })
            .add_subscriptions({
              mixed_double: [
                [{ id: 1, name: 'João' }, { id: 34, name: 'Cleber' }],
                [{ id: 5, name: 'Carlos' }, { id: 33, name: 'Erica' }]
              ]
            })

          tournament = builder.build

          expect(tournament).to have_attributes(
            class: tournament_class,
            settings: have_attributes(
              class: settings_class,
              courts: 1,
              match_time: 60,
              break_time: 10,
              single_day_matches: false,
              tournament_days: be_empty
            )
          )
          expect(tournament).to have_attributes(
            groups: a_collection_including(
              have_attributes(
                class: group_class,
                category: :mixed_double,
                teams: a_collection_including(
                  have_attributes(
                    class: team_class,
                    participants: a_collection_including(
                      have_attributes(
                        class: participant_class,
                        id: 1,
                        name: 'João'
                      ),
                      have_attributes(
                        class: participant_class,
                        id: 34,
                        name: 'Cleber'
                      )
                    )
                  ),
                  have_attributes(
                    class: team_class,
                    participants: a_collection_including(
                      have_attributes(
                        class: participant_class,
                        id: 5,
                        name: 'Carlos'
                      ),
                      have_attributes(
                        class: participant_class,
                        id: 33,
                        name: 'Erica'
                      )
                    )
                  )
                ),
                all_matches: a_collection_including(
                  have_attributes(
                    class: match_class,
                    team1: have_attributes(
                      class: team_class,
                      participants: a_collection_including(
                        have_attributes(
                          class: participant_class,
                          id: 1,
                          name: 'João'
                        ),
                        have_attributes(
                          class: participant_class,
                          id: 34,
                          name: 'Cleber'
                        )
                      )
                    ),
                    team2: have_attributes(
                      class: team_class,
                      participants: a_collection_including(
                        have_attributes(
                          class: participant_class,
                          id: 5,
                          name: 'Carlos'
                        ),
                        have_attributes(
                          class: participant_class,
                          id: 33,
                          name: 'Erica'
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        end
      end
    end
  end

  describe '#add_matches' do
    it 'adds a matches for multiple categories' do
      builder = described_class.new

      matches = { cat1: [[1, 2], [3, 4]], cat2: [[5, 6], [7, 8]] }
      builder.add_matches(matches)

      expect(builder.matches).to eq matches
    end
  end

  describe '#add_match' do
    it 'adds matches for a single category' do
      builder = described_class.new

      builder.add_match(category: :cat1, category_matches: [[1, 2], [3, 4]])

      expect(builder.matches).to eq({ cat1: [[1, 2], [3, 4]] })
    end
  end

  describe '#add_subscriptions' do
    it 'adds a participants for multiple categories' do
      builder = described_class.new

      subscriptions = { cat1: [{ id: 1, name: 'João' }, { id: 2, name: 'Maria' }] }

      builder.add_subscriptions(subscriptions)

      expect(builder.subscriptions).to eq subscriptions
    end
  end

  describe '#add_subscription' do
    it 'adds participants for a single category' do
      builder = described_class.new

      builder.add_subscription(
        category: :cat1,
        participants: [{ id: 1, name: 'João' }, { id: 2, name: 'Maria' }]
      )

      expect(builder.subscriptions).to eq(
        {
          cat1: [
            { id: 1, name: 'João' },
            { id: 2, name: 'Maria' }
          ]
        }
      )
    end
  end

  describe '#add_configurations' do
    it 'adds configurations for tournament' do
      builder = described_class.new

      configurations = { break_time: 10, match_time: 60 }

      builder.add_configurations(configurations)

      expect(builder.configurations).to include(configurations)
    end
  end

  describe '#add_configuration' do
    it 'add a configuration for tournament' do
      builder = described_class.new

      builder.add_configuration(key: :break_time, value: 10)

      expect(builder.configurations).to include({ break_time: 10 })
    end
  end

  describe '#add_schedule' do
    it 'adds dates and available times as tournament days' do
      builder = described_class.new

      builder.add_schedule(
        {
          '2023-10-10': { start: 10, end: 15 },
          '2023-10-11': { start: 9, end: 13 }
        }
      )

      expect(builder.tournament_days).to eq [
        SportsManager::TournamentDay.new(
          date: '2023-10-10',
          start_hour: 10,
          end_hour: 15
        ),
        SportsManager::TournamentDay.new(
          date: '2023-10-11',
          start_hour: 9,
          end_hour: 13
        )
      ]
    end
  end

  describe '#add_date' do
    it 'adds date and available time as a tournament day' do
      builder = described_class.new

      builder.add_date(date: '2023-10-10', start_hour: 10, end_hour: 15)

      expect(builder.tournament_days).to eq [
        SportsManager::TournamentDay.new(
          date: '2023-10-10',
          start_hour: 10,
          end_hour: 15
        )
      ]
    end
  end
end
