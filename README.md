# PlexPostTranscode
A docker image to transcode video files after recording them

## Sources
This project combines several different projects
### [LinuxServer.io](https://github.com/linuxserver/docker-baseimage-xenial)
Uses lsiobase/xenial for its work done to bring in s6 and PID and GID environment variables
### [ntodd/ruby-xenial:2.4.1](https://github.com/ntodd/video_transcoding_docker)
Copied the Doockerfile and changed which base file it was starting off of to the LinuxServer.io.  This gives me ruby to install software later on.
### [ntodd/video-transcoding:0.17.3](https://github.com/ntodd/video_transcoding_docker)
Copied the Dockerfile to install video-transcoding and its required software
### [donmelton/video_transcoding](https://github.com/donmelton/video_transcoding)
The real reason for this project.  Instead of using the Handbrake CLI, this program figures out the settings for Handbrake and then runs it.  This way if the recordings ever change, transcoding will be able to adapt
### [mjbrowns/plexpost](https://github.com/mjbrowns/plexpost)
This docker image used comskip and only HandBrake CLI to queue up recorded Plex media files and transcode them.  I simplfied the process of getting the docker image instead of having to build it, tore out ComSkip for now, and replaced the HandBrake CLI with transcode-video.  

## Working with Plex
This image needs access to your media files to figure out where to put the transcoded files.  The plexpost volume should also be mounted to plex.  Go to the DVR settings in Plex and enter /postproc/bin/plexPost.sh as the post processing script.

## Usage

```
docker create --name plexTranscode \
    -e PUID=<UID> -e PGID=<GID> \
    -v </path/to/tvshows>:/media/TV \
    -v </path/to/movies>:/media/Movies \
    -v </path/to/postproc>:/postproc \
    unkas/plexposttranscode
```

## Parameters

* `-e QUEUETIMER` - How long in seconds between queue scans (Default 0)
* `-e QUEUEDAYS` - How Long to keep completed queue files
* `-e REMOVETS` - Remove the .ts source file upon successful transcode: 0=no 1=yes
* `-e TSCLEAN` - Tells the manager to scan the Movie and TV librarues for .ts-sav files and remove them once they are older than TSDAYS
* `-e TSDAYS` - How many days until .ts-sav files are delete from when they are created

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. LinuxServer avoids this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" <sup>TM</sup>.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```