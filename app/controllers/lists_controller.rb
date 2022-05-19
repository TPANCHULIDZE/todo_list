class ListsController < ApplicationController

  get '/users/todos/:id/lists' do
    @todo = Todo.find(params[:id])
    @lists = List.where(todo_id: params[:id])
    erb :'lists/show'
  end

  get '/users/todos/:id/lists/new' do
    @todo = Todo.find(params[:id])
    erb :'lists/new'
  end

  post '/users/todos/:id/lists/create' do
    @todo = Todo.find(params[:id])
     if params[:description] == "" || params[:start_date] == "" || params[:end_date] == ""
      redirect "/users/todos/#{@todo.id}/lists/new"
    else
      @list = List.new(description: params[:description], start_date: params[:start_date], end_date: params[:end_date])
      @list.todo_id = @todo.id
      @list.is_end = false
      @list.save
      redirect  "/users/todos/#{@todo.id}/lists"    
    end
  end

  get '/users/todos/:todo_id/lists/edit/:id' do
    @todo = Todo.find(params[:todo_id])
    @list = List.find(params[:id])
    erb :'lists/edit'
  end

  get "/users/todos/:todo_id/lists/edit/value/:id" do
    @list = List.find(params[:id])
    @todo = Todo.find(params[:todo_id])
    erb :'lists/edit_value'
  end

  patch "/users/todos/:todo_id/lists/update/value/:id" do
    if signed_in?
      @current_user = User.find(session[:user_id])
      @user = User.find_by(username: params[:username])
      @todo = Todo.find(params[:todo_id])
      @list = List.find(params[:id])
      if @user == @current_user && @user.authenticate(params[:password])
        @list.update(is_end: !@list.is_end)
        redirect "/users/todos/#{@todo.id}/lists"
      else
        redirect "/users/todos/#{@todo.id}/lists/edit/value/#{@list.id}"
      end
    else
      redirect '/users/signin'
    end
  end

  patch '/users/todos/:todo_id/lists/update/:id' do
    if signed_in?
      @current_user = User.find(session[:user_id])
      @user = User.find_by(username: params[:username])
      @todo = Todo.find(params[:todo_id])
      @list = List.find(params[:id])
      if @user == @current_user && @user.authenticate(params[:password])
        if params[:description] == "" || params[:start_date] == "" || params[:end_date] == ""
          redirect "/users/todos/#{@todo.id}/lists/edit/#{@list.id}"
        else
          @list.update(description: params[:description], start_date: params[:start_date], end_date: params[:end_date])
          redirect  "/users/todos/#{@todo.id}/lists"
        end
      else
        redirect "/users/todos/#{@todo.id}/lists/edit/#{@list.id}"
      end
    else
      redirect '/users/signin'
    end
  end

end


