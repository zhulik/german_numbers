# frozen_string_literal: true

module GermanNumbers
  module Parser
    class ParsingError < StandardError
    end

    class Parser
      extend GermanNumbers::StateMachine
      state_machine_for :state do
        state :initial, can_be_initial: true, final: false
        state :thousends
        state :million_keyword, final: true
        state :millionen_keyword, final: true
        state :millions
        state :milliarde_keyword, final: true
        state :milliarden_keyword, final: true
        state :billions

        transition from: :initial, to: %i[thousends million_keyword millionen_keyword
                                          milliarde_keyword milliarden_keyword]
      end

      DIGITS = GermanNumbers::DIGITS.invert
      ERRORS = ['ein', 'sech', 'sieb', nil, ''].freeze

      def initialize
        initialize_state(:initial)
      end

      def parse(string)
        raise GermanNumbers::Parser::ParsingError if ERRORS.include?(string)
        parts = string.split(' ')
        GermanNumbers::Parser::SmallNumberParser.new.parse(parts[0])
      rescue GermanNumbers::Parser::ParsingError::GermanNumbers::StateMachine::StateError
        raise GermanNumbers::Parser::ParsingError, "#{string} is no a valid German number"
      end
    end
  end
end
