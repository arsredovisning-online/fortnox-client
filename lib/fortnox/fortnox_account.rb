class FortnoxAccount
  attr_reader :number
  attr_reader :balance
  attr_reader :description
  attr_reader :has_verifications

  def initialize(number, balance = nil, description = nil, has_verifications = nil)
    @number = number
    @balance = balance
    @description = description
    @has_verifications = has_verifications
  end
end