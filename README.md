# Chaos Engineering Demo with LocalStack and DynamoDB

This project demonstrates a simple chaos engineering experiment using LocalStack to simulate AWS DynamoDB.  The code creates a DynamoDB table, inserts an item, and then retrieves the item.  It also includes error handling to demonstrate how to catch potential exceptions during DynamoDB operations.

## Prerequisites

* **LocalStack Pro** with the [`localstack` CLI](https://docs.localstack.cloud/getting-started/installation/#localstack-cli).
* **AWS SDK for .NET:** Install the `AWSSDK.DynamoDBv2` NuGet package in your project.
* **.NET SDK:** Ensure you have the .NET SDK installed.
* **[AWS CLI](https://docs.localstack.cloud/user-guide/integrations/aws-cli/)** with the [`awslocal` wrapper](https://docs.localstack.cloud/user-guide/integrations/aws-cli/#localstack-aws-cli-awslocal).


## Running the Demo

Start LocalStack Pro with the `LOCALSTACK_AUTH_TOKEN` pre-configured:

```bash
export LOCALSTACK_AUTH_TOKEN=<your-auth-token>
make start
make ready
```

1. **Start LocalStack:** Ensure LocalStack is running locally as described above.

2. **Build and Run:** Build and run the C# project. The application will:
    * Connect to your local DynamoDB instance running in LocalStack.
    * Create a table named "Products" if it doesn't already exist.
    * Insert an item with ID "123" into the table.
    * Retrieve the item and print its attributes to the console.
    * Handle any exceptions that may occur during these operations.

## Key Concepts

* **LocalStack:**  Provides a local AWS cloud stack for development and testing.  This allows you to run the demo without needing a real AWS account.
* **DynamoDB:**  A NoSQL database service provided by AWS. This demo showcases basic DynamoDB operations.
* **Chaos Engineering:**  While this demo doesn't introduce explicit chaos, it forms the foundation for chaos experiments.  You can extend this code to simulate failures, outages, or latency issues and observe how your application behaves under stress.  (See below for ideas on extending this project for chaos experiments).

## Extending for Chaos Experiments

Here are some ideas to extend this demo for more realistic chaos engineering experiments:

* **Simulate Latency:** Introduce artificial latency in the DynamoDB calls to simulate network delays.
* **Simulate Errors:** Inject errors (e.g., throttling exceptions, connection errors) to test your application's resilience.
* **Data Corruption:**  Introduce data corruption scenarios to see how your application handles unexpected data.


## Error Handling

The code includes error handling using `try-catch` blocks to catch `AmazonDynamoDBException` and generic `Exception` objects. This demonstrates best practices for handling potential issues when interacting with DynamoDB.
