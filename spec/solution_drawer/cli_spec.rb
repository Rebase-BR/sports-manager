# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::SolutionDrawer::CLI do
  describe '.draw' do
    it 'initializes and call draw' do
      instance = spy
      tournament_solution = spy

      allow(described_class).to receive(:new).and_return instance

      described_class.draw(tournament_solution)

      expect(described_class).to have_received(:new).with(tournament_solution)
      expect(instance).to have_received(:draw)
    end
  end

  describe '#draw' do
    it 'outputs a timetable' do
      category = :mixed_single

      participant1 = SportsManager::Participant.new(id: 1, name: 'João')
      participant2 = SportsManager::Participant.new(id: 34, name: 'Cleber')

      team1 = SportsManager::Team.new(participants: [participant1], category: category)
      team2 = SportsManager::Team.new(participants: [participant2], category: category)

      match = SportsManager::Match.new(
        category: :mixed_single,
        id: 1,
        round: 0,
        team1: team1,
        team2: team2
      )
      date = SportsManager::TournamentDay.new(
        date: '2023-09-09',
        start_hour: 9,
        end_hour: 15
      )
      timeslot = SportsManager::Timeslot.new(
        date: date,
        slot: Time.new(2023, 9, 9, 9),
        court: 0
      )

      solutions = [{ match => timeslot }]

      tournament_solution = SportsManager::TournamentSolution.new(
        tournament: spy,
        solutions: solutions
      )

      message = <<~MESSAGE
        Tournament Timetable:

        Solution 1
          category   | id | round |  participants   | court |      time#{'     '}
        -------------|----|-------|-----------------|-------|---------------
        mixed_single | 1  | 0     | João vs. Cleber | 0     | 09/09 at 09:00

        Total solutions: 1
      MESSAGE

      drawer = described_class.new(tournament_solution)
      expect { drawer.draw }
        .to output(message)
        .to_stdout
    end

    context 'when it has byes' do
      it 'does not print bye to timetable' do
        category = :mixed_single

        participant1 = SportsManager::Participant.new(id: 1, name: 'João')
        participant2 = SportsManager::Participant.new(id: 34, name: 'Cleber')

        team1 = SportsManager::Team.new(participants: [participant1], category: category)
        team2 = SportsManager::Team.new(participants: [participant2], category: category)

        bye = SportsManager::ByeMatch.new(category: category)

        match = SportsManager::Match.new(
          category: :mixed_single,
          id: 1,
          round: 0,
          team1: team1,
          team2: team2,
          depends_on: [bye]
        )
        date = SportsManager::TournamentDay.new(
          date: '2023-09-09',
          start_hour: 9,
          end_hour: 15
        )
        timeslot = SportsManager::Timeslot.new(
          date: date,
          slot: Time.new(2023, 9, 9, 9),
          court: 0
        )

        solutions = [{ match => timeslot }]

        tournament_solution = SportsManager::TournamentSolution.new(
          tournament: spy,
          solutions: solutions
        )

        message = <<~MESSAGE
          Tournament Timetable:

          Solution 1
            category   | id | round |  participants   | court |      time#{'     '}
          -------------|----|-------|-----------------|-------|---------------
          mixed_single | 1  | 0     | João vs. Cleber | 0     | 09/09 at 09:00

          Total solutions: 1
        MESSAGE

        drawer = described_class.new(tournament_solution)
        expect { drawer.draw }
          .to output(message)
          .to_stdout
      end
    end

    context 'when there is no solution' do
      it 'returns a no solution message' do
        tournament_solution = SportsManager::TournamentSolution.new(
          tournament: spy,
          solutions: []
        )
        message = "No solution found\n"

        drawer = described_class.new(tournament_solution)

        expect { drawer.draw }
          .to output(message)
          .to_stdout
      end
    end
  end
end
