import grpc
import perf_pb2
import perf_pb2_grpc
from concurrent import futures
import time
import argparse

class PerfService(perf_pb2_grpc.PerfServiceServicer):
    def __init__(self, payload_size):
        self.payload_size = payload_size
        self.payload = b's' * (self.payload_size * 1024 * 1024)

    def ExchangeData(self, request, context):
        return perf_pb2.DataResponse(payload=self.payload)

def serve():
    parser = argparse.ArgumentParser(description='gRPC Performance Server')
    parser.add_argument('--payload_size', type=int, default=4,
                        help='Payload size in MB (default: 4, max: 50)')
    parser.add_argument('--port', type=int, default=50051,
                        help='Port to listen on (default: 50051)')
    args = parser.parse_args()

    if args.payload_size > 50:
        print("Error: payload_size cannot exceed 50MB")
        return
    if args.payload_size < 1:
        print("Error: payload_size must be at least 1MB")
        return

    payload_size = args.payload_size
    print(f"Server configured with {payload_size}MB payload.")

    # Set max message size to 60MB to accommodate 50MB + overhead
    MAX_MESSAGE_LENGTH = 60 * 1024 * 1024
    options = [
        ('grpc.max_send_message_length', MAX_MESSAGE_LENGTH),
        ('grpc.max_receive_message_length', MAX_MESSAGE_LENGTH),
    ]
    
    server = grpc.server(
        futures.ThreadPoolExecutor(max_workers=10),
        options=options
    )
    perf_pb2_grpc.add_PerfServiceServicer_to_server(PerfService(payload_size), server)
    server.add_insecure_port(f'[::]:{args.port}')
    print(f"Server starting on port {args.port}...")
    server.start()
    try:
        while True:
            time.sleep(86400)
    except KeyboardInterrupt:
        server.stop(0)

if __name__ == '__main__':
    serve()
