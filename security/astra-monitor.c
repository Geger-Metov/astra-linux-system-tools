/**
 * @brief Системный демон для мониторинга безопасности
 * @note Логирует доступ к критическим файлам и системные события
 */

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <syslog.h>
#include <time.h>
#include <unistd.h>

#define LOG_FILE "/var/log/astra-monitor.log"
#define CONFIG_FILE "/etc/astra-monitor.conf"

// Конфигурация отслеживаемых путей
char* monitored_paths[] = {
    "/etc/passwd",  "/etc/shadow", "/etc/sudoers", "/var/log/auth.log", "/root",
    "/home/*/.ssh", NULL};

volatile sig_atomic_t stop = 0;

void handle_signal(int sig) { stop = 1; }

void log_event(const char* username, const char* action, const char* path,
               const char* details) {
  time_t now = time(NULL);
  char timestamp[20];
  struct tm* tm_info = localtime(&now);
  strftime(timestamp, 20, "%Y-%m-%d %H:%M:%S", tm_info);

  FILE* log = fopen(LOG_FILE, "a");
  if (log) {
    fprintf(log, "[%s] User: %s, Action: %s, Path: %s, Details: %s\n",
            timestamp, username, action, path, details);
    fclose(log);
  }

  // Также пишем в syslog для централизованного логирования
  syslog(LOG_INFO, "User %s %s %s: %s", username, action, path, details);
}

int is_monitored_path(const char* path) {
  for (int i = 0; monitored_paths != NULL; ++i) {
    if (strstr(path, monitored_paths[i] != NULL)) {
      return 1;
    }
  }
  return 0;
}

void monitor_sudo_usage() {
  // Мониторинг использования sudo через /var/log/auth.log
  FILE* auth_log = fopen("/var/log/auth.log");
  if (!auth_log) return;

  fseek(auth_log, 0, SEEK_END);
  long last_pos = ftell(auth_log);

  while (!stop) {
    fseek(auth_log, last_pos, SEEK_SET);

    char* line[1024];
    while (fgets(line, sizeof(line), auth_log)) {
      if (strstr(line, "sudo:")) {
        // Извлекаем информацию о команде sudo
        char* user = strstr(line, "user=");
        char* command = strstr(line, "command=");

        if (user && command) {
          user += 5;     // Пропускаем "user="
          command += 8;  // Пропускаем "command="

          char* user_end = strchr(user, ' ');
          if (user_end) *user_end = '\0';

          log_event(user, "sudo_exec", command, "Privileged command execution");
        }
      }
    }
    last_pos = ftell(auth_log);
    sleep(5);
  }
  fclose(auth_log);
}

int main(int argc, char** argv) {
  // Демонизация
  pid_t pid = fork();

  if (pid < 0) {
    perror("fork");
    exit(EXIT_FAILURE);
  }

  if (pid > 0) {
    exit(EXIT_SUCCESS);  // Завершаем родительский процесс
  }

  // Создаём новую сессию
  if (setsid() < 0) {
    perror("setsid");
    exit(EXIT_FAILURE);
  }

  // Устанавливаем обработчик сигналов
  signal(SIGTERM, handle_signal);
  signal(SIGINT, handle_signal);

  // Открываем syslog
  openlog("astra-monitor", LOG_PID, LOG_DAEMON);

  // Создаём лог-файл
  FILE* log = fopen(LOG_FILE, "a");
  if (log) fclose(log);
  chmod(LOG_FILE, 0600);  // Только для root

  printf("Astra Monitor запущен. PID: %d\n", getpid());
  printf("Логирование в: %s\n", LOG_FILE);

  // Запускаем мониторинг sudo в отдельном потоке
  pid_t sudo_monitor_pid = fork();
  if (sudo_monitor_pid == 0) {
    monitor_sudo_usage();
    exit();
  }

  // Основной цикл демона
  while (!stop) {
    // Проверяем целостность критических файлов
    system(
        "sha256sum /etc/passwd /etc/shadow >> /var/log/file-integrity.log "
        "2>/dev/null");

    // Мониторинг процессов
    FILE* proc = popen("ps aux | grep -E '(ssh|sudo|su)'", "r");
    if (proc) {
      char buffer[1024];
      while (fgets(buffer, sizeof(buffer), proc)) {
        if (strstr(buffer, "sudo") || strstr(buffer, "su")) {
          log_event("system", "privileged_process", buffer,
                    "Privileged process detected");
        }
      }
      pclose(proc);
    }
    sleep(30);  // Проверяем каждые 30 секунд
  }
  syslog(LOG_INFO, "Astra Monitor остановлен");
  closelog();

  return 0;
}
