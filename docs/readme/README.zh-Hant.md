# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · **繁體中文** · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Tiếng Việt](README.vi.md) · [ไทย](README.th.md)

[![最新版本](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![授權：MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![下載次數](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

一款小巧的 macOS 選單列 App，讓按鍵、視窗和 Dock 更好用：阻擋 Control 快速鍵，防止誤按 ⌘Q 和 ⌘W，像 Windows 的 Alt+Shift 一樣用 Option+Shift 切換語言，像 Windows 一樣按住按鍵連續輸入，關閉滑鼠加速，讓滑鼠滾輪像 Windows 一樣按行捲動，讓滑鼠側邊按鈕可以返回和前進，關閉最後一個視窗時結束 App，在 Dock 中按一下即可隱藏 App，還能讓你的 Mac 保持喚醒。

## 安裝

使用 [Homebrew](https://brew.sh)：

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

不使用 Homebrew 時，打開「終端機」，貼上下面這一行，然後按下 Return 鍵：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

或下載 [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg)，打開後將 App 拖到「應用程式」檔案夾。

Homebrew 和指令碼都會把 App 放到 `/Applications`，啟動它，要求權限，並開啟「登入時打開」。之後 App 會自動更新，請參閱[更新](#更新)。若要移除，請參閱[解除安裝](#解除安裝)。

## 第一次啟動

pika-tools 需要兩項權限。第一次啟動時，它會打開設定中的「權限」頁面，一步步引導你完成，macOS 也會顯示自己的提示。前往 **系統設定 › 隱私權與安全性**，在以下兩項中開啟 pika-tools：

- **輔助使用**：讓 App 能在按鍵或按一下傳到其他 App 之前加以修改。
- **輸入監控**：讓 App 能夠看到按鍵和按一下的動作。

App 會在一兩秒內偵測到變更，不需要重新啟動。

pika-tools 不會記錄、儲存或傳送你輸入或點按的任何內容。事件只在記憶體中處理並立即傳遞出去。唯一的網路請求是檢查更新，也就是向 GitHub 詢問最新版本。

## 功能

**阻擋 Control 快速鍵。** Control 會變成一般按鍵。App 仍然知道它被按住，但 macOS 不再把它當成快速鍵：Control+空白鍵不會切換輸入方式，Control+方向鍵不會切換桌面，按住 Control 再按一下就是一般的按一下，而不是打開快速選單。輔助按一下和雙指點一下照常可用。適合在遊戲和遠端桌面中使用，因為 Control 在那裡另有用途。

**保護 ⌘Q 和 ⌘W。** 單獨按 ⌘Q 和 ⌘W 不會有任何作用，因此不會誤結束 App 或誤關視窗。想要結束或關閉時，加按 Shift：⇧⌘Q 結束，⇧⌘W 關閉。適用於所有 App。每個按鍵都有各自的開關。預設為關閉。

**用 Option+Shift 切換語言。** 按住 Option 再按一下 Shift：macOS 會切換到下一個輸入方式。繼續按住 Option 再按一下 Shift，就會繼續往下切換。按住 Shift 再按一下 Option，則切回上一個。如果中途按了其他鍵、按了一下滑鼠，或加按 Command、Control 或 Fn，就不會切換，所以像 Option+Shift+方向鍵這類快速鍵照常可用。預設為關閉。

**按住按鍵連續輸入。** 按住一個鍵，就會像在 Windows 上一樣不停地重複輸入這個字母，而不是彈出重音選單。玩遊戲和打字時都很方便。已經打開的 App 需重新啟動後生效。關閉後，macOS 恢復原來的行為。預設為關閉。

**關閉指標加速。** 無論滑鼠移動得多快，指標都只移動與滑鼠完全相同的距離，就像 LinearMouse 一樣。**軌跡速度** 滑桿用來設定指標移動的快慢。只對滑鼠有效，觸控式軌跡板保持不變。關閉此功能或結束 pika-tools 後，macOS 會恢復它自己的設定。預設為關閉。

**按行捲動。** 滑鼠滾輪每捲一格，捲動的行數都一樣，不管你轉得多快，和 Windows 一樣。每格可以選 1 到 10 行，預設 3 行。自然捲動維持你在「系統設定」中的設定。只對滑鼠有效，觸控式軌跡板維持不變。預設為關閉。

有些 App 和遊戲以精確像素計算捲動：遇到它們時，把同一個設定切換為按像素，每格可選 1 到 200 像素，預設 40。

**側邊按鈕用於返回和前進。** 滑鼠按鈕 4 和 5 可以在 Safari、Finder 等 Apple App，以及 Firefox、Opera 和 ForkLift 中返回和前進，就像在觸控式軌跡板上輕掃一樣。其他 App，例如 JetBrains 系列 IDE，會原樣收到這兩個按鈕，並按自己的方式處理。如果你的滑鼠側邊按鈕方向相反，請開啟 **交換側邊按鈕**。預設為關閉。

**關閉最後一個視窗時結束。** 關閉 App 的最後一個視窗後，App 就會結束，就像在 Windows 上一樣。Finder 會保持開啟，在其他桌面上有視窗或有視窗縮到 Dock 的 App 也不會結束。你可以列出永遠不要以這種方式結束的 App。預設為關閉。

**在 Dock 中按一下以隱藏。** 在 Dock 中按一下目前正在使用的 App 圖像，它就會隱藏。再按一下即可恢復。預設為關閉。

**綠色按鈕放大視窗。** 按一下視窗的綠色按鈕，視窗會填滿螢幕，而不會進入全螢幕。再按一下，恢復原本大小。按住 ⌥ 時，按鈕照常運作。全螢幕仍可在按鈕的選單中或按 ⌃⌘F 使用。可以列出綠色按鈕應照常運作的 App。預設為關閉。

**在 Finder 中新增檔案。** 在 Finder 視窗或桌面上按右鍵，選擇 **新增檔案**，輸入名稱，就會出現一個空白檔案，就像 Windows 的「新增 › 文字文件」。預設為 .txt。預設關閉。

**在 Finder 中用 Enter 打開檔案。** 在 Finder 視窗或桌面上選取檔案，按 Return 或 Enter 就會打開，就像 Windows 一樣。按 F2 或 fn F2 可重新命名所選檔案。在文字欄位中，例如輸入名稱時，這些按鍵照常運作。預設關閉。

**在 Finder 中用 ⌘X 剪下檔案。** 選取檔案並按 ⌘X，打開目的地檔案夾後按 ⌘V，檔案會移到那裡而不是被拷貝，就像 Windows 的「剪下」和「貼上」。按 ⌘C 可取消剪下。預設關閉。

每個工具在選單和設定中都有各自的開關。需要恢復一般的 Control+C？關閉那個工具即可。

選單列圖像一眼就能看出狀態：工具正在運作時顯示帶有點按標記的箭頭，全部關閉時顯示加上斜線的箭頭，工具已開啟但缺少權限時顯示警告三角形。

選單列面板一開始只顯示幾列。要顯示哪些列，由你決定：按一下底部的鉛筆按鈕，勾選想看到的項目，再按一下**完成**。隱藏的列仍會照常運作，並保留在設定中。面板在螢幕上放不下時，可以捲動。

App 會跟隨系統語言，或使用你在設定中選擇的語言。支援本頁頂端列出的全部 23 種語言。

## 保持喚醒

在你離開鍵盤時防止 Mac 進入睡眠：時間可以是 1 秒到 365 天之間的任意長度，或一直持續到你手動關閉。在選單中開啟它，並在設定中設定時間長度：輸入天、小時、分鐘和秒，按 ↑ 和 ↓，或按一下 15 分鐘到 8 小時的預設值。選單會顯示剩餘時間和結束時間。**讓顯示器保持開啟** 還能防止螢幕變暗。結束 pika-tools 也會結束「保持喚醒」。

在 MacBook 上，你也可以開啟 **闔上螢幕時繼續運作**。macOS 沒有這樣的開關，因此 pika-tools 會執行 `pmset -a disablesleep 1` 並要求輸入管理者密碼：只有管理者才能更改 Mac 的睡眠方式。當「保持喚醒」結束、你結束 App 或 App 當掉時，此設定都會自動恢復原狀。如果不輸入密碼，什麼都不會改變。闔上螢幕使用時，請保持 Mac 通風良好。**電池電量低於 20% 時停止** 會在電池耗盡前結束這次工作階段。

透過「捷徑」App，可以把「保持喚醒」、螢幕常亮和闔蓋模式放到控制中心、選單列或桌面小工具的按鈕上，連結在「設定 › 保持喚醒」裡拷貝。

## 設定

從選單中選擇 **設定⋯** 或按 ⌘, 打開設定，也可以從 Finder、Launchpad 或 Spotlight 再次啟動 pika-tools。視窗打開期間，App 會顯示在 Dock 和 ⌘Tab 中。

- **一般**：登入時打開、外觀（跟隨系統、淺色或深色）、語言、更新和備份：把設定輸出為檔案或從檔案輸入，也可以透過 iCloud 雲碟同步。
- **鍵盤**：Control 快速鍵、⌘Q 和 ⌘W、語言切換。
- **滑鼠**：指標加速和軌跡速度、按行捲動、側邊按鈕。
- **視窗與 App**：關閉最後一個視窗時結束、用綠色按鈕放大視窗（均附例外列表），以及在 Dock 中按一下以隱藏。
- **保持喚醒**：時間長度、顯示器和螢幕闔上選項。
- **權限**：兩項權限的狀態，開啟同步後還有 iCloud 雲碟的狀態，以及打開「系統設定」中對應位置的按鈕。
- **關於**：版本、更新記錄連結和問題回報連結。

每個頁面底部都有一個 **回復預設值…** 按鈕。它會先詢問你，然後關閉該頁面上的工具並還原它們的選項，就像 pika-tools 從未動過一樣。

**透過 iCloud 同步設定** 能讓 pika-tools 在你所有的 Mac 上保持一致。設定存放在 iCloud 雲碟的 pika-tools 檔夾裡，以最近一次的更改為準。預設為關閉，而且需要先開啟 iCloud 雲碟。權限不會同步：每台 Mac 都會各自請求。

## 更新

pika-tools 會在啟動時以及每隔 6 小時檢查新版本。你可以在「設定 › 一般」中關閉此功能。有新版本時，選單中會出現 **更新到 ⋯** 按鈕：按一下，App 就會下載更新、安裝並重新啟動。你也可以在「設定 › 一般」中按一下 **立即檢查** 手動檢查。

使用 Homebrew 時，也可以執行 `brew upgrade --cask pika-tools`。

從 1.3 版開始，更新後權限會保留。

## 解除安裝

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

如果是用 Homebrew 安裝的：`brew uninstall --cask --zap pika-tools`。

兩種方式都會結束 App、將其從登入項目中移除並刪除。指令碼還會重置它的權限。

## 常見問題

**為什麼需要兩項權限？**
macOS 把對鍵盤和滑鼠的存取分成兩部分。「輸入監控」讓 App 能看到事件，「輔助使用」讓 App 能修改事件。阻擋快速鍵兩者都需要。

**macOS 提示 App 來自未識別的開發者。**
pika-tools 已簽署，但未經 Apple 公證。Homebrew 和安裝指令碼會幫你處理這一點。如果你用的是 dmg，請打開 **系統設定 › 隱私權與安全性** 並按一下 **強制打開**，或執行：

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**支援搭載 Intel 處理器的 Mac 嗎？**
支援。這是適用於 Apple 晶片和 Intel 的通用 App，需要 macOS 14 Sonoma 或以上版本。

**權限已開啟，但什麼都沒有作用。**
在 **系統設定 › 隱私權與安全性** 中，用 − 按鈕從兩個列表中移除 pika-tools，然後重新加入。pika-tools 設定的「權限」頁面中有按鈕可以直接打開對應位置。

## 參與貢獻

從原始碼建置和發布版本的方法請見 [CONTRIBUTING.md](../../CONTRIBUTING.md)。變更記錄請見 [CHANGELOG.md](../../CHANGELOG.md)。

## 授權

MIT，© 2026 pikapik。詳見 [LICENSE](../../LICENSE)。
