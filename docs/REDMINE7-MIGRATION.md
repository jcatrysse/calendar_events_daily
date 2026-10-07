# Redmine 7 migration: calendar_events_daily

Start a Claude Code (or Codex) session on this repository, branch `redmine70-migration`, with:

> Read CLAUDE.md and docs/REDMINE7-MIGRATION.md, then carry out the Redmine 7 migration of this
> plugin as described there, on branch redmine70-migration. That includes the plugin's tests on
> PostgreSQL, every function exercised end to end on a real running Redmine in a
> browser (with and without permissions, failure paths included) with screenshots you looked at,
> and an OpenAI review of the diff when OPENAI_API_KEY is set. Report to me in Dutch at the end.

This file is the plan and the memory of that work. Update it as you go: verdicts, results,
what is left. Written 2026-10-06 from a measured analysis (report at the bottom).

## Status

| | |
|---|---|
| Plugin id | `calendar_events_daily` |
| GEOxyz runs today | `master` |
| Upstream | ablidadev/calendar_events_daily master @ 9b44827 (2024-01-16); bokos/redmine_calendar_events_daily master @ d2f2a11 (2024-01-16) |
| Runs on Redmine 7 as is | DEELS (master); this branch: JA |
| Upstream sync | UPSTREAM DOOD |
| After sync | n.v.t. |
| Complexity (1 trivial .. 5 rewrite) | 2 |
| Measured on | Redmine 7.0.1 (7.0-stable-GEOxyz @ 8067e23), Rails 8.1.3.1, Ruby 3.3.6, PostgreSQL 16.15 (production database of GEOxyz). Earlier runs on MariaDB 10.11.14, Redmine 6.1-stable and 5.1-stable (before pictures) are kept as history |
| Migration session | 2026-10-06 work list, 2026-10-07 Jan's decisions built: tests green on PostgreSQL alone and with 40 other GEOxyz plugins, e2e green, OpenAI review resolved |
| Plugin version | 0.0.3, `requires_redmine 6.0.0` (was 0.0.2, 5.1.0) |

## Already on this branch

| commit | what |
|---|---|
| `096e277` | Test kit: `test_setup.sh` created no PostgreSQL role when run as root (`$SUDO -u postgres` with empty `$SUDO`) |
| `f63d833` | Calendar partial rebuilt on the 7.0-stable core partial (today indicator, SVG markers, version icon), "between" SVG icon from a plugin sprite, PNG markers and `::before` overrides removed, stylesheet scoped to the calendar (global link colour rule gone), `requires_redmine 6.0.0`; first tests of the plugin |
| `b5b3f12` | "issue active on this day" in the calendar legend through `view_calendars_show_bottom`; the head hook that loaded an empty script and an inline variable on every page is removed |
| `92bb139` | `events=` indexes only the days the calendar shows (an issue due years ahead filled the index with every day until then) |
| `be885ac` | Legend reads as one block |
| `04bd27a` | End-to-end scenarios and seed, screenshots (PostgreSQL) |
| `4c9f99e` | E2E evidence on MariaDB, together with redmine_people and redmine_agile, before pictures on 5.1 |
| `ada177b` | Test pinning how versions span days (kept, decided by Jan q1), README requirement |
| `0fef6f2` | Jan's decisions of 2026-10-07 (docs/DECISIONS-2026-10-07.md) |
| `65d1a45` | Decision q2: issues that start before and end after the displayed month (calendar) or week (My page) are shown too |
| `067f37f` | E2E scenario `spanning-issues.mjs`, seed, screenshots (PostgreSQL) |
| `71befba` | Context-menu scenario robust against other plugins' menu items; e2e run with 40 GEOxyz plugins |

## Work list for the migration session

In this order: things that break, security, the GEOxyz changes, the open items, then the checks.

**Open items from the analysis** (Dutch; where they conflict with a decision or a priority item above, those win)

1. DONE `f63d833`. Rebuild the common/_calendar.html.erb override on the 7.0 partial: restore span.day-value (today indicator #43728), choose SVG or PNG markers (not both), restore sprite_icon 'package'.
   The partial is now the 7.0-stable core partial verbatim plus the `between` class and its marker, so a
   future core change is a plain diff. Markers: core SVG (`bullet-go`, `bullet-end`, `bullet-go-end`);
   "between" gets `icon--between` from `assets/images/icons.svg` (Tabler "arrows-horizontal", MIT, the
   icon set core uses; it is the same ⇔ idea as the old `cal_between.png`). Choice recorded under
   "Open questions for Jan". Tests: `calendars_controller_test.rb`, `my_controller_test.rb`.
2. DONE `f63d833`. Remove the global a:link/a:visited colour rule from the plugin CSS.
   It recoloured every link on calendar pages and, through `text-decoration: none`, cancelled core's
   line-through on closed issues in the calendar (seen in `docs/e2e/before/before-closed-issue.png`).
   Test: `calendar_events_daily_assets_test.rb` (every selector must be scoped to `.cal`); e2e
   `failure-paths-closed-issue.png`.
3. DONE `b5b3f12`. Empty calendar_events_daily.js loaded on every page; between legend never added.
   Script and head hook removed; the legend line is rendered server side with the existing locale key
   (en, de). Tests: `calendar_events_daily_assets_test.rb`, `calendars_controller_test.rb`.

Found during the session:

- DONE `92bb139`. `events=` walked every day from start to due date; clamped to the displayed range. Test: `calendar_helper_patch_test.rb`.
- DONE `65d1a45` (decision q2, 2026-10-07). Issues spanning the whole displayed range: `CalendarsController`
  (prepend on `render`, for `show`) adds the issues of the same query that start before and end after the grid;
  `MyHelper#render_calendar_block` (prepend) has the same overlap in its condition; `Calendar#events=` rebuilds its
  index. Tests: `calendars_controller_test.rb` (html, xhr, filter, private project, no duplicates),
  `my_controller_test.rb` (whole week, non-member project), `calendar_helper_patch_test.rb` (index rebuilt);
  the four new behaviour tests fail without the change. E2E `spanning-issues.mjs`.
- General decision `prepend`, never `alias_method`: this plugin only uses `prepend` (Calendar, CalendarsController,
  MyHelper); no other GEOxyz plugin patches `CalendarsController#show`/`#render` or
  `MyHelper#render_calendar_block` (checked in all 42 `redmine70-migration` branches).
- Not changed, recorded: see "Findings outside this plugin".

**Checks**

4. DONE. 2026-10-07, Redmine 7.0-stable-GEOxyz, PostgreSQL 16.15: alone `25 runs, 114 assertions, 0 failures, 0 errors,
   0 skips`; with 40 other GEOxyz plugins (all `redmine70-migration` branches except redmine_issue_field_visibility and
   redmine_tint_issues, see findings) `25 runs, 114 assertions, 0 failures, 0 errors, 0 skips`.
   History, 2026-10-06: PostgreSQL 16.15 `18 runs, 96 assertions, 0 failures, 0 errors, 0 skips`;
   MariaDB 10.11.14 `18 runs, 96 assertions, 0 failures, 0 errors, 0 skips`. Redmine 6.1-stable, PostgreSQL:
   `17 runs, 76 assertions, 0 failures` (before the version test was added). 5.1: not supported any more
   (`sprite_icon` does not exist there); master stays the 5.1 version. Every fix's test was run against
   master's code first: 9 failures there, as intended. The plugin has no migrations (nothing to roll back);
   eager load OK (`Rails.application.eager_load!`, production server boot), hook registered once.
5. DONE, nothing needed. Webhooks: the plugin changes no issue data and no API output; it only changes how the
   calendar draws issues. Core webhook payloads are unaffected.
6. DONE. Every function end to end on a running Redmine 7 in production mode, see "Inventory of functions".

## GEOxyz changes to review or re-apply

These GEOxyz commits are on the branch GEOxyz runs today and therefore on this branch. Review each one against the code it now sits on (upstream merges and Redmine 7 core): drop it if upstream or core now does the same, rewrite it if it is not up to the quality rules below (tests, I18n, security, portability), keep it otherwise. Record the verdict per commit in this file.

| commit | date | subject | verdict |
|---|---|---|---|
| `a7d61a5` | 2025-04-26 | * GUI correction * Correct references to plugin name | Plugin name in `stylesheet_link_tag`/`javascript_include_tag`: kept (correct). Compact yellow issue boxes (`div.issue` padding 6px, border): kept, but scoped to `.cal div.issue` (core 7 gives every `div.issue` 16px padding, which would make calendar cells huge). PNG markers and the `::before` overrides: dropped, Redmine 7 draws the markers as SVG (both together gave double markers in the legend). Global `a:link, a:visited` rule: dropped (work list item 2). |

## After the upgrade (production)

Actions the person doing the upgrade must take, or know about, for this plugin:

- Deploy branch `redmine70-migration` (plugin version 0.0.3); no migrations, no settings, no cron.
- Redmine 5.1 cannot run 0.0.3 (`requires_redmine 6.0.0` stops the boot with a clear message), so upgrade
  the plugin together with Redmine.
- Precompile or let Propshaft serve the plugin assets as usual (`assets/images/icons.svg`,
  `assets/stylesheets/calendar_events_daily.css`); the old PNGs and `calendar_events_daily.js` are gone,
  a stale copy under `public/plugin_assets/calendar_events_daily/` can be deleted.
- What users will see: the Redmine 7 markers (circle arrows, diamond) instead of the green/red PNG arrows,
  a ↔ icon on days between start and due date, a legend line "issue active on this day", the blue circle
  around today, and closed issues struck through in the calendar like everywhere else in Redmine.
- Also new for users (decision q2): an issue that runs through a whole month (or week on My page) now appears on
  every day of it; long issues make the calendar fuller. One extra query per calendar page.
- Versions keep showing on every day from the earliest start of their issues to their date (decision q1).

## Inventory of functions

Run 2026-10-07 against `./.codex/start_server.sh` (production mode, PostgreSQL 16.15) in `docs/e2e/`:
`./.codex/e2e.sh` smoke 10 screenshots 0 problems, core flows 6/0, plugin scenarios 6 scripts, 29 screenshots,
0 problems (plus 2 cropped close-ups). Every screenshot opened. With 40 other GEOxyz plugins in `docs/e2e/together/`:
every check of this plugin passes; the problems listed there are other plugins' (see findings). History:
`docs/e2e/mariadb/` (MariaDB, 2026-10-06, before decision q2), `docs/e2e/before/` (master on Redmine 5.1).

| function | how a user reaches it | scenario | screenshots |
|---|---|---|---|
| Issue shown on every day between start and due date, with a "between" marker; start/end/one-day markers; issues with only one date only on that date | Project > Calendar | `test/e2e/project-calendar.mjs` | `project-calendar-manager-month.png`, `project-calendar-between-entry.png` |
| Legend line "issue active on this day" | Project > Calendar, below the calendar | `project-calendar.mjs` | `project-calendar-manager-month.png` |
| Redmine 7 today indicator and version icon kept | Project > Calendar | `project-calendar.mjs` | `project-calendar-manager-month.png` |
| Issue due years ahead: between on every later day, also in the following months | Project > Calendar | `project-calendar.mjs` | `project-calendar-manager-month.png`, `project-calendar-next-month-long-running.png` |
| Same calendar per role: member without extra rights, non-member on public and private project, anonymous | Project > Calendar | `project-calendar.mjs` | `project-calendar-reporter-month.png`, `project-calendar-outsider-private-refused.png` (403), `project-calendar-anonymous-private-login.png` |
| Cross-project calendar with project prefix, private issues only for members | Top menu > Calendar (`/issues/calendar`) | `global-calendar.mjs` | `global-calendar-admin.png`, `global-calendar-outsider.png` |
| My page week calendar block | My page, block "Calendar" | `my-page-calendar.mjs` | `my-page-calendar-manager.png`, `my-page-calendar-block.png`, `my-page-calendar-outsider.png` (empty block) |
| Tooltip and context menu on a between entry, edit through the menu, greyed actions for a reporter | Hover / right-click an entry | `context-menu.mjs` | `context-menu-tooltip.png`, `context-menu-manager-menu.png`, `context-menu-manager-priority-changed.png`, `context-menu-reporter-menu.png` |
| Issues that start before and end after the displayed month or week, on every day as between; query filters and visibility apply (decision q2) | Project > Calendar, top menu > Calendar, My page | `spanning-issues.mjs`, `project-calendar.mjs` | `spanning-issues-admin-all-projects.png`, `spanning-issues-manager-project.png`, `spanning-issues-manager-filter.png`, `spanning-issues-manager-my-page.png`, `spanning-issues-reporter-project.png`, `spanning-issues-reporter-all-projects.png`, `spanning-issues-reporter-private-refused.png` (403), `spanning-issues-outsider-all-projects.png`, `spanning-issues-outsider-private-refused.png` (403), `spanning-issues-outsider-my-page.png` (empty), `project-calendar-next-month-long-running.png` |
| Failure paths: calendar module off (403), role without view_calendar (403), invalid filter (error, no calendar, no legend), bad month/year, closed issue struck through, no plugin asset on other pages, assets served | Project > Calendar with these conditions | `failure-paths.mjs` | `failure-paths-module-off.png`, `failure-paths-no-view-calendar.png`, `failure-paths-invalid-query.png`, `failure-paths-bad-month.png`, `failure-paths-closed-issue.png`, `failure-paths-reporter-public.png` |

The plugin has no permissions, settings, routes, API, mail, rake tasks or cron of its own; it only changes
how core's calendar (project, cross-project, My page) draws issues. Every screenshot was opened and checked.

## Findings outside this plugin (not changed here)

- Core: the calendar only fetches issues that start or end in the displayed range. Solved in this plugin by decision
  q2 (`65d1a45`). redmine_reporter_dashboards builds its own week calendar with core's condition
  (`reporter_project_pages_helper.rb:338`), so issues spanning that whole week stay missing there.
- With all 42 GEOxyz plugins (2026-10-07), recursion from `alias_method` mixed with `prepend`, not in this plugin:
  redmine_issue_field_visibility (`alias_method` on `IssueQuery#initialize_available_filters`) with redmine_agile
  (`prepend`): SystemStackError on every issue query (issue list, calendar); redmine_tint_issues (`alias_method` on
  `Issue#css_classes`) with redmine_agile: SystemStackError wherever an issue's CSS classes are drawn (calendar,
  issue list); redmine_mail_digest (`alias_method` on `ProjectsHelper#project_settings_tabs`) with the others:
  Project > Settings HTTP 500 (`docs/e2e/together/smoke-06.png`). These are for those plugins' sessions under
  Jan's general decision; the combination run here leaves the first two out.
- redmine_view_issue_description: the reporter gets 403 on an issue page in the combination
  (`vid_authorize_issue_detail`), that plugin's own permission working as designed.
- Core 7.0: on the cross-project calendar a version is drawn as "E2E project -" wrapped next to the link
  (`span.icon.icon-package` is a flex box); same markup as core, `global-calendar-admin.png`.
- redmineup gem 1.1.13 (used by redmine_agile and redmine_people): `redmineup.css`, `calendars.css` and `money.css`
  still carry the 5.1 calendar rules (`.cal .starting a.issue { background: url(bullet_go.png); padding-left: 16px }`),
  so on Redmine 7 every page asks for `/assets/plugin_assets/redmineup/bullet_*.png` (404) and core's start/end
  markers and legend get a 16px indent (`docs/e2e/together/project-calendar-manager-month.png`). For the migration
  of those plugins / the gem, not for this one.
- redmine_agile or redmine_people (redmine70-migration): `linkableAttributeFields is not defined` on the issue page
  as reporter (`docs/e2e/together/core.md`).
- redmine_people patches `Redmine::Helpers::Calendar` too (`custom_events=`); it does not go through this plugin's
  `events=`, and its own calendar test passes with both installed (`3 runs, 22 assertions, 0 failures`).

## Review

- Own review of the whole diff: one point, the version behaviour (open question 1); nothing else.
- OpenAI review (`gpt-5`, range `8104c28..ada177b`): no findings, `docs/reviews/openai-2026-10-06-ada177b.md`.
- 2026-10-07, own review of the new commits: nothing to change (added issues are disjoint from core's, one extra
  query, filters and visibility through `@query`, guarded against adding twice).
- OpenAI review (`gpt-5`, range `e737933..71befba`): two findings, both resolved as not a defect with the core
  code that shows it (core fetches against the grid, not the month; `IssueQuery#issues` always includes
  `:project`), `docs/reviews/openai-2026-10-07-71befba.md`.

## Decided by Jan

2026-10-07, in the coordinating session (docs/DECISIONS-2026-10-07.md). Final.

General, for every GEOxyz plugin: GEOxyz goes straight to Redmine 7, no backports to 5.1, Redmine 5.1 compatibility
is no longer a requirement; PostgreSQL 16 only (MariaDB runs no longer required); `prepend`, never `alias_method`,
on core methods other plugins also patch; GitHub Actions manual only.

1. **Versions on the days before their date** (q1). Jan chose A: "Zo laten, versies op elke dag" (Geen wijziging;
   lange versies blijven de kalender vullen.). Kept, pinned by `test_version_is_shown_from_the_start_of_its_issues_to_its_date`.
2. **Issues spanning a whole month** (q2). Jan chose B: "Aanpassen, als aparte wijziging met tests" (De kalender
   haalt ook tickets op die de maand overlappen; de plugin past daarvoor twee stukken Redmine-code aan.). Built in
   `65d1a45`, e2e in `067f37f`.
3. **Marker style** (q3). Jan chose A: "De Redmine 7-iconen houden" (Ziet eruit als de rest van Redmine 7;
   gebruikers zien wel andere markeringen dan ze gewend zijn.). Kept as built in `f63d833`.
4. **Redmine 5.1** (was open question 4): settled by the general decision; this branch needs Redmine 6.0+, nothing
   for 5.1.

No open questions left. Not testable here: nothing; the plugin has no external integration.

## How to test

```sh
./.codex/redmine_clone.sh 7.0-stable-GEOxyz      # or 5.1-stable / 6.1-stable / 7.0-stable
./.codex/test_setup.sh                                 # PostgreSQL; RMP_PROVISION_DB=0 if a server runs
./.codex/test_plugin.sh                                # minitest + rspec of this plugin
```

```sh
./.codex/start_server.sh       # real Redmine (production mode) with this plugin, seeded users and projects
./.codex/e2e.sh                # browser: smoke over the plugin's pages, core issue flows, test/e2e/*.mjs
./.codex/openai_review.sh      # independent OpenAI review of the diff, only when OPENAI_API_KEY is set
```
Write one scenario per function in `test/e2e/<function>.mjs` (example at the top of
`.codex/e2e/lib.mjs`); screenshots and a table per scenario land in `docs/e2e/`. Users:
`admin`, `manager` (every permission), `reporter` (no plugin permissions), `outsider` (no
membership); password `Redmine7Test!`. Needs Node with Playwright and Chromium
(`npm install -g playwright && npx playwright install --with-deps chromium`).

On GitHub the same runs by hand only: Actions > "Redmine tests (manual)" > Run workflow (tick
"e2e" for the browser run; screenshots come back as an artifact).

The coordinator's harness (`plugin-check.sh` in the migration kit, kept outside this repo) adds a
browser smoke test of every page the plugin adds and runs all GEOxyz plugins together; the
results quoted in the analysis come from it.

## How the migration session works (same for every plugin)

1. **Start**: `git fetch && git checkout redmine70-migration && git pull`. Read this whole file,
   including the analysis report at the bottom. Do not reopen decisions recorded here.
2. **Baseline, before you change anything**:
   - the plugin's tests on Redmine 7.0-stable-GEOxyz with PostgreSQL;
   - a real running Redmine with this plugin (`./.codex/start_server.sh`) and the browser run
     (`./.codex/e2e.sh`: smoke over every page the plugin adds, plus the core issue flows).
   Write the numbers here. Something already broken now is a finding, not your regression.
3. **Inventory of functions**: list every function of the plugin in this file, in a table
   "function | how a user reaches it | scenario | screenshot". Take them from the README,
   `init.rb` (permissions, menus, settings, project modules), routes, hooks and view
   overrides, macros, mail handling, API endpoints, rake tasks and cron jobs. This table is the
   coverage list for step 8; a function that is not in it will not be tested.
4. **GEOxyz changes**: go through the table above, one item at a time. Each kept or re-made change
   is its own commit with a test that proves it. Record the verdict in the table.
5. **Work list**: then the numbered list, in order. One concern per commit.
6. **Portability**: tests and migrations run on PostgreSQL 16, the database GEOxyz uses (decided by Jan
   2026-10-07); keep SQL portable to MySQL/MariaDB where that costs nothing. Migrations must be reversible and
   are run down and up on PostgreSQL.
7. **Together**: run with the other GEOxyz plugins installed (the migration kit's harness, or
   `RMP_EXTRA_PLUGINS`). A failure that only appears in combination is a finding to record here.
8. **End to end, visually, every function**: on the real Redmine from `start_server.sh`
   (production mode, the way GEOxyz runs it), write one scenario per function in
   `test/e2e/<function>.mjs` with `.codex/e2e/lib.mjs` and run them with `./.codex/e2e.sh`.
   - Each function as the users that matter: `admin`, `manager` (every permission, the
     plugin's included), `reporter` (member without the plugin's permissions), `outsider`
     (no membership, private project must stay invisible).
   - The failure paths too: setting off, permission absent, empty state, invalid input, the
     value that used to raise. A refusal that is shown is evidence as much as a success.
   - One screenshot per function and per path, with a caption saying what it proves. Open
     every screenshot and look at it: a picture nobody looked at proves nothing. Commit them
     in `docs/e2e/` and list them in the inventory table.
   - Functions without a page (mail in and out, REST API, rake tasks, cron, webhooks): exercise
     them against the same running instance (mails land in `redmine/tmp/mails`, `t.mails()`
     reads them; API through `t.page.request`) and record command and result.
   - Before pictures where behaviour or layout changes: the branch GEOxyz runs today, on
     Redmine 5.1, same scenarios, `RMP_E2E_OUT=docs/e2e/before`.
9. **Independent review**: first your own, adversarial: re-read the whole diff as if someone
   else wrote it and you are paid to reject it. Then, **when `OPENAI_API_KEY` is set in the
   session**, `./.codex/openai_review.sh`: it sends the diff of this branch to an OpenAI model
   and writes `docs/reviews/openai-<date>-<sha>.md`. Every finding gets a `Resolution:` line
   there (fixed in <commit>, with a test, or why not). Fix, re-run the tests and the e2e set,
   and run the review again until it has nothing new that you accept. Without the key: write
   "OpenAI review: skipped, no OPENAI_API_KEY" in the report; never send code anywhere else.
10. **After the upgrade**: anything the production upgrade must do for this plugin (data fixes,
    settings, cron, files, removed features) goes into the section "After the upgrade".
11. **Finish**: update "Status", the inventory and the work list in this file, push
    `redmine70-migration`, and report: what changed, test numbers on both databases, e2e
    numbers (scenarios, screenshots, problems), the review result, what is left, what needs Jan.

### Stop and ask Jan when
- a GEOxyz change would be lost or behave differently for users;
- a new gem, a new setting with user impact, or a schema change not required by Redmine 7 seems needed;
- the change would send data to an external service (the OpenAI review of the code diff is the
  one exception Jan approved, and only when the key is present);
- upstream and GEOxyz disagree on behaviour and both are defensible.

## Rules

- **Target**: Redmine 7.0-stable-GEOxyz (https://github.com/jcatrysse/redmine), Rails 8.1, Ruby 3.3+.
  Core sources for comparison: branches `5.1-stable`, `6.1-stable`, `7.0-stable`, `7.0-stable-GEOxyz`.
- **Evidence**: never report a test, lint, browser check or review as passed without having seen
  it. Quote the summary lines; list the screenshots. "Should work" is not a result, and a green
  test suite is not proof that a feature works in the browser.
- **Tests**: never skip, delete or weaken a test. A test that encodes Redmine 5 markup or
  behaviour is updated to Redmine 7, with the reason in the commit. Every fix gets a test that
  fails without it.
- **Minimal diffs** in the plugin's own style. No reformatting, no unrelated refactoring.
  Something wrong elsewhere: write it down here, do not fix it in passing.
- **Security**: authorization on every action and entry point; `safe_attributes`, never
  `to_unsafe_hash` into `update`; no SQL built from params; no secrets in logs; no `html_safe` on
  user input.
- **Webhooks (new in Redmine 7)**: core sends issue payloads (core `issues/show.api.rsb`, rendered
  as the webhook owner) to webhook endpoints, past plugin hooks and controller patches. If the
  plugin hides, adds or changes issue data, make webhooks consistent with that or record why not.
- **Redmine 7 conventions**: SVG icons through `sprite_icon` (the `icon icon-*` CSS is gone),
  Propshaft assets under `assets/` (`/assets/plugin_assets/<id>/...`), the new header and user menu,
  `ContextMenus::*Controller`, Loofah-based text formatting, Chart.js as an ES module, sudo mode
  (on by default: `t.sudo()` in a scenario). The breaker list is in the migration kit's CHECKLIST.md.
- **Locales**: keep the locales the plugin ships in sync; translate a new key by matching the
  closest existing key in the same file, not from scratch; do not add new languages.
- **No 5.1** (decided by Jan 2026-10-07): GEOxyz goes straight to Redmine 7; no backports, no code paths only
  for 5.1, nothing cherry-picked to the default branch or the branch production runs today.
- **PostgreSQL only** (decided by Jan 2026-10-07): tests and e2e on PostgreSQL 16; keep SQL portable where it
  costs nothing; a MariaDB-only problem is a note here, not a blocker.
- **`prepend`, never `alias_method`** on a core method other plugins also patch (decided by Jan 2026-10-07).
- **Git**: work on `redmine70-migration` only; never push to the default branch; never force-push
  a branch someone else uses. Descriptive commit messages (what and why). Push after every
  commit, together with the updated status in this file: a cloud session can stop at a usage
  limit, and work that is not pushed is lost with its container.
- **GitHub Actions**: manual only (`workflow_dispatch`). Do not add push, pull_request or schedule
  triggers.

## Definition of done

- All items of the work list are done or explicitly deferred with a reason, in this file.
- The plugin's tests are green on Redmine 7.0-stable-GEOxyz with PostgreSQL
  (numbers in this file); boot, production-like eager load, migrations up/down OK.
- Every function in the inventory exercised end to end on a real running Redmine, with and
  without permissions and on its failure paths; `./.codex/e2e.sh` green; screenshots looked at,
  committed in `docs/e2e/` and listed.
- Review done: your own, and the OpenAI review when the key is present, every finding resolved
  in `docs/reviews/`.
- No new failure when run together with the other GEOxyz plugins.
- "After the upgrade" lists every action production needs; "Status" is current.


## Analysis report (2026-10-06, Dutch)

# calendar_events_daily
- Gebruikte branch: master @ a7d61a5 (2025-04-26) - plugin id calendar_events_daily, versie 0.0.2
- Upstream: ablidadev/calendar_events_daily - upstream HEAD master @ 9b44827 (2024-01-16), enige branch. De README noemt ook bokos/redmine_calendar_events_daily (oorspronkelijke auteur): master @ d2f2a11 (2024-01-16, zelfde "update view for redmine 5.1"), 2 commits, niets nieuwers.
- Fork t.o.v. upstream: 1 eigen commit (a7d61a5 GUI + pluginnaam), 0 upstream-commits ontbreken
- Andere relevante branches: geen.
- Geen Gemfile, geen migraties, geen tests.
- Werking: prepend op `Redmine::Helpers::Calendar` (`initialize`, `events=`, `events_on`) + override van core-partial app/views/common/_calendar.html.erb (klasse `between`) + CSS met PNG-markeringen.

## 1. Werkt out of the box op Redmine 7?   DEELS
- Harness (results/1006-085948-...): alles OK, smoke 60/60 - maar de smoke bezoekt `/projects/<p>/calendar`, in 7.0 een 404 (route is `/projects/:id/issues/calendar`); de kalender werd door de harness dus niet getest.
- Live op de juiste URL: de functie werkt - issue verschijnt op elke dag tussen start- en einddatum (5 `between`, 1 `starting`, 1 `ending`), contextmenu op de kalender OK, geen JS-fouten. De helper-patch past nog (signatuur `initialize(date, lang, period)`, `@ending/@starting_events_by_days` ongewijzigd).
- Wat de override verbergt (vergeleken met 7.0 zonder plugin, screenshots gemaakt): de "vandaag"-aanduiding van 7.0 (#43728: blauwe cirkel rond het dagnummer via `span.day-value`) ontbreekt, vandaag is enkel vet; de SVG-markeringen `bullet-go/bullet-end/bullet-go-end` en `package` (versies) ontbreken; de core-legende toont wel SVG-iconen, de cellen PNG's.

## 2. Upstream sync?   UPSTREAM DOOD
- Beide upstreams sinds januari 2024 stil, fork bevat alles.

## 3. Werkt na sync op Redmine 7?   n.v.t.

## 4. Complexiteit en blokkers   score 2
- Blokkers: geen (niets raist). Branch redmine70-migration = origin/master.
- Stille breuken:
  - app/views/common/_calendar.html.erb is een 5.1-kopie (diff tegen 7.0: `span.day-value`, `sprite_icon`-markeringen en `sprite_icon 'package'` ontbreken). Open.
  - assets/stylesheets/calendar_events_daily.css zet globaal `a:link, a:visited { color: #169 }` op kalenderpagina's.
  - assets/javascripts/calendar_events_daily.js is leeg maar wordt via `view_layouts_base_html_head` op elke pagina geladen (+ inline variabele `calendar_events_daily_between`); de "between"-legende wordt nergens toegevoegd.
- Overlap met Redmine 7 core: geen (core toont issues alleen op start- en einddag).
- Open werk voor ansif:
  - Override herbouwen op de 7.0-partial: `<p class="day-num"><span class="day-value"><%= day.day %></span> ...`, de `between`-klasse behouden, kiezen tussen core-SVG (`sprite_icon('bullet-go'...)`) of de PNG's (niet beide, anders dubbele markering), `sprite_icon 'package'` voor versies terugzetten.
  - Globale linkkleur-regel uit de CSS halen; lege JS en inline variabele schrappen of de legende echt aanvullen.

## Branch redmine70-migration
- Basis: origin/master @ a7d61a5 (geen commits)
- Commits: geen
- Eindresultaat harness (results/1006-100229-s3-calendar_events_daily_redmine70-migration): OK bundle, boot 0.0.2, eager load, migraties dev+test, OK smoke 60/60 (kalender niet gedekt door de smoke, zie boven)
- Rollback migraties: n.v.t.

