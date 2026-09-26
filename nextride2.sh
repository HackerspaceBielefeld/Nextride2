#!/bin/bash
### BEGIN INIT INFO
# Provides:          flutter_pi_nextride
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Flutter Pi Nextride
# Description:       Starts, stops, restarts, and checks the status of the nextride display.
### END INIT INFO

# Pfad zu den kompilierten Flutter-Assets
ASSET_PATH="/opt/nextride/flutter_assets"

# Bildschirmdrehung in Grad
ROTATION_ANGLE="180"

# HASSIO_*-Variablen, siehe README.md (Datei mit chmod 600 anlegen).
ENV_FILE=/etc/nextride2.env
if [ -r "$ENV_FILE" ]; then
    set -a
    . "$ENV_FILE"
    set +a
fi

SESSION_NAME="flutter_pi_nextride"
LOGFILE=/var/log/flutter_pi_nextride.log

# Liefert die PID der screen-Session bzw. nichts, wenn sie nicht laeuft.
session_pid() {
    /usr/bin/screen -ls "$SESSION_NAME" 2>/dev/null \
        | sed -n "s/^[[:space:]]*\([0-9][0-9]*\)\.$SESSION_NAME[[:space:]].*/\1/p" \
        | head -n 1
}

case "$1" in
    start)
        if [ -n "$(session_pid)" ]; then
            echo "Flutter Pi Nextride is already running."
            exit 1
        fi
        echo "Starting Flutter Pi Nextride..."

        # -L/-Logfile: sonst landet die Ausgabe in der Session und nicht im Log,
        # denn 'screen -dm' kehrt sofort zurueck.
        /usr/bin/screen -dmS "$SESSION_NAME" -L -Logfile "$LOGFILE" \
            /usr/local/bin/flutter-pi -r "$ROTATION_ANGLE" "$ASSET_PATH"

        if [ -z "$(session_pid)" ]; then
            echo "Failed to start Flutter Pi Nextride, see $LOGFILE."
            exit 1
        fi
        echo "Flutter Pi Nextride started (pid $(session_pid))."
        ;;
    stop)
        if [ -z "$(session_pid)" ]; then
            echo "Flutter Pi Nextride is not running."
            exit 1
        fi
        echo "Stopping Flutter Pi Nextride..."
        /usr/bin/screen -S "$SESSION_NAME" -X quit
        echo "Flutter Pi Nextride stopped."
        ;;
    restart)
        "$0" stop
        sleep 1
        "$0" start
        ;;
    status)
        PID="$(session_pid)"
        if [ -n "$PID" ]; then
            echo "Flutter Pi Nextride is running (pid $PID)."
        else
            echo "Flutter Pi Nextride is not running."
            exit 3
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
