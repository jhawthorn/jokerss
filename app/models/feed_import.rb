class FeedImport
  def initialize(url)
    @url = url
  end

  def find_or_build_feed
    feed_url = self.feed_url
    Feed.find_or_initialize_by(fetch_url: feed_url)
  end

  def feed_url
    guess_from_url ||
      valid_feed ||
      from_meta_tag
  end

  # We can be pretty lenient. No danger detecting non-feed XML
  FEED_CONTENT_TYPES = %w[
    application/rss+xml
    application/rdf+xml
    application/atom+xml
    text/xml
  ]

  def valid_feed
    content_type = http_response.headers["content-type"]

    if FEED_CONTENT_TYPES.any? { |x| content_type.start_with?(x) }
      return @url
    end
  end

  def from_meta_tag
    doc = Nokogiri::HTML(http_response.body)

    if tag = doc.at_css("link[rel='alternate'][type='application/atom+xml']")
      return URI.join(@url, tag[:href]).to_s
    end

    if tag = doc.at_css("link[rel='alternate'][type='application/rss+xml']")
      return URI.join(@url, tag[:href]).to_s
    end
  end

  def guess_from_url
    case @url
    when /https:\/\/www\.youtube\.com\/user\/([^\/#\?]*)/
      "https://www.youtube.com/feeds/videos.xml?user=#{$1}"
    when /https:\/\/www\.youtube\.com\/channel\/([^\/#\?]*)/
      "https://www.youtube.com/feeds/videos.xml?channel_id=#{$1}"
    when /https:\/\/www\.youtube\.com\/playlist\?list=([^&]*)/,
         /https:\/\/www\.youtube\.com\/watch\?.*&list=([^&]*)/
      "https://www.youtube.com/feeds/videos.xml?playlist_id=#{$1}"
    when /https:\/\/www\.reddit\.com\/r\/([^\/#\?]*)/
      "https://www.reddit.com/r/#{$1}.rss"
    end
  end

  def http_response
    @http_response ||= faraday.get(@url)
  end

  def faraday
    conn = Faraday.new do |f|
      f.request :retry
      f.response :follow_redirects
    end
  end
end
