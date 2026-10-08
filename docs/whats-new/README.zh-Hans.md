<p align="center"><a href="../readme/README.zh-Hans.md"><img src="../media/icon.png" width="96" height="96" alt="pika-tools"></a></p>
<h1 align="center">pika-tools 更新内容</h1>
<p align="center">每次更新，几句话加一张图，最新的在最前面。</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <b>简体中文</b> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.25.2"></a>点按快捷键，直接去能更改它的地方

<sub>1.25.2 · 2026年10月8日</sub>

在设置中点按快捷键，“系统设置”会在正确的位置打开。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

以前点按快捷键（比如聚焦的快捷键），总会打开“修饰键”。现在点按聚焦的按键，会直接打开“聚焦”。

对于其他快捷键，“系统设置”会打开到“键盘”，按键旁会出现一条简短提示，告诉你该点哪里：先点“键盘快捷键…”，再点“调度中心”或其他部分。

“游戏”页面和“在访达中剪切文件”也是这样。剪切文件时，提示会带你去“App快捷键”。

**试试看：** 设置 › 游戏，然后点按“搜索不会弹出”旁边的按键

**修复**

- 点按快捷键不会再打开“修饰键”。

---

## <a id="v1.25.1"></a>大图片，游戏直接从程序坞选

<sub>1.25.1 · 2026年10月8日</sub>

每个开关现在都有一张大图片，“添加游戏…”会显示程序坞里的内容。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

在“动画”和“游戏”页面，所有图片现在都变大了，和页面顶部的那张一样。一眼就能看懂每个开关做什么，图片仍按你选的速度播放。

点按“添加游戏…”，就能看到你的程序坞：放在那里的 App 和正在打开的 App，顺序也一样。放在程序坞里的游戏即使关着也会出现，Minecraft 也是。点一下就能添加，勾号表示它已在列表中。再点一下就能移除。

你仍然可以从访达把游戏拖到这里。不用再把它从程序坞里拖出来，所以程序坞也不会提示要移除它。

**试试看：** 设置 › 游戏，然后点按“添加游戏…”

**修复**

- 放在程序坞里但没有打开的游戏，现在会出现在添加列表中。

---

## <a id="v1.25.0"></a>一键添加游戏，按键也能自己定

<sub>1.25.0 · 2026年10月8日</sub>

从正在打开的 App 里挑选游戏，退出和关闭用的按键也由你来定。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

点按“添加游戏…”，正在打开的 App 会像程序坞里那样以大图标排开。点一下就能添加，也可以把图标拖进列表。还可以直接从访达或程序坞把游戏拖进来。现在任何 App 都可以当作游戏，连用 Java 运行的 Minecraft 也行；之前添加的游戏都会保留。

游戏模式的开关现在用大白话说明，比如“游戏不会关闭”或“搜索不会弹出”，每个开关还配了一张小图，画出它拦住的东西。系统里的名称，比如聚焦，会以灰色显示在旁边。

在“设置 › 窗口”中，点按“退出应用”或“关闭窗口”旁边的按键，然后按下新的按键。按 ⌫ 可恢复 ⇧⌘Q 和 ⇧⌘W；如果按键已被占用，pika-tools 会先问你。游戏模式也会使用你的按键。另外，设置里的每个快捷键现在都会显示它在你的 Mac 上实际的设置：你自己的按键，或“已关闭”。

**试试看：** 设置 › 游戏，然后点按“添加游戏…”

**修复**

- 在访达中剪切文件时，会遵循你在“系统设置”里为访达设定的“剪切”快捷键。
- 列表中的 App 名称不再显示“.app”。

---

## <a id="v1.24.1"></a>速度变化，立刻就能看到

<sub>1.24.1 · 2026年10月8日</sub>

“动画”页面现在会告诉你改动在哪里生效，也会保护你自己设的值。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

程序坞只有在自动隐藏时才能滑得更快。如果你的程序坞一直显示，“自动隐藏和显示程序坞”开关现在就在速度滑块正下方。

改动之后，页面底部会出现一行提示：重新打开 App 后生效。访达要重新启动才会用上快速查看和分栏的新速度，所以这行提示里有一个“重新启动访达”按钮。

滑块绝不会让你已经调快的东西变慢，比如你在终端里用命令调过的。“恢复默认”和卸载 pika-tools 会把你之前的值还回来，而不是把它们抹掉。

**试试看：** 设置 › 动画

**修复**

- 程序坞不自动隐藏时，不会再无故重新启动。

---

## <a id="v1.24.0"></a>Mac 动得多快，由你决定

<sub>1.24.0 · 2026年10月8日</sub>

新的“动画”页面，决定 Mac 上的东西打开、滑出和出现得有多快。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

一个滑块就够了。拖动它，隐藏的程序坞、新窗口、存储对话框、快速查看和访达中的分栏会一起变快，从“与 macOS 相同”一直到“即时”。

只想调一项？每种效果都有自己的设置，最小化效果、程序坞里跳动的图标和访达动画也一样。每项设置旁边都有一张小图，正好按你选的速度在动。

“恢复默认”只还原 pika-tools 改过的内容，卸载时也一样。如果你曾在终端里亲自设过其中某个值，pika-tools 会原样显示它。

**试试看：** 设置 › 动画

---

## <a id="v1.23.2"></a>游戏模式里，每个快捷键都有自己的开关

<sub>1.23.2 · 2026年10月8日</sub>

现在你可以一个一个决定，玩游戏时游戏模式要屏蔽哪些快捷键。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q 和 ⌘W 现在有各自的开关，聚焦、Siri、⌘Tab、调度中心、轻扫、指针、屏幕等其他项目也一样。你之前的选择都会保留。

每一行都准确显示它拦住的按键，所以你总能知道一个开关管什么。

键盘语言设置已从游戏模式中移除。⌃空格和其他切换语言的方式随时可用，在游戏里也一样。

**试试看：** 设置 › 游戏

**修复**

- 同一个快捷键的按键靠得更近，不同快捷键之间多留了一点空，一眼就能看出哪个在哪儿结束、下一个从哪儿开始。

---

## <a id="v1.23.1"></a>网速多快，用大白话告诉你

<sub>1.23.1 · 2026年10月8日</sub>

“网速测试”会检查你的网络连接，并简单告诉你它够做什么。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

点按“测速”，大约半分钟后就能看到下载、上传、Ping 和响应能力。数字下方用简单的话说明，够不够看 4K 电影、视频通话、玩在线游戏和下载大文件。

测速在 Apple 的服务器上进行，最近一次结果会一直保留到下一次测速。“网速测试”在设置里有自己的页面，在菜单栏面板里有一行，还有一个给“快捷指令”App 用的链接：`pika-tools://speed-test`。

游戏模式学会了两件事。屏蔽 Control 快捷键现在归入了游戏模式：在游戏里，⌃-点按仍是普通点按，⌃ 快捷键不会触发；其他地方 ⌃ 照常使用。它还能识别 Minecraft：把 Minecraft Launcher 或 CurseForge 添加到你的游戏里，当 Minecraft 本身在最前面时，游戏模式就会打开。

**试试看：** 设置 › 网速测试，然后点按“测速”

**修复**

- 自己编译的 pika-tools 测试版会在 iCloud 云盘里单独保存设置，不会再动你的设置。

---

## <a id="v1.23.0"></a>游戏模式：玩游戏不被打扰

<sub>1.23.0 · 2026年10月7日</sub>

添加你的游戏，Mac 就不会再把你拉出游戏。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

玩游戏时，聚焦、Siri、⌘Tab、调度中心和在桌面之间轻扫都不会在游戏上方打开。⌘Q 和 ⌘W 不会意外关闭游戏，指针会留在游戏所在的屏幕上，屏幕也保持常亮。

要退出游戏，请按 ⇧⌘Q；要关闭游戏窗口，请按 ⇧⌘W。⌥⌘Esc 始终有效。pika-tools 会推荐它在你的 Mac 上找到的游戏。游戏模式默认关闭，你打开后才生效。

“保持唤醒”现在可以选择屏幕怎么做：一直亮着，不显示屏幕保护程序和锁定屏幕；或者像平时一样熄灭，而 Mac 继续工作。新的“立即关闭显示器”按钮会马上让屏幕变暗；移动鼠标或按任意键即可恢复。

**试试看：** 设置 › 游戏，然后点按“添加游戏…”

**修复**

- 在台式 Mac 上，“保持唤醒”不再显示合盖相关的选项。

---

<p align="center"><sub>更早的版本请查看<a href="../../CHANGELOG.md">更新日志</a>（英文）。</sub></p>
