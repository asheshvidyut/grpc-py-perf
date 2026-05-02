# Configuration
PYTHON="/usr/local/google/home/asheshvidyut/perfy-grpc/venv-master/bin/python"
PYSPY="./venv/bin/py-spy"
SERVER_SCRIPT="server.py"
CLIENT_SCRIPT="client.py"

# Output files
PYSPY_SERVER_OUTPUT="server-master.pprof"
PYSPY_CLIENT_OUTPUT="client-master.pprof"
CPROFILE_SERVER_OUTPUT="server-master.cprof"
CPROFILE_CLIENT_OUTPUT="client-master.cprof"

# Function to cleanup background processes
cleanup() {
    echo "Cleaning up..."
    if [ ! -z "$SERVER_PID" ]; then
        # Use -INT instead of -SIGINT for better portability
        kill -INT $SERVER_PID 2>/dev/null
        wait $SERVER_PID 2>/dev/null
    fi
}

trap cleanup EXIT

# 0. Print environment info
echo ">>> Environment Info:"
$PYTHON --version
$PYTHON -c "import grpc; print(f'gRPC version: {grpc.__version__}')"
echo ""

# 1. Start the server with cProfile
echo ">>> Starting server with cProfile..."
$PYTHON -m cProfile -o "$CPROFILE_SERVER_OUTPUT" "$SERVER_SCRIPT" &
SERVER_PID=$!

# 2. Wait for the server to be ready
echo ">>> Waiting for server to start on port 50051..."
while ! nc -z localhost 50051; do   
  sleep 0.2
done
echo ">>> Server is up (PID: $SERVER_PID)"

# 3. Start py-spy recording for server
echo ">>> Starting py-spy recording for server (pprof format)..."
# pprof format was not available, so we use pprof
$PYSPY record --format raw -o "$PYSPY_SERVER_OUTPUT" --pid "$SERVER_PID" --nonblocking &
PYSPY_PID=$!

# 4. Run the client with cProfile and py-spy
echo ">>> Running client benchmarking with cProfile and py-spy..."
$PYSPY record --format raw -o "$PYSPY_CLIENT_OUTPUT" -- $PYTHON -m cProfile -o "$CPROFILE_CLIENT_OUTPUT" "$CLIENT_SCRIPT"

# 5. Stop everything
echo ">>> Client finished. Stopping server..."
kill -INT "$SERVER_PID"

# Wait for server to finish saving profile
wait "$SERVER_PID"

echo ">>> Benchmarking complete!"
echo "-----------------------------------"
echo "Results:"
echo "- Server pprof: $PYSPY_SERVER_OUTPUT (View at speedscope.app)"
echo "- Client pprof: $PYSPY_CLIENT_OUTPUT (View at speedscope.app)"
echo "- Server cProfile:   $CPROFILE_SERVER_OUTPUT"
echo "- Client cProfile:   $CPROFILE_CLIENT_OUTPUT"
echo ""
echo "To view cProfile data:"
echo "snakeviz $CPROFILE_SERVER_OUTPUT"

echo "go tool pprof -http=:8080 $PYSPY_OUTPUT"

