# frozen_string_literal: true

module SportsManager
  class TournamentDay
    # Public: Validates tournament day's date and time range
    class Validator
      extend Forwardable

      DateParsingError = Class.new(StandardError) do
        def initialize(date)
          message = "It is not possible to parse Date: #{date}"
          super(message)
        end
      end

      InvalidHour = Class.new(StandardError) do
        def initialize(start_hour, end_hour)
          message = 'start_hour and end_hour must be between 0 and 23. ' \
                    "start_hour: #{start_hour}, end_hour: #{end_hour}"
          super(message)
        end
      end

      MIN_HOUR = 0
      MAX_HOUR = 23

      attr_reader :tournament_day

      def_delegators :tournament_day, :start_hour, :end_hour, :date

      def initialize(tournament_day)
        @tournament_day = tournament_day
      end

      def validate!
        return true if valid?
        raise DateParsingError, date unless parseable_date?

        raise InvalidHour.new(start_hour, end_hour)
      end

      def valid?
        parseable_date? && in_day_range?
      end

      private

      def parseable_date?
        !!parse_date
      end

      def parse_date
        @parse_date ||= begin
          Date.strptime(date, '%Y-%m-%d')
        rescue StandardError
          nil
        end
      end

      def in_day_range?
        [start_hour, end_hour].all?(&method(:day_range?))
      end

      def day_range?(hour)
        hour.between?(MIN_HOUR, MAX_HOUR)
      end
    end
  end
end
