# frozen_string_literal: true

module SportsManager
  class TournamentSolution
    # Public: A schedule for the participating teams.
    class Solution
      attr_reader :fixtures

      CATEGORY_SEPARATOR = /[_-]/.freeze

      def initialize(fixtures)
        @fixtures = fixtures
      end

      def courts
        fixtures.map(&:court).uniq
      end

      def categories
        fixtures.map(&:category).uniq
      end

      def fixtures_dependencies_by_category
        fixtures_dependencies.uniq.group_by(&:category)
      end

      def acronyms
        categories.reduce({}) do |acronyms, category|
          category_acronym = build_category_acronym(category, 2, acronyms)

          acronyms.merge(category => category_acronym)
        end
      end

      private

      def fixtures_dependencies
        (fixtures | bye_dependencies).flatten.uniq.sort_by(&:match_id)
      end

      def bye_dependencies
        fixtures.flat_map(&:bye_dependencies)
      end

      def build_category_acronym(category, size = 2, reference = {})
        parts = category.to_s.split(CATEGORY_SEPARATOR)
        interval = (0..size)

        build_acronym(parts, interval, reference)
      end

      def build_acronym(parts, interval, reference, acronym = [])
        max_size = interval.max

        interval.reduce(acronym) do |acronym_reduce, position|
          result = update_acronym(acronym_reduce, parts, position, max_size)

          acr = result.each_slice(parts.size).reduce(&:zip).join

          next acr if acr.size < max_size
          break acr unless reference.values.include?(acr)

          new_interval = interval.minmax.map(&1.method(:+))

          acr = build_acronym(parts, new_interval, reference, result)

          break acr
        end
      end

      def update_acronym(acronym, parts, position, max_size)
        remaining_size = max_size - acronym.size
        letters = extract_acronym(parts, position, remaining_size)
        acronym.push(*letters)
      end

      def extract_acronym(parts, position, remain_size)
        parts
          .map { |part| part[position] }
          .compact
          .yield_self { |mapped_letters| mapped_letters.map { |letter| letter[0..remain_size] } }
      end
    end
  end
end
