module CalendarEventsDaily
  # The week calendar on My page, as core's MyHelper#render_calendar_block, plus the issues that
  # start before and end after the week. Compare with core when upgrading Redmine.
  module MyHelperPatch
    def render_calendar_block(block, settings)
      calendar = Redmine::Helpers::Calendar.new(User.current.today, current_language, :week)
      calendar.events = Issue.visible.
        where(:project => User.current.projects).
        where("(start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?)",
              calendar.startdt, calendar.enddt, calendar.startdt, calendar.enddt, calendar.startdt, calendar.enddt).
        includes(:project, :tracker, :priority, :assigned_to).
        references(:project, :tracker, :priority, :assigned_to).
        to_a

      render :partial => 'my/blocks/calendar', :locals => {:calendar => calendar, :block => block}
    end
  end
end
