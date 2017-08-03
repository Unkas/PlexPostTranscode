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