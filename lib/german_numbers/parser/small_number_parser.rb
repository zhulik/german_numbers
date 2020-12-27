# frozen_string_literal: true

module GermanNumbers
  module Parser
    class SmallNumberParser
      extend GermanNumbers::StateMachine

      state_machine_for :order do
        state :initial, final: false
        state :units
        state :tausend_keyword, unique: true, final: false
        state :thousands

        transition from: :initial, to: %i[units tausend_keyword]
        transition from: :tausend_keyword, to: :thousands
      end

      def initialize(range = 0..999_999)
        initialize_order(:initial)
        @range = range
        @k = 1
      end

      def parse(string)
        string.split(/(tausend)/).reverse.inject(0) { parse_part(_1, _2) }
      end

      private

      def parse_part(sum, part)
        if order_state == :tausend_keyword
          self.order_state = :thousands
          @k *= 1000
        end
        if part == 'tausend'
          self.order_state = :tausend_keyword
          return sum
        end
        raise ParsingError if %w(eins null).include?(part) && order_state == :thousands

        parse_number(sum, part)
      end

      def parse_number(sum, part)
        m = StackMachine.new
        (sum + part.split('').reverse.inject(0) { m.step(_1, _2) } * @k).tap do
          raise ParsingError if !m.empty? || !m.final_stack_state? || !@range.cover?(_1)
        end
      end
    end
  end
end
