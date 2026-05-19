import random
import string
from datetime import datetime, timedelta

from pymongo import MongoClient

MONGO_URI = "mongodb://admin:password@localhost:27017"
DB_NAME = "homework_db"
COLLECTION_NAME = "users"
NUM_DOCUMENTS = 200_000

CITIES = [
    "Moscow", "Saint Petersburg", "Novosibirsk", "Yekaterinburg",
    "Kazan", "Nizhny Novgorod", "Chelyabinsk", "Samara",
    "Omsk", "Rostov-on-Don", "Ufa", "Krasnoyarsk",
    "Voronezh", "Perm", "Volgograd",
]

FIRST_NAMES = [
    "Alexander", "Dmitry", "Maxim", "Sergey", "Andrey",
    "Alexey", "Artem", "Ilya", "Kirill", "Mikhail",
    "Nikita", "Matvey", "Roman", "Egor", "Artyom",
    "Anna", "Maria", "Elena", "Olga", "Tatiana",
    "Natalia", "Irina", "Svetlana", "Ekaterina", "Julia",
]

LAST_NAMES = [
    "Ivanov", "Petrov", "Sidorov", "Kozlov", "Novikov",
    "Morozov", "Volkov", "Sokolov", "Lebedev", "Kuznetsov",
]


def random_email(first_name, last_name):
    domains = ["mail.ru", "yandex.ru", "gmail.com", "rambler.ru", "bk.ru"]
    suffix = random.randint(1, 9999)
    return f"{first_name.lower()}.{last_name.lower()}{suffix}@{random.choice(domains)}"


def generate_batch(batch_size):
    docs = []
    base_date = datetime(2020, 1, 1)
    for _ in range(batch_size):
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        registered_at = base_date + timedelta(
            days=random.randint(0, 1825),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
        )
        docs.append({
            "first_name": first_name,
            "last_name": last_name,
            "email": random_email(first_name, last_name),
            "age": random.randint(18, 70),
            "city": random.choice(CITIES),
            "salary": random.randint(30_000, 300_000),
            "registered_at": registered_at,
        })
    return docs


def main():
    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    collection = db[COLLECTION_NAME]

    existing = collection.count_documents({})
    if existing > 0:
        print(f"Collection already has {existing} documents. Dropping...")
        collection.drop()

    batch_size = 10_000
    inserted = 0
    while inserted < NUM_DOCUMENTS:
        batch = generate_batch(min(batch_size, NUM_DOCUMENTS - inserted))
        collection.insert_many(batch)
        inserted += len(batch)
        print(f"Inserted {inserted}/{NUM_DOCUMENTS} documents")

    total = collection.count_documents({})
    print(f"\nDone. Total documents in '{COLLECTION_NAME}': {total}")
    client.close()


if __name__ == "__main__":
    main()
