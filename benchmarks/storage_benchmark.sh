#!/bin/bash


echo "=== ТЕСТИРОВАНИЕ ДИСКОВЫХ ПОДСИСТЕМ ==="


echo "1. ИНФОРМАЦИЯ О СИСТЕМЕ ХРАНЕНИЯ:"
lsblk > disk_info.log
df -h >> disk_info.log
cat disk_info.log
echo ""


echo "2. ИНФОРМАЦИЯ О СИСТЕМЕ ХРАНЕНИЯ:"
sudo hdparm -T /dev/sda > disk_cache.log 2>&1
cat disk_cache.log
echo ""


echo "3. ТЕСТ ПРЯМОГО ЧТЕНИЯ С ДИСКА:"
sudo hdparm -t /dev/sda > disk_read.log 2>&1
cat disk_read.log
echo ""


echo "4. ПОСЛЕДОВАТЕЛЬНЫЕ ОПЕРАЦИИ:"
echo "Тест записи..."
dd if=/dev/zero of=/tmp/testfile bs=1G count=1 oflag=direct 2> write_speed.log
echo "Тест чтения..."
dd if=/tmp/testfile of=/dev/null bs=1G count=1 2> read_speed.log


grep "copied" write_speed.log
grep "copied" read_speed.log
echo ""


echo "5. КОМПЛЕКСНОЕ ТЕСТИРОВАНИЕ:"
cat > /tmp/fio_test.fio << 'EOF'
[global]
ioengine=libaio
direct=1
size=512M
runtime=30
directory=/tmp

[seq-read]
bs=1M
rw=read
stonewall

[seq-write]
bs=1M
rw=write
stonewall

[rand-read]
bs=4k
rw=randread
stonewall

[rand-write]
bs=4k
rw=randwrite
stonewall
EOF


fio /tmp/fio_test.fio --output-format=normal > fio_results.log 2>&1
grep -A5 "Run status" fio_results.log
echo ""


echo "6. МОНИТОРИНГ ДИСКОВЫХ ОПЕРАЦИЙ:"
iostat -x 1 3 > iostat.log
cat iostat.log
echo ""


rm -f /tmp/testfile /tmp/fio_test.fio


echo "=== ТЕСТИРОВАНИЕ ДИСКА ЗАВЕРШЕНО ==="
