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
        interval.reduce(acronym) do |acronym_result, position|
          acronym_result = add_letters_to_acronym(parts, position, max_size, acronym_result)
          acr = join_acronym_parts(acronym_result, parts.size)
          return acr if acronym_complete?(acr, max_size, reference)

          acronym_result
        end
        retry_with_larger_interval(parts, interval, reference, acronym_result)
      end

      def add_letters_to_acronym(parts, position, max_size, acronym_result)
        remain_size = max_size - acronym_result.size
        letters = extract_first_letters(parts, position, remain_size)
        acronym_result.push(*letters)
      end

      def join_acronym_parts(acronym_result, parts_size)
        acronym_result.each_slice(parts_size).reduce(&:zip).join
      end

      def acronym_complete?(acr, max_size, reference)
        acr.size >= max_size && !reference.values.include?(acr)
      end

      def retry_with_larger_interval(parts, interval, reference, acronym_result)
        new_interval = interval.minmax.map(&1.method(:+))
        build_acronym(parts, new_interval, reference, acronym_result)
      end

      def extract_first_letters(parts, position, remain_size)
        parts
          .map { |part| part[position] }
          .compact
          .yield_self { |mapped_letters| mapped_letters.map { |letter| letter[0..remain_size] } }
      end
    end
  end
end
