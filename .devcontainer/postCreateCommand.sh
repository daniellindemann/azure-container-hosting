#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
# Treat unset variables as an error and exit
# Return the exit status of the last command in a pipeline that failed
set -euo pipefail

script_dir=$(dirname "$0")

# ensure permissions in home directory
sudo chown -R "$(whoami)" "$HOME"

# install tools
IS_ARM=$(if [[ $(uname -m) == 'aarch64' || $(uname -m) == "arm64" ]]; then echo true; else echo false; fi)
# https://github.com/derailed/k9s/releases/download/v0.50.12/k9s_Linux_arm64.tar.gz
# https://github.com/derailed/k9s/releases/download/v0.50.12/k9s_Linux_amd64.tar.gz
if ! command -v k9s &> /dev/null; then
    echo "Installing k9s"
    k9s_VERSION_DOWNLOAD_FILE_SUFFIX=$(if [[ $IS_ARM = true ]]; then echo 'Linux_arm64'; else echo 'Linux_amd64'; fi)
    k9s_VERSION=$(
        curl --silent "https://api.github.com/repos/derailed/k9s/releases/latest" | \
            grep '"tag_name":' | \
            sed -E 's/.*"v([^"]+)".*/\1/' \
    ) && curl -L -o k9s.tar.gz "https://github.com/derailed/k9s/releases/download/v${k9s_VERSION}/k9s_${k9s_VERSION_DOWNLOAD_FILE_SUFFIX}.tar.gz" \
    && tar -xvzf ./k9s.tar.gz k9s && sudo mv ./k9s /usr/local/bin && rm ./k9s.tar.gz
    echo "k9s installed"
fi

# update dotnet workloads
sudo dotnet workload update

# install dotnet tools
dotnet tool restore

# restore and build projects
dotnet restore && dotnet build --no-restore

echo "✅ Post-create command completed successfully."
