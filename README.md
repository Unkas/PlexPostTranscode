# PlexPostTranscode
A docker image to transcode video files after recording them

All volumes being mounted have to be also mounted in Plex

## Usage

```
docker create --name plexTranscode \
    -v </path/to/tvshows>:/media/TV \
    -v </path/to/movies>:/media/Movies \
    -v </path/to/plexPost>:/plexpost \
    unkas:plextranscode
'''