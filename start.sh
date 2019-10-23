#!/bin/bash

export MIX_ENV=prod
export PORT=4793

echo "Starting app..."

# Start to run in background from shell.
#_build/prod/rel/dots_and_boxes/bin/memory dots_and_boxes

# Foreground for testing and for systemd
_build/prod/rel/dots_and_boxes/bin/dots_and_boxes start