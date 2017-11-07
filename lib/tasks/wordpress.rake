namespace :wordpress do
  desc "Import WordPress data"
  task import: :environment do
    # Get the WordPress data
    require 'wordpress/posts_import'
    require 'open-uri'
    AWS_RESOURCE = Aws::S3::Resource.new( region: 'us-east-2', access_key_id: ENV[ 'AWSAccessKeyId' ], secret_access_key: ENV[ 'AWSSecretKey' ] )
    data = WordPress::Data.new
    # Import the posts
    data.posts.each do | data |
      binding.pry
      # category = Category.create( name: data.category )
      # post = Post.create( title: data.title, slug: data.slug, body: data.content, user_id: "1", category_id: category.id )
      # data.comments.each do | comment |
      #   comment.update_attributes( user_id: "1", post_id: post.id )
      #   comment.save
      # end
    end
  end
end
