module TimeHelper
  def relative_time(time)
    return "never" unless time
    content_tag("relative-time", "", datetime: time.iso8601)
  end
end
