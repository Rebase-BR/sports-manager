# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    class Mermaid
      class SolutionGantt
        extend Forwardable

        TIME_TEMPLATE = '%d/%m %H:%M'
        TIME_INTERVAL = '1h' # TODO: make it dynamic

        attr_reader :solution

        def_delegators :solution, :fixtures, :acronyms

        def self.draw(solution)
          new(solution).draw
        end

        def initialize(solution)
          @solution = solution
        end

        def draw
          Gantt.draw(sections: sections)
        end

        def sections
          fixtures
            .group_by(&:court)
            .yield_self { |sections_fixtures| build_sections(sections_fixtures) }
        end

        private

        def build_sections(sections_fixtures)
          sections_fixtures.transform_values do |fixtures|
            fixtures.map(&method(:build_task))
          end
        end

        def build_task(fixture)
          category = fixture.category
          match_id = fixture.match_id
          slot = fixture.slot

          category_acronym = acronyms[category].upcase
          id = "#{category_acronym} M#{match_id}"
          interval = TIME_INTERVAL
          time = slot.strftime(TIME_TEMPLATE)

          { id: id, interval: interval, time: time }
        end
      end
    end
  end
end
