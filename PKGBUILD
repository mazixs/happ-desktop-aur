# Maintainer: Mazix 
# Telegram: @xizam
pkgname=happ-desktop
pkgver=1.0.2
pkgrel=3
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
install="${pkgname}.install"
source=("Happ.linux.x86.AppImage::file://${PWD}/Happ.linux.x86.AppImage")
sha256sums=('SKIP')
noextract=("Happ.linux.x86.AppImage")

prepare() {
    cd "${srcdir}"
    
    # Распаковка AppImage
    chmod +x Happ.linux.x86.AppImage
    ./Happ.linux.x86.AppImage --appimage-extract > /dev/null
}

package() {
    cd "${srcdir}/squashfs-root"
    
    # Сохраняем структуру как в AppImage: bin/Happ + bin/tun/ + bin/core/
    # Это необходимо для правильного поиска VPN ядер приложением
    
    # Установка основного исполняемого файла
    install -Dm755 usr/bin/Happ "${pkgdir}/opt/happ/bin/Happ"
    
    # Установка VPN ядер (sing-box и xray) - им нужны capabilities
    install -Dm755 usr/bin/tun/sing-box "${pkgdir}/opt/happ/bin/tun/sing-box"
    install -Dm644 usr/bin/tun/LICENSE "${pkgdir}/opt/happ/bin/tun/LICENSE"
    
    install -Dm755 usr/bin/core/xray "${pkgdir}/opt/happ/bin/core/xray"
    install -Dm644 usr/bin/core/LICENSE "${pkgdir}/opt/happ/bin/core/LICENSE"
    install -Dm644 usr/bin/core/README.md "${pkgdir}/opt/happ/bin/core/README.md"
    install -Dm644 usr/bin/core/geoip.dat "${pkgdir}/opt/happ/bin/core/geoip.dat"
    install -Dm644 usr/bin/core/geosite.dat "${pkgdir}/opt/happ/bin/core/geosite.dat"
    
    # Установка antifilter
    install -Dm755 usr/bin/antifilter/antifilter "${pkgdir}/opt/happ/bin/antifilter/antifilter"
    
    # Установка qt.conf
    install -Dm644 usr/bin/qt.conf "${pkgdir}/opt/happ/bin/qt.conf"
    
    # Установка bundled библиотек Qt5 (необходимы для ABI совместимости)
    cp -r usr/lib "${pkgdir}/opt/happ/"
    
    # Установка plugins
    cp -r usr/plugins "${pkgdir}/opt/happ/"
    
    # Установка QML модулей
    cp -r usr/qml "${pkgdir}/opt/happ/"
    
    # Замена проблемного bundled плагина QtGraphicalEffects на системный
    rm -f "${pkgdir}/opt/happ/qml/QtGraphicalEffects/private/libqtgraphicaleffectsprivate.so"
    install -Dm755 /usr/lib/qt/qml/QtGraphicalEffects/private/libqtgraphicaleffectsprivate.so \
        "${pkgdir}/opt/happ/qml/QtGraphicalEffects/private/libqtgraphicaleffectsprivate.so"
    
    # Установка переводов
    cp -r usr/translations "${pkgdir}/opt/happ/"
    
    # Установка иконки
    install -Dm644 happ.png "${pkgdir}/usr/share/pixmaps/happ.png"
    
    # Установка desktop файла
    install -Dm644 Happ.desktop "${pkgdir}/usr/share/applications/happ.desktop"
    
    # Обновление путей в desktop файле
    sed -i 's|Exec=/opt/happ/Happ %f|Exec=/opt/happ/Happ %f|g' \
        "${pkgdir}/usr/share/applications/happ.desktop"
    sed -i 's|Icon=happ|Icon=/usr/share/pixmaps/happ.png|g' \
        "${pkgdir}/usr/share/applications/happ.desktop"
    
    # Создание wrapper скрипта для настройки окружения Qt
    mkdir -p "${pkgdir}/usr/bin"
    cat > "${pkgdir}/usr/bin/happ" <<'EOF'
#!/bin/bash
# Используем bundled Qt библиотеки + фикс QtGraphicalEffects
export LD_LIBRARY_PATH="/opt/happ/lib:${LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="/opt/happ/plugins:${QT_PLUGIN_PATH}"
# Используем ТОЛЬКО bundled QML, системный путь НЕ добавляем (конфликт Qt версий)
export QML2_IMPORT_PATH="/opt/happ/qml:${QML2_IMPORT_PATH}"
exec /opt/happ/bin/Happ "$@"
EOF
    chmod +x "${pkgdir}/usr/bin/happ"
}
