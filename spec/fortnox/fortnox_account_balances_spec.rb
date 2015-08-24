require 'fast_spec_helper'
require_from_root 'lib/fortnox/fortnox_api'
require_from_root 'lib/fortnox/fortnox_account_balances'
require 'bigdecimal'

require 'ostruct'
require 'vcr'

describe FortnoxAccountBalances, :vcr do
  ACCESS_TOKEN = 'dd49b5e5-032d-424b-93ad-7a62e15064c6'
  CLIENT_SECRET = 'GkEhaNS5h9'

  let(:logger) { double("logger").as_null_object }
  let(:api) { FortnoxApi.new(ACCESS_TOKEN, CLIENT_SECRET, logger: logger) }

  describe '#account_balances' do
    let(:balances) { FortnoxAccountBalances.new(api, Date.new(2015, 7, 31), 1) }

    it 'retrieves account balances' do
      expected_result = {
          1510 => BigDecimal.new('125.00'),
          1630 => BigDecimal.new('853.00'),
          1920 => BigDecimal.new('488664.08'),
          1930 => BigDecimal.new('243877.44'),
          2081 => BigDecimal.new('-50000.00'),
          2091 => BigDecimal.new('-157515.90'),
          2099 => BigDecimal.new('-159412.74'),
          2440 => BigDecimal.new('-190187.50'),
          2510 => BigDecimal.new('-14986.76'),
          2611 => BigDecimal.new('-25.00'),
          2650 => BigDecimal.new('-85965.00'),
          2999 => BigDecimal.new('-3000.00'),
      }
      VCR.use_cassette 'fortnox/account_balances' do
        account_balances = balances.account_balances.select { |account, balance| balance.nonzero? && account < 3000 }
        expect(account_balances).to eq(expected_result)
      end
    end
  end
end
