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

    unless @logged_in.nil?
      @groups = UserClass.where(user_id: @logged_in).join(:classes, id: :class_id).all.objectify('Classes')
    end
    
    @error_severity = session[:error_severity]
    if @error_severity.nil?
      @error_severity = 'danger'
    end
    @flash = [[session[:error_message], @error_severity]]
    session[:error_message] = nil
    session[:error_severity] = nil
    SassCompiler.compile
  end

  get '/' do
    @path = '/'
    # flash[:notice] = "Hooray, Flash is working!"

    if !params[:group_id].nil? && UserClass.where(user_id: @logged_in, class_id: params[:group_id]).all.length == 1
      @class_id = params[:group_id]
      session[:class_id] = @class_id
    end

    if !@logged_in.nil? && !@class_id.nil?
      @users = User.fetch.all.objectify('User') # TODO: Optimize this one. Get all names of needed ids in SQL and do not filter users out "manually"
      if params['page'].nil? || params['page'] == '1'
        @posts = Post.where(class_id: @class_id).order(:time_stamp).reverse.limit(10).all.objectify('Post')
        @page = 1
      else
        @page = params['page'].to_i
        count = (params['page'].to_i - 1) * 10
        @posts = Post.where(class_id: @class_id).order(:time_stamp).reverse.limit(count...count + 10).all.objectify('Post')
      end
      showing_after_this_page = @page * 10
      target = Post.where(class_id: @class_id).count(:id)

      @more_content = showing_after_this_page.to_i < target.to_i

      # Adds the author name
      @posts.each do |post|
        @users.each do |user|
          if post.author_id.to_i == user.id.to_i
            post.author user.name
          end
        end
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

    path = (SecureRandom.uuid + '.' + filename.split('.').last).to_s
    File.open('./bin/public/files/' + path, 'wb') do |f|
      f.write(tempfile.read)
    end

    x = Post.new(message: params[:message], author_id: session[:user_id], time_stamp: DateTime.now.to_time.to_i, img_path: path, img_name: filename, class_id: @class_id)
    x.save

    redirect "/post/#{x.id}"
  end

  post '/login' do
    user = User.new params
    x = User.where(email: params['email'])
    if x.all.empty?
      session[:error_message] = 'No user with those details exists.'
      redirect '/login'
    end
    x = x.first.objectify('User')
    if x == user
      session[:user_id] = x.id
      session[:admin] = x.admin == 1
      begin
        session[:class_id] = UserClass.fetch.where(user_id: x.id).all.objectify('UserClass').first.class_id
      rescue StandardError
        session[:error_message] = 'No groups.'
      end
    else
      session[:error_message] = 'No user with those details exists.'
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
      session[:error_message] = 'Terms where not fulfilled'
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
      session[:error_message] = 'There is already an account with that email adress registered. Have you forgotten your password?'
      redirect '/login'
    end
  end

  get '/group/join' do
    @identifier = params['identifier']
    slim :join_group
  end

  post '/group/join' do
    if @logged_in.is_a? Integer
      begin
        id = Classes.where(identifier: params['identifier']).first.objectify('Classes').id
      rescue
        session[:error_message] = 'Invalid group code'
        redirect back
      end

      @groups.each do |group|
        if group.class_id == id
          session[:error_message] = 'Already in group'
          redirect "/?group_id=#{id}"
        end
      end

      begin
        z = UserClass.new(user_id: @logged_in, class_id: id, admin: 0)
        z.save
        redirect "/?group_id=#{id}"
      rescue
        session[:error_message] = 'Invalid group code'
        redirect back
      end

    else
      session[:error_message] = 'Not signed in'
      redirect '/'
    end
  end

  get '/group/create' do
    slim :create_group
  end

  post '/group/create' do
    begin
      file = params['file']
      tempfile = file[:tempfile]
      filename = file[:filename]

      path = (SecureRandom.uuid + '.' + filename.split('.').last).to_s
      File.open('./bin/public/files/' + path, 'wb') do |f|
        f.write(tempfile.read)
      end
      params.delete :file

      params[:img_path] = path
    rescue StandardError
      params[:img_path] = 'default_img.png'
    end

    params[:identifier] = SecureRandom.uuid
    x = Classes.new(params)
    x.save

    z = UserClass.new(user_id: @logged_in, class_id: x.id, admin: 1)
    z.save

    session[:class_id] = x.id
    redirect "/group/users?=#{x.id}"
  end

  # TODO:
  get '/manage_group' do
    ids = []
    @groups.each do |ent|
      ids << ent.group_id
    end

    Classes.where(id: ids)

    slim :group_manage
  end

  get '/new_password' do
    @identifier = params['identifier']
    slim :password_new
  end

  post '/password_new' do
    begin
      user = User.fetch.where(identifier: params['identifier']).join(:reset_password, user_id: :id).first.objectify('User')
      user.remove_instance_variable(:@user_id)
      user.remove_instance_variable(:@identifier)
    rescue
      session[:error_message] = 'The session has expired'
      redirect '/login'
    end
    if user.nil?
      session[:error_message] = 'The session has expired'
    else
      user.new_password params['password']
      user.save
      ResetPassword.fetch.where(identifier: params['identifier']).delete

      session[:error_message] = 'Password updated'
    end
    redirect '/login'
  end

  get '/reset_password' do
    slim :password_reset
  end

  post '/reset_password' do
    user = User.fetch.where(email: params['email']).all.objectify('User')
    p user
    if user.nil? || user == []
      redirect back
    else
      identifier = user.first.reset_password
      p identifier
      # <header style='width: 100%; height: 10vh; max-height: 100px; background: url('#{ENV['URL']}/img/hero_default.png')'> </header>
      body = "
        <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
        <html xmlns='http://www.w3.org/1999/xhtml'>
        <head>
          <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
          <title>Memmory Archive</title>
          <meta name='viewport' content='width=device-width, initial-scale=1.0'/>
        </head>
        <body syle='width: 100%; min-height: 100vh;'>
        <div>
          <header style='width: 100%; height: 10vh; max-height: 100px; background: url('http://localhost:9292/img/hero_default.png')'> </header>
          <div style='padding: 40px; background: rgba(0,0,0,0.1)'>
            <h1 style='text-align: center; width: 100%;'>Memmory Archive </h1>
            <div style='height: 30px;'></div>
            <h2 style='text-align: center; width: 100%;'>Password Reset </h2>
            <p>Someone requested that the password for an account associated with your emailadress should be changed.<p>
            <p>Reset your password by pressing <a href='#{ENV['URL']}/new_password?identifier=#{identifier}' style='font-weight: bold;'>here</a></p>
        </div>
        <footer style='width: 100%; padding: 0.5em;'>
            <p style='width: 100%; text-align: center;'>If you did not request a password reset you will need to do a password reset the next time you intend to sign in.</p>
        </footer>
        </div>
        </body>
        </html>"
      non_html = "Memmory Archive\nReset your password by visiting  #{ENV['URL']}/new_password?identifier=#{identifier} \nIf you did not request a password reset you do not have to take any further action."

      # image = File.open('./public/img/hero_default.jpg')

      begin

        Pony.mail(
          to: params['email'],
          subject: 'Password reset',
          html_body: body,
          body: non_html,
          # attachments: {image: image},
          via: :smtp,
          via_options: {
            address: 'smtp.gmail.com',
            port: '587',
            enable_starttls_auto: true,
            user_name: 'bobbisbyggaren@gmail.com',
            password: ENV['SMTP_PASSWORD'],
            authentication: :plain, # :plain, :login, :cram_md5, no auth by default
            domain: 'localhost.localdomain'
            # The HELO domain provided by the client to the server
          }
        )
        session[:error] = 'Message sent successfully'
        session[:error_type] = 200
      rescue StandardError
        session[:error] = 'Something went wrong. Try again'
        session[:error_type] = 500
      ensure
        redirect back
      end
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
