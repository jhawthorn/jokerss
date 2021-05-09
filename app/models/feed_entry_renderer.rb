# frozen_string_literal: true

class FeedEntryRenderer
  def initialize(entry)
    @entry = entry
    @feed = entry.feed
  end

  def to_html
    return "" unless @entry.content

    result = pipeline.call(@entry.content)
    result[:output].to_s.html_safe
  end

  def base_url
    @entry.url || @feed.homepage_url
  end

  def pipeline
    context = {
      subpage_url: base_url,
      base_url: base_url
    }
    HTML::Pipeline.new([
      SanitizationFilter,
      AbsoluteUrlFilter,
    ], context)
  end

  class SanitizationFilter < HTML::Pipeline::SanitizationFilter
    def allowlist
      allowlist = super
      allowlist.merge(
        remove_contents: %i[script style iframe object embed]
      )
    end
  end

  # Based on
  # https://github.com/feedbin/html-pipeline/blob/feedbin/lib/html/pipeline/absolute_href_filter.rb
  # and
  # https://github.com/feedbin/html-pipeline/blob/feedbin/lib/html/pipeline/absolute_source_filter.rb
  class AbsoluteUrlFilter < HTML::Pipeline::Filter
    # HTML Filter for replacing relative and root relative href or src
    #
    # This is useful if the content for the page assumes the host is known
    # i.e. scraped webpages and some RSS feeds.
    #
    # Context options:
    #   :href_base_url (required) - Base URL for image host for root relative href.
    #   :href_subpage_url (required) - For relative href.
    #
    # This filter does not write additional information to the context.
    def call
      absolutize("a", "href")
      absolutize("img,video,audio,source", "src")
      absolutize("video", "poster")
      doc
    end

    def absolutize(selector, attr)
      doc.search(selector).each do |element|
        value = element[attr]
        next if value.nil? || value.empty?
        value = value.strip
        value = fully_qualify(value)
        element[attr] = value
      end
    end

    def fully_qualify(src)
      unless src.start_with?('http://') || src.start_with?("https://") || src.start_with?("data:")
        if src.start_with? '/'
          base = base_url
        else
          base = subpage_url
        end
        src = URI.join(base, src).to_s rescue nil
      end
      src
    end

    def base_url
      context[:base_url] or raise "Missing context :base_url for #{self.class.name}"
    end

    def subpage_url
      context[:subpage_url] or raise "Missing context :subpage_url for #{self.class.name}"
    end
  end
end
