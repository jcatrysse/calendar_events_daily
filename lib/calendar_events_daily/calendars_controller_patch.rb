module CalendarEventsDaily
  # Core's calendar fetches only issues that start or end in the displayed month, so an issue
  # that runs through the whole month is missing. Add those, through the same query (filters,
  # visibility), just before the page renders: covers the normal and the xhr response of show.
  module CalendarsControllerPatch
    def render(*args, &block)
      calendar_events_daily_add_spanning_issues if action_name == 'show'
      super
    end

    private

    def calendar_events_daily_add_spanning_issues
      return if @calendar_events_daily_added || @calendar.nil? || @query.nil? || !@query.valid?

      @calendar_events_daily_added = true
      spanning = @query.issues(
        :include => [:tracker, :assigned_to, :priority],
        :conditions => [
          "#{Issue.table_name}.start_date < ? AND #{Issue.table_name}.due_date > ?",
          @calendar.startdt, @calendar.enddt
        ]
      )
      @calendar.events = @calendar.events + spanning if spanning.any?
    end
  end
end
