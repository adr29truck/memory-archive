# frozen_string_literal: true

require_relative 'application_controller'

# Handles post specific methods
class Post < ApplicationController
  set_columns :id, :message, :author_id, :time_stamp, :img_path, :img_name
  set_table :post

  # Sets author of post or returns it
  #
  # value - String (Optional author name)
  #
  # Returns author_name as String
  def author(value = nil)
    if value.nil?
      @author
    else
      @author = value
    end
  end
end
