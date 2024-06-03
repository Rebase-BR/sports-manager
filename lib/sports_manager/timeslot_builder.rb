# frozen_string_literal: true

module SportsManager
  # NOTE: maybe change the name since we are not creating a Timeslot object here
  # Public: Builds the possible timeslots as Time objects
  class TimeslotBuilder
    require 'time'
    require 'forwardable'
    extend Forwardable

    attr_reader :tournament_day

    def_delegators :tournament_day, :start_hour, :end_hour, :date

    def self.build(tournament_day:, interval:)
      new(tournament_day: tournament_day, interval: interval).build
    end

    def initialize(tournament_day:, interval:)
      @tournament_day = tournament_day
      @interval = interval
    end

    def build
      time_range.step(interval).map(&Time.method(:at))
    end

    private

    def time_range
      (start_time.to_i..end_time.to_i)
    end

    def interval
      @interval * 60
    end

    def start_time
      parse_time(start_hour)
    end

    def end_time
      parse_time(end_hour)
    end

    def parse_time(time)
      Time.parse("#{date}T#{time}:00:00")
    end
  end
end
