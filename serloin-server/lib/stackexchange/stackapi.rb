require "httparty"
require "glutton_ratelimit"


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


class ThrottledHTTP
  extend GluttonRatelimit

  def initialize
    @backoff = nil
  end

  def get_json(uri, query)
    unless @backoff.nil?
      sleep(@backoff)
      @backoff = nil
    end

    response = HTTParty.get(uri, query)
    unless response.code == 200
      puts "[Warning] Got response code `#{response.code}` which is not a Teapot."
      puts response.body
      return {"items": []}
    end

    result = JSON.parse(response.body)

    if result.key?("backoff")
      @backoff = result["backoff"]
    end

    result
  end

  rate_limit :get_json, 60, 60  # 1 GET request every 1 second
end

class StackExchangeRequestBuilder

  def initialize(base_uri: 'api.stackexchange.com', version: '2.2', site: 'stackoverflow', access_token: nil)
    @base_uri = base_uri
    @version = version
    @site = site
    @access_token = access_token
    @http = ThrottledHTTP.new
  end

  def build_request(path, query_params={})
    unless @access_token.nil?
      query_params.merge!({"access_token" => @access_token, "key" => ")T2x8ZEOMl8neRq7th6VRg(("})
    end

    yield(
      "https://#{@base_uri}/#{@version}#{path}",
      query_params.merge({"site" => @site})
    )
  end

  # TODO: Make this more robust against bad number of pages
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
      build_request "/tags", query_params.merge({"page" => page}) do |uri, query|
        puts "Here is my awesome query #{query}"
        @http.get_json(uri, :query => query)
      end
    end

    puts responses

    responses
      .flat_map { |response| response["items"] }
      .map { |tag| tag["name"] }

  end


  def top_answerers_for_tag(tag)
    path = "/tags/#{tag}/top-answerers/all_time"
    query_params = {
      "pagesize": 100,
      "filter": "!-pcLI4I7",
    }

    build_request path, query_params do |uri, query|
      @http.get_json(uri, :query => query)
    end
  end

end

S = StackExchangeRequestBuilder.new(access_token: "D6zqa4HRNjy2JbUDGKIaXQ))")

S.tags(4).map do |tag|
  File.open("../../../data/#{tag}.json", "w") do |file|
    puts "Getting top answerers for tag `#{tag}`"
    response = S.top_answerers_for_tag(URI.escape(tag))
    file.write(response.to_json)
  end
end
