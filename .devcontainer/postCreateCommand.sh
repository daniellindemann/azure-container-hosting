#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
# Treat unset variables as an error and exit
# Return the exit status of the last command in a pipeline that failed
set -euo pipefail

script_dir=$(dirname "$0")

# install dotnet tools
dotnet tool restore

# restore and build projects
dotnet restore && dotnet build --no-restore

echo "✅ Post-create command completed successfully."
