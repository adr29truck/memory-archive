# frozen_string_literal: true

require_relative 'application_controller'

# Handles faq specific methods
class Faq < ApplicationController
  set_columns :id, :question, :answer
  set_table :faq
end