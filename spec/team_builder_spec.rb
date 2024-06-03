# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::TeamBuilder do
  context '#build' do
    it 'returns the teams for a category' do
      category = :mixed_single
      subscriptions = [{ id: 1, name: 'João' }, { id: 2, name: 'Marcelo' }]

      teams = described_class
        .new(category: category, subscriptions: subscriptions)
        .build

      expect(teams).to match_array [
        have_attributes(
          class: SportsManager::SingleTeam,
          category: category,
          participants: match_array([
            have_attributes(class: SportsManager::Participant, id: 1, name: 'João')
          ])
        ),
        have_attributes(
          class: SportsManager::SingleTeam,
          category: category,
          participants: match_array([
            have_attributes(class: SportsManager::Participant, id: 2, name: 'Marcelo')
          ])
        )
      ]
    end

    context 'when multiple matches' do
      it 'returns the teams for the category' do
        category = :mixed_single
        subscriptions = [
          { id: 1, name: 'João' },
          { id: 2, name: 'Marcelo' },
          { id: 15, name: 'Bruno' },
          { id: 16, name: 'Fábio' }
        ]

        teams = described_class
          .new(category: category, subscriptions: subscriptions)
          .build

        expect(teams).to match_array [
          have_attributes(
            class: SportsManager::SingleTeam,
            category: category,
            participants: match_array([
              have_attributes(class: SportsManager::Participant, id: 1, name: 'João')
            ])
          ),
          have_attributes(
            class: SportsManager::SingleTeam,
            category: category,
            participants: match_array([
              have_attributes(class: SportsManager::Participant, id: 2, name: 'Marcelo')
            ])
          ),
          have_attributes(
            class: SportsManager::SingleTeam,
            category: category,
            participants: match_array([
              have_attributes(class: SportsManager::Participant, id: 15, name: 'Bruno')
            ])
          ),
          have_attributes(
            class: SportsManager::SingleTeam,
            category: category,
            participants: match_array([
              have_attributes(class: SportsManager::Participant, id: 16, name: 'Fábio')
            ])
          )
        ]
      end
    end

    context 'when it is a double category' do
      it 'returns the teams for it' do
        category = :mixed_double
        subscriptions = [
          [{ id: 1, name: 'João' }, { id: 2, name: 'Marcelo' }],
          [{ id: 17, name: 'Laura' }, { id: 18, name: 'Karina' }]
        ]

        teams = described_class
          .new(category: category, subscriptions: subscriptions)
          .build

        expect(teams).to match_array [
          have_attributes(
            class: SportsManager::DoubleTeam,
            category: category,
            participants: match_array([
              have_attributes(class: SportsManager::Participant, id: 1, name: 'João'),
              have_attributes(class: SportsManager::Participant, id: 2, name: 'Marcelo')
            ])
          ),
          have_attributes(
            class: SportsManager::DoubleTeam,
            category: category,
            participants: match_array([
              have_attributes(class: SportsManager::Participant, id: 17, name: 'Laura'),
              have_attributes(class: SportsManager::Participant, id: 18, name: 'Karina')
            ])
          )
        ]
      end
    end
  end
end
