// Function: an issue on a between day is a full calendar entry: tooltip on hover,
// right-click context menu with the user's own rights, and an edit through it works.
import { e2e } from '../../.codex/e2e/lib.mjs';
import { check } from './helpers.mjs';

const t = await e2e('context-menu');
const CAL = '/projects/e2e-project/issues/calendar';
const entry = () => t.page.locator('ul.cal div.issue.between', { hasText: 'Calendar span 5-9' }).first();

await t.login('manager');
await t.go(CAL);
await entry().hover();
const tip = entry().locator('span.tip');
check(t, await tip.isVisible(), 'tooltip shows on hover of a between entry');
check(t, /Start date/.test(await tip.innerText()), 'tooltip lists the dates');
await t.shot('tooltip', 'Manager: hovering a between entry shows the issue tooltip with start and due date', { full: false });

await t.page.mouse.move(0, 0);
await entry().click({ button: 'right', position: { x: 12, y: 10 } });
await t.page.locator('#context-menu').waitFor({ state: 'visible' });
const menu = await t.page.locator('#context-menu').innerText();
check(t, /Edit/.test(menu) && /Priority/.test(menu), `context menu offers edit and priority: ${menu.replace(/\s+/g, ' ').slice(0, 80)}`);
await t.shot('manager-menu', 'Manager: right-click on a between entry opens the issue context menu with all actions');

await t.page.locator('#context-menu a.submenu', { hasText: 'Priority' }).hover();
await t.page.locator('#context-menu a', { hasText: /^High$/ }).click();
await t.settle();
t.check('set priority');
await t.sudo();
const high = await t.page.locator('ul.cal div.issue.between[class*="priority-high"]', { hasText: 'Calendar span 5-9' }).count();
check(t, high === 3, `priority changed through the menu of a between entry, entry re-rendered on all between days: ${high}`);
await t.shot('manager-priority-changed', 'Manager: after "Priority > High" from the menu, the issue is back on the calendar on all its days');

// put it back, so the scenario can run again
await t.page.mouse.move(0, 0);
await entry().click({ button: 'right', position: { x: 12, y: 10 } });
await t.page.locator('#context-menu a.submenu', { hasText: 'Priority' }).hover();
await t.page.locator('#context-menu a', { hasText: /^Normal$/ }).click();
await t.settle();
t.check('reset priority');

await t.login('reporter');
await t.go(CAL);
await entry().click({ button: 'right', position: { x: 12, y: 10 } });
await t.page.locator('#context-menu').waitFor({ state: 'visible' });
const enabledDelete = await t.page.locator('#context-menu a', { hasText: 'Delete issue' }).evaluateAll(as => as.filter(a => !a.classList.contains('disabled')).length);
const enabledEdit = await t.page.locator('#context-menu a', { hasText: /^Edit$/ }).evaluateAll(as => as.filter(a => !a.classList.contains('disabled')).length);
check(t, enabledDelete === 0 && enabledEdit === 0, `reporter: edit and delete are disabled in the context menu of a between entry (delete ${enabledDelete}, edit ${enabledEdit})`);
await t.shot('reporter-menu', 'Reporter: the context menu on a between entry greys out what the Reporter role may not do (Edit, Delete issue)');

await t.done();
