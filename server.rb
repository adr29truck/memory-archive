# frozen_string_literal: true

require 'dotenv'
require 'securerandom'

Dotenv.load

# Handeles server routes
class Server < Sinatra::Base
  enable :sessions
  before do
    @admin = session[:admin]
    @logged_in = session[:user_id]
    @cookies_allowed = session[:cookies]
    @class_id = session[:class_id]

    if @logged_in != nil
      @groups = UserClass.where(user_id: @logged_in).join(:classes, id: :class_id).all.objectify('Classes')
    end
  end

  get '/' do
    if params[:group_id] != nil && UserClass.where(user_id: @logged_in, class_id: params[:group_id]).all.length == 1
      @class_id = params[:group_id]
      session[:class_id] = @class_id
    end

    if @logged_in != nil && @class_id != nil
      if params['page'] == nil || params['page'] == '1'
        @posts = Post.where(class_id: @class_id).order(:time_stamp).reverse.limit(10).all.objectify('Post')
        @page = 1
      else
        @page = params['page'].to_i
        count = ((params['page'].to_i) -1) * 10
        @posts = Post.where(class_id: @class_id).order(:time_stamp).reverse.limit(count...count+10).all.objectify('Post')
      end
      showing_after_this_page = @page * 10
      target = Post.where(class_id: @class_id).count(:id)

      if showing_after_this_page.to_i >= target.to_i
        @more_content = false
      else
        @more_content = true
      end
                        
    end
    slim :index
  end

  get '/login/?' do
    slim :login
  end


  get '/post/create' do
    slim :create_post
  end

  post '/post/create' do

    file = params['file']
    tempfile = file[:tempfile]
    filename = file[:filename]

    path = "#{SecureRandom.uuid + "." +filename.split('.').last}"
    File.open("./public/files/" + path, 'wb') do |f|
      f.write(tempfile.read)
    end

    x = Post.new({message: params[:message], author_id: session[:user_id], time_stamp: DateTime.now.to_time.to_i, img_path: path, img_name: filename, class_id: @class_id})
    x.save

    redirect "/post/#{x.id}"
  end

  post '/login' do
    user = User.new params
    x = User.where(email: params['email'])
    if x.all.empty?
      session[:error_message] = 'Fel epostadress eller lösendord.'
      redirect '/login'
    end
    x = x.first.objectify('User')
    if x == user
      session[:user_id] = x.id
      session[:admin] = x.admin == 1
      session[:class_id] = UserClass.fetch.where(user_id: x.id).all.objectify('UserClass').first.class_id
    else
      session[:error_message] = 'Fel epostadress eller lösendord.'
      redirect '/login'
    end
    redirect '/'
  end

  get '/logout/?' do
    cookies_allowed = @cookies_allowed
    session.clear
    session[:cookies] = cookies_allowed
    redirect '/'
  end

  get '/register/?' do
    slim :register
  end

  post '/register' do
    if params['terms'] != 'on'
      session[:error_message] = 'Villkoren upfylldes ej.'
      redirect '/register'
    end
    params.delete :terms
    x = User.where(email: params['email'])
    if x.all.empty?
      user = User.create params
      user.save
      session[:user_id] = user.id
      redirect '/'
    else
      session[:error_message] = 'Det finns redan ett konto med den epostadressen. Har du glömt ditt lösenord?'
      redirect '/login'
    end
  end

  post '/cookie_deny' do
    session[:cookies] = false
    redirect back
  end

  post '/cookie_allow' do
    session[:cookies] = true
    redirect back
  end

  not_found do
    slim :not_found
  end
end
