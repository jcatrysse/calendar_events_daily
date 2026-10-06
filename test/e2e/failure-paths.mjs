// Failure paths and edge cases of the calendar with the plugin: module off,
// permission absent, invalid query, closed issues, and no plugin code on other pages.
import { e2e } from '../../.codex/e2e/lib.mjs';
import { check, cells, range } from './helpers.mjs';

const t = await e2e('failure-paths');

await t.login('manager');
await t.go('/projects/e2e-nocal/issues/calendar', { status: 403 });
await t.shot('module-off', 'Calendar module disabled in "E2E no calendar": the calendar is refused with 403');

await t.go('/projects/e2e-project/issues/calendar?set_filter=1&f[]=start_date&op[start_date]=%3D&v[start_date][]=not-a-date');
check(t, await t.page.locator('#errorExplanation').count() === 1, 'invalid filter: the error is shown');
check(t, await t.page.locator('ul.cal').count() === 0 && await t.page.locator('p.legend').count() === 0, 'invalid filter: no calendar and no legend, nothing raised');
await t.shot('invalid-query', 'Invalid start date filter: Redmine shows the validation error, no calendar and no legend (no 500)');

await t.go('/projects/e2e-project/issues/calendar?set_filter=1&f[]=status_id&op[status_id]=*');
const c = await cells(t.page, 'Calendar closed span');
check(t, JSON.stringify(c.between) === JSON.stringify(range(23, 25)), `closed issue shown between on 23-25 with status "any": ${c.between}`);
const deco = await t.page.locator('ul.cal div.issue.between a.issue.closed', { hasText: /Bug #|Feature #|Support #/ }).first().evaluate(a => getComputedStyle(a).textDecorationLine);
check(t, deco === 'line-through', `closed issue link struck through as in core (the old global link rule removed it): ${deco}`);
await t.shot('closed-issue', 'Status "any": the closed issue is on its between days, its link struck through like core does for closed issues');

await t.go('/projects/e2e-project/issues/calendar?year=2026&month=13');
check(t, await t.page.locator('ul.cal').count() === 1, 'month=13 falls back to the current month');
await t.go('/projects/e2e-project/issues/calendar?year=abc&month=xyz');
check(t, await t.page.locator('ul.cal').count() === 1, 'non-numeric year/month fall back to the current month');
await t.shot('bad-month', 'year=abc&month=xyz: the current month is shown, no error');

await t.login('reporter');
await t.go('/projects/e2e-private/issues', { status: 200 });
await t.go('/projects/e2e-private/issues/calendar', { status: 403 });
await t.shot('no-view-calendar', 'Reporter in E2E private with a role without "View calendar": the calendar is refused with 403 (issues list itself is allowed)');

await t.go('/projects');
const html = await t.page.content();
check(t, !html.includes('calendar_events_daily'), 'pages without a calendar load no script or stylesheet of the plugin');
await t.go('/projects/e2e-project/issues/calendar');
const sheet = await t.page.request.get(t.BASE + await t.page.locator('link[href*="calendar_events_daily"]').getAttribute('href'));
const sprite = await t.page.request.get(t.BASE + await t.page.locator('ul.cal div.issue.between svg use').first().getAttribute('href').then(h => h.split('#')[0]));
check(t, sheet.status() === 200 && sprite.status() === 200, `stylesheet ${sheet.status()} and SVG sprite ${sprite.status()} served by Propshaft`);
await t.shot('reporter-public', 'Reporter on the public project calendar: between entries, legend and plugin assets load (200)');

await t.done();
