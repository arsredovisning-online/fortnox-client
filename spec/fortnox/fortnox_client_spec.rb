require 'fast_spec_helper'
require 'json'
# require_from_root 'app/services/import/import_error'
require_from_root 'lib/fortnox/fortnox_client'
require_from_root 'lib/fortnox/fortnox_url'
require_from_root 'lib/fortnox/fortnox_error'
require 'webmock/rspec'

describe FortnoxClient do
  let(:logger) { double("logger").as_null_object }
  let(:client) { FortnoxClient.new(logger: logger) }

  describe '#get' do
    let (:url) { FortnoxUrl.base_url }

    context 'successful request' do
      it 'returns response body' do
        stub_request(:get, 'https://api.fortnox.se/3').to_return({body: 'foo', status: 200})
        expect(client.get(url)).to eq('foo')
      end

      it 'returns response body for with different status code' do
        stub_request(:get, 'https://api.fortnox.se/3').to_return({body: 'foo', status: 203})
        expect(client.get(url)).to eq('foo')
      end
    end

    context 'server error' do
      it 'raises error with status code' do
        stub_request(:get, 'https://api.fortnox.se/3').to_return({body: '{}', status: 503})
        expect { client.get(url) }.to raise_error(FortnoxError, 'Det går ej att kontakta Fortnox (status=503)')
      end

      it 'logs the error' do
        body = '{"foo":"bar"}'
        stub_request(:get, 'https://api.fortnox.se/3').to_return({body: body, status: 503})

        expect(logger).to receive(:error).with(/#{body}/)

        client.get(url) rescue nil    # Ignore exception - we want to check the mock expectation above
      end
    end

    context 'client error' do
      it 'raises error with error message from response' do
        stub_request(:get, 'https://api.fortnox.se/3').to_return({body: '{"ErrorInformation":{"error":1,"message":"Ogiltig parameter i anropet.","code":"2000588"}}', status: 403})
        expect { client.get(url) }.to raise_error(FortnoxError, 'Ogiltig parameter i anropet.')
      end

      it 'handles upper case keys in error JSON' do
        stub_request(:get, 'https://api.fortnox.se/3').to_return({body: '{"ErrorInformation":{"Error":1,"Message":"Ogiltig inloggning","Code":"2000310"}}', status: 403})
        expect { client.get(url) }.to raise_error(FortnoxError, 'Ogiltig inloggning')
      end

      it 'gives more detailed message for code 2001103 (Api-licens saknas)' do
        stub_request(:get, 'https://api.fortnox.se/3').to_return({body: '{"ErrorInformation":{"error":1,"message":"Api-licens saknas.","code":"2001103"}}', status: 403})
        expect { client.get(url) }.to raise_error(FortnoxError, /Fortnox gav tillbaka felmeddelandet.*Api-licens saknas.*För att använda integrationen krävs att/)
      end
    end

    context 'connection error' do
      it 'returns status error when failing to connect' do
        stub_request(:get, 'https://api.fortnox.se/3').to_raise('Connection error')
        expect { client.get(url) }.to raise_error(FortnoxError, 'Det går ej att kontakta Fortnox')
      end
    end
  end

end