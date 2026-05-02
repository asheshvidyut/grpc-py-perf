import grpc
import perf_pb2
import perf_pb2_grpc
from concurrent import futures
import time

class PerfService(perf_pb2_grpc.PerfServiceServicer):
    def ExchangeData(self, request, context):
        # Generate 50MB response
        response_payload = b's' * (50 * 1024 * 1024)
        return perf_pb2.DataResponse(payload=response_payload)

def serve():
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
    perf_pb2_grpc.add_PerfServiceServicer_to_server(PerfService(), server)
    server.add_insecure_port('[::]:50051')
    print("Server starting on port 50051...")
    server.start()
    try:
        while True:
            time.sleep(86400)
    except KeyboardInterrupt:
        server.stop(0)

if __name__ == '__main__':
    serve()
