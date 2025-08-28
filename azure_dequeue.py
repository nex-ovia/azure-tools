#!/usr/bin/env python3
"""
Enterprise-grade utility to move messages from Azure Service Bus Dead-Letter Queue (DLQ)
back to the main queue.

Business Logic:
---------------
WHAT: Reads messages from <queue>/$DeadLetterQueue and republishes them into <queue>.
WHY: Useful for retrying previously failed messages after fixing the root cause.
WHERE: Runs locally (via `uv run`) or in CI/CD as a job/tool.
WHEN: Run on-demand or scheduled to reprocess dead-lettered events.
HOW: Uses Azure Service Bus SDK (async) for safe message transfer.

NOTES / WHAT'S NOT:
- Does NOT transform messages (business-specific replay/transforms must be added separately).
- Does NOT hardcode credentials: uses env vars + `.env` for local dev.
"""

import os
import asyncio
import logging
from dotenv import load_dotenv
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage

# ============================================================
#  CONFIGURATION AND SETUP
# ============================================================

# Load .env file if present (local dev mode)
load_dotenv()

SERVICE_BUS_CONN_STR = os.getenv("SERVICE_BUS_CONN_STR")
QUEUE_NAME = os.getenv("QUEUE_NAME")

# Safety check
if not SERVICE_BUS_CONN_STR or not QUEUE_NAME:
    raise ValueError("Missing required env vars: SERVICE_BUS_CONN_STR and/or QUEUE_NAME")

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger("azure-dlq-mover")


# ============================================================
#  BUSINESS LOGIC
# ============================================================

async def move_dlq_messages():
    """
    Connect to the Dead-Letter Queue, receive messages, and re-publish them
    into the main queue. Each message is explicitly completed from DLQ
    only after successful send to avoid duplication.
    """
    async with ServiceBusClient.from_connection_string(
        conn_str=SERVICE_BUS_CONN_STR,
        logging_enable=False
    ) as client:

        # Dead-letter subqueue receiver
        receiver = client.get_queue_receiver(
            queue_name=QUEUE_NAME,
            sub_queue="deadletter"
        )

        # Main queue sender
        sender = client.get_queue_sender(queue_name=QUEUE_NAME)

        async with receiver, sender:
            logger.info("Listening to DLQ for queue='%s' ...", QUEUE_NAME)

            async for msg in receiver:
                try:
                    # Extract body safely (convert generator to string)
                    body = b"".join(b for b in msg.body).decode("utf-8", errors="replace")

                    new_msg = ServiceBusMessage(
                        body=body,
                        application_properties=msg.application_properties
                    )

                    # Send to active queue
                    await sender.send_messages(new_msg)

                    # Mark original DLQ message as processed
                    await receiver.complete_message(msg)

                    logger.info("Moved DLQ message ID=%s back to queue=%s", msg.message_id, QUEUE_NAME)

                except Exception as e:
                    logger.error("Failed to move message ID=%s: %s", msg.message_id, e)
                    # Do not complete → message stays in DLQ for retry/inspection


# ============================================================
#  ENTRYPOINT
# ============================================================

async def main():
    logger.info("Starting DLQ → Queue mover")
    await move_dlq_messages()
    logger.info("Completed DLQ processing run")


if __name__ == "__main__":
    asyncio.run(main())