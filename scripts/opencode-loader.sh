#!/bin/bash
makoctl notify -a "opencode" -i "opencode-desktop" -t 2000 "Opening OpenCode..." &
sleep 0.5
/opt/opencode-desktop/ai.opencode.desktop --ozone-platform-hint=auto &
