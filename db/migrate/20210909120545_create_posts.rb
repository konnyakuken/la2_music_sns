class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|

      t.string :jacket
      t.string :artist
      t.string :song
      t.string :album
      t.string :sample
      t.text :comment
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
