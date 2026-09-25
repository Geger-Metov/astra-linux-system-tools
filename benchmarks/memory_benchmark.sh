#!/bin/bash


echo "=== ТЕСТИРОВАНИЕ ПАМЯТИ ==="


echo "1. ИСХОДНОЕ СОСТОЯНИЕ ПАМЯТИ:"
free -h > memory_info.log
cat memory_info.log
echo ""


echo "2. ПОДРОБНАЯ ИНФОРМАЦИЯ О ПАМЯТИ:"
cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable|SwapTotalSwapFree)" > mem_details.log
cat mem_details.log
echo ""


echo "3. АКТИВНОСТЬ ПАМЯТИ В РЕАЛЬНОМ ВРЕМЕНИ:"
vmstat 1 5 > vmstat.log
cat vmstat.log
echo ""


echo "4. ПРОПУСКНАЯ СПОСОБНОСТЬ ПАМЯТИ:"
sysbench memory --memory-total-size=2G --memory-oper=write run > memory_speed.log 2>&1
grep -E "(Total operations|transferred|MiB/sec)" memory_speed.log
echo ""


echo "5. НАГРУЗОСНЫЙ ТЕСТ ПАМЯТИ:"
stress-ng --vm 2 --vm-bytes 1G --timeout 20s --metrics-brief > memory_stress.log 2>&1
echo ""


echo "6. АКТИВНОСТЬ ПОДКАЧКИ:"
grep -E "(pswpin|pswpout)" /proc/vmstat > swap_activity.log 2>&1 || echo "Информация о  swap недоступна"
cat swap_activity.log 2>/dev/null || true
echo ""


echo "=== ТЕСТИРОВАНИЕ ПАМЯТИ ЗАВЕРШЕНО ==="
