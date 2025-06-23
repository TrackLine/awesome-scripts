#!/bin/sh
# setup-zerotier.sh
# Конфигурирует ZeroTier на OpenWrt и перезапускает службу.

set -e  # останавливаемся при любой ошибке

# 0. (необязательно) ставим пакет, если его ещё нет
if ! opkg list-installed | grep -q '^zerotier'; then
    echo "[INFO] Устанавливаем пакет zerotier..."
    opkg update
    opkg install zerotier
fi

# 1. Настраиваем uci
uci batch <<'EOF'
set zerotier.global.enabled='1'
delete zerotier.earth
set zerotier.mynet='network'
set zerotier.mynet.id='8a4614eac456f0b5'
commit zerotier
EOF

# 2. Перезапускаем службу
/etc/init.d/zerotier restart

echo "[INFO] Готово! ZeroTier активирован и подключён к сети."
