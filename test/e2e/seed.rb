# Calendar data for the end-to-end scenarios, run by .codex/start_server.sh after
# the generic seed. Idempotent; dates are set relative to today on every run, so
# the current month always holds every case.
admin = User.find_by!(login: 'admin')
User.current = admin
manager = User.find_by!(login: 'manager')
reporter = User.find_by!(login: 'reporter')
project = Project.find_by!(identifier: 'e2e-project')
private_project = Project.find_by!(identifier: 'e2e-private')

today = Date.today
month = Date.civil(today.year, today.month, 1)
week = Redmine::Helpers::Calendar.new(today, :en, :week).startdt

def calendar_issue(project, subject, start_date, due_date, closed: false, tracker: nil)
  issue = Issue.find_by(project_id: project.id, subject: subject) ||
          Issue.new(project: project, tracker: project.trackers.first, subject: subject, author: User.current,
                    priority: IssuePriority.default || IssuePriority.first)
  issue.tracker = tracker if tracker
  issue.status ||= issue.tracker.default_status
  issue.start_date = start_date
  issue.due_date = due_date
  issue.status = IssueStatus.where(is_closed: true).first if closed
  issue.save!
  issue
end

calendar_issue(project, 'Calendar span 5-9', month + 4, month + 8)
calendar_issue(project, 'Calendar one day', month + 14, month + 14)
calendar_issue(project, 'Calendar start only', month + 11, nil)
calendar_issue(project, 'Calendar due only', nil, month + 12)
calendar_issue(project, 'Calendar long running', month + 19, today >> 36)
calendar_issue(project, 'Calendar closed span', month + 21, month + 25, closed: true)
calendar_issue(project, 'Calendar this week', week + 1, week + 20)
calendar_issue(private_project, 'Calendar private span', month + 4, month + 8)
# Start before and end after the displayed month (and week): core alone does not fetch these
calendar_issue(project, 'Calendar whole month bug', month - 10, (month >> 1) + 10)
calendar_issue(private_project, 'Calendar private whole month', month - 10, (month >> 1) + 10)
calendar_issue(project, 'Calendar whole month feature', month - 10, (month >> 1) + 10,
               tracker: project.trackers.where.not(id: project.trackers.first.id).first)

version = Version.find_by(project_id: project.id, name: 'Calendar version') ||
          Version.new(project: project, name: 'Calendar version')
version.effective_date = month + 20
version.save!

# Calendar module off: the calendar must be refused, not crash
nocal = Project.find_by(identifier: 'e2e-nocal') ||
        Project.new(identifier: 'e2e-nocal', name: 'E2E no calendar', is_public: true)
nocal.enabled_module_names = Redmine::AccessControl.available_project_modules.map(&:to_s) - ['calendar']
nocal.trackers = Tracker.all
nocal.save!
full = Role.find_by!(name: 'E2E full')
Member.create!(principal: manager, project: nocal, roles: [full]) unless Member.where(user_id: manager.id, project_id: nocal.id).exists?

# A member whose role lacks view_calendar: sees the issues, not the calendar
nocal_role = Role.find_by(name: 'E2E no calendar') || Role.new(name: 'E2E no calendar', assignable: true)
nocal_role.permissions = [:view_issues, :add_issues]
nocal_role.issues_visibility = 'all'
nocal_role.save!
unless Member.where(user_id: reporter.id, project_id: private_project.id).exists?
  Member.create!(principal: reporter, project: private_project, roles: [nocal_role])
end

# My page with the calendar block for the manager and for the outsider (no memberships)
[manager, User.find_by!(login: 'outsider')].each do |user|
  pref = user.pref
  layout = pref.my_page_layout
  next if layout.values.flatten.include?('calendar')

  layout = layout.deep_dup
  (layout['top'] ||= []).unshift('calendar')
  pref.my_page_layout = layout
  pref.save!
end

puts "Calendar seed: #{Issue.where('subject LIKE ?', 'Calendar %').count} issues, month #{month}, week from #{week}"
