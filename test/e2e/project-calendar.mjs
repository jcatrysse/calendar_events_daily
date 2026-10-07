// Function: an issue appears on every day from its start to its due date in the
// project calendar, with a "between" marker and a legend entry; core markers,
// today indicator and versions keep working. As every user that matters.
import { e2e } from '../../.codex/e2e/lib.mjs';
import { check, cells, range } from './helpers.mjs';

const t = await e2e('project-calendar');
const CAL = '/projects/e2e-project/issues/calendar';

await t.login('manager');
await t.go(CAL);
let c = await cells(t.page, 'Calendar span 5-9');
check(t, JSON.stringify(c.starting) === '["5"]' && JSON.stringify(c.ending) === '["9"]', `span 5-9 starts on 5 and ends on 9: ${JSON.stringify(c)}`);
check(t, JSON.stringify(c.between) === JSON.stringify(range(6, 8)), `span 5-9 shown between on 6, 7, 8: ${c.between}`);
check(t, c.icons.every(i => ['bullet-go', 'bullet-end', 'between'].includes(i)), `one SVG marker per entry: ${c.icons}`);
c = await cells(t.page, 'Calendar one day');
check(t, JSON.stringify(c.both) === '["15"]' && c.between.length === 0 && c.icons[0] === 'bullet-go-end', `one-day issue: one starting+ending entry on 15: ${JSON.stringify(c)}`);
c = await cells(t.page, 'Calendar start only');
check(t, JSON.stringify(c.starting) === '["12"]' && c.between.length === 0, `start-only issue only on its start date: ${JSON.stringify(c)}`);
c = await cells(t.page, 'Calendar due only');
check(t, JSON.stringify(c.ending) === '["13"]' && c.between.length === 0, `due-only issue only on its due date: ${JSON.stringify(c)}`);
c = await cells(t.page, 'Calendar private span');
check(t, c.between.length === 0, 'issue of another project not in this project calendar');
const legend = await t.page.locator('p.legend.cal span.between').innerText();
check(t, legend.trim() === 'issue active on this day', `legend explains between: "${legend.trim()}"`);
check(t, await t.page.locator('p.legend.cal img').count() === 0, 'legend has no PNG markers next to the SVGs');
check(t, await t.page.locator('li.calbody.today span.day-value').count() === 1, 'today indicator (span.day-value) present');
check(t, await t.page.locator('ul.cal span.icon-package svg use[href$="#icon--package"]').count() === 1, 'version shown with its package icon');
await t.shot('manager-month', 'Manager: "Calendar span 5-9" on 5 (start), 6-8 (between, arrows icon), 9 (end); one-day issue on 15 with the diamond; version on 21 with the package icon; legend lists "issue active on this day"; today has the Redmine 7 circle');
await t.page.locator('ul.cal div.issue.between', { hasText: 'Calendar span 5-9' }).first().screenshot({ path: 'docs/e2e/project-calendar-between-entry.png' });

c = await cells(t.page, 'Calendar long running');
check(t, JSON.stringify(c.starting) === '["20"]' && c.between.includes('21') && c.between.includes('31') === (daysInMonth() >= 31) && c.ending.length === 0,
  `long-running issue (due in three years) starts on 20 and is between on every later day in view: ${c.between}`);

// An issue that neither starts nor ends in the displayed month is fetched too (decision Jan, 2026-10-07)
await t.go(`${CAL}?year=${nextYear()}&month=${nextMonth()}`);
c = await cells(t.page, 'Calendar long running');
check(t, c.between.length >= 35 && c.starting.length === 0 && c.ending.length === 0, `next month: long-running issue between on every day in view: ${c.between.length} days`);
await t.shot('next-month-long-running', 'Next month: "Calendar long running" (started this month, due in three years) is on every day in view as between; before 2026-10-07 core did not fetch it');

await t.login('reporter');
await t.go(CAL);
c = await cells(t.page, 'Calendar span 5-9');
check(t, c.between.length === 3, `reporter (core Reporter role, view_calendar) sees the between days: ${c.between}`);
await t.shot('reporter-month', 'Reporter: same calendar, same between days; the plugin adds no permission of its own');

await t.login('outsider');
await t.go(CAL);
c = await cells(t.page, 'Calendar span 5-9');
check(t, c.between.length === 3, 'outsider sees the public project calendar');
await t.go('/projects/e2e-private/issues/calendar', { status: 403 });
check(t, !(await t.page.content()).includes('Calendar private span'), 'outsider: private project calendar refused, private issue not shown');
await t.shot('outsider-private-refused', 'Outsider: the private project calendar is refused with 403, nothing of the private issue shows');

await t.anonymous();
await t.go('/projects/e2e-private/issues/calendar');
check(t, new URL(t.page.url()).pathname === '/login', `anonymous on the private calendar is sent to the login page: ${t.page.url()}`);
await t.shot('anonymous-private-login', 'Anonymous: the private project calendar redirects to the login page');

await t.done();

function daysInMonth() { const d = new Date(); return new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate(); }
function nextMonth() { const d = new Date(); return ((d.getMonth() + 1) % 12) + 1; }
function nextYear() { const d = new Date(); return d.getMonth() === 11 ? d.getFullYear() + 1 : d.getFullYear(); }
