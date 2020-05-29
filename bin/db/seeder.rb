# frozen_string_literal: true

require 'bcrypt'
require 'sequel'

DB = Sequel.sqlite('./bin/db/data.db')

def reset_database!
  DB.drop_table? :user
  DB.drop_table? :user_classes
  DB.drop_table? :alert
  DB.drop_table? :post
  DB.drop_table? :reset_password
  DB.drop_table? :images
  DB.drop_table? :classes
  DB.drop_table? :policy

  DB.create_table! :user do
    Integer :id, primary_key: true
    String :name
    String :email, unique: true
    String :encrypted_password
    Integer :admin
  end

  DB.create_table! :policy do
    Integer :id, primary_key: true
    String :title
    String :body
  end

  DB.create_table! :user_classes do
    Integer :user_id
    Integer :class_id
    Integer :admin
  end

  DB.create_table! :classes do
    Integer :id, primary_key: true, unique: true, auto_increment: true
    String :name, null: false
    String :description
    String :identifier, null: false
    String :img_path, null: true
  end

  DB.create_table! :alert do
    Integer :id, primary_key: true, unique: true, auto_increment: true
    Integer :valid_until, null: true
    Integer :valid, null: true
    String :level, null: true
    String :message, null: true
    Integer :read_more, null: true
    String :read_more_link
  end

  DB.create_table! :post do
    Integer :id, primary_key: true, unique: true, auto_increment: true
    String :message, null: true
    Integer :author_id, null: false
    Integer :time_stamp, null: false
    String :img_path, null: false
    String :img_name, null: false
    Integer :class_id, null: false
  end

  DB.create_table! :reset_password do
    Integer :user_id, unique: true
    String :identifier, unique: true
  end

  puts 'Seeder ran'
  puts 'Created tables'
end

def insert_data
  dataset = DB[:user]
  dataset.insert(name: 'John', email: 'john.example@example.example', encrypted_password: BCrypt::Password.create('admin'), admin: 1)
  dataset.insert(name: 'David', email: 'david.ek@example.example', encrypted_password: BCrypt::Password.create('admin'), admin: 0)
  dataset.insert(name: 'Gustav', email: 'gustav@example.example', encrypted_password: BCrypt::Password.create('admin'), admin: 0)
  dataset.insert(name: 'Admin', email: 'admin@admin', encrypted_password: BCrypt::Password.create('admin'), admin: 1)

  dataset = DB[:policy]
  dataset.insert(title: 'Privacy Policy', body: '<h3> PRivat</h3>', id: 1)
  dataset.insert(title: 'Cookie Policy', body: '
    <p>To give you as the visitor the best possible experience on our website, we utilize cookies. Cookies are used so that we can save your interactions and choices made on the website. 
    <br>In some instances third-parties might place cookies on your device to track statistics of user interactions.</p>
    <p>You can change the settings on your device to avoid us and third-parties from placing cookies on your device. Such settings would cause some functions on our website do not work.<p>
    <h1 class="title is-4">What are cookies?</h4>
    <p>A cookie is a small amount of data with a uniquely identifiable label. The data is sent from our servers to your device where the browser saves it to its memory so that the website can recognize your device.</p>
    <p>All websites can place cookies on your device if your browser settings allow for it. For this information not to be abused, websites can only read data from cookies that they placed on your device.</p>
    <p>There are two types of cookies, permanent and temporary. Permanent cookies are stored in a file on your device during a longer time frame. Temporary cookies are temporarily placed on your device when visiting a website but disappear after closing down the page, meaning they are not permanently stored on your device. Most companies use cookies on their webpages to improve user experience. And the use of cookies can not damage your files or increase the risks of malware on your device</p>

    <p>As a user you can change the settings to allow the use of cookies automatically in your browser or if you want to be asked before they are stored or if you do not agree to any cookies being placed on your device.</p>
    <p>Our cookies are used to improve the user experience, with interactive messages, the ability to login and use the webpages intended functions.<br>If you choose to deactivate cookies we can not provide our services to you, as cookies are required for our site to function properly.</p>
    <br>
    <p>More information about cookies are available at <a href="https://www.allaboutcookies.org/cookies/">www.allaboutcookies.org</a></p>
    <br>
    <p>All browsers are different. To find information on how to change the settings for cookies look for information in the help function of your browser. You can also manually erase all cookies from your device. This can be done through the browsers settings.</p>', id: 2)
  dataset.insert(title: 'Terms and Conditions', body: 'admin@admin', id:3)

  puts 'Inserted data'
end

reset_database!
insert_data
