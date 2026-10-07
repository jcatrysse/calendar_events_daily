# global-calendar

Run 2026-10-07T16:13:51.689Z against http://127.0.0.1:3002 (PostgreSQL 16, with 40 other GEOxyz plugins on redmine70-migration, all but redmine_issue_field_visibility and redmine_tint_issues).

| screenshot | user | URL | shows |
|---|---|---|---|
| ![](global-calendar-admin.png) | admin | `/issues/calendar` | Admin, all projects: between entries of both projects, each prefixed with the project name (E2E project / E2E private) |
| ![](global-calendar-outsider.png) | outsider | `/issues/calendar` | Outsider, all projects: only the public project; the private issue is on no day, also not as between |

## Problems

- /issues/calendar as admin: 404 image /assets/plugin_assets/redmineup/bullet_go.png
- /issues/calendar as admin: 404 image /assets/plugin_assets/redmineup/bullet_diamond.png
- /issues/calendar as admin: 404 image /assets/plugin_assets/redmineup/bullet_end.png
- login manager: 404 image /assets/plugin_assets/redmineup/bullet_go.png
- login manager: 404 image /assets/plugin_assets/redmineup/bullet_end.png
- /issues/calendar as manager: 404 image /assets/plugin_assets/redmineup/bullet_diamond.png
- /issues/calendar as outsider: 404 image /assets/plugin_assets/redmineup/bullet_go.png
- /issues/calendar as outsider: 404 image /assets/plugin_assets/redmineup/bullet_end.png
- /issues/calendar as outsider: 404 image /assets/plugin_assets/redmineup/bullet_diamond.png
