# typed: false
# frozen_string_literal: true

module GermanNumbers
  module Parser
    class StackMachine
      extend GermanNumbers::StateMachine

      state_machine_for :stack do
        state :initial, can_be_initial: true, final: false
        state :null, unique: true
        state :eins, unique: true
        state :zehn, unique: true
        state :short_units, unique: true
        state :under_twenty, unique: true
        state :dozens, unique: true
        state :und_keyword, final: false, unique: true
        state :units
        state :hundert_keyword, final: false, unique: true
        state :hundreds

        transition from: :initial, to: %i[units hundert_keyword dozens null eins zehn under_twenty]
        transition from: :dozens, to: %i[und_keyword hundert_keyword]
        transition from: :zehn, to: %i[hundert_keyword short_units]

        transition from: :und_keyword, to: :units
        transition from: :units, to: :hundert_keyword
        transition from: :hundert_keyword, to: :hundreds
        transition from: :hundreds, to: :units
        transition from: :eins, to: :hundert_keyword
        transition from: :short_units, to: :hundert_keyword
        transition from: :under_twenty, to: :hundert_keyword
      end

      SHORT = {
        'eins' => 1,
        'sech' => 6,
        'sieb' => 7
      }.freeze

      KEYWORDS = {
        'und' => :und_keyword,
        'hundert' => :hundert_keyword
      }.freeze

      SHORT_UNITS = Set.new(%w(drei vier fünf sech sieb acht neun)).freeze

      def initialize
        initialize_stack(:initial)
        @collector = ''
        @k = 1
      end

      # rubocop:disable Metrics/MethodLength
      def step(result, letter)
        @collector = letter + @collector
        num = SHORT[@collector] || Parser::DIGITS[@collector]
        unless (s = select_state(num, @collector)).nil?
          self.stack_state = s
        end
        if stack_state == :hundert_keyword
          self.stack_state = :hundreds
          @k = 100
        end
        unless (st = KEYWORDS[@collector]).nil?
          self.stack_state = st
          @collector = ''
          return result
        end
        return result if num.nil?

        @collector = ''
        result + num * @k
      end
      # rubocop:enable Metrics/MethodLength

      def empty?
        @collector.empty?
      end

      private

      def select_state(num, collector)
        if stack_state == :zehn && SHORT_UNITS.include?(collector)
          :short_units
        elsif collector == 'eins'
          :eins
        elsif collector == 'null'
          :null
        else
          num_state(num)
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def num_state(num)
        return if num.nil?
        return :zehn if num == 10
        return :units if num >= 1 && num <= 9
        return :under_twenty if num >= 11 && num <= 19
        return :dozens if num >= 20 && num <= 99
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
