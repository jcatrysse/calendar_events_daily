# OpenAI review 71befba

Model `gpt-5`, range `e737933..71befba`, 12 file(s), 1 request(s), 21160 tokens.

Add a `Resolution:` line under every finding: fixed in <commit>, or why not.

## Part 1 of 1

Major, lib/calendar_events_daily/calendars_controller_patch.rb:17
Problem: The added overlap query uses calendar.startdt/enddt (the full 5–6 week grid) instead of the displayed month’s boundaries. It only adds issues where start_date < startdt AND due_date > enddt. Issues that start before the first day of the month (but not before startdt) and end after the last day of the month (but not after enddt) still won’t be included, although they span the whole displayed month.
Failure scenario: October 2026 (week starts Monday): startdt = 2026-09-28, enddt = 2026-11-01. Issue with start_date = 2026-09-30 and due_date = 2026-11-01 spans the whole month of October (before Oct 1 and after Oct 31). Core won’t fetch it (neither starts nor ends in Oct). The plugin intends to add it, but the condition (start_date < 2026-09-28 AND due_date > 2026-11-01) is false, so the issue is still missing.
Fix: For the monthly calendar, compare against the month boundaries, not the grid:
- month_begin = @calendar.date.beginning_of_month
- month_end = @calendar.date.end_of_month
Use conditions: ["#{Issue.table_name}.start_date < ? AND #{Issue.table_name}.due_date > ?", month_begin, month_end]
Keep using startdt/enddt for the My page week block (already correct there).

Resolution: not a defect, no change. Core's CalendarsController#show fetches issues with start_date or
due_date BETWEEN @calendar.startdt AND @calendar.enddt, the whole displayed grid, not the month. The
example (start 2026-09-30, due 2026-11-01, grid 2026-09-28..2026-11-01) is fetched by core already (both
dates are in the grid) and drawn on every day by the plugin. The patch adds exactly the complement: issues
that start before and end after the grid. Using month boundaries would add issues core already fetched.

Major, lib/calendar_events_daily/calendars_controller_patch.rb:17
Problem: N+1 queries for project on added issues in the cross-project calendar. The added fetch includes [:tracker, :assigned_to, :priority] but not :project. The common/_calendar partial prefixes issues with their project name when no @project is set; without preloading, this triggers a SELECT per issue.
Failure scenario: Visit /issues/calendar with at least one “spanning” issue added by the patch. Logs show per-issue queries like SELECT "projects".* FROM "projects" WHERE "projects"."id" = ? for each added issue; page slows with many issues.
Fix: Include project in the added fetch (to match core):
spanning = @query.issues(
  include: [:project, :tracker, :assigned_to, :priority],
  conditions: ["#{Issue.table_name}.start_date < ? AND #{Issue.table_name}.due_date > ?", month_begin, month_end]
)

Resolution: not a defect, no change. IssueQuery#issues (app/models/issue_query.rb:415) always does
`includes(([:status, :project] + (options[:include] || [])).uniq)`, so :project is preloaded for the added
issues as for core's own; the include list is the one core's show passes.
