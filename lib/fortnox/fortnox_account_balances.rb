require 'thread'

class FortnoxAccountBalances

  def initialize(api, to_date, thread_count = 10)
    @api = api
    @to_date = to_date
    @thread_count = thread_count
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

  def account_balances(accounts = all_accounts)
    balances = Hash[
        accounts.map {|account|
          [account, BigDecimal.new(account_data[account][:balance_brought_forward])]
        }
    ]
    res = voucher_data
    res.each do |number, voucher|
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
      year_id = api.get_financial_year_for(to_date)
      account_urls = api.get_account_urls(year_id)
      @account_data = fetch_data_in_parallel(account_urls, :get_account)
    end
    @account_data
  end

  def fetch_data_in_parallel(urls, api_method)
    result = Hash.new
    queue = Queue.new
    chunk_size = urls.length / thread_count + 1
    workers = urls.each_slice(chunk_size).map do |slice|
      Thread.new do
        slice.each { |url|
          queue << api.send(api_method, url)
        }
      end
    end
    workers.map(&:join)
    until queue.empty? do
      data = queue.pop
      number = data[:number]
      result[number] = data
    end
    result
  end

  def voucher_data
    year_id = api.get_financial_year_for(to_date)
    voucher_urls = api.get_voucher_urls(year_id)
    fetch_data_in_parallel(voucher_urls, :get_voucher)
  end

  attr_reader :api, :to_date, :thread_count
end