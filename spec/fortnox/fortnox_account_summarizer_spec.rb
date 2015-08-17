require 'fast_spec_helper'
require_from_root 'lib/fortnox/fortnox_account_summarizer'

describe FortnoxAccountSummarizer do

  let(:api) { double("FortnoxApi") }
  let(:start_date) { Date.new(2013, 1, 1) }
  let(:end_date) { Date.new(2013, 12, 31) }
  let(:summarizer) { FortnoxAccountSummarizer.new(api, start_date, end_date) }

  account_data = {
      url1910: {account: 1910, balance_brought_forward: 0, balance_carried_forward: 1910.19},
      url2610: {account: 2610, balance_brought_forward: 0, balance_carried_forward: 2610.26},
      url3010: {account: 3010, balance_brought_forward: 0, balance_carried_forward: 3010.30},
      url5410: {account: 5410, balance_brought_forward: 0, balance_carried_forward: 5410.54},
  }

  before do
    allow(api).to receive(:get_financial_year_for).with(start_date) { 17 }
    allow(api).to receive(:get_account_urls).with(17) { account_data.keys.map(&:to_s) }
    account_data.each_pair do |url_sym, data|
      allow(api).to receive(:get_account).with(url_sym.to_s) { data }
    end
  end

  context 'all_accounts' do

    it 'returns a list of all accounts' do
      expect(summarizer.all_accounts).to eq [1910, 2610, 3010, 5410]
    end

  end

  context 'account balances' do

    it 'returns the "balance carried forward" for each account' do
      expect(summarizer.account_balances([1910, 2610, 3010, 5410])).to eq( {
          1910 => 1910.19,
          2610 => 2610.26,
          3010 => 3010.30,
          5410 => 5410.54
      })
    end

  end
end

