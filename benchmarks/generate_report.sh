#!/bin/bash


echo "Создание сводного отчёта о производительности..."


CPU_SCORE=$(grep "events per second" sysbench_cpu.log 2>/dev/null | awk '{print $NF}' | tail -1)
MEMORY_SPEED=$(grep "MiB/sec" memory_speed.log 2>/dev/null | awk '{print $4}')
DISK_READ=$(grep "Timing buffered" disk_read.log 2>/dev/null | awk '{print $11}')
NETWORK_LATENCY=$(grep "rtt" ping_test.log 2>/dev/null | awk -F'/' '{print $5}')
BOOT_TIME=$(systemd-analyze time 2>/dev/null | grep "=" | awk '{print $4}' | sed 's/s//')


cat > perfomance_report.md << EOF
# Отчёт о производительности Astra Linux


## Основные показатели


- **Производительность CPU:** $CPU_SCORE events/sec
- **Скорость операций с памятью:** $MEMORY_SPEED MiB/sec
- **Скорость чтения с диска:** $DISK_READ MB/s
- **Сетевая задержка:** $NETWORK_LATENCY ms
- **Время загрузки:** $BOOT_TIME s

EOF


echo "Отчёт создан: perfomance_report.md"
