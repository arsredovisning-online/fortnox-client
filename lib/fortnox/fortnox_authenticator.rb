require 'json'
require_relative 'fortnox_client'
require_relative 'fortnox_url'

class FortnoxAuthenticator

  def initialize(authorization_code, client_secret, logger: Rails.logger)
    @client = FortnoxClient.new(headers: {'Authorization-Code' => authorization_code, 'Client-Secret' => client_secret}, logger: logger)
  end

  def retrieve_access_token
    response = client.get(FortnoxUrl.base_url)
    extract_access_code(response)
  end

  def extract_access_code(json)
    JSON.parse(json)['Authorization']['AccessToken']
  end

  private

  attr_reader :client

end