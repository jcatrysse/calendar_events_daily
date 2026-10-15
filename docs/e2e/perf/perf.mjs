// Screenshots for the render-cost change (2026-10-14): a month with 400 multi-day issues
// (seed in docs/e2e/perf/seed_perf.rb), the same page before and after. Kept out of test/e2e
// because it needs that seed. Run: RMP_E2E_OUT=docs/e2e/perf PERF_LABEL=after ./.codex/e2e.sh docs/e2e/perf/perf.mjs
// Server time per page: docs/e2e/perf/measure.sh <label> (curl, median of 5).
import { e2e } from '../../../.codex/e2e/lib.mjs';

const label = process.env.PERF_LABEL || 'after';
const t = await e2e(`perf-${label}`);
await t.login('admin');
await t.go('/projects/e2e-project/issues/calendar');
const nav = await t.page.evaluate(() => { const e = performance.getEntriesByType('navigation')[0]; return { server: Math.round(e.responseStart - e.requestStart), load: Math.round(e.loadEventEnd) }; });
const entries = await t.page.locator('ul.cal div.issue').count();
const between = await t.page.locator('ul.cal div.issue.between').count();
await t.page.mouse.move(0, 0);
await t.shot('month', `${label}: E2E project calendar with 400 multi-day issues, ${entries} entries (${between} between), server ${nav.server} ms, load event at ${nav.load} ms`, { full: false });
const tips = await t.page.locator('ul.cal div.issue span.tip').count();
await t.page.locator('ul.cal div.issue.between').nth(40).hover();
const betweenTip = await t.page.locator('ul.cal div.issue.between').nth(40).locator('span.tip').count();
await t.shot('tooltip', `${label}: hovering a between entry, ${betweenTip ? 'its tooltip shows' : 'no tooltip (just the link)'}; ${tips} hidden tooltips in the page`, { full: false });
if (!betweenTip) {
  await t.page.mouse.move(0, 0);
  await t.page.locator('ul.cal div.issue.starting').nth(10).hover();
  await t.shot('tooltip-start', `${label}: hovering a start-day entry shows the issue tooltip`, { full: false });
}
await t.done();
