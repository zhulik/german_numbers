# frozen_string_literal: true

module GermanNumbers
  module Parser
    class SmallNumberParser
      extend GermanNumbers::StateMachine
      ERRORS = %w(null eins).freeze

      state_machine_for :state do
        state :initial, can_be_initial: true, final: false
        state :units
        state :tausend_keyword, unique: true, final: false
        state :thousands

        transition from: :initial, to: %i[units tausend_keyword]
        transition from: :tausend_keyword, to: :thousands
      end

      def initialize(max = 999_999)
        initialize_state(:initial)
        @max = max
        @k = 1
      end

      def parse(string)
        string.split(/(tausend)/).reverse.inject(0, &method(:parse_part))
      end

      private

      def parse_part(sum, part)
        if tausend_keyword_state?
          thousands_state!
          @k *= 1000
        end
        if part == 'tausend'
          tausend_keyword_state!
          return sum
        end
        raise ParsingError if ERRORS.include?(part) && thousands_state?
        parse_number(sum, part)
      end

      def parse_number(sum, part)
        m = StackMachine.new
        (sum + part.split('').reverse.inject(0, &m.method(:step)) * @k).tap do |res|
          raise GermanNumbers::Parser::ParsingError if !m.empty? || !m.final_state_state? || res > @max
        end
      end
    end
  end
end
