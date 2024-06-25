# frozen_string_literal: true

module SportsManager
  # Public: Builds a group with matches, teams, and participants from a payload
  #
  # category      - The matches' category.
  # subscriptions - The players subscribed. Doubles are represented as a nested list.
  # matches       - A list of matches. Each match is represented by a list of
  #                 players that will be participaing in it.
  #
  # Example 1: A Team of one player
  # Mixed single category with subscribed players: João, Marcelo, Bruno, and Fábio.
  # The initial matches will be:
  #   * João vs Fábio
  #   * Marcelo vs Bruno
  #
  #   category: :mixed_single
  #   subscriptions: [
  #     { id: 1, name: "João"},
  #     { id: 2, name: "Marcelo" },
  #     { id: 15, name: 'Bruno' },
  #     { id: 16, name: 'Fábio' }
  #   ]
  #   matches: [
  #     [1,16],
  #     [2,15]
  #   ]
  #
  # Example 2: A team of two players
  # Women's double category with subscribed players: Laura, Karina, Camila,
  # Bruna, Carolina, Patricia, Jéssica, and Daniela.
  #
  # The initial matches will be:
  #   * Laura and Karina vs Jéssica and Daniela
  #   * Camila and Bruna vs Carolina and Patricia
  #
  #   category: :womens_double
  #   subscriptions: [
  #     [{ id: 17, name: 'Laura' },    { id: 18, name: 'Karina' }],
  #     [{ id: 19, name: 'Camila' },   { id: 20, name: 'Bruna' }],
  #     [{ id: 29, name: 'Carolina' }, { id: 30, name: 'Patricia' }],
  #     [{ id: 31, name: 'Jéssica' },  { id: 32, name: 'Daniela' }]
  #   ]
  #   matches: [
  #     [[17, 18], [31, 32]],
  #     [[19, 20], [29, 30]]
  #   ]
  class GroupBuilder
    attr_reader :category, :subscriptions, :matches

    def initialize(category:, subscriptions:, matches:)
      @category = category
      @subscriptions = subscriptions
      @matches = matches
    end

    def build
      Group.new(category: category, matches: builded_matches, teams: teams)
    end

    private

    def builded_matches
      MatchBuilder.new(category: category, matches: matches, teams: teams).build
    end

    def teams
      TeamBuilder.new(category: category, subscriptions: subscriptions).build
    end
  end
end
