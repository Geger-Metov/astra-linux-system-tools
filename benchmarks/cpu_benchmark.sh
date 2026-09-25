#!/bin/bash

echo "=== ТЕСТИРОВАНИЕ ПРОИЗВОДИТЕЛЬНОСТИ ПРОЦЕССОРА"

echo "1. ИНФОРМАЦИЯ О ПРОЦЕССОРЕ:"
lscpu | grep -E "(Model name|CPU\(s\)|Thread|Core|Socket)"
echo ""


echo "2. ЗАГРУЗКА ЦП В СОСТОЯНИИ ПОКОЯ:"
mpstat 1 5 | tail -n 5 > cpu_idle.log
cat cpu_idle.log
echo ""


echo "3. ТЕСТ ЦЕЛОЧИСЛЕННЫХ ВЫЧИСЛЕНИЙ:"
sysbench cpu --cpu-max-prime=20000 --threads=1 run > sysbench_cpu.log 2>&1
grep -E "(total time|events per second)" sysbench_cpu.log
echo ""


echo "4. МНОГОПОТОЧНАЯ ПРОИЗВОДИТЕЛЬНОСТЬ:"
for threads in 1 2 4; do
	echo "Потоков: $threads"
	sysbench cpu --cpu-max-prime=10000 --threads=$threads run 2>/dev/null | grep "events per second"
done
echo ""


echo "5. КОМПЛЕКСНАЯ НАГРУЗКА:"
stress-ng --cpu 4 --cpu-method matrixprod --timeout 30s --metrics-brief > stress_test.log 2>&1
grep -E "(stress-ng|CPU)" stress_test.log
echo ""


echo "=== ТЕСТИРОВАНИЕ ПРОЦЕССОРА ЗАВЕРШЕНО ==="
