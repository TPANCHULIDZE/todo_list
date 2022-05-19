require './config/environment'

class UsersController < ApplicationController

  get '/users' do
    @users = User.all
    erb :'users/index'
  end

  get '/users/signup' do
    if !signed_in?
      erb :'users/new'
    else
      redirect to '/lists'
    end
  end

  post '/users/create' do
    if params[:username] == "" || params[:password] == "" || params[:email] == ""
      redirect to '/users/signup'
    else 
      @user = User.create(username: params[:username], email: params[:email], password: params[:password])
      session[:user_id] = @user.id
      session[:username] = @user.username
      redirect "/"
    end
  end

  get '/users/signin' do
    if !signed_in?
      erb :'users/signin'
    else
      redirect to '/'
    end
  end

  post '/users/signin' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      session[:username] = @user.username
      redirect "/"
    else
      redirect '/users/signin'
    end
  end

  get '/users/logout' do
    if signed_in?
      session.destroy
      erb :'users/logout'
    else
      redirect '/'
    end
  end

  get '/users/edit' do
    if signed_in?
      erb :'users/edit'
    else
      redirect '/users/signin'
    end
  end

  patch '/users/update' do
    @user = User.find_by(username: params[:username])
    @current_user = User.find_by(id: session[:user_id])
    if @user == @current_user && @user.authenticate(params[:password])
      if params[:new_username] == "" || params[:new_password] == "" || params[:new_email] == ""
        redirect to '/users/edit'
      else 
        @user.update(username: params[:new_username], email: params[:new_email], password: params[:new_password])
        session[:user_id] = @user.id
        session[:username] = @user.username
        redirect "/"
      end
    else
      redirect '/users/edit'
    end
  end

end

