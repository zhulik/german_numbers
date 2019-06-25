# typed: strict
# frozen_string_literal: true

module GermanNumbers
  module StateMachine
    extend T::Sig

    include Kernel

    class StateError < StandardError
    end

    class State
      extend T::Sig

      sig { returns(Symbol) }
      attr_reader :name

      sig { params(name: Symbol, initial: T::Boolean, final: T::Boolean, unique: T::Boolean).void }
      def initialize(name, initial, final, unique)
        @name = T.let(name, Symbol)
        @initial = T.let(initial, T::Boolean)
        @final = T.let(final, T::Boolean)
        @unique = T.let(unique, T::Boolean)
      end

      sig { returns(T::Boolean) }
      def can_be_initial?
        @initial
      end

      sig { returns(T::Boolean) }
      def final?
        @final
      end

      sig { returns(T::Boolean) }
      def unique?
        @unique
      end
    end

    class Machine
      extend T::Sig

      sig { returns(T::Hash[Symbol, State]) }
      attr_reader :states

      sig { returns(T::Hash[Symbol, T::Array[Symbol]]) }
      attr_reader :transitions

      sig { void }
      def initialize
        @states = T.let({}, T::Hash[Symbol, State])
        @transitions = T.let(Hash.new { [] }, T::Hash[Symbol, T::Array[Symbol]])
      end

      sig { params(state: Symbol, final: T::Boolean, unique: T::Boolean).void }
      def state(state, final: true, unique: false)
        @states[state] = State.new(state, @states.empty?, final, unique)
      end

      sig { params(from: Symbol, to: T.any(Symbol, T::Array[Symbol])).void }
      def transition(from:, to:)
        to = [to].flatten
        validate_state!([from, to].flatten)
        to.each do |s|
          @transitions[from] = T.must(@transitions[from]) << s
        end
      end

      sig { params(states: T::Array[Symbol]).void }
      def validate_state!(states)
        states.each do |state|
          raise StateError, "#{state} is unknown state" unless @states.include?(state)
        end
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    sig { params(field: Symbol, block: T.proc.void).void }
    def state_machine_for(field, &block)
      m = Machine.new
      T.unsafe(m).instance_eval(&block)
      var_name = "@#{field}_state"
      set_name = "#{field}_state="
      history_name = "@#{field}_state_history"

      T.unsafe(self).define_method("#{field}_state") do
        instance_variable_get(var_name)
      end

      T.unsafe(self).define_method(set_name) do |ns|
        state = instance_variable_get(var_name)
        raise StateError, "#{ns} is not possible state after #{state}" unless T.must(m.transitions[state]).include?(ns)
        if instance_variable_get(history_name).include?(ns) && T.must(m.states[ns]).unique?
          raise StateError, "#{ns} is a unique state and has already been taken"
        end

        instance_variable_get(history_name) << ns
        instance_variable_set(var_name, ns)
      end

      T.unsafe(self).define_method("initialize_#{field}") do |initial|
        m.validate_state!([initial])
        raise StateError, "#{initial} is not possible initial state" unless T.must(m.states[initial]).can_be_initial?

        instance_variable_set(history_name, Set.new)
        instance_variable_set(var_name, initial)
      end

      T.unsafe(self).define_method("final_#{field}_state?") do
        T.must(m.states[instance_variable_get(var_name)]).final?
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
