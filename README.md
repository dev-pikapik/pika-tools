# pika-tools

Маленькие полезные штуки для macOS в строке меню.

Сейчас внутри одна, но главная: **Ctrl+клик работает как обычный клик**. Контекстное меню больше не выскакивает.
Это спасает в играх, где Ctrl — кнопка действия: зажал Ctrl, кликнул — получил выстрел или выбор, а не меню.

- Правый клик мышью и тап двумя пальцами работают как раньше.
- Ctrl на клавиатуре остаётся нажатым — игра его видит.
- Включается и выключается одним переключателем.
- macOS 14 Sonoma и новее, Apple Silicon и Intel. На macOS 26 Tahoe — Liquid Glass.

## Установка

Через Homebrew:

```bash
brew tap dev-pikapik/pika-tools https://github.com/dev-pikapik/pika-tools && brew trust dev-pikapik/pika-tools && brew install --cask pika-tools && open -a pika-tools
```

Или без Homebrew, одной командой в Терминале:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Оба способа ставят готовую сборку в `/Applications`, снимают карантин, запускают приложение, просят доступы и включают автозапуск.
Хочешь собрать сам из исходников — добавь `--source` в конце (нужны Xcode Command Line Tools):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)" -- --source
```

Или скачай `pika-tools.dmg` из [Releases](https://github.com/dev-pikapik/pika-tools/releases) и перетащи в «Программы». Если macOS не даёт открыть:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

## Обновления

Приложение само проверяет новые версии — при запуске и раз в 6 часов. Когда выходит новая, в меню появляется кнопка **Обновить до …**: один клик, и pika-tools скачает, поставит и перезапустит себя.
Внизу меню видно текущую версию, там же кнопка **Проверить**.

Через Homebrew тоже можно: `brew upgrade --cask pika-tools`.

После обновления macOS считает приложение новым, поэтому доступы надо включить ещё раз — окно с подсказкой откроется само.

## Доступы

Без них macOS не пустит приложение к кликам. При первом запуске откроется окно с подсказкой, а macOS покажет свои запросы.

Открой **System Settings › Privacy & Security** и включи pika-tools в двух списках:

| Раздел | Зачем |
|---|---|
| **Accessibility** (Универсальный доступ) | чтобы менять клик |
| **Input Monitoring** (Мониторинг ввода) | чтобы видеть клик |

Приложение само проверяет доступы каждые 1,5 секунды — ничего перезапускать не нужно. Иконка в меню станет обычной стрелкой с кликом.

Не работает, хотя галочка стоит? Так бывает после пересборки. Удали pika-tools из обоих списков кнопкой «−», затем нажми в меню **Проверить доступы** и включи заново.

## Иконка в строке меню

| Иконка | Что значит |
|---|---|
| стрелка с кликом | Активно — Ctrl+клик работает как обычный клик |
| перечёркнутая стрелка | Выключено |
| треугольник | Включено, но нет доступа |

## Автозапуск

Включается сам при первом запуске. Выключить или включить обратно — переключатель **Открывать при входе** в меню.
Если macOS попросит подтверждение: **System Settings › General › Login Items** → разреши pika-tools.

## Удаление

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Ставил через Homebrew — тогда `brew uninstall --cask --zap pika-tools`.
Оба способа закроют приложение, уберут его из автозапуска и удалят. Скрипт ещё и сбросит доступы.

## Сборка из исходников

Нужны только Xcode Command Line Tools.

```bash
git clone https://github.com/dev-pikapik/pika-tools.git
cd pika-tools
./scripts/build.sh      # build/pika-tools.app
./scripts/package.sh    # build/pika-tools.dmg и build/pika-tools.zip
```

### Подпись

По умолчанию сборка подписывается ad-hoc — этого хватает для своего Mac.
Есть Developer ID? Тогда можно подписать и нотаризовать:

```bash
xcrun notarytool store-credentials pika-notary --apple-id you@example.com --team-id TEAMID
SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" NOTARY_PROFILE=pika-notary ./scripts/package.sh
```

## Как устроено

```
Sources/pika-tools/
  main.swift, App.swift, MenuView.swift
  Tools/Tool.swift                   протокол Tool и ToolRegistry
  Tools/CtrlClick/CtrlClickTool.swift
  Common/                            общие куски интерфейса, доступы, автозапуск, обновления
Casks/pika-tools.rb                  Homebrew cask
scripts/                             сборка, упаковка, релиз
```

Ctrl+клик ловится через `CGEventTap` до того, как событие попадёт в приложения. У левого клика снимается флаг Ctrl — и всё.
Правый клик и клавиатура не трогаются.

Новый инструмент = новый файл в `Tools/` с классом под протокол `Tool` и одна строка в `ToolRegistry.tools`.

## Выпустить новую версию

```bash
./scripts/release.sh 1.0.1
```

Скрипт поднимет версию, соберёт `.zip` и `.dmg`, обновит cask, закоммитит, поставит тег, запушит и создаст релиз на GitHub.
Установленные приложения увидят его сами.

## Лицензия

MIT, © 2026 pikapik. См. [LICENSE-MIT](LICENSE-MIT).
