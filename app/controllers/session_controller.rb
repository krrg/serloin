require 'cgi'
require 'uri'
require './lib/magicblackbox/MagicBlackBoxParameters'
require './lib/magicblackbox/MagicBlackBox'
require './lib/stackexchange/stackapi'

class SessionController < ApplicationController
  def create

    uri = URI.parse(request.url)
    params = CGI.parse(uri.query)
    params[:client_id] = ENV['CLIENT_ID']
    params[:client_secret] = ENV['CLIENT_SECRET']
    params[:redirect_uri] = 'https://serloin.herokuapp.com/auth/stackoverflow/callback'
    uri = URI.parse('https://stackexchange.com')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    post_requ = Net::HTTP::Post.new("/oauth/access_token")
    post_requ.add_field('Content-Type', 'application/x-www-form-urlencoded')
    post_requ.set_form_data(params)
    @response = http.request(post_requ)

    if Integer(response.code) != 200
      flash[:danger] = "There was an error authenticating with Stack Exchange"
      redirect_to root_url
    end

    @access_token = response.code.split('=')[1]

  end

  def results
    requ_builder =  StackExchangeRequestBuilder.new(access_token: @access_token, app_key: ENV['CLIENT_KEY'])
    user_info = requ_builder.current_user_info()
    recent_questions = requ_builder.most_recent_questions()

    currentTime = Time.now.to_i
    questionList = Hash.new
    recent_questions.each do |question|
      magicBlackBoxParameters = MagicBlackBoxParameters.new(user_info, question,
        MagicBlackBoxAdjacencyGraphData.new(user_info, question), currentTime)
      questionList[question.questionId] = MagicBlackBox.new(magicBlackBoxParameters).runBlackBox()
    end
    questionList.sort_by {|question,score| [-score]}
    
  end
end
