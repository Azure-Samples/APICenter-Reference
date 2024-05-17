#!/bin/bash

# This copies client SDK related files to the web app project.

set -e

function usage() {
    cat <<USAGE

    Usage: $0 [-s|--source] [-t|--target] [-h|--help]

    Options:
        -s|--source:  Source path
        -t|--target:  Target path

        -h|--help:    Show this message.

USAGE

    exit 1
}

SOURCE="dotnet/src/WebApp.Extensions/*"
TARGET="dotnet/src/WebApp"

if [[ $# -eq 0 ]]; then
    SOURCE="dotnet/src/WebApp.Extensions/*"
    TARGET="dotnet/src/WebApp"
fi

while [[ "$1" != "" ]]; do
    case $1 in
        -s | --source)
            shift
            SOURCE="$1"
        ;;

        -t | --target)
            shift
            TARGET="$1"
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

# Check if both source and target are provided
if [ -z "$SOURCE" ] || [ -z "$TARGET" ]; then
    echo "Both 'Source' and 'Target' must be provided"
    echo ""

    usage
    exit 1
fi

# Get the root of the repository
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)

# Copy files
cp -R "$REPOSITORY_ROOT/$SOURCE" "$REPOSITORY_ROOT/$TARGET"
