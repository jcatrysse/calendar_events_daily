# failure-paths

Run 2026-10-06T19:45:38.663Z against http://127.0.0.1:3000 (MariaDB 10.11, with redmine_people and redmine_agile redmine70-migration).

| screenshot | user | URL | shows |
|---|---|---|---|
| ![](failure-paths-module-off.png) | manager | `/projects/e2e-nocal/issues/calendar` | Calendar module disabled in "E2E no calendar": the calendar is refused with 403 |
| ![](failure-paths-invalid-query.png) | manager | `/projects/e2e-project/issues/calendar?set_filter=1&f[]=start_date&op[start_date]=%3D&v[start_date][]=not-a-date` | Invalid start date filter: Redmine shows the validation error, no calendar and no legend (no 500) |
| ![](failure-paths-closed-issue.png) | manager | `/projects/e2e-project/issues/calendar?set_filter=1&f[]=status_id&op[status_id]=*` | Status "any": the closed issue is on its between days, its link struck through like core does for closed issues |
| ![](failure-paths-bad-month.png) | manager | `/projects/e2e-project/issues/calendar?year=abc&month=xyz` | year=abc&month=xyz: the current month is shown, no error |
| ![](failure-paths-no-view-calendar.png) | reporter | `/projects/e2e-private/issues/calendar` | Reporter in E2E private with a role without "View calendar": the calendar is refused with 403 (issues list itself is allowed) |
| ![](failure-paths-reporter-public.png) | reporter | `/projects/e2e-project/issues/calendar` | Reporter on the public project calendar: between entries, legend and plugin assets load (200) |

## Problems

- login manager: 404 image /assets/plugin_assets/redmineup/bullet_go.png
- login manager: 404 image /assets/plugin_assets/redmineup/bullet_end.png
- /projects/e2e-project/issues/calendar?set_filter=1&f[]=status_id&op[status_id]=* as manager: 404 image /assets/plugin_assets/redmineup/bullet_diamond.png
- /projects/e2e-project/issues/calendar as reporter: 404 image /assets/plugin_assets/redmineup/bullet_go.png
- /projects/e2e-project/issues/calendar as reporter: 404 image /assets/plugin_assets/redmineup/bullet_diamond.png
- /projects/e2e-project/issues/calendar as reporter: 404 image /assets/plugin_assets/redmineup/bullet_end.png
