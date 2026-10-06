// Function: the cross-project calendar (/issues/calendar) shows issues on their
// between days too, with the project name, and only issues the user may see.
import { e2e } from '../../.codex/e2e/lib.mjs';
import { check, cells, range } from './helpers.mjs';

const t = await e2e('global-calendar');

await t.login('admin');
await t.go('/issues/calendar');
let c = await cells(t.page, 'Calendar private span');
check(t, JSON.stringify(c.between) === JSON.stringify(range(6, 8)), `admin sees the private project's issue between on 6-8: ${c.between}`);
const prefixed = await t.page.locator('ul.cal div.issue.between', { hasText: 'Calendar private span' }).first().innerText();
check(t, prefixed.startsWith('E2E private -'), `entries carry the project name: "${prefixed.split('\n')[0]}"`);
await t.shot('admin', 'Admin, all projects: between entries of both projects, each prefixed with the project name (E2E project / E2E private)');

await t.login('manager');
await t.go('/issues/calendar');
c = await cells(t.page, 'Calendar private span');
check(t, c.between.length === 3, 'manager (member of the private project) sees its between days');

await t.login('outsider');
await t.go('/issues/calendar');
c = await cells(t.page, 'Calendar private span');
const pub = await cells(t.page, 'Calendar span 5-9');
check(t, c.between.length === 0 && c.starting.length === 0 && c.ending.length === 0, 'outsider: no entry of the private project on any day, between days included');
check(t, pub.between.length === 3, 'outsider: public project issue between on 6-8');
await t.shot('outsider', 'Outsider, all projects: only the public project; the private issue is on no day, also not as between');

await t.done();
