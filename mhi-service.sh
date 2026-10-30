#!/bin/sh

BIN=/qmf/qml/apps/mhi/toon-mhi
PID=/var/run/mhi.pid
LOG=/var/volatile/log/mhi.log
CONFIG=/mnt/data/tsc/mhi.json
STATUS=/var/volatile/tmp/mhi-status.json

is_running() {
    test -f "$PID" && kill -0 "$(cat "$PID")" 2>/dev/null
}

start_service() {
    test -x "$BIN" || exit 1
    is_running && exit 0
    mkdir -p /var/volatile/log
    "$BIN" >>"$LOG" 2>&1 &
    echo $! >"$PID"
}

stop_service() {
    if is_running; then
        kill "$(cat "$PID")" 2>/dev/null
        i=0
        while is_running && test "$i" -lt 20; do
            usleep 100000 2>/dev/null || sleep 1
            i=$((i + 1))
        done
    fi
    rm -f "$PID"
}

case "$1" in
    start) start_service ;;
    stop) stop_service ;;
    restart) stop_service; start_service ;;
    status) is_running && echo running || { echo stopped; exit 1; } ;;
    *) echo "Gebruik: $0 {start|stop|restart|status|test}"; exit 2 ;;
esac
