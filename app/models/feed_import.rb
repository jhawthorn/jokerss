class FeedImport
  def initialize(url)
    @url = url
  end

  def find_or_build_feed
    feed_url = self.feed_url
    Feed.find_or_initialize_by(fetch_url: feed_url)
  end

  def feed_url
    case @url
    when /https:\/\/www\.youtube\.com\/user\/([^\/#\?]*)/,
         /https:\/\/www\.youtube\.com\/c\/([^\/#\?]*)/
      "https://www.youtube.com/feeds/videos.xml?user=#{$1}"
    when /https:\/\/www\.youtube\.com\/channel\/([^\/#\?]*)/
      "https://www.youtube.com/feeds/videos.xml?channel_id=#{$1}"
    when /https:\/\/www\.youtube\.com\/playlist\?list=([^&]*)/,
         /https:\/\/www\.youtube\.com\/watch\?.*&list=([^&]*)/
      "https://www.youtube.com/feeds/videos.xml?playlist_id=#{$1}"
    when /https:\/\/www\.reddit\.com\/r\/([^\/#\?]*)/
      "https://www.reddit.com/r/#{$1}.rss"
    else
      @url
    end
  end
end
