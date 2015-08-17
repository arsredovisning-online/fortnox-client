class FortnoxUrl
  BASE_URL = 'https://api.fortnox.se/3'

  attr_reader :uri

  def initialize(url)
    @uri = URI(url)
  end

  def self.base_url
    new(BASE_URL)
  end

  def self.build(path_suffix: '', params: {})
    uri = uri_for(path_suffix)
    uri.query = URI.encode_www_form(params) unless params.empty?
    new(uri)
  end

  private

  def self.uri_for(path_suffix)
    return URI(BASE_URL) if path_suffix == ''
    path_suffix = path_suffix[1..-1] if path_suffix[0] == '/'
    URI("#{BASE_URL}/#{path_suffix}")
  end

end