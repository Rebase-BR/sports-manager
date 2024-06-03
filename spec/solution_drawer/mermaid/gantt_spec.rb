# frozen_string_literal: true

RSpec.describe SportsManager::SolutionDrawer::Mermaid::Gantt do
  describe '.draw' do
    it 'initilizes and call draw' do
      configurations = { title: 'Title' }
      instance = instance_double(
        described_class,
        add_configurations: true,
        draw: true
      )

      allow(described_class)
        .to receive(:new)
        .and_return(instance)

      allow(instance)
        .to receive(:add_configurations)
        .with(configurations)
        .and_return(instance)

      expect(described_class.draw(configurations)).to eq true
      expect(instance).to have_received(:add_configurations)
      expect(instance).to have_received(:draw)
    end
  end

  describe '#draw' do
    it 'outputs a gantt chart' do
      configurations = {
        display_mode: :empty,
        title: 'Testing Title',
        date_format: 'DD HH:mm',
        axis_format: '%H',
        tick_interval: '2hours',
        sections: {
          field0: [
            { time: '09/09 09:00', id: 'MX M1', interval: '1h' },
            { time: '09/09 10:00', id: 'MX M2', interval: '1h' },
            { time: '09/09 11:00', id: 'MX M3', interval: '1h' },
            { time: '09/09 12:00', id: 'MX M4', interval: '1h' },
            { time: '09/09 13:00', id: 'MX M5', interval: '1h' },
            { time: '09/09 14:00', id: 'MX M6', interval: '1h' },
            { time: '09/09 15:30', id: 'MX M7', interval: '1h' }
          ]
        }
      }

      gantt_output = <<~GANTT.chomp
        ---
        displayMode:#{' '}
        ---
        gantt
          title Testing Title
          dateFormat DD HH:mm
          axisFormat %H
          tickInterval 2hours

          section field0
            MX M1: 09/09 09:00, 1h
            MX M2: 09/09 10:00, 1h
            MX M3: 09/09 11:00, 1h
            MX M4: 09/09 12:00, 1h
            MX M5: 09/09 13:00, 1h
            MX M6: 09/09 14:00, 1h
            MX M7: 09/09 15:30, 1h
      GANTT

      gantt = described_class.new
      gantt.add_configurations(configurations)

      expect(gantt.draw).to eq gantt_output
    end

    context 'when nothing is set' do
      it 'uses the default configurations' do
        gantt_output = <<~GANTT.chomp
          ---
          displayMode: compact
          ---
          gantt
            title Tournament Schedule
            dateFormat DD/MM HH:mm
            axisFormat %H:%M
            tickInterval 1hour


        GANTT

        gantt = described_class.new

        expect(gantt.draw).to eq gantt_output
      end
    end
  end
end
