class ListsController < ApplicationController

  get '/users/todos/:id/:page_id/lists' do
    @todo = Todo.find(params[:id])

    @page_id = [params[:page_id].to_i, START_PAGE].max
    @start_point = (@page_id - 1) * MAX_NUMBER_OF_ITEM
    @number_of_lists = List.where(todo_id: params[:id]).count(:id)

    @lists = List.where(todo_id: params[:id]).limit(MAX_NUMBER_OF_ITEM).offset(@start_point)

    erb :'lists/show'
  end

  get '/users/todos/:id/lists/new' do
    @todo = Todo.find(params[:id])

    erb :'lists/new'
  end

  get "/users/todos/:todo_id/lists/delete/:id" do
    redirect '/users/signin' unless signed_in?

    @todo = Todo.find_by(id: params[:todo_id])
    @list = List.find_by(id: params[:id])

    erb :'lists/delete'
  end

  delete "/users/todos/:todo_id/lists/delete/:id" do
    redirect '/users/signin' unless signed_in?

    @todo = Todo.find(params[:todo_id])
    @list = List.find(params[:id])

     
    flash[:success] = "#{@list.description} is deleted"
    @list.destroy

    
    redirect "/users/todos/#{@todo.id}/#{START_PAGE}/lists"
  end

  post '/users/todos/:id/lists/create' do
    @todo = Todo.find(params[:id])

    
    if empty_field?(params)
      flash[:alert] = "some field is empty"
      redirect "/users/todos/#{@todo.id}/lists/new" 
    end

    @list = create_list(params)
    flash[:success] = "#{@list.description} is created"

    redirect  "/users/todos/#{@todo.id}/#{START_PAGE}/lists"  
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
    redirect '/users/signin' unless signed_in?

    @todo = Todo.find(params[:todo_id])
    @list = List.find(params[:id])

    flash[:success] = "#{@list.description} is done"
    @list.update(is_end: !@list.is_end)

    redirect "/users/todos/#{@todo.id}/#{START_PAGE}/lists"
  end

  patch '/users/todos/:todo_id/lists/update/:id' do
    redirect '/users/signin' unless signed_in?

    @todo = Todo.find(params[:todo_id])
    @list = List.find(params[:id])

    list_info = fill_empty_field(params, @list)

    @list = update_list(list_info, @list)
    flash[:success] = "#{@list.description} is updated"

    redirect  "/users/todos/#{@todo.id}/#{START_PAGE}/lists"
  end

  private

  def empty_field?(list_info)
    list_info[:description].strip == "" || list_info[:start_date].strip == "" || list_info[:end_date].strip == ""
  end

  def fill_empty_field(list_info, list)
    list_info[:description] = list.description if list_info[:description] == ""

    list_info[:start_date] = list.start_date if list_info[:start_date] == "" 

    list_info[:end_date] = list.end_date if list_info[:end_date] == ""

    list_info
  end

  def create_list(list_info)
    list = List.new(description: list_info[:description], start_date: list_info[:start_date], end_date: list_info[:end_date])
    list.todo_id = list_info[:id]
    list.is_end = false
    list.save
    list
  end

  def not_authenticate_user(user_info)
    user = User.find_by(username: params[:username])
    current_user = User.find(session[:user_id])
    !(user == current_user && user.authenticate(user_info[:password]))
  end

  def update_list(list_info, list)
    list.update(description: list_info[:description], start_date: list_info[:start_date], end_date: list_info[:end_date])
    list
  end
end


