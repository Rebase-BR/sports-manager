# frozen_string_literal: true

module SportsManager
  # Public: A available time in a court that can be scheduled
  class Timeslot
    include Comparable

    attr_reader :court, :slot, :date

    alias hour slot

    def initialize(court:, date:, slot:)
      @court = court
      @date = date
      @slot = slot
    end

    # TODO: timezone
    def datetime
      return slot if slot.is_a? Time

      @datetime ||= DateTime.parse("#{date} #{hour}:00:00")
    end

    def <=>(other)
      return false unless instance_of?(other.class)

      datetime <=> other.datetime
    end

    def ==(other)
      instance_of?(other.class) &&
        court == other.court &&
        datetime == other.datetime
    end
  end
end
