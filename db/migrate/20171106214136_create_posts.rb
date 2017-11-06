class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :body, null: false
      t.date :original_date
      t.references :user, null: false, index: true

      t.timestamps
    end
  end
end
