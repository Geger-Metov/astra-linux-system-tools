# Astra Linux System Tools

Collection of system monitoring, security auditing and performance testing tools for Astra Linux.

The project combines low-level system utilities written in C, a Python-based audit viewer and a set of Bash scripts for system benchmarking.

## Features

### Security monitoring

`astra-monitor` is a background system daemon implemented in C.

It provides:

* monitoring of privileged activity;
* logging of `sudo` usage;
* monitoring of selected system processes;
* integrity checks for critical system files;
* logging to a dedicated file and `syslog`;
* automatic service management through `systemd`.

The daemon is configured as a `systemd` service and is designed to run with elevated privileges.

### Sudo auditing

`secure-sudo` is a wrapper around `sudo` that records privileged command execution.

For each command it can collect:

* user name;
* executed command;
* terminal information;
* current working directory;
* execution timestamp.

The utility also checks commands against a predefined set of suspicious patterns and writes alerts to a separate log.

### Audit viewer

`audit-viewer.py` provides a command-line interface for working with security logs.

Available operations include:

* viewing monitoring logs;
* viewing `sudo` audit logs;
* displaying user activity statistics;
* searching logs for suspicious activity;
* exporting collected data to a report.

### System benchmarking

The `benchmarks` directory contains Bash scripts for testing different system subsystems:

* CPU performance;
* memory usage and throughput;
* storage performance;
* network performance;
* system boot time;
* service initialization;
* application startup time.

The benchmark suite can collect the results into a separate directory and generate a summary report.

## Project structure

```text
.
├── security/
│   ├── astra-monitor.c
│   ├── astra-monitor.service
│   ├── secure-sudo.c
│   ├── audit-viewer.py
│   └── Makefile
│
├── benchmarks/
│   ├── comprehensive_benchmark.sh
│   ├── cpu_benchmark.sh
│   ├── memory_benchmark.sh
│   ├── storage_benchmark.sh
│   ├── network_benchmark.sh
│   ├── boot_benchmark.sh
│   ├── generate_report.sh
│   └── install_dependencies.sh
│
└── README.md
```

## Technologies

* C
* Python
* Bash
* Linux
* systemd
* syslog
* GCC
* GNU Make
* `sysbench`
* `stress-ng`
* `fio`
* `hdparm`
* `sysstat`
* `iperf3`

## Requirements

The tools are designed for Astra Linux or a compatible Debian-based Linux environment.

Depending on the selected component, the following software may be required:

* GCC
* GNU Make
* Python 3
* systemd
* `sysstat`
* `sysbench`
* `stress-ng`
* `hdparm`
* `fio`
* `iperf3`
* `speedtest-cli`

Some utilities operate on system files, system logs and privileged processes and therefore require root privileges.

## Building

Build the security monitoring component with:

```bash
cd security
make
```

This produces the `astra-monitor` executable.

## Installing the monitor

The Makefile provides an installation target:

```bash
cd security
sudo make install
```

The installation places the executable in:

```text
/usr/local/bin/astra-monitor
```

and installs the systemd unit:

```text
/etc/systemd/system/astra-monitor.service
```

After installation, the service can be managed with:

```bash
sudo systemctl start astra-monitor
sudo systemctl status astra-monitor
```

To enable automatic startup:

```bash
sudo systemctl enable astra-monitor
```

## Running the audit viewer

The audit viewer is intended to be launched with elevated privileges:

```bash
sudo python3 security/audit-viewer.py
```

The application provides an interactive command-line menu for examining security logs and generating reports.

## Running benchmarks

The complete benchmark suite can be started with:

```bash
cd benchmarks
sudo bash comprehensive_benchmark.sh
```

Individual benchmark scripts can also be executed separately:

```bash
bash cpu_benchmark.sh
bash memory_benchmark.sh
bash storage_benchmark.sh
bash network_benchmark.sh
bash boot_benchmark.sh
```

Benchmark results are written to log files and generated result directories.

## Logging

The monitoring components use several system log locations, including:

```text
/var/log/astra-monitor.log
/var/log/sudo-audit.log
/var/log/sudo-alerts.log
/var/log/auth.log
/var/log/file-integrity.log
```

The exact availability of these paths depends on the target Linux configuration and logging subsystem.

## Environment-specific considerations

The project interacts directly with the operating system and therefore depends on the target environment.

In particular, some scripts and utilities assume:

* a Debian-based package manager (`apt`);
* `systemd`;
* standard Linux system paths;
* access to privileged system logs;
* availability of specific benchmark utilities;
* a compatible storage device configuration.

For this reason, individual scripts may require configuration changes when running on a different distribution or hardware environment.

## Scope

The project focuses on practical system-level programming and administration tasks:

* interaction with Linux processes and system resources;
* background service development;
* system logging;
* security event auditing;
* shell automation;
* performance measurement and benchmarking;
* integration with `systemd`.
