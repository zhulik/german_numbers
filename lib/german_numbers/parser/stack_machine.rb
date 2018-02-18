# frozen_string_literal: true

module GermanNumbers
  module Parser
    class StackMachine
      SHORT = {
        'eins' => 1,
        'sech' => 6,
        'sieb' => 7
      }.freeze

      KEYWORDS = {
        'und' => :und_keyword,
        'hundert' => :hundert_keyword
      }.freeze

      def initialize
        @state = SmallNumbersStateMachine.new(:initial)
        @collector = ''
        @multiplier = 1
      end

      def step(result, letter)
        @collector = letter + @collector
        num = SHORT[@collector] || Parser::DIGITS[@collector]
        @state.apply_state!(num, @collector)
        @state.hundert_keyword? do
          @state.state = :hundreds
          @multiplier = 100
        end
        unless KEYWORDS[@collector].nil?
          @state.state = KEYWORDS[@collector]
          @collector = ''
          return result
        end
        return result if num.nil?
        result += num * @multiplier
        @collector = ''
        result
      end

      def empty?
        @collector.empty?
      end

      def finite_state?
        @state.finite_state?
      end
    end
  end
end
