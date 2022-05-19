require './config/environment'

class UsersController < ApplicationController

  get '/users' do
    @users = User.all
    erb :'users/show'
  end

  get '/users/signup' do
    redirect '/lists' if signed_in?
   
    erb :'users/new'
  end

  post '/users/create' do
    redirect to '/users/signup' if not_validate_information?(params)
   
    @user = create_user(params)
    fill_session(@user)

    redirect "/"
  end

  get '/users/signin' do
    redirect '/' if signed_in?
    
    erb :'users/signin'
  end

  post '/users/signin' do
    @user = find_user(params[:username])

    if @user && @user.authenticate(params[:password])
      fill_session(@user)
      redirect "/"
    else
      redirect '/users/signin'
    end
  end

  get '/users/logout' do
    redirect '/' unless signed_in?
    
    session.destroy
    erb :'users/logout'
  end

  get '/users/edit' do
    redirect '/users/signin' unless signed_in?
    
    erb :'users/edit'
  end

  patch '/users/update' do
    user_info = params
    @user = find_user(user_info[:username])
    user_info = become_validate_information(user_info, @user)
    
    redirect '/users/edit' if is_incorrect_information_for_update?(@user, user_info)

    update_user(@user, user_info)

    redirect "/"
  end

  private

  def fill_session(user)
    session[:user_id] = user.id
    session[:username] = user.username
  end

  def find_user(username)
    User.find_by(username: username)
  end

  def correct_user(user, user_info)
    user == current_user() && user.authenticate(user_info[:password])
  end

  def become_validate_information(user_info, user)
    user_info[:new_username] = user.username if user_info[:new_username] == ""

    user_info[:new_password] = user.password if user_info[:new_password] == "" 

    user_info[:new_email] = user.email if user_info[:new_email] == ""

    user_info
  end

  def not_validate_information?(user_info)
    is_not_every_field_fill?(user_info) || is_username_used?(user_info[:username])
  end

  def is_incorrect_information_for_update?(user, user_info)
    is_username_used?(user_info[:new_username]) || !correct_user(user, user_info)
  end

  def is_username_used?(username)
    User.find_by(username: username) && session[:username] != username
  end

  def is_not_every_field_fill?(user_info)
    user_info[:username] == "" || user_info[:password] == "" || user_info[:email] == ""
  end

  def update_user(user, user_info)
    user.update(username: user_info[:new_username], email: user_info[:new_email], password: user_info[:new_password])
    fill_session(user)
  end

  def create_user(user_info)
    User.create(username: user_info[:username], email: user_info[:email], password: user_info[:password])
  end
end

