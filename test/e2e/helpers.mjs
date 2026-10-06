// Shared checks for the calendar scenarios: a failed check is a problem in the run.
export function check(t, ok, what) {
  if (!ok) t.problems.push(`check failed: ${what}`);
  console.log(`  ${ok ? 'ok  ' : 'FAIL'} ${what}`);
}

// Calendar cells (li.calbody) that show the issue with this subject, per marker class.
export async function cells(page, subject) {
  return page.evaluate(s => {
    const out = { between: [], starting: [], ending: [], both: [], icons: [] };
    document.querySelectorAll('ul.cal li.calbody').forEach(li => {
      const day = li.querySelector('.day-value')?.textContent.trim();
      li.querySelectorAll('div.issue').forEach(div => {
        if (!div.textContent.includes(s)) return;
        const c = div.classList;
        if (c.contains('between')) out.between.push(day);
        else if (c.contains('starting') && c.contains('ending')) out.both.push(day);
        else if (c.contains('starting')) out.starting.push(day);
        else if (c.contains('ending')) out.ending.push(day);
        out.icons.push([...div.querySelectorAll(':scope > svg use')].map(u => u.getAttribute('href').split('#icon--')[1]).join('+'));
      });
    });
    return out;
  }, subject);
}

export const range = (a, b) => Array.from({ length: b - a + 1 }, (_, i) => String(a + i));
