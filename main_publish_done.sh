#!/bin/sh

# This script runs when a main stream stops publishing to nginx

set -euf

DIR="$(dirname "$0")"
. "$DIR/config.sh"
. "$DIR/utils.sh" # parse_argv, is_running, kill, push_stream

exec > "$LOGS_FOLDER/scripts/main_publish_done.log" 2>&1

parse_argv "$@"

# Stop pushing main stream.
# In case stopping avconv/ffmpeg needs some time, use a loop.
# Otherwise pushing backup may be denied with 'already publishing' error
while is_running main; do
	kill main
	sleep 0.1
done

# If backup is not pushing yet, push it
is_running backup || push_stream backup

exit 0
