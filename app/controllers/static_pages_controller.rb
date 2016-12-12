class StaticPagesController < ApplicationController
  def home
    @oauth_url = "https://stackexchange.com/oauth?client_id=8577&redirect_uri=https%3A%2F%2Fserloin.herokuapp.com%2Fauth%2Fstackoverflow%2Fcallback&response_type=code&scope=no_expiry&state=23637e859ceb0de3b44099350b9b278ee741c3b1091b3ec0"
  end
end
