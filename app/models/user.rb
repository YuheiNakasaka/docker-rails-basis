# frozen_string_literal: true

class User < ApplicationRecord
  devise :authenticatable

  has_one :database_authentication, dependent: :destroy
end
