#!/usr/bin/env -S nim --hints:off
mode = ScriptMode.Verbose

exec "nim c -d:ssl ares"
