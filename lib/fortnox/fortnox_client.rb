require 'net/http'
require_relative 'fortnox_error'
require_relative 'null_logger'
require 'net/http/persistent'

class FortnoxClient

  def initialize(logger: NullLogger.new, headers: {})
    @logger = logger
    @headers = headers.merge('Accept' => 'application/json')
    @http = Net::HTTP::Persistent.new 'FortnoxClient'
  end

  def get(url)
    begin
      req = Net::HTTP::Get.new(url.uri, headers)
      response = @http.request(url.uri, req)
    rescue
      raise FortnoxError.new('Det går ej att kontakta Fortnox')
    end
    verify_status(response)
    response.body
  end

  private

  attr_reader :logger

  def client(uri)
    client = Net::HTTP.new(uri.host, uri.port)
    client.use_ssl = true
    client.verify_mode = OpenSSL::SSL::VERIFY_NONE
    client
  end

  def verify_status(response)
    status = response.code
    return if status.to_s[0] == '2'
    logger.error("Error response from FortNox: #{response.read_body}")
    raise_specific_error(response)
    raise FortnoxError.new("Ogiltig behörighet") if status.to_s[0] == '4'
    raise FortnoxError.new("Det går ej att kontakta Fortnox (status=#{status})")
  end

  def raise_specific_error(response)
    body = response.read_body
    if body.include?("{")
      json_response = JSON.parse(body)
      error_info = json_response["ErrorInformation"]
      if error_info
        # Fortnox errors can have both upper and lower case keys, hence the extraction code below.
        message = error_info.detect { |k, v| k.downcase == "message" }[1]
        code = error_info.detect { |k, v| k.downcase == "code" }[1]

        message = specific_message(message, code)

        raise FortnoxError.new(message, code: code)
      end
    end
  end

  def specific_message(message, code)
    case code.to_i
      when 2001103
        "Fortnox gav tillbaka felmeddelandet <b>\"#{message}\"</b>. För att använda integrationen krävs att " +
            "Fortnox-kontot har en s.k. \"Api-licens\". Detta är en tilläggstjänst som man prenumererar på i Fortnox. " +
            "<a href=\"http://www.fortnox.se/kopplingar/mer-information/\" target=\"_blank\">Mer&nbsp;information.</a> " +
            "Om du inte har denna licens går det istället att exportera en SIE-fil från Fortnox och " +
            "importera den i Årsredovisning Online."
      else
        message
    end
  end

  attr_reader :headers
end
