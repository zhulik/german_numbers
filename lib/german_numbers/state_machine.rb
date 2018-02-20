# frozen_string_literal: true

module GermanNumbers
  module StateMachine
    class StateError < StandardError
    end
    class State
      attr_reader :name

      def initialize(name, initial, final, unique)
        @name = name
        @initial = initial
        @final = final
        @unique = unique
      end

      def can_be_initial?
        @initial
      end

      def final?
        @final
      end

      def unique?
        @unique
      end
    end

    class Machine
      attr_reader :states, :transitions

      def initialize
        @states = {}
        @transitions = Hash.new { [] }
      end

      def state(state, can_be_initial: false, final: true, unique: false)
        @states[state] = State.new(state, can_be_initial, final, unique)
      end

      def transition(from:, to:)
        to = [to].flatten
        validate_state!(from, *to)
        to.each do |s|
          @transitions[from] = @transitions[from] << s
        end
      end

      def validate_state!(*states)
        states.each do |state|
          raise GermanNumbers::StateMachine::StateError, "#{state} is unknown state" unless @states.include?(state)
        end
      end

      def transition?(old_state, new_state)
        @transitions[old_state].include?(new_state)
      end

      def can_be_initial?(state)
        @states[state].can_be_initial?
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def state_machine_for(field, &block)
      m = Machine.new
      m.instance_eval(&block)

      define_method("#{field}_state=") do |ns|
        return if ns.nil?
        unless m.transition?(send("#{field}_state"), ns)
          raise GermanNumbers::StateMachine::StateError, "#{ns} is not possible state after #{send("#{field}_state")}"
        end
        if instance_variable_get("@#{field}_state_history").include?(ns) && m.states[ns].unique?
          raise GermanNumbers::StateMachine::StateError, "#{ns} is a unique and has already been taken"
        end
        instance_variable_get("@#{field}_state_history") << ns
        instance_variable_set("@#{field}_state", ns)
      end

      define_method("#{field}_state") do
        instance_variable_get("@#{field}_state")
      end

      define_method("initialize_#{field}") do |initial|
        m.validate_state!(initial)
        instance_variable_set("@#{field}_state_history", Set.new)
        unless m.can_be_initial?(initial)
          raise GermanNumbers::StateMachine::StateError, "#{initial} is not possible initial state"
        end
        instance_variable_set("@#{field}_state", initial)
      end

      define_method("final_#{field}_state?") do
        m.states[send("#{field}_state")].final?
      end

      m.states.each_key do |st|
        define_method("#{st}_state?") do |&blk|
          return false unless send("#{field}_state") == st
          blk&.call
          true
        end

        define_method("#{st}_state!") do
          send("#{field}_state=", st)
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
