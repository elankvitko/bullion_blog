class AddReferenceToCategory < ActiveRecord::Migration[5.1]
  def change
    add_reference :categories, :post_category, index: true
  end
end
