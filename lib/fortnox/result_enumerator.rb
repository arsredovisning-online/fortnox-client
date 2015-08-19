require_relative 'fortnox_url'

class ResultEnumerator
  include Enumerable

  def initialize(client, path_suffix, array_name, params)
    @client = client
    @path_suffix = path_suffix
    @array_name = array_name
    @params = params
  end

  def each
    params_with_page = params
    loop do
      url = FortnoxUrl.build(path_suffix: path_suffix, params: params_with_page)
      response = client.get(url)
      result = JSON.parse(response)
      current_page, total_pages = extract_page_info(result)
      result[array_name].each do |item|
        yield item
      end

      break if current_page >= total_pages
      params_with_page.merge!(page: current_page + 1)
    end
  end

  private

  attr_reader :client, :path_suffix, :array_name, :params

  def extract_page_info(result)
    meta_info = result['MetaInformation']
    return meta_info['@CurrentPage'].to_i, meta_info['@TotalPages'].to_i
  end

end