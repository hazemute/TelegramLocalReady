# Локальный Telegram / MyTelegram из этого проекта

Это не отдельный kit. Всё настроено прямо в `Telegram-master`:

- Android-клиент находится в корне проекта (`TMessagesProj*`).
- Self-hosted сервер находится в `mytelegram-dev`.
- MongoDB, Redis, RabbitMQ и MinIO запускаются локально через Docker Desktop.
- Клиент перенаправлен с публичных Telegram DC на твой сервер.
- RSA public key клиента соответствует `mytelegram-dev/source/src/MyTelegram.AuthServer/private.pkcs8.key`.
- Open-source сервер зафиксирован на API layer 224 / образах `0.40.224.502`.
- Код входа для тестовой установки: `22222`.

## 1. Что поставить на Windows

Нужно:

1. Docker Desktop с WSL2 backend.
2. Android Studio 2025.1.4.
3. Через SDK Manager:
   - Android SDK 36;
   - Build Tools 36.0.0;
   - Android NDK `27.2.12479018`;
   - CMake `3.22.1`.

Java отдельно обычно не нужна: можно использовать JBR из Android Studio.

## 2. Запуск сервера

Открой корень проекта и запусти **от имени администратора**:

```bat
START_SERVER.cmd
```

Скрипт сам:

- найдёт основной IPv4 этого ПК;
- пропишет его в Android-клиент;
- пропишет этот же IP в `App__DcOptions` сервера;
- один раз заменит дефолтные пароли/ключи локальными случайными значениями;
- скачает pinned Docker images;
- поднимет MongoDB, Redis, RabbitMQ, MinIO и MyTelegram;
- откроет входящие MTProto TCP-порты в Windows Firewall.

Если сервер должен быть доступен через конкретный LAN/VPN IP, укажи его явно:

```bat
START_SERVER.cmd 192.168.1.50
```

или, например, IP виртуальной приватной сети:

```bat
START_SERVER.cmd 26.x.x.x
```

Важно: этот IP должен быть реально назначен твоему ПК и быть доступен устройствам друзей.

## 3. Проверка сервера

```bat
DOCTOR.cmd
```

Проверяются контейнеры и порты:

- MTProto: `20443`, `20543`, `20643`, `20644`, `30443`, `30444`;
- MongoDB: `127.0.0.1:27017`;
- Redis: `127.0.0.1:6379`;
- MinIO: `127.0.0.1:9000`;
- RabbitMQ management: `127.0.0.1:15672`.

Логи:

```bat
SERVER_LOGS.cmd
```

Остановить сервер:

```bat
STOP_SERVER.cmd
```

Данные сохраняются в:

```text
mytelegram-dev/docker/compose/data/
```

То есть `STOP_SERVER.cmd` базу не удаляет.

## 4. Сборка Android-клиента

После успешного запуска сервера:

```bat
BUILD_CLIENT.cmd
```

Если используешь конкретный IP, можно передать его ещё раз:

```bat
BUILD_CLIENT.cmd 192.168.1.50
```

Готовый APK будет скопирован сюда:

```text
dist/MyTelegram-local.apk
```

APK ставишь на свой Android и на устройства друзей.

## 5. Вход

Вводишь любой тестовый номер, который сервер принимает по формату номера. Код подтверждения:

```text
22222
```

Аккаунты и сообщения хранятся в твоём локальном MongoDB, файлы — через локальный MinIO.

## 6. Что доступно в OSS-сервере

Базовый open-source MyTelegram рассчитан прежде всего на:

- личные чаты;
- supergroups;
- channels.

Корневой Android-клиент в архиве новее сервера и изначально был на layer 229. Для этой сборки он объявляет layer 224, чтобы соответствовать open-source backend. Базовые чаты должны идти через этот backend, но функции Telegram, появившиеся после layer 224 или относящиеся к Pro-функциям MyTelegram, могут не работать.

## 7. Где менять IP вручную

Обычно не нужно. `SETUP_LOCAL.cmd` делает это сам.

Главная клиентская настройка:

```text
TMessagesProj/jni/tgnet/LocalServerConfig.h
```

Серверные адреса:

```text
mytelegram-dev/docker/compose/.env
```

## 8. Локальные админ-сервисы

MongoDB доступен только с этого ПК:

```text
mongodb://127.0.0.1:27017
```

Можно открыть его через MongoDB Compass.

RabbitMQ management:

```text
http://127.0.0.1:15672
```

MinIO console:

```text
http://127.0.0.1:9001
```

Логины/пароли после первого `START_SERVER.cmd` лежат в:

```text
mytelegram-dev/docker/compose/.env
```

## 9. Важное про публичный интернет

Конфигурация с фиксированным кодом `22222` сделана только для обучения/закрытой компании. Не пробрасывай эти порты напрямую на публичный интернет с таким кодом входа. Для друзей проще использовать одну LAN или приватную VPN-сеть.
