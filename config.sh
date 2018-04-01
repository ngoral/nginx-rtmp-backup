# configuration file for nginx-rtmp-backup

# [true|false] defines whether or not stream changes back to main if it recovers
# with true it will change back, with false -- stay on backup stream
MAIN_STREAM_PRIORITY="true"

# [avconv|ffmpeg] defines which program will push your stream
# use avconv if not sure
RUNNER="avconv"

# nginx rtmp application name for main stream
MAIN_STREAM_APPNAME="main"

# nginx rtmp application name for backup stream
BACKUP_STREAM_APPNAME="backup"

# nginx rtmp application name for final stream
OUT_STREAM_APPNAME="out"

# username for nginx worker processes
NGINX_USER="nobody"
# group for NGINX_USER
NGINX_GROUP="nogroup"

# Following parameters are technical. Please, DO NOT CHANGE them.
# If changed anyway, run init.sh again.

# app name
CURRENT_APPLICATION_NAME="nginx-rtmp-backup"

# folder where pidfiles are stored
PIDS_FOLDER="/run/$CURRENT_APPLICATION_NAME"

# folder where logfiles are stored
LOGS_FOLDER="/var/log/$CURRENT_APPLICATION_NAME"
