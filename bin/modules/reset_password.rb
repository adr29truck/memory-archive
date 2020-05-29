# frozen_string_literal: true

require 'securerandom'
require_relative 'application_controller'

# Handles password specific methods
class ResetPassword < ApplicationController
  set_columns :user_id, :identifier
  set_table :reset_password

  # Handles password reset
  #
  # params - Hash
  #
  # Returns reset identifier as a String
  def self.reset(params)
    ResetPassword.fetch.where(user_id: params[:user_id]).delete

    params['identifier'] = SecureRandom.uuid
    x = new params
    x.save

    params['identifier']
  end
end
