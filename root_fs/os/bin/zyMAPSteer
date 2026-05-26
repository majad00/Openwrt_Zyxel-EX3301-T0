#!/bin/sh
# Fake version - looks busy but does nothing
PIDFILE="/var/run/$(basename $0).pid"

# Create PID file
echo $$ > "$PIDFILE"

# Make it look like it's initializing
sleep 2

# Main "work" loop
while true; do
    # Update status
    echo "$(date): $(basename $0) is running normally" > /var/log/fake_script.log 2>/dev/null
    
    # Respond to signals
    if [ -f /tmp/stop_$(basename $0) ]; then
        rm -f "$PIDFILE"
        exit 0
    fi
    
    # Sleep a long time
    sleep 86400  # 24 hours
done
