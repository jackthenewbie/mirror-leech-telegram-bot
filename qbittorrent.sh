#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.py"


if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config.py not found in $SCRIPT_DIR"
    echo "Defaulting to starting qbittorrent-nox..."
    qbittorrent-nox -d --profile="$SCRIPT_DIR"
    echo "qbittorrent-nox started."
    exit 0
fi

selfhost_value=$(python3 -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
try:
    import config
    value = getattr(config, 'QBITTORRENT_SELFHOST', None)
    if value is None:
        print('NOT_FOUND')
    elif isinstance(value, bool):
        print(str(value).lower())
    else:
        print(str(value).lower())
except Exception as e:
    print(f'ERROR: {str(e)}')
" 2>/dev/null)


if [ "$selfhost_value" = "true" ]; then
    echo "QBITTORRENT_SELFHOST is True. Not starting qbittorrent-nox."
else
    if [ "$selfhost_value" = "false" ]; then
        echo "QBITTORRENT_SELFHOST is False. Starting qbittorrent-nox..."
    elif [ "$selfhost_value" = "NOT_FOUND" ]; then
        echo "QBITTORRENT_SELFHOST variable not found. Defaulting to starting qbittorrent-nox..."
    elif [[ "$selfhost_value" == ERROR:* ]]; then
        echo "Error reading config: ${selfhost_value#ERROR: }. Defaulting to starting qbittorrent-nox..."
    else
        echo "QBITTORRENT_SELFHOST has unexpected value: '$selfhost_value'. Defaulting to starting qbittorrent-nox..."
    fi
    qbittorrent-nox -d --profile="$SCRIPT_DIR"
    echo "qbittorrent-nox started."
fi

exit 0