require 'fast_spec_helper'
require_from_root 'lib/fortnox/fortnox_api'

require 'ostruct'
require 'vcr'

describe FortnoxApi, :vcr do
  ACCESS_TOKEN = 'dd49b5e5-032d-424b-93ad-7a62e15064c6'
  CLIENT_SECRET = 'GkEhaNS5h9'

  let(:logger) { double("logger").as_null_object }
  let(:api) { FortnoxApi.new(ACCESS_TOKEN, CLIENT_SECRET, logger: logger) }
  let(:api_with_page_size_1) { FortnoxApi.new(ACCESS_TOKEN, CLIENT_SECRET, 1, logger: logger) }

  describe 'get financial years' do
    let(:expected_result) { [OpenStruct.new(id: 1, from_date: Date.new(2014, 1, 1), to_date: Date.new(2014, 12, 31)),
                             OpenStruct.new(id: 2, from_date: Date.new(2011, 7, 13), to_date: Date.new(2012, 12, 31))] }

    it 'retrieves financial years' do
      VCR.use_cassette "fortnox/get_financial_years" do
        expect(api.get_financial_years).to eq expected_result
      end
    end

    it 'handles multiple pages' do
      VCR.use_cassette "fortnox/get_financial_years_page_size_1" do
        expect(api_with_page_size_1.get_financial_years).to eq expected_result
      end
    end
  end

  describe 'search for financial year by date' do
    it 'finds year with correct date' do
      VCR.use_cassette "fortnox/get_financial_year_for" do
        expect(api.get_financial_year_for(Date.new(2011,7,13))).to eq 2
      end
    end

    it 'gets no financial year for wrong date' do
      VCR.use_cassette "fortnox/get_financial_year_for_wrong_date" do
        expect(api.get_financial_year_for(Date.new(2011,6,13))).to eq -1
      end
    end
  end

  describe 'vouchers' do
    it 'gets voucher list' do
      expected_result = (1..236).map { |voucher| "https://api.fortnox.se/3/vouchers/A/#{voucher}?financialyear=2" }
      VCR.use_cassette "fortnox/get_vouchers" do
        expect(api.get_voucher_urls(2)).to eq expected_result
      end
    end

    it 'gets limited voucher list' do
      expected_result = (1..19).map { |voucher| "https://api.fortnox.se/3/vouchers/A/#{voucher}?financialyear=2" }
      VCR.use_cassette "fortnox/get_limited_voucher_list" do
        expect(api.get_voucher_urls(2, Date.new(2011,9,30))).to eq expected_result
      end
    end

    it 'gets single voucher' do
      VCR.use_cassette "fortnox/get_single_voucher" do
        url = "https://api.fortnox.se/3/vouchers/A/17?financialyear=2"
        expected_result = {
            voucher_number: 17,
            rows: [
                OpenStruct.new(account: 5420, credit: 0, debit: 370.78),
                OpenStruct.new(account: 1910, credit: 370.78, debit: 0),
                OpenStruct.new(account: 2640, credit: 0, debit: 92.7),
                OpenStruct.new(account: 2614, credit: 92.7, debit: 0),
                OpenStruct.new(account: 2615, credit: 92.7, debit: 0),
            ]
        }
        expect(api.get_voucher(url)).to eq expected_result
      end
    end
  end

  describe 'accounts' do
    it 'retrieves list of account urls' do
      VCR.use_cassette "fortnox/get_account_urls" do
        account_urls = api.get_account_urls(2)
        expect(account_urls.size).to eq 74
        expect(account_urls).to include 'https://api.fortnox.se/3/accounts/1630?financialyear=2'
        expect(account_urls).to include 'https://api.fortnox.se/3/accounts/1931?financialyear=2'
        expect(account_urls).to include 'https://api.fortnox.se/3/accounts/5410?financialyear=2'
        expect(account_urls).not_to include 'https://api.fortnox.se/3/accounts/1010?financialyear=2'
      end
    end

    it 'retrieves single account' do
      VCR.use_cassette "fortnox/get_single_account" do
        url = 'https://api.fortnox.se/3/accounts/1931?financialyear=2'
        account = api.get_account(url)
        expect(account).to eq OpenStruct.new(account: 1931,
                                             description: 'Företagskonto, Swedbank',
                                             balance_brought_forward: 0,
                                             balance_carried_forward: 3002.91)
      end
    end

  end
end