# GET  =========================================================================

get '/' do
  erb :index
end

get '/sign_in' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  redirect request_token.authorize_url
end

get '/sign_out' do
  session.clear
  redirect '/'
end

get '/auth' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # our request token is only valid until we use it to get an access token, so let's delete it from our session
  session.delete(:request_token)

  @twitter_username = @access_token.params[:screen_name]
  twitter_token = @access_token.params[:oauth_token]
  twitter_secret = @access_token.params[:oauth_token_secret]

  # at this point in the code is where you'll need to create your user account and store the access token

  @user = User.find_by_username(@twitter_username)
  # @user = User.create(username: "#{@twitter_username}", oauth_token: twitter_token, oauth_secret: twitter_secret)

  if !@user
    @user = User.create(username: "#{@twitter_username}", oauth_token: twitter_token, oauth_secret: twitter_secret)
  end

  erb :authorized
end

# POST =========================================================================

post '/twitter_update' do
  user = User.find_by_username(params[:twitter_username])
  twitter_user = Twitter::Client.new( oauth_token: user.oauth_token, oauth_token_secret: user.oauth_secret)
  twitter_user.update(params[:tweet])
  redirect '/auth'
end
