# frozen_string_literal: true

class StateMachineExample
  extend GermanNumbers::StateMachine

  state_machine_for :state do
    state :first, can_be_initial: true
    state :second, can_be_initial: true
    state :third
    state :fourth

    transition from: :first, to: :second
    transition from: :second, to: :third
    transition from: :third, to: :first
    transition from: :third, to: :fourth
  end

  def initialize(initial_state)
    initialize_state(initial_state)
  end
end
