import time

from pymongo import MongoClient

MONGO_URI = "mongodb://admin:password@localhost:27017"
DB_NAME = "homework_db"
COLLECTION_NAME = "users"


def timed(label, func, *args, **kwargs):
    print(f"\n{'=' * 60}")
    print(f"  {label}")
    print(f"{'=' * 60}")
    start = time.perf_counter()
    result = func(*args, **kwargs)
    elapsed = time.perf_counter() - start
    print(f"  Time: {elapsed:.4f}s")
    return result, elapsed


def query_by_city(collection, city="Kazan"):
    cursor = collection.find({"city": city}, {"_id": 0, "first_name": 1, "last_name": 1, "city": 1, "salary": 1})
    results = list(cursor.limit(10))
    count = collection.count_documents({"city": city})
    print(f"  Found {count} users in '{city}', showing first 10:")
    for r in results:
        print(f"    {r['first_name']} {r['last_name']} — salary: {r['salary']}")
    return count


def query_by_age_range(collection, min_age=25, max_age=35):
    query = {"age": {"$gte": min_age, "$lte": max_age}}
    count = collection.count_documents(query)
    results = list(collection.find(query, {"_id": 0, "first_name": 1, "last_name": 1, "age": 1}).limit(10))
    print(f"  Found {count} users aged {min_age}-{max_age}, showing first 10:")
    for r in results:
        print(f"    {r['first_name']} {r['last_name']} — age: {r['age']}")
    return count


def query_top_salaries(collection, limit=5):
    results = list(
        collection.find({}, {"_id": 0, "first_name": 1, "last_name": 1, "salary": 1, "city": 1})
        .sort("salary", -1)
        .limit(limit)
    )
    print(f"  Top {limit} salaries:")
    for r in results:
        print(f"    {r['first_name']} {r['last_name']} ({r['city']}) — salary: {r['salary']}")
    return results


def update_salary_by_name(collection, first_name, last_name, new_salary):
    result = collection.update_many(
        {"first_name": first_name, "last_name": last_name},
        {"$set": {"salary": new_salary}},
    )
    print(f"  Matched: {result.matched_count}, Modified: {result.modified_count}")
    return result.modified_count


def update_city_by_age_range(collection, min_age, max_age, new_city):
    result = collection.update_many(
        {"age": {"$gte": min_age, "$lte": max_age}},
        {"$set": {"city": new_city}},
    )
    print(f"  Matched: {result.matched_count}, Modified: {result.modified_count}")
    return result.modified_count


def main():
    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    collection = db[COLLECTION_NAME]

    total = collection.count_documents({})
    print(f"Total documents: {total}")

    # --- SELECT queries ---
    timed("SELECT: Users by city (Kazan)", query_by_city, collection, "Kazan")
    timed("SELECT: Users aged 25-35", query_by_age_range, collection, 25, 35)
    timed("SELECT: Top 5 salaries", query_top_salaries, collection, 5)

    # --- UPDATE queries ---
    timed(
        "UPDATE: Set salary=500000 for 'Alexander Ivanov'",
        update_salary_by_name, collection, "Alexander", "Ivanov", 500000,
    )
    timed(
        "UPDATE: Set city='Moscow' for users aged 65-70",
        update_city_by_age_range, collection, 65, 70, "Moscow",
    )

    client.close()
    print("\nAll queries completed.")


if __name__ == "__main__":
    main()
