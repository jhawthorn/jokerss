require "test_helper"

class FeedImportTest < ActiveSupport::TestCase
  def test_import_youtube_channel_id
    url = "https://www.youtube.com/channel/UC3_AWXcf2K3l9ILVuQe-XwQ"
    feed_url = FeedImport.new(url).feed_url
    assert_equal "https://www.youtube.com/feeds/videos.xml?channel_id=UC3_AWXcf2K3l9ILVuQe-XwQ", feed_url
  end

  def test_import_youtube_featured
    url = "https://www.youtube.com/c/Matthiaswandel/featured"
    feed_url = FeedImport.new(url).feed_url
    assert_equal "https://www.youtube.com/feeds/videos.xml?user=Matthiaswandel", feed_url
  end

  def test_import_youtube_username
    url = "https://www.youtube.com/user/Matthiaswandel"
    feed_url = FeedImport.new(url).feed_url
    assert_equal "https://www.youtube.com/feeds/videos.xml?user=Matthiaswandel", feed_url
  end

  def test_import_youtube_playlist_video
    url = "https://www.youtube.com/watch?v=RBucMKhrL8M&list=PLSnvVtM4lBIV6RpdePEuat1-wYUzHfshj"
    feed_url = FeedImport.new(url).feed_url
    assert_equal "https://www.youtube.com/feeds/videos.xml?playlist_id=PLSnvVtM4lBIV6RpdePEuat1-wYUzHfshj", feed_url
  end

  def test_import_youtube_playlist
    url = "https://www.youtube.com/playlist?list=PLSnvVtM4lBIV6RpdePEuat1-wYUzHfshj"
    feed_url = FeedImport.new(url).feed_url
    assert_equal "https://www.youtube.com/feeds/videos.xml?playlist_id=PLSnvVtM4lBIV6RpdePEuat1-wYUzHfshj", feed_url
  end
end
