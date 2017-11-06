class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :tags
  has_many :comments
end
