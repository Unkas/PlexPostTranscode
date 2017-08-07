#!/usr/bin/with-contenv sh
exec s6-setuidgid ${TRANSCODE_USER} /postproc/bin/queueman.sh
