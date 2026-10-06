require File.expand_path('../../test_helper', __FILE__)

class CalendarEventsDaily::CalendarHelperPatchTest < ActiveSupport::TestCase
  def setup
    User.current = nil
    @calendar = Redmine::Helpers::Calendar.new(Date.new(2026, 10, 1), :en, :month)
  end

  def test_issue_is_shown_on_every_day_from_start_to_due_date
    issue = Issue.new(:subject => 'span', :start_date => Date.new(2026, 10, 5), :due_date => Date.new(2026, 10, 9))
    @calendar.events = [issue]

    (Date.new(2026, 10, 5)..Date.new(2026, 10, 9)).each do |day|
      assert_equal [issue], @calendar.events_on(day), "missing on #{day}"
    end
    assert_equal [], @calendar.events_on(Date.new(2026, 10, 4))
    assert_equal [], @calendar.events_on(Date.new(2026, 10, 10))
  end

  def test_issue_without_due_date_is_only_shown_on_its_start_date
    issue = Issue.new(:subject => 'open end', :start_date => Date.new(2026, 10, 5))
    @calendar.events = [issue]

    assert_equal [issue], @calendar.events_on(Date.new(2026, 10, 5))
    assert_equal [], @calendar.events_on(Date.new(2026, 10, 6))
  end

  def test_issue_without_start_date_is_only_shown_on_its_due_date
    issue = Issue.new(:subject => 'no start', :due_date => Date.new(2026, 10, 9))
    @calendar.events = [issue]

    assert_equal [issue], @calendar.events_on(Date.new(2026, 10, 9))
    assert_equal [], @calendar.events_on(Date.new(2026, 10, 8))
  end

  def test_versions_are_shown_on_their_date
    version = Version.new(:name => 'v', :effective_date => Date.new(2026, 10, 7))
    @calendar.events = [version]

    assert_equal [version], @calendar.events_on(Date.new(2026, 10, 7))
    assert_equal [], @calendar.events_on(Date.new(2026, 10, 8))
  end

  def test_version_is_shown_from_the_start_of_its_issues_to_its_date
    # behaviour since upstream 0.0.1, kept: Version#start_date is the earliest start date of its issues
    # (open question for Jan in docs/REDMINE7-MIGRATION.md)
    version = Version.new(:name => 'v', :effective_date => Date.new(2026, 10, 7))
    version.instance_variable_set(:@start_date, Date.new(2026, 10, 5))
    @calendar.events = [version]

    (Date.new(2026, 10, 5)..Date.new(2026, 10, 7)).each do |day|
      assert_equal [version], @calendar.events_on(day), "missing on #{day}"
    end
    assert_equal [], @calendar.events_on(Date.new(2026, 10, 4))
  end

  def test_issue_is_listed_once_per_day
    issue = Issue.new(:subject => 'one day', :start_date => Date.new(2026, 10, 5), :due_date => Date.new(2026, 10, 5))
    @calendar.events = [issue]

    assert_equal [issue], @calendar.events_on(Date.new(2026, 10, 5))
  end

  def test_days_outside_the_calendar_are_not_indexed
    # due far ahead: the index must stay within the days the calendar shows
    issue = Issue.new(:subject => 'long', :start_date => Date.new(2026, 10, 20), :due_date => Date.new(2099, 12, 31))
    @calendar.events = [issue]

    days = @calendar.instance_variable_get(:@events_by_days).keys
    assert days.all? {|d| d >= @calendar.startdt && d <= @calendar.enddt}, "indexed #{days.min}..#{days.max}"
    assert_equal [issue], @calendar.events_on(@calendar.enddt)
    assert_equal [issue], @calendar.events_on(Date.new(2026, 10, 20))
  end

  def test_week_calendar
    calendar = Redmine::Helpers::Calendar.new(Date.new(2026, 10, 7), :en, :week)
    issue = Issue.new(:subject => 'week', :start_date => Date.new(2026, 9, 1), :due_date => Date.new(2026, 12, 1))
    calendar.events = [issue]

    calendar.format_month.each do |day|
      assert_equal [issue], calendar.events_on(day)
    end
  end
end
