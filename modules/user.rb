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
    BCrypt::Password.new(encrypted_password) == other.password
  end
end
