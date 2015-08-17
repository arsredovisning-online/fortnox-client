require 'fast_spec_helper'
require_from_root 'lib/fortnox/fortnox_authenticator'

require 'vcr'


describe FortnoxAuthenticator, :vcr do
  let(:api_code) { '52420a95-3e6c-50d7-63b2-abcfdfa3e588' }
  let(:client_secret) { 'GkEhaNS5h9' }
  let(:logger) { double("logger").as_null_object }

  it 'retrieves authorization token' do
    VCR.use_cassette "fortnox/retrieve_access_token" do
      authenticator = FortnoxAuthenticator.new(api_code, client_secret, logger: logger)
      expect(authenticator.retrieve_access_token).to eq 'dd49b5e5-032d-424b-93ad-7a62e15064c6'
    end
  end

  it 'handles failure retrieving authorization token' do
    VCR.use_cassette "fortnox/failure_retrieving_access_token" do
      authenticator = FortnoxAuthenticator.new('Not a correct api code', client_secret, logger: logger)
      expect { authenticator.retrieve_access_token }.to raise_error(FortnoxError, 'Ogiltig behörighet')
    end
  end

  it 'extracts access token from json body' do
    json = <<-EOF
     {
        "Authorization": {
          "AccessToken": "3f08d038-f380-4893-94a0-a08f6e60e67a"
        }
      }
    EOF
    authenticator = FortnoxAuthenticator.new(api_code, client_secret, logger: logger)
    expect(authenticator.extract_access_code(json)).to eq '3f08d038-f380-4893-94a0-a08f6e60e67a'
  end
end