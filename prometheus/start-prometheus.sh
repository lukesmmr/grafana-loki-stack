#!/bin/sh

set -e

# Ensure data directory exists
mkdir -p /etc/prometheus/data

# Add debugging
echo "Debugging information:" > /etc/prometheus/data/debug.log
echo "Date: $(date)" >> /etc/prometheus/data/debug.log
echo "NODE_EXPORTER_CLIENTS: '$NODE_EXPORTER_CLIENTS'" >> /etc/prometheus/data/debug.log

# Parse the NODE_EXPORTER_CLIENTS environment variable
# Format: ip:port:nodename,ip:port:nodename
if [ -n "$NODE_EXPORTER_CLIENTS" ]; then
  echo "NODE_EXPORTER_CLIENTS is not empty, processing..." >> /etc/prometheus/data/debug.log
  
  # Process the comma-separated list
  # First, replace commas with spaces
  CLIENTS=$(echo "$NODE_EXPORTER_CLIENTS" | tr ',' ' ')
  echo "CLIENTS after processing: '$CLIENTS'" >> /etc/prometheus/data/debug.log
  
  # Initialize the node mappings JSON array
  echo "[" > /etc/prometheus/data/node_mappings.json
  FIRST_MAPPING=true
  
  # Process each client
  for CLIENT in $CLIENTS; do
    echo "Processing CLIENT: '$CLIENT'" >> /etc/prometheus/data/debug.log
    
    # Split the client string by colon
    IP_PORT=$(echo "$CLIENT" | cut -d':' -f1-2)
    NODENAME=$(echo "$CLIENT" | cut -d':' -f3)
    IP=$(echo "$IP_PORT" | cut -d':' -f1)
    
    echo "IP_PORT: '$IP_PORT', NODENAME: '$NODENAME', IP: '$IP'" >> /etc/prometheus/data/debug.log
    
    # Add to node mappings JSON file
    if [ "$FIRST_MAPPING" = "true" ]; then
      echo "  {" >> /etc/prometheus/data/node_mappings.json
      FIRST_MAPPING=false
    else
      echo "  }, {" >> /etc/prometheus/data/node_mappings.json
    fi
    echo "    \"targets\": [\"$IP_PORT\"]," >> /etc/prometheus/data/node_mappings.json
    echo "    \"labels\": {" >> /etc/prometheus/data/node_mappings.json
    echo "      \"nodename\": \"$NODENAME\"," >> /etc/prometheus/data/node_mappings.json
    echo "      \"ip\": \"$IP\"" >> /etc/prometheus/data/node_mappings.json
    echo "    }" >> /etc/prometheus/data/node_mappings.json
  done
  
  # Close the node mappings JSON file
  if [ "$FIRST_MAPPING" = "false" ]; then
    echo "  }" >> /etc/prometheus/data/node_mappings.json
  fi
  echo "]" >> /etc/prometheus/data/node_mappings.json
  echo "Node mappings file created successfully" >> /etc/prometheus/data/debug.log

  # Create a symlink for backward compatibility
  ln -sf /etc/prometheus/data/node_mappings.json /etc/prometheus/node_mappings.json
else
  echo "NODE_EXPORTER_CLIENTS is empty, creating empty array" >> /etc/prometheus/data/debug.log
  # Default empty array if no clients specified
  echo "[]" > /etc/prometheus/data/node_mappings.json
  ln -sf /etc/prometheus/data/node_mappings.json /etc/prometheus/node_mappings.json
fi

# Ensure the file exists and has proper permissions
ls -la /etc/prometheus/data/ >> /etc/prometheus/data/debug.log
cat /etc/prometheus/data/node_mappings.json >> /etc/prometheus/data/debug.log 2>&1

# Copy the prometheus.yml template to the final location
cp /etc/prometheus/prometheus.yml.template /etc/prometheus/prometheus.yml
echo "Prometheus configuration copied" >> /etc/prometheus/data/debug.log

# Start Prometheus with the generated configuration file
echo "Starting Prometheus..." >> /etc/prometheus/data/debug.log
exec /bin/prometheus --config.file=/etc/prometheus/prometheus.yml "$@"
