# frozen_string_literal: true

module SportsManager
  class SolutionDrawer
    class Mermaid
      class NodeStyle
        # TODO: Add an algorithms to dynamically create the colors
        COLORS = %w[
          #A9F9A9 #4FF7DE #FF6E41
          #5FAD4E #009BFF #00FF00
          #FF0000 #01FFFE #FFA6FE
          #FFDB66 #006401 #010067
          #95003A #007DB5 #FF00F6
          #FFEEE8 #774D00 #90FB92
          #0076FF #D5FF00 #FF937E
          #6A826C #FF029D #FE8900
          #7A4782 #7E2DD2 #85A900
          #FF0056 #A42400 #00AE7E
          #683D3B #BDC6FF #263400
          #BDD393 #00B917 #9E008E
          #001544 #C28C9F #FF74A3
          #01D0FF #004754 #E56FFE
          #788231 #0E4CA1 #91D0CB
          #BE9970 #968AE8 #BB8800
          #43002C #DEFF74 #00FFC6
          #FFE502 #620E00 #008F9C
          #98FF52 #7544B1 #B500FF
          #00FF78 #005F39 #6B6882
          #A75740 #A5FFD2 #FFB167
        ].freeze

        attr_reader :elements

        def self.call(elements)
          new(elements).to_params
        end

        def initialize(elements)
          @elements = elements.map(&:to_s)
        end

        def to_params
          { class_definitions: class_definitions, subgraph_colorscheme: subgraph_colorscheme }
        end

        def subgraph_colorscheme
          elements.map do |element|
            node_name = element.upcase
            style_class = element

            "#{node_name}:::#{style_class}"
          end
        end

        def class_definitions
          colorscheme.map do |element, properties|
            attributes = properties
              .map { |property| property.join(':') }
              .join(', ')
            "#{element} #{attributes}"
          end
        end

        def colorscheme
          elements.each_with_index.with_object({}) do |(element, index), scheme|
            node_color = COLORS[index]
            text_color = text_color(node_color)

            scheme[element] = { fill: node_color, color: text_color }
          end
        end

        # Internal: ripoff from stackoverflow
        def text_color(color)
          red, green, blue = color
            .gsub('#', '')
            .chars
            .each_slice(2)
            .map(&:join)
            .map(&:hex)

          formula = (red * 0.299) + (green * 0.587) + (blue * 0.114)

          formula > 186 ? '#000000' : '#FFFFFF'
        end
      end
    end
  end
end
