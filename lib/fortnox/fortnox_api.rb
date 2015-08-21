require_relative 'fortnox_client'
require_relative 'result_enumerator'
require_relative 'null_logger'
require 'ostruct'
require 'json'
require 'bigdecimal/util'

class FortnoxApi

  def initialize(access_token, client_secret, page_size = 100, logger: NullLogger.new)
    @client = FortnoxClient.new(headers: {'Access-Token' => access_token, 'Client-Secret' => client_secret}, logger: logger)
    @page_size = page_size
  end

  def get_financial_years
    ResultEnumerator.new(client, 'financialyears', 'FinancialYears', {limit: page_size}).map do |year|
      OpenStruct.new(id: year['Id'], from_date: Date.parse(year['FromDate']), to_date: Date.parse(year['ToDate']))
    end
  end

  def get_financial_year_for(from_date)
    url = FortnoxUrl.build(path_suffix: 'financialyears', params: {date: from_date.iso8601})
    response = client.get(url)
    years = JSON.parse(response)['FinancialYears']
    return years[0]['Id'] if years.size > 0
    -1
  end

  def get_voucher_urls(financial_year_id, to_date = nil)
    params = {limit: page_size, financialyear: financial_year_id}
    params[:todate] = to_date.iso8601 if to_date
    ResultEnumerator.new(client, 'vouchers', 'Vouchers', params).map { |voucher| voucher['@url'] }
  end

  def get_voucher(url)
    response = client.get(FortnoxUrl.new(url))
    voucher = JSON.parse(response)['Voucher']
    rows = voucher['VoucherRows'].map do |voucher_row|
      OpenStruct.new(account: voucher_row['Account'], credit: decimal(voucher_row['Credit']), debit: decimal(voucher_row['Debit']))
    end
    { number: voucher['VoucherNumber'], rows: rows}
  end

  def get_account_urls(financial_year_id)
    params = {limit: page_size, financialyear: financial_year_id}
    ResultEnumerator.new(client, 'accounts', 'Accounts', params).
        select {|account| account['Active']}.
        map { |account| account['@url'] }
  end

  def get_account(url)
    response = client.get(FortnoxUrl.new(url))
    account = JSON.parse(response)['Account']
    OpenStruct.new(number: account['Number'],
                   description: account['Description'],
                   balance_brought_forward: decimal(account['BalanceBroughtForward']),
                   balance_carried_forward: decimal(account['BalanceCarriedForward']))
  end

  private

  attr_reader :client, :page_size

  def decimal(number)
    number.to_d.truncate(2)
  end
end