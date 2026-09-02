#!/bin/bash

# This sets the metadata for the API registered on API Center.

set -euo pipefail

function usage() {
    cat <<USAGE

    Usage: $0 [--resource-id] [-g|--resource-group] [-s|-n|--service|--name|--service-name] \\
              [--api-id] [-k|--key|--metadata-key] [-v|--value|--metadata-value] [--api-version] \\
              [-h|--help]

    Options:
        --resource-id                           Resource ID. It must be provided unless 'resource-group' is provided.
        -g|--resource-group                     Resource group. It must be provided unless 'resource-id' is provided.
        -s|-n|--service|--name|--service-name   API Center instance name. It must be provided unless 'resource-id' is provided.
        --api-id                                API ID registered to API Center.
        -k|--key|--metadata-key                 Metadata key.
        -v|--value|--metadata-value             Metadata value.
        --api-version                           REST API version. Default is '2024-03-01'.

        -h|--help:                              Show this message.

USAGE
}

function require_value() {
    if [[ $# -lt 2 ]]; then
        echo "Option '$1' requires a value." >&2
        usage >&2
        exit 1
    fi
}

RESOURCE_ID=
RESOURCE_GROUP=
SERVICE_NAME=
API_ID=
METADATA_KEY=
METADATA_VALUE=
API_VERSION="2024-03-01"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --resource-id)
            require_value "$@"
            RESOURCE_ID="$2"
            shift 2
        ;;

        -g | --resource-group)
            require_value "$@"
            RESOURCE_GROUP="$2"
            shift 2
        ;;

        -s | -n | --service | --name | --service-name)
            require_value "$@"
            SERVICE_NAME="$2"
            shift 2
        ;;

        --api-id)
            require_value "$@"
            API_ID="$2"
            shift 2
        ;;

        -k | --key | --metadata-key)
            require_value "$@"
            METADATA_KEY="$2"
            shift 2
        ;;

        -v | --value | --metadata-value)
            require_value "$@"
            METADATA_VALUE="$2"
            shift 2
        ;;

        --api-version)
            require_value "$@"
            API_VERSION="$2"
            shift 2
        ;;

        -h | --help)
            usage
            exit 0
        ;;

        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
        ;;
    esac
done

if [[ -z "$RESOURCE_ID" && ( -z "$RESOURCE_GROUP" || -z "$SERVICE_NAME" ) ]]; then
    echo "'resource-id' must be provided, or both 'resource-group' and 'service-name' must be provided" >&2
    exit 1
fi
if [[ -z "$API_ID" ]]; then
    echo "'api-id' must be provided" >&2
    exit 1
fi
if [[ -z "$METADATA_KEY" || -z "$METADATA_VALUE" ]]; then
    echo "Both 'metadata-key' and 'metadata-value' must be provided" >&2
    exit 1
fi

IFS='/' read -ra SEGMENTS <<< "$RESOURCE_ID"
if [ -z "$RESOURCE_GROUP" ]; then
    RESOURCE_GROUP=${SEGMENTS[4]}
fi
if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME=${SEGMENTS[8]}
fi

CUSTOM_PROPERTIES=$(jq -nc \
    --arg key "$METADATA_KEY" \
    --arg value "$METADATA_VALUE" \
    '{($key): $value}')

az apic api update \
    -g "$RESOURCE_GROUP" \
    -s "$SERVICE_NAME" \
    --api-id "$API_ID" \
    --custom-properties "$CUSTOM_PROPERTIES"
