require "httparty"

class StackExchangeApi

  @@base_uri = 'api.stackexchange.com'
  @@version = '2.2'

  def initialize(service)
    @options = {
      query: {
        site: service
      }
    }
  end

end

class StackExchangeRequestBuilder

  def initialize(base_uri='api.stackexchange.com', version='2.2', site='stackoverflow', api_key=nil)
    @base_uri = base_uri
    @version = version
    @site = site
  end

  def build_request(path, query_params={})
    yield(
      "https://#{@base_uri}/#{@version}#{path}",
      query_params.merge({"site" => @site})
    )
  end


  """
  Warning: This method blithely assumes that the number of pages specified will actually
  be available.  It will explode if this is false.  So, be careful with how many pages
  you request.
  """
  def tags(pages=1)
    query_params = {
      "order": "desc",
      "sort": "popular",
      "pagesize": 100,
      "filter": "!-.G.68grSaJo",  # Filter to only `count` and `name`
    }

    responses = (1..pages).map do |page|
      build_request("/tags", query_params.merge({"page" => page})) do |uri, query|
        JSON.parse(HTTParty.get(uri, :query => query).body)
      end
    end

    responses
      .flat_map { |response| response["items"]}
      .map { |tag| tag["name"] }
  end


  def top_answerers_for_tag(tag)
    path = "/tags/#{tag}/top-answerers/all_time"
    query_params = {
      "pagesize": 100,
    }
  end

end

S = StackExchangeRequestBuilder.new
puts(S.tags(pages=3))
