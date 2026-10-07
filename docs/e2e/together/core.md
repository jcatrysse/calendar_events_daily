# core

Run 2026-10-07T16:11:00.932Z against http://127.0.0.1:3002 (PostgreSQL 16, with 40 other GEOxyz plugins on redmine70-migration, all but redmine_issue_field_visibility and redmine_tint_issues).

| screenshot | user | URL | shows |
|---|---|---|---|
| ![](core-new-issue-form.png) | manager | `/projects/e2e-project/issues/new` | New issue form as a member with every permission |
| ![](core-issue-created.png) | manager | `/issues/18` | The issue is created and shown |
| ![](core-note-added.png) | manager | `/issues/18` | The note is saved and shown in the history |
| ![](core-context-menu.png) | manager | `/projects/e2e-project/issues` | The context menu on the issue list |
| ![](core-issue-as-reporter.png) | reporter | `/issues/1` | An issue seen by a member without the plugin's permissions |
| ![](core-private-refused.png) | outsider | `/projects/e2e-private` | A private project is refused to a non-member |

## Problems

- login manager: 404 image /assets/plugin_assets/redmineup/bullet_go.png
- login manager: 404 image /assets/plugin_assets/redmineup/bullet_end.png
- /issues/1 as reporter: HTTP 403, expected 200
