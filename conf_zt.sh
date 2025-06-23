#!/bin/sh
# setup-zerotier-interface.sh
# Скрипт для настройки интерфейса ZeroTier и фаервола на OpenWrt

set -e

ZTNID="8a4614eac456f0b5"  # Укажите ваш Network ID

# Ждём появления интерфейса (вдруг роутер только что загрузился)
echo "[INFO] Ждём появления интерфейса ZeroTier..."
RETRIES=20
while [ $RETRIES -gt 0 ]; do
    IFNAME=$(zerotier-cli get "$ZTNID" portDeviceName 2>/dev/null || true)
    if echo "$IFNAME" | grep -q '^zt'; then
        echo "[INFO] Найден интерфейс: $IFNAME"
        break
    fi
    sleep 2
    RETRIES=$((RETRIES - 1))
done

if [ -z "$IFNAME" ]; then
    echo "[ERROR] Интерфейс ZeroTier не найден. Проверьте подключение к сети $ZTNID."
    exit 1
fi

# Настройка сетевого интерфейса
uci -q delete network.ZeroTier
uci set network.ZeroTier=interface
uci set network.ZeroTier.proto='none'
uci set network.ZeroTier.device="$IFNAME"

# Настройка зоны фаервола
uci add firewall zone
uci set firewall.@zone[-1].name='vpn'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='ACCEPT'
uci set firewall.@zone[-1].masq='1'
uci add_list firewall.@zone[-1].network='ZeroTier'

# Направления маршрутизации между зонами
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='vpn'
uci set firewall.@forwarding[-1].dest='lan'

uci add firewall forwarding
uci set firewall.@forwarding[-1].src='vpn'
uci set firewall.@forwarding[-1].dest='wan'

uci add firewall forwarding
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='vpn'

# Применение настроек
uci commit
echo "[INFO] Настройки применены. Перезагружаемся..."

reboot
