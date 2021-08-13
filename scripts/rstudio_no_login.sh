#!/bin/bash

# From https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_rstudio.sh#L86
cp /etc/rstudio/disable_auth_rserver.conf /etc/rstudio/rserver.conf 

# echo '#!/usr/bin/with-contenv bash
# ## load /etc/environment vars first:
# for line in $( cat /etc/environment ) ; do export $line > /dev/null; done
# exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0 --auth-minimum-user-id 0 --auth-validate-users 0 ' \
# > /etc/services.d/rstudio/run

