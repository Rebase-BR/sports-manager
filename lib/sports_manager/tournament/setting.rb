# frozen_string_literal: true

module SportsManager
  class Tournament
    # Public: The tournament's configurations
    class Setting
      attr_reader :match_time, :break_time, :courts, :tournament_days, :single_day_matches

      def initialize(match_time:, break_time:, courts:, tournament_days:, single_day_matches:)
        @match_time = match_time
        @break_time = break_time
        @courts = courts
        @tournament_days = tournament_days
        @single_day_matches = single_day_matches
      end

      def ==(other)
        return false unless instance_of?(other.class)

        match_time == other.match_time &&
          break_time == other.break_time &&
          courts == other.courts &&
          tournament_days == other.tournament_days &&
          single_day_matches == other.single_day_matches
      end

      def timeslots
        @timeslots ||= tournament_days.flat_map(&method(:build_day_slots))
      end

      def court_list
        @court_list ||= courts.times.to_a
      end

      private

      def build_day_slots(tournament_day)
        tournament_day
          .timeslots(interval: break_time)
          .yield_self { |slots| court_list.product(slots) }
          .map { |(court, slot)| Timeslot.new(court: court, date: tournament_day, slot: slot) }
      end
    end
  end
end
