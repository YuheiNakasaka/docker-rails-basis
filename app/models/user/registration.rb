# frozen_string_literal: true

class User::Registration < ApplicationRecord
  devise :confirmable
end
