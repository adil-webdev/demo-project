class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.text :content, null: false
      t.string :status, default: 'pending'
      t.string :ip_address

      t.timestamps
    end

    add_index :comments, :status
    add_index :comments, [:post_id, :created_at]
  end
end
