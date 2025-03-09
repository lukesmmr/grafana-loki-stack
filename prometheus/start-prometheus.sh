#!/bin/sh

set -e

# Parse the NODE_EXPORTER_CLIENTS environment variable
# Format: ip:port:nodename,ip:port:nodename
if [ -n "$NODE_EXPORTER_CLIENTS" ]; then
  # Process the comma-separated list
  # First, replace commas with spaces
  CLIENTS=$(echo "$NODE_EXPORTER_CLIENTS" | tr ',' ' ')
  
  # Initialize the node mappings JSON array
  echo "[" > /etc/prometheus/node_mappings.json
  FIRST_MAPPING=true
  
  # Process each client
  for CLIENT in $CLIENTS; do
    # Split the client string by colon
    IP_PORT=$(echo "$CLIENT" | cut -d':' -f1-2)
    NODENAME=$(echo "$CLIENT" | cut -d':' -f3)
    IP=$(echo "$IP_PORT" | cut -d':' -f1)
    
    # Add to node mappings JSON file
    if [ "$FIRST_MAPPING" = "true" ]; then
      echo "  {" >> /etc/prometheus/node_mappings.json
      FIRST_MAPPING=false
    else
      echo "  }, {" >> /etc/prometheus/node_mappings.json
    fi
    echo "    \"targets\": [\"$IP_PORT\"]," >> /etc/prometheus/node_mappings.json
    echo "    \"labels\": {" >> /etc/prometheus/node_mappings.json
    echo "      \"nodename\": \"$NODENAME\"," >> /etc/prometheus/node_mappings.json
    echo "      \"ip\": \"$IP\"" >> /etc/prometheus/node_mappings.json
    echo "    }" >> /etc/prometheus/node_mappings.json
  done
  
  # Close the node mappings JSON file
  if [ "$FIRST_MAPPING" = "false" ]; then
    echo "  }" >> /etc/prometheus/node_mappings.json
  fi
  echo "]" >> /etc/prometheus/node_mappings.json
else
  # Default empty array if no clients specified
  echo "[]" > /etc/prometheus/node_mappings.json
fi

# Copy the prometheus.yml template to the final location
cp /etc/prometheus/prometheus.yml.template /etc/prometheus/prometheus.yml

# Start Prometheus with the generated configuration file
exec /bin/prometheus --config.file=/etc/prometheus/prometheus.yml "$@"
