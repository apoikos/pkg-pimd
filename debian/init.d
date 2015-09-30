#!/bin/sh
# kFreeBSD do not accept scripts as interpreters, using #!/bin/sh and sourcing.
if [ true != "$INIT_D_SCRIPT_SOURCED" ] ; then
    set "$0" "$@"; INIT_D_SCRIPT_SOURCED=true . /lib/init/init-d-script
fi

### BEGIN INIT INFO
# Provides:          pimd
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: PIM-SM/SSM multicast routing daemon
# Description:       Lightweight, stand-alone PIM-SM/SSM multicast routing daemon
### END INIT INFO

NAME=pimd
DAEMON=/usr/sbin/pimd
PIDFILE="/var/run/${NAME}.pid"

do_reload() {
        log_daemon_msg "Reloading $DESC configuration files" "$NAME"
        start-stop-daemon --oknodo --stop --signal HUP --quiet \
          --pidfile "$PIDFILE" --exec "$DAEMON"
        log_end_msg $?
}
