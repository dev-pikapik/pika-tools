# Private

This folder is where a separate private repository is mounted: drafts, experiments and tools that aren't public yet. The public build doesn't depend on it. If the folder is empty, everything builds as usual.

## Setup

```bash
git rm -r --cached Private
rm -rf Private
git submodule add git@github.com:dev-pikapik/pika-tools-private.git Private
git commit -m "Add private submodule"
```

To clone everything at once:

```bash
git clone --recurse-submodules git@github.com:dev-pikapik/pika-tools.git
```

Without access to the private repository, a regular `git clone` leaves this folder empty.

## Private tools

If `Private/Sources/` contains `.swift` files, `scripts/build.sh` adds them to the build and sets the `PIKA_PRIVATE` flag. One of those files then has to declare the list:

```swift
let privateTools: [any Tool] = [
    MySecretTool(),
]
```

Don't keep secrets, keys or tokens here or anywhere in the public code.
