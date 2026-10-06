// Function: the calendar block on My page (one week) shows issues on their between
// days with the same markers; the block has no legend, as in core.
import { e2e } from '../../.codex/e2e/lib.mjs';
import { check, cells } from './helpers.mjs';

const t = await e2e('my-page-calendar');

await t.login('manager');
await t.go('/my/page');
await t.page.mouse.move(0, 0);
const block = t.page.locator('#block-calendar');
check(t, await block.count() === 1, 'manager has the calendar block on My page');
const c = await cells(t.page, 'Calendar this week');
check(t, c.between.length >= 5 && c.starting.length <= 1 && c.ending.length === 0, `"Calendar this week" between on the other days of the week: ${JSON.stringify(c)}`);
check(t, await block.locator('li.calbody.today span.day-value').count() === 1, 'today indicator in the week');
check(t, await block.locator('svg use[href*="plugin_assets/calendar_events_daily/icons"]').count() >= 5, 'between icon loaded from the plugin sprite');
check(t, await t.page.locator('p.legend').count() === 0, 'no legend on My page');
await block.screenshot({ path: 'docs/e2e/my-page-calendar-block.png' });
await t.shot('manager', 'Manager, My page: the week calendar block shows "Calendar this week" on its start day and as between on every later day of the week');

await t.login('outsider');
await t.go('/my/page');
check(t, await t.page.locator('#block-calendar ul.cal').count() === 1, 'outsider has the calendar block');
check(t, await t.page.locator('#block-calendar div.issue').count() === 0, 'outsider: no issue in the block (only projects the user is a member of, as in core)');
await t.shot('outsider', 'Outsider, My page: the calendar block is there but empty, no issue of any project, private or public (core lists member projects only)');

await t.done();
