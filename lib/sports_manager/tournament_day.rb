# frozen_string_literal: true

# TODO: revisit this logic
module SportsManager
  # Public: One of the tournament's day with their specific date, duration,
  # and timeslots available
  class TournamentDay
    include Comparable

    MAX_HOUR = 24
    ONE_HOUR = 60

    attr_reader :start_hour, :end_hour, :date

    def self.for(date:, start_hour:, end_hour:)
      new(date: date, start_hour: start_hour, end_hour: end_hour)
    end

    def initialize(date:, start_hour:, end_hour:)
      @date = date.to_s
      @start_hour = start_hour.to_i
      @end_hour = end_hour.to_i
      Validator.new(self).validate!
    end

    def timeslots(interval: ONE_HOUR)
      TimeslotBuilder.build(tournament_day: self, interval: interval)
    end

    def total_time
      @total_time ||= if start_hour <= end_hour
        end_hour - start_hour
      else
        # TODO: maybe remove since we are not workig (yet)
        # with time between two dates (start:20h, end:04h)
        (MAX_HOUR - start_hour) + end_hour
      end
    end

    def <=>(other)
      return unless instance_of?(other.class)

      equality(other).find(-> { 0 }, &:nonzero?)
    end

    private

    def equality(other)
      [
        date <=> other.date,
        start_hour <=> other.start_hour,
        end_hour <=> other.end_hour
      ]
    end
  end
end
