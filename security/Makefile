CC = gcc
CFLAGS = -Wall -Wextra -O2
TARGET = astra-monitor
SRC = astra-monitor.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

install:
	cp $(TARGET) /usr/local/bin/
	cp astra-monitor.service /etc/systemd/system/
	chmod 755 /usr/local/bin/$(TARGET)
	systemctl daemon-reload
	systemctl enable astra-monitor.service

clean:
	rm -f $(TARGET).o

.PHONY: all install clean
