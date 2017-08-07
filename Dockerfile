FROM ntodd/ruby-xenial:2.4.0
LABEL maintainer="Paul Snell"

ENV GEM_VERSION 0.17.3

RUN set -ex \
    && apt-get update -qq && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository ppa:stebbins/handbrake-releases \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        mkvtoolnix \
        mp4v2-utils \
        mpv \
        handbrake-cli \
    && apt-get remove -y software-properties-common && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && gem install video_transcoding -v "$GEM_VERSION"

ENV TZ=America/New_York \
    TRANSCODE_UID=1001 \
    TRANSCODE_GID=1003 \
    TRANSCODE_USER=transcode \
    TRANSCODE_GROUP=transcode \
    TVDIR=/media/TV \
    MVDIR=/media/Movies \
    POSTDATA=/postproc \
    QUEUEDIR=/postproc/queue \
    QUEUETIMER=600 \
    QUEUEDAYS=60 \
    REMOVETS=0 \
    TSCLEAN=1 \
    TSDAYS=60

VOLUME ["$POSTDATA", "$QUEUEDIR", "$TVDIR", "$MVDIR"]

COPY src/plexProcess /postproc/bin
COPY src/queueProcess /usr/local/bin

#ENTRYPOINT ["/postproc/bin/queueman-run.sh"]
