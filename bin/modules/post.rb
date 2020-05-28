# frozen_string_literal: true

require_relative 'application_controller'

# Handles user specific methods
class Post < ApplicationController
  set_columns :id, :message, :author_id, :time_stamp, :img_path, :img_name
  set_table :post

  def author(value = nil)
    if value.nil?
      @author
    else
      @author = value
    end
  end
end
