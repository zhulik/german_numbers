# frozen_string_literal: true

describe GermanNumbers::StateMachine do
  describe '.new' do
    context 'when initial state is unknown' do
      it 'raises error' do
        expect { StateMachineExample.new(:unknown) }.to raise_error(GermanNumbers::StateMachine::Error)
      end
    end

    context 'when initial state is not possible' do
      it 'raises error' do
        expect { StateMachineExample.new(:third) }.to raise_error(GermanNumbers::StateMachine::Error)
      end
    end
  end

  describe '#state=' do
    let!(:machine) { StateMachineExample.new(:first) }

    context 'with possible transition' do
      it 'changes state' do
        machine.state = :second
        expect(machine.state).to eq(:second)
        machine.state = :third
        expect(machine.state).to eq(:third)
        machine.state = :first
        expect(machine.state).to eq(:first)
        machine.state = :second
        expect(machine.state).to eq(:second)
        machine.state = :third
        expect(machine.state).to eq(:third)
        machine.state = :fourth
        expect(machine.state).to eq(:fourth)
      end
    end

    context 'with impossible transition' do
      it 'raises error' do
        expect { machine.state = :unknown }.to raise_error(GermanNumbers::StateMachine::Error)
        expect { machine.state = :third }.to raise_error(GermanNumbers::StateMachine::Error)
      end
    end
  end
end
