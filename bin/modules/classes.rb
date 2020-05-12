# frozen_string_literal: true

require_relative 'application_controller'

# Handles user specific methods
class Classes < ApplicationController
  set_columns :id, :name, :description, :identifier, :img_path
  set_table :classes
end
