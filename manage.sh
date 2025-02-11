#!/bin/bash
#
# manage.sh - Control script for the Logging Stack
#
# Usage:
#   ./manage.sh start     # Start the logging stack
#   ./manage.sh stop      # Stop the logging stack
#   ./manage.sh restart   # Restart the logging stack
#   ./manage.sh status    # Show status of the stack containers
#
# This script assumes that your docker-compose.loki.yml file is in the same directory.
# Ensure Docker and Docker Compose are installed and configured correctly.

set -e

# --- Function: usage ---
function usage() {
  echo "Usage: $0 {start|stop|restart|status}"
  exit 1
}

# --- Validate Arguments ---
if [ $# -ne 1 ]; then
  usage
fi

COMMAND=$1

# --- Check Dependencies ---
if ! command -v docker compose &> /dev/null; then
    echo "Error: docker compose command not found. Please install Docker Compose."
    exit 1
fi

# --- Check for docker-compose.yml file ---
DOCKER_COMPOSE_FILE="docker-compose.loki.yml"
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
  echo "Error: $DOCKER_COMPOSE_FILE not found in the current directory."
  exit 1
fi

# --- Function: start_stack ---
function start_stack() {
  echo "Starting the logging stack..."
  docker compose up -d
  if [ $? -eq 0 ]; then
    echo "Logging stack started successfully."
  else
    echo "Failed to start the logging stack."
    exit 1
  fi
}

# --- Function: stop_stack ---
function stop_stack() {
  echo "Stopping the logging stack..."
  docker compose down
  if [ $? -eq 0 ]; then
    echo "Logging stack stopped successfully."
  else
    echo "Failed to stop the logging stack."
    exit 1
  fi
}

# --- Function: restart_stack ---
function restart_stack() {
  echo "Restarting the logging stack..."
  stop_stack
  # Allow some time for containers to shut down gracefully
  sleep 2
  start_stack
}

# --- Function: status_stack ---
function status_stack() {
  echo "Current status of the logging stack containers:"
  docker ps
}

# --- Main Command Logic ---
case "$COMMAND" in
  start)
    start_stack
    ;;
  stop)
    stop_stack
    ;;
  restart)
    restart_stack
    ;;
  status)
    status_stack
    ;;
  *)
    usage
    ;;
esac

exit 0