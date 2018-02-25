# frozen_string_literal: true

module GermanNumbers
  module Parser
    class ParsingError < StandardError
    end

    class Parser
      extend GermanNumbers::StateMachine
      state_machine_for :order do
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
        initialize_order(:initial)
      end

      def parse(string)
        raise ParsingError if ERRORS.include?(string)
        string.split(' ').reverse.inject(0, &method(:parse_part)).tap do
          raise ParsingError unless final_order_state?
        end
      rescue ParsingError, StateMachine::StateError
        raise ParsingError, "#{string} is not a valid German number"
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def parse_part(sum, part)
        if order_state == :initial && KEYWORDS[part].nil?
          self.order_state = :thousands
          return parse_part(sum, part)
        end

        unless (st = KEYWORDS[part]).nil?
          self.order_state = st
          return sum
        end

        return SmallNumberParser.new.parse(part) if order_state == :thousands

        self.order_state = :million if order_state == :million_keyword
        self.order_state = :millions if order_state == :millionen_keyword
        self.order_state = :billion if order_state == :milliarde_keyword
        self.order_state = :billions if order_state == :milliarden_keyword

        if order_state == :million
          raise ParsingError unless part == 'eine'
          return sum + 1_000_000
        end
        if order_state == :billion
          raise ParsingError unless part == 'eine'
          return sum + 1_000_000_000
        end

        return sum + SmallNumberParser.new(2..999).parse(part) * 1_000_000 if order_state == :millions
        return sum + SmallNumberParser.new(2..999).parse(part) * 1_000_000_000 if order_state == :billions
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
