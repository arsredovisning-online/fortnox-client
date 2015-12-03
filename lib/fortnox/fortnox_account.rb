class FortnoxAccount
  attr_reader :number
  attr_accessor :balance
  attr_accessor :description
  attr_accessor :has_verifications

  def initialize(number, balance = nil, description = nil, has_verifications = nil)
    @number = number
    @balance = balance
    @description = description
    @has_verifications = has_verifications
  end
end