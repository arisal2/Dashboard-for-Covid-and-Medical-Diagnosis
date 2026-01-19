#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails/tmp/pids/server.pid

# If running the rails server, wait for database
if [ "${1}" == "rails" ] && [ "${2}" == "server" ]; then
    echo "Waiting for database..."
    while ! pg_isready -h db -p 5432 -q; do
        sleep 1
    done
    echo "Database is ready!"
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
