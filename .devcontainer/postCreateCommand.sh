#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
# Treat unset variables as an error and exit
# Return the exit status of the last command in a pipeline that failed
set -euo pipefail

script_dir=$(dirname "$0")

# ensure permissions in home directory
sudo chown -R "$(whoami)" "$HOME"

# update dotnet workloads
sudo dotnet workload update

# install dotnet tools
dotnet tool restore

# restore and build projects
dotnet restore && dotnet build --no-restore

echo "✅ Post-create command completed successfully."
