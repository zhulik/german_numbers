# typed: true
# frozen_string_literal: true

module GermanNumbers
  module Parser
    class SmallNumberParser
      extend GermanNumbers::StateMachine

      state_machine_for :order do
        T.unsafe(self).state :initial, final: false
        T.unsafe(self).state :units
        T.unsafe(self).state :tausend_keyword, unique: true, final: false
        T.unsafe(self).state :thousands

        T.unsafe(self).transition from: :initial, to: %i[units tausend_keyword]
        T.unsafe(self).transition from: :tausend_keyword, to: :thousands
      end

      def initialize(range = 0..999_999)
        initialize_order(:initial)
        @range = range
        @k = 1
      end

      def parse(string)
        string.split(/(tausend)/).reverse.inject(0, &method(:parse_part))
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
        (sum + part.split('').reverse.inject(0, &m.method(:step)) * @k).tap do |res|
          raise ParsingError if !m.empty? || !m.final_stack_state? || !@range.cover?(res)
        end
      end
    end
  end
end
