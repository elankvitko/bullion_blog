class HomeController < ApplicationController
  def index
    # Retrieve all posts by original date and sort them from newest to oldest
    @posts = Post.all.sort_by { | post | post.original_date }.reverse

    # Set Restrictions and generate home slider content
    @ok_categories = [ "Weekly Market Analysis", "New Releases", "Market News" ]
    @featured_categories = []
    @ok_categories.each { | name | @featured_categories.concat( Category.where( name: name ) ) }
    @featured_posts = []
    @reject = Category.find_by( name: "Daily Market Review" )

    @weekly_market_analysis_block = []

    @featured_categories.each do | category |
      posts = category.posts.where( "original_date > ?", Date.today - 20 )

      posts.each do | post |
        if post.categories.include? @reject
          next
        else
          @featured_posts << post
        end
      end
    end

    # Generate Article Widgets
    categories = [ "Weekly Market Analysis", "Daily Market Review", "Market News", "New Releases", "Precious Metals Investing", "Miscellaneous" ]
    categories.map! { | category | Category.find_by( name: category ) }
    @posts_by_category = {}

    # Iterate through each catgeory and collect posts
    categories.each do | category |
      # Check to see if this category already exists and create if it does not
      @posts_by_category[ category.name ] = [] if !@posts_by_category[ category.name ]

      # Collect posts where the date is limited to Today minus the last 15 days
      collected_posts = category.posts.where( "original_date > ?", Date.today - 180 )

      collected_posts.each do | post |
        @posts_by_category[ category.name ] << post
      end
    end

    # Sort Posts
    @posts_by_category.each do | category, posts |
      @posts_by_category[ category ] = posts.sort_by! { | post | post.original_date }.reverse
    end
  end
end
