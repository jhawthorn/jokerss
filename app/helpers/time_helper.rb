module TimeHelper
  def relative_time(time)
    content_tag("relative-time", "", datetime: time.iso8601)
  end
end
