# NGINX-RTMP-BACKUP
This is a set of shell scripts that allows you to implement elementary backups for your RTMP streams.
## Prerequisites
You have to have [avconv](https://libav.org/avconv.html) (or [ffmpeg](https://www.ffmpeg.org/)) and [nginx](https://nginx.ru/en/) with [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module) installed on your machine.

## Installation
1. Download files from this repo (or clone it locally);
2. Place them into a directory readable by nginx (e.g. `/usr/local/share/nginx-rtmp-backup/`);
3. Make necessary modifications to `config.sh` (see [below](#configure-scripts));
4. Set execution permissions for `init.sh` (`chmod a+x init.sh`);
5. Run `init.sh` (`./init.sh`);
6. Configure your nginx-rtmp-module (see [below](#configure-nginx-rtmp)).

### Configure scripts
It is necessary to set a few parameters for the scripts to work properly:
* `MAIN_STREAM_APPNAME`
Should match the name of a nginx-rtmp application accepting the main stream.
Default is `main`.
* `BACKUP_STREAM_APPNAME`
Should match the name of a nginx-rtmp application accepting the backup stream.
Default is `backup`.
* `OUT_STREAM_APPNAME`
Should match the name of a nginx-rtmp application where the stream should finaly appear.
Default is `out`.
* `MAIN_STREAM_PRIORITY`
`true` or `false`. If set to `true`, the main stream will be pushed to out stream each time it recovers. If set to `false`, once the out stream switches to backup, it will stay there.
Default is `true`.
* `RUNNER`
`avconv` or `ffmpeg`. Defines which program will push streams.
Default is `avconv`.
* `NGINX_USER`
A username nginx workers runs under. Required for setting right permissions for logs and pids folders.
Default is `nobody`.
* `NGINX_GROUP`
A group `NGINX_USER` belongs to.
Default is `nogroup`.

### Configure nginx-rtmp
An example configuration matching the default config is presented in `nginx_example.conf`.
Basically, you need to create three applications, one accepting the main stream, another accepting the backup stream, and the third, where your final stream will appear.

```rtmp {
    server {
        listen 1935;

        # An application where the final stream will appear.
        # Its name should match $OUT_STREAM_APPNAME in config.sh.
        application out {
            # Enable live streaming.
            live on;
        }

        # An application for main incoming streams.
        # Its name should match $MAIN_STREAM_APPNAME in config.sh.
        application main {
            # Enable live streaming.
            live on;

            # This will prevent avconv/ffmpeg from hanging when stream ends.
            # We will kill it from scripts anyway, but just in case.
            play_restart on;

            # You may want this in case not to allow anyone to watch streams from this point.
            deny play all;
            # However, we need `out` app to have access.
            allow play 127.0.0.1;

            # That's where the magic starts.
            # Do not forget to change paths.
            # Output for scripts is already redirected, see README#Usage#Logs.

            # When any stream starts publishing to this app,
            # we call main_publish.sh and provide a streamname as a parameter.
            exec_publish /usr/local/share/nginx-rtmp-backup/main_publish.sh $name;
            # When stream stops publishing,
            # call main_publish_done.sh and pass a streamname to it.
            exec_publish_done /usr/local/share/nginx-rtmp-backup/main_publish_done.sh $name;
        }

        # An application for backup incoming streams.
        # Its name should match $BACKUP_STREAM_APPNAME in config.sh.
        # Everything is the same as for `main` app.
        application backup {
            live on;
            play_restart on;
            deny play all;
            allow play 127.0.0.1;

            # When stream stops publishing,
            # call backup_publish_done.sh and pass a streamname to it.
            exec_publish_done /usr/local/share/nginx-rtmp-backup/backup_publish_done.sh $name;
        }
    }
}
```


## Usage
After you have installed and configured scripts, simply send two streams to the apps (`$MAIN_STREAM_APPNAME` and `$BACKUP_STREAM_APPNAME`) with identical streamnames (keys) and watch them in final app (`$OUT_STREAM_APPNAME`).
For example, if you have specified the following names for nginx-rtmp apps:
`MAIN_STREAM_APPNAME="main"`
`BACKUP_STREAM_APPNAME="backup"`
`OUT_STREAM_APPNAME="out"`,
and then sent your streams to `rtmp://your.domain/main/test` and `rtmp://your.domain/backup/test`, you can watch the output stream at `rtmp://your.domain/out/test`.
When switching between streams, you may see a slight delay, as avconv/ffmpeg needs time to run.
### Logs
All logs are stored at `/var/log/nginx-rtmp/backup`.
Logs for avconv/ffmpeg are stored under the names `main_$streamname.log` and `backup_$streamname.log`, where `$streamname` is the RTMP key you send your stream to.
Logs for scripts are stored in the subdirectory `scripts` named after the scripts themselves.

