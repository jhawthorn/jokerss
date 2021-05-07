class RefreshJob < ApplicationJob
  queue_as :default

  def perform(feed)
    feed.fetch!
  end
end
