## Install additional apt packages
sudo apt-get update && \
    sudo apt upgrade -y && \
    sudo apt-get install -y dos2unix libsecret-1-0 xdg-utils && \
    sudo apt clean -y && \
    sudo rm -rf /var/lib/apt/lists/*

## Configure git
git config --global pull.rebase false
git config --global core.autocrlf input

## Enable local HTTPS for .NET
dotnet dev-certs https --trust

## AZURE BICEP CLI ##
az bicep install

## AZURE FUNCTIONS CORE TOOLS ##
npm i -g azure-functions-core-tools@4 --unsafe-perm true

## Azurite ##
npm install -g azurite

## AZURE STATIC WEB APPS CLI ##
npm i -g @azure/static-web-apps-cli
