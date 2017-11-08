class AddReferenceToPosts < ActiveRecord::Migration[5.1]
  def change
    add_reference :posts, :post_category, index: true
  end
end
