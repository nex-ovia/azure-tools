# Azure Tools

This repository contains scripts and utilities to work with Microsoft Azure services.

## Primary Dependency

This project uses [UV](https://github.com/astral-sh/uv) as the primary Python runner and dependency manager. Please ensure you have UV installed:

```sh
curl -Ls https://astral.sh/uv/install.sh | sh
```

All scripts and dependency management instructions in this repository assume UV is available.

## Scripts

- [`azure_dequeue.py`](azure-tools/azure_dequeue.py): Dequeues messages from the Service Bus dead-letter queue to the main queue. See [azure_dequeue_README.md](azure_dequeue_README.md) for usage details.

More scripts will be added to this repository to support various Azure operations.
