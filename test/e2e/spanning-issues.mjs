// Function (decision Jan 2026-10-07, q2): issues that start before and end after the displayed
// month or week are shown on every day as "between", in the project calendar, the cross-project
// calendar and the My page block, with the query's filters and the user's visibility applied.
import { e2e } from '../../.codex/e2e/lib.mjs';
import { check, cells } from './helpers.mjs';

const t = await e2e('spanning-issues');
const CAL = '/projects/e2e-project/issues/calendar';
const days = async (subject) => { const c = await cells(t.page, subject); return { ...c, all: c.between.length + c.starting.length + c.ending.length + c.both.length }; };

await t.login('admin');
await t.go('/issues/calendar');
let c = await days('Calendar whole month bug');
const p = await days('Calendar private whole month');
check(t, c.between.length >= 35 && c.all === c.between.length, `admin, all projects: whole-month issue between on every day in view (${c.between.length})`);
check(t, p.between.length >= 35, `admin sees the private project's whole-month issue (${p.between.length})`);
await t.page.mouse.move(0, 0);
await t.shot('admin-all-projects', 'Admin, all projects: "Calendar whole month" and "Calendar private whole month" (start last month, due next month) on every day as between');

await t.login('manager');
await t.go(CAL);
c = await days('Calendar whole month bug');
check(t, c.between.length >= 35, `manager, project calendar: whole-month issue on every day (${c.between.length})`);
await t.page.mouse.move(0, 0);
await t.shot('manager-project', 'Manager, project calendar: the whole-month issue and feature run through every day of the month; before the change they were missing');

await t.go(`${CAL}?set_filter=1&f[]=status_id&op[status_id]=o&f[]=tracker_id&op[tracker_id]=%3D&v[tracker_id][]=1`);
c = await days('Calendar whole month feature');
const bug = await days('Calendar whole month bug');
check(t, c.all === 0 && bug.between.length >= 35, `tracker filter "Bug": the whole-month feature is filtered out (${c.all}), the whole-month bug stays (${bug.between.length})`);
await t.page.mouse.move(0, 0);
await t.shot('manager-filter', 'Manager, filter tracker = Bug: the whole-month Feature is gone, the whole-month Bug stays; the added issues follow the query');

await t.go('/my/page');
await t.page.mouse.move(0, 0);
c = await days('Calendar whole month bug');
check(t, c.between.length === 7, `manager, My page week: whole-month issue on all 7 days (${c.between.length})`);
const pw = await days('Calendar private whole month');
check(t, pw.between.length === 7, `manager, My page week: private whole-month issue on all 7 days, manager is a member (${pw.between.length})`);
await t.shot('manager-my-page', 'Manager, My page: the week block shows both whole-month issues on all seven days');

await t.login('reporter');
await t.go(CAL);
c = await days('Calendar whole month bug');
check(t, c.between.length >= 35, `reporter, project calendar: whole-month issue on every day (${c.between.length})`);
await t.page.mouse.move(0, 0);
await t.shot('reporter-project', 'Reporter (core Reporter role): sees the whole-month issues of the public project like every other issue');
await t.go('/projects/e2e-private/issues/calendar', { status: 403 });
await t.shot('reporter-private-refused', 'Reporter in E2E private without "View calendar": the private calendar is refused (403), also with the change');
await t.go('/issues/calendar');
c = await days('Calendar private whole month');
const coreFetched = await days('Calendar private span');
// the cross-project calendar lists what the user may see (view_issues), core does the same for its own issues
check(t, (c.all > 0) === (coreFetched.all > 0), `reporter, all projects: the private whole-month issue follows core's visibility, like the private span core fetches itself (${c.all} / ${coreFetched.all})`);
await t.page.mouse.move(0, 0);
await t.shot('reporter-all-projects', 'Reporter, all projects: issues of E2E private are listed because the reporter may view its issues (core rule for the cross-project calendar); the whole-month issue follows the same rule as the private span');
await t.go('/my/page');
c = await days('Calendar private whole month');
check(t, c.all === 0, `reporter, My page: no private whole-month issue (${c.all})`);

await t.login('outsider');
await t.go('/issues/calendar');
c = await days('Calendar private whole month');
const pub = await days('Calendar whole month bug');
check(t, c.all === 0 && pub.between.length >= 35, `outsider, all projects: public whole-month issue shown (${pub.between.length}), private one not (${c.all})`);
await t.page.mouse.move(0, 0);
await t.shot('outsider-all-projects', 'Outsider, all projects: the public whole-month issues on every day, nothing of the private project');
await t.go('/projects/e2e-private/issues/calendar', { status: 403 });
await t.shot('outsider-private-refused', 'Outsider: the private project calendar is refused (403)');
await t.go('/my/page');
c = await days('Calendar whole month bug');
check(t, c.all === 0, `outsider, My page: no issue at all, no memberships (${c.all})`);
await t.shot('outsider-my-page', 'Outsider, My page: the week block stays empty, as core (member projects only)');

await t.done();
