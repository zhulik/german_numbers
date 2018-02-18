# frozen_string_literal: true

module GermanNumbers
  module Parser
    class SmallNumbersStateMachine < GermanNumbers::StateMachine
      state :initial, can_be_initial: true
      state :null
      state :eins
      state :dozens
      state :und_keyword
      state :units
      state :hundert_keyword
      state :hundreds

      transition from: :initial, to: :units
      transition from: :initial, to: :hundert_keyword
      transition from: :initial, to: :dozens
      transition from: :initial, to: :null
      transition from: :initial, to: :eins

      transition from: :dozens, to: :und_keyword
      transition from: :dozens, to: :hundert_keyword
      transition from: :und_keyword, to: :units
      transition from: :units, to: :hundert_keyword
      transition from: :hundert_keyword, to: :hundreds
      transition from: :hundreds, to: :units
      transition from: :eins, to: :hundert_keyword

      def apply_num_state(num, collector)
        self.state = :null if collector == 'null'
        return self.state = :eins if collector == 'eins'
        self.state = :units if (1..9).cover?(num)
        self.state = :dozens if (20..99).cover?(num)
      end
    end
  end
end
