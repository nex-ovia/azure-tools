# azure_dequeue.py

## Overview

`azure_dequeue.py` is an enterprise-grade utility for moving messages from an Azure Service Bus Dead-Letter Queue (DLQ) back to the main queue. This is useful for retrying previously failed messages after resolving the root cause.

## What It Does
- Connects to the Azure Service Bus for a specified queue.
- Reads messages from the DLQ.
- Republishes each message to the main queue.
- Marks DLQ messages as completed only after successful transfer (avoiding duplication).
- Logs all operations for traceability.

## What It Does NOT Do
- Does not transform messages (business-specific logic must be added separately).
- Does not hardcode credentials (uses environment variables and `.env` for local dev).

## Usage

### Prerequisites
- Python 3.8+
- Install dependencies:
  ```sh
  uv pip install 
  ```
- Set environment variables in a `.env` file or your shell:
  ```env
  SERVICE_BUS_CONN_STR="<your_connection_string>"
  QUEUE_NAME="<your_queue_name>"
  ```

### Running the Script
Use [uv](https://github.com/astral-sh/uv) for fast, isolated execution:
```sh
uv run azure-tools/azure_dequeue.py
```

## Processing Flow

1. **Start**
2. Load `.env` and environment variables
3. Connect to Azure Service Bus
4. Listen to the Dead-Letter Queue (DLQ)
5. For each message in the DLQ:
   1. Send the message to the main queue
   2. Mark the DLQ message as completed
6. Repeat until no more messages remain in the DLQ
7. **End**

## Example .env File
```
SERVICE_BUS_CONN_STR="Endpoint=sb://..."
QUEUE_NAME="my-queue"
```

## Logging
All actions are logged to the console for monitoring and troubleshooting.

## Extending
- Add business-specific message transforms in the message handling section.
- Integrate with CI/CD for automated DLQ reprocessing jobs.

## Support
For issues or feature requests, open an issue in this repository.
