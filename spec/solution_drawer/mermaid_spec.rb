# frozen_string_literal: true

RSpec.describe SportsManager::SolutionDrawer::Mermaid do
  describe '.draw' do
    it 'initializes and call draw' do
      tournament_solution = spy
      instance = instance_double(described_class, draw: true)

      allow(described_class)
        .to receive(:new)
        .and_return(instance)

      expect(described_class.draw(tournament_solution)).to eq true
      expect(instance).to have_received(:draw)
    end
  end

  describe '#draw' do
    it 'outputs graph and gantt charts' do
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
        Solutions:
        --------------------------------------------------------------------------------
        Solutions 1
        Gantt:
        ---
        displayMode: compact
        ---
        gantt
          title Tournament Schedule
          dateFormat DD/MM HH:mm
          axisFormat %H:%M
          tickInterval 1hour

          section 0
            MS M1: 09/09 09:00, 1h
        Graph:
        graph LR
        classDef court0 fill:#A9F9A9, color:#000000
        subgraph colorscheme
          direction LR

          COURT0:::court0
        end
        subgraph mixed_single
          direction LR

          mixed_single_1[1\\nJoão vs. Cleber\\n09/09 09:00]:::court0
        end
        --------------------------------------------------------------------------------
        Total solutions: 1
      MESSAGE

      drawer = described_class.new(tournament_solution)
      expect { drawer.draw }
        .to output(message)
        .to_stdout
    end

    context 'when there is no solution' do
      it 'outputs no solution message' do
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
