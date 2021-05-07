class HomeController < ApplicationController
  def index
    redirect_to timeline_feeds_path
  end
end
