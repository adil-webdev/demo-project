class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content
      t.string :status, default: 'draft'
      t.integer :views_count, default: 0
      t.string :attachment_path

      t.timestamps
    end

    add_index :posts, :status
    add_index :posts, :created_at
  end
end
