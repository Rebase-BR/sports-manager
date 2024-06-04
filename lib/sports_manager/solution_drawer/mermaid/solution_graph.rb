# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    class Mermaid
      class SolutionGraph
        attr_reader :solution

        STYLE_CLASS_DEFINITION = '%<name> fill:%<fill>, color:%<color>'

        LinkNode = Struct.new(:node_hash) do
          def definition
            "#{node_hash[:previous_name]} --> #{node_hash[:next_name]}"
          end
        end

        def self.draw(solution)
          new(solution).draw
        end

        def initialize(solution)
          @solution = solution
        end

        def draw
          Graph.draw(subgraphs: subgraphs, **node_style)
        end

        private

        def subgraphs
          solution
            .fixtures_dependencies_by_category
            .yield_self(&method(:build_subgraphs))
            .yield_self(&method(:serialize))
        end

        def build_subgraphs(categories_fixtures)
          categories_fixtures
            .transform_values { |fixtures| build_nodes(fixtures) }
            .transform_values { |nodes| (nodes | build_links(nodes)) }
        end

        def build_nodes(fixtures)
          fixtures
            .sort_by(&:match_id)
            .map { |fixture| Node.for(fixture) }
        end

        def build_links(nodes)
          nodes
            .select(&:links?)
            .flat_map { |linked_node| build_link(linked_node, nodes) }
        end

        def build_link(linked_node, nodes)
          new_nodes = nodes
            .select { |node| linked_node.depends_on?(node) }

          new_nodes.map do |previous_node|
            LinkNode.new({ previous_name: previous_node.name, next_name: linked_node.name })
          end
        end

        def serialize(graph)
          graph.transform_values { |nodes| nodes.map(&:definition) }
        end

        def node_style
          courts = solution.courts.map { |n| "court#{n}" }
          NodeStyle.call(courts)
        end
      end
    end
  end
end
