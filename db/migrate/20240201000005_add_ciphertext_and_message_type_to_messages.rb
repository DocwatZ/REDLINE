# frozen_string_literal: true

class AddCiphertextAndMessageTypeToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :ciphertext, :text
    add_column :messages, :message_type, :string, null: false, default: "text" # text, system

    # Make body nullable — E2EE rooms use ciphertext only
    change_column_null :messages, :body, true
  end
end
