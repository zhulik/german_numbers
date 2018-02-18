# frozen_string_literal: true

module GermanNumbers
  class StateMachine
    class Error < ArgumentError
    end
    class State
      attr_reader :name

      def initialize(name, initial)
        @name = name
        @initial = initial
      end

      def can_be_initial?
        @initial
      end
    end
    class << self
      attr_reader :states, :transitions

      def state(state, can_be_initial: false)
        @states ||= {}
        @states[state] = State.new(state, can_be_initial)
      end

      def transition(from:, to:)
        validate_state!(from, to)
        @transitions ||= Hash.new { [] }
        @transitions[from] = @transitions[from] << to
      end

      def validate_state!(*states)
        states.each do |state|
          raise Error, "#{state} is unknown state" unless @states.include?(state)
        end
      end

      def transition?(old_state, new_state)
        @transitions[old_state].include?(new_state)
      end

      def can_be_initial?(state)
        @states[state].can_be_initial?
      end
    end

    attr_reader :state

    def initialize(initial)
      self.class.validate_state!(initial)
      raise Error, "#{initial} is not possible initial state" unless self.class.can_be_initial?(initial)
      @state = initial

      self.class.states.each_key do |name|
        define_singleton_method "#{name}?" do |&block|
          # binding.pry if @state == :hundert_keyword
          return false unless @state == name
          block&.call
          true
        end
      end
    end

    def state=(new_state)
      raise Error, "#{new_state} is not possible state after #{@state}" unless self.class.transition?(@state, new_state)
      @state = new_state
    end
  end
end
