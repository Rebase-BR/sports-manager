# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::SolutionDrawer::CLI::SolutionTable do
  describe '#draw' do
    it 'draws a solution with its scheduled matches' do
      match = instance_double(
        SportsManager::Match,
        category: :mixed_single,
        id: 1,
        round: 2,
        title: 'João vs. Marcelo'
      )
      timeslot = instance_double(
        SportsManager::Timeslot,
        court: 3,
        slot: Time.new(2023, 9, 9, 9)
      )
      fixtures = [
        SportsManager::TournamentSolution::Fixture.new(
          match: match,
          timeslot: timeslot
        )
      ]
      solution = instance_double(
        SportsManager::TournamentSolution::Solution,
        fixtures: fixtures
      )
      table = <<~TABLE.chomp
          category   | id | round |   participants   | court |      time#{'     '}
        -------------|----|-------|------------------|-------|---------------
        mixed_single | 1  | 2     | João vs. Marcelo | 3     | 09/09 at 09:00
      TABLE

      solution_table = described_class.new(solution)

      expect(solution_table.draw).to eq table
    end
  end
end
