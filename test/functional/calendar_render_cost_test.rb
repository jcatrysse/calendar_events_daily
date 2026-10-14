require File.expand_path('../../test_helper', __FILE__)

# Each issue on the calendar is drawn on every day of its span; the work per issue (tooltip,
# CSS classes, link) must be done once per page, not once per day.
class CalendarEventsDaily::CalendarRenderCostTest < Redmine::ControllerTest
  tests CalendarsController

  module CountTooltips
    def render_issue_tooltip(issue)
      Thread.current[:calendar_events_daily_counts][:tooltip] += 1 if Thread.current[:calendar_events_daily_counts]
      super
    end
  end

  module CountCssClasses
    def css_classes(*args)
      Thread.current[:calendar_events_daily_counts][:css] += 1 if Thread.current[:calendar_events_daily_counts]
      super
    end
  end

  IssuesHelper.prepend CountTooltips
  Issue.prepend CountCssClasses

  def setup
    travel_to Date.new(2026, 10, 14)
    User.current = nil
    Issue.where(:project_id => 1).update_all(:start_date => nil, :due_date => nil)
    @issue = Issue.generate!(:project_id => 1, :subject => 'Long issue', :assigned_to_id => 2,
                             :start_date => Date.new(2026, 10, 5), :due_date => Date.new(2026, 10, 9))
  end

  def teardown
    Thread.current[:calendar_events_daily_counts] = nil
  end

  def test_work_per_issue_does_not_grow_with_its_span
    short = counts_for_october
    @issue.update_columns(:due_date => Date.new(2026, 10, 24))
    long = counts_for_october

    assert_equal 5, short[:entries]
    assert_equal 20, long[:entries]
    assert_equal 1, short[:tooltip]
    assert_equal short[:tooltip], long[:tooltip], 'tooltip rendered once per issue, not per day'
    assert_equal short[:css], long[:css], 'css_classes computed once per issue, not per day'
  end


  private

  def counts_for_october
    Thread.current[:calendar_events_daily_counts] = {:tooltip => 0, :css => 0}
    get :show, :params => {:project_id => 1, :year => 2026, :month => 10}
    assert_response :success
    counts = Thread.current[:calendar_events_daily_counts].dup
    Thread.current[:calendar_events_daily_counts] = nil
    counts[:entries] = css_select('ul.cal div.issue').count {|div| div.text.include?('Long issue')}
    # every entry is still a full entry: tooltip, checkbox for the context menu
    assert_select 'ul.cal div.issue.hascontextmenu', :text => /Long issue/, :count => counts[:entries] do
      assert_select 'span.tip', :count => counts[:entries]
      assert_select 'input[name=?][value=?]', 'ids[]', @issue.id.to_s, :count => counts[:entries]
    end
    counts
  end
end
