# План: Форк Caelestia Shell

## Текущее состояние (2026-11-06, сессия 2)

**Форк** в `~/workspace/caelestia-shell`, ветка `custom/main`.

Remotes:
- `origin` = `https://github.com/senshu-dev/caelestia-shell.git` (наш GitHub-репо, создан)
- `upstream` = `https://github.com/caelestia-dots/shell.git`

**Push заблокирован** — PAT не имеет `repo` scope. Нужно обновить токен или настроить SSH.

### Зависимость: caelestia-dots/lib

Форк зависит от **`caelestia-dots/lib`** — backing C++ библиотека, предоставляет cmake target `caelestia::caelestia` и заголовки `<caelestia/utils/cache.hpp>`, `<caelestia/scheme/scheme.hpp>` и т.д. В AUR пакета нет — PKGBUILD создан в `packages/caelestia-lib-git/`. Клонировано в `~/workspace/caelestia-lib`.

**Порядок сборки:** caelestia-lib-git → caelestia-shell-custom.

### Что уже вмержено

| Фича | Источник | Коммитов | Статус |
|---|---|---|---|
| Per-monitor popup notifications | PR #2255 (soramanew) | 117 | **Вмержено** |
| Custom notif actions via hints | PR #2259 (soramanew) | 1 | **Cherry-picked** |
| Fix: actionOnClick default | PR #2262 (soramanew) | 1 | **Cherry-picked** |

### Что НЕ вошло и почему

| Фича | Источник | Причина |
|---|---|---|
| Per-workspace wallpaper | PR #2210 (systemeror12) | `services/Wallpapers.qml` перенесён в C++ (`plugin/src/Caelestia/Scheme/wallpapers.cpp`) в рефакторе notifs. Нужен ручной порт на C++ |
| O(n²) notif fix | PR #2021/issue #2020 | Уже решено рефактором — старый O(n²) паттерн удалён |
| caelestia-zeti | Mpradeep-dev/IO-ZetZor | Репо не найден на GitHub (удалён/переименован) |
| File dialog, video PFPs, async thumbnailing | dev-ветки | 30+ коммитов каждая, не критичны |

## Оставшиеся задачи

### Задача 1: GitHub-репо ✅ (частично)

Репо создано: `senshu-dev/caelestia-shell`. Remotes настроены. **Push ожидает** исправления PAT/SSH.

```bash
# После исправления auth:
cd ~/workspace/caelestia-shell
git push -u origin custom/main
```

### Задача 2: Per-workspace wallpaper — порт на C++ ✅

Реализовано (коммит `d6be56e8`). Изменения в 13 файлах:
- C++ Config: `WorkspaceWallpapers.enabled` в `backgroundconfig.hpp`
- C++ State: `workspaceWallpapers` QVariantMap в `rootnodes.hpp`
- C++ Wallpapers: `wallpaperForWorkspace`/`assignToWorkspace`/`clearWorkspace(s)` в `wallpapers.cpp/hpp`
- C++ CMake: добавлена зависимость `caelestia-state` для Scheme модуля
- QML: `WallpaperImpl` резолвит обои per-screen через активный workspace
- QML: все call site `setWallpaper` также записывают в workspace map когда фича включена
- UI: toggle в Wallpaper & Style настройках nexus
- Включается через `background.workspaceWallpapers.enabled: true` в `shell.json`

### Задача 3: Установка форка на хост (в процессе)

**Подход: свои PKGBUILD** (в `packages/`)

1. Сначала собрать и установить `caelestia-lib-git`:
```bash
cd ~/workspace/dotfiles/packages/caelestia-lib-git
makepkg -si
```

2. Затем собрать и установить `caelestia-shell-custom`:
```bash
cd ~/workspace/dotfiles/packages/caelestia-shell-custom
makepkg -si
```

Форк собирается из `~/workspace/caelestia-shell` (custom/main).

### Задача 4: Обновить dotfiles (15 мин)

В `~/workspace/dotfiles`:
1. `setup.sh` — добавить шаг установки/симлинка форка shell
2. `CLAUDE.md` — задокументировать использование форка
3. Per-monitor конфиги — обновить `HDMI-A-2/shell.json` (уведомления теперь можно отключить per-monitor через PR #2255)

### Задача 5: Стратегия синхронизации

```bash
# Периодически:
git fetch upstream
git checkout main && git merge upstream/main
git checkout custom/main && git rebase main
# Разрешить конфликты, протестировать, push
```

Когда PR #2255 замержат в upstream — наш мерж станет no-op (коммиты уже есть).

## Лицензии

| Репо | Лицензия |
|---|---|
| caelestia-dots/shell | GPL-3.0 |
| Наш форк | GPL-3.0 (обязательно) |

Attribution — в файле `NOTICE` (уже создан в форке).

## Риски

1. **Quickshell API breaks** — upstream может менять QML/C++ API
2. **C++ порт wallpaper** — самая трудоёмкая задача, требует знания Qt6/QML
3. **Сборка** — форк включает C++ plugin, нужны зависимости для компиляции

## Контекст dotfiles

- Репо: `~/workspace/dotfiles`, branch `main`, 3 коммита
- Все конфиги симлинканы в `~/.config/`
- Мониторы: DP-6 (primary, ws 1-4), HDMI-A-2 (secondary, ws 5-8)
- Per-monitor Caelestia: DP-6 = всё, HDMI-A-2 = только launcher + обои
- **Per-monitor notifs теперь возможны** через PR #2255 в нашем форке
