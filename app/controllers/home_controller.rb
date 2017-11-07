class HomeController < ApplicationController
  def index
    @posts = Post.all.sort_by { | post | post.id }.reverse
  end
end
