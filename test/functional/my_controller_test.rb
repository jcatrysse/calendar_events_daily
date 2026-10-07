require File.expand_path('../../test_helper', __FILE__)

class CalendarEventsDaily::MyControllerTest < Redmine::ControllerTest
  tests MyController

  def test_page_calendar_block_shows_issue_on_days_between
    travel_to Date.new(2026, 10, 14)
    Issue.generate!(:project_id => 1, :subject => 'Week spanning issue',
                    :start_date => Date.new(2026, 10, 12), :due_date => Date.new(2026, 10, 30))
    @request.session[:user_id] = 2
    preferences = User.find(2).pref
    preferences[:my_page_layout] = {'top' => ['calendar']}
    preferences.save!

    get :page
    assert_response :success

    # week Sunday 11 to Saturday 17: starts on the 12th, between from the 13th
    assert_select 'div#block-calendar ul.cal div.issue.starting', :text => /Week spanning issue/, :count => 1
    assert_select 'div#block-calendar ul.cal div.issue.between', :text => /Week spanning issue/, :count => 5 do
      assert_select 'svg use[href$=?]', '#icon--between'
    end
    assert_select 'div#block-calendar ul.cal li.calbody.today span.day-value', :text => '14'
    # no legend on My page, as in core
    assert_select 'p.legend', 0
  end

  def test_page_calendar_block_includes_issue_spanning_the_whole_week
    travel_to Date.new(2026, 10, 14)
    Issue.generate!(:project_id => 1, :subject => 'Whole week issue',
                    :start_date => Date.new(2026, 10, 1), :due_date => Date.new(2026, 10, 30))
    # visible to user 2, but in a project user 2 is not a member of: My page leaves it out, as core does
    Issue.generate!(:project_id => 3, :subject => 'Other project issue',
                    :start_date => Date.new(2026, 10, 1), :due_date => Date.new(2026, 10, 30))
    @request.session[:user_id] = 2
    preferences = User.find(2).pref
    preferences[:my_page_layout] = {'top' => ['calendar']}
    preferences.save!

    get :page
    assert_response :success

    assert_select 'div#block-calendar ul.cal div.issue.between', :text => /Whole week issue/, :count => 7
    assert_select 'div#block-calendar ul.cal div.issue', :text => /Other project issue/, :count => 0
  end
end
