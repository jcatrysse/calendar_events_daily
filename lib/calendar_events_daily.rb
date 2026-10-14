module CalendarEventsDaily
  # Redmine builds a jQuery UI tooltip for every [title]:not(.no-tooltip) on the page. Inside the
  # hidden issue tooltip (the assignee avatar) that is one widget per day of every issue, seconds in
  # the browser on a busy month; the browser's own title still shows. Only adds a class to the start
  # tags of escaped HTML rendered by Redmine, where attribute values hold no raw < > or ".
  def self.without_title_widgets(html)
    return html unless html.html_safe?

    html.to_str.gsub(/<[a-z][^<>]*\stitle="[^<>]*>/i) do |tag|
      if tag.include?(' class="')
        tag.sub(' class="', ' class="no-tooltip ')
      else
        tag.sub(/\A<[a-z0-9]+/i, '\\0 class="no-tooltip"')
      end
    end.html_safe
  end

  module CalendarHelperPatch
    def initialize(date, lang = current_language, period = :month)
      super
      @events_by_days = Hash.new {|h,k| h[k] = [] }
    end

    def events
      @events
    end

    def events=(events)
      @events_by_days = Hash.new {|h,k| h[k] = [] }
      super
      @events.each do |event|
        next if event.start_date.nil? || event.due_date.nil?
        # Only the days this calendar shows: an issue due years ahead would otherwise fill the hash with every day until then
        ([event.start_date, @startdt].max..[event.due_date, @enddt].min).each do |d|
          @events_by_days[d] << event
        end
      end
    end
    def events_on(day)
      ((@events_by_days[day] || []) + (@ending_events_by_days[day] || []) + (@starting_events_by_days[day] || [])).uniq
    end
  end
end
