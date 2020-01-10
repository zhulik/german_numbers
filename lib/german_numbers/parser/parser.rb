# typed: strict
# frozen_string_literal: true

module GermanNumbers
  module Parser
    class ParsingError < StandardError
    end

    class Parser
      extend T::Sig

      extend GermanNumbers::StateMachine
      state_machine_for :order do
        T.unsafe(self).state :initial, final: false
        T.unsafe(self).state :thousands
        T.unsafe(self).state :million_keyword, final: false
        T.unsafe(self).state :millionen_keyword, final: false
        T.unsafe(self).state :million, final: true
        T.unsafe(self).state :millions, final: true
        T.unsafe(self).state :milliarde_keyword, final: false
        T.unsafe(self).state :milliarden_keyword, final: false
        T.unsafe(self).state :billion, final: true
        T.unsafe(self).state :billions, final: true

        T.unsafe(self).transition from: :initial, to: %i[thousands million_keyword millionen_keyword
                                                         milliarde_keyword milliarden_keyword]
        T.unsafe(self).transition from: :thousands, to: %i[million_keyword millionen_keyword milliarde_keyword
                                                           milliarden_keyword]
        T.unsafe(self).transition from: :million_keyword, to: :million
        T.unsafe(self).transition from: :millionen_keyword, to: :millions
        T.unsafe(self).transition from: :milliarde_keyword, to: :billion
        T.unsafe(self).transition from: :milliarden_keyword, to: :billions
        T.unsafe(self).transition from: :million, to: %i[milliarde_keyword milliarden_keyword]
        T.unsafe(self).transition from: :millions, to: %i[milliarde_keyword milliarden_keyword]
      end

      DIGITS = T.let(GermanNumbers::DIGITS.invert, T::Hash[String, Integer])

      ERRORS = T.let(['ein', 'sech', 'sieb', nil, ''], T::Array[T.untyped])

      KEYWORDS = T.let({
                         'Million' => :million_keyword,
                         'Millionen' => :millionen_keyword,
                         'Milliarde' => :milliarde_keyword,
                         'Milliarden' => :milliarden_keyword
                       }, T::Hash[String, Symbol])

      sig { void }
      def initialize
        initialize_order(:initial)
      end

      sig { params(string: String).returns(Integer) }
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
      sig { params(sum: Integer, part: String).returns(Integer) }
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

        raise ParsingError
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
