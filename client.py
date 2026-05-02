import grpc
import perf_pb2
import perf_pb2_grpc
import time
import statistics

def run():
    # Set max message size to 60MB
    MAX_MESSAGE_LENGTH = 60 * 1024 * 1024
    options = [
        ('grpc.max_send_message_length', MAX_MESSAGE_LENGTH),
        ('grpc.max_receive_message_length', MAX_MESSAGE_LENGTH),
    ]
    
    channel = grpc.insecure_channel('localhost:50051', options=options)
    stub = perf_pb2_grpc.PerfServiceStub(channel)
    
    payload = b'c' * (50 * 1024 * 1024)
    latencies = []
    
    print("Starting 100 iterations of 50MB exchange...")
    
    for i in range(100):
        start_time = time.perf_counter()
        request = perf_pb2.DataRequest(payload=payload)
        response = stub.ExchangeData(request)
        end_time = time.perf_counter()
        
        latency = (end_time - start_time) * 1000 # in ms
        latencies.append(latency)
        
        if (i + 1) % 10 == 0:
            print(f"Completed {i + 1}/100 iterations. Last latency: {latency:.20f}ms")

    print("\nResults:")
    print(f"Total iterations: {len(latencies)}")
    print(f"Average Latency: {statistics.mean(latencies):.2f} ms")
    print(f"Median Latency:  {statistics.median(latencies):.2f} ms")
    print(f"Min Latency:     {min(latencies):.2f} ms")
    print(f"Max Latency:     {max(latencies):.2f} ms")
    print(f"P95 Latency:     {statistics.quantiles(latencies, n=20)[18]:.2f} ms")

if __name__ == '__main__':
    run()
