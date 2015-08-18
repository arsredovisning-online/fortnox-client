class FortnoxAccountSummarizer
  def initialize(api, from_date, to_date)
    @api = api
    @from_date = from_date
    @to_date = to_date
  end

  def all_accounts
    data.keys
  end

  def account_balances(accounts)
    Hash[
      accounts.map {|account|
        [account, data[account][:balance_carried_forward]]
      }
    ]
  end

  def account_descriptions(accounts)
    Hash[
      accounts.map {|account|
        [account, data[account][:description]]
      }
    ]
  end

  private

  def data
    unless @data
      @data = Hash.new
      year_id = api.get_financial_year_for(from_date)
      account_urls = api.get_account_urls(year_id)
      account_urls.each { |url|
        account_data = api.get_account(url)
        account_number = account_data[:account]
        @data[account_number] = account_data
      }
    end
    @data
  end

  attr_reader :api, :from_date, :to_date
end