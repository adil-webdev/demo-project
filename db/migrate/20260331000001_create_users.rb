class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest
      t.string :role, default: 'user'
      t.string :ssn  # Sensitive data - should be encrypted
      t.boolean :premium, default: false
      t.datetime :membership_expires_at

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
