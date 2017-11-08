namespace :wordpress do
  desc "Import WordPress data"
  task import: :environment do
    # Get the WordPress data
    require 'wordpress/posts_import'
    require 'open-uri'
    AWS_RESOURCE = Aws::S3::Resource.new( region: 'us-east-2', access_key_id: ENV[ 'AWSAccessKeyId' ], secret_access_key: ENV[ 'AWSSecretKey' ] )

    files = [ "daily_market_review.xml", "market_news.xml", "miscellaneous.xml", "new_releases.xml", "precious_metals_investing.xml", "weekly_market_analysis.xml" ]

    files.each do | file |
      data = WordPress::Data.new( file )

      data.posts.each do | data |
        category = Category.where( name: data.category )
        category.empty? ? category = Category.create( name: data.category ) : category = category[ 0 ]

        possbile_post = Post.where( title: data.title )

        if possbile_post.empty?
          post = Post.create( title: data.title, slug: data.slug, original_date: data.original_date, body: data.content, user_id: "1", image_url: data.set_featured_img )
          PostCategory.create( post_id: post.id, category_id: category.id )

          data.comments.each do | comment |
            comment.update_attributes( user_id: "1", post_id: post.id )
            comment.save
          end
        else
          post = possbile_post[ 0 ]
          PostCategory.create( post_id: post.id, category_id: category.id )
        end
      end
    end
  end
end
