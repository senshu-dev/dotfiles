# План: Форк Caelestia Shell

## Текущее состояние (2026-11-06)

**Форк уже создан** в `~/workspace/caelestia-shell`, ветка `custom/main`, 121 коммит поверх upstream.

Remote `origin` = `https://github.com/caelestia-dots/shell.git` (upstream).
GitHub-репо под своим аккаунтом **ещё не создан** — нужно создать и добавить как `senshu` remote.

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

### Задача 1: Создать GitHub-репо (5 мин)

```bash
cd ~/workspace/caelestia-shell
gh repo create senshu/caelestia-shell --private --source=. --push
# потом переименовать remote:
git remote rename origin upstream
git remote add origin https://github.com/senshu/caelestia-shell.git
git push -u origin custom/main
```

### Задача 2: Per-workspace wallpaper — порт на C++ (2-4 часа)

PR #2210 меняет `services/Wallpapers.qml`, но upstream перенёс логику в C++:
- **Новое расположение:** `plugin/src/Caelestia/Scheme/wallpapers.cpp` / `.hpp`
- **Что нужно:** изучить diff PR #2210, адаптировать к C++ API, скомпилировать

Шаги:
1. `git diff pr/2210..main -- services/Wallpapers.qml` — понять что PR менял
2. Изучить `plugin/src/Caelestia/Scheme/wallpapers.cpp` — текущая C++ реализация
3. Добавить per-workspace логику в C++ код
4. Обновить QML биндинги если нужно
5. Собрать и протестировать

### Задача 3: Установка форка на хост (30 мин)

**Вариант A (рекомендуемый для начала):** Overlay
```bash
# Симлинк форка поверх системного
ln -sf ~/workspace/caelestia-shell ~/.local/share/quickshell/caelestia
# или через XDG: файлы в ~/.config/quickshell/caelestia/ перезаписывают /etc/xdg/
```

**Вариант B (для стабильности позже):** Свой PKGBUILD
- Скопировать `caelestia-shell-git` PKGBUILD
- Заменить source URL на `senshu/caelestia-shell`
- `makepkg -si`

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
