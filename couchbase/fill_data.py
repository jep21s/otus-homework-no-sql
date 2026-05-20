import random
import time
from datetime import datetime, timedelta

from couchbase.auth import PasswordAuthenticator
from couchbase.cluster import Cluster
from couchbase.options import ClusterOptions

CB_HOST = "couchbase://172.20.0.2"
CB_USER = "Administrator"
CB_PASS = "password"
BUCKET_NAME = "homework"
NUM_DOCUMENTS = 50_000
BATCH_SIZE = 500

CITIES = [
    "Moscow", "Saint Petersburg", "Novosibirsk", "Yekaterinburg",
    "Kazan", "Nizhny Novgorod", "Chelyabinsk", "Samara",
    "Omsk", "Rostov-on-Don", "Ufa", "Krasnoyarsk",
    "Voronezh", "Perm", "Volgograd",
]

FIRST_NAMES = [
    "Alexander", "Dmitry", "Maxim", "Sergey", "Andrey",
    "Alexey", "Artem", "Ilya", "Kirill", "Mikhail",
    "Anna", "Maria", "Elena", "Olga", "Tatiana",
    "Natalia", "Irina", "Svetlana", "Ekaterina", "Julia",
]

LAST_NAMES = [
    "Ivanov", "Petrov", "Sidorov", "Kozlov", "Novikov",
    "Morozov", "Volkov", "Sokolov", "Lebedev", "Kuznetsov",
]


def generate_doc(doc_id):
    first_name = random.choice(FIRST_NAMES)
    last_name = random.choice(LAST_NAMES)
    return {
        "id": doc_id,
        "first_name": first_name,
        "last_name": last_name,
        "age": random.randint(18, 70),
        "city": random.choice(CITIES),
        "salary": random.randint(30_000, 300_000),
        "email": f"{first_name.lower()}.{last_name.lower()}{random.randint(1, 9999)}@mail.ru",
    }


def main():
    auth = PasswordAuthenticator(CB_USER, CB_PASS)
    cluster = Cluster(CB_HOST, ClusterOptions(auth))
    cluster.wait_until_ready(timedelta(seconds=60))

    bucket = cluster.bucket(BUCKET_NAME)
    collection = bucket.default_collection()

    print(f"Connected to bucket '{BUCKET_NAME}'")
    print(f"Inserting {NUM_DOCUMENTS} documents in batches of {BATCH_SIZE}...")

    start = time.perf_counter()
    inserted = 0

    while inserted < NUM_DOCUMENTS:
        batch_size = min(BATCH_SIZE, NUM_DOCUMENTS - inserted)
        for i in range(batch_size):
            doc_id = inserted + i + 1
            key = f"user::{doc_id}"
            doc = generate_doc(doc_id)
            collection.upsert(key, doc)
        inserted += batch_size
        elapsed = time.perf_counter() - start
        print(f"  Inserted {inserted}/{NUM_DOCUMENTS} ({elapsed:.1f}s)")

    total_elapsed = time.perf_counter() - start
    print(f"\nDone! {NUM_DOCUMENTS} documents inserted in {total_elapsed:.1f}s")

    doc = collection.get("user::1").content_as[dict]
    print(f"\nSample document (user::1): {doc}")

    cluster.close()


if __name__ == "__main__":
    main()
