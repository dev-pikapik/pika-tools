<p align="center"><a href="../readme/README.ko.md"><img src="../media/icon.png" width="96" height="96" alt="pika-tools"></a></p>
<h1 align="center">pika-tools의 새로운 기능</h1>
<p align="center">업데이트마다 몇 마디 말과 그림 한 장으로, 최신 순으로 소개합니다.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <b>한국어</b> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.25.0"></a>클릭 한 번으로 게임 추가, 키도 직접 정하세요

<sub>1.25.0 · 2026년 10월 8일</sub>

지금 열려 있는 앱에서 게임을 고르고, 종료와 닫기에 쓸 키도 직접 정할 수 있습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

‘게임 추가…’를 누르면 지금 열려 있는 앱이 Dock처럼 큰 아이콘으로 나타납니다. 한 번 클릭하면 추가되고, 아이콘을 목록으로 끌어와도 됩니다. Finder나 Dock에서 게임을 바로 끌어다 놓을 수도 있습니다. 이제 어떤 앱이든 게임이 될 수 있고, Java로 실행되는 Minecraft도 마찬가지입니다. 전에 추가한 게임은 그대로 남아 있습니다.

게임 모드 스위치가 ‘게임이 종료되지 않음’이나 ‘검색이 튀어나오지 않음’처럼 쉬운 말로 바뀌었고, 각 스위치에는 무엇을 막는지 보여 주는 작은 그림이 붙었습니다. Spotlight 같은 시스템 이름은 옆에 회색으로 표시됩니다.

설정 › 윈도우에서 ‘앱 종료’나 ‘윈도우 닫기’ 옆의 키를 클릭하고 새 키를 누르세요. ⌫를 누르면 ⇧⌘Q와 ⇧⌘W로 돌아가고, 이미 쓰이는 키라면 pika-tools가 먼저 물어봅니다. 게임 모드도 직접 정한 키를 씁니다. 그리고 설정의 모든 단축키가 이제 Mac에 실제로 설정된 그대로 보입니다. 직접 정한 키가 보이거나 ‘끔’으로 표시됩니다.

**사용해 보기:** 설정 › 게임에서 ‘게임 추가…’

**수정 사항**

- Finder에서 파일 잘라내기는 시스템 설정에서 Finder의 ‘잘라내기’에 지정한 단축키를 따릅니다.
- 목록의 앱 이름이 ‘.app’ 없이 표시됩니다.

---

## <a id="v1.24.1"></a>바로 눈에 보이는 속도 변화

<sub>1.24.1 · 2026년 10월 8일</sub>

이제 애니메이션 페이지가 변경 사항이 어디에 나타나는지 알려 주고, 직접 정한 값도 지켜 줍니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Dock은 자동으로 가려질 때만 더 빨리 나타날 수 있습니다. Dock을 늘 표시해 두었다면, 이제 ‘자동으로 Dock 가리기와 보기’ 스위치가 속도 슬라이더 바로 아래에 있습니다.

변경하면 페이지 아래에 앱을 다시 열면 적용된다는 줄이 나타납니다. 훑어보기와 계층 보기의 새 속도는 Finder를 재시작해야 보이므로, 이 줄에는 ‘Finder 재시작’ 버튼이 있습니다.

슬라이더는 터미널 명령어 등으로 이미 빠르게 해 둔 것을 절대 느리게 만들지 않습니다. 또 ‘기본값으로 복원’이나 pika-tools 제거는 값을 지우지 않고 이전 값으로 되돌립니다.

**사용해 보기:** 설정 › 애니메이션

**수정 사항**

- Dock이 가려지지 않을 때 쓸데없이 재시작하지 않습니다.

---

## <a id="v1.24.0"></a>Mac이 움직이는 속도를 직접 고르세요

<sub>1.24.0 · 2026년 10월 8일</sub>

새 애니메이션 페이지에서 Mac의 모든 것이 열리고, 미끄러지고, 나타나는 속도를 정합니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

슬라이더 하나면 됩니다. 움직이면 가려진 Dock, 새 윈도우, 저장 대화상자, 훑어보기, Finder의 계층 보기가 한꺼번에 빨라집니다. ‘macOS와 동일’부터 ‘즉시’까지 고를 수 있습니다.

하나만 조절하고 싶나요? 효과마다 따로 설정이 있고, 최소화 효과, Dock에서 튀어오르는 아이콘, Finder 애니메이션도 마찬가지입니다. 각 설정 옆에서는 작은 그림이 고른 속도 그대로 움직입니다.

‘기본값으로 복원’은 pika-tools가 바꾼 것만 되돌리고, 앱을 제거할 때도 같습니다. 예전에 터미널에서 직접 정한 값이 있다면 pika-tools는 그 값을 그대로 보여 줍니다.

**사용해 보기:** 설정 › 애니메이션

---

## <a id="v1.23.2"></a>게임 모드의 단축키마다 스위치가 생겼습니다

<sub>1.23.2 · 2026년 10월 8일</sub>

이제 게임하는 동안 게임 모드가 무엇을 막을지 단축키마다 직접 정합니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q와 ⌘W의 스위치가 따로 생겼고, Spotlight, Siri, ⌘Tab, Mission Control, 쓸어넘기기, 포인터, 화면 등도 마찬가지입니다. 이전에 고른 설정은 그대로 유지됩니다.

각 줄에는 그 줄이 막는 키가 정확히 표시되어, 스위치가 무슨 일을 하는지 항상 알 수 있습니다.

키보드 언어 설정은 게임 모드에서 빠졌습니다. ⌃스페이스를 비롯한 언어 전환 방법은 게임 중에도 언제나 작동합니다.

**사용해 보기:** 설정 › 게임

**수정 사항**

- 한 단축키의 키들은 더 가깝게 붙고, 서로 다른 단축키 사이에는 여백이 조금 더 생겨 어디서 끝나고 어디서 시작하는지 쉽게 보입니다.

---

## <a id="v1.23.1"></a>인터넷 속도를 쉬운 말로

<sub>1.23.1 · 2026년 10월 8일</sub>

속도 테스트가 연결 상태를 확인하고, 무엇을 하기에 충분한지 쉽게 알려 줍니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

‘속도 측정’을 누르면 30초쯤 뒤에 다운로드, 업로드, 핑, 응답성이 나타납니다. 숫자 아래에는 4K 영화, 영상 통화, 온라인 게임, 큰 파일 다운로드에 충분한지 쉬운 말로 적혀 있습니다.

측정은 Apple 서버에서 이루어지고, 마지막 결과는 다음 측정 때까지 남아 있습니다. 속도 테스트는 설정에 자체 페이지가 있고, 메뉴 막대 패널에 한 줄이 있으며, 단축어 앱용 링크도 있습니다: `pika-tools://speed-test`.

게임 모드는 두 가지를 새로 배웠습니다. Control 단축키 차단이 이제 게임 모드의 일부가 되어, 게임 중에는 ⌃-클릭이 그냥 클릭으로 남고 ⌃ 단축키가 작동하지 않습니다. 게임 밖에서는 ⌃가 평소처럼 작동합니다. 또 Minecraft를 알아봅니다. Minecraft Launcher나 CurseForge를 게임에 추가하면 Minecraft 자체가 앞에 있을 때 게임 모드가 켜집니다.

**사용해 보기:** 설정 › 속도 테스트에서 ‘속도 측정’

**수정 사항**

- 직접 빌드한 pika-tools 테스트 버전은 iCloud Drive에 설정을 따로 저장하고, 더 이상 사용자의 설정을 건드리지 않습니다.

---

## <a id="v1.23.0"></a>게임 모드: 방해 없이 플레이하세요

<sub>1.23.0 · 2026년 10월 7일</sub>

게임을 추가해 두면 Mac이 더 이상 게임에서 끌어내지 않습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

플레이하는 동안 Spotlight, Siri, ⌘Tab, Mission Control, 데스크탑 간 쓸어넘기기가 게임 위에 열리지 않습니다. ⌘Q와 ⌘W로 게임이 실수로 닫히지 않고, 포인터는 게임 화면에 머물며, 화면도 꺼지지 않습니다.

게임을 끝내려면 ⇧⌘Q, 게임 윈도우를 닫으려면 ⇧⌘W를 누르세요. ⌥⌘Esc는 언제나 작동합니다. pika-tools가 Mac에서 찾은 게임을 추천합니다. 게임 모드는 직접 켜기 전까지 꺼져 있습니다.

잠자기 방지에서 화면을 어떻게 할지 고를 수 있습니다. 화면 보호기와 잠금 화면 없이 계속 켜 두거나, Mac은 계속 일하면서 화면만 평소처럼 꺼지게 할 수 있습니다. 새 ‘지금 디스플레이 끄기’ 버튼은 화면을 바로 끄고, 마우스를 움직이거나 키를 누르면 다시 켜집니다.

**사용해 보기:** 설정 › 게임에서 ‘게임 추가…’

**수정 사항**

- 덮개가 없는 Mac에서는 잠자기 방지에 덮개를 닫았을 때의 옵션이 더 이상 나타나지 않습니다.

---

<p align="center"><sub>이전 버전은 <a href="../../CHANGELOG.md">변경 기록</a>(영어)에서 볼 수 있습니다.</sub></p>
