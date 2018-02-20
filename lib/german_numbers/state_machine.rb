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
          raise StateError, "#{state} is unknown state" unless @states.include?(state)
        end
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def state_machine_for(field, &block)
      m = Machine.new
      m.instance_eval(&block)
      var_name = "@#{field}_state"
      set_name = "#{field}_state="
      history_name = "@#{field}_state_history"

      define_method("#{field}_state") do
        instance_variable_get(var_name)
      end

      define_method(set_name) do |ns|
        state = instance_variable_get(var_name)
        raise StateError, "#{ns} is not possible state after #{state}" unless m.transitions[state].include?(ns)
        if instance_variable_get(history_name).include?(ns) && m.states[ns].unique?
          raise StateError, "#{ns} is a unique state and has already been taken"
        end
        instance_variable_get(history_name) << ns
        instance_variable_set(var_name, ns)
      end

      define_method("initialize_#{field}") do |initial|
        m.validate_state!(initial)
        raise StateError, "#{initial} is not possible initial state" unless m.states[initial].can_be_initial?
        instance_variable_set(history_name, Set.new)
        instance_variable_set(var_name, initial)
      end

      define_method("final_#{field}_state?") do
        m.states[instance_variable_get(var_name)].final?
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
