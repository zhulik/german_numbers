# frozen_string_literal: true

module GermanNumbers
  module Parser
    class Parser
      DIGITS = GermanNumbers::DIGITS.invert

      def parse(string)
        raise Error if string == 'ein'
        parts = string.split(GermanNumbers::DIGITS[1000]).reverse
        k = parts.one? && string.include?(GermanNumbers::DIGITS[1000]) ? 1000 : 1
        parts.inject(0) do |sum, part|
          m = StackMachine.new
          (part.split('').reverse.inject(0, &m.method(:step)) * k).tap do
            k *= 1000
          end + sum
        end
      rescue GermanNumbers::Parser::Error
        raise ArgumentError, "#{string} is no a valid German number"
      end
    end
  end
end