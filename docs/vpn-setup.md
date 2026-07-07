# VPN Setup — Foxnezia + sing-box 1.10.2

## Стек
- **sing-box 1.10.2** (`/usr/local/bin/sing-box`) — ручная установка, Void пакет удалён
- **Foxnezia подписка** — VLESS + Reality, UUID: `30f19571-6229-42d2-9b2d-07b395ae239b`
- **Прозрачный прокси** — TUN-интерфейс, весь трафик через VPN

## Файлы
| Файл | Описание |
|------|----------|
| `/home/vlad/.config/sing-box/config.json` | Конфиг sing-box (TUN + SOCKS + HTTP inbounds) |
| `/home/vlad/.local/bin/vpn-toggle` | Скрипт управления VPN (on/off/toggle/status/list/connect) |
| `/home/vlad/.local/bin/sing-box-start` | Обёртка для запуска sing-box с `ulimit -n 65536` |
| `/tmp/vpn-status` | Текущий статус: `ON:Имя` / `OFF` / `CONNECTING` / `SEARCH` |
| `/tmp/vpn-server-ip` | IP текущего VPN-сервера |
| `/tmp/vpn-server-name` | Имя текущего VPN-сервера |
| `/tmp/foxnezia-servers.txt` | Кэш списка серверов |
| `/tmp/sing-box.log` | Лог sing-box |
| `/etc/resolv.conf` | DNS (должен быть только `nameserver 192.168.1.1`, без `0.0.0.0`) |

## Восстановление sing-box

```bash
# Удалить текущий
sudo rm /usr/local/bin/sing-box

# Скачать 1.10.2
wget https://github.com/SagerNet/sing-box/releases/download/v1.10.2/sing-box-1.10.2-linux-amd64.tar.gz
tar xzf sing-box-1.10.2-linux-amd64.tar.gz
sudo cp sing-box-1.10.2-linux-amd64/sing-box /usr/local/bin/
sudo chmod +x /usr/local/bin/sing-box
```

## Ключевые параметры конфига sing-box

```json
{
  "inbounds": {
    "tun": {
      "inet4_address": "172.19.0.1/30",
      "auto_route": true,    // ОБЯЗАТЕЛЬНО — иначе TUN не получит IP
      "stack": "system"
    }
  },
  "dns": {
    "servers": [{ "address": "192.168.1.1", "detour": "direct" }]
  },
  "route": {
    "rules": [
      { "ip_is_private": true, "outbound": "direct" },  // Локальная сеть — bypass
      { "protocol": "dns", "outbound": "direct" }        // DNS — bypass
    ]
  }
}
```

**КРИТИЧЕСКИ ВАЖНО:**
- `auto_route: true` — без него TUN не поднимается (sing-box 1.10)
- DNS outbound `direct` — иначе DNS-запросы петляют через TUN
- `resolv.conf` — НЕ должен содержать `nameserver 0.0.0.0` (ломает DNS через TUN)

## Горячие клавиши
| Комбинация | Действие |
|------------|----------|
| `Super+Alt+V` | Toggle VPN on/off |
| `Super+U` → `1-9` | Подключиться к серверу №1-9 |
| `Super+U` → `0` | Выключить VPN |
| `Super+U` → `Escape` | Выйти из режима |

## Команды
```bash
vpn-toggle on              # Включить (случайный сервер)
vpn-toggle off             # Выключить
vpn-toggle toggle          # Переключить
vpn-toggle status          # Статус + IP
vpn-toggle list            # Список Reality-серверов (с номерами)
vpn-toggle connect 5       # Подключить сервер №5
```

## Восстановление DNS
Если VPN не работает, проверь `/etc/resolv.conf`:
```bash
cat /etc/resolv.conf
# Должно быть:
nameserver 1.1.1.1
nameserver 192.168.1.1

# Если есть nameserver 0.0.0.0 — удалить:
sudo sed -i '/nameserver 0.0.0.0/d' /etc/resolv.conf

# Фикс для dhcpcd (чтобы не перезаписывал):
sudo sh -c 'echo "nameserver 1.1.1.1" > /etc/resolv.conf.head'
```

## Диагностика
```bash
# Лог
cat /tmp/sing-box.log

# Статус
cat /tmp/vpn-status

# Маршруты
ip route show

# TUN интерфейс
ip addr show tun0

# Тест прозрачного прокси (без -x)
curl -s https://api.ipify.org

# Тест SOCKS
curl -x socks5h://127.0.0.1:10808 -s https://api.ipify.org

# Ручной запуск sing-box (для отладки)
sudo pkill sing-box
sudo sing-box run -c /home/vlad/.config/sing-box/config.json
```

## Известные проблемы
1. **sing-box 1.13.14** убрал `auto_route/strict_route` из TUN — НЕ устанавливать
2. **`nameserver 0.0.0.0`** в resolv.conf ломает DNS — убрать
3. Некоторые серверы не отвечают — vpn-toggle автоматически пробует другие (до 3 попыток)
4. `ulimit -n` должен быть 65536 (иначе "too many open files")
