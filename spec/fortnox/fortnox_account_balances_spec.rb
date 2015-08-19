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
          1910 => BigDecimal.new("-434.0"),
          1931 => BigDecimal.new("75886.02"),
          1941 => BigDecimal.new("154456.62"),
          2081 => BigDecimal.new("-50000.0"),
          2514 => BigDecimal.new("-16510.91"),
          2519 => BigDecimal.new("149420.0"),
          2610 => BigDecimal.new("-185732.0"),
          2614 => BigDecimal.new("-163.01"),
          2615 => BigDecimal.new("-163.01"),
          2617 => BigDecimal.new("-70.31"),
          2620 => BigDecimal.new("23.49"),
          2640 => BigDecimal.new("13625.65"),
          2645 => BigDecimal.new("70.31"),
          2710 => BigDecimal.new("-3627.0"),
          2730 => BigDecimal.new("14907.09"),
          3010 => BigDecimal.new("-742928.0"),
          3740 => BigDecimal.new("0.22"),
          4535 => BigDecimal.new("281.3"),
          5400 => BigDecimal.new("17675.2"),
          5410 => BigDecimal.new("27614.4"),
          5420 => BigDecimal.new("6882.86"),
          6071 => BigDecimal.new("580.8"),
          6100 => BigDecimal.new("511.9"),
          6212 => BigDecimal.new("2650.21"),
          6250 => BigDecimal.new("480.0"),
          6570 => BigDecimal.new("1162.5"),
          6970 => BigDecimal.new("2487.62"),
          6992 => BigDecimal.new("500.0"),
          7220 => BigDecimal.new("354056.0"),
          7410 => BigDecimal.new("68060.0"),
          7511 => BigDecimal.new("111241.0"),
          7533 => BigDecimal.new("16510.91"),
          7610 => BigDecimal.new("518.08"),
          7699 => BigDecimal.new("4736.54"),
          8311 => BigDecimal.new("-476.62"),
          8314 => BigDecimal.new("19.0"),
          8423 => BigDecimal.new("25.0")
      }
      VCR.use_cassette 'fortnox/account_balances' do
        account_balances = balances.account_balances.select { |account, balance| balance.nonzero? }
        # puts account_balances.map { |account, balance| "#{account} => BigDecimal.new(\"#{balance.to_s('F')}\"),\n"}
        expect(account_balances).to eq(expected_result)
      end
    end
  end
end