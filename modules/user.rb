# frozen_string_literal: true

require 'bcrypt'
require_relative 'application_controller'

# Handles user specific methods
class User < ApplicationController
  set_columns :id, :name, :email, :encrypted_password, :admin
  set_table :user

  # Creates a new user based on provided params
  #
  # params - (Hash - name, password, email, admin)
  def self.create(params)
    params['encrypted_password'] = BCrypt::Password.create(params['password'])
    params.delete :password
    params.delete :terms
    User.new(params)
  end

  def make_admin
    self.admin = 1
  end

  def remove_admin
    self.admin = 0
  end

  def ==(other)
    begin
      BCrypt::Password.new(encrypted_password) == other.password
    rescue
      false
    end
  end

  def new_password(new_pass)
    self.encrypted_password = BCrypt::Password.create(new_pass)
  end

  def reset_password
    self.encrypted_password = 'potatis'
    self.save

    ResetPassword.reset(user_id: self.id)
  end
end
