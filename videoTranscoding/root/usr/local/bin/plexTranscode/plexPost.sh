#!/bin/bash
SCRIPT=$(readlink -f $0)
SCRIPTDIR=$(dirname ${SCRIPT})
BASE=$(dirname ${SCRIPTDIR})
QUEUEDIR=${BASE}/queue

PLEXFILE="$1"
PLEXFN=$(basename "$1")
WORKDIR=$(dirname "$1")
JOBID=$(basename "$WORKDIR")

echo "${PLEXFN}" > "${QUEUEDIR}/${JOBID}.job"
