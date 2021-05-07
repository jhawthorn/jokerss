class Feed < ApplicationRecord
  has_many :entries

  def fetch!
    FeedUpdater.new(self).call
    self
  end
end
