require 'pg'
class TodosController < ApplicationController
    
  get '/users/todos' do
    redirect '/users/signin' unless signed_in?

    @todos = Todo.where(user_id: session[:user_id])

    erb :'todos/index'
  end

  get '/users/todos/add' do
    @user = User.find_by(id: session[:user_id])

    erb :'todos/new'
  end

  post '/users/todos/create' do
    redirect '/users/todos/add' if params[:title] == ""
      
    @todo = create_todo(params)

    redirect '/users/todos'
  end

  get '/users/todos/edit/:id' do
    redirect '/users/signin' unless signed_in?

    @user = User.find(session[:user_id])
    @todo = Todo.find(params[:id])

    erb :'todos/edit'
  end

  patch '/users/todos/update/:id' do
    redirect '/users/signin' unless signed_in?

    @todo = Todo.find(params[:id])

    redirect "/users/todos/edit/#{params[:id]}" if (not_authenticate_user(params) || params[:new_title] == "")

    @todo.update(title: params[:new_title])
    
    redirect '/users/todos'    
  end

  get '/users/todos/delete/:id' do
    redirect '/users/signin' unless signed_in?

    @user = User.find_by(id: session[:user_id])
    @todo = Todo.find_by(id: params[:id])

    erb :'todos/delete'
  end

  delete '/users/todos/delete/:id' do
    redirect '/users/signin' unless signed_in?

    @todo = Todo.find(params[:id])

    redirect "/users/todos/delete/#{params[:id]}" if not_authenticate_user(params)
      
    @todo.destroy
    
    redirect '/users/todos'  
  end

  private 

  def create_todo(todo_info)
    @todo = Todo.new(title: params[:title])
    @todo.user_id = session[:user_id]
    @todo.save
    @todo
  end

  def not_authenticate_user(user_info)
    user = User.find_by(username: params[:username])
    current_user = User.find(session[:user_id])
    !(user == current_user && user.authenticate(user_info[:password]))
  end

end