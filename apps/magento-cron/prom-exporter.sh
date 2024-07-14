#!/bin/bash

# Configuration
SERVICE_NAME="magento-cron"
COMPANY="xxx"
PROJECT="xxx"
ENV="xxx"
PUSHGATEWAY_URL="http://pushgateway.xxx.xx.xx.ro:80"
JOB_NAME="magento-cron"
INSTANCE_NAME="jti"

# Function to check if magento cron:run is running
is_magento_cron_running() {
  if pgrep -f "magento cron:run" > /dev/null; then
    return 0
  else
    return 1
  fi
}

# Check if the magento cron:run script is running
if is_magento_cron_running; then
  SERVICE_STATUS=1
  echo "Magento cron:run is running"
else
  SERVICE_STATUS=0
  echo "Magento cron:run is not running"
fi

# Get the current timestamp
CURRENT_TIMESTAMP=$(date +%s)

# Push metrics to Prometheus Pushgateway
cat <<EOF | curl --data-binary @- ${PUSHGATEWAY_URL}/metrics/job/${JOB_NAME}/instance/${INSTANCE_NAME}
# TYPE service_status gauge
service_status{service="${SERVICE_NAME}", company="${COMPANY}", project="${PROJECT}", env="${ENV}",instance="${INSTANCE_NAME}"} $SERVICE_STATUS
# TYPE up gauge
up{service="${SERVICE_NAME}", company="${COMPANY}", project="${PROJECT}", env="${ENV}", instance="${INSTANCE_NAME}"} $SERVICE_STATUS
# TYPE service_status_timestamp gauge
enode_metrics_timestamp{service="${SERVICE_NAME}", company="${COMPANY}", project="${PROJECT}", env="${ENV}", instance="${INSTANCE_NAME}} $CURRENT_TIMESTAMP
EOF

echo "Metrics pushed to Prometheus Pushgateway"

# Optional: Schedule this script using cron to run periodically
# For example, to run this script every 5 minutes, add the following line to your crontab:
# */5 * * * * /path/to/this/script.sh
