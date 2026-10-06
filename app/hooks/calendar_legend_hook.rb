module CalendarLegendHook
  class LegendHook < Redmine::Hook::ViewListener
    render_on :view_calendars_show_bottom, partial: 'calendars/calendar_events_daily_legend'
  end
end
