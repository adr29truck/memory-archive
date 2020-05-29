# frozen_string_literal: true

require_relative 'application_controller'

# Handles policy specific methods
class Policy < ApplicationController
  set_columns :id, :title, :body
  set_table :policy

  def self.privacy_policy
    fetch.where(id: 1).all.objectify('Policy').first
  end

  def self.cookie_policy
    fetch.where(id: 2).all.objectify('Policy').first
  end

  def self.terms_and_conditions
    fetch.where(id: 3).all.objectify('Policy').first
  end
end