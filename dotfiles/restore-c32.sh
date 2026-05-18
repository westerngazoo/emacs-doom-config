#!/bin/bash
MUSIC=$(aerospace list-windows --all | grep -i "amazon music" | awk '{print $1}')
BROWSER=$(aerospace list-windows --all | grep -i "Chrome" | grep -v "amazon" | awk '{print $1}' | head -1)
[ -n "$MUSIC" ]   && aerospace resize --window-id "$MUSIC"   height 280
[ -n "$BROWSER" ] && aerospace resize --window-id "$BROWSER" height 560
