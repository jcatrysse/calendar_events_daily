# my-page-calendar

Run 2026-10-07T16:14:25.133Z against http://127.0.0.1:3002 (PostgreSQL 16, with 40 other GEOxyz plugins on redmine70-migration, all but redmine_issue_field_visibility and redmine_tint_issues).

| screenshot | user | URL | shows |
|---|---|---|---|
| ![](my-page-calendar-manager.png) | manager | `/my/page` | Manager, My page: the week calendar block shows "Calendar this week" on its start day and as between on every later day of the week |
| ![](my-page-calendar-outsider.png) | outsider | `/my/page` | Outsider, My page: the calendar block is there but empty, no issue of any project, private or public (core lists member projects only) |

## Problems

- login manager: 404 image /assets/plugin_assets/redmineup/bullet_go.png
- login manager: 404 image /assets/plugin_assets/redmineup/bullet_end.png
