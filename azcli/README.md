# Azure CLI quick commands

This document describes the purpose and usage of the `azcli.zsh` helper script. The script contains common Azure CLI commands for logging in, selecting a subscription, creating/updating a resource group, and assigning a role to a user.

**Location**: `./azcli.zsh`

**Quick summary**
- Purpose: Provide simple, repeatable Azure CLI commands to create a resource group, update tags, and assign a user the `Contributor` role scoped to the resource group.
- Intended use: Source your environment variables from `az.env` and run the commands interactively or as part of an automation step.

**Prerequisites**
- `az` (Azure CLI) installed and on your `PATH`.
- `zsh` available (the file is `.zsh`, but commands can be run from any shell by copying the commands or running `zsh azcli.zsh`).
- A properly configured `az.env` file with required environment variables (see the sample below).
- An authenticated Azure session (the script runs `az login` interactively).

Example: install Azure CLI on macOS (Homebrew):

```
brew update
brew install azure-cli
```

**Recommended safety**
- Keep your `az.env` out of version control. Add it to `.gitignore`.
- sample az.env is avaialble in the git. 
- Use least privilege for `TARGET_USER` and prefer managed identities/service principals for automation instead of interactive user accounts.
- Inspect and confirm the variables before running commands that create or modify resources.

**Environment file (`az.env`)**
The `azcli.zsh` script expects you to `source az.env` before running. Create a file named `az.env` (in the same directory or point to it) with the following variables:

```
# Example az.env
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP_NAME="my-resource-group"
LOCATION="eastus"
TAGS="owner=alice environment=dev"
TARGET_USER="alice@example.com"
```

Notes:
- `TAGS` can contain multiple key=value pairs separated by spaces. To avoid word-splitting issues, wrap the whole tags string in quotes as shown.

**How the script works / Included commands**
The script includes these Azure CLI operations (in order):

- `az login` — interactive login.
- `source az.env` — load environment variables from `az.env` (you should run this locally; the script includes a `source` line as a reminder).
- `az account set --subscription ${SUBSCRIPTION_ID}` — choose the subscription to operate in.
- `az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION" --tags $TAGS` — create resource group with tags.
- `az group show --name "$RESOURCE_GROUP_NAME" --query "tags"` — verify tags on the resource group.
- `az group update --name "$RESOURCE_GROUP_NAME" --tags $TAGS` — update tags on the resource group.
- `az role assignment create --assignee "$TARGET_USER" --role "Contributor" --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"` — assign Contributor role to a user at the resource group scope.
- `az role assignment list --assignee "$TARGET_USER" --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME" --output table` — list role assignments for verification.

**Usage examples**

1) Interactive (recommended for manual use):

```
# from the folder containing az.env and azcli.zsh
source az.env
zsh azcli.zsh
```

or copy-paste the commands from `azcli.zsh` into your terminal after sourcing `az.env`.

2) Make the script executable and run it (ensure it has a proper shebang first):

```
# (Optional) Add shebang at top of azcli.zsh if you want to execute it directly
# Add this as the first line: #!/usr/bin/env zsh
chmod +x azcli.zsh
./azcli.zsh
```

3) Non-interactive automation (CI/CD):
- Prefer using a service principal or managed identity. Replace the interactive `az login` with `az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant-id>` or use `az login --identity` for managed identities.

**Common improvements & gotchas**
- The script shows `--tags $TAGS` without quotes in the original. If your `TAGS` value contains spaces, ensure you wrap it in quotes when used (e.g., `--tags "$TAGS"`) to prevent word-splitting.
- For automation, consider `set -euo pipefail` (or `set -e` with `zsh` equivalents) at the top of the script to fail fast on errors.
- Consider adding a `--yes` or `--no-prompt` flag where available for non-interactive use.
- Validate the values of required environment variables before running the Azure CLI commands. Example guard in `zsh`:

```
: "${SUBSCRIPTION_ID:?SUBSCRIPTION_ID is required}"
: "${RESOURCE_GROUP_NAME:?RESOURCE_GROUP_NAME is required}"
```

**Security & Permissions**
- Role assignment uses the `Contributor` role — that grants broad permissions within the resource group. Use more restrictive roles where possible.
- Do not store plaintext credentials (client secrets) in `az.env` unless the file is protected and never committed to source control.

**Troubleshooting**
- If `az` commands fail, run `az account show` to confirm the active subscription and `az login` again if needed.
- Use `--debug` or `--verbose` with the `az` command to get more diagnostic output.


---

*Footnote: This README was generated with assistance from an AI agent.*
