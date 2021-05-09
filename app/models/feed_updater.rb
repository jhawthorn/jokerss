require 'net/http'
require 'uri'
require 'feedjira'

class FeedUpdater
  ACCEPT_HEADER = "Accept: application/rss+xml, application/rdf+xml;q=0.8, application/atom+xml;q=0.6, application/xml;q=0.4, text/xml;q=0.4"

  class FetchFailed < StandardError; end

  def initialize(feed)
    @db_feed = feed
  end

  def call
    xml = fetch_xml
    feed = Feedjira.parse(xml)
    entries = feed.entries

    @db_feed.transaction do
      @db_feed.title = feed.title
      @db_feed.homepage_url = feed.url
      @db_feed.save!

      existing_db_entries = @db_feed.entries.where(guid: entries.map(&:id)).index_by(&:guid)

      entries.each do |entry|
        id = entry.id
        db_entry = existing_db_entries[id] || @db_feed.entries.new(guid: id)
        db_entry.url = entry.url
        db_entry.title = entry.title
        db_entry.content = entry.content || entry.summary
        db_entry.summary = entry.summary
        db_entry.published = entry.published
        db_entry.data = entry.to_h
        db_entry.save!
      end
    end
  end

  def fetch_xml
    # FIXME: this could use some safety checks
    uri = URI.parse(@db_feed.fetch_url)
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = ACCEPT_HEADER

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    unless response.code == "200"
      raise FetchFailed, "status=#{response.code}\n#{response.body}"
    end

    response.body
  end
end
