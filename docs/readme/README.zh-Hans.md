# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · **简体中文** · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![最新版本](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![许可证：MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![下载量](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

一款小巧的 macOS 菜单栏 App，改善按键、窗口和程序坞的使用体验：屏蔽 Control 快捷键，防止误按 ⌘Q 和 ⌘W，像 Windows 上的 Alt+Shift 一样用 Option+Shift 切换语言，关闭鼠标加速，让鼠标滚轮像 Windows 一样按行滚动，让鼠标侧键可以后退和前进，关闭最后一个窗口时退出 App，在程序坞中点按即可隐藏 App，还能让你的 Mac 保持唤醒。

## 安装

使用 [Homebrew](https://brew.sh)：

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

不使用 Homebrew 时，打开“终端”，粘贴下面这行，然后按下 Return 键：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

或者下载 [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg)，打开后将 App 拖到“应用程序”文件夹。

Homebrew 和脚本都会把 App 放到 `/Applications`，启动它，请求权限，并打开“登录时打开”。之后 App 会自动更新，详见[更新](#更新)。如需移除，请参阅[卸载](#卸载)。

## 首次启动

pika-tools 需要两项权限。首次启动时，它会打开设置中的“权限”页面，一步步引导你完成，macOS 也会显示自己的提示。前往 **系统设置 › 隐私与安全性**，在以下两项中打开 pika-tools：

- **辅助功能**：让 App 能在按键或点按传到其他 App 之前对其进行修改。
- **输入监控**：让 App 能够看到按键和点按。

App 会在一两秒内识别到更改，无需重新启动。

pika-tools 不会记录、存储或发送你输入或点按的任何内容。事件只在内存中处理并立即传递出去。唯一的网络请求是检查更新，即向 GitHub 查询最新版本。

## 功能

**屏蔽 Control 快捷键。** Control 变成一个普通按键。App 仍然能知道它被按住，但 macOS 不再把它当作快捷键：Control+空格键不会切换输入法，Control+箭头键不会切换桌面，按住 Control 点按就是普通点按，而不是打开快捷菜单。辅助点按和双指轻点照常可用。适合游戏和远程桌面，在那里 Control 另有用途。

**保护 ⌘Q 和 ⌘W。** 单独按 ⌘Q 和 ⌘W 不会有任何反应，因此不会误退出 App 或误关窗口。想要退出或关闭时，加按 Shift：⇧⌘Q 退出，⇧⌘W 关闭。适用于所有 App。每个按键都有单独的开关。默认关闭。

**用 Option+Shift 切换语言。** 按住 Option 再按一下 Shift：macOS 会切换到下一个输入法。继续按住 Option 再按一下 Shift，就会继续往下切换。按住 Shift 再按一下 Option，则切回上一个。如果中途按了其他键、点按了鼠标，或者加按了 Command、Control 或 Fn，就不会切换，所以像 Option+Shift+箭头键这样的快捷键照常可用。默认关闭。

**关闭指针加速。** 无论鼠标移动得多快，指针都只移动与鼠标完全相同的距离，就像 LinearMouse 一样。**追踪速度** 滑块用于设定指针移动的快慢。仅对鼠标有效，触控板保持不变。关闭此功能或退出 pika-tools 后，macOS 会恢复它自己的设置。默认关闭。

**按行滚动。** 鼠标滚轮每滚一格，滚动的行数都一样，不管你转得多快，和 Windows 一样。每格可以选 1 到 10 行，默认 3 行。自然滚动保持你在“系统设置”中的设置。只对鼠标有效，触控板保持不变。默认关闭。

**侧键用于返回和前进。** 鼠标按键 4 和 5 可以在 Safari、访达等 Apple App，以及 Firefox、Opera 和 ForkLift 中后退和前进，就像在触控板上轻扫一样。其他 App，例如 JetBrains 系列 IDE，会原样收到这两个按键，并按自己的方式处理。如果你的鼠标侧键方向相反，请打开 **交换侧键**。默认关闭。

**关闭最后一个窗口时退出。** 关闭 App 的最后一个窗口后，App 就会退出，就像在 Windows 上一样。访达会保持打开，在其他桌面上有窗口或有窗口最小化到程序坞的 App 也不会退出。你可以列出永远不要以这种方式退出的 App。默认关闭。

**在程序坞中点按以隐藏。** 在程序坞中点按当前正在使用的 App 的图标，它就会隐藏。再点按一次即可恢复。默认关闭。

每个工具在菜单和设置中都有单独的开关。需要恢复普通的 Control+C？关闭那个工具即可。

菜单栏图标一眼就能看出状态：工具正在运行时显示带点按标记的箭头，全部关闭时显示带斜线的箭头，工具已打开但缺少权限时显示警告三角形。

App 跟随系统语言，或使用你在设置中选择的语言。支持本页顶部列出的全部 23 种语言。

## 保持唤醒

在你离开键盘时防止 Mac 进入睡眠：时长可以是 1 分钟到 12 个月之间的任意时间，或者一直持续到你手动关闭。在菜单中打开它，在设置中以分钟、小时、天、周或月为单位设定时长。菜单会显示剩余时间和结束时间。**保持显示器开启** 还能防止屏幕变暗。退出 pika-tools 会结束“保持唤醒”。

在 MacBook 上，你还可以打开 **合盖时继续运行**。macOS 没有这样的开关，因此 pika-tools 会运行 `pmset -a disablesleep 1` 并要求输入管理员密码：只有管理员才能更改 Mac 的睡眠方式。当“保持唤醒”结束、你退出 App 或 App 崩溃时，此设置都会自动恢复原状。如果不输入密码，什么都不会改变。合盖使用时请保持 Mac 通风良好。**电池电量低于 20% 时停止** 会在电池耗尽前结束本次会话。

## 设置

从菜单中选择 **设置…** 或按 ⌘, 打开设置，也可以从访达、启动台或聚焦搜索再次启动 pika-tools。窗口打开期间，App 会显示在程序坞和 ⌘Tab 中。

- **通用**：登录时打开、外观（跟随系统、浅色或深色）、语言、更新和备份：把设置导出为文件或从文件导入，也可以通过 iCloud 云盘同步。
- **键盘**：Control 快捷键、⌘Q 和 ⌘W、语言切换。
- **鼠标**：指针加速和追踪速度、按行滚动、侧键。
- **窗口与应用**：关闭最后一个窗口时退出（附例外列表），以及在程序坞中点按以隐藏。
- **保持唤醒**：时长、显示器和合盖选项。
- **权限**：两项权限的状态，开启同步后还有 iCloud 云盘的状态，以及打开“系统设置”中对应位置的按钮。
- **关于**：版本、更新日志链接和问题反馈链接。

每个页面底部都有一个 **恢复默认…** 按钮。它会先询问你，然后关闭该页面上的工具并还原它们的选项，就像 pika-tools 从未改动过一样。

**通过 iCloud 同步设置** 能让 pika-tools 在你所有的 Mac 上保持一致。设置保存在 iCloud 云盘的 pika-tools 文件夹里，以最近一次的更改为准。默认关闭，并且需要先打开 iCloud 云盘。权限不会同步：每台 Mac 都会各自请求。

## 更新

pika-tools 会在启动时以及每隔 6 小时检查新版本。你可以在“设置 › 通用”中关闭此功能。有新版本时，菜单中会出现 **更新到 …** 按钮：点按一下，App 就会下载更新、安装并重新启动。你也可以在“设置 › 通用”中点按 **立即检查** 手动检查。

使用 Homebrew 时，也可以运行 `brew upgrade --cask pika-tools`。

从 1.3 版开始，更新后权限会保留。

## 卸载

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

如果是用 Homebrew 安装的：`brew uninstall --cask --zap pika-tools`。

两种方式都会退出 App、将其从登录项中移除并删除。脚本还会重置它的权限。

## 常见问题

**为什么需要两项权限？**
macOS 把对键盘和鼠标的访问分成两部分。“输入监控”让 App 能看到事件，“辅助功能”让 App 能修改事件。屏蔽快捷键两者都需要。

**macOS 提示 App 来自身份不明的开发者。**
pika-tools 已签名，但未经 Apple 公证。Homebrew 和安装脚本会帮你处理这一点。如果你用的是 dmg，请打开 **系统设置 › 隐私与安全性** 并点按 **仍要打开**，或者运行：

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**支持搭载 Intel 处理器的 Mac 吗？**
支持。这是适用于 Apple 芯片和 Intel 的通用 App，需要 macOS 14 Sonoma 或更高版本。

**权限已打开，但什么都不起作用。**
在 **系统设置 › 隐私与安全性** 中，用 − 按钮从两个列表中移除 pika-tools，然后重新添加。pika-tools 设置的“权限”页面中有按钮可以直接打开对应位置。

## 参与贡献

从源代码构建和发布版本的方法见 [CONTRIBUTING.md](../../CONTRIBUTING.md)。更改记录见 [CHANGELOG.md](../../CHANGELOG.md)。

## 许可证

MIT，© 2026 pikapik。详见 [LICENSE](../../LICENSE)。
