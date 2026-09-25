/**
 * @brief Обёртка для sudo с расширенным логированием
 * @note Заменяет стандартный sudo и добавляет детальное аудитирование
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#define SUDO_AUDIT_LOG "/var/log/sudo-audit.log"
#define MAX_COMMAND_LEN 4096

void log_sudo_command(const char* user, const char* command,
                      const char* terminal, const char* cwd) {
  time_t now = time(NULL);
  char timestamp[20];
  struct tm* tm_info = localtime(&now);
  strftime(timestamp, 20, "%Y-%m-%d %H:%M:%S", tm_info);

  FILE* log = fopen(SUDO_AUDIT_LOG, "a");
  if (log) {
    fprintf(log, "[%s] USER=%s COMMAND=%s TERMINAL=%s CWD=%s\n", timestamp,
            user, command, terminal, cwd);
    fclose(log);
  }
}

int main(int argc, char** argv) {
  if (argc < 2) {
    // Вызываем оригинальный sudo с теми же аргументами
    execvp("/usr/bin/sudo.orig", argv);
    perror("execvp");
    return 1;
  }

  // Получаем информацию о пользователе
  uid_t uid = getuid();
  struct passwd* pw = getpwuid(uid);
  const char* username = pw ? pw->pw_name : "unknown";

  // Получаем текущий рабочий каталог
  char cwd[1024];
  if (!getcwd(cwd, sizeof(cwd))) {
    strcpy(cwd, "unknown");
  }

  // Получаем терминал
  char* terminal = getenv("TERM");
  if (!terminal) terminal = "unknown";

  // Формируем полную команду
  char full_command[MAX_COMMAND_LEN] = "";
  for (int i = 1; i < argc; ++i) {
    strcat(full_command, argv[i]);
    if (i < argc - 1) strcat(full_command, " ");
  }

  // Логируем команду
  log_sudo_command(username, full_command, terminal, cwd);

  // Проверяем подозрительные команды
  const char* suspicious_patterns[] = {"rm - rf /", "chmod 777", "passwd root",
                                       "dd if=",    "mkfs",      NULL};

  for (int i = 0; suspicious_patterns[i] != NULL; ++i) {
    if (strstr(full_command, suspicious_patterns[i])) {
      // Дополнительное логирование для опасных команд
      FILE* alert = fopen("/var/log/sudo-alerts.log", "a");
      if (alert) {
        fprintf(alert, "ALERT: User %s attempted dangerous command: %s\n",
                username, full_command);
        fclose(alert);
      }
      break;
    }
  }
  // Вызываем оригинальный sudo
  execvp("/usr/bin/sudo.orig", argv);

  // Если execvp вернул ошибку
  perror("execvp");
  return 1;
}
