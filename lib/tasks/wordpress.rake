namespace :wordpress do
  desc "Import WordPress data"
  task import: :environment do
    # Get the WordPress data
    require 'wordpress/posts_import'
    data = WordPress::Data.new
    # Import the posts
    data.posts.each do | data |
      binding.pry
    end
  end
end
