require 'pg'
require 'sinatra/flash'

class TodosController < ApplicationController

  get '/users/:id/todos' do
    redirect '/users/signin' unless signed_in?

    @page_id = [params[:id].to_i, START_PAGE].max
    @start_point = (@page_id - 1) * MAX_NUMBER_OF_ITEM
    @number_of_todos = Todo.where(user_id: session[:user_id]).count(:id)

    @todos = Todo.where(user_id: session[:user_id]).limit(MAX_NUMBER_OF_ITEM).offset(@start_point)

    erb :'todos/show'
  end

  get '/users/todos/add' do
    redirect "/users/signin" unless signed_in?

    @user = User.find_by(id: session[:user_id])

    erb :'todos/new'
  end

  post '/users/todos/create' do
    redirect "/users/signin" unless signed_in?

    if params[:title] == ""
      flash[:alert] = "title is empty" 
      redirect '/users/todos/add' 
    end

    @todo = create_todo(params)
    flash[:success] = "new todo is create"
    
    redirect "/users/#{START_PAGE}/todos"
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

    if (not_authenticate_user(params) || params[:new_title] == "")
      flash[:alert] = "some information is not correct"
      redirect "/users/todos/edit/#{params[:id]}" 
    end

    @todo.update(title: params[:new_title])
    flash[:success] = "successfully update #{@todo.title}"

    redirect "/users/#{START_PAGE}/todos" 
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

    if not_authenticate_user(params)
      flash[:alert] = "username or password is not correct"
      redirect "/users/todos/delete/#{params[:id]}" 
    end

    todo_name = @todo.title
    @todo.destroy
    flash[:success] = "#{todo_name} is deleted"

    redirect "/users/#{START_PAGE}/todos" 
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