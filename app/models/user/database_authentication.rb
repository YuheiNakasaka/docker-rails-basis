# frozen_string_literal: true

class User::DatabaseAuthentication < ApplicationRecord
  devise :database_authenticatable, :validatable, :registerable, :recoverable

  belongs_to :user
end
