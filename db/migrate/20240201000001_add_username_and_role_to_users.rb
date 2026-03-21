# frozen_string_literal: true

class AddUsernameAndRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :username, :string
    add_column :users, :role, :string, null: false, default: "user" # user, admin

    # Make email nullable for username-only accounts
    change_column_null :users, :email, true
    change_column_default :users, :email, nil

    add_index :users, :username, unique: true

    # Allow unique email only when present (partial index)
    remove_index :users, :email
    add_index :users, :email, unique: true, where: "email IS NOT NULL AND email != ''"
  end
end
