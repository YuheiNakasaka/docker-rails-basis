# frozen_string_literal: true

class DeviseCreateUserDatabaseAuthentications < ActiveRecord::Migration[7.1]
  def change
    create_table :user_database_authentications do |t|
      t.references :user, foreign_key: true, index: { unique: true }

      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      t.timestamps null: false
    end

    add_index :user_database_authentications, :email, unique: true
  end
end
