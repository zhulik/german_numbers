# typed: false
# frozen_string_literal: true

describe GermanNumbers::StateMachine do
  describe '.new' do
    context 'when initial state is unknown' do
      it 'raises error' do
        expect { StateMachineExample.new(:unknown) }.to raise_error(GermanNumbers::StateMachine::StateError)
      end
    end

    context 'when initial state is not possible' do
      it 'raises error' do
        expect { StateMachineExample.new(:third) }.to raise_error(GermanNumbers::StateMachine::StateError)
      end
    end
  end

  describe '#state=' do
    let!(:machine) { StateMachineExample.new(:first) }

    context 'with possible transition' do
      it 'changes state' do
        machine.state_state = :second
        expect(machine.state_state).to eq(:second)
        machine.state_state = :third
        expect(machine.state_state).to eq(:third)
        machine.state_state = :first
        expect(machine.state_state).to eq(:first)
        machine.state_state = :second
        expect(machine.state_state).to eq(:second)
        machine.state_state = :third
        expect(machine.state_state).to eq(:third)
        machine.state_state = :fourth
        expect(machine.state_state).to eq(:fourth)
      end
    end

    context 'with impossible transition' do
      it 'raises error' do
        expect { machine.state_state = :unknown }.to raise_error(GermanNumbers::StateMachine::StateError)
        expect { machine.state_state = :third }.to raise_error(GermanNumbers::StateMachine::StateError)
      end
    end
  end
end
