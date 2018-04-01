#!/bin/sh

# This script runs when a main stream is published to nginx

set -euf

DIR="$(dirname "$0")"
. "$DIR/config.sh"
. "$DIR/utils.sh" # parse_argv, assert_one_of, kill, is_running, push_stream

exec > "$LOGS_FOLDER/scripts/main_publish.log" 2>&1

parse_argv "$@"
assert_one_of MAIN_STREAM_PRIORITY true false

# Kill backup pushing process if priority is for main stream
[ "$MAIN_STREAM_PRIORITY" = true ] && kill backup || : # || : prevents falling because of set -e
# If none of streams is pushing, push main
is_running main || is_running backup || push_stream main

exit 0
