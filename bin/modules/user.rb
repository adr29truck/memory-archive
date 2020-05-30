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

  # Gives user admin acces
  def make_admin
    self.admin = 1
  end

  # Removes users admin acces
  def remove_admin
    self.admin = 0
  end

  # Compares if passwords match the one on record
  def ==(other)
    begin
      BCrypt::Password.new(encrypted_password) == other.password
    rescue StandardError
      false
    end
  end

  # Sets a new password of a user
  def new_password(new_pass)
    self.encrypted_password = BCrypt::Password.create(new_pass)
  end

  # Initiates password reset for a user
  #
  # Returns reset_password identifier
  def reset_password
    ResetPassword.reset(user_id: id)
  end
end
