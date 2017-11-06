class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :body, null: false
      t.references :user, null: false, index: true
      t.references :post, null: false, index: true

      t.timestamps
    end
  end
end
