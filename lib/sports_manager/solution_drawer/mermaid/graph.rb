# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    class Mermaid
      class Graph
        attr_reader :configurations

        FIELDS = %i[
          subgraphs
          class_definitions
          subgraph_colorscheme
        ].freeze

        TEMPLATE = <<~GRAPH.chomp
          graph LR
          %<class_definitions>s
          %<subgraph_colorscheme>s
          %<subgraphs>s
        GRAPH

        SUBGRAPH = <<~GRAPH.chomp
          subgraph %<name>s
            direction LR

            %<nodes>s
          end
        GRAPH

        STYLE = <<~GRAPH.chomp
          classDef %<class_definition>s
        GRAPH

        # TODO: move to class and make dynamic based on input
        DEFAULT_STYLE_CONFIGURATIONS = {
          class_definitions: [
            'court0 fill:#a9f9a9',
            'court1 fill:#4ff7de',
            'court_default fill:#aff7de'
          ],
          subgraph_colorscheme: [
            'COURT_0:::court0',
            'COURT_1:::court1',
            'COURT:::court_default',
            'COURT_0 --- COURT_1 --- COURT'
          ]
        }.freeze

        def self.draw(configurations = {})
          new
            .add_configurations(configurations)
            .draw
        end

        def initialize
          @configurations = {}
        end

        def draw
          format(TEMPLATE, graph_configurations)
        end

        def add_configurations(configurations)
          DEFAULT_STYLE_CONFIGURATIONS
            .merge(configurations)
            .slice(*FIELDS)
            .each { |field, value| public_send("add_#{field}", value) }

          self
        end

        def add_subgraphs(subgraphs)
          configurations[:subgraphs] = subgraphs
            .map { |(name, nodes)| build_subgraph(name, nodes) }
            .join("\n")

          self
        end

        def add_class_definitions(class_definitions)
          configurations[:class_definitions] = class_definitions
            .map { |class_definition| format(STYLE, class_definition: class_definition) }
            .join("\n")

          self
        end

        def add_subgraph_colorscheme(subgraph_colorscheme)
          nodes = subgraph_colorscheme.join("\n  ")
          colorscheme = format(SUBGRAPH, name: 'colorscheme', nodes: nodes)

          configurations[:subgraph_colorscheme] = colorscheme

          self
        end

        private

        def graph_configurations
          configurations.slice(*FIELDS)
        end

        def build_subgraph(name, nodes)
          subgraph_nodes = nodes.join("\n  ")

          format(SUBGRAPH, name: name, nodes: subgraph_nodes)
        end
      end
    end
  end
end
