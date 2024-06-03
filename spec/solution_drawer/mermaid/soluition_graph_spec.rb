# frozen_string_literal: true

RSpec.describe SportsManager::SolutionDrawer::Mermaid::SolutionGraph do
  describe '.draw' do
    it 'initilizes and call draw' do
      solution = spy
      instance = instance_double(described_class, draw: true)

      allow(described_class)
        .to receive(:new)
        .with(solution)
        .and_return(instance)

      expect(described_class.draw(solution)).to eq true
      expect(instance).to have_received(:draw)
    end
  end

  describe '#draw' do
    it 'outputs a graph with categories as subgraphs' do
      category = :mixed_single

      match1 = instance_double(
        SportsManager::Match,
        category: category,
        id: 1,
        title: 'João vs. Marcelo',
        dependencies?: false,
        playable?: true,
        depends_on: []
      )
      match2 = instance_double(
        SportsManager::Match,
        category: category,
        id: 2,
        title: 'José vs. Pedro',
        dependencies?: false,
        playable?: true,
        depends_on: []
      )
      match3 = instance_double(
        SportsManager::Match,
        category: category,
        id: 3,
        title: 'M1 vs. M2',
        dependencies?: true,
        playable?: true,
        depends_on: [match1, match2]
      )

      date = SportsManager::TournamentDay.new(
        date: '2023-09-09',
        start_hour: 9,
        end_hour: 15
      )

      timeslot1 = SportsManager::Timeslot.new(date: date, court: 0, slot: Time.new(2023, 9, 9, 9))
      timeslot2 = SportsManager::Timeslot.new(date: date, court: 1, slot: Time.new(2023, 9, 9, 9))
      timeslot3 = SportsManager::Timeslot.new(date: date, court: 0, slot: Time.new(2023, 9, 9, 10))

      fixture1 = SportsManager::TournamentSolution::Fixture.new(match: match1, timeslot: timeslot1)
      fixture2 = SportsManager::TournamentSolution::Fixture.new(match: match2, timeslot: timeslot2)
      fixture3 = SportsManager::TournamentSolution::Fixture.new(match: match3, timeslot: timeslot3)

      solution = SportsManager::TournamentSolution::Solution.new([fixture1, fixture2, fixture3])

      graph_output = <<~GRAPH.chomp
        graph LR
        classDef court0 fill:#A9F9A9, color:#000000
        classDef court1 fill:#4FF7DE, color:#000000
        subgraph colorscheme
          direction LR

          COURT0:::court0
          COURT1:::court1
        end
        subgraph mixed_single
          direction LR

          mixed_single_1[1\\nJoão vs. Marcelo\\n09/09 09:00]:::court0
          mixed_single_2[2\\nJosé vs. Pedro\\n09/09 09:00]:::court1
          mixed_single_3[3\\nM1 vs. M2\\n09/09 10:00]:::court0
          mixed_single_1 --> mixed_single_3
          mixed_single_2 --> mixed_single_3
        end
      GRAPH

      graph = described_class.new(solution)

      expect(graph.draw).to eq(graph_output)
    end

    context 'when byes are present' do
      it 'outputs a graph with categories as subgraphs' do
        category = :mixed_single

        match1 = instance_double(
          SportsManager::ByeMatch,
          category: category,
          id: 1,
          title: 'João | BYE',
          dependencies?: false,
          playable?: false
        )
        match2 = instance_double(
          SportsManager::ByeMatch,
          category: category,
          id: 2,
          title: 'José | BYE',
          dependencies?: false,
          playable?: false
        )
        match3 = instance_double(
          SportsManager::Match,
          category: category,
          id: 3,
          title: 'M1 vs. M2',
          dependencies?: true,
          playable?: true,
          depends_on: [match1, match2]
        )

        date = SportsManager::TournamentDay.new(
          date: '2023-09-09',
          start_hour: 9,
          end_hour: 15
        )

        timeslot = SportsManager::Timeslot.new(
          court: 0, date: date,
          slot: Time.new(2023, 9, 9, 10)
        )

        fixture = SportsManager::TournamentSolution::Fixture.new(match: match3, timeslot: timeslot)

        solution = SportsManager::TournamentSolution::Solution.new([fixture])

        graph_output = <<~GRAPH.chomp
          graph LR
          classDef court0 fill:#A9F9A9, color:#000000
          subgraph colorscheme
            direction LR

            COURT0:::court0
          end
          subgraph mixed_single
            direction LR

            mixed_single_1["1\\nJoão | BYE"]:::court
            mixed_single_2["2\\nJosé | BYE"]:::court
            mixed_single_3[3\\nM1 vs. M2\\n09/09 10:00]:::court0
            mixed_single_1 --> mixed_single_3
            mixed_single_2 --> mixed_single_3
          end
        GRAPH

        graph = described_class.new(solution)

        expect(graph.draw).to eq(graph_output)
      end
    end
  end
end
