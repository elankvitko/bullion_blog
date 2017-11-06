class AddReferenceToPosts < ActiveRecord::Migration[5.1]
  def change
    add_reference :posts, :category, index: true
  end
end
