<p align="center"><a href="../readme/README.zh-Hant.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">pikapik 更新內容</h1>
<p align="center">每次更新，幾句話加一張圖，最新的在最前面。</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <b>繁體中文</b> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.27.1"></a>更安靜、更輕巧，Finder 馬上可用

<sub>1.27.1 · 2026年10月9日</sub>

設定幾乎不再佔用你的 Mac，搬到 pikapik 後，Finder 的右鍵選單項目馬上就能用。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

設定裡的小動畫以前每秒會把整個頁面重繪很多次，所以只要視窗開著，Mac 就一直在忙。現在每張圖只重繪自己，每秒最多 30 次，捲出畫面或視窗隱藏時就會休息。外觀完全一樣。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

從 pika-tools 搬到 pikapik 後，Finder 可能還在尋找舊的 App，「新增檔案」、「轉換為」等右鍵選單項目沒有反應。現在 pikapik 會在第一次啟動時發現這件事，如果 Finder 沒有打開的視窗、也沒有正在拷貝的東西，就自動重新啟動 Finder。否則 Finder 頁面會出現一行簡短提示和「重新啟動 Finder」按鈕。

在系統設定中登入時打開的 App 列表裡，現在顯示新名稱 pikapik，並保持開啟。

**試試看：** 設定 › Finder

---

## <a id="v1.27.0"></a>來認識你的桌面寵物

<sub>1.27.0 · 2026年10月9日</sub>

螢幕底部住進了一個小夥伴，App 也有了新名字：pikapik。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

在設定 › 寵物中打開它。它會在視窗和 Dock 後面散步，指標擋路時跳過去，按空白鍵時跳一下。你可以把它拎起來、帶著走、丟出去，還能在它跳到半空時接住。

它偶爾會坐下來說句話。新版本真的推出時，它會告訴你一次，點一下它就會打開設定，更新就在那裡等著。

pika-tools 現在叫 pikapik。你的權限、設定和捷徑裡的連結都維持不變。如果你是用 Homebrew 安裝的，請執行一次 `brew update && brew upgrade --cask pikapik`。

**試試看：** 設定 › 寵物

**修正**

- 檢查更新時，即使你已經是最新版，也會提示有新版本。
- 打開權限頁面時會讓 Mac 一直忙碌。

---

## <a id="v1.26.2"></a>用你的語言看「新功能」

<sub>1.26.2 · 2026年10月8日</sub>

設定裡的「新功能」現在會打開這個頁面，語言和 App 一致。

<img src="../media/icon.png" width="128" height="128" alt="">

打開「設定 › 關於」，按一下「新功能」，就會直接來到這裡：每次更新都配有一張圖，語言和 pika-tools 一致。

完整的變更列表也更整齊了。每個版本都標明了發佈日期，點版本號碼就能打開它的下載頁面。

pika-tools 的使用方式沒有任何改變。更新照常送達，自動更新或透過 Homebrew 都可以。

**試試看：** 設定 › 關於 › 新功能

**修正**

- 「新功能」之前打開的是一份很長的英文技術列表，而不是這個頁面。
- 變更列表裡原本無處可去的連結，現在會打開正確的頁面。

---

## <a id="v1.26.1"></a>遊戲圖片動起來了

<sub>1.26.1 · 2026年10月8日</sub>

「遊戲」頁面上的圖片現在會動，一眼就能看出每個開關擋住了什麼。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

「遊戲」頁面的每個開關旁邊，現在都有一個小遊戲在進行。按鍵出現並被按下，你會看到有什麼會跳到遊戲上面，例如 Spotlight 或「指揮中心」，同時遊戲停住。開關打開時，按鍵只會柔和地亮一下，遊戲照常進行。切換開關，圖片會立刻顯示其中的差別。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

小遊戲會跟隨 Mac 的外觀：淺色模式是晴朗的白天，深色模式是有月亮和星星的寧靜夜晚。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

在 App 的所有圖片裡，指標現在像手一樣移動：遠的地方多花一點時間，停穩後才按下。圖片重新開始時，會平順地回到開頭，而不是跳回去。視窗被遮住時圖片會休息，打開「減少動態效果」後圖片保持不動。

**試試看：** 設定 › 遊戲

---

## <a id="v1.26.0"></a>新圖像，以及舊權限的大掃除

<sub>1.26.0 · 2026年10月8日</sub>

pika-tools 換上新面貌，現在還能清除已刪除 App 留下的權限。

<img src="../media/icon.png" width="128" height="128" alt="">

新圖像是深色方塊上藍、紫、珊瑚色的 pikapik 標誌。選單列也顯示同樣的形狀，並會配合淺色或深色選單列。所有工具都關閉時，這個形狀會變淡。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

刪除 App 後，macOS 仍會保留你給過它的權限，而「系統設定」沒有辦法移除。現在「權限」頁面有一個名為「已刪除 App 留下的權限」的列表：每個 App 都附上圖像，並顯示它曾被允許做什麼以及時間。「移除」清除一個 App，「全部移除」一次清除全部；重新安裝的 App 只會再問你一次。若要看到這個列表，請給 pika-tools 完整磁碟取用權限：在你按下「移除」之前，它只看不改。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

「動畫」和「遊戲」頁面的圖片依實際尺寸重新繪製，因此很清晰。視窗會帶著圓角縮進 Dock，指標先按一下，之後才打開選單。另外，「關於」底部多了一行低調的文字：「用心打造 · 請我喝杯咖啡」。不會跳出任何東西，也從不提醒你。

**試試看：** 設定 › 權限，然後查看「已刪除 App 留下的權限」

**修正**

- 按一下系統快速鍵會直接打開它在「系統設定」中的區塊，例如 Mission Control，而不只是「鍵盤」。
- 按鍵旁的提示不會再在「系統設定」打開的瞬間消失。

---

## <a id="v1.25.2"></a>按一下快速鍵，直接到能更改它的地方

<sub>1.25.2 · 2026年10月8日</sub>

在設定中按一下快速鍵，「系統設定」會在正確的位置打開。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

以前按一下快速鍵（例如 Spotlight 的快速鍵），總是會打開「變更鍵」。現在按一下 Spotlight 的按鍵，就會直接打開 Spotlight。

其他快速鍵會打開「系統設定」的「鍵盤」，按鍵旁會出現一則簡短提示，告訴你要按哪裡：先按「鍵盤快速鍵⋯」，再按「指揮中心」或其他部分。

「遊戲」頁面和「在 Finder 中剪下檔案」也一樣。剪下檔案時，提示會帶你到「App快速鍵」。

**試試看：** 設定 › 遊戲，然後按一下「搜尋不會跳出來」旁的按鍵

**修正**

- 按一下快速鍵不會再打開「變更鍵」。

---

## <a id="v1.25.1"></a>大圖片，遊戲直接從 Dock 選

<sub>1.25.1 · 2026年10月8日</sub>

每個開關現在都有一張大圖片，「加入遊戲…」會顯示 Dock 裡的內容。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

在「動畫」和「遊戲」頁面，所有圖片現在都變大了，和頁面最上方的那張一樣。一眼就看得懂每個開關做什麼，圖片仍照你選的速度播放。

按一下「加入遊戲…」，就能看到你的 Dock：放在那裡的 App 和正在打開的 App，順序也一樣。放在 Dock 裡的遊戲就算關著也會出現，Minecraft 也是。點一下就能加入，勾號表示它已在列表中。再點一下就能移除。

你仍然可以從 Finder 把遊戲拖到這裡。不用再把它從 Dock 裡拖出來，所以 Dock 也不會提示要移除它。

**試試看：** 設定 › 遊戲，然後按一下「加入遊戲…」

**修正**

- 放在 Dock 裡但沒有打開的遊戲，現在會出現在加入列表中。

---

## <a id="v1.25.0"></a>一鍵加入遊戲，按鍵也能自己決定

<sub>1.25.0 · 2026年10月8日</sub>

從正在打開的 App 裡挑選遊戲，結束和關閉用的按鍵也由你決定。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

按一下「加入遊戲…」，正在打開的 App 會像 Dock 裡那樣以大圖像排開。點一下就能加入，也可以把圖像拖進列表。還可以直接從 Finder 或 Dock 把遊戲拖進來。現在任何 App 都可以當作遊戲，連用 Java 執行的 Minecraft 也行；之前加入的遊戲都會保留。

遊戲模式的開關現在用白話說明，例如「遊戲不會關閉」或「搜尋不會跳出來」，每個開關還配了一張小圖，畫出它擋下的東西。系統裡的名稱，例如 Spotlight，會以灰色顯示在旁邊。

在「設定 › 視窗」中，按一下「結束 App」或「關閉視窗」旁邊的按鍵，然後按下新的按鍵。按 ⌫ 可恢復 ⇧⌘Q 和 ⇧⌘W；如果按鍵已被占用，pika-tools 會先問你。遊戲模式也會使用你的按鍵。另外，設定裡的每個快速鍵現在都會顯示它在你的 Mac 上實際的設定：你自己的按鍵，或「已關閉」。

**試試看：** 設定 › 遊戲，然後按一下「加入遊戲…」

**修正**

- 在 Finder 中剪下檔案時，會遵循你在「系統設定」裡為 Finder 設定的「剪下」快速鍵。
- 列表中的 App 名稱不再顯示「.app」。

---

## <a id="v1.24.1"></a>速度變化，馬上就看得到

<sub>1.24.1 · 2026年10月8日</sub>

「動畫」頁面現在會告訴你改動在哪裡生效，也會保護你自己設定的值。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Dock 只有在自動隱藏時才能滑得更快。如果你的 Dock 一直顯示，「自動隱藏和顯示 Dock」開關現在就在速度滑桿正下方。

改動之後，頁面底部會出現一行提示：重新打開 App 後生效。Finder 要重新啟動才會用上快速查看和直欄的新速度，所以這行提示裡有一個「重新啟動 Finder」按鈕。

滑桿絕不會讓你已經調快的東西變慢，例如你在終端機裡用指令調過的。「回復預設值」和解除安裝 pika-tools 會把你之前的值還回來，而不是把它們抹掉。

**試試看：** 設定 › 動畫

**修正**

- Dock 沒有自動隱藏時，不會再無故重新啟動。

---

## <a id="v1.24.0"></a>Mac 動得多快，由你決定

<sub>1.24.0 · 2026年10月8日</sub>

新的「動畫」頁面，決定 Mac 上的東西打開、滑出和出現得有多快。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

一個滑桿就夠了。拖動它，隱藏的 Dock、新視窗、儲存對話框、快速查看和 Finder 中的直欄會一起變快，從「與 macOS 相同」一直到「即時」。

只想調一項？每種效果都有自己的設定，縮到最小效果、Dock 裡跳動的圖像和 Finder 動畫也一樣。每項設定旁邊都有一張小圖，剛好照你選的速度在動。

「回復預設值」只還原 pika-tools 改過的內容，解除安裝時也一樣。如果你曾在終端機裡親自設定過其中某個值，pika-tools 會原樣顯示它。

**試試看：** 設定 › 動畫

---

## <a id="v1.23.2"></a>遊戲模式裡，每個快速鍵都有自己的開關

<sub>1.23.2 · 2026年10月8日</sub>

現在你可以一個一個決定，玩遊戲時遊戲模式要擋下哪些快速鍵。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q 和 ⌘W 現在有各自的開關，Spotlight、Siri、⌘Tab、指揮中心、滑動、指標、螢幕等其他項目也一樣。你之前的選擇都會保留。

每一行都準確顯示它擋下的按鍵，所以你總是知道一個開關管什麼。

鍵盤語言設定已從遊戲模式中移除。⌃空白鍵和其他切換語言的方式隨時可用，在遊戲裡也一樣。

**試試看：** 設定 › 遊戲

**修正**

- 同一個快速鍵的按鍵靠得更近，不同快速鍵之間多留了一點空間，一眼就能看出哪個在哪裡結束、下一個從哪裡開始。

---

## <a id="v1.23.1"></a>網速多快，用白話告訴你

<sub>1.23.1 · 2026年10月8日</sub>

「網速測試」會檢查你的網路連線，並簡單告訴你它夠做什麼。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

按一下「測速」，大約半分鐘後就能看到下載、上傳、Ping 和回應能力。數字下方用簡單的話說明，夠不夠看 4K 電影、視訊通話、玩線上遊戲和下載大型檔案。

測速在 Apple 的伺服器上進行，最近一次結果會一直保留到下一次測速。「網速測試」在設定裡有自己的頁面，在選單列面板裡有一行，還有一個給「捷徑」App 用的連結：`pika-tools://speed-test`。

遊戲模式學會了兩件事。阻擋 Control 快速鍵現在歸入了遊戲模式：在遊戲裡，⌃ 點按仍是一般點按，⌃ 快速鍵不會觸發；其他地方 ⌃ 照常使用。它還能辨識 Minecraft：把 Minecraft Launcher 或 CurseForge 加入你的遊戲，當 Minecraft 本身在最前面時，遊戲模式就會開啟。

**試試看：** 設定 › 網速測試，然後按一下「測速」

**修正**

- 自己編譯的 pika-tools 測試版會在 iCloud 雲碟裡分開儲存設定，不會再動到你的設定。

---

## <a id="v1.23.0"></a>遊戲模式：玩遊戲不被打擾

<sub>1.23.0 · 2026年10月7日</sub>

加入你的遊戲，Mac 就不會再把你拉出遊戲。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

玩遊戲時，Spotlight、Siri、⌘Tab、指揮中心和在桌面之間滑動都不會在遊戲上方打開。⌘Q 和 ⌘W 不會意外關閉遊戲，指標會留在遊戲所在的螢幕上，螢幕也保持開啟。

要結束遊戲，請按 ⇧⌘Q；要關閉遊戲視窗，請按 ⇧⌘W。⌥⌘Esc 永遠有效。pika-tools 會推薦它在你的 Mac 上找到的遊戲。遊戲模式預設關閉，要你打開才會生效。

「保持喚醒」現在可以選擇螢幕要怎麼做：一直亮著，不顯示螢幕保護程式和鎖定畫面；或者像平常一樣關閉，而 Mac 繼續工作。新的「立即關閉顯示器」按鈕會馬上讓螢幕變暗；移動滑鼠或按任意鍵就會恢復。

**試試看：** 設定 › 遊戲，然後按一下「加入遊戲…」

**修正**

- 在桌上型 Mac 上，「保持喚醒」不再顯示闔上螢幕相關的選項。

---

<p align="center"><sub>更早的版本請見<a href="../../CHANGELOG.md">更新記錄</a>（英文）。</sub></p>
