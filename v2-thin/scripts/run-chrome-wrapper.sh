#!/bin/bash
exec /usr/bin/google-chrome-stable \
    --no-sandbox \
    --no-zygote \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-dev-shm-usage \
    --user-data-dir=/tmp/chrome-data \
    --window-size=1280,800 \
    --window-position=0,0 \
    "$@"
