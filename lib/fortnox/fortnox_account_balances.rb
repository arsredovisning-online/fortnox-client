require 'thread'

class FortnoxAccountBalances
  THREAD_COUNT = 10

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

  def account_balances(accounts = all_accounts)
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
      year_id = api.get_financial_year_for(to_date)
      account_urls = api.get_account_urls(year_id)
      @account_data = fetch_account_data_in_parallel(account_urls)
      # account_urls.each { |url|
      #   account_data = api.get_account(url)
      #   account_number = account_data[:account]
      #   @account_data[account_number] = account_data
      # }
    end
    @account_data
  end

  def fetch_account_data_in_parallel(account_urls)
    account_data = Hash.new
    queue = Queue.new
    chunk_size = account_urls.length / THREAD_COUNT + 1
    workers = account_urls.each_slice(chunk_size).map do |slice|
      Thread.new do
        slice.each { |url|
          queue << api.get_account(url)
        }
      end
    end
    workers.map(&:join)
    until queue.empty? do
      account = queue.pop
      account_number = account[:account]
      account_data[account_number] = account
    end
    account_data
  end

  def fetch_voucher_data_in_parallel(voucher_urls)
    voucher_data = Hash.new
    queue = Queue.new
    chunk_size = voucher_urls.length / THREAD_COUNT + 1
    workers = voucher_urls.each_slice(chunk_size).map do |slice|
      Thread.new do
        slice.each { |url|
          queue << api.get_voucher(url)
        }
      end
    end
    workers.map(&:join)
    until queue.empty? do
      voucher = queue.pop
      account_number = voucher[:account]
      voucher_data[account_number] = voucher
    end
    voucher_data
  end

  def vouchers
    voucher_data = Hash.new
    year_id = api.get_financial_year_for(from_date)
    voucher_urls = api.get_voucher_urls(year_id)
    # voucher_urls.each { |url|
    #   voucher_data = api.get_account(url)
    #   account_number = voucher_data[:account]
    #   voucher_data[account_number] = voucher_data
    # }
    # voucher_data
    fetch_voucher_data_in_parallel(voucher_urls)
  end

  attr_reader :api, :to_date
end