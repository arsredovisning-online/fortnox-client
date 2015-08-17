class FortnoxError < StandardError
  attr_reader :code

  def initialize(message, code: nil)
    super(message)
    @code = code
  end

  def detailed_message
    "Error from Fortnox: #{message} (#{code})"
  end
end
