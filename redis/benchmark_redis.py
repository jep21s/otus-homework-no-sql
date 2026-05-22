import json
import os
import time

import redis

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_FILE = os.path.join(SCRIPT_DIR, "data.json")
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))


def load_data():
    with open(DATA_FILE, "r") as f:
        return json.load(f)


def benchmark_string(r, data):
    key = "bench:string"
    raw = json.dumps(data)

    start = time.perf_counter()
    r.set(key, raw)
    write_time = time.perf_counter() - start

    start = time.perf_counter()
    _ = r.get(key)
    read_time = time.perf_counter() - start

    r.delete(key)
    return write_time, read_time


def benchmark_hset(r, data):
    key = "bench:hset"

    start = time.perf_counter()
    pipe = r.pipeline(transaction=False)
    for i, item in enumerate(data):
        pipe.hset(key, str(i), json.dumps(item))
    pipe.execute()
    write_time = time.perf_counter() - start

    start = time.perf_counter()
    _ = r.hgetall(key)
    read_time = time.perf_counter() - start

    r.delete(key)
    return write_time, read_time


def benchmark_zset(r, data):
    key = "bench:zset"

    start = time.perf_counter()
    pipe = r.pipeline(transaction=False)
    for i, item in enumerate(data):
        pipe.zadd(key, {json.dumps(item): i})
    pipe.execute()
    write_time = time.perf_counter() - start

    start = time.perf_counter()
    _ = r.zrange(key, 0, -1)
    read_time = time.perf_counter() - start

    r.delete(key)
    return write_time, read_time


def benchmark_list(r, data):
    key = "bench:list"

    start = time.perf_counter()
    pipe = r.pipeline(transaction=False)
    for item in data:
        pipe.rpush(key, json.dumps(item))
    pipe.execute()
    write_time = time.perf_counter() - start

    start = time.perf_counter()
    _ = r.lrange(key, 0, -1)
    read_time = time.perf_counter() - start

    r.delete(key)
    return write_time, read_time


def main():
    print("Loading data...")
    data = load_data()
    print(f"Records: {len(data)}")
    print(f"File size: {os.path.getsize(DATA_FILE) / (1024 * 1024):.2f} MB")
    print()

    r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
    r.ping()
    print(f"Connected to Redis at {REDIS_HOST}:{REDIS_PORT}")
    print()

    benchmarks = [
        ("String (SET/GET)", benchmark_string),
        ("Hash   (HSET/HGETALL)", benchmark_hset),
        ("ZSet   (ZADD/ZRANGE)", benchmark_zset),
        ("List   (RPUSH/LRANGE)", benchmark_list),
    ]

    results = []
    for name, fn in benchmarks:
        print(f"Running {name}...")
        write_time, read_time = fn(r, data)
        results.append((name, write_time, read_time))

    print()
    print("=" * 65)
    print(f"{'Structure':<26} {'Write (s)':>12} {'Read (s)':>12} {'Total (s)':>12}")
    print("=" * 65)
    for name, wt, rt in results:
        total = wt + rt
        print(f"{name:<26} {wt:>12.4f} {rt:>12.4f} {total:>12.4f}")
    print("=" * 65)


if __name__ == "__main__":
    main()
