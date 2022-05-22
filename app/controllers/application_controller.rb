require './config/environment'

class ApplicationController < Sinatra::Base
  MAX_NUMBER_OF_ITEM = 2
  START_PAGE = 1
  
  configure do
    set :views, "app/views"
    set :public_dir, "public"
    enable :sessions
    register Sinatra::Flash
  end

  get "/" do
    erb :show
  end

  def signed_in?
    !!session[:user_id]
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
end