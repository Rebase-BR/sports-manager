# frozen_string_literal: true

RSpec.describe SportsManager::SolutionDrawer::Mermaid::Graph do
  describe '.draw' do
    it 'initilizes and call draw' do
      configurations = { subgraphs: spy }
      instance = instance_double(
        described_class,
        add_configurations: true,
        draw: true
      )

      allow(described_class)
        .to receive(:new)
        .and_return(instance)

      allow(instance)
        .to receive(:add_configurations)
        .with(configurations)
        .and_return(instance)

      expect(described_class.draw(configurations)).to eq true
      expect(instance).to have_received(:add_configurations)
      expect(instance).to have_received(:draw)
    end
  end

  describe '#draw' do
    it 'outputs a graph with subgraphs' do
      configurations = {
        subgraphs: {
          mixed_single: [
            "mixed_single_1[1\nJoão vs. Cleber\n09/09 09:00]:::court0",
            "mixed_single_2[2\nCarlos vs. Erica\n09/09 10:00]:::court0",
            "mixed_single_3[3\nDaniel vs. Carolina\n09/09 11:00]:::court0",
            "mixed_single_4[4\nLaura vs. Joana\n09/09 12:00]:::court0",
            "mixed_single_5[5\nM1 vs. M2\n09/09 13:00]:::court0",
            "mixed_single_6[6\nM3 vs. M4\n09/09 14:00]:::court0",
            "mixed_single_7[7\nM5 vs. M6\n09/09 15:30]:::court0",
            'mixed_single_1 --> mixed_single_5',
            'mixed_single_2 --> mixed_single_5',
            'mixed_single_3 --> mixed_single_6',
            'mixed_single_4 --> mixed_single_6',
            'mixed_single_5 --> mixed_single_7',
            'mixed_single_6 --> mixed_single_7'
          ]
        }
      }

      graph_output = <<~GRAPH.chomp
        graph LR
        classDef court0 fill:#a9f9a9
        classDef court1 fill:#4ff7de
        classDef court_default fill:#aff7de
        subgraph colorscheme
          direction LR

          COURT_0:::court0
          COURT_1:::court1
          COURT:::court_default
          COURT_0 --- COURT_1 --- COURT
        end
        subgraph mixed_single
          direction LR

          mixed_single_1[1\nJoão vs. Cleber\n09/09 09:00]:::court0
          mixed_single_2[2\nCarlos vs. Erica\n09/09 10:00]:::court0
          mixed_single_3[3\nDaniel vs. Carolina\n09/09 11:00]:::court0
          mixed_single_4[4\nLaura vs. Joana\n09/09 12:00]:::court0
          mixed_single_5[5\nM1 vs. M2\n09/09 13:00]:::court0
          mixed_single_6[6\nM3 vs. M4\n09/09 14:00]:::court0
          mixed_single_7[7\nM5 vs. M6\n09/09 15:30]:::court0
          mixed_single_1 --> mixed_single_5
          mixed_single_2 --> mixed_single_5
          mixed_single_3 --> mixed_single_6
          mixed_single_4 --> mixed_single_6
          mixed_single_5 --> mixed_single_7
          mixed_single_6 --> mixed_single_7
        end
      GRAPH

      graph = described_class.new
      graph.add_configurations(configurations)

      expect(graph.draw).to eq graph_output
    end

    context 'when nothing, besides subgraph, is set' do
      it 'uses the default configurations' do
        configurations = {
          subgraphs: {
            mixed_single: [
              "mixed_single_1[1\nJoão vs. Cleber\n09/09 09:00]:::court0",
              "mixed_single_2[2\nCarlos vs. Erica\n09/09 10:00]:::court0",
              "mixed_single_3[3\nDaniel vs. Carolina\n09/09 11:00]:::court0",
              "mixed_single_4[4\nLaura vs. Joana\n09/09 12:00]:::court0",
              "mixed_single_5[5\nM1 vs. M2\n09/09 13:00]:::court0",
              "mixed_single_6[6\nM3 vs. M4\n09/09 14:00]:::court0",
              "mixed_single_7[7\nM5 vs. M6\n09/09 15:30]:::court0",
              'mixed_single_1 --> mixed_single_5',
              'mixed_single_2 --> mixed_single_5',
              'mixed_single_3 --> mixed_single_6',
              'mixed_single_4 --> mixed_single_6',
              'mixed_single_5 --> mixed_single_7',
              'mixed_single_6 --> mixed_single_7'
            ]
          },
          class_definitions: [
            'color1 fill:#abffcc',
            'color2 fill:#44ccbb',
            'color0 fill:#cc99cc'
          ],
          subgraph_colorscheme: [
            'COURT_0:::color0',
            'COURT_1:::color1',
            'COURT:::color2'
          ]
        }

        graph_output = <<~GRAPH.chomp
          graph LR
          classDef color1 fill:#abffcc
          classDef color2 fill:#44ccbb
          classDef color0 fill:#cc99cc
          subgraph colorscheme
            direction LR

            COURT_0:::color0
            COURT_1:::color1
            COURT:::color2
          end
          subgraph mixed_single
            direction LR

            mixed_single_1[1\nJoão vs. Cleber\n09/09 09:00]:::court0
            mixed_single_2[2\nCarlos vs. Erica\n09/09 10:00]:::court0
            mixed_single_3[3\nDaniel vs. Carolina\n09/09 11:00]:::court0
            mixed_single_4[4\nLaura vs. Joana\n09/09 12:00]:::court0
            mixed_single_5[5\nM1 vs. M2\n09/09 13:00]:::court0
            mixed_single_6[6\nM3 vs. M4\n09/09 14:00]:::court0
            mixed_single_7[7\nM5 vs. M6\n09/09 15:30]:::court0
            mixed_single_1 --> mixed_single_5
            mixed_single_2 --> mixed_single_5
            mixed_single_3 --> mixed_single_6
            mixed_single_4 --> mixed_single_6
            mixed_single_5 --> mixed_single_7
            mixed_single_6 --> mixed_single_7
          end
        GRAPH

        graph = described_class.new
        graph.add_configurations(configurations)

        expect(graph.draw).to eq graph_output
      end
    end
  end
end
