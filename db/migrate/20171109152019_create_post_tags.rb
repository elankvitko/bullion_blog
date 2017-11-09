class CreatePostTags < ActiveRecord::Migration[5.1]
  def change
    create_table :post_tags do |t|
      t.integer :post_id, index: true
      t.integer :tag_id, index: true

      t.timestamps
    end
  end
end