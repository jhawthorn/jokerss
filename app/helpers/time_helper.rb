module TimeHelper
  def relative_time(time)
    return "never" if !time || time.to_i == 0
    content_tag("relative-time", "", datetime: time.iso8601)
  end
end
