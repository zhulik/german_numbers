# frozen_string_literal: true

module GermanNumbers
  module Parser
    class ParsingError < StandardError
    end

    class Parser
      extend GermanNumbers::StateMachine
      state_machine_for :state do
        state :initial, can_be_initial: true, final: false
        state :thousands
        state :million_keyword, final: false
        state :millionen_keyword, final: false
        state :million, final: true
        state :millions, final: true
        state :milliarde_keyword, final: false
        state :milliarden_keyword, final: false
        state :billion, final: true
        state :billions, final: true

        transition from: :initial, to: %i[thousands million_keyword millionen_keyword
                                          milliarde_keyword milliarden_keyword]
        transition from: :thousands, to: %i[million_keyword millionen_keyword milliarde_keyword milliarden_keyword]
        transition from: :million_keyword, to: :million
        transition from: :millionen_keyword, to: :millions
        transition from: :milliarde_keyword, to: :billion
        transition from: :milliarden_keyword, to: :billions
        transition from: :million, to: %i[milliarde_keyword milliarden_keyword]
        transition from: :millions, to: %i[milliarde_keyword milliarden_keyword]
      end

      DIGITS = GermanNumbers::DIGITS.invert
      ERRORS = ['ein', 'sech', 'sieb', nil, ''].freeze
      KEYWORDS = {
        'Million' => :million_keyword,
        'Millionen' => :millionen_keyword,
        'Milliarde' => :milliarde_keyword,
        'Milliarden' => :milliarden_keyword
      }.freeze

      def initialize
        initialize_state(:initial)
      end

      def parse(string)
        raise GermanNumbers::Parser::ParsingError if ERRORS.include?(string)
        string.split(' ').reverse.inject(0, &method(:parse_part)).tap do
          raise GermanNumbers::Parser::ParsingError unless final_state_state?
        end
      rescue GermanNumbers::Parser::ParsingError, GermanNumbers::StateMachine::StateError
        raise GermanNumbers::Parser::ParsingError, "#{string} is no a valid German number"
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def parse_part(sum, part)
        if initial_state? && KEYWORDS[part].nil?
          thousands_state!
          return parse_part(sum, part)
        end

        unless KEYWORDS[part].nil?
          self.state_state = KEYWORDS[part]
          return sum
        end

        thousands_state? do
          return GermanNumbers::Parser::SmallNumberParser.new.parse(part)
        end

        million_keyword_state? do
          million_state!
        end
        millionen_keyword_state? do
          millions_state!
        end

        milliarde_keyword_state? do
          billion_state!
        end
        milliarden_keyword_state? do
          billions_state!
        end

        million_state? do
          raise GermanNumbers::Parser::ParsingError unless part == 'eine'
          return sum + 1_000_000
        end
        billion_state? do
          raise GermanNumbers::Parser::ParsingError unless part == 'eine'
          return sum + 1_000_000_000
        end

        millions_state? do
          return sum + GermanNumbers::Parser::SmallNumberParser.new(2..999).parse(part) * 1_000_000
        end

        billions_state? do
          return sum + GermanNumbers::Parser::SmallNumberParser.new(2..999).parse(part) * 1_000_000_000
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
