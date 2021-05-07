class Feed < ApplicationRecord
  def fetch!
    FeedUpdater.new(self).call
    self
  end
end
