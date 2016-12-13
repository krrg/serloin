require "httparty"
require "glutton_ratelimit"
require_relative "../magicblackbox/MagicBlackBoxParameters.rb"

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
      return {"items" => []}
    end

    result = JSON.parse(response.body)

    if result.key?("backoff")
      @backoff = result["backoff"]
    end

    result
  end

  rate_limit :get_json, 90, 60  # 1 GET request every 1 second
end

class StackExchangeRequestBuilder

  def initialize(base_uri: 'api.stackexchange.com', version: '2.2', site: 'stackoverflow', access_token: nil, app_key: nil)
    @base_uri = base_uri
    @version = version
    @site = site
    @access_token = access_token
    @app_key = app_key
    @http = ThrottledHTTP.new
  end

  def build_request(path, query_params={})
    unless @access_token.nil?
      query_params.merge!({"access_token" => @access_token})
    end

    unless @app_key.nil?
      query_params.merge!({"key" => @app_key})
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
      "order" => "desc",
      "sort" => "popular",
      "pagesize" => 100,
      "filter" => "!-.G.68grSaJo",  # Filter to only `count` and `name`
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
      "pagesize" => 50,
      "filter" => "!-pcLI4I7",
    }

    build_request path, query_params do |uri, query|
      @http.get_json(uri, :query => query)
    end
  end

  def answer_tags_for_user(userid)
    path = "/users/#{userid}/answers"
    query_params = {
      "pagesize" => 90,
      "filter" => "!SWJ_BpAceOUGGWr5yQ",
      "min" => 1,
      "order" => "desc",
      "sort" => "votes",
    }

    build_request path, query_params do |uri, query|
      @http.get_json(uri, :query => query)
    end
  end

  def current_user_info()
    path = "/me"
    query_params = {
      "filter" => "!*MxJcsZ)vC2RZAFo",
    }

    build_request path, query_params do |uri, query|
      user = @http.get_json(uri, :query => query)["items"].first
      answer_tags = answer_tags_for_user(user['user_id'])

      MagicBlackBoxCurrentUser.new(
        answer_tags_to_tagscore_hash(answer_tags), user['reputation']
      )
    end
  end

  private def answer_tags_to_tagscore_hash(answer_tags)
    tagscores = Hash.new(0)

    answer_tags["items"].each do |question|
      question["tags"].each do |tag|
        tagscores[tag] += question["score"]
      end
    end

    tagscores
  end


  def most_recent_questions()
    path = "/questions"

    query_params = {
      "filter" => "!1PUh93)XFP63W)XMP1SId(Le9aYxX5bDg"#"!)IMAC7XMVlKG0H_pp2p35TC6b7T8TaZ*HbWV",
      "pagesize" => 100,
      "todate" => Time.now.to_i - 600,  # Must have been up for 10 minutes
      "order" => "desc",
      "sort" => "creation"
    }

    build_request path, query_params do |uri, query|
      @http.get_json(uri, :query => query)["items"]
        .map { |question| question_to_blackbox_question(question) }
    end
  end

  private def question_to_blackbox_question(question)
    tags = question["tags"]
    answer_upvotes = if question.key? "answers" then question["answers"].map { |answer| answer["score"] } else [] end
    creation_date = question["creation_date"]
    bounty = question.key? "bounty_amount"
    close_votes = question["close_vote_count"]
    question_upvotes = question["score"]
    page_views = question["view_count"]
    asker_rep = question["owner"]["reputation"]
    is_closed = question.key? "closed_date"
    question_id = question["question_id"]
    title = question["title"]

    MagicBlackBoxCurrentQuestion.new(
      tags, answer_upvotes, creation_date,
      bounty, close_votes, question_upvotes,
      page_views, asker_rep, is_closed, question_id, title
    )
  end

end

# File.open("../../../data/edge_entries.csv", "w") do |edge_file|
#   S.tags(1).map do |tag|
#     File.open("../../../data/#{tag}.json", "w") do |file|
#       puts "Getting top answerers for tag `#{tag}`"
#       response = S.top_answerers_for_tag(URI.escape(tag))

#       user_ids = response["items"].map { |top_answerer| top_answerer["user"]["user_id"] }

#       user_ids.each do |userid|
#         puts "\t Getting answer tags for user #{userid} under tag #{tag}"
#         answer_tags = S.answer_tags_for_user(userid)["items"]

#         answer_tags.each do |answer|
#           upvotes = answer["score"]
#           answer["tags"].each do |tag2|
#             edge_file.write([tag, tag2, upvotes].join(",") + "\n")
#           end
#         end

#       end
#     end
#   end
# end
