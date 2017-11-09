namespace :wipe_post_data do
  desc "Destroy All Posts And Data Along With It"
  task wipe: :environment do
    Post.destroy_all
    Category.destroy_all
    Comment.destroy_all
    Tag.destroy_all
    PostCategory.destroy_all
    PostTag.destroy_all
  end
end
