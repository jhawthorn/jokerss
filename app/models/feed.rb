class Feed < ApplicationRecord
  has_many :entries

  define_prelude(:entries_count) do |feeds|
    counts = Entry.where(feed: feeds).group(:feed_id).count
    feeds.index_with { |x| counts[x.id] }
  end

  def fetch!
    FeedUpdater.new(self).call
    self
  end

  def self.fetch_all!
    find_each(&:fetch!)
  end
end
