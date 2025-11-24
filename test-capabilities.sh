#!/bin/bash
# Скрипт для проверки capabilities после установки

echo "=========================================="
echo "  Проверка установки Happ Desktop"
echo "=========================================="
echo ""

# Проверка установки пакета
if pacman -Q happ-desktop &>/dev/null; then
    echo "✓ Пакет happ-desktop установлен"
    VERSION=$(pacman -Q happ-desktop | awk '{print $2}')
    echo "  Версия: $VERSION"
else
    echo "✗ Пакет happ-desktop НЕ установлен"
    exit 1
fi

echo ""
echo "=========================================="
echo "  Проверка файлов"
echo "=========================================="
echo ""

# Проверка основных файлов
FILES=(
    "/opt/happ/Happ:GUI приложение"
    "/opt/happ/tun/sing-box:VPN ядро sing-box"
    "/opt/happ/core/xray:VPN ядро xray"
    "/opt/happ/antifilter/antifilter:Antifilter"
    "/usr/bin/happ:Wrapper скрипт"
    "/usr/share/applications/happ.desktop:Desktop файл"
    "/usr/share/pixmaps/happ.png:Иконка"
)

for entry in "${FILES[@]}"; do
    FILE="${entry%%:*}"
    DESC="${entry##*:}"
    if [ -e "$FILE" ]; then
        echo "✓ $DESC: $FILE"
    else
        echo "✗ $DESC: $FILE НЕ НАЙДЕН"
    fi
done

echo ""
echo "=========================================="
echo "  Проверка Capabilities"
echo "=========================================="
echo ""

# Проверка capabilities для sing-box
echo "sing-box:"
if [ -f /opt/happ/tun/sing-box ]; then
    CAP=$(getcap /opt/happ/tun/sing-box 2>/dev/null)
    if [[ "$CAP" == *"cap_net_admin"* ]]; then
        echo "  ✓ $CAP"
    else
        echo "  ✗ cap_net_admin НЕ установлен"
        echo "  Текущее значение: ${CAP:-нет}"
    fi
else
    echo "  ✗ Файл не найден"
fi

echo ""

# Проверка capabilities для xray
echo "xray:"
if [ -f /opt/happ/core/xray ]; then
    CAP=$(getcap /opt/happ/core/xray 2>/dev/null)
    if [[ "$CAP" == *"cap_net_admin"* ]]; then
        echo "  ✓ $CAP"
    else
        echo "  ✗ cap_net_admin НЕ установлен"
        echo "  Текущее значение: ${CAP:-нет}"
    fi
else
    echo "  ✗ Файл не найден"
fi

echo ""
echo "=========================================="
echo "  Проверка TUN модуля"
echo "=========================================="
echo ""

if lsmod | grep -q "^tun"; then
    echo "✓ Модуль tun загружен"
else
    echo "✗ Модуль tun НЕ загружен"
    echo "  Загрузите командой: sudo modprobe tun"
fi

echo ""
echo "=========================================="
echo "  Проверка библиотек Qt5"
echo "=========================================="
echo ""

if ldd /opt/happ/Happ 2>/dev/null | grep -q "not found"; then
    echo "✗ Обнаружены отсутствующие библиотеки:"
    ldd /opt/happ/Happ | grep "not found"
else
    echo "✓ Все необходимые библиотеки найдены"
fi

echo ""
echo "=========================================="
echo "  Итого"
echo "=========================================="
echo ""

if [ -f /opt/happ/Happ ] && \
   getcap /opt/happ/tun/sing-box 2>/dev/null | grep -q "cap_net_admin" && \
   getcap /opt/happ/core/xray 2>/dev/null | grep -q "cap_net_admin"; then
    echo "✓ Happ Desktop готов к работе!"
    echo ""
    echo "Запуск:"
    echo "  happ                    # из терминала"
    echo "  Меню → Utility → Happ   # из меню приложений"
else
    echo "✗ Обнаружены проблемы при установке"
    echo ""
    echo "Попробуйте переустановить пакет:"
    echo "  sudo pacman -R happ-desktop"
    echo "  makepkg -si --cleanbuild"
fi

echo ""
