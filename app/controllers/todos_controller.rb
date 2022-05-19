require 'pg'
class TodosController < ApplicationController
    
  get '/users/todos' do
    if signed_in?
      @todos = Todo.where(user_id: session[:user_id])
      erb :'todos/index'
    else
      redirect '/users/signin'
    end
  end

  get '/users/todos/add' do
    @user = User.find_by(id: session[:user_id])
    erb :'todos/new'
  end

  post '/users/todos/create' do
    if params[:title] == ""
      redirect '/users/todos/add'
    else
      @todo = Todo.new(title: params[:title])
      @todo.user_id = session[:user_id]
      @todo.save
      redirect '/users/todos'
    end
  end

  get '/users/todos/edit/:id' do
    if signed_in?
      @user = User.find(session[:user_id])
      @todo = Todo.find(params[:id])
      erb :'todos/edit'
    else
      redirect '/users/signin'
    end
  end

  patch '/users/todos/update/:id' do
    if signed_in?
      @current_user = User.find(session[:user_id])
      @user = User.find_by(username: params[:username])
      @todo = Todo.find(params[:id])
      if @user == @current_user && @user.authenticate(params[:password])
        if params[:new_title] == ""
          redirect "/users/todos/edit/#{params[:id]}"
        else
          @todo.update(title: params[:new_title])
          redirect '/users/todos'
        end
      else
        redirect "/users/todos/edit/#{params[:id]}"
      end
    else
      redirect '/users/signin'
    end
  end

  get '/users/todos/delete/:id' do
    if signed_in?
      @user = User.find_by(id: session[:user_id])
      @todo = Todo.find_by(id: params[:id])
      erb :'todos/delete'
    else
      redirect '/users/signin'
    end
  end

  delete '/users/todos/delete/:id' do
    if signed_in?
      @current_user = User.find(session[:user_id])
      @user = User.find_by(username: params[:username])
      @todo = Todo.find(params[:id])
      if @user == @current_user && @user.authenticate(params[:password])
        @todo.destroy
        redirect '/users/todos'
      else
        redirect "/users/todos/delete/#{params[:id]}"
      end
    else
      redirect '/users/signin'
    end
  end

end