#!/bin/bash
set -e

until curl -s http://localhost:9200 > /dev/null; do
  echo "Waiting for OpenSearch..."
  sleep 2
done

echo "OpenSearch is ready"

echo "Creating index 'documents'..."
curl -s -X PUT "http://localhost:9200/documents" \
  -H "Content-Type: application/json" \
  -d '{
    "settings": {
      "analysis": {
        "filter": {
          "ru_stop": {
            "type": "stop",
            "stopwords": "_russian_"
          },
          "ru_stemmer": {
            "type": "stemmer",
            "language": "russian"
          }
        },
        "analyzer": {
          "my_russian": {
            "type": "custom",
            "tokenizer": "standard",
            "filter": ["lowercase", "ru_stop", "ru_stemmer"]
          }
        }
      }
    },
    "mappings": {
      "properties": {
        "text": {
          "type": "text",
          "analyzer": "my_russian"
        }
      }
    }
  }'

echo -e "\n\nAdding documents..."

curl -s -X POST "http://localhost:9200/documents/_doc/1" \
  -H "Content-Type: application/json" \
  -d '{"text": "моя мама мыла посуду а кот жевал сосиски"}'

echo ""

curl -s -X POST "http://localhost:9200/documents/_doc/2" \
  -H "Content-Type: application/json" \
  -d '{"text": "рама была отмыта и вылизана котом"}'

echo ""

curl -s -X POST "http://localhost:9200/documents/_doc/3" \
  -H "Content-Type: application/json" \
  -d '{"text": "мама мыла раму"}'

echo -e "\n\nDone. Documents indexed."
