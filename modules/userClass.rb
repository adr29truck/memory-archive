# frozen_string_literal: true


require_relative 'application_controller'

# Handles user specific methods
class UserClass < ApplicationController
  set_columns :id, :name, :email, :encrypted_password, :admin
  set_table :user_classes
end
