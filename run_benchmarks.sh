#!/bin/bash

# Configuration
PAYLOAD_SIZES=(4 16 32 64 128)
# Environment:Port mapping
ENVS=("venv-opt/bin/python:50051" "venv-master/bin/python:50052")

# Function to clean up background processes
cleanup() {
    if [ ! -z "$SERVER_PID" ]; then
        kill "$SERVER_PID" 2>/dev/null
    fi
}
trap cleanup EXIT

for ENV_INFO in "${ENVS[@]}"; do
    PYTHON_EXE="${ENV_INFO%%:*}"
    PORT="${ENV_INFO##*:}"
    
    echo "========================================================================"
    echo "Environment: $PYTHON_EXE"
    echo "Port:        $PORT"
    echo "========================================================================"
    
    for SIZE in "${PAYLOAD_SIZES[@]}"; do
        echo ">>> Payload Size: ${SIZE}MB"
        
        # Start server in background
        # Redirecting server output to a log file to keep the terminal clean
        LOG_FILE="server_${PORT}_${SIZE}mb.log"
        $PYTHON_EXE server.py --payload_size "$SIZE" --port "$PORT" > "$LOG_FILE" 2>&1 &
        SERVER_PID=$!
        
        # Give the server a moment to start
        sleep 2
        
        # Run client
        if ! $PYTHON_EXE client.py --payload_size "$SIZE" --port "$PORT"; then
            echo "Error running client for ${SIZE}MB payload."
        fi
        
        # Shutdown server
        kill "$SERVER_PID"
        wait "$SERVER_PID" 2>/dev/null
        SERVER_PID=""
        
        echo "------------------------------------------------------------------------"
    done
    echo ""
done

echo "All benchmarks completed."
