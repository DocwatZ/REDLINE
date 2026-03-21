# frozen_string_literal: true

class CreateIdentities < ActiveRecord::Migration[7.1]
  def change
    create_table :identities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at

      t.timestamps null: false
    end

    add_index :identities, [:provider, :uid], unique: true
  end
end
