require File.expand_path('../../test_helper', __FILE__)

class CalendarEventsDaily::CalendarsControllerTest < Redmine::ControllerTest
  tests CalendarsController

  def setup
    travel_to Date.new(2026, 10, 14)
    User.current = nil
    @issue = Issue.generate!(:project_id => 1, :subject => 'Spanning issue',
                             :start_date => Date.new(2026, 10, 5), :due_date => Date.new(2026, 10, 9))
  end

  def test_show_marks_issue_on_days_between_start_and_due_date
    get :show, :params => {:project_id => 1, :year => 2026, :month => 10}
    assert_response :success

    assert_select 'ul.cal div.issue.hascontextmenu.tooltip', :text => /Spanning issue/, :count => 5
    assert_select 'ul.cal div.issue.starting', :text => /Spanning issue/, :count => 1
    assert_select 'ul.cal div.issue.ending', :text => /Spanning issue/, :count => 1
    assert_select 'ul.cal div.issue.between', :text => /Spanning issue/, :count => 3 do
      # one marker per day, and not a core start or end marker
      assert_select 'svg.icon-svg', :count => 3
      assert_select 'svg use[href*=?][href$=?]', 'plugin_assets/calendar_events_daily/icons', '#icon--between'
      assert_select 'a.issue[href=?]', "/issues/#{@issue.id}"
      assert_select 'input[name=?][type=checkbox][value=?]', 'ids[]', @issue.id.to_s
    end
  end

  def test_show_keeps_core_markers_on_start_and_due_date
    get :show, :params => {:project_id => 1, :year => 2026, :month => 10}
    assert_response :success

    assert_select 'ul.cal div.issue.starting:not(.ending)', :text => /Spanning issue/ do
      assert_select 'svg.icon-svg', :count => 1
      assert_select 'svg use[href$=?]', '#icon--bullet-go'
    end
    assert_select 'ul.cal div.issue.ending:not(.starting)', :text => /Spanning issue/ do
      assert_select 'svg.icon-svg', :count => 1
      assert_select 'svg use[href$=?]', '#icon--bullet-end'
    end
  end

  def test_show_marks_one_day_issue_as_starting_and_ending
    Issue.generate!(:project_id => 1, :subject => 'One day issue',
                    :start_date => Date.new(2026, 10, 20), :due_date => Date.new(2026, 10, 20))
    get :show, :params => {:project_id => 1, :year => 2026, :month => 10}
    assert_response :success

    assert_select 'ul.cal div.issue.starting.ending:not(.between)', :text => /One day issue/, :count => 1 do
      assert_select 'svg.icon-svg', :count => 1
      assert_select 'svg use[href$=?]', '#icon--bullet-go-end'
    end
  end

  def test_show_has_redmine7_today_marker_and_version_icon
    Version.generate!(:project_id => 1, :name => 'Calendar version', :effective_date => Date.new(2026, 10, 21))
    get :show, :params => {:project_id => 1, :year => 2026, :month => 10}
    assert_response :success

    assert_select 'ul.cal li.calbody p.day-num span.day-value', :count => 35
    assert_select 'ul.cal li.calbody.today p.day-num span.day-value', :text => '14'
    assert_select 'ul.cal span.icon.icon-package', :text => /Calendar version/ do
      assert_select 'svg use[href$=?]', '#icon--package'
    end
  end

  def test_show_adds_between_to_the_legend_and_loads_the_stylesheet
    get :show, :params => {:project_id => 1, :year => 2026, :month => 10}
    assert_response :success

    assert_select 'p.legend.cal span.between', :text => 'issue active on this day' do
      assert_select 'svg use[href*=?][href$=?]', 'plugin_assets/calendar_events_daily/icons', '#icon--between'
    end
    assert_select 'p.legend.cal span.starting:not(.ending)', :count => 1
    assert_select 'head link[rel=stylesheet][href*=?]', 'plugin_assets/calendar_events_daily/calendar_events_daily'
  end

  def test_show_with_invalid_query_has_no_calendar_and_no_legend
    get :show, :params => {:project_id => 1, :set_filter => 1,
                           :f => ['start_date'], :op => {'start_date' => '='}, :v => {'start_date' => ['not a date']}}
    assert_response :success

    assert_select 'ul.cal', 0
    assert_select 'p.legend', 0
  end

  def test_show_does_not_show_issues_of_a_private_project_to_a_non_member
    Issue.generate!(:project_id => 5, :subject => 'Private spanning issue',
                    :start_date => Date.new(2026, 10, 5), :due_date => Date.new(2026, 10, 9))
    @request.session[:user_id] = 7 # no membership
    get :show, :params => {:year => 2026, :month => 10}
    assert_response :success

    assert_select 'ul.cal div.issue.between', :text => /Spanning issue/, :count => 3
    assert_select 'ul.cal div.issue', :text => /Private spanning issue/, :count => 0
  end
end
