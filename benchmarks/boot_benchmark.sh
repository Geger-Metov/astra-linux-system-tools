#!/bin/bash


echo "=== ТЕСТИРОВАНИЕ ВРЕМЕНИ ЗАГРУЗКИ И ОТКЛИКА ==="


echo "1. АНАЛИЗ ВРЕМЕНИ ЗАГРУЗКИ СИСТЕМЫ:"
systemd-analyze time > boot_time.log
systemd-analyze critical-chain >> boot_time.log
cat boot_time.log
echo ""


echo "2. ВРЕМЯ ИНИЦИАЛИЗАЦИИ СЕРВИСОВ:"
systemd-analyze blame | head -10 > service_times.log
cat service_times.log
echo ""


echo "3. ТЕСТ ОТКЛИКА СИСТЕМЫ:"
for i in {1..3}; do
	echo "Итерация $i"
	{ time ls -la /usr/bin > /dev/null 2>&1; } 2> response_$i.log
	grep "real" response_$i.log
done
echo ""


echo "4. ТЕСТ ЗАПУСКА ПРИЛОЖЕНИЙ:"
echo "Проверка доступности базовых приложений..."
which firefox > /dev/null 2>&1 && { time firefox --version > /dev/null 2>&1; } 2> firefox_time.log && echo "Firefox: $(grep 'real' firefox_time.log)" || echo "Firefox не установлен"


which libreoffice > /dev/null 2>&1 && { time libreoffice --version > /dev/null 2>&1; } 2> libreoffice_time.log && echo "LibreOffice: $(grep 'real' libreoffice_time.log)" || echo "LibreOffice не установлен"
echo ""


echo "=== ТЕСТИРОВАНИЕ ЗАГРУЗКИ ЗАВЕРШЕНО ==="
