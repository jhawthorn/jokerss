class Feed < ApplicationRecord
  has_many :entries

  def entries_count
    entries.count
  end

  def fetch!
    FeedUpdater.new(self).call
    self
  end

  def self.fetch_all!
    find_each(&:fetch!)
  end
end
