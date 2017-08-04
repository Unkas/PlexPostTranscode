#!/bin/bash

do_log(){
    echo "${QE} -$@"
}

die() {
    do_log "${@}"
	trap "" SIGNIT SIGTERM SIGHUP
	cleanup
	exit 1
}

cleanup() {
    [ -z "${WORKDIR}" ] && return
	[ -d ${WORKDIR} ] && rm -rf ${WORKDIR}
}

transcode_video () {
    typeset INFILE="$1"
	shift
	nice transcode_video INFILE
}
QUEUEDIR=/home/vader/github/queue
[ -f ${QUEUEDIR}/.debug ] && set -x
QE=$1
QF=${QUEUEDIR}/${QE}.job
QFD=${QUEUEDIR}/${QE}.working
QDS=${QUEUEDIR}/${QE}.save

SRCFN=$(< ${QF})
SRCEXT=${SRCFN##*.}
SRCFND=${SRCFN%.*}

do_log "Processing ${SRCFNB}"
mv "${QF}" "${QFD}"
