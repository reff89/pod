#!/bin/bash

# Полный скрипт для запуска ComfyUI с расширенными функциями, устраняющий предыдущие проблемы.
# Включает в себя автоматическое добавление SSH-ключей, установку всех зависимостей и запуск сервера.

# Настройки переменных
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAjbmKl/xki999HbBAXGmMbDghbM05dAa/ywpzUiBFa3 reffex89@gmail.com"
DEFAULT_WORKFLOW="https://raw.githubusercontent.com/ai-dock/comfyui/main/config/workflows/flux-comfyui-example.json"

APT_PACKAGES=(
    "curl"
    "git"
    "wget"
    "python3"
    "python3-pip"
    "iptables"
)

PIP_PACKAGES=(
    "torch"
    "aiohttp"
    "rich"
    "transformers"
)

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/MushroomFleet/DJZ-Nodes"
    "https://github.com/Gourieff/comfyui-reactor-node"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/crystian/ComfyUI-Crystools"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/giriss/comfy-image-saver"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/WASasquatch/was-node-suite-comfyui"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/melMass/comfy_mtb"
    "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    "https://github.com/sipherxyz/comfyui-art-venture"
    "https://github.com/twri/sdxl_prompt_styler"
    "https://github.com/hylarucoder/comfyui-copilot"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/KoreTeknology/ComfyUI-Universal-Styler"
    "https://github.com/kijai/ComfyUI-MochiWrapper"
    "https://github.com/city96/ComfyUI_ExtraModels"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/CosmicLaca/ComfyUI_Primere_Nodes"
)

function provisioning_start() {
    # Добавление публичного ключа для SSH
    echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys

    # Установка APT-пакетов
    apt-get update
    for pkg in "${APT_PACKAGES[@]}"; do
        apt-get install -y $pkg
    done

    # Установка Python-зависимостей
    for pip_pkg in "${PIP_PACKAGES[@]}"; do
        pip install $pip_pkg
    done

    # Загрузка и установка узлов (nodes)
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="/opt/ComfyUI/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"
        if [[ -d $path ]]; then
            (cd "$path" && git pull)
        else
            git clone "$repo" "$path" --recursive
        fi
        if [[ -e $requirements ]]; then
            pip install -r "$requirements"
        fi
    done

    # Проброс порта для доступа к веб-интерфейсу
    iptables -A INPUT -p tcp --dport 18188 -j ACCEPT

    provisioning_print_end
}

function provisioning_print_end() {
    echo -e "\nПровизия завершена: Веб-интерфейс скоро будет доступен.\n"
}

# Запуск ComfyUI
function start_comfyui() {
    cd /workspace/ComfyUI || exit
    python main.py --listen 0.0.0.0 --port 18188 &
}

# Выполнение провизии и запуск сервера
provisioning_start
start_comfyui
