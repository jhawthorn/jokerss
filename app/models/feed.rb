class Feed < ApplicationRecord
  has_many :entries, dependent: :destroy

  after_create :enqueue_refresh
  after_update :enqueue_refresh, if: :fetch_url_changed?

  define_prelude(:entries_count) do |feeds|
    counts = Entry.where(feed: feeds).group(:feed_id).count
    feeds.index_with { |x| counts[x.id] }
  end

  define_prelude(:last_published) do |feeds|
    by_id = Entry.where(feed: feeds).group(:feed_id).maximum(:published)
    feeds.index_with { |x| by_id[x.id] }
  end

  def fetch!
    FeedUpdater.new(self).call
    self
  end

  def self.fetch_all!
    find_each(&:fetch!)
  end

  private

  def enqueue_refresh
    RefreshJob.perform_later(self)
  end
end
