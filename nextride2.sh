#!/bin/bash
### BEGIN INIT INFO
# Provides:          flutter_pi_nextride
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Flutter Pi Nextride
# Description:       Starts, stops, restarts, and checks the status of the /home/pi/nextride script rotated by 180 degrees.
### END INIT INFO

# Change the following to the path of your nextride script
SCRIPT_PATH="/home/pi/nextride"

# Change the following to the rotation angle you want (in degrees)
ROTATION_ANGLE="180"

# Do not modify the following
PIDFILE=/var/run/flutter_pi_nextride.pid
LOGFILE=/var/log/flutter_pi_nextride.log

case "$1" in
    start)
        if [ -f $PIDFILE ]; then
            echo "Flutter Pi Nextride is already running."
            exit 1
        fi
        echo "Starting Flutter Pi Nextride..."
        
        /usr/bin/screen -dmS flutter_pi_nextride /usr/local/bin/flutter-pi -r 180 /opt/nextride/flutter_assets >> $LOGFILE 2>&1
        echo $! > $PIDFILE
        echo "Flutter Pi Nextride started."
        ;;
    stop)
        if [ ! -f $PIDFILE ]; then
            echo "Flutter Pi Nextride is not running."
            exit 1
        fi
        echo "Stopping Flutter Pi Nextride..."
        kill $(cat $PIDFILE)
        rm $PIDFILE
        echo "Flutter Pi Nextride stopped."
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
    status)
        if [ -f $PIDFILE ]; then
            echo "Flutter Pi Nextride is running (pid $(cat $PIDFILE))."
        else
            echo "Flutter Pi Nextride is not running."
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
