# frozen_string_literal: true

class CreateUserKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :user_keys do |t|
      t.references :user, null: false, foreign_key: true
      t.text :public_key, null: false

      t.timestamps null: false
    end

    add_index :user_keys, :user_id, unique: true
  end
end
