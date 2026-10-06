require File.expand_path('../../test_helper', __FILE__)

class CalendarEventsDaily::AssetsTest < Redmine::IntegrationTest
  def test_pages_without_calendar_load_nothing_of_the_plugin
    # production eager loads every hook of the plugin; the test environment does not
    Rails.autoloaders.main.eager_load_dir(File.expand_path('../../../app/hooks', __FILE__))
    get '/projects'
    assert_response :success

    assert_not_includes response.body, 'calendar_events_daily'
  end

  def test_stylesheet_only_styles_the_calendar
    css = File.read(File.expand_path('../../../assets/stylesheets/calendar_events_daily.css', __FILE__))
    selectors = css.gsub(%r{/\*.*?\*/}m, '').scan(/([^{}]+)\{/).flat_map {|(s)| s.split(',')}.map(&:strip)

    assert selectors.any?
    selectors.each do |selector|
      assert_match(/\A\S*\.cal\b/, selector, "#{selector} reaches outside the calendar")
    end
  end
end
