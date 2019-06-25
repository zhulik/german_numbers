# typed: strict
# frozen_string_literal: true

module GermanNumbers
  module Parser
    class StackMachine
      extend T::Sig

      extend GermanNumbers::StateMachine

      state_machine_for :stack do
        T.unsafe(self).state :initial, final: false
        T.unsafe(self).state :null, unique: true
        T.unsafe(self).state :eins, unique: true
        T.unsafe(self).state :zehn, unique: true
        T.unsafe(self).state :short_units, unique: true
        T.unsafe(self).state :under_twenty, unique: true
        T.unsafe(self).state :dozens, unique: true
        T.unsafe(self).state :und_keyword, final: false, unique: true
        T.unsafe(self).state :units
        T.unsafe(self).state :hundert_keyword, final: false, unique: true
        T.unsafe(self).state :hundreds

        T.unsafe(self).transition from: :initial, to: %i[units hundert_keyword dozens null eins zehn under_twenty]
        T.unsafe(self).transition from: :dozens, to: %i[und_keyword hundert_keyword]
        T.unsafe(self).transition from: :zehn, to: %i[hundert_keyword short_units]

        T.unsafe(self).transition from: :und_keyword, to: :units
        T.unsafe(self).transition from: :units, to: :hundert_keyword
        T.unsafe(self).transition from: :hundert_keyword, to: :hundreds
        T.unsafe(self).transition from: :hundreds, to: :units
        T.unsafe(self).transition from: :eins, to: :hundert_keyword
        T.unsafe(self).transition from: :short_units, to: :hundert_keyword
        T.unsafe(self).transition from: :under_twenty, to: :hundert_keyword
      end

      SHORT = T.let({
                      'eins' => 1,
                      'sech' => 6,
                      'sieb' => 7
                    }, T::Hash[String, Integer])

      KEYWORDS = T.let({
                         'und' => :und_keyword,
                         'hundert' => :hundert_keyword
                       }, T::Hash[String, Symbol])

      SHORT_UNITS = T.let(Set.new(%w(drei vier fünf sech sieb acht neun)), T::Set[String])

      sig { void }
      def initialize
        initialize_stack(:initial)
        @collector = T.let('', String)
        @k = T.let(1, Integer)
      end

      # rubocop:disable Metrics/MethodLength
      sig { params(result: Integer, letter: String).returns(Integer) }
      def step(result, letter)
        @collector = letter + @collector
        num = SHORT[@collector] || Parser::DIGITS[@collector]
        unless (s = select_state(num, @collector)).nil?
          self.stack_state = s
        end
        if stack_state == :hundert_keyword
          self.stack_state = :hundreds
          @k = 100
        end
        unless (st = KEYWORDS[@collector]).nil?
          self.stack_state = st
          @collector = ''
          return result
        end
        return result if num.nil?

        @collector = ''
        result + num * @k
      end
      # rubocop:enable Metrics/MethodLength

      sig { returns(T::Boolean) }
      def empty?
        @collector.empty?
      end

      private

      sig { params(num: T.nilable(Integer), collector: String).returns(T.nilable(Symbol)) }
      def select_state(num, collector)
        if stack_state == :zehn && SHORT_UNITS.include?(collector)
          :short_units
        elsif collector == 'eins'
          :eins
        elsif collector == 'null'
          :null
        else
          num_state(num)
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      sig { params(num: T.nilable(Integer)).returns(T.nilable(Symbol)) }
      def num_state(num)
        return if num.nil?
        return :zehn if num == 10
        return :units if num >= 1 && num <= 9
        return :under_twenty if num >= 11 && num <= 19
        return :dozens if num >= 20 && num <= 99
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
