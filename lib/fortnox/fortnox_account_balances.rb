class FortnoxAccountBalances
  def initialize(api, to_date)
    @api = api
    @to_date = to_date
  end

  def all_accounts
    account_data.keys
  end

  def account_balances_carried_forward(accounts)
    Hash[
        accounts.map {|account|
          [account, account_data[account][:balance_carried_forward]]
        }
    ]
  end

  def account_balances(accounts)
    balances = Hash[
        accounts.map {|account|
          [account, BigDecimal.new(account_data[account][:balance_brought_forward])]
        }
    ]
    year_id = api.get_financial_year_for(to_date)
    voucher_urls = api.get_voucher_urls(year_id, to_date)
    voucher_urls.each do |voucher_url|
      voucher = api.get_voucher(voucher_url)
      voucher[:rows].each do |row|
        balances[row[:account]] = balances[row[:account]] + row[:debit] - row[:credit]
      end
    end
    balances
  end

  def account_descriptions(accounts)
    Hash[
        accounts.map {|account|
          [account, account_data[account][:description]]
        }
    ]
  end

  private

  def account_data
    unless @account_data
      @account_data = Hash.new
      year_id = api.get_financial_year_for(to_date)
      account_urls = api.get_account_urls(year_id)
      account_urls.each { |url|
        account_data = api.get_account(url)
        account_number = account_data[:account]
        @account_data[account_number] = account_data
      }
    end
    @account_data
  end

  def vouchers()
    voucher_data = Hash.new
    year_id = api.get_financial_year_for(from_date)
    account_urls = api.get_account_urls(year_id)
    account_urls.each { |url|
      account_data = api.get_account(url)
      account_number = account_data[:account]
      voucher_data[account_number] = account_data
    }
    voucher_data
  end

  attr_reader :api, :to_date
end