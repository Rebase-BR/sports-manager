# frozen_string_literal: true

RSpec.describe SportsManager::SolutionDrawer::Mermaid::SolutionGantt do
  describe '.draw' do
    it 'initilizes and calls draw' do
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
    it 'outputs a gantt chart' do
      fixtures = [
        instance_double(
          SportsManager::TournamentSolution::Fixture,
          category: :mixed_single,
          match_id: 1,
          court: 0,
          slot: Time.new(2023, 9, 9, 9)
        ),
        instance_double(
          SportsManager::TournamentSolution::Fixture,
          category: :mixed_single,
          match_id: 2,
          court: 1,
          slot: Time.new(2023, 9, 9, 9)
        ),
        instance_double(
          SportsManager::TournamentSolution::Fixture,
          category: :mixed_single,
          match_id: 3,
          court: 0,
          slot: Time.new(2023, 9, 9, 10)
        ),
        instance_double(
          SportsManager::TournamentSolution::Fixture,
          category: :mixed_single,
          match_id: 4,
          court: 1,
          slot: Time.new(2023, 9, 9, 11)
        )
      ]

      solution = SportsManager::TournamentSolution::Solution.new(fixtures)

      gantt_output = <<~GANTT.chomp
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
            MS M3: 09/09 10:00, 1h
          section 1
            MS M2: 09/09 09:00, 1h
            MS M4: 09/09 11:00, 1h
      GANTT

      gantt = described_class.new(solution)

      expect(gantt.draw).to eq(gantt_output)
    end
  end
end
