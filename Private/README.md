# Private

Сюда подключается отдельный приватный репозиторий — черновики, задумки и инструменты, которые пока не для всех.
Публичная сборка от этой папки не зависит: нет её содержимого — всё собирается как обычно.

## Подключить

```bash
git rm -r --cached Private
rm -rf Private
git submodule add git@github.com:dev-pikapik/pika-tools-private.git Private
git commit -m "Подключить приватный репозиторий"
```

Склонировать всё вместе:

```bash
git clone --recurse-submodules git@github.com:dev-pikapik/pika-tools.git
```

Без доступа к приватному репозиторию обычный `git clone` просто оставит папку пустой.

## Приватные инструменты

Если в `Private/Sources/` есть `.swift`-файлы, `scripts/build.sh` сам добавит их в сборку и включит флаг `PIKA_PRIVATE`.
Тогда в одном из файлов нужно объявить список:

```swift
let privateTools: [any Tool] = [
    MySecretTool(),
]
```

Секреты, ключи и токены не храни ни здесь, ни в публичном коде.
