#!/bin/bash

# Проверка запуска от root
if [ "$(id -u)" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт от root (sudo)"
  exit 1
fi

echo "Включение BBR..."

# Включение BBR в sysctl
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_congestion_control=bbr

# Добавление в /etc/sysctl.conf для постоянного применения
grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf || echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
grep -q "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf || echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

# Применение настроек
sysctl -p

# Проверка, что BBR действительно активен
echo "Проверка статуса TCP алгоритма:"
sysctl net.ipv4.tcp_congestion_control
lsmod | grep bbr

echo "Готово! BBR должен быть включен."
