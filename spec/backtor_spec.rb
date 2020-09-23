# frozen_string_literal: true

require 'timeout'

RSpec.describe Backtor do
  context 'instantiation' do
    context 'name' do
      it 'can be given' do
        b = Backtor.new(name: 'example') {}
        expect(b.name).to eq 'example'
      end
      
      it 'can be omitted' do
        b = Backtor.new {}
        expect(b.name).to eq nil
      end

      it 'must be a string' do
        expect { Backtor.new(name: 3) {} }.to raise_error TypeError
      end
    end

    it 'requires a block' do
      expect { Backtor.new }.to raise_error ArgumentError
    end
  end
  
  it 'has #current' do
    expect(Backtor.current).to be_a Backtor
  end

  it 'can take arguments which are passed to the block' do
    b = Backtor.new(3) { |x| x + 1 }
    expect(b.take).to eq 4
    
    b = Backtor.new('a', 'b') { |a, b| [a, b] }
    expect(b.take).to eq ['a', 'b']
  end

  it 'yields the block\'s return value' do
    b = Backtor.new { 'foo' }
    expect(b.take).to eq 'foo'
  end

  context 'send/recv' do
    it 'works in basic form' do
      b = Backtor.new { Backtor.recv }
      b.send 'foo'
      expect(b.take).to eq 'foo'
    end

    it 'does not block on send' do
      # Hacky - just make sure that the test completes
      Timeout.timeout(5) do
        b = Backtor.new { sleep 10 }
        b.send 'never received'
      end
    end
  end
end
