# Maintainer: Mazix 
# Telegram: @xizam
pkgname=happ-desktop
pkgver=1.0.2
pkgrel=4
pkgdesc="Happ VPN Desktop Client with TUN interface support (native installation)"
arch=('x86_64')
url="https://github.com/mazixs/happ-desktop-aur"
license=('unknown')
depends=(
    'qt5-base'
    'qt5-svg'
    'qt5-declarative'
    'qt5-graphicaleffects'
    'qt5-quickcontrols2'
    'openssl'
    'libcap'
)
provides=("${pkgname}")
conflicts=("${pkgname}")
install="${pkgname}.install"
source=("Happ.linux.x86.AppImage::file://${PWD}/Happ.linux.x86.AppImage")
sha256sums=('0b0209d918b69c3c70cb1e62098cba2c409d45a59383510248b348277d6bf440')
noextract=("Happ.linux.x86.AppImage")

prepare() {
    cd "${srcdir}"
    
    # Распаковка AppImage
    chmod +x Happ.linux.x86.AppImage
    ./Happ.linux.x86.AppImage --appimage-extract > /dev/null
}

package() {
    cd "${srcdir}/squashfs-root"
    
    # 1. Подготовка директорий
    install -d "${pkgdir}/opt/happ"
    install -d "${pkgdir}/usr/bin"
    install -d "${pkgdir}/usr/share/applications"
    install -d "${pkgdir}/usr/share/pixmaps"
    
    # 2. Массовое копирование ресурсов (bin, lib, plugins, qml, translations)
    # Копируем все нужные папки рекурсивно, сохраняя структуру
    cp -r usr/bin "${pkgdir}/opt/happ/"
    cp -r usr/lib "${pkgdir}/opt/happ/"
    cp -r usr/plugins "${pkgdir}/opt/happ/"
    cp -r usr/qml "${pkgdir}/opt/happ/"
    cp -r usr/translations "${pkgdir}/opt/happ/"
    
    # Исправление прав доступа для исполняемых файлов
    chmod 755 "${pkgdir}/opt/happ/bin/Happ"
    chmod 755 "${pkgdir}/opt/happ/bin/tun/sing-box"
    chmod 755 "${pkgdir}/opt/happ/bin/core/xray"
    chmod 755 "${pkgdir}/opt/happ/bin/antifilter/antifilter"

    # 3. WORKAROUND: Конфликт QtGraphicalEffects
    # Bundled библиотека конфликтует с системным окружением Arch Linux.
    # Заменяем её на системную (требует зависимости qt5-graphicaleffects).
    msg2 "Applying QtGraphicalEffects workaround..."
    rm -f "${pkgdir}/opt/happ/qml/QtGraphicalEffects/private/libqtgraphicaleffectsprivate.so"
    install -Dm755 /usr/lib/qt/qml/QtGraphicalEffects/private/libqtgraphicaleffectsprivate.so \
        "${pkgdir}/opt/happ/qml/QtGraphicalEffects/private/libqtgraphicaleffectsprivate.so"
    
    # 4. Установка qt.conf (если он нужен для переопределения путей внутри бинарника)
    # Обычно лежит в usr/bin/qt.conf в AppImage
    if [ -f usr/bin/qt.conf ]; then
        install -Dm644 usr/bin/qt.conf "${pkgdir}/opt/happ/bin/qt.conf"
    fi

    # 5. Интеграция (Desktop файл и иконка)
    # Ищем иконку и desktop файл в корне squashfs-root
    install -Dm644 happ.png "${pkgdir}/usr/share/pixmaps/happ.png"
    install -Dm644 Happ.desktop "${pkgdir}/usr/share/applications/happ.desktop"
    
    # Исправление путей в desktop файле
    # ВАЖНО: Запускаем через wrapper /usr/bin/happ, а не напрямую!
    # Удаляем %f, так как VPN клиент вряд ли открывает файлы через аргументы
    sed -i 's|^Exec=.*|Exec=/usr/bin/happ|' "${pkgdir}/usr/share/applications/happ.desktop"
    sed -i 's|^Icon=.*|Icon=happ|' "${pkgdir}/usr/share/applications/happ.desktop"
    
    # Добавляем/Исправляем StartupWMClass для корректной работы иконки в Wayland/Gnome
    if grep -q "StartupWMClass" "${pkgdir}/usr/share/applications/happ.desktop"; then
        sed -i 's|^StartupWMClass=.*|StartupWMClass=Happ|' "${pkgdir}/usr/share/applications/happ.desktop"
    else
        echo "StartupWMClass=Happ" >> "${pkgdir}/usr/share/applications/happ.desktop"
    fi
    
    # 6. Создание wrapper скрипта
    # Настраивает LD_LIBRARY_PATH и пути к QML/плагинам перед запуском
    cat > "${pkgdir}/usr/bin/happ" <<'EOF'
#!/bin/bash
# Используем bundled Qt библиотеки + фикс QtGraphicalEffects
export LD_LIBRARY_PATH="/opt/happ/lib:${LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="/opt/happ/plugins:${QT_PLUGIN_PATH}"
# Используем ТОЛЬКО bundled QML, системный путь НЕ добавляем (конфликт Qt версий)
export QML2_IMPORT_PATH="/opt/happ/qml:${QML2_IMPORT_PATH}"

# ПРИНУДИТЕЛЬНО используем xcb (X11) backend.
# Это предотвращает краши на Wayland, если в AppImage нет wayland-плагинов,
# и решает проблемы с декорированием окон.
export QT_QPA_PLATFORM=xcb

exec /opt/happ/bin/Happ "$@"
EOF
    chmod +x "${pkgdir}/usr/bin/happ"
}
