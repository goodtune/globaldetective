#!/bin/bash

set -ex -o pipefail

uv run -s manage.py migrate
uv run -m gunicorn project.wsgi "$@"
