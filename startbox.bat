#!/bin/bash

# This script will be sourced in init.sh
# Provisioning container environment

# Constants
DEFAULT_WORKFLOW="https://raw.githubusercontent.com/ai-dock/comfyui/main/config/workflows/flux-comfyui-example.json"

APT_PACKAGES=(
    # Add any required apt packages here
)

PIP_PACKAGES=(
    # Add any required pip packages here
)

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/MushroomFleet/DJZ-Nodes"
    "https://github.com/Gourieff/comfyui-reactor-node"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    # Add other nodes as needed...
)

WORKFLOWS=(
    "https://github.com/MushroomFleet/DJZ-Workflows"
)

# Functions to handle package installation and provisioning
function provisioning_start() {
    if [[ ! -d /opt/environments/python ]]; then 
        export MAMBA_BASE=true
    fi
    source /opt/ai-dock/etc/environment.sh
    source /opt/ai-dock/bin/venv-set.sh comfyui

    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_nodes
    provisioning_get_pip_packages
    provisioning_print_end
}

function pip_install() {
    if [[ -z $MAMBA_BASE ]]; then
        "$COMFYUI_VENV_PIP" install --no-cache-dir "$@"
    else
        micromamba run -n comfyui pip install --no-cache-dir "$@"
    fi
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
        sudo apt-get update
        sudo apt-get install -y ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
        pip_install ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="/opt/ComfyUI/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"
        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                printf "Updating node: %s...\n" "${repo}"
                ( cd "$path" && git pull )
                if [[ -e $requirements ]]; then
                   pip_install -r "$requirements"
                fi
            fi
        else
            printf "Downloading node: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive
            if [[ -e $requirements ]]; then
                pip_install -r "${requirements}"
            fi
        fi
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n"
    printf "#                                            #\n"
    printf "#          Provisioning container            #\n"
    printf "#                                            #\n"
    printf "##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete: Web UI will start now\n\n"
}

# Run the provisioning script
provisioning_start

# Starting ComfyUI
cd /opt/ComfyUI
python main.py --listen 0.0.0.0 --port 18188