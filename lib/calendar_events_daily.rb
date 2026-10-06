module CalendarEventsDaily
  module CalendarHelperPatch
    def initialize(date, lang = current_language, period = :month)
      super
      @events_by_days = Hash.new {|h,k| h[k] = [] }
    end

    def events=(events)
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
