# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SportsManager::Constraints::MultiCategoryConstraint do
  describe '.for_tournament' do
    it 'sets constraint with participants in multiple categories and their matches' do
      csp = spy
      participant = double
      matches = [double, double]
      tournament = instance_double(
        SportsManager::Tournament,
        match_time: 60,
        break_time: 30,
        multi_tournament_participants: [participant]
      )
      constraint = instance_double(described_class)

      allow(tournament)
        .to receive(:find_participant_matches)
        .with(participant)
        .and_return matches

      allow(described_class)
        .to receive(:new)
        .with(
          target_participant: participant,
          matches: matches,
          match_time: 60,
          break_time: 30
        ).and_return constraint

      described_class.for_tournament(tournament: tournament, csp: csp)

      expect(csp).to have_received(:add_constraint).with(constraint)
    end
  end

  describe '#satisfies?' do
    context 'when all variables are assigned' do
      context 'and matches have different timeslots with interval of <break_time> between them' do
        it 'returns true' do
          match_time = 60
          break_time = 10
          match_a = double('Match A')
          match_b = double('Match B')
          matches = [match_a, match_b]
          target_participant = double('Participant')

          slot_a = Time.parse('2023-10-10T10:00:00')
          slot_b = Time.parse('2023-10-10T11:10:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b
          }

          satisfies = described_class
            .new(
              target_participant: target_participant,
              matches: matches,
              match_time: match_time,
              break_time: break_time
            )
            .satisfies?(assignment)

          expect(satisfies).to eq true
        end
      end

      context 'and matches have different timeslots without interval between them' do
        it 'retuns false' do
          match_time = 60
          break_time = 10
          match_a = double('Match A')
          match_b = double('Match B')
          matches = [match_a, match_b]
          target_participant = double('Participant')

          slot_a = Time.parse('2023-10-10T10:00:00')
          slot_b = Time.parse('2023-10-10T11:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b
          }

          satisfies = described_class
            .new(
              target_participant: target_participant,
              matches: matches,
              match_time: match_time,
              break_time: break_time
            )
            .satisfies?(assignment)

          expect(satisfies).to eq false
        end
      end

      context 'and matches have different timeslots with interval higher than <break_time>' do
        it 'returns true' do
          match_time = 60
          break_time = 10
          match_a = double('Match A')
          match_b = double('Match B')
          matches = [match_a, match_b]
          target_participant = double('Participant')

          slot_a = Time.parse('2023-10-10T10:00:00')
          slot_b = Time.parse('2023-10-10T12:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b
          }

          satisfies = described_class
            .new(
              target_participant: target_participant,
              matches: matches,
              match_time: match_time,
              break_time: break_time
            )
            .satisfies?(assignment)

          expect(satisfies).to eq true
        end
      end

      context 'and matches have same timeslots' do
        it 'returns false' do
          match_time = 60
          break_time = 10
          match_a = double('Match A')
          match_b = double('Match B')
          matches = [match_a, match_b]
          target_participant = double('Participant')

          slot_a = Time.parse('2023-10-10T10:00:00')
          slot_b = Time.parse('2023-10-10T10:00:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b
          }

          satisfies = described_class
            .new(
              target_participant: target_participant,
              matches: matches,
              match_time: match_time,
              break_time: break_time
            )
            .satisfies?(assignment)

          expect(satisfies).to eq false
        end

        context 'in different days' do
          it 'returns true' do
            match_time = 60
            break_time = 10
            match_a = double('Match A')
            match_b = double('Match B')
            matches = [match_a, match_b]
            target_participant = double('Participant')

            slot_a = Time.parse('2023-10-10T10:00:00')
            slot_b = Time.parse('2023-10-11T10:00:00')

            timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
            timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)

            assignment = {
              match_a => timeslot_a,
              match_b => timeslot_b
            }

            satisfies = described_class
              .new(
                target_participant: target_participant,
                matches: matches,
                match_time: match_time,
                break_time: break_time
              )
              .satisfies?(assignment)

            expect(satisfies).to eq true
          end
        end
      end

      context 'when assignment has other matches' do
        it 'ignores them and use only those in constraint' do
          match_time = 60
          break_time = 10
          match_a = double('Match A')
          match_b = double('Match B')
          match_c = double('Match B')
          matches = [match_a, match_b]
          target_participant = double('Participant')

          slot_a = Time.parse('2023-10-10T10:00:00')
          slot_b = Time.parse('2023-10-10T11:10:00')
          slot_c = Time.parse('2023-10-10T10:30:00')

          timeslot_a = SportsManager::Timeslot.new(slot: slot_a, court: spy, date: spy)
          timeslot_b = SportsManager::Timeslot.new(slot: slot_b, court: spy, date: spy)
          timeslot_c = SportsManager::Timeslot.new(slot: slot_c, court: spy, date: spy)

          assignment = {
            match_a => timeslot_a,
            match_b => timeslot_b,
            match_c => timeslot_c
          }

          satisfies = described_class
            .new(
              target_participant: target_participant,
              matches: matches,
              match_time: match_time,
              break_time: break_time
            )
            .satisfies?(assignment)

          expect(satisfies).to eq true
        end
      end
    end

    context 'when not all matches are assigned' do
      it 'retuns true' do
        match_time = 60
        break_time = 10
        match_a = double('Match A')
        match_b = double('Match B')
        matches = [match_a, match_b]
        target_participant = double('Participant')

        assignment = { match_a => double }

        satisfies  = described_class
          .new(target_participant: target_participant, matches: matches, match_time: match_time, break_time: break_time)
          .satisfies?(assignment)

        expect(satisfies).to eq true
      end
    end
  end
end
