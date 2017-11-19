#!/bin/bash

do_log(){
    echo "${QE} -$@"
}

die() {
    do_log "${@}"
    trap "" SIGINT SIGTERM SIGHUP
    #cleanup
    exit 1
}

cleanup() {
    [ -z "${WORKDIR}" ] && return
    [ -d ${WORKDIR} ] && rm -rf ${WORKDIR}
}

transcode_video () {
    typeset INFILE="$1"
    typeset OUTFILE="$2"
    shift
    shift
    nice transcode-video --target small --crop detect --fallback-crop none "$INFILE" -o "$OUTFILE"
}

[ -f ${QUEUEDIR}/.debug ] && set -x
QE=$1
QF=${QUEUEDIR}/${QE}.job
QFD=${QUEUEDIR}/${QE}.working
QFS=${QUEUEDIR}/${QE}.save

SRCFN=$(< ${QF})
SRCEXT=${SRCFN##*.}
#Source file name without Extention
SRCFNB=${SRCFN%.*}

do_log "Processing ${SRCFNB}"
mv "${QF}" "${QFD}"

#See if we can find the file in the TVDIR or MVDIR path
SRCDIR=$(find "${TVDIR}" ${MVDIR} -name "${SRCFN}" -printf "%h\n")
_check=$(find "${TVDIR}" ${MVDIR} -name "${SRCFN}" -printf "%h\n"|wc -l)
do_log ${_check}
[ ${_check} -gt 1 ] && die "ERROR: multiple input files found!"
[ ${_check} -eq 0 ] && die "ERROR: couldn't find input file ($SRCFN) in library!"

WORKDIR=${QUEUEDIR}/working-${QE}
do_log ${WORKDIR}
mkdir -p ${WORKDIR}
trap "die 'Caught signal'" SIGINT SIGTERM SIGHUP
cd ${WORKDIR}
#
#Main processing code below
#

IF="${SRCDIR}/${SRCFN}"
OF="${SRCDIR}/${SRCFNB}.mkv"
OFTS="${SRCDIR}/${SRCFNB}.mkv-ts"
WF1="${WORKDIR}/source.ts"
WF2="${WORKDIR}/source.mkv"
WF3="${WORKDIR}/transcode-source.mkv"
WF4="${WORKDIR}/transcode.mkv"

if [ "${SRCEXT}" = "mkv" ] ;then
    IFN2="${SRCFNB}.mkv-orig"
    IF2="${SRCDIR}/${IFN2}"
    do_log "Moving source to $IF2"
    mv "${IF}" "${IFN}"
    IF="${IF2}"
    echo "$IFN2" > "${QFD}"
fi

if [ -z "${IF}" ];then
    die "ERROR: Calculated input file is blank"
fi
if [ -f "${OF}" ];then
    die "ERROR: Output file already exists"
fi
if [ ! -f "${IF}" ];then
    die "ERROR: Input file does not exist: ${IF}"
fi
do_log "Linking: ${IF} ${WF1}"
# link .ts file to working-dir/source.ts
ln -sf "${IF}" "${WF1}" || die "ERROR: failed to link ${WF1}"

# Handbrake working-dir/transcode-source.mkv to working-dir/transcoded.mkv
do_log "Starting transcode (HandBrake)"
do_log "${WF1}" "${WF4}" 
transcode_video "${WF1}" "${WF4}" > ${WORKDIR}/transcode.log 2>&1 || die "ERROR: HandBrakeCLI exited with error $?"
OLDSZ=$(stat -Lc %s "${WF1}")
NEWSZ=$(stat -Lc %s "${WF4}")
if [ $((${OLDSZ}/10 > ${NEWSZ})) -ne 0 ]; then
    die "WARNING: Transcoded file is too small!"
fi
# move transcoded.mkv to target-dir/{FN}.mkv
mv "${WF4}" "${OF}" || die "ERROR: failed to move transcoded output to ${OF}"
mv "${IF}" "${OFTS}"
if [ "${REMOVETS}" = "1" ];then
    rm "${OFTS}"
fi

#
# all done
#
do_log "Success"
trap "" SIGINT SIGTERM SIGHUP
mv "${QFD}" "${QFS}"
cleanup 








