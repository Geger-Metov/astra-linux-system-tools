"""
Утилита для просмотра логов безопасности
"""


import sys
import os
import re
from datetime import datetime
from collections import defaultdict


class AuditViewer:
    def __init__(self):
        self.log_files = {
            'monitor': '/var/log/astra-monitor.log',
            'sudo': '/var/log/sudo-audit.log',
            'alerts': '/var/log/sudo-alerts.log',
            'auth': '/var/log/auth.log'
        }


    def display_menu(self):
        print("\n=== Astra Linux Security Audit Viewer ===")
        print("1. Просмотр логов мониторинга")
        print("2. Просмотр логов sudo")
        print("3. Просмотр предупреждений безопасности")
        print("4. Статистика по пользователям")
        print("5. Поиск подозрительной активности")
        print("6. Экспорт отчётов")
        print("0. Выход")


    def view_monitor_logs(self, lines=50):
        # Просмотр логов мониторинга
        if not os.path.exists(self.log_files['monitor']):
            print("Файл логов мониторинга не найден")
            return

        with open(self.log_files['monitor'], 'r') as f:
            logs = f.readlines()[-lines]

        print(f"\nПоследние {len(logs)} записей из логов мониторинга:")
        print("=" * 80)
        for log in logs:
            print(log.strip())


    def analyze_user_activity(self):
        # Анализ активности пользователей
        if not os.path.exists(self.log_files['sudo']):
            print("Файл логов sudo не найден")
            return

        user_stats = defaultdict(int)

        with open(self.log_files['sudo'], 'r') as f:
            for line in f:
                coincidence = re.search(r'USER=(\w+)', line)
                if coincidence:
                    user = coincidence.group(1)
                    user_stats[user] += 1

        print("\nСтатистика использования sudo:")
        print("=" * 80)
        for user, count in sorted(user_stats.items(), 
                                  key = lambda x: x[1], reverse=True):
            print(f"{user}: {count} команд")


    def search_suspicious_activity(self):
        # Поиск подозрительной активности
        patterns = [
            (r'rm -rf', 'Удаление файлов'),
            (r'chmod 777', 'Изменение прав доступа'),
            (r'passwd', 'Изменение пароля'),
            (r'ssh.*@.*', 'SSH подключения'),
            (r'su -', 'Смена пользователя')
        ]
        
        print("\nПоиск подозрительной активности:")
        print("=" * 80)

        for log_file in ['monitor', 'sudo', 'auth']:
            if os.path.exists(self.log_files[log_file]):
                with open(self.log_files[log_file], 'r') as f:
                    for line_num, line in enumerate(f, 1):
                        for pattern, description in patterns:
                            if re.search(pattern, line, re.IGNORECASE):
                                print(f"[{log_file}:{line_num}] {description}: {line.strip()}")
    

    def export_report(self, filename="security_report.txt"):
        # Экспорт отчёта
        with open(filename, 'w') as report:
            report.write("Отчёт по безопасности Astra Linux\n")
            report.write("=" * 50 + "\n")
            report.write(f"Дата генерации: {datetime.now()}\n\n")

            for log_name, log_file in self.log_files.items():
                if os.path.exists(log_file):
                    report.write(f"\n--- Логи {log_name} ---\n")
                    with open(log_file, 'r') as f:
                        # Берём последние 100 строк каждого лога
                        lines = f.readlines()[-100:]
                        report.writelines(lines)

        print(f"Отчёт сохранён в файл: {filename}")


    def run(self):
        while True:
            try:
                choice = input("\nВыберите опцию: ").strip()

                match choice:
                    case 0:
                        print("Выход...")
                        break
                    case 1:
                        self.view_monitor_logs()
                    case 2:
                        self.view_monitor_logs('sudo')
                    case 3:
                        self.view_monitor_logs('alerts')
                    case 4:
                        self.analyze_user_activity()
                    case 5:
                        self.search_suspicious_activity()
                    case 6:
                        self.export_report()
                    case _:
                        print("Неверный выбор")

            except KeyboardInterrupt:
                print("\nВыход...")
                break
            except Exception as e:
                print(f"Ошибка: {e}")


if __name__ == "__main__":
    if os.geteuid() != 0:
        print("Для работы утилиты требуются права root")
        sys.exit(1)

    viewer = AuditViewer()
    viewer.run()
