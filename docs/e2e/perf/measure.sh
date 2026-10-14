#!/usr/bin/env bash
# measure.sh <label> : median of 5 for the calendar pages as admin, saves HTML
set -e
B=http://127.0.0.1:3000; J=/tmp/claude-0/perf/jar-$1; rm -f $J
tok=$(curl -s -c $J -b $J $B/login | grep -o 'name="authenticity_token" value="[^"]*"' | head -1 | sed 's/.*value="//;s/"$//')
curl -s -c $J -b $J -o /dev/null --data-urlencode "authenticity_token=$tok" --data-urlencode "username=admin" --data-urlencode "password=Redmine7Test!" $B/login
for path in /issues/calendar /projects/e2e-project/issues/calendar /my/page; do
  curl -s -b $J -o /dev/null "$B$path"   # warm up
  times=$(for i in 1 2 3 4 5; do curl -s -b $J -o /tmp/claude-0/perf/$1$(echo $path | tr / _).html -w '%{time_total}\n' "$B$path"; done | sort -n | sed -n 3p)
  size=$(stat -c %s /tmp/claude-0/perf/$1$(echo $path | tr / _).html)
  echo "$1 $path median ${times}s html ${size} bytes"
done
