#!/bin/sh

set -e

# Parse the NODE_EXPORTER_CLIENTS environment variable
# Convert comma-separated list to JSON array format for Prometheus
if [ -n "$NODE_EXPORTER_CLIENTS" ]; then
  # Process the comma-separated list into a JSON array format
  # First, replace commas with spaces
  CLIENTS=$(echo "$NODE_EXPORTER_CLIENTS" | tr ',' ' ')
  
  # Initialize the JSON array
  JSON_ARRAY="["
  
  # Process each client
  for CLIENT in $CLIENTS; do
    # Add quotes around each client and a comma after (except for the last one)
    if [ "$JSON_ARRAY" = "[" ]; then
      JSON_ARRAY="$JSON_ARRAY\"$CLIENT\""
    else
      JSON_ARRAY="$JSON_ARRAY, \"$CLIENT\""
    fi
  done
  
  # Close the JSON array
  JSON_ARRAY="$JSON_ARRAY]"
else
  # Default empty array if no clients specified
  JSON_ARRAY="[]"
fi

# Create the final prometheus.yml by replacing the placeholder
# Using sed for the substitution
sed "s|\${NODE_EXPORTER_CLIENTS}|$JSON_ARRAY|g" /etc/prometheus/prometheus.yml.template > /etc/prometheus/prometheus.yml

# Start Prometheus with the generated configuration file
exec /bin/prometheus --config.file=/etc/prometheus/prometheus.yml "$@"
