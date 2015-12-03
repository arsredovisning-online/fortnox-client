require 'fast_spec_helper'
require_from_root 'lib/fortnox/fortnox_account'
describe FortnoxAccount do

  context 'instance creation' do
    it 'needs a number to be initialized' do
      expect {FortnoxAccount.new}.to raise_error ArgumentError
    end

    it 'can be initialized with optional attributes' do
      expect {FortnoxAccount.new('1930', 100.00, 'Bankkonto', false)}.to_not raise_error
    end
  end

  context 'attributes' do
    let (:all_attributes) {FortnoxAccount.new('1930', 100.00, 'Bankkonto', false)}

    describe '#number' do
      it 'responds with the number' do
        expect(all_attributes.number).to eq('1930')
      end
    end

    describe '#balance' do
      it 'responds with the balance' do
        expect(all_attributes.balance).to eq(100.00)
      end
    end

    describe '#description' do
      it 'responds with the description' do
        expect(all_attributes.description).to eq('Bankkonto')
      end
    end

    describe '#description' do
      it 'responds with the has_verifications' do
        expect(all_attributes.has_verifications).to be_falsey
      end
    end
  end
end