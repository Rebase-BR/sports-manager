# frozen_string_literal: true

module SportsManager
  module Algorithms
    module Filtering
      class NoOverlap
        require 'forwardable'
        extend Forwardable

        attr_reader :tournament

        def_delegators :tournament, :match_time

        def self.for(dependency:, problem: nil) # rubocop:disable Lint/UnusedMethodArgument
          new(dependency)
        end

        def initialize(tournament)
          @tournament = tournament
        end

        def call(values:, assignment_values: [])
          unassigned_values = values - assignment_values

          unassigned_values.reject do |timeslot|
            timeslot_range = to_range(timeslot.slot)

            assignment_values.any? do |assignment_value|
              next if timeslot.court != assignment_value.court

              assigned_range = to_range(assignment_value.slot)

              overlap?(timeslot_range, assigned_range)
            end
          end
        end

        private

        def overlap?(time_range1, time_range2)
          time_range1.cover?(time_range2.first) ||
            time_range2.cover?(time_range1.first)
        end

        def to_range(value)
          end_value = value + (match_time * 60)

          (value...end_value)
        end
      end
    end
  end
end
