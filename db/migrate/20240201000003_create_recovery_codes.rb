# frozen_string_literal: true

class CreateRecoveryCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :recovery_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code_digest, null: false
      t.datetime :used_at

      t.timestamps null: false
    end

    add_index :recovery_codes, [:user_id, :code_digest]
  end
end
