require 'fast_spec_helper'
require_from_root 'lib/fortnox/fortnox_api'
require_from_root 'lib/fortnox/fortnox_account_balances'

require 'ostruct'
require 'vcr'

describe FortnoxAccountBalances, :vcr do
  ACCESS_TOKEN = 'dd49b5e5-032d-424b-93ad-7a62e15064c6'
  CLIENT_SECRET = 'GkEhaNS5h9'

  let(:logger) { double("logger").as_null_object }
  let(:api) { FortnoxApi.new(ACCESS_TOKEN, CLIENT_SECRET, logger: logger) }

  describe '#account_balances' do
    let(:balances) { FortnoxAccountBalances.new(api, Date.new(2012, 7, 31)) }

    it 'retrieves account balances' do
      expected_result = {
          2081 => BigDecimal.new("-50000.0"),
          2519 => BigDecimal.new("298840.0"),
          6570 => BigDecimal.new("1250.0"),
          7699 => BigDecimal.new("7533.04"),
          2640 => BigDecimal.new("157.09"),
          6970 => BigDecimal.new("3283.44"),
          8999 => BigDecimal.new("150224.92"),
          3010 => BigDecimal.new("-1148637.0"),
          2099 => BigDecimal.new("-150224.92"),
          1630 => BigDecimal.new("1.0"),
          6992 => BigDecimal.new("500.0"),
          6071 => BigDecimal.new("780.8"),
          8311 => BigDecimal.new("-3318.29"),
          4535 => BigDecimal.new("565.02"),
          2112 => BigDecimal.new("-14200.0"),
          2614 => BigDecimal.new("-163.01"),
          2645 => BigDecimal.new("141.24"),
          7220 => BigDecimal.new("562056.0"),
          6100 => BigDecimal.new("543.1"),
          2615 => BigDecimal.new("0.01"),
          1910 => BigDecimal.new("-434.0"),
          7410 => BigDecimal.new("88504.0"),
          8314 => BigDecimal.new("17.0"),
          2617 => BigDecimal.new("-141.24"),
          2650 => BigDecimal.new("-270091.0"),
          6212 => BigDecimal.new("5374.37"),
          7511 => BigDecimal.new("176593.0"),
          8423 => BigDecimal.new("25.0"),
          5400 => BigDecimal.new("20095.2"),
          3740 => BigDecimal.new("0.65"),
          2510 => BigDecimal.new("-53604.66"),
          2620 => BigDecimal.new("23.49"),
          1931 => BigDecimal.new("3002.91"),
          2710 => BigDecimal.new("-20342.0"),
          6250 => BigDecimal.new("480.0"),
          7533 => BigDecimal.new("21470.62"),
          8811 => BigDecimal.new("14200.0"),
          5410 => BigDecimal.new("36594.4"),
          2514 => BigDecimal.new("-21470.62"),
          1941 => BigDecimal.new("298798.29"),
          2730 => BigDecimal.new("3613.09"),
          7610 => BigDecimal.new("1129.19"),
          8910 => BigDecimal.new("53604.66"),
          5420 => BigDecimal.new("7503.07")
      }
      VCR.use_cassette 'fortnox/account_balances' do
        account_balances = balances.account_balances.select { |account, balance| balance.nonzero? }
        # puts account_balances.map { |account, balance| "#{account} => BigDecimal.new(\"#{balance.to_s('F')}\"),\n"}
        expect(account_balances).to eq(expected_result)
      end
    end
  end
end