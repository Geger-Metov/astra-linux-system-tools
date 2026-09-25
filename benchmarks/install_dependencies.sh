#!/bin/bash


echo "=== УСТАНОВКА НЕОБХОДИМЫХ УТИЛИТ ДЛЯ ТЕСТИРОВАНИЯ ==="


# обновление списка пакетов
sudo apt-get update > /dev/null 2>&1


# Установка утилит для мониторинга
sudo apt-get install -y htop sysstat procps > /dev/null 2>&1
echo "Утилиты мониторинга установлены"


# Установка утилит тестирования диска
sudo apt-get install -y hdparm fio > /dev/null 2>&1
echo "Утилиты тестирования диска установлены"


# Установка сетевых утилит
sudo apt-get install -y iperf3 speedtest-cli iproute2 > /dev/null 2>&1
echo "Сетевые утилиты установлены"


# Установка бенчмарков
sudo apt-get install stress-ng sysbench > /dev/null 2>&1
echo "Бенчмарки установлены"


# Установка дополнительных утилит
sudo apt-get install -y bc > /dev/null 2>&1
echo "Дополнительные утилиты установлены"


echo "=== ВСЕ ЗАВИСИМОСТИ УСТАНОВЛЕНЫ ==="
