class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.references :post, null: false, index: true

      t.timestamps
    end
  end
end
