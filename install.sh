#!/bin/bash

# Parse arguments
INCLUDE_GPG=false
VAULT="NONE"
set -eu

for arg in "$@"; do
    case $arg in
        --include-gpg)
        INCLUDE_GPG=true
        shift # Remove --include-gpg from processing
        ;;
    esac
    case $arg in
        --vault-1password)
        VAULT="1password"
        shift # Remove --vault from processing
        ;;
    esac
done

source ./common/utils.sh

confirm 

source ./common/common-setup.sh

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
   if [[ -f /etc/lsb-release ]]; then
        source ./ubuntu/ubuntu-setup.sh
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    source ./macos/macos-setup.sh
elif [[ "$OSTYPE" == "cygwin" ]]; then
    echo "Cygwin is not fully supported. Please use native PowerShell scripts."
elif [[ "$OSTYPE" == "msys" ]]; then
    echo "Git Bash is not fully supported. Please use native PowerShell scripts."
elif [[ "$OSTYPE" == "win32" ]]; then
    ./windows/PowerShell/windows-setup.ps1
else
    echo "Unknown OS type: $OSTYPE"
fi


