# PlexPostTranscode
A docker image to transcode video files after recording them

## References
This project combines several different projects
### LinuxServer.io
Uses lsiosio/xenial for its work done to bring in s6 and PID and GID environment variables
### ntodd/ruby-xenial:2.4.1
Copied the Doockerfile and changed which base file it was starting off of to the LinuxServer.io.  This gives me ruby to install software later on.
### ntodd/video-transcoding:0.17.3
Copied the Dockerfile to install video-transcoding and its required software
### donmelton/video_transcoding
The real reason for this project.  Instead of using the Handbrake CLI, this program figures out the settings for Handbrake and then runs it.  This way if the recordings ever change, transcoding will be able to adapt
### mjbrowns/plexpost
This docker image used comskip and only HandBrake CLI to queue up recorded Plex media files and transcode them.  I simplfied the process of getting the docker image instead of having to build it, tore out ComSkip for now, and replaced the HandBrake CLI with transcode-video.  

## Working with Plex
This image needs access to your media files to figure out where to put the transcoded files.  The plexpost volume should also be mounted to plex.  Go to the DVR settings in Plex and enter /plexpost/bin/plexPost.sh as the post processing script.

## Usage

```
docker create --name plexTranscode \
    -e UID=<UID> -e GID=<GID> \
    -v </path/to/tvshows>:/media/TV \
    -v </path/to/movies>:/media/Movies \
    -v </path/to/plexPost>:/plexpost \
    unkas:plextranscode
'''