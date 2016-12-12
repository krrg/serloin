require 'cgi'
require 'uri'

class SessionController < ApplicationController
  def create
    puts "hello"
    uri = URI.parse(request.url)
    params = CGI.parse(uri.query)
    params[:client_id] = ENV['CLIENT_ID']
    params[:client_secret] = ENV['CLIENT_SECRET']
    params[:redirect_uri] =
    uri = URI.parse('https://stackexchange.com')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    post_requ = Net::HTTP::Post.new("/oauth/access_token")
    post_requ.add_field('Content-Type', 'application/x-www-form-urlencoded')
    post_requ.set_form_data(params)
    @response = http.request(post_requ)
    puts "CODE: #{response.code}"
    puts "BODY: #{response.body}"
  end

  def finalize

  end
end
