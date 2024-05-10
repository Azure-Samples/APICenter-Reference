#!/bin/bash

# This sets the metadata for the API registered on API Center.

set -e

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

    exit 1
}

RESOURCE_ID=
RESOURCE_GROUP=
SERVICE_NAME=
API_ID=
METADATA_KEY=
METADATA_VALUE=
API_VERSION="2024-03-01"

if [[ $# -eq 0 ]]; then
    RESOURCE_ID=
    RESOURCE_GROUP=
    SERVICE_NAME=
    API_ID=
    METADATA_KEY=
    METADATA_VALUE=
    API_VERSION="2024-03-01"
fi

while [[ "$1" != "" ]]; do
    case $1 in
        --resource-id)
            shift
            RESOURCE_ID="$1"
        ;;

        -g | --resource-group)
            shift
            RESOURCE_GROUP="$1"
        ;;

        -s | -n | --service | --name | --service-name)
            shift
            SERVICE_NAME="$1"
        ;;

        --api-id)
            shift
            API_ID="$1"
        ;;

        -k | --key | --metadata-key)
            shift
            METADATA_KEY="$1"
        ;;

        -v | --value | --metadata-value)
            shift
            METADATA_VALUE="$1"
        ;;

        --api-version)
            shift
            API_VERSION="$1"
        ;;

        -h | --help)
            usage
            exit 1
        ;;

        *)
            usage
            exit 1
        ;;
    esac

    shift
done

if [ -z "$RESOURCE_ID" ] && ( [ -z "$RESOURCE_GROUP" ] || [ -z "$SERVICE_NAME" ] ); then
    echo "'resource-id' must be provided, or both 'resource-group' and 'service-name' must be provided"
    exit 0
fi
if [ -z "$API_ID" ]; then
    echo "'api-id' must be provided"
    exit 0
fi
if [ -z "$METADATA_KEY" ] || [ -z "$METADATA_VALUE" ]; then
    echo "Both 'metadata-key' and 'metadata-value' must be provided"
    exit 0
fi

IFS='/' read -ra SEGMENTS <<< "$RESOURCE_ID"
if [ -z "$RESOURCE_GROUP" ]; then
    RESOURCE_GROUP=${SEGMENTS[4]}
fi
if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME=${SEGMENTS[8]}
fi

CUSTOM_PROPERTIES=$(echo "{\"$METADATA_KEY\":\"$METADATA_VALUE\"}" | jq -c .)

updated=$(az apic api update \
    -g $RESOURCE_GROUP \
    -s $SERVICE_NAME \
    --api-id $API_ID \
    --custom-properties $CUSTOM_PROPERTIES)
