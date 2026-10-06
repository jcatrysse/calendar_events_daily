# global-calendar

Run 2026-10-06T19:45:45.048Z against http://127.0.0.1:3000 (MariaDB 10.11, with redmine_people and redmine_agile redmine70-migration).

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
- /issues/calendar as outsider: 404 image /assets/plugin_assets/redmineup/bullet_diamond.png
- /issues/calendar as outsider: 404 image /assets/plugin_assets/redmineup/bullet_end.png
