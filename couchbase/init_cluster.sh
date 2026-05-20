#!/bin/bash
set -e

CB_HOST="http://localhost:8091"
CB_USER="Administrator"
CB_PASS="password"
RAM_MB=512
BUCKET_NAME="homework"
BUCKET_RAM_MB=256

NODE1_IP=$(docker inspect couchbase-node1 --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
NODE2_IP=$(docker inspect couchbase-node2 --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
NODE3_IP=$(docker inspect couchbase-node3 --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "Node1 IP: $NODE1_IP"
echo "Node2 IP: $NODE2_IP"
echo "Node3 IP: $NODE3_IP"

wait_for_node() {
    echo "Waiting for Couchbase at $1..."
    for i in $(seq 1 30); do
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$1:8091/ui/index.html" 2>/dev/null || echo "000")
        if [ "$HTTP_CODE" = "200" ]; then
            echo "Couchbase is ready at $1."
            return 0
        fi
        echo "  Attempt $i/30 — HTTP $HTTP_CODE, retrying in 5s..."
        sleep 5
    done
    echo "ERROR: Couchbase did not become ready at $1"
    exit 1
}

echo "=== Step 1: Initialize node1 ==="
wait_for_node localhost

if curl -s -u "$CB_USER:$CB_PASS" "$CB_HOST/pools/default" 2>/dev/null | grep -q "storageTotals"; then
    echo "Node1 already initialized."
else
    echo "Initializing node1..."
    RESP=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$CB_HOST/clusterInit" \
        -d "hostname=$NODE1_IP" \
        -d "username=$CB_USER" \
        -d "password=$CB_PASS" \
        -d "port=SAME" \
        -d "services=kv,n1ql,index" \
        -d "memoryQuota=$RAM_MB" \
        -d "indexMemoryQuota=$RAM_MB")
    HTTP_CODE=$(echo "$RESP" | grep "HTTP_CODE:" | cut -d: -f2)
    BODY=$(echo "$RESP" | grep -v "HTTP_CODE:")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
        echo "Node1 initialized successfully."
    else
        echo "ERROR: clusterInit failed (HTTP $HTTP_CODE): $BODY"
        exit 1
    fi
fi

echo "=== Step 2: Add node2 and node3 ==="
RESP2=$(curl -s -w "\nHTTP_CODE:%{http_code}" -u "$CB_USER:$CB_PASS" -X POST "$CB_HOST/controller/addNode" \
    -d "hostname=$NODE2_IP" \
    -d "user=$CB_USER" \
    -d "password=$CB_PASS" \
    -d "services=kv,n1ql,index")
HTTP2=$(echo "$RESP2" | grep "HTTP_CODE:" | cut -d: -f2)
BODY2=$(echo "$RESP2" | grep -v "HTTP_CODE:")
if [ "$HTTP2" = "200" ] || [ "$HTTP2" = "202" ]; then
    echo "node2 added (IP: $NODE2_IP)."
else
    echo "node2 response (HTTP $HTTP2): $BODY2"
fi

RESP3=$(curl -s -w "\nHTTP_CODE:%{http_code}" -u "$CB_USER:$CB_PASS" -X POST "$CB_HOST/controller/addNode" \
    -d "hostname=$NODE3_IP" \
    -d "user=$CB_USER" \
    -d "password=$CB_PASS" \
    -d "services=kv,n1ql,index")
HTTP3=$(echo "$RESP3" | grep "HTTP_CODE:" | cut -d: -f2)
BODY3=$(echo "$RESP3" | grep -v "HTTP_CODE:")
if [ "$HTTP3" = "200" ] || [ "$HTTP3" = "202" ]; then
    echo "node3 added (IP: $NODE3_IP)."
else
    echo "node3 response (HTTP $HTTP3): $BODY3"
fi

echo "=== Step 3: Rebalance cluster ==="
KNOWN=$(curl -s -u "$CB_USER:$CB_PASS" "$CB_HOST/pools/default" | python3 -c "
import sys, json
pool = json.load(sys.stdin)
nodes = pool.get('nodes', [])
print(','.join('ns_1@' + n['hostname'].split(':')[0] for n in nodes))
")
echo "Known nodes: $KNOWN"

REB_RESP=$(curl -s -w "\nHTTP_CODE:%{http_code}" -u "$CB_USER:$CB_PASS" -X POST "$CB_HOST/controller/rebalance" \
    -d "knownNodes=$KNOWN")
REB_HTTP=$(echo "$REB_RESP" | grep "HTTP_CODE:" | cut -d: -f2)
REB_BODY=$(echo "$REB_RESP" | grep -v "HTTP_CODE:")
if [ "$REB_HTTP" = "200" ] || [ "$REB_HTTP" = "202" ]; then
    echo "Rebalance started."
else
    echo "Rebalance response (HTTP $REB_HTTP): $REB_BODY"
fi

echo "Waiting for rebalance to complete..."
for i in $(seq 1 60); do
    STATUS=$(curl -s -u "$CB_USER:$CB_PASS" "$CB_HOST/pools/default" 2>/dev/null | python3 -c "
import sys, json
try:
    pool = json.load(sys.stdin)
    print(pool.get('rebalanceStatus', 'none'))
except:
    print('error')
" 2>/dev/null || echo "error")
    if [ "$STATUS" = "none" ]; then
        break
    fi
    echo "  Rebalance status: $STATUS ($i/60)"
    sleep 5
done
echo "Rebalance complete."

echo "=== Step 4: Create bucket with replicas ==="
if curl -s -u "$CB_USER:$CB_PASS" "$CB_HOST/pools/default/buckets/$BUCKET_NAME" 2>/dev/null | grep -q "name"; then
    echo "Bucket '$BUCKET_NAME' already exists."
else
    BUCK_RESP=$(curl -s -w "\nHTTP_CODE:%{http_code}" -u "$CB_USER:$CB_PASS" -X POST "$CB_HOST/pools/default/buckets" \
        -d "name=$BUCKET_NAME" \
        -d "ramQuotaMB=$BUCKET_RAM_MB" \
        -d "bucketType=couchbase" \
        -d "replicaNumber=2" \
        -d "flushEnabled=1" \
        -d "evictionPolicy=valueOnly")
    BUCK_HTTP=$(echo "$BUCK_RESP" | grep "HTTP_CODE:" | cut -d: -f2)
    BUCK_BODY=$(echo "$BUCK_RESP" | grep -v "HTTP_CODE:")
    if [ "$BUCK_HTTP" = "200" ] || [ "$BUCK_HTTP" = "202" ]; then
        echo "Bucket '$BUCKET_NAME' created with 2 replicas."
    else
        echo "Bucket response (HTTP $BUCK_HTTP): $BUCK_BODY"
    fi
fi

echo "Waiting for bucket to be ready..."
sleep 10

echo ""
echo "=== Cluster setup complete! ==="
echo "Couchbase UI: http://localhost:8091"
echo "Login: $CB_USER / $CB_PASS"
echo "Bucket: $BUCKET_NAME"
