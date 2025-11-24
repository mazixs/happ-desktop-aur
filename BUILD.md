# Инструкция по сборке Happ Desktop

## Быстрый старт

```bash
# 1. Клонирование репозитория
git clone https://github.com/mazixs/happ-desktop-aur.git
cd happ-desktop-aur

# 2. Убедитесь, что Happ.linux.x86.AppImage находится в текущей директории
ls -lh Happ.linux.x86.AppImage

# 3. Сборка и установка
makepkg -si

# 4. Проверка установки
./test-capabilities.sh

# 5. Запуск
happ
```

## Требования

### Системные зависимости для сборки

```bash
sudo pacman -S base-devel
```

### Runtime зависимости (устанавливаются автоматически)

- `qt5-base`
- `qt5-svg`
- `qt5-declarative`
- `openssl`
- `libcap`

## Детальная сборка

### Шаг 1: Подготовка

```bash
# Проверка наличия AppImage
file Happ.linux.x86.AppImage
# Ожидается: ELF 64-bit LSB executable...

# Проверка структуры проекта
tree -L 1 -a
# .
# ├── .git/
# ├── .gitignore
# ├── .SRCINFO
# ├── BUILD.md
# ├── Happ.linux.x86.AppImage
# ├── PKGBUILD
# ├── README.md
# ├── happ-desktop.install
# └── test-capabilities.sh
```

### Шаг 2: Проверка PKGBUILD

```bash
# Валидация синтаксиса
namcap PKGBUILD

# Просмотр информации о пакете
makepkg --printsrcinfo
```

### Шаг 3: Сборка

```bash
# Чистая сборка (рекомендуется)
makepkg -si --cleanbuild

# Опции:
# -s, --syncdeps     Установить недостающие зависимости
# -i, --install      Установить пакет после сборки
# -c, --clean        Очистить рабочие файлы после сборки
# -f, --force        Перезаписать существующий пакет
# --cleanbuild       Удалить директорию $srcdir перед сборкой
```

### Шаг 4: Проверка

```bash
# Проверка установленных файлов
pacman -Ql happ-desktop

# Проверка зависимостей
pacman -Qi happ-desktop

# Проверка capabilities
getcap /opt/happ/tun/sing-box
getcap /opt/happ/core/xray

# Полная проверка
./test-capabilities.sh
```

## Процесс сборки (что происходит внутри)

### prepare()

1. Делает AppImage исполняемым
2. Распаковывает AppImage в `squashfs-root/`

### package()

1. Копирует основное приложение в `/opt/happ/`
2. Копирует VPN ядра (sing-box, xray) с сохранением прав
3. Копирует библиотеки, плагины, QML модули
4. Устанавливает иконку и desktop файл
5. Создает wrapper скрипт `/usr/bin/happ`
6. Создает символические ссылки для совместимости

### post_install() (из happ-desktop.install)

1. Устанавливает `cap_net_admin+ep` на sing-box
2. Устанавливает `cap_net_admin+ep` на xray
3. Выводит информацию об установке

## Решение проблем при сборке

### Ошибка: AppImage not found

```bash
# Проверьте путь в PKGBUILD
grep "^source=" PKGBUILD

# Убедитесь, что AppImage в текущей директории
ls -lh *.AppImage
```

### Ошибка: Missing dependencies

```bash
# Установите зависимости сборки
sudo pacman -S base-devel

# Установите runtime зависимости
sudo pacman -S qt5-base qt5-svg qt5-declarative openssl libcap
```

### Ошибка: Permission denied

```bash
# Убедитесь, что AppImage исполняемый
chmod +x Happ.linux.x86.AppImage
```

### Ошибка при установке capabilities

```bash
# Убедитесь, что libcap установлен
pacman -Q libcap

# Проверьте наличие setcap
which setcap

# Запустите post_install вручную
sudo bash -c "source happ-desktop.install && post_install"
```

## Переустановка

```bash
# Полное удаление
sudo pacman -R happ-desktop

# Очистка сборки
rm -rf src/ pkg/ *.pkg.tar.zst squashfs-root/

# Пересборка
makepkg -si --cleanbuild
```

## Обновление версии

```bash
# 1. Обновите pkgver в PKGBUILD
vim PKGBUILD

# 2. Пересоздайте .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# 3. Коммит изменений
git add PKGBUILD .SRCINFO
git commit -m "Update to version X.X.X"
git push

# 4. Пересоберите
makepkg -si --cleanbuild --force
```

## Публикация в AUR

```bash
# 1. Убедитесь, что source указывает на публичный URL
# Измените в PKGBUILD:
# source=("https://example.com/Happ.linux.x86.AppImage")

# 2. Обновите checksums
updpkgsums

# 3. Пересоздайте .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# 4. Тестовая сборка
makepkg -si --cleanbuild

# 5. Push в AUR
git remote add aur ssh://aur@aur.archlinux.org/happ-desktop.git
git push aur master
```

## Дополнительные команды

```bash
# Проверка качества пакета
namcap *.pkg.tar.zst

# Просмотр содержимого пакета
tar -tvf *.pkg.tar.zst | less

# Извлечение файлов из пакета (без установки)
tar -xvf *.pkg.tar.zst -C /tmp/test-pkg/

# Проверка линковки
ldd /tmp/test-pkg/opt/happ/Happ
```

## Тестирование в чистом окружении (chroot)

```bash
# Создание чистого окружения
sudo pacman -S devtools

# Сборка в чroot
extra-x86_64-build

# Это гарантирует, что все зависимости корректно указаны
```

## Логи и отладка

```bash
# Сборка с отладкой
makepkg -si 2>&1 | tee build.log

# Просмотр подробных логов установки
journalctl -u pacman -b | grep happ

# Отладка запуска приложения
QT_DEBUG_PLUGINS=1 /opt/happ/Happ 2>&1 | tee app.log
```
