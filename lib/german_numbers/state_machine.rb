# frozen_string_literal: true

module GermanNumbers
  class StateMachine
    class Error < ArgumentError
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
    class << self
      attr_reader :states, :transitions

      def state(state, can_be_initial: false, final: true, unique: false)
        @states ||= {}
        @states[state] = State.new(state, can_be_initial, final, unique)
      end

      def transition(from:, to:)
        to = [to].flatten
        validate_state!(from, *to)
        @transitions ||= Hash.new { [] }
        to.each do |s|
          @transitions[from] = @transitions[from] << s
        end
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
      @history = Set.new
      self.class.validate_state!(initial)
      raise Error, "#{initial} is not possible initial state" unless self.class.can_be_initial?(initial)
      @state = initial

      states.each_key do |name|
        define_singleton_method "#{name}?" do |&block|
          return false unless @state == name
          block&.call
          true
        end
      end
    end

    def state=(ns)
      return if ns.nil?
      raise Error, "#{ns} is not possible state after #{@state}" unless self.class.transition?(@state, ns)
      raise Error, "#{ns} is a unique and has already been taken" if @history.include?(ns) && states[ns].unique?
      @history << ns
      @state = ns
    end

    def finite_state?
      states[state].final?
    end

    private

    def states
      self.class.states
    end
  end
end
