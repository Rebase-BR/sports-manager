# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    class Mermaid
      class Node
        extend Forwardable
        TIME_TEMPLATE = '%d/%m %H:%M'

        attr_reader :fixture

        def_delegators :fixture, :match_id, :category, :title, :court

        def self.for(fixture)
          node_class = fixture.playable? ? self : ByeNode

          node_class.new(fixture)
        end

        def initialize(fixture)
          @fixture = fixture
        end

        def name
          "#{category}_#{match_id}"
        end

        # Internal: my_node[This is a node]:::awesome_style
        def definition
          "#{name}[#{description}]:::#{style_class}"
        end

        def style_class
          "court#{court}"
        end

        def description
          "#{match_id}\\n#{title}\\n#{slot}"
        end

        def slot
          fixture.slot.strftime(TIME_TEMPLATE)
        end

        def links?
          fixture.dependencies?
        end

        def depends_on?(node)
          fixture.depends_on?(node.fixture)
        end
      end
    end
  end
end
