#!/bin/bash


echo "=== ТЕСТИРОВАНИЕ СЕТЕВОЙ ПРОИЗВОДИТЕЛЬНОСТИ ==="


echo "1. БАЗОВАЯ СЕТЕВАЯ ИНФОРМАЦИЯ:"
ip addr show > network_info.log
ip route | grep default >> network_info.log
cat network_info.log
echo ""


echo "2. ТЕСТ ЗАДЕРЖКИ ДО ШЛЮЗА:"
gateway=$(ip route | grep default | awk '{print $3}')
ping -c 10 $gateway > ping_test.log 2>&1
grep -E "(rtt|packet loss)" ping_test.log
echo ""


echo "3. СКОРОСТЬ ИНТЕРНЕТ-СОЕДИНЕНИЯ:"
speedtest-cli --simple > speedtest.log 2>&1
cat speedtest.log
echo ""


echo "4. АКТИВНЫЕ СЕТЕВЫЕ СОЕДИНЕНИЯ:"
ss -tuln | head -10 > connections.log
echo "Количество установленных соединений: $(ss -t | wc -1)" >> connections.log
cat connections.log
echo ""


echo "5. НАГРУЗОЧНЫЙ ТЕСТ СЕТЕВОГО СТЕКА:"
timeout 10s stess-ng --udp 2 --udp-domain ipv4 > network_stress.log 2>&1
echo "Нагрузочный тест завершен"
echo ""


echo "=== ТЕСТИРОВАНИЕ СЕТИ ЗАВЕРШЕНО ==="
