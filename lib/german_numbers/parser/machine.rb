# frozen_string_literal: true

module GermanNumbers
  module Parser
    class Machine
      SHORT = {
        'eins' => 1,
        'sech' => 6,
        'sieb' => 7
      }.freeze

      def initialize
        @collector = ''
        @prev = 0
        @and = false
        @hundred = false
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/MethodLength
      def step(result, letter)
        @collector = letter + @collector
        num = SHORT[@collector]
        raise Error if !num.nil? && result != 10 && @collector != 'eins'
        num ||= Parser::DIGITS[@collector]
        if @collector == 'und'
          raise Error if @and
          @and = true
        end
        @collector = '' if @collector == 'und' || !num.nil?
        return result if num.nil?
        result += if @prev == 100
                    raise Error unless (1..9).cover?(num)
                    @prev * (num - 1)
                  else
                    num
                  end
        if num == 100
          raise Error if @hundred
          @hundred = true
        end
        @prev = num
        result
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/MethodLength
    end
  end
end
