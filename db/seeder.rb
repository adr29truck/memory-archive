# frozen_string_literal: true

require 'bcrypt'
require 'sequel'

DB = Sequel.sqlite('./db/data.db')

def reset_database!

  DB.drop_table? :user
  DB.drop_table? :user_classes
  DB.drop_table? :alert
  DB.drop_table? :post
  DB.drop_table? :reset_password
  DB.drop_table? :images
  DB.drop_table? :classes

  DB.create_table! :user do
    Integer :id, primary_key: true
    String :name
    String :email, unique: true
    String :encrypted_password
    Integer :admin
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

  puts 'Seeder run'
  puts 'Created tables'
end

def insert_data
  dataset = DB[:user]
  dataset.insert(name: 'John', email: 'john.example@example.example', encrypted_password: BCrypt::Password.create('admin'), admin: 1)
  dataset.insert(name: 'David', email: 'david.ek@example.example', encrypted_password: BCrypt::Password.create('admin'), admin: 0)
  dataset.insert(name: 'Gustav', email: 'gustav@example.example', encrypted_password: BCrypt::Password.create('admin'), admin: 0)
  dataset.insert(name: 'Admin', email: 'admin@admin', encrypted_password: BCrypt::Password.create('admin'), admin: 1)

  puts 'Inserted data'
end

reset_database!
insert_data
