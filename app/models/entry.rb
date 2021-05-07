class Entry < ApplicationRecord
  belongs_to :feed

  def pretty_title
    title = self.title.dup
    title.gsub!("#{feed.title} - ", "")
    title.gsub!("- #{feed.title}", "")
    title
  end
end
