# gRPC Performance Testing

This project provides a simple gRPC service to measure latency for data exchange with configurable payload sizes.

## Prerequisites

- Python 3.x
- `grpcio` and `grpcio-tools` packages

## Setup

1. (Optional) Create and activate a virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

2. Install dependencies:
   ```bash
   pip install grpcio grpcio-tools
   ```

3. (If needed) Regenerate gRPC code:
   ```bash
   python3 -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. perf.proto
   ```

## Usage

Both the server and client support the following arguments:
- `--payload_size`: Specify the size of the data exchanged in megabytes (MB).
- `--port`: Specify the port to use (default: 50051).

### Server

The server generates a response payload of the specified size for every request.

```bash
# Run with defaults (4MB payload, port 50051)
python3 server.py

# Run with custom payload size and port
python3 server.py --payload_size 10 --port 50052
```

### Client

The client sends a request payload of the specified size and measures the round-trip latency.

```bash
# Run with defaults (4MB payload, port 50051)
python3 client.py

# Run with custom payload size and port
python3 client.py --payload_size 10 --port 50052
```

## Constraints

- **Default Port:** 50051
- **Default Payload Size:** 4 MB
- **Maximum Payload Size:** 50 MB
- **Minimum Payload Size:** 1 MB
- **gRPC Max Message Length:** Configured to 60 MB to accommodate payload and overhead.
