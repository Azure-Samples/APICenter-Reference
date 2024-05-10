#!/bin/bash

# This registers API to API Center.

set -e

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

    exit 1
}

RESOURCE_ID=
RESOURCE_GROUP=
SERVICE_NAME=
FILE_LOCATION=
API_MANAGEMENT_ID=
API_VERSION="2024-03-01"

if [[ $# -eq 0 ]]; then
    RESOURCE_ID=
    RESOURCE_GROUP=
    SERVICE_NAME=
    FILE_LOCATION=
    API_MANAGEMENT_ID=
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

        -f | --file-location)
            shift
            FILE_LOCATION="$1"
        ;;

        --api-management-id)
            shift
            API_MANAGEMENT_ID="$1"
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

if [ -z "$RESOURCE_ID" ] && [ -z "$RESOURCE_GROUP" -o -z "$SERVICE_NAME" ] ; then
    echo "'resource-id' must be provided, or both 'resource-group' and 'service-name' must be provided"
    exit 0
fi
if [ -z "$FILE_LOCATION" ] && [ -z "$API_MANAGEMENT_ID" ] ; then
    echo "'file-lcation' must be provided"
    exit 0
fi
if [ -z "$FILE_LOCATION" ] && [[ "$API_MANAGEMENT_ID" != /subscriptions/* ]] ; then
    echo "'api-management-id' must be a valid resource ID"
    exit 0
fi

IFS='/' read -ra SEGMENTS <<< "$RESOURCE_ID"
if [ -z "$RESOURCE_GROUP" ] ; then
    RESOURCE_GROUP=${SEGMENTS[4]}
fi
if [ -z "$SERVICE_NAME" ] ; then
    SERVICE_NAME=${SEGMENTS[8]}
fi

REPOSITORY_ROOT=$(git rev-parse --show-toplevel)

if [ -z "$API_MANAGEMENT_ID" ] ; then
    echo "Registering API from a file: $FILE_LOCATION ..."

    registered=$(az apic api register \
    -g $RESOURCE_GROUP \
    -s $SERVICE_NAME \
    --api-location "$REPOSITORY_ROOT/$FILE_LOCATION")
else
    echo "Registering API from API Management: $API_MANAGEMENT_ID ..."

    registered=$(az apic service import-from-apim \
    -g $RESOURCE_GROUP \
    -s $SERVICE_NAME \
    --source-resource-ids "$API_MANAGEMENT_ID/apis/*")
fi
