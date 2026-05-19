import time

from pymongo import MongoClient

MONGO_URI = "mongodb://admin:password@localhost:27017"
DB_NAME = "homework_db"
COLLECTION_NAME = "users"

QUERY_CITY = "Kazan"


def run_query(collection):
    query = {"city": QUERY_CITY}
    projection = {"_id": 0, "first_name": 1, "last_name": 1, "salary": 1, "city": 1}

    start = time.perf_counter()
    results = list(collection.find(query, projection))
    elapsed = time.perf_counter() - start

    explain = collection.find(query).explain()["queryPlanner"]["winningPlan"]

    return {
        "elapsed": elapsed,
        "count": len(results),
        "stage": explain.get("stage", explain.get("inputStage", {}).get("stage", "unknown")),
        "docs_examined": collection.find(query).explain().get("executionStats", {}).get("totalDocsExamined", "N/A"),
    }


def drop_all_indexes(collection):
    indexes = collection.list_indexes()
    for idx in indexes:
        name = idx["name"]
        if name != "_id_":
            collection.drop_index(name)
            print(f"  Dropped index: {name}")


def main():
    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    collection = db[COLLECTION_NAME]

    total = collection.count_documents({})
    print(f"Total documents: {total}")
    print(f"Query: find users where city = '{QUERY_CITY}'\n")

    # --- WITHOUT INDEX ---
    drop_all_indexes(collection)
    print("\n--- RUNNING WITHOUT INDEX ---")
    # warm-up
    list(collection.find({"city": QUERY_CITY}))

    result_no_index = run_query(collection)
    print(f"  Documents found:    {result_no_index['count']}")
    print(f"  Execution time:     {result_no_index['elapsed']:.4f}s")
    print(f"  Plan stage:         {result_no_index['stage']}")
    explain_full = collection.find({"city": QUERY_CITY}).explain()
    exec_stats = explain_full.get("executionStats", {})
    print(f"  Docs examined:      {exec_stats.get('totalDocsExamined', 'N/A')}")
    print(f"  Execution time (ms): {exec_stats.get('executionTimeMillis', 'N/A')}")

    # --- CREATE INDEX ---
    print("\n--- CREATING INDEX on 'city' ---")
    collection.create_index("city")
    print("  Index created: city_1")

    # --- WITH INDEX ---
    print("\n--- RUNNING WITH INDEX ---")
    # warm-up
    list(collection.find({"city": QUERY_CITY}))

    result_with_index = run_query(collection)
    print(f"  Documents found:    {result_with_index['count']}")
    print(f"  Execution time:     {result_with_index['elapsed']:.4f}s")
    print(f"  Plan stage:         {result_with_index['stage']}")
    explain_full = collection.find({"city": QUERY_CITY}).explain()
    exec_stats = explain_full.get("executionStats", {})
    print(f"  Docs examined:      {exec_stats.get('totalDocsExamined', 'N/A')}")
    print(f"  Execution time (ms): {exec_stats.get('executionTimeMillis', 'N/A')}")

    # --- COMPARISON ---
    exec_no = explain_full.get("executionStats", {}).get("executionTimeMillis", 0)
    # re-run explain for no-index (we already have it from before, let's recalculate)
    drop_all_indexes(collection)
    list(collection.find({"city": QUERY_CITY}))  # warm-up
    explain_no_index = collection.find({"city": QUERY_CITY}).explain()
    exec_no = explain_no_index.get("executionStats", {}).get("executionTimeMillis", 0)

    collection.create_index("city")
    list(collection.find({"city": QUERY_CITY}))  # warm-up
    explain_with_index = collection.find({"city": QUERY_CITY}).explain()
    exec_with = explain_with_index.get("executionStats", {}).get("executionTimeMillis", 0)

    print("\n" + "=" * 60)
    print("  COMPARISON SUMMARY")
    print("=" * 60)
    print(f"  {'Metric':<25} {'No Index':<15} {'With Index':<15}")
    print(f"  {'-' * 55}")
    print(f"  {'Plan stage':<25} {'COLLSCAN':<15} {'IXSCAN':<15}")
    print(f"  {'Docs examined':<25} {explain_no_index.get('executionStats', {}).get('totalDocsExamined', 'N/A'):<15} {explain_with_index.get('executionStats', {}).get('totalDocsExamined', 'N/A'):<15}")
    print(f"  {'Execution time (ms)':<25} {exec_no:<15} {exec_with:<15}")

    if exec_no > 0 and exec_with > 0:
        speedup = exec_no / exec_with
        print(f"\n  Speedup: {speedup:.1f}x faster with index")

    client.close()


if __name__ == "__main__":
    main()
