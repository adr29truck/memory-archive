# frozen_string_literal: true

require 'dotenv'
require 'securerandom'

Dotenv.load

# Handeles server routes
class Server < Sinatra::Base
  enable :sessions
  before do
    if session[:cookie].nil?
      @first_time = true
      session[:cookie] = 'true'
    else
      @first_time = false
    end

    @first_visit = back.include?('/group/create') unless back.nil?
    @super_admin = session[:super_admin]
    @logged_in = session[:user_id]
    @cookies_allowed = session[:cookies]
    @class_id = session[:class_id]
    @admin = false
    unless @logged_in.nil?
      @groups = UserClass.where(user_id: @logged_in).join(:classes, id: :class_id).all.objectify('Classes')
      @admin = @groups.map { |e| e.class_id.to_i == @class_id.to_i }.include?(true)
    end

    @error_severity = session[:error_severity]
    @error_severity = 'danger' if @error_severity.nil?

    @flash = [[session[:error_message], @error_severity]]
    session[:error_message] = nil
    session[:error_severity] = nil
    SassCompiler.compile
  end

  #########
  # Index #
  #########

  get '/' do
    @path = '/'

    if !params[:group_id].nil? && UserClass.where(user_id: @logged_in, class_id: params[:group_id]).all.length == 1
      @class_id = params[:group_id]
      session[:class_id] = @class_id
    end

    if !@logged_in.nil? && !@class_id.nil?
      @users = User.fetch.join(:user_classes, user_id: :id).where(class_id: @class_id).all.objectify('User') # TODO: Optimize this one. Get all names of needed ids in SQL and do not filter users out "manually"
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
          post.author user.name if post.author_id.to_i == user.id.to_i
        end
        post.author = 'Removed' if post.author.nil?
      end
    end

    slim :index
  end

  ####################
  # Login & register #
  ####################

  get '/login/?' do
    session[:reverse] = back
    slim :login
  end

  post '/login' do
    user = User.new params
    x = User.where(email: params['email'])
    if x.all.empty?
      session[:error_severity] = 'info'
      session[:error_message] = 'No user with those details exists.'
      redirect '/login'
    end
    x = x.first.objectify('User')
    if x == user
      session[:user_id] = x.id
      session[:user_name] = x.name
      session[:super_admin] = x.admin == 1
      begin
        session[:class_id] = UserClass.fetch.where(user_id: x.id).all.objectify('UserClass').first.class_id
      rescue StandardError
      end
    else
      session[:error_severity] = 'info'
      session[:error_message] = 'No user with those details exists.'
      redirect '/login'
    end
    if session[:reverse].nil? || session[:reverse].include?('/login') || session[:reverse].include?('/new_password')
      redirect '/'
    end
    temp = session[:reverse]
    session[:reverse] = nil
    redirect temp
  end

  get '/logout/?' do
    cookies_allowed = @cookies_allowed
    session.clear
    session[:cookies] = cookies_allowed
    redirect '/'
  end

  get '/register/?' do
    session[:reverse] = back
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
      redirect '/' if session[:reverse].nil? || session[:reverse].include?('/login') || session[:reverse].include?('/register')
      redirect session[:reverse]
    else
      session[:error_message] = 'There is already an account with that email adress registered. Have you forgotten your password?'
      redirect '/login'
    end
  end

  get '/group/join' do
    if !@logged_in.nil?
      @identifier = params['identifier']
      if !@identifier.nil?
        @group = Classes.fetch.where(identifier: params['identifier']).all.objectify('Classes')
      else
        @group = nil
      end
      slim :join_group
    else
      session[:error_message] = 'Not signed in'
      redirect '/'
    end
  end

  post '/group/join' do
    if @logged_in.is_a? Integer
      begin
        id = Classes.where(identifier: params['identifier']).first.objectify('Classes').id
      rescue StandardError
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
        session[:error_message] = 'Successfully joined group'
        session[:error_severity] = 'valid'
        redirect "/?group_id=#{id}"
      rescue StandardError
        session[:error_message] = 'Invalid group code'
        redirect back
      end

    else
      session[:error_message] = 'Not signed in'
      redirect '/'
    end
  end

  get '/group/create' do
    if !@logged_in.nil?
      slim :create_group
    else
      session[:error_message] = 'Not signed in'
      redirect '/'
    end
  end

  post '/group/create' do
    if !@logged_in.nil?
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
      redirect '/'
    else
      session[:error_message] = 'Not signed in'
      redirect '/'
    end
  end

  post '/group/invite/new' do
    if !@logged_in.nil?
      begin
        group = @groups.select { |e| e if e.id == @class_id }.first

        non_html = "You have been invited to #{group.name}" \
                  'To join register an account if you do not already have one and then use the link below' \
                  " #{ENV['URL']}/group/join?identifier=#{group.identifier}"
        body = "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
          <html xmlns='http://www.w3.org/1999/xhtml'>
          <head>
            <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
            <title>Memory Archive</title>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'/>
            </head>
            <body style='width: 100%;'>
            <div style='width: 100%; height: 10vh; max-height: 100px; background-position: center center; background-repeat: no-repeat; background-size: cover; background-image: url(#{ENV['URL']}/img/hero_default-min.jpg);'>
            </div>
              <div>
                <div style='padding: 40px; background: rgba(0,0,0,0.1)'>
                  <h1 style='text-align: center; width: 100%;'>Memory Archive </h1>
                  <div style='height: 30px;'></div>
                  <h2 style='text-align: center; width: 100%;'>Group Invite</h2>
                  <h3 style='text-align: center;'>You have been invited to #{group.name}</h3>
                  <p style='text-align: center;'>To join register an account if you do not already have one by visiting <a href='#{ENV['URL']}/register' style='font-weight: bold;'>Memory Archive</a>. Then use <a href='#{ENV['URL']}/group/join?identifier=#{group.identifier}'>This link</a> or the code below to join.</p>
                  <div class='group_code' style='margin:auto auto; padding:1em 20px'>
                    <h2 style='width: 100%; text-align: center;'> Group code</h2>
                    <h2 class='subtilte' style='background: lightgrey; padding: 4px; text-align: center;'> #{group.identifier}</h2>
                  </div>
                </div>
                <footer style='width: 100%; padding: 0.5em;'>
                    <p style='width: 100%; text-align: center;'>If you do not want to join you can ignore this email.</p>
                </footer>
              </div>
            </body>
          </html>"

        params['email'].split(',').each do |email|
          Pony.mail(
            to: email,
            subject: 'Group Invite',
            html_body: body,
            body: non_html,
            via: :smtp,
            via_options: {
              address: 'smtp.gmail.com',
              port: '587',
              enable_starttls_auto: true,
              user_name: 'bobbisbyggaren@gmail.com',
              password: ENV['SMTP_PASSWORD'],
              authentication: :plain,
              domain: 'localhost.localdomain'
              # The HELO domain provided by the client to the server
            }
          )
        end

        session[:error_message] = 'A email with details on how to join has been sent to the provided adresses.'
        session[:error_severity] = 'valid'
      rescue StandardError
        session[:error] = 'Something went wrong. Try again'
        session[:error_severity] = 'danger'
      ensure
        redirect back
      end
    else
      session[:error_message] = 'Insufficient privilege'
      redirect back
    end
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
    rescue StandardError
      session[:error_message] = 'The session has expired'
      redirect '/login'
    end
    if user.nil?
      session[:error_message] = 'The session has expired'
    else
      user.new_password params['password']
      user.save
      ResetPassword.fetch.where(identifier: params['identifier']).delete
      session[:error_severity] = 'valid'
      session[:error_message] = 'Password updated'
    end
    redirect '/login'
  end

  get '/reset_password/?' do
    slim :password_reset
  end

  post '/reset_password' do
    user = User.fetch.where(email: params['email']).all.objectify('User')
    if user.nil? || user == []
      session[:error_message] = 'No user with those details found.'
      redirect back
    else
      identifier = user.first.reset_password
      p identifier
      body = "
      <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
        <html xmlns='http://www.w3.org/1999/xhtml'>
        <head>
          <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
          <title>Memmory Archive</title>
          <meta name='viewport' content='width=device-width, initial-scale=1.0'/>
          </head>
          <body style='width: 100%;'>
          <div style='width: 100%; height: 10vh; max-height: 100px; background-position: center center; background-repeat: no-repeat; background-size: cover; background-image: url(#{ENV['URL']}/img/hero_default-min.jpg);'>
          </div>
            <div>
              <div style='padding: 40px; background: rgba(0,0,0,0.1)'>
                <h1 style='text-align: center; width: 100%;'>Memmory Archive </h1>
                <div style='height: 30px;'></div>
                <h2 style='text-align: center; width: 100%;'>Password Reset </h2>
                <p style='text-align: center;'>Someone requested that the password for an account associated with your email should be changed.<p>
                <p style='text-align: center;'>Reset your password by pressing <a href='#{ENV['URL']}/new_password?identifier=#{identifier}' style='font-weight: bold;'>here</a></p>
              </div>
              <footer style='width: 100%; padding: 0.5em;'>
                  <p style='width: 100%; text-align: center;'>If you did not request a password reset you can ignore this email.</p>
              </footer>
            </div>
          </body>
        </html>"
      non_html = "Memmory Archive\nReset your password by visiting  #{ENV['URL']}/new_password?identifier=#{identifier} \nIf you did not request a password reset you do not have to take any further action."

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
        session[:error_message] = 'A email with details on how to reset your password has been sent to the given email address'
        session[:error_severity] = 'valid'
      rescue StandardError
        session[:error] = 'Something went wrong. Try again'
        session[:error_severity] = 'danger'
      ensure
        redirect back
      end
    end
  end

  ###############
  # Admin pages #
  ###############

  get '/admin/?' do
    slim :'admin/admin'
  end

  post '/admin/faq/save-question' do
    if params.include?('id')
      params['id'] = params['id'].to_i
    end
    params['answer'] = params['answer'].gsub(/\R+/, '<br><br>')
    new_question = Faq.new(params)
    new_question.save

    redirect '/faq'
  end

  post '/admin/faq/delete' do
    Faq.fetch.where(id: params['question_id']).delete
    redirect back
  end

  get '/admin/faq/:id/edit/?' do
    @question = Faq.fetch.where(id: params['id']).first.objectify('Faq')
    @question.answer = @question.answer.gsub('<br>', "\r\n")
    slim :'admin/admin_faq_edit'
  end

  ##############
  # User pages #
  ##############

  get '/post/create' do
    if !@logged_in.nil? && !@class_id.nil?
      slim :create_post
    else
      redirect '/'
    end
  end

  post '/post/create' do
    if !@logged_in.nil? && !@class_id.nil?
      begin
        file = params['file']
        tempfile = file[:tempfile]
        filename = file[:filename]

        path = (SecureRandom.uuid + '.' + filename.split('.').last).to_s
        File.open('./bin/public/files/' + path, 'wb') do |f|
          f.write(tempfile.read)
        end

        x = Post.new(message: params[:message], author_id: session[:user_id], time_stamp: DateTime.now.to_time.to_i, img_path: path, img_name: filename, class_id: @class_id)
        x.save
      rescue StandardError
        session[:error_message] = 'Something went wrong. Try again.'
        redirect '/post/create'
      end
      redirect "/post/#{x.id}"
    else
      session[:error_message] = 'Insufficient privilege'
      redirect '/'
    end
  end

  get '/group/join/?' do
    if !@logged_in.nil?
      @identifier = params['identifier']
      if !@identifier.nil?
        @group = Classes.fetch.where(identifier: params['identifier']).all.objectify('Classes')
      else
        @group = nil
      end
      slim :join_group
    else
      session[:error_message] = 'Not signed in'
      redirect '/'
    end
  end

  post '/group/join' do
    if @logged_in.is_a? Integer
      begin
        id = Classes.where(identifier: params['identifier']).first.objectify('Classes').id
      rescue StandardError
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
        session[:error_message] = 'Successfully joined group'
        session[:error_severity] = 'valid'
        redirect "/?group_id=#{id}"
      rescue StandardError
        session[:error_message] = 'Invalid group code'
        redirect back
      end

    else
      session[:error_message] = 'Not signed in'
      redirect '/'
    end
  end

  get '/group/create/?' do
    if !@logged_in.nil?
      slim :create_group
    else
      session[:error_message] = 'Not signed in'
      redirect '/'
    end
  end

  post '/group/create' do
    if !@logged_in.nil?
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
      redirect '/'
    else
      session[:error_message] = 'Not signed in'
      redirect '/'
    end
  end

  # TODO:
  get '/manage_group/?' do
    ids = []
    @groups.each do |ent|
      ids << ent.group_id
    end

    Classes.where(id: ids)

    slim :group_manage
  end

  get '/faq/?' do
    @all_questions = Faq.fetch_all.objectify('Faq')
    slim :faq
  end

  post '/faq/mail-question' do
    body = "
    <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
      <html xmlns='http://www.w3.org/1999/xhtml'>
      <head>
        <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
        <title>Memmory Archive</title>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'/>
        </head>
        <body style='width: 100%;'>
        <div style='width: 100%; height: 10vh; max-height: 100px; background-position: center center; background-repeat: no-repeat; background-size: cover; background-image: url(#{ENV['URL']}/img/hero_default-min.jpg);'>
        </div>
          <div>
            <div style='padding: 40px; background: rgba(0,0,0,0.1)'>
              <h1 style='text-align: center; width: 100%;'>Memmory Archive Admin</h1>
              <div style='height: 30px;'></div>
              <h2 style='text-align: center; width: 100%;'>Question by Email</h2>
              <p style='text-align: center;'>Someone emailed a question<p>
              <p style='text-align: center;'>Return address: #{params['email']}</p>
            </div>
          </div>
        </body>
      </html>"
    non_html = "#{params['question']}"
    
    begin
      Pony.mail(
        to: "le@ekstener.se",
        subject: 'Custom question',
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
      session[:error_message] = 'An email with your question has been sent to us and we will try to get back to you as fast as possible'
      session[:error_severity] = 'valid'
    rescue StandardError
      session[:error] = 'Something went wrong. Try again'
      session[:error_severity] = 'danger'
    ensure
      redirect back
    end
  end

  get '/cookie_policy' do
    @policy = Policy.cookie_policy
    slim :policy
  end
  
  get '/terms_and_conditions' do
    @policy = Policy.terms_and_conditions
    slim :policy
  end
  
  get '/privacy_policy' do 
    @policy = Policy.privacy_policy
    slim :policy
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
