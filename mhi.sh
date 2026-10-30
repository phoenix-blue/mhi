#!/bin/sh

APP_DIR=/qmf/qml/apps/mhi
CONFIG=/mnt/data/tsc/mhi.json
SERVICE_LINK=/qmf/bin/mhi-service.sh
BOOT_LINK=/etc/rc5.d/S98mhi

install_app() {
    mkdir -p /mnt/data/tsc /var/volatile/log

    if [ -x "$SERVICE_LINK" ]; then
        "$SERVICE_LINK" stop >/dev/null 2>&1
    fi

    # Updates must never replace the configured units, ESPHome keys or tile IDs.
    if [ ! -s "$CONFIG" ]; then
        cp "$APP_DIR/mhi.json" "$CONFIG"
    fi
    chmod 600 "$CONFIG"

    chmod 755 "$APP_DIR/toon-mhi"
    chmod 755 "$APP_DIR/mhi-service.sh"
    chmod 755 "$APP_DIR/S98mhi"
    chmod 755 "$APP_DIR/mhi.sh"

    ln -sf "$APP_DIR/mhi-service.sh" "$SERVICE_LINK"
    ln -sf "$APP_DIR/S98mhi" "$BOOT_LINK"

    "$SERVICE_LINK" start
}

uninstall_app() {
    if [ -x "$SERVICE_LINK" ]; then
        "$SERVICE_LINK" stop >/dev/null 2>&1
    fi
    rm -f "$SERVICE_LINK" "$BOOT_LINK"
    # /mnt/data/tsc/mhi.json is deliberately retained for a reinstall.
}

case "$1" in
    uninstall) uninstall_app ;;
    *) install_app ;;
esac
