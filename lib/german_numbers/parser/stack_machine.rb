# frozen_string_literal: true

module GermanNumbers
  module Parser
    class StackMachine
      extend GermanNumbers::StateMachine

      state_machine_for :state do
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

      NUM_KEYWORDS = {
        'eins' => :eins,
        'null' => :null
      }.freeze

      SHORT_UNITS = %w(drei vier fünf sech sieb acht neun).freeze

      def initialize
        initialize_state(:initial)
        @collector = ''
        @multiplier = 1
      end

      # rubocop:disable Metrics/MethodLength
      def step(result, letter)
        @collector = letter + @collector
        num = SHORT[@collector] || Parser::DIGITS[@collector]
        apply_state!(num, @collector)
        hundert_keyword? do
          self.state = :hundreds
          @multiplier = 100
        end
        unless KEYWORDS[@collector].nil?
          self.state = KEYWORDS[@collector]
          @collector = ''
          return result
        end
        return result if num.nil?
        result += num * @multiplier
        @collector = ''
        result
      end
      # rubocop:enable Metrics/MethodLength

      def empty?
        @collector.empty?
      end

      private

      def apply_state!(num, collector)
        return self.state = NUM_KEYWORDS[collector] unless NUM_KEYWORDS[collector].nil?
        return self.state = :short_units if zehn? && SHORT_UNITS.include?(collector)

        apply_num_state!(num)
      end

      def apply_num_state!(num)
        self.state = case num
                     when 10 then :zehn
                     when 1..9 then :units
                     when 11..19 then :under_twenty
                     when 20..99 then :dozens
                     end
      end
    end
  end
end
