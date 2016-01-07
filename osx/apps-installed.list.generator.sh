#!/bin/sh
# gets all apps and subtract builtin apps
(ls /App*; ls /App*/Util*) | sed 's/\.app$//' | grep -F -x -v -f apps-builtin.list > apps-installed.list
