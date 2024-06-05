# frozen_string_literal: true

RSpec.describe SportsManager::SolutionDrawer do
  describe '#none' do
    it 'does nothing' do
      tournament_solution = spy

      drawer = described_class.new(tournament_solution)

      expect(drawer.none).to be_nil
    end
  end

  describe '#mermaid' do
    it 'uses mermaid to draw the solution' do
      tournament_solution = SportsManager::TournamentSolution.new(
        tournament: spy,
        solutions: [spy]
      )
      mermaid = SportsManager::SolutionDrawer::Mermaid

      allow(mermaid).to receive(:draw)

      described_class.new(tournament_solution).mermaid

      expect(mermaid).to have_received(:draw).with(tournament_solution)
    end
  end

  describe '#cli' do
    it 'uses cli to draw the solution' do
      tournament_solution = SportsManager::TournamentSolution.new(
        tournament: spy,
        solutions: [spy]
      )
      cli = SportsManager::SolutionDrawer::CLI

      allow(cli).to receive(:draw)

      described_class.new(tournament_solution).cli

      expect(cli).to have_received(:draw).with(tournament_solution)
    end
  end
end
