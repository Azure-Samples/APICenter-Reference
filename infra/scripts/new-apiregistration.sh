#!/bin/bash

# This registers API to API Center.

set -euo pipefail

function usage() {
    cat <<USAGE

    Usage: $0 [--resource-id] [-g|--resource-group] [-s|-n|--service|--name|--service-name] [-f|--file-location] [--api-management-id] [--api-version] [-h|--help]

    Options:
        --resource-id                           Resource ID. It must be provided unless 'resource-group' is provided.
        -g|--resource-group                     Resource group. It must be provided unless 'resource-id' is provided.
        -s|-n|--service|--name|--service-name   API Center instance name. It must be provided unless 'resource-id' is provided.
        -f|--file-location                      File location to register.
        --api-management-id                     API Management resource ID. If provided, 'FileLocation' will be ignored.
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
FILE_LOCATION=
API_MANAGEMENT_ID=
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

        -f | --file-location)
            require_value "$@"
            FILE_LOCATION="$2"
            shift 2
        ;;

        --api-management-id)
            require_value "$@"
            API_MANAGEMENT_ID="$2"
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
if [[ -z "$FILE_LOCATION" && -z "$API_MANAGEMENT_ID" ]]; then
    echo "'file-location' or 'api-management-id' must be provided" >&2
    exit 1
fi
if [[ -n "$API_MANAGEMENT_ID" && "$API_MANAGEMENT_ID" != /subscriptions/* ]]; then
    echo "'api-management-id' must be a valid resource ID" >&2
    exit 1
fi

IFS='/' read -ra SEGMENTS <<< "$RESOURCE_ID"
if [[ -z "$RESOURCE_GROUP" ]]; then
    RESOURCE_GROUP=${SEGMENTS[4]}
fi
if [[ -z "$SERVICE_NAME" ]]; then
    SERVICE_NAME=${SEGMENTS[8]}
fi

REPOSITORY_ROOT=$(git rev-parse --show-toplevel)

if [[ -z "$API_MANAGEMENT_ID" ]]; then
    echo "Registering API from a file: $FILE_LOCATION ..."

    az apic api register \
        -g "$RESOURCE_GROUP" \
        -s "$SERVICE_NAME" \
        --api-location "$REPOSITORY_ROOT/$FILE_LOCATION"
else
    echo "Registering API from API Management: $API_MANAGEMENT_ID ..."

    IFS='/' read -ra SEGMENTS <<< "$API_MANAGEMENT_ID"
    API_IDS_OUTPUT=$(az apim api list \
        -g "${SEGMENTS[4]}" \
        -n "${SEGMENTS[8]}" \
        --query "[].id" \
        --output tsv)

    if [[ -z "$API_IDS_OUTPUT" ]]; then
        echo "No APIs were found in the API Management service." >&2
        exit 1
    fi

    mapfile -t API_IDS <<< "$API_IDS_OUTPUT"

    for API_ID in "${API_IDS[@]}"; do
        az apic service import-from-apim \
            -g "$RESOURCE_GROUP" \
            -s "$SERVICE_NAME" \
            --source-resource-ids "$API_ID"
    done
fi
