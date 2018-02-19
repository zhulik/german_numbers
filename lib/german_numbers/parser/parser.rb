# frozen_string_literal: true

module GermanNumbers
  module Parser
    class ParsingError < StandardError
    end

    class Parser
      DIGITS = GermanNumbers::DIGITS.invert
      ERRORS = ['ein', 'sech', 'sieb', nil, ''].freeze

      def parse(string)
        raise_error!(string) if ERRORS.include?(string)
        parts = string.split('tausend').reverse
        k = parts.one? && string.include?('tausend') ? 1000 : 1
        parts.inject(0) do |sum, part|
          m = StackMachine.new
          (part.split('').reverse.inject(0, &m.method(:step)) * k).tap do
            k *= 1000
            raise_error!(string) if !m.empty? || !m.final_state?
          end + sum
        end
      rescue GermanNumbers::StateMachine::StateError
        raise_error!(string)
      end

      def raise_error!(string)
        raise GermanNumbers::Parser::ParsingError, "#{string} is no a valid German number"
      end
    end
  end
end
