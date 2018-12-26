#!/bin/bash

# Use localhost for local testing.
export PYTHONPATH=$PYTHONPATH:/app/
exec /usr/local/bin/bokeh serve --port 5006 --allow-websocket-origin=${BOKEH_HOST} --prefix /bokeh /app/bokeh/*.py
