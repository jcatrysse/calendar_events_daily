// "Before" pictures: the branch GEOxyz runs today (master) on Redmine 5.1, same seed.
// Kept out of test/e2e so that e2e.sh does not run it against Redmine 7. Run against the 5.1 server:
//   RMP_PORT=3001 RMP_E2E_OUT=docs/e2e/before ./.codex/e2e.sh docs/e2e/before/before.mjs
import { e2e } from '../../../.codex/e2e/lib.mjs';

const t = await e2e('before');
await t.login('manager');
await t.go('/projects/e2e-project/issues/calendar');
await t.page.mouse.move(0, 0);
await t.shot('project-calendar', 'Before (master on Redmine 5.1): between days marked with the PNG "between" icon, start/end with PNG bullets; no legend line for "between"');
await t.go('/projects/e2e-project/issues/calendar?set_filter=1&f[]=status_id&op[status_id]=*');
await t.shot('closed-issue', 'Before: with status "any" the closed issue is shown, its link not struck through (the plugin\'s global link rule removed it)');
await t.go('/my/page');
await t.page.mouse.move(0, 0);
await t.shot('my-page', 'Before: My page week calendar block with between entries');
await t.done();
