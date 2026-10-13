#!/bin/bash
# Run the demo twice:
# 1. with a fault injected on DynamoDB PutItem through the LocalStack Chaos API,
#    and check the program reports the AWS SDK exception
# 2. without the fault, and check the item is stored and read back
set -euo pipefail

ENDPOINT=${ENDPOINT:-http://localhost:4566}
RUN_DEMO=${RUN_DEMO:-dotnet run --project ChaosEngDemo}
# A non-retryable error, so the SDK fails fast instead of backing off
FAULT='[{"service": "dynamodb", "region": "us-east-1", "operation": "PutItem", "probability": 1.0,
  "error": {"statusCode": 400, "code": "AccessDeniedException"}}]'

remove_fault() {
  curl -s -X DELETE "$ENDPOINT/_localstack/chaos/faults" -H 'Content-Type: application/json' -d "$FAULT" > /dev/null
}
trap remove_fault EXIT

echo "Injecting a fault on DynamoDB PutItem"
curl -s --fail-with-body -X POST "$ENDPOINT/_localstack/chaos/faults" \
  -H 'Content-Type: application/json' -d "$FAULT" > /dev/null

output=$($RUN_DEMO 2>&1)
echo "$output"
if [[ "$output" != *"AWS SDK Exception caught!"* || "$output" != *"Error Code: AccessDeniedException"* ]]; then
  echo "Test failed: the demo did not report the injected fault"
  exit 1
fi
if [[ "$output" == *"Item inserted."* ]]; then
  echo "Test failed: the item was inserted despite the fault"
  exit 1
fi
echo "PASS: the demo caught the injected AccessDeniedException"

remove_fault
echo "Fault removed, running the demo again"

output=$($RUN_DEMO 2>&1)
echo "$output"
if [[ "$output" != *"Item retrieved:"* || "$output" != *"Name: Chaos Widget"* ]]; then
  echo "Test failed: the demo did not read the item back"
  exit 1
fi
name=$(lstk aws dynamodb get-item --table-name Products --key '{"Id": {"S": "123"}}' \
  --query Item.Name.S --output text)
if [ "$name" != "Chaos Widget" ]; then
  echo "Test failed: item 123 in the Products table has name '$name'"
  exit 1
fi
echo "PASS: the item was stored in DynamoDB and read back"

echo "Test passed: the demo handles DynamoDB faults and recovers once they are gone"
