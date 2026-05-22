import json
import random
import string
import os

TARGET_SIZE_MB = 20
OUTPUT_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data.json")


def random_string(length=10):
    return "".join(random.choices(string.ascii_letters + string.digits, k=length))


def generate_record(index):
    return {
        "id": index,
        "name": random_string(20),
        "email": f"{random_string(8)}@{random_string(6)}.{random.choice(['com', 'org', 'net'])}",
        "age": random.randint(18, 80),
        "score": round(random.uniform(0, 100), 4),
        "active": random.choice([True, False]),
        "tags": [random_string(5) for _ in range(random.randint(1, 5))],
        "address": {
            "city": random_string(10),
            "street": random_string(15),
            "zip": f"{random.randint(10000, 99999)}",
        },
        "description": random_string(50),
    }


def main():
    records = []
    index = 0
    while True:
        records.append(generate_record(index))
        index += 1
        if index % 5000 == 0:
            size = len(json.dumps(records).encode("utf-8"))
            if size >= TARGET_SIZE_MB * 1024 * 1024:
                break

    with open(OUTPUT_FILE, "w") as f:
        json.dump(records, f)

    actual_size = os.path.getsize(OUTPUT_FILE)
    print(f"Generated {OUTPUT_FILE}")
    print(f"Records: {len(records)}")
    print(f"Size: {actual_size / (1024 * 1024):.2f} MB")


if __name__ == "__main__":
    main()
