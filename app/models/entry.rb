class Entry < ApplicationRecord
  belongs_to :feed

  serialize :data, JSON

  def youtube?
    data.key?("youtube_video_id")
  end

  def pretty_title
    title = self.title.dup
    title.gsub!("#{feed.title} - ", "")
    title.gsub!("- #{feed.title}", "")
    title
  end
end
