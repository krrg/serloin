require 'cgi'
require 'uri'

class SessionController < ApplicationController
  def create
    puts "hello"
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

    token = response.code.split('=')[1]


  end
end
