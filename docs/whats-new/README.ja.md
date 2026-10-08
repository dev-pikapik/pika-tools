<p align="center"><a href="../readme/README.ja.md"><img src="../media/icon.png" width="96" height="96" alt="pika-tools"></a></p>
<h1 align="center">pika-toolsの新機能</h1>
<p align="center">アップデートごとに、短い言葉と1枚の絵で。新しい順に並んでいます。</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <b>日本語</b> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.25.1"></a>大きな絵と、Dockからそのままゲームを

<sub>1.25.1 · 2026年10月8日</sub>

どのスイッチにも大きな絵がつき、「ゲームを追加…」でDockにあるものが見えるようになりました。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

「アニメーション」と「ゲーム」のページでは、すべての絵がページ上部の絵と同じ大きさになりました。それぞれのスイッチが何をするのかひと目でわかり、絵は選んだ速さのまま動きます。

「ゲームを追加…」を押すと、Dockがそのまま並びます。Dockに置いているアプリと、いま開いているアプリが同じ順番で表示されます。Dockに置いたゲームは閉じていても表示され、Minecraftも出てきます。クリックひとつで追加され、チェックマークでリストに入ったことがわかります。もう一度クリックすると外せます。

これまでどおり、Finderからゲームをここへドラッグすることもできます。Dockから引き出す必要はもうないので、Dockが「削除しますか」と言ってくることもありません。

**試してみる：** 設定 › ゲーム で「ゲームを追加…」

**修正**

- Dockに置いてあって閉じているゲームも、追加のリストに表示されるようになりました。

---

## <a id="v1.25.0"></a>ワンクリックでゲームを追加、キーも自分で決められます

<sub>1.25.0 · 2026年10月8日</sub>

いま開いているアプリからゲームを選べて、終了と閉じるのキーも自分で決められます。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

「ゲームを追加…」を押すと、いま開いているアプリがDockのような大きなアイコンで並びます。クリックひとつで追加でき、アイコンをリストへドラッグしても追加できます。FinderやDockから直接ゲームをドロップすることもできます。どんなアプリでもゲームにでき、Javaで動くMinecraftも大丈夫です。これまで追加したゲームはそのまま引き継がれます。

ゲームモードのスイッチは「ゲームが終了しない」「検索が飛び出さない」のようなわかりやすい言葉になり、それぞれに何を止めるかを表す小さな絵が付きました。Spotlightなどのシステムでの名前は、横にグレーで表示されます。

設定 › ウインドウ で「アプリを終了」か「ウインドウを閉じる」の横のキーをクリックし、新しいキーを押します。⌫で⇧⌘Qと⇧⌘Wに戻り、そのキーがすでに使われているときは、pika-toolsが先に確認します。ゲームモードもあなたのキーを使います。さらに、設定に並ぶショートカットはすべて、あなたのMacで実際にどう設定されているかをそのまま表示します。自分で決めたキーか、「オフ」です。

**試してみる：** 設定 › ゲーム で「ゲームを追加…」

**修正**

- Finderでのファイルのカットは、システム設定でFinderの「カット」に割り当てたショートカットに従います。
- リスト内のアプリ名は「.app」なしで表示されます。

---

## <a id="v1.24.1"></a>速さの変化がすぐわかるように

<sub>1.24.1 · 2026年10月8日</sub>

「アニメーション」ページが、変更がどこに反映されるかを教えてくれるようになり、あなた自身の設定値も守ります。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Dockが速く出入りするのは、Dockを隠しているときだけです。いつも表示したままなら、「Dockを自動的に表示/非表示」スイッチが速度スライダーのすぐ下に表示されるようになりました。

変更すると、ページの下に「アプリを開き直すと反映されます」という一行が出ます。クイックルックとカラムの新しい速さはFinderを再起動してから反映されるので、この一行には「Finderを再起動」ボタンがあります。

スライダーは、ターミナルのコマンドなどであなたがすでに速くしていたものを遅くすることはありません。「デフォルトに戻す」やpika-toolsのアンインストールでは、値を消すのではなく、以前の値に戻します。

**試してみる：** 設定 › アニメーション

**修正**

- Dockを隠していないとき、Dockが無駄に再起動しなくなりました。

---

## <a id="v1.24.0"></a>Macの動きの速さを選べます

<sub>1.24.0 · 2026年10月8日</sub>

新しい「アニメーション」ページで、Macでものが開いたり、滑り出たり、現れたりする速さを決められます。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

スライダーひとつで十分です。動かすだけで、隠したDock、新しいウインドウ、保存ダイアログ、クイックルック、Finderのカラムがまとめて速くなります。「macOSと同じ」から「瞬時」まで選べます。

ひとつだけ調整したいときは？ エフェクトごとに個別の設定があり、しまうときのエフェクト、Dockの弾むアイコン、Finderのアニメーションも同じように設定できます。各設定の横では、小さな絵が選んだ速さそのままに動きます。

「デフォルトに戻す」で元に戻るのはpika-toolsが変えたものだけで、アンインストールしたときも同じです。以前ターミナルで自分で設定した値があれば、pika-toolsはそのまま表示します。

**試してみる：** 設定 › アニメーション

---

## <a id="v1.23.2"></a>ゲームモードのショートカットを1つずつオン/オフ

<sub>1.23.2 · 2026年10月8日</sub>

プレイ中にゲームモードが何を止めるか、ショートカットごとに選べるようになりました。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Qと⌘Wのスイッチが別々になりました。Spotlight、Siri、⌘Tab、Mission Control、スワイプ、ポインタ、画面なども同じように個別です。これまでの設定は引き継がれます。

各行には、その行が止めるキーがそのまま表示されるので、スイッチが何をするのかいつもわかります。

キーボードの入力言語の設定は、ゲームモードからなくなりました。⌃スペースなどの言語切り替えは、ゲーム中でもいつでも使えます。

**試してみる：** 設定 › ゲーム

**修正**

- 1つのショートカットのキーは近くにまとまり、別のショートカットとの間には少し余白ができました。どこで区切れているか、ひと目でわかります。

---

## <a id="v1.23.1"></a>インターネットの速さを、わかりやすい言葉で

<sub>1.23.1 · 2026年10月8日</sub>

「速度テスト」が接続を調べて、何に十分なのかをシンプルに教えてくれます。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

「速度を測定」を押すと、30秒ほどでダウンロード、アップロード、Ping、応答性が表示されます。数字の下には、4K動画、ビデオ通話、オンラインゲーム、大きなダウンロードに足りるかどうかが、わかりやすい言葉で書かれています。

測定はAppleのサーバで行われ、最後の結果は次に測定するまで残ります。「速度テスト」には設定内の専用ページ、メニューバーのパネルの行、「ショートカット」アプリ用のリンク `pika-tools://speed-test` があります。

ゲームモードは2つのことを覚えました。Controlショートカットのブロックがゲームモードの一部になり、ゲーム中は⌃-クリックがただのクリックのまま、⌃のショートカットも反応しません。ゲーム以外では⌃はいつも通りです。さらにMinecraftを認識します。Minecraft LauncherかCurseForgeをゲームに追加すると、Minecraft本体が前面にあるときにゲームモードがオンになります。

**試してみる：** 設定 › 速度テスト で「速度を測定」

**修正**

- 自分でビルドしたpika-toolsのテスト版は、iCloud Driveに設定を別々に保存し、あなたの設定に触れなくなりました。

---

## <a id="v1.23.0"></a>ゲームモード：じゃまされずにプレイ

<sub>1.23.0 · 2026年10月7日</sub>

ゲームを追加しておけば、Macがあなたをゲームから引き離さなくなります。

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

プレイ中は、Spotlight、Siri、⌘Tab、Mission Control、デスクトップ間のスワイプがゲームの上に開きません。⌘Qや⌘Wで誤ってゲームが閉じることもなく、ポインタはゲームの画面にとどまり、画面も消えません。

ゲームを終了するには⇧⌘Q、ウインドウを閉じるには⇧⌘Wを押します。⌥⌘Escはいつでも使えます。pika-toolsはMacで見つけたゲームを提案します。ゲームモードは、あなたがオンにするまでオフのままです。

「スリープさせない」では、画面の動きを選べるようになりました。スクリーンセーバーやロック画面なしでつけたままにするか、Macは動かしたまま、いつも通り画面を消すかです。新しい「今すぐディスプレイをオフ」ボタンで画面がすぐ暗くなり、マウスを動かすかキーを押すと戻ります。

**試してみる：** 設定 › ゲーム で「ゲームを追加…」

**修正**

- 蓋のないMacでは、「スリープさせない」に蓋を閉じたとき用のオプションが表示されなくなりました。

---

<p align="center"><sub>以前のバージョンは<a href="../../CHANGELOG.md">変更履歴</a>（英語）をご覧ください。</sub></p>
