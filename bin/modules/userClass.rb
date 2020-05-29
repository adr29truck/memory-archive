# frozen_string_literal: true

require_relative 'application_controller'

# Handles user_class specific methods
class UserClass < ApplicationController
  set_columns :user_id, :class_id, :admin
  set_table :user_classes
end
