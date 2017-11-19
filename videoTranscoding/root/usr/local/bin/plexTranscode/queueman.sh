#!/usr/bin/env bash

do_log() {
    echo "$@"
}

die() {
    msg=("$@")
    for line in "${msg[@]}"; do
        do_log $line
    done
    exit 1
}

alerter() {
    MSG=$1
    LOG=$2
    TITLE=$3
    shift 3
    [ ! -z "$MAILTO" ] && {
        ( echo From:${MAILFROM}
        echo Subject:PLEXPOST JOB ALERT - ${MSG}
        echo ""
        echo "$TITLE"
        echo ""
        [ -f "$LOG" ] && cat "$LOG"
        ) | ssmtp ${MAILTO}
    }
    [ ! -z "$SLACK_HOOK" ] && {
        slackpost init  $SLACK_HOOK "$MSG" -u plexpost -i warning 
        slackpost attach "$(<$LOG)" -t "$TITLE" -c "#bc0000" 
        slackpost send
    }
}

daily_cleanup() {
    do_log "Running Daily Cleanup"
    LASTCLEAN="$(date +%D)"
    find ${QUEUEDIR} -maxdepth 1 -name '*.working' | while read FN; do
        echo "Stale working queue entry found: $(basename ${FN})"
        alerter "Stale working queue entry found: $(basename ${FN})" "${FN}" "Queue Entry"
    done
    find ${QUEUEDIR} -maxdepth 1 -mtime +${QUEUEDAYS:-60} -name '*.save' | while read FN; do
        do_log "Removing ${FN}"
        [ -f "${FN}" ] && rm "${FN}"
    done
    find ${QUEUEDIR} -maxdepth 1 -mtime +${QUEUEDAYS:-60} -name '*.log' | while read FN; do
        do_log "Removing ${FN}"
        [ -f "${FN}" ] && rm "${FN}"
    done
    find ${QUEUEDIR} -maxdepth 1 -type d -mtime +${QUEUEDAYS:-60} -name 'working-*' | while read DN; do
        do_log "Removing stale working directory${DN}"
        [ -d "${DN}" ] && rm -rf "${DN}"
    done
    if [ "${TSCLEAN:-0}" = "1" ]; then
        find ${TVDIR:-/dev/null} -mtime +${TSDAYS:-60} -name '*.mkv-ts' | while read FN; do
            do_log "Cleaning ${FN}"
            [ -f "${FN}" ] && rm "${FN}"
        done
        find ${MVDIR:-/dev/null} -mtime +${TSDAYS:-60} -name '*.mkv-ts' | while read FN; do
            do_log "Cleaning ${FN}"
            [ -f "${FN}" ] && rm "${FN}"
        done
    fi
}

[ -d /${QUEUEDIR} ] || die "Error! Couldn't find queue directory!"

FINISHED=""

trap "FINISHED=YES" SIGINT SIGTERM SIGHUP

do_log "Starting to monitor Queue"

while [ -z "$FINISHED" ]; do
    [ "${LASTCLEAN:-00/00/00}" != "$(date +%D)" ] && daily_cleanup
    find ${QUEUEDIR} -maxdepth 1 -name '*.job' | while read FN; do
        _qt=$(basename ${FN})
        _qe=${_qt%.job}
        _tf=${QUEUEDIR}/${_qe}.log
        _te=${QUEUEDIR}/${_qe}.err
        cat ${FN} > ${_tf}
        ("${QUEUEPROCESS}/plexProcess.sh" $_qe || touch ${_te}) 2>&1 | tee -a ${_tf}
        if [ -f "${_te}" ];then
            alerter "Error Processing Queue Entry: ${_qe}" "${_tf}" "Log File"
            rm "${_te}"
        else
            rm "${_tf}"
        fi
    done
    sleep ${QUEUETIMER:-10}
done

do_log "Queue monitoring terminated."
