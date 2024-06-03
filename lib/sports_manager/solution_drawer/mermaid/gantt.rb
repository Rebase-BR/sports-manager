# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    class Mermaid
      class Gantt
        extend Forwardable

        attr_reader :configurations

        DISPLAY_MODE = {
          compact: 'compact',
          empty: nil
        }.freeze

        FIELDS = %i[
          display_mode
          title
          date_format
          axis_format
          tick_interval
          sections
        ].freeze

        DEFAULT_CONFIGURATIONS = {
          display_mode: :compact,
          title: 'Tournament Schedule',
          date_format: 'DD/MM HH:mm',
          axis_format: '%H:%M',
          tick_interval: '1hour',
          sections: ''
        }.freeze

        TEMPLATE = <<~GANTT.chomp
          ---
          displayMode: %<display_mode>s
          ---
          gantt
            title %<title>s
            dateFormat %<date_format>s
            axisFormat %<axis_format>s
            tickInterval %<tick_interval>s

          %<sections>s
        GANTT

        TASK_TEMPLATE = '    %<id>s: %<time>s, %<interval>s'

        def self.draw(configurations = {})
          new
            .add_configurations(configurations)
            .draw
        end

        def initialize
          @configurations = {}
        end

        def draw
          format(TEMPLATE, gantt_configurations)
        end

        def add_display_mode(mode = :compact)
          configurations[:display_mode] = DISPLAY_MODE[mode.to_sym]

          self
        end

        def add_title(title)
          configurations[:title] = title

          self
        end

        def add_date_format(format)
          configurations[:date_format] = format

          self
        end

        def add_axis_format(format)
          configurations[:axis_format] = format

          self
        end

        def add_tick_interval(format)
          configurations[:tick_interval] = format

          self
        end

        def add_sections(sections_tasks)
          configurations[:sections] = sections_tasks
            .map { |(section, tasks)| build_section(section, tasks) }
            .join("\n")

          self
        end

        def add_configurations(configurations)
          configurations.slice(*FIELDS).each do |field, value|
            public_send("add_#{field}", value)
          end

          self
        end

        private

        def gantt_configurations
          DEFAULT_CONFIGURATIONS
            .merge(configurations)
            .slice(*FIELDS)
        end

        def build_section(section, tasks)
          section_name = "  section #{section}"
          section_tasks = tasks.map { |fields| format(TASK_TEMPLATE, fields) }

          [section_name, section_tasks].join("\n")
        end
      end
    end
  end
end
