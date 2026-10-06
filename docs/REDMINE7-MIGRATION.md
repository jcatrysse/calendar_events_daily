# Redmine 7 migration: calendar_events_daily

Start a Claude Code (or Codex) session on this repository, branch `redmine70-migration`, with:

> Read CLAUDE.md and docs/REDMINE7-MIGRATION.md, then carry out the Redmine 7 migration of this
> plugin as described there, on branch redmine70-migration. Report to me in Dutch at the end.

This file is the plan and the memory of that work. Update it as you go: verdicts, results,
what is left. Written 2026-10-06 from a measured analysis (report at the bottom).

## Status

| | |
|---|---|
| Plugin id | `calendar_events_daily` |
| GEOxyz runs today | `master` |
| Upstream | ablidadev/calendar_events_daily master @ 9b44827 (2024-01-16); bokos/redmine_calendar_events_daily master @ d2f2a11 (2024-01-16) |
| Runs on Redmine 7 as is | DEELS |
| Upstream sync | UPSTREAM DOOD |
| After sync | n.v.t. |
| Complexity (1 trivial .. 5 rewrite) | 2 |
| Measured on | Redmine 7.0.1 (7.0-stable-GEOxyz + latest 7.0-stable), Rails 8.1.3.1, Ruby 3.3.6, PostgreSQL 16 and MariaDB 10.11 |
| Branch head when this file was written | `a7d61a5` |

## Already on this branch

- nothing: the branch equals the branch GEOxyz runs today.

## Work list for the migration session

In this order: things that break, security, the GEOxyz changes, the open items, then the checks.

**Open items from the analysis** (Dutch; where they repeat a priority item, the priority item wins)

1. Rebuild the common/_calendar.html.erb override on the 7.0 partial: restore span.day-value (today indicator #43728), choose SVG or PNG markers (not both), restore sprite_icon 'package'
2. Remove the global a:link/a:visited colour rule from the plugin CSS
3. Empty calendar_events_daily.js loaded on every page; between legend never added

**Checks**

4. Run the plugin's whole test suite on Redmine 7.0-stable-GEOxyz with PostgreSQL AND MariaDB, and once on 5.1-stable if the branch is meant to stay 5.1-compatible.
5. Check Redmine 7 webhooks against this plugin (see "Rules"), and note the result here even if nothing is needed.
6. Verify every feature of the plugin by hand on a running Redmine 7 (screenshots).

## GEOxyz changes to review or re-apply

These GEOxyz commits are on the branch GEOxyz runs today and therefore on this branch. Review each one against the code it now sits on (upstream merges and Redmine 7 core): drop it if upstream or core now does the same, rewrite it if it is not up to the quality rules below (tests, I18n, security, portability), keep it otherwise. Record the verdict per commit in this file.

| commit | date | subject |
|---|---|---|
| `a7d61a5` | 2025-04-26 | * GUI correction * Correct references to plugin name |

## After the upgrade (production)

Actions the person doing the upgrade must take, or know about, for this plugin:

- None known. Add here what the session finds.

## How to test

```sh
./.codex/redmine_clone.sh 7.0-stable-GEOxyz      # or 5.1-stable / 6.1-stable / 7.0-stable
./.codex/test_setup.sh                                 # RMP_DB=mariadb for MariaDB, RMP_PROVISION_DB=0 if a server runs
./.codex/test_plugin.sh                                # minitest + rspec of this plugin
```
On GitHub the same runs by hand only: Actions > "Redmine tests (manual)" > Run workflow.

The coordinator's harness (`plugin-check.sh` in the migration kit, kept outside this repo) adds a
browser smoke test of every page the plugin adds and runs all GEOxyz plugins together; the
results quoted in the analysis come from it.

## How the migration session works (same for every plugin)

1. **Start**: `git fetch && git checkout redmine70-migration && git pull`. Read this whole file,
   including the analysis report at the bottom. Do not reopen decisions recorded here.
2. **Baseline**: set up Redmine 7.0-stable-GEOxyz and run the plugin's tests on PostgreSQL and
   on MariaDB (see "How to test"). Write the numbers here before you change anything.
3. **GEOxyz changes**: go through the table above, one item at a time. Each kept or re-made change
   is its own commit with a test that proves it. Record the verdict in the table.
4. **Work list**: then the numbered list, in order. One concern per commit.
5. **Portability**: everything must run on Redmine's supported databases (PostgreSQL,
   MySQL/MariaDB; SQLite where the plugin already supports it). Migrations must be reversible and
   are run down and up on PostgreSQL and MariaDB.
6. **Browser**: start a Redmine 7 with this plugin, exercise every feature as admin and as a
   normal user with and without the plugin's permissions, and save screenshots (before on 5.1 or
   the old branch, after on 7.0) where behaviour or layout matters.
7. **Together**: run with the other GEOxyz plugins installed (the migration kit's harness, or
   `RMP_EXTRA_PLUGINS`). A failure that only appears in combination is a finding to record here.
8. **After the upgrade**: anything the production upgrade must do for this plugin (data fixes,
   settings, cron, files, removed features) goes into the section "After the upgrade".
9. **Finish**: update "Status" and the work list in this file, push `redmine70-migration`, and
   report: what changed, test numbers on both databases, what is left, what needs Jan.

### Stop and ask Jan when
- a GEOxyz change would be lost or behave differently for users;
- a new gem, a new setting with user impact, or a schema change not required by Redmine 7 seems needed;
- the change would send data to an external service;
- upstream and GEOxyz disagree on behaviour and both are defensible.

## Rules

- **Target**: Redmine 7.0-stable-GEOxyz (https://github.com/jcatrysse/redmine), Rails 8.1, Ruby 3.3+.
  Core sources for comparison: branches `5.1-stable`, `6.1-stable`, `7.0-stable`, `7.0-stable-GEOxyz`.
- **Evidence**: never report a test, lint or browser check as passed without having seen it.
  Quote the summary lines. "Should work" is not a result.
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
  `ContextMenus::*Controller`, Loofah-based text formatting, Chart.js as an ES module.
  The breaker list is in the migration kit's CHECKLIST.md.
- **Locales**: keep the locales the plugin ships in sync; translate a new key by matching the
  closest existing key in the same file, not from scratch; do not add new languages.
- **5.1 compatibility**: prefer fixes that also run on Redmine 5.1 so they can be merged early;
  say so when a fix cannot.
- **Git**: work on `redmine70-migration` only; never push to the default branch; never force-push
  a branch someone else uses. Descriptive commit messages (what and why).
- **GitHub Actions**: manual only (`workflow_dispatch`). Do not add push, pull_request or schedule
  triggers.

## Definition of done

- All items of the work list are done or explicitly deferred with a reason, in this file.
- The plugin's tests are green on Redmine 7.0-stable-GEOxyz with PostgreSQL and MariaDB
  (numbers in this file); boot, production-like eager load, migrations up/down OK.
- Every feature verified by hand on Redmine 7; screenshots listed.
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

