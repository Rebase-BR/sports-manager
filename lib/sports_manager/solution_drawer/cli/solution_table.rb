# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    class CLI
      class SolutionTable
        TIME_TEMPLATE = '%d/%m at %H:%M'

        attr_reader :fixtures

        def initialize(solution)
          @fixtures = solution.fixtures
        end

        def draw
          Table.draw(formatted_fixtures)
        end

        private

        def formatted_fixtures
          fixtures.map(&method(:serialized_fixture))
        end

        def serialized_fixture(fixture)
          {
            category: fixture.category,
            id: fixture.match_id,
            round: fixture.round,
            participants: fixture.title,
            court: fixture.court,
            time: fixture.slot.strftime(TIME_TEMPLATE)
          }
        end
      end
    end
  end
end
