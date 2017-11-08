class HomeController < ApplicationController
  def index
    @posts = Post.all.sort_by { | post | post.original_date }.reverse
  end
end
