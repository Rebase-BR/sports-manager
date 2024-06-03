# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    class Mermaid
      class ByeNode
        extend Forwardable

        attr_reader :fixture

        def_delegators :fixture, :match_id, :category, :title

        def initialize(fixture)
          @fixture = fixture
        end

        def name
          "#{category}_#{match_id}"
        end

        def definition
          "#{name}[\"#{description}\"]:::#{style_class}"
        end

        def style_class
          'court'
        end

        def description
          "#{match_id}\\n#{title}"
        end

        def links?
          false
        end
      end
    end
  end
end
