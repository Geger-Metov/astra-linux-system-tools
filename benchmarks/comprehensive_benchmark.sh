#!/bin/bash


echo "=== КОМПЛЕКСНОЕ ТЕСТИРОВАНИЕ ASTRA LINUX ==="
echo "Начало: $(date)"
echo ""


chmod +x install_dependencies.sh cpu_benchmark.sh memory_benchmark.sh storage_benchmark.sh network_benchmark.sh boot_benchmark.sh generate_report.sh > /dev/null 2>&1


RESULTS_DIR="benchmark_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"
cd "$RESULTS_DIR"


echo "Установка зависимостей..."
echo ""
echo ""
bash ./install_dependencies.sh


echo "Запуск тестов..."
{
    echo "=== ИНФОРМАЦИЯ О СИСТЕМЕ ==="
    uname -a
    echo ""
    lsb_release -a 2>/dev/null || cat /etc/os-release
    echo ""


    bash ../cpu_benchmark.sh
    bash ../memory_benchmark.sh
    bash ../storage_benchmark.sh
    bash ../network_benchmark.sh
    bash ../boot_benchmark.sh

    echo "=== СВОДНЫЕ РЕЗУЛЬТАТЫ ==="
    echo "Тестирование завершено: $(date)"


    echo ""
    echo "ОСНОВНЫЕ МЕТРИКИ:"
    echo "- Процессор: $(grep 'events per second' sysbench_cpu.log 2>/dev/null | tail -1 awk '{print $NF}' || echo 'N/A')"
    echo "- Память: $(grep 'MiB/sec' memory_speed.log 2>/dev/null | awk '{print $4}' || echo 'N/A')"
    echo "- Диск (чтение): $(grep 'Timing buffered' disk_read.log 2>/dev/null | awk '{print $11}' || echo 'N/A') MB/s"
    echo "- Сеть (ping): $(grep 'rtt' ping_test.log 2>/dev/null | awk -F'/' '{print $5}' || echo 'N/A') ms"
    
} | tee comprehensive_results.log


echo ""
echo "Результаты сохранены в директорию: $RESULTS_DIR"
echo "Основной файл результатов: comprehensive_results.log"
