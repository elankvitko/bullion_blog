namespace :wordpress do
  desc "Import WordPress data"
  task import: :environment do
    # Get the WordPress data
    require 'wordpress/posts_import'
    require 'open-uri'
    AWS_RESOURCE = Aws::S3::Resource.new( region: 'us-east-2', access_key_id: ENV[ 'AWSAccessKeyId' ], secret_access_key: ENV[ 'AWSSecretKey' ] )
    files = [ "part1.xml", "part2.xml", "part3.xml", "part4.xml" ]

    files.each do | file |
      data = WordPress::Data.new( file )

      data.posts.each do | data |
        data.content
        # next if data.original_date.nil?
        # category = data.category
        # tags = data.tags
        # save_category = ""
        # save_tag = ""
        # post = Post.create( title: data.title, slug: data.slug, original_date: data.original_date, body: data.content, user_id: "1", image_url: data.set_featured_img )
        #
        # category.each do | category |
        #   cat_arr = Category.where( name: category )
        #   cat_arr.empty? ? save_category = Category.create( name: category ) : save_category = cat_arr[ 0 ]
        #   PostCategory.create( post_id: post.id, category_id: save_category.id )
        # end
        #
        # if !tags.empty?
        #   tags.each do | tag |
        #     tag_arr = Tag.where( name: tag )
        #     tag_arr.empty? ? save_tag = Tag.create( name: tag ) : save_tag = tag_arr[ 0 ]
        #     PostTag.create( post_id: post.id, tag_id: save_tag.id )
        #   end
        # end
      end
    end
  end
end
