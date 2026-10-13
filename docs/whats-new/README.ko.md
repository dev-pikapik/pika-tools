<p align="center"><a href="../readme/README.ko.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">pikapik의 새로운 기능</h1>
<p align="center">업데이트마다 몇 마디 말과 그림 한 장으로, 최신 순으로 소개합니다.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <b>한국어</b> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.39.4"></a>빨간색 버튼이 더 이상 압축 파일 작업을 멈추지 않아요

<sub>1.39.4 · 2026년 10월 13일</sub>

전에는 암호 창을 빨간색 버튼으로 닫으면 pikapik을 다시 시작할 때까지 압축 파일을 열거나 만들 수 없었어요. 이 문제를 고쳤어요.

이제 암호 창과 새 압축 파일 창의 빨간색 버튼은 ‘취소’와 똑같이 작동하고, 다음 압축 파일도 바로 열려요. 새 압축 파일에서 ‘암호’를 켜면 커서가 바로 암호 칸으로 가요. VoiceOver는 이제 설정 › 정보에 있는 업데이트 버튼을 버튼 자체의 이름으로 읽어요.

---

## <a id="v1.39.3"></a>펫이 내 리듬에 맞춰요

<sub>1.39.3 · 2026년 10월 13일</sub>

타이핑하는 동안 펫은 기운이 나서 경쾌한 발걸음으로 총총 걸어 다녀요. Mac 앞에서 자리를 비우면 졸음이 와서 앉더니 꾸벅꾸벅 졸기 시작해요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.3/pet-rhythm-dark.png"><img src="../media/whats-new/1.39.3/pet-rhythm-light.png" width="340" alt=""></picture>

키보드와 마우스를 40초쯤 쓰지 않으면 눈꺼풀이 무거워지고, 1분 30초가 지나면 푹 잠들어 작은 z가 둥실둥실 떠올라요. 아무 키나 누르거나 마우스를 움직이면 잠에서 깨어 일어나 다시 걸어가요. 조는 동안에는 조용히 지내고 에너지도 아껴요.

pikapik은 무엇을 입력하는지 절대 보지 않아요. 마지막으로 키를 누르거나 마우스를 움직인 뒤 얼마나 지났는지만 확인해요. macOS가 화면을 어둡게 하기 전에 확인하는 것과 같은 방식이라 따로 권한이 필요 없어요. 펫이 늘 활기찬 게 좋다면 펫 설정에서 ‘내 리듬에 맞춰요’를 끄세요.

**사용해 보기:** 설정 › 펫 › 내 리듬에 맞춰요

---

## <a id="v1.39.2"></a>동기화된 설정이 이제 pikapik 폴더에 있어요

<sub>1.39.2 · 2026년 10월 13일</sub>

iCloud로 설정을 동기화하고 있다면, 이제 설정은 iCloud Drive의 pika-tools 대신 pikapik 폴더에 저장되고, pikapik이 알아서 옮겨요.

<img src="../media/icon.png" width="128" height="128" alt="">

따로 할 일은 없어요. 설정은 그대로이고, 옮기기가 끝나면 이전 폴더는 사라져요. 그 폴더에 직접 넣은 파일이 있다면 폴더는 그대로 남아요. 여러 Mac에서 동기화한다면, 계속 설정을 공유할 수 있도록 각 Mac에서 pikapik을 업데이트하세요.

**수정 사항**

- Homebrew로 pikapik을 완전히 제거(brew uninstall --zap)하면 이제 최근 제거한 앱 목록도 함께 지워져요.
- 이 페이지의 이전 글에서도 이제 앱 이름이 pikapik으로 나와요.

---

## <a id="v1.39.1"></a>압축 파일 창에 익숙한 제목 막대

<sub>1.39.1 · 2026년 10월 13일</sub>

압축 파일 창에 macOS에서 익숙한 제목 막대와 왼쪽의 동그란 버튼 세 개가 다시 생겼어요.

Mac의 다른 창처럼 위쪽을 드래그해서 창을 옮길 수 있어요. 새 압축 파일 창과 암호 창에서 빨간색 버튼을 누르면 아무것도 만들거나 풀지 않고 창이 닫혀요. 창에서 쓸 일이 없는 버튼은 회색이에요. 작은 사본을 만들거나 파일을 변환할 때 진행 상황을 보여 주는 창에도 같은 버튼이 생겼어요. 이제 ‘압축 파일을 이 앱으로 열기’가 전에 ZIP과 7Z 파일을 열던 앱을 기억해 두었다가, 끄면 그 앱으로 되돌려요.

---

## <a id="v1.39.0"></a>새로워진 압축 파일 창, 암호는 두 번 입력

<sub>1.39.0 · 2026년 10월 13일</sub>

새 압축 파일에 암호를 걸 때 이제 두 번 입력합니다. 오타 때문에 내 파일을 못 여는 일이 없습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

두 암호가 같으면 입력란 아래에 초록색 줄이, 다르면 빨간색 줄이 나타나고, 같아질 때까지 ‘생성’은 누를 수 없습니다.

모든 압축 파일 창이 새 모습이 되었습니다. 큰 아이콘, 암호용 스위치 하나, 그리고 파일 이름이 ZIP처럼 그대로 보이는지, 7Z처럼 함께 숨겨지는지 알려 주는 짧은 줄이 있습니다. macOS 26에서는 버튼이 Liquid Glass로 되어 있습니다.

설치도 더 쉬워졌습니다. GitHub의 pikapik 페이지 맨 위에 있는 명령은 Mac에 다른 것을 설치하지 않아도 됩니다. 내려받은 파일에 개발자 서명이 있고 Apple의 악성 소프트웨어 검사를 통과한 경우에만 pikapik를 설치합니다.

---

## <a id="v1.38.2"></a>App Store 버전과 함께 있어도 더 안전한 업데이트

<sub>1.38.2 · 2026년 10월 12일</sub>

App Store 버전 pikapik도 Mac에 있다면, 이제 GitHub 버전은 제자리에서 업데이트되고 App Store 버전은 건드리지 않아요.

이전에는 GitHub 버전이 예전 이름인 pika-tools 그대로이고 Homebrew로 설치하지 않았다면, 업데이트가 설치되지 않고 대신 App Store 버전이 열렸어요. 게다가 로그인 시 pikapik 열기도 꺼졌어요.

---

## <a id="v1.38.1"></a>더 안정적인 Finder 메뉴

<sub>1.38.1 · 2026년 10월 12일</sub>

디스크를 연결하거나, 디스크 이미지를 열거나, Mac을 잠자기에서 깨우거나, Finder로 전환해도 Finder 오른쪽 클릭 메뉴의 pikapik 항목이 더 이상 사라지지 않아요.

드물게 이 항목을 보여 주는 도우미가 바로 그 순간 종료되는 일이 있었어요.

---

## <a id="v1.38.0"></a>Finder에서 압축 파일을 열고 만듭니다

<sub>1.38.0 · 2026년 10월 12일</sub>

새로운 ‘Finder의 압축 파일’은 macOS가 열지 못하는 RAR 등의 압축 파일을 열고, 오른쪽 클릭 메뉴로 ZIP과 7Z를 만듭니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

설정 › Finder를 열고 ‘Finder의 압축 파일’을 켜세요. 압축 파일을 오른쪽 클릭하고 ‘압축 풀기’를 선택하면 파일이 바로 옆에 나타납니다. 다른 파일이나 폴더를 오른쪽 클릭하고 ‘압축 파일 만들기…’를 선택하면 ZIP, 7Z, TAR.GZ, TAR.XZ를 만들 수 있습니다. ZIP과 7Z에는 암호를 걸 수 있고, 어떤 압축 파일이든 여러 부분으로 나눌 수 있습니다. 예를 들어 이메일용 15 MB씩으로 나눌 수 있습니다. 이렇게 만든 ZIP에는 숨겨진 서비스 파일이 들어가지 않고, 어떤 언어의 이름이든 읽을 수 있게 유지됩니다.

pikapik은 macOS가 열지 못하는 것도 엽니다. 여러 파일로 나뉜 RAR, 암호가 걸린 7Z, 그리고 ZIPX, CAB, LZH, ARJ, ZST, WIM 등입니다. 더블 클릭하면 pikapik에서 열립니다. 오래된 ZIP 안의 파일 이름도, 예를 들어 키릴 문자나 일본어, 중국어라도 제대로 읽힙니다. ‘압축 파일을 이 앱으로 열기’ 스위치를 켜면 ZIP과 7Z도 pikapik이 맡고, TAR와 GZ는 이미 잘 처리하는 Mac 기본 압축 앱에 그대로 남습니다.

암호는 창에서 물어보고, ‘중단’을 누르면 어떤 작업이든 취소되며, 손상된 압축 파일에서는 아직 읽을 수 있는 부분을 꺼내 옵니다. 풀면 엄청난 크기로 부풀어 오르는 압축 파일은 풀기 전에 먼저 묻고, 자기 폴더 밖에 쓰려는 압축 파일은 막습니다. Mac App Store 버전에는 없습니다. 압축 파일을 선택하고 스페이스 바를 누르면 안에 무엇이 들어 있는지 미리 볼 수 있습니다.

---

## <a id="v1.37.3"></a>FPS 표시가 알맞은 곳에서 권한을 요청합니다

<sub>1.37.3 · 2026년 10월 12일</sub>

FPS 표시에 필요한 화면 기록은 이제 다른 권한과 함께 ‘권한’ 페이지에서 허용합니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

게임의 프레임을 세려면 FPS 표시에 화면 기록이 필요할 수 있습니다. 전에는 pikapik이 ‘게임’ 페이지에서 바로 요청했습니다. 이제는 다른 모든 권한과 같은 곳에 모여 있습니다. FPS 표시에 필요해지면 설정 › 권한에 ‘화면 기록’ 항목이 나타나고, 거기서 허용을 누르면 됩니다.

‘게임’ 페이지에는 이제 스위치 아래에 늘 보던 한 줄, “권한이 필요합니다. 클릭하여 허용하세요.”만 나옵니다. 이 줄의 허용 버튼을 누르면 ‘화면 기록’ 항목으로 바로 이동합니다. FPS 표시를 켜도 더 이상 질문이 저절로 뜨지 않으며, 게임 중에는 pikapik이 예전처럼 아무것도 요청하지 않습니다.

---

## <a id="v1.37.2"></a>Apple이 확인했어요

<sub>1.37.2 · 2026년 10월 12일</sub>

pikapik은 이제 Apple이 확인한 개발자의 서명이 있고 Apple의 검사도 거쳤어요. 그래서 처음 열 때 macOS가 더 이상 경고하지 않아요.

이번 업데이트 후 macOS가 pikapik에 허용했던 권한(손쉬운 사용, 입력 모니터링, 전체 디스크 접근 등)을 다시 물어볼 수 있어요. 시스템 설정 › 개인정보 보호 및 보안에서 한 번 더 허용해 주세요. 팬 제어를 쓰고 있다면 pikapik 설정에서 다시 허용하세요. macOS가 암호를 한 번 물어봐요.

---

## <a id="v1.37.1"></a>FPS 표시가 게임을 바로 따라갑니다

<sub>1.37.1 · 2026년 10월 12일</sub>

게임 윈도우를 옮기면 이제 FPS 표시도 함께 움직입니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

이전에는 표시가 움직이는 윈도우를 약 1초에 한 번만 따라잡아서 뒤처졌습니다. 이제는 화면의 매 프레임마다 윈도우 위치를 확인하므로, 늦어도 몇 밀리초 안에 따라갑니다. 윈도우가 멈춰 있을 때는 확인 횟수를 줄여서, 게임하는 동안에도 Mac에 거의 부담을 주지 않습니다. 또한 윈도우 일부가 화면 가장자리 밖으로 나가도 표시가 다른 곳으로 튀지 않습니다.

체스처럼 조용한 게임에서 0이 표시되어도 문제없습니다. 이런 게임은 무언가 움직일 때만 새 그림을 그립니다. 말이 움직이는 동안에는 숫자가 올라가고, 판이 멈추면 다시 0으로 돌아갑니다.

---

## <a id="v1.37.0"></a>게임이 얼마나 부드러운지 확인하기

<sub>1.37.0 · 2026년 10월 12일</sub>

새 FPS 표시는 게임 모서리에 작은 카운터를 띄워, 게임이 얼마나 부드럽게 실행되는지 바로 보여 줘요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

설정 › 게임을 열고 FPS 표시를 켜 보세요. 게임 모드가 켜져 있는 동안 어떤 게임이든 한쪽 모서리에 숫자가 적힌 작고 어두운 표시가 나타나요. FPS는 초당 프레임 수, 즉 게임이 1초에 그리는 그림의 수이고, 숫자가 클수록 게임이 부드러워요. 스위치 위의 그림에서 모서리를 클릭하면 위치를 고를 수 있어요.

클릭은 표시를 그대로 통과하고, 표시는 게임 창을 따라다녀요. 줄표(—)는 첫 프레임이 아직 오지 않았다는 뜻이고, 흐린 0은 게임이 그리기를 멈췄다는 뜻이에요. FPS 표시는 직접 켜기 전까지 꺼져 있어요.

macOS 27에서는 대부분의 게임을 macOS가 직접 세므로 권한이 필요 없어요. 일부 게임, 주로 오래된 게임은 화면 기록으로만 셀 수 있고, 이 경우 숫자가 화면 주사율보다 높아질 수 없어요. macOS 14–26과 Mac App Store 버전에서는 모든 게임을 이렇게 세기 때문에, FPS 표시를 켜면 화면 기록 권한을 요청해요. 이미지는 저장되거나 전송되지 않아요.

---

## <a id="v1.36.0"></a>걱정 없이 앱 제거하기

<sub>1.36.0 · 2026년 10월 12일</sub>

새 앱 제거는 앱을 파일째 제거하고, 마음이 바뀌면 모두 되돌려 줘요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

설정 › 앱 제거를 열고 앱을 고르거나 그림 위에 끌어다 놓아 보세요. pikapik이 그 앱이 Mac에 남겨 둔 모든 것을 파일마다 이유와 함께 보여 줘요. 앱의 것이 분명한 파일은 체크되어 있고, 관련이 있을지도 모르는 파일은 체크되어 있지 않아요. 휴지통으로 이동을 클릭하면 모두 휴지통으로 가기 때문에 영구적으로 삭제되는 것은 없어요.

마음이 바뀌었나요? 되돌리기를 클릭하면 모든 것이 원래 자리로 돌아가요. 최근 제거한 10건은 파일이 휴지통에 있는 동안 최근 제거됨에 남아요. 앱 초기화는 앱은 그대로 두고 저장된 데이터와 설정, 임시 파일만 제거해서 앱이 이상하게 동작할 때 쓸 수 있어요.

직접 앱을 휴지통에 넣었나요? 그런 앱과 남은 파일도 페이지에 나타나고, 앱이 휴지통으로 갈 때마다 정리를 제안하는 스위치도 있어요. 직접 선택하기 전에는 아무것도 제거되지 않아요. 모두 보려면 전체 디스크 접근 권한이 필요해요.

---

## <a id="v1.35.0"></a>펫에게 옷을 입혀요

<sub>1.35.0 · 2026년 10월 12일</sub>

펫에게 옷장이 생겼어요. 함께 놀수록 입을 수 있는 옷이 늘어나요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

설정 › 펫을 열고 펫이 입을 것을 골라 보세요. 모자, 안경, 목도리, 셔츠, 신발, 망토, 날개까지 있어요. 고르면 바로 입어요. 처음부터 쓸 수 있는 건 몇 개뿐이고, 나머지는 함께 놀면서 받는 상이에요. 펫을 집어 던져 보고, 공을 차며 놀고, 창 위로 올라가거나 수다 떠는 모습을 지켜보거나, 그저 매일 곁에 있어 주세요. 상을 받으면 펫이 알려 줘요.

완성된 코디를 고르면 한 번에 머리부터 발끝까지 입혀 줘요. 마법사, 해적, 우주비행사, 슈퍼히어로, 왕 등이 있어요. 코디에 필요한 아이템을 모두 받으면 쓸 수 있어요.

걸음 수, 던진 횟수, 함께한 날짜 수 같은 간단한 숫자만 저장해요. 이 숫자는 이 Mac에만 남고 어디로도 전송되지 않아요. 설정 › 펫에서 언제든 지울 수 있어요.

---

## <a id="v1.34.0"></a>게임 중 마우스와 트랙패드

<sub>1.34.0 · 2026년 10월 12일</sub>

쓸어넘기기, 핀치, 핫 코너도 이제 키보드 단축키처럼 게임에서 벗어나게 하지 않습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

설정 › 게임 › 추가 게임 설정에 ‘마우스 및 트랙패드’ 그룹이 있습니다. macOS에서 켜져 있는 항목만 Apple의 이름과 작은 그림과 함께 보여 줍니다. 마우스 버튼 단축키, 데스크탑 및 전체 화면 앱 사이 쓸어넘기기, Mission Control과 App Exposé, 앱을 위한 핀치와 데스크탑을 위한 벌리기, 알림 센터를 위한 오른쪽 가장자리에서 쓸어넘기기, 그리고 각 핫 코너와 그 동작입니다. 게임이 맨 앞에 있는 동안에는 이 동작들이 일시 중지되어, 실수로 쓸어넘기거나 화면 모서리를 스치더라도 게임에서 벗어나지 않습니다. 게임 안의 제스처는 계속 작동합니다. 각 항목은 평소처럼 작동하도록 설정할 수도 있습니다.

---

## <a id="v1.33.2"></a>단축키 그룹이 바로 열려요

<sub>1.33.2 · 2026년 10월 11일</sub>

가장 긴 시스템 단축키 그룹도 곧바로 열리고, 모든 항목에 알기 쉬운 이름이 붙어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

예전에는 수십 개 항목이 있는 그룹을 열면 설정 창이 잠깐 멈췄어요. 모든 항목과 움직이는 미리보기를 한꺼번에 만들었기 때문이에요. 이제는 화면에 보이는 항목과 그 근처 몇 개만 만들어요. ‘시스템 동작’과 번호로만 표시되던 항목도 사라졌어요. 받아쓰기, Siri, 밝기와 확대/축소 키는 원래 이름으로 보이고, macOS가 이름을 붙이지 않은 동작은 숨겨지지만 예전처럼 게임 중에는 일시 중지돼요.

---

## <a id="v1.33.1"></a>단축키 그룹이 멈춤 없이 열립니다

<sub>1.33.1 · 2026년 10월 11일</sub>

미리보기가 많은 긴 목록을 열어도 게임 페이지가 부드럽게 동작합니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

이전에는 시스템 키보드 단축키 그룹을 열면 각 행과 미리보기를 여러 번 계산하느라 설정 창이 최대 3초 동안 멈췄습니다. 이제 각 행을 한 번만 계산하므로 그룹이 거의 바로 열립니다.

---

## <a id="v1.33.0"></a>모든 권한을 한곳에서

<sub>1.33.0 · 2026년 10월 11일</sub>

설정 › 권한에 pikapik이 쓰는 권한이 모두 모였고, 어떤 권한이든 직접 거둘 수 있어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

설정 › 권한에는 pikapik이 쓰는 모든 권한이 나와요. 손쉬운 사용과 입력 모니터링부터 팬 제어, Finder 확장 프로그램, iCloud Drive, 전체 디스크 접근 권한까지요. 각 줄에는 무엇에 쓰이는지 한 문장으로 적혀 있고, 켜져 있으면 초록색 체크, 빠져 있으면 주황색 엑스가 표시돼요.

줄마다 버튼은 하나예요. 권한이 없으면 허용, 켜져 있으면 끄기가 보여요. 그래서 시스템 설정을 뒤지지 않고도 그 자리에서 어떤 권한이든 거둘 수 있어요. 손쉬운 사용과 입력 모니터링은 pikapik이 먼저 물어본 뒤, 그 권한 없이 다시 시작해요.

아직 주지 않은 권한이 필요한 도구는 반쯤 회색으로 보여요. 눌러 보면 권한 화면이 열리면서 알맞은 줄이 강조돼요. 이제 허용만 한 번 누르면 돼요.

**사용해 보기:** 설정 › 권한을 열어 각 줄을 살펴보세요. 회색 도구를 누르면 그 도구에 필요한 권한으로 바로 이동해요.

---

## <a id="v1.32.2"></a>더 안전한 설치, 업데이트해도 앱이 사라지지 않아요

<sub>1.32.2 · 2026년 10월 11일</sub>

설치, 업데이트, 삭제를 더 안전하게 만드는 수정입니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

팬 도우미는 이제 더 신중하게 설치되고 시작 전에 확인됩니다. 업데이트를 복사하지 못해도 지금 쓰는 pikapik은 그대로 남습니다. 삭제하면 팬 도우미도 함께 제거되고, 키 반복 설정, Dock 모서리, 시스템 단축키가 원래대로 돌아옵니다.

도구가 다시 시작될 때 누르고 있던 키가 더는 걸리지 않고, ‘누르고 있는 키 반복’을 끄면 직접 정한 악센트 메뉴 설정이 돌아옵니다. 화면이 잠자기 중이거나 잠겨 있으면 펫도 쉬며, archive.tar.gz의 사본은 이제 archive 2.tar.gz로 불립니다.

---

## <a id="v1.32.1"></a>팬 수동 속도가 첫 시도부터 적용돼요

<sub>1.32.1 · 2026년 10월 11일</sub>

‘팬’에서 ‘수동’을 골라도 더 이상 자동으로 돌아가지 않아요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

처음 ‘수동’을 누르면 안전 경고와 함께 팬이 자동으로 돌아가고, 두 번째에야 적용되는 일이 있었어요. 이제 첫 시도부터 ‘수동’이 유지돼요.

팬이 스스로 수동에서 벗어나면 pikapik이 실제로 자동으로 되돌려요. 화면에 보이는 모습이 항상 Mac의 실제 동작과 같아요.

다시 허용할 필요는 없어요. 업데이트만 하면 바로 쓸 수 있어요.

**사용해 보기:** ‘설정’ › ‘팬’을 열고 ‘수동’을 선택하세요.

---

## <a id="v1.32.0"></a>팬이 얼마나 빠르게 도는지 확인하세요

<sub>1.32.0 · 2026년 10월 11일</sub>

새로운 팬 탭에서 모든 팬을 실시간으로 보고 속도도 고를 수 있어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

설정에 팬 탭이 생겼고 메뉴에도 전용 줄이 추가되었어요. 각 팬이 지금 얼마나 빠르게 돌고 있는지 실시간으로 볼 수 있고, 옆에서는 작은 팬이 함께 돌아요.

자동으로 두면 지금까지처럼 Mac이 알아서 정해요. 수동을 고르면 슬라이더 하나로 원하는 속도를 정할 수 있어요. 처음 한 번만 관리자 암호로 허용하면 끝이에요.

안전하게 쓸 수 있도록 만들었어요. pikapik을 종료할 때, Mac이 잠자기에 들어갈 때, pikapik이 비정상 종료될 때, Mac이 뜨거워질 때 팬은 자동으로 돌아가요.

**사용해 보기:** 설정 › 팬을 열어 속도를 확인해 보세요. 수동을 고르면 슬라이더를 써 볼 수 있어요.

---

## <a id="v1.31.4"></a>필요할 때 자세히

<sub>1.31.4 · 2026년 10월 11일</sub>

더 간결한 게임 페이지와 하나의 검색.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

각 모드의 동작 설명이 드롭다운 목록 안에 표시됩니다. 목록을 닫으면 선택한 이름만 페이지에 남습니다.

동작 이름을 반복하는 설명은 제거했습니다. 유용한 추가 정보는 유지했습니다.

전체 검색에서 이름, 의미, 키로 시스템 동작을 찾을 수 있습니다. 결과를 선택하면 해당 설정이 열리고 강조 표시됩니다.

**사용해 보기:** 전체 검색에서 동작을 찾고 모드 목록을 열어보세요.

---

## <a id="v1.31.3"></a>통일된 게임 설정 디자인

<sub>1.31.3 · 2026년 10월 11일</sub>

일관된 미리보기와 더 명확한 단축키 선택.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

모든 단축키가 게임 보호와 다른 설정 페이지처럼 넓은 미리보기를 사용합니다. 아래에 설명, 컨트롤, 선택한 옵션의 설명이 표시됩니다.

«게임 모드 규칙 따르기». 짧은 단축키로 메뉴 없이 언어를 바꿉니다. 게임 키를 누르고 있으면 실수로 언어가 바뀌지 않습니다.

«게임 중 비활성화». 게임이 맨 앞에 있는 동안 이 macOS 동작은 비활성화됩니다. 게임을 벗어나면 이전처럼 작동합니다. «게임 중 허용». 윈도우를 열거나 게임의 포커스를 가져가더라도 macOS가 동작을 정상 실행합니다.

**사용해 보기:** 추가 게임 설정에서 시스템 컨트롤을 펼치고 플레이 중 동작을 선택하세요.

---

## <a id="v1.31.2"></a>용도가 분명한 게임 설정

<sub>1.31.2 · 2026년 10월 11일</sub>

보호를 조정하고 Mac 단축키를 살펴보세요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

반복된 폴더를 여덟 가지 명확한 주제로 정리했습니다. 각 제목에는 이름, 설명, 아이콘, 개수가 있습니다. 행의 어느 곳이든 클릭하면 열립니다.

각 동작의 애니메이션 미리보기 옆에 용도를 설명합니다. 현재 키와 게임에서의 동작은 별도 행에 표시합니다. 설명도 검색할 수 있습니다.

지정되지 않은 키에는 시스템 설정으로 가는 링크가 표시됩니다. 일반 게임 보호는 별도 섹션에 모았으며 기존 선택은 유지됩니다.

**사용해 보기:** 추가 게임 설정을 열고 주제를 펼쳐 동작 설명과 미리보기를 비교하세요.

---

## <a id="v1.31.1"></a>게임 중 언어 전환 제스처

<sub>1.31.1 · 2026년 10월 11일</sub>

기본은 간단하게, 필요할 때는 전체 시스템 목록을 확인하세요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

macOS 언어 단축키가 지정되지 않았거나 꺼져 있어도 게임에서 pikapik 언어 전환 제스처를 사용할 수 있습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

자동 모드는 창을 열거나 포커스를 옮기는 동작을 일시 중지해요. 빠르고 의도적인 언어 단축키는 시스템 창 없이 입력 소스를 바꿔요. 누르고 있는 이동 키가 우선하므로 달리기와 점프가 실수로 언어를 바꾸지 않아요.

검색 가능한 목록에서 동작마다 조정할 수 있어요. 언어는 백그라운드에서 바꾸고 다른 동작은 중지하거나 평소처럼 허용할 수 있어요. 선택은 동기화돼요. 키를 관찰하는 다른 앱은 따로 표시되고 강제 종료는 계속 사용할 수 있어요.

**사용해 보기:** ⌥를 누른 채 ⇧를 누르면 다음 언어, ⇧를 누른 채 ⌥를 누르면 이전 언어

---

## <a id="v1.31.0"></a>게임 모드가 Mac의 단축키를 알아요

<sub>1.31.0 · 2026년 10월 11일</sub>

기본은 간단하게, 필요할 때는 전체 시스템 목록을 확인하세요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

게임 모드를 켜고 플레이하세요. 추가 게임 설정에는 Mac이 공개하는 목록, 현재 키 지정, 동작별 애니메이션 미리보기가 있어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

자동 모드는 창을 열거나 포커스를 옮기는 동작을 일시 중지해요. 빠르고 의도적인 언어 단축키는 시스템 창 없이 입력 소스를 바꿔요. 누르고 있는 이동 키가 우선하므로 달리기와 점프가 실수로 언어를 바꾸지 않아요.

검색 가능한 목록에서 동작마다 조정할 수 있어요. 언어는 백그라운드에서 바꾸고 다른 동작은 중지하거나 평소처럼 허용할 수 있어요. 선택은 동기화돼요. 키를 관찰하는 다른 앱은 따로 표시되고 강제 종료는 계속 사용할 수 있어요.

**사용해 보기:** 추가 게임 설정에서 캡처나 언어 단축키를 검색하고 보호 유무에 따른 미리보기를 비교하세요.

---

## <a id="v1.30.14"></a>단축키 링크가 충돌 없이 열려요

<sub>1.30.14 · 2026년 10월 11일</sub>

꺼진 단축키를 클릭해도 pikapik이 종료되지 않아요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

게임 페이지에서 키가 지정되지 않은 단축키도 클릭할 수 있어요. 시스템 설정이 안전하게 열려요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

이전에는 설정 창이 열리는 동안 변하는 같은 행을 두 번 읽기도 했어요. 그 사이 글자가 사라지면 앱이 충돌했어요.

이제 각 행을 한 번만 읽어요. 없는 글자는 건너뛰어요. 다른 페이지의 단축키 링크에도 적용돼요.

**사용해 보기:** 게임 페이지에서 꺼진 단축키를 클릭하세요.

---

## <a id="v1.30.13"></a>Control을 누른 채 계속 플레이하세요

<sub>1.30.13 · 2026년 10월 10일</sub>

Control을 누를 때 언어 전환이 게임의 스페이스 키를 가로채지 않아요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Control을 누른 채 달리고 스페이스로 점프하세요. 게임 모드에서는 Control+스페이스와 Control+Option+스페이스의 언어 전환이 일시 중지돼요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Control을 쓰거나 Command 없이 Shift, Option을 쓰는 다른 macOS 단축키와 직접 설정한 조합도 일시 중지돼요. 키 누르기, 떼기, 계속 누르기가 함께 게임에 전달돼요.

pikapik의 언어 전환 제스처와 게임 수정 키를 쓰는 종료 단축키도 방해하지 않아요. 게임을 떠나면 시스템 단축키가 원래대로 돌아와요.

**사용해 보기:** Control을 누른 채 이동하고 스페이스를 여러 번 누르세요. 게임을 떠난 뒤 평소처럼 언어를 바꿔 보세요.

---

## <a id="v1.30.12"></a>활성 상태 보기에서 게임을 드래그하세요

<sub>1.30.12 · 2026년 10월 10일</sub>

게임 모드가 활성 상태 보기에서 드래그한 프로세스를 받아요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

게임 프로세스를 찾아 설정 → 게임의 내 게임으로 행을 드래그하세요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Dock에 일반 아이콘이 없는 Java 게임도 추가할 수 있어요. 이전에는 파일 대신 프로세스 번호와 이름이 담긴 행이 무시되었어요.

게임은 다음 실행 때도 기억되고 Minecraft는 자기 이름으로 표시돼요. 번호와 이름은 실행 중인 프로세스와 일치해야 해요.

**사용해 보기:** 실행 중인 Minecraft의 java 행을 내 게임으로 드래그하세요.

---

## <a id="v1.30.11"></a>실행 중인 게임을 바로 추가하세요

<sub>1.30.11 · 2026년 10월 10일</sub>

게임을 추가할 때 열려 있는 게임이 먼저 표시돼요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

설정 → 게임 → 게임 추가에서 실행 중인 게임을 클릭하세요. Java나 다른 실행 환경을 사용하는 게임도 .app 파일 없이 표시돼요. Minecraft는 java 대신 Minecraft로 표시돼요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Dock의 앱은 별도의 접이식 목록으로 정리되어 실행 중인 게임을 바로 찾을 수 있어요.

기타…와 드래그 앤 드롭은 앱뿐 아니라 게임의 실행 파일도 받아요. 추가한 뒤 게임으로 전환하면 게임 모드가 켜져요.

**사용해 보기:** 게임을 열어 둔 채 게임 추가를 선택하고 아이콘을 클릭하세요. 폴더를 찾을 필요가 없어요.

---

## <a id="v1.30.10"></a>펫이 점프해도 보여요

<sub>1.30.10 · 2026년 10월 10일</sub>

Dock이 없는 화면에서 펫이 점프할 때 더 이상 창 뒤로 사라지지 않아요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

전에는 Dock이 다른 디스플레이에 있거나 숨겨져 있으면 펫이 창 뒤로 뛰어올라 착지할 때까지 보이지 않았어요. 이제는 땅에서 떨어지는 순간 Dock이 있든 없든 어느 화면에서나 창 앞에 보여요. 공도 마찬가지예요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

펫의 가장자리에만 닿은 창은 이제 점프하는 펫을 가리지 않아요. 보고 있는 영상처럼 창이 펫을 정말로 덮고 있을 때만 펫이 창 뒤에 머물러요.

땅에서는 예전처럼 펫과 공이 창 뒤에서 돌아다녀요.

**사용해 보기:** Dock을 자동으로 숨기거나 다른 디스플레이로 옮긴 다음, 창 옆에서 스페이스 바를 눌러 보세요. 펫이 창 앞에서 점프해요.

---

## <a id="v1.30.9"></a>전체 화면은 온전히 내 것, 공도 공정하게

<sub>1.30.9 · 2026년 10월 10일</sub>

전체 화면 영상에 펫이 더 이상 끼어들지 않고, 공도 없는 것에 부딪히지 않아요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

전에는 전체 화면으로 영상을 볼 때 펫이 가끔 튀어나왔어요. 이제 pikapik이 화면이 전체 화면인지 macOS에 직접 묻고, 전환이 끝나면 한 번 더 확인해요. 전체 화면에서 나올 때까지 펫과 공은 숨어 있어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

공이 빈 공간에서 튕겨 나오지 않아요. Dock 위의 보이지 않는 벽에 부딪히지 않고 그대로 넘어가요. 이제 마우스는 포인터가 공에 정말 닿을 때만 공을 쳐요. 살짝 닿으면 굴러가고, 빠르게 휘두르면 날아가요. 펫이나 공이 창 뒤에 숨어 있으면, 그 창 위에서 마우스를 움직여도 건드리지 않아요.

데스크탑에서 파일을 드래그해도 더 이상 펫의 발판이 생기지 않아요. 발판은 선택 상자로만 생겨요.

**사용해 보기:** 영상을 전체 화면으로 보면서 스페이스로 몇 번 일시 정지해 보세요. 펫은 나오지 않아요. 그다음 마우스로 공을 휙 쳐 보세요.

---

## <a id="v1.30.8"></a>게임하는 동안 화면 모서리가 조용해요

<sub>1.30.8 · 2026년 10월 10일</sub>

게임 모드에서 마우스를 화면 가장자리나 모서리로 옮겨도 이제 핫 코너가 켜지거나 숨긴 Dock이 나오지 않아요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

전에는 게임 도중 마우스가 화면 모서리나 가장자리로 가면 핫 코너가 켜지거나 숨긴 Dock이 튀어나오곤 했어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

이제 게임 모드가 게임하는 동안 핫 코너와 숨긴 Dock을 꺼 둬요. 게임을 끝내고 몇 초 뒤, 또는 pikapik을 종료하면 원래대로 돌아와요.

그리고 게임 화면 가장자리에서 포인터가 더 이상 끊기지 않아요.

**사용해 보기:** 게임 모드를 켜고 게임을 시작한 다음, 마우스를 화면 모서리로 옮겨 보세요. 아무것도 튀어나오지 않아요.

---

## <a id="v1.30.7"></a>펫이 더 이상 영상 앞에 끼어들지 않아요

<sub>1.30.7 · 2026년 10월 10일</sub>

펫이나 공이 창 뒤에 있으면 점프하거나 날아도 그대로 뒤에 있어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

전에는 펫이나 공이 영상이나 게임 뒤에 숨어 있어도, 점프하거나 날면 보고 있던 화면 위로 튀어나오곤 했어요. 영상을 멈추려고 스페이스 바를 눌러도 펫이 나왔고요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

이제는 무엇을 하든 자기를 가린 창 뒤에 그대로 있어요. 그리고 Firefox에서 영상을 전체 화면으로 보면 바로 숨어요.

일반 창 뒤로 숨는 건 전과 똑같아요.

**사용해 보기:** 화면 아래쪽까지 덮는 큰 창에서 영상을 틀고 스페이스 바로 멈춰 보세요. 펫은 영상 뒤에 그대로 있어요.

---

## <a id="v1.30.6"></a>전체 화면일 땐 펫이 모든 화면에서 쉬어요

<sub>1.30.6 · 2026년 10월 10일</sub>

어떤 앱이든 전체 화면일 때 펫과 공이 이제 모든 디스플레이에서 숨어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

전에는 영상이나 게임을 전체 화면으로 열면 펫과 공이 가끔 다른 화면으로 옮겨 가서 계속 놀았어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

이제 어떤 앱이든 전체 화면인 동안 모든 디스플레이에서 숨어요. 전체 화면을 끝내면 바로 돌아와요.

일반 창 뒤로 숨는 건 전과 똑같아요.

**사용해 보기:** 디스플레이가 두 대라면 한쪽에서 영상을 전체 화면으로 틀어 보세요. 펫과 공이 두 화면 모두에서 사라졌다가 전체 화면을 끝내면 돌아와요.

---

## <a id="v1.30.5"></a>영상을 보거나 게임할 때 펫이 비켜 줘요

<sub>1.30.5 · 2026년 10월 10일</sub>

앱이 전체 화면일 때 펫과 공이 이제 숨어요. 노치가 있는 Mac에서도요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

전에는 노치가 있는 Mac에서 펫이 전체 화면 영상이나 게임 위에 남아 있을 때가 있었고, 공이 다른 디스플레이의 전체 화면 앱 위로 튀어나오기도 했어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

이제 앱이 화면 전체를 채우는 동안 펫과 공은 보이지 않는 곳에서 기다려요. 전체 화면을 끝내면 바로 돌아와요.

일반 창 뒤로 숨는 건 전과 똑같아요.

**사용해 보기:** 영상을 전체 화면으로 틀거나 게임을 시작해 보세요. 다 끝날 때까지 펫과 공이 방해하지 않아요.

---

## <a id="v1.30.4"></a>펫이 점프하거나 선택 상자를 타고 올라가도 보여요

<sub>1.30.4 · 2026년 10월 10일</sub>

펫과 공이 공중에 있는 동안 더 이상 창 뒤로 사라지지 않아요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

전에는 펫이 포인터를 뛰어넘거나 선택 상자를 타고 올라가면 최대로 키운 창에 가려져서 펫이 사라진 것처럼 보였어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

이제 펫이나 공이 Dock보다 높이 있는 동안에는 창 앞에 보여요. 땅으로 돌아오면 다시 창 뒤로 가요.

그리고 펫은 예전처럼 다시 Dock 뒤를 걸어 다닐 수 있어요.

**사용해 보기:** 창을 최대로 키우고, 데스크탑에서 Dock 옆에 선택 상자를 그리기 시작해 펫이 올라타게 한 다음 천천히 위로 드래그해 보세요. 펫이 상자를 타고 창 앞으로 올라가요.

---

## <a id="v1.30.3"></a>펫과 공이 더 이상 Dock 아래로 숨지 않아요

<sub>1.30.3 · 2026년 10월 9일</sub>

펫이 더 이상 Dock 아래에서 걷거나 자지 않아서 언제나 보여요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

전에는 펫과 공이 아무도 볼 수 없는 Dock 바로 아래에서 자주 걷고 쉬었어요. 창을 최대로 키우면 펫이 아예 사라진 것처럼 보였어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

이제 Dock은 펫과 공에게 벽과 같아요. 펫은 Dock 가장자리에서 돌아서고, 공은 Dock에 맞고 튕겨 나와요.

그래서 창이 화면을 가득 채워도 펫은 언제나 Dock 옆에 보여요.

**사용해 보기:** 창을 최대로 키우고 몇 분 동안 지켜보세요. 펫이 언제나 Dock 왼쪽이나 오른쪽에 보여요.

---

## <a id="v1.30.2"></a>펫이 더 이상 창 뒤에서 사라지지 않아요

<sub>1.30.2 · 2026년 10월 9일</sub>

창에 가려져도 펫은 계속 움직이고, 선택을 놓으면 땅으로 떨어져요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

펫이 사는 띠를 창이 전부 가리면 pikapik이 펫을 일시 정지해서 펫이 공중에 멈춰 버릴 수 있었어요. 이제 펫과 공은 창 뒤에서도 계속 걷고, 떨어지고, 놀아요. 그리기만 잠시 쉬어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

선택 상자가 창 뒤에서 펫을 들어 올려도, 놓는 순간 펫이 떨어져서 다시 Dock 옆에 보여요.

그리고 선택 상자가 펫을 자기 띠보다 높이 들어 올리지 않아요.

**사용해 보기:** 창을 최대로 키우고, 그 뒤에서 선택 상자로 펫을 들어 올린 다음 놓아 보세요. 펫이 떨어져 Dock 옆에 나타나요.

---

## <a id="v1.30.1"></a>데스크탑 선택 상자가 다시 작동해요

<sub>1.30.1 · 2026년 10월 9일</sub>

펫과 공이 다시 선택 상자 위로 뛰어오르고, 앱 목록은 앱일 때만 빛나요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Dock이나 원격 데스크탑 앱이 화면 전체를 덮고 있으면 데스크탑에 그린 선택 상자를 pikapik이 알아채지 못했어요. 이제 다시 알아채고, 펫과 공이 예전처럼 그 위로 뛰어올라요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

설정의 앱 목록은 앱을 끌어왔을 때만 빛나요. 다른 파일은 무시돼서 테두리도 나타나지 않고 쓸데없는 항목도 추가되지 않아요. 앱을 다른 파일과 함께 끌어오면 앱만 추가돼요.

그리고 앱을 놓거나 포인터를 치우면 테두리가 바로 꺼져요.

**사용해 보기:** 데스크탑에 선택 상자를 그리고 펫이 그 위로 뛰어오르는 걸 지켜보세요.

---

## <a id="v1.30.0"></a>종료해도 pikapik이 꺼지지 않습니다

<sub>1.30.0 · 2026년 10월 9일</sub>

습관처럼 종료를 눌렀나요? 단축키, ‘잠자기 방지’, 펫은 그대로 계속 작동합니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

‘종료’를 선택하거나 ⌘Q를 누르거나 Dock에서 pikapik을 종료하면, 창을 닫고 메뉴 막대 아이콘을 숨기지만 백그라운드에서 조용히 계속 작동합니다. 단축키, ‘잠자기 방지’, 펫은 그대로 켜져 있습니다. 아이콘을 다시 보려면 pikapik을 한 번 더 열기만 하면 됩니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

정말 종료하고 싶다면 Option(⌥) 키를 누른 채 ‘종료’를 선택하거나 ⌥⌘Q를 누르세요. pikapik이 처음 백그라운드로 갈 때 무슨 일이 일어났는지 알려 주고, 그 자리에서 완전히 종료할 수도 있습니다.

예전 방식이 더 좋다면 설정 › 일반에서 ‘종료 후에도 백그라운드에서 실행’을 끄세요. 업데이트, 언어 변경, 로그아웃, 재시동, 시스템 종료 때는 언제나 pikapik이 완전히 종료되므로 기다릴 일이 없습니다.

**사용해 보기:** ⌘Q를 누른 다음 pikapik을 다시 열어 아이콘을 되돌려 보세요.

---

## <a id="v1.29.1"></a>펫이 모든 화면을 걸어 다녀요

<sub>1.29.1 · 2026년 10월 9일</sub>

모니터가 두 대 이상인가요? 이제 펫과 공이 어느 화면이든 함께하고, 길을 잃지도 않아요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

펫이 한 화면의 가장자리에 닿으면 그대로 옆 화면으로 넘어가고, 공도 뒤따라 굴러가요. 마우스로 펫이나 공을 들어 원하는 화면으로 옮길 수도 있어요. 앱이 전체 화면이 되면 방해되지 않게 다른 화면으로 옮겨 가고, 모니터를 빼면 주 화면으로 돌아와요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

공이 더 이상 구석에 끼지 않아요. 펫이 달려가 공을 머리 위로 뒤로 퍼 올리고 계속 놀아요.

그리고 펫이 더는 사라지지 않아요. 2초마다 화면에 있는지 스스로 확인하고, 잠자기, Mac 잠금, 데스크탑 전환, 전체 화면 뒤에 문제가 생겨도 곧바로 알아서 돌아와요.

**사용해 보기:** 펫을 다른 화면으로 옮기거나 공을 구석으로 굴려 보세요.

**수정 사항**

- 던진 펫이 닿을 수 없을 만큼 높은 선택 상자에 내려앉았다가 사라지는 일이 없어졌어요.

---

## <a id="v1.29.0"></a>펫에게 공이 생겼어요

<sub>1.29.0 · 2026년 10월 9일</sub>

이제 화면 아래쪽에서 작은 축구공이 굴러다녀요. 펫이 공을 가지고 놀고, 여러분도 함께 놀 수 있어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

공은 진짜처럼 구르고 튀어요. 펫은 공을 쫓아가서 차고, 다시 쫓아가요. 포인터를 공 쪽으로 빠르게 움직이면 직접 찰 수 있고, 펫처럼 공을 집어 들고 옮겨서 던질 수도 있어요.

작은 비법이 있어요. 데스크탑의 빈 곳을 클릭하고 드래그해서 선택 상자를 그려 보세요. Shift를 눌러도 괜찮아요. 마우스 버튼을 누르고 있는 동안 상자는 선반이 돼요. 펫이 그 위로 뛰어오르고, 공도 올라갈 수 있어요. 버튼을 놓으면 선반은 사라져요.

데스크탑이 조용한 게 좋다면 펫 설정에서 ‘공’을 끄세요. 펫은 다시 혼자 산책해요.

**사용해 보기:** 설정 › 펫 › 공

**수정 사항**

- Dock 옆에서는 펫이 다시 마음껏 높이 뛰어요. Dock 바로 위에 있을 때만 낮게 있어서 Dock 위로 삐져나오지 않아요.

---

## <a id="v1.28.0"></a>클릭이나 드래그로 앱 추가

<sub>1.28.0 · 2026년 10월 9일</sub>

설정의 모든 앱 목록에 이제 Dock에 있는 앱과 지금 열려 있는 앱이 보이고, Finder에서 앱을 끌어다 놓을 수도 있습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

초록색 버튼이나 Home과 End처럼 어떤 기능은 비켜 줄 앱을 고를 수 있어요. 예전에는 ‘앱 추가…’를 누르면 모든 것이 들어 있는 긴 폴더만 열렸습니다. 이제는 Dock의 앱과 지금 열려 있는 앱이 선반에 놓입니다. 앱을 클릭하면 추가되고, 한 번 더 클릭하면 빠집니다. 그 밖의 앱은 ‘기타…’에서 고르세요.

Finder에서 앱을 목록 위로 바로 끌어다 놓을 수도 있어요. 목록이 빛나며 앱이 들어갈 자리를 보여 줍니다. 게임도 같은 선반으로 똑같이 추가할 수 있어요.

문제가 생겼을 때 쓰는 GitHub 버그 신고 양식에서 이제 pikapik과 macOS 버전을 목록에서 고를 수 있어서, 알려 주시는 시간이 줄어듭니다.

**사용해 보기:** 설정 › 윈도우에서 ‘앱 추가…’

**수정 사항**

- 두 Mac 모두 클래식 스크롤 방향을 쓸 때 AnyDesk 같은 원격 데스크톱 앱을 통한 스크롤이 더 이상 두 번 뒤집히지 않습니다. 이제 pikapik은 실제 마우스나 트랙패드의 스크롤만 뒤집습니다. Mos처럼 자체적으로 부드러운 스크롤을 만드는 앱은 그 앱에서 방향을 설정하세요.
- 펫은 점프할 때도 걸을 때처럼 Dock 뒤에 머물고, 전체 화면 앱이나 게임에서 나오면 스스로 돌아옵니다.
- 설정의 작은 그림을 둘러싼 얇은 테두리가 Retina가 아닌 일반 디스플레이에서 더 이상 사라지지 않습니다.

---

## <a id="v1.27.3"></a>펫은 언제나 보이고, 창은 바로 쓸 수 있게 열려요

<sub>1.27.3 · 2026년 10월 9일</sub>

펫이 점프 도중에 창 뒤로 숨지 않고, pikapik 창은 바로 쓸 수 있는 상태로 열려요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

펫이 포인터를 뛰어넘거나 데굴데굴 구르면 다른 앱의 창 뒤로 들어가 공중에서 사라질 때가 있었어요. 이제는 점프하는 내내 앞에 있다가, 땅에 내려오면 다시 창 뒤로 돌아가요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

로그인할 때, 업데이트한 뒤, pikapik:// 링크로 pikapik이 백그라운드에서 조용히 시작되면 창이 회색으로 열리고 클릭할 때까지 다른 창 뒤에 남아 있을 때가 있었어요. 이제 설정과 새 파일 창이 앞으로 나와서 바로 입력할 수 있어요.

작은 사본 만들기 뒤에 나오는 메시지와 추가할 앱을 고르는 목록도 마찬가지예요. 따로 하실 일은 없어요.

**사용해 보기:** 설정 › 펫

---

## <a id="v1.27.2"></a>새 파일이 돌아오고, 설정은 더 가벼워졌어요

<sub>1.27.2 · 2026년 10월 9일</sub>

이제 모두의 Finder 오른쪽 클릭 메뉴에 새 파일이 다시 나타나고, 설정은 Mac에 부담을 더 적게 줘요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

지난 업데이트 뒤 Finder가 새 파일을 백그라운드에서 다시 시작하면서 어느 폴더에서 동작하는지 잊어버릴 때가 있었어요. 그러면 오른쪽 클릭 메뉴에서 항목이 조용히 사라졌죠. 이제 새 파일은 시작할 때마다 Finder에 폴더를 다시 알려 주고, pikapik도 실행 직후 Finder가 잘 기억하는지 확인해요. 따로 할 일은 없어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

설정의 움직이는 그림은 이제 그림의 절반 이상이 화면에 보일 때만 움직여요. 게임 그림 속 작은 주인공은 여전히 1초에 30번, 뒤의 언덕과 땅은 15번 움직여요. 그래서 게임 페이지가 Mac에 주는 부담이 훨씬 줄었어요. 모습은 그대로예요.

업데이트 뒤에는 앱이 정말로 다른 위치로 옮겨졌을 때만 Finder 항목을 다시 등록해요. 그래서 Finder가 매번 다시 불러올 필요가 없어요.

**사용해 보기:** 설정 › 게임

---

## <a id="v1.27.1"></a>더 조용하고 가볍게, Finder도 바로

<sub>1.27.1 · 2026년 10월 9일</sub>

설정이 Mac에 거의 부담을 주지 않고, pikapik으로 옮긴 직후부터 Finder 오른쪽 클릭 항목이 작동합니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

설정의 작은 움직이는 그림이 예전에는 1초에 여러 번 페이지 전체를 다시 그려서, 창을 열어 두기만 해도 Mac이 바빴습니다. 이제 각 그림은 자기 자신만 1초에 최대 30번 다시 그리고, 스크롤해서 안 보이거나 창을 가리면 쉽니다. 모양은 그대로입니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

pika-tools에서 pikapik으로 옮긴 뒤 Finder가 예전 앱을 계속 찾아서 ‘새 파일’, ‘변환’ 같은 오른쪽 클릭 항목이 작동하지 않을 수 있었습니다. 이제 pikapik이 처음 실행할 때 이를 알아차리고, 열린 Finder 창이 없고 복사 중인 것도 없으면 Finder를 알아서 재시작합니다. 그렇지 않으면 Finder 페이지에 짧은 안내와 ‘Finder 재시작’ 버튼이 나타납니다.

시스템 설정의 로그인 시 열리는 앱 목록에 이제 새 이름 pikapik으로 표시되고, 켜진 상태로 유지됩니다.

**사용해 보기:** 설정 › Finder

---

## <a id="v1.27.0"></a>데스크탑 펫을 소개해요

<sub>1.27.0 · 2026년 10월 9일</sub>

이제 화면 아래쪽에 작은 친구가 살아요. 그리고 앱 이름이 pikapik으로 바뀌었어요.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

설정 › 펫에서 켜 보세요. 윈도우와 Dock 뒤를 산책하고, 포인터가 길을 막으면 뛰어넘고, 스페이스를 누르면 점프해요. 집어서 옮기고, 던지고, 점프하는 도중에 다시 잡을 수도 있어요.

가끔 앉아서 짧게 한마디 해요. 새 버전이 정말 나오면 한 번만 알려 주고, 펫을 클릭하면 업데이트가 기다리는 설정이 열려요.

pika-tools는 이제 pikapik이에요. 권한, 설정, 단축어 링크는 모두 그대로예요. Homebrew로 설치했다면 `brew update && brew upgrade --cask pikapik`을 한 번 실행하세요.

**사용해 보기:** 설정 › 펫

**수정 사항**

- 이미 최신 버전인데도 업데이트 확인에서 새 버전이 있다고 나오던 문제를 고쳤어요.
- 권한 페이지를 열어 두면 Mac이 계속 바빴어요.

---

## <a id="v1.26.2"></a>‘새로운 기능’을 내 언어로

<sub>1.26.2 · 2026년 10월 8일</sub>

설정의 ‘새로운 기능’이 이제 앱과 같은 언어로 이 페이지를 엽니다.

<img src="../media/icon.png" width="128" height="128" alt="">

설정 › 정보에서 ‘새로운 기능’을 클릭하면 바로 이곳으로 옵니다. 업데이트마다 그림이 있는 이 페이지가 pikapik과 같은 언어로 열립니다.

전체 변경 목록도 더 깔끔해졌습니다. 버전마다 나온 날짜가 표시되고, 버전 번호를 누르면 해당 다운로드 페이지가 열립니다.

pikapik이 작동하는 방식은 그대로입니다. 업데이트는 전처럼 저절로, 또는 Homebrew로 받습니다.

**사용해 보기:** 설정 › 정보 › 새로운 기능

**수정 사항**

- ‘새로운 기능’이 이 페이지 대신 영어로 된 긴 기술 목록을 열었습니다.
- 변경 목록에서 아무 데도 연결되지 않던 링크가 이제 올바른 페이지를 엽니다.

---

## <a id="v1.26.1"></a>게임 그림이 살아 움직입니다

<sub>1.26.1 · 2026년 10월 8일</sub>

‘게임’ 페이지의 그림이 이제 움직여서, 각 스위치가 무엇을 막는지 바로 보입니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

‘게임’ 페이지의 스위치마다 작은 게임이 돌아갑니다. 키가 나타나 눌리면 Spotlight나 Mission Control처럼 게임 위로 튀어나올 것이 보이고, 게임은 멈춥니다. 스위치가 켜져 있으면 키가 부드럽게 빛날 뿐 게임은 계속됩니다. 스위치를 바꾸면 그림이 그 차이를 바로 보여 줍니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

작은 게임은 Mac의 화면 모드를 따릅니다. 라이트 모드에서는 맑은 낮, 다크 모드에서는 달과 별이 뜬 고요한 밤입니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

앱의 모든 그림에서 포인터가 이제 손처럼 움직입니다. 먼 곳은 조금 더 천천히 가고, 멈춘 다음에야 클릭합니다. 그림이 처음으로 돌아갈 때도 뛰지 않고 부드럽게 돌아갑니다. 윈도우가 가려져 있으면 그림은 쉬고, ‘동작 줄이기’를 켜면 멈춰 있습니다.

**사용해 보기:** 설정 › 게임

---

## <a id="v1.26.0"></a>새 아이콘, 그리고 오래된 권한 정리

<sub>1.26.0 · 2026년 10월 8일</sub>

pikapik이 새 얼굴을 갖췄고, 이제 삭제한 앱이 남긴 권한도 지울 수 있습니다.

<img src="../media/icon.png" width="128" height="128" alt="">

새 아이콘은 어두운 타일 위에 파랑, 보라, 코럴로 그린 pikapik 마크입니다. 메뉴 막대에도 같은 모양이 나타나며, 밝은 메뉴 막대와 어두운 메뉴 막대에 맞춰집니다. 모든 도구가 꺼져 있으면 모양이 흐려집니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

앱을 삭제해도 macOS는 그 앱에 준 권한을 그대로 남겨 두고, 시스템 설정에서는 지울 방법이 없습니다. 이제 ‘권한’ 페이지에 ‘삭제한 앱이 남긴 권한’ 목록이 생겼습니다. 앱마다 아이콘과 무엇이 허용되었는지, 언제였는지가 표시됩니다. ‘제거’는 앱 하나를, ‘모두 제거’는 전부를 지우며, 다시 설치한 앱은 그냥 한 번 더 물어봅니다. 목록을 보려면 pikapik에 전체 디스크 접근 권한을 주세요. ‘제거’를 누르기 전까지는 보기만 하고 아무것도 바꾸지 않습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

‘애니메이션’과 ‘게임’ 페이지의 그림을 실제 크기에 맞게 새로 그려서 선명해졌습니다. 윈도우는 둥근 모서리 그대로 Dock으로 줄어들고, 포인터가 먼저 클릭한 다음에야 메뉴가 열립니다. 그리고 ‘정보’ 아래쪽에 조용한 한 줄 ‘정성껏 만들었습니다 · 커피 한 잔 사 주기’가 생겼습니다. 아무것도 튀어나오지 않고, 다시 알려 주지도 않습니다.

**사용해 보기:** 설정 › 권한에서 ‘삭제한 앱이 남긴 권한’

**수정 사항**

- 시스템 단축키를 클릭하면 ‘키보드’만이 아니라 Mission Control처럼 그 단축키가 있는 섹션이 시스템 설정에서 바로 열립니다.
- 키 옆의 도움말이 시스템 설정이 열리자마자 사라지지 않습니다.

---

## <a id="v1.25.2"></a>단축키를 바꾸는 곳이 바로 열립니다

<sub>1.25.2 · 2026년 10월 8일</sub>

설정에서 단축키를 클릭하면 시스템 설정의 올바른 위치가 열립니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

이전에는 Spotlight 같은 단축키를 클릭하면 항상 ‘보조 키’가 열렸습니다. 이제 Spotlight 키를 클릭하면 바로 Spotlight가 열립니다.

다른 단축키는 시스템 설정의 ‘키보드’가 열리고, 키 옆에 어디를 클릭할지 알려 주는 짧은 도움말이 나타납니다. ‘키보드 단축키…’를 클릭한 다음 ‘Mission Control’ 같은 항목을 클릭하세요.

‘게임’ 페이지와 ‘Finder에서 파일 잘라내기’도 똑같습니다. 파일을 잘라낼 때는 도움말이 ‘앱 단축키’로 안내합니다.

**사용해 보기:** 설정 › 게임에서 ‘검색이 튀어나오지 않음’ 옆의 키를 클릭

**수정 사항**

- 단축키를 클릭해도 더 이상 ‘보조 키’가 열리지 않습니다.

---

## <a id="v1.25.1"></a>큰 그림, 그리고 Dock에서 바로 고르는 게임

<sub>1.25.1 · 2026년 10월 8일</sub>

모든 스위치에 큰 그림이 생겼고, ‘게임 추가…’에서 Dock에 있는 것이 보입니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

‘애니메이션’과 ‘게임’ 페이지의 그림이 모두 페이지 맨 위 그림처럼 커졌습니다. 스위치마다 무엇을 하는지 한눈에 보이고, 그림은 여전히 고른 속도대로 움직입니다.

‘게임 추가…’를 누르면 Dock이 그대로 보입니다. Dock에 둔 앱과 지금 열려 있는 앱이 같은 순서로 나옵니다. Dock에 둔 게임은 닫혀 있어도 보이고, Minecraft도 나옵니다. 한 번 클릭하면 추가되고, 체크 표시로 목록에 들어갔다는 것을 알 수 있습니다. 한 번 더 클릭하면 뺄 수 있습니다.

예전처럼 Finder에서 게임을 여기로 끌어올 수도 있습니다. 이제 Dock에서 끌어낼 필요가 없으니 Dock이 제거하겠느냐고 묻지도 않습니다.

**사용해 보기:** 설정 › 게임에서 ‘게임 추가…’

**수정 사항**

- Dock에 있지만 닫혀 있는 게임도 이제 추가 목록에 나옵니다.

---

## <a id="v1.25.0"></a>클릭 한 번으로 게임 추가, 키도 직접 정하세요

<sub>1.25.0 · 2026년 10월 8일</sub>

지금 열려 있는 앱에서 게임을 고르고, 종료와 닫기에 쓸 키도 직접 정할 수 있습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

‘게임 추가…’를 누르면 지금 열려 있는 앱이 Dock처럼 큰 아이콘으로 나타납니다. 한 번 클릭하면 추가되고, 아이콘을 목록으로 끌어와도 됩니다. Finder나 Dock에서 게임을 바로 끌어다 놓을 수도 있습니다. 이제 어떤 앱이든 게임이 될 수 있고, Java로 실행되는 Minecraft도 마찬가지입니다. 전에 추가한 게임은 그대로 남아 있습니다.

게임 모드 스위치가 ‘게임이 종료되지 않음’이나 ‘검색이 튀어나오지 않음’처럼 쉬운 말로 바뀌었고, 각 스위치에는 무엇을 막는지 보여 주는 작은 그림이 붙었습니다. Spotlight 같은 시스템 이름은 옆에 회색으로 표시됩니다.

설정 › 윈도우에서 ‘앱 종료’나 ‘윈도우 닫기’ 옆의 키를 클릭하고 새 키를 누르세요. ⌫를 누르면 ⇧⌘Q와 ⇧⌘W로 돌아가고, 이미 쓰이는 키라면 pikapik이 먼저 물어봅니다. 게임 모드도 직접 정한 키를 씁니다. 그리고 설정의 모든 단축키가 이제 Mac에 실제로 설정된 그대로 보입니다. 직접 정한 키가 보이거나 ‘끔’으로 표시됩니다.

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

슬라이더는 터미널 명령어 등으로 이미 빠르게 해 둔 것을 절대 느리게 만들지 않습니다. 또 ‘기본값으로 복원’이나 pikapik 제거는 값을 지우지 않고 이전 값으로 되돌립니다.

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

‘기본값으로 복원’은 pikapik이 바꾼 것만 되돌리고, 앱을 제거할 때도 같습니다. 예전에 터미널에서 직접 정한 값이 있다면 pikapik은 그 값을 그대로 보여 줍니다.

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

측정은 Apple 서버에서 이루어지고, 마지막 결과는 다음 측정 때까지 남아 있습니다. 속도 테스트는 설정에 자체 페이지가 있고, 메뉴 막대 패널에 한 줄이 있으며, 단축어 앱용 링크도 있습니다: `pikapik://speed-test`.

게임 모드는 두 가지를 새로 배웠습니다. Control 단축키 차단이 이제 게임 모드의 일부가 되어, 게임 중에는 ⌃-클릭이 그냥 클릭으로 남고 ⌃ 단축키가 작동하지 않습니다. 게임 밖에서는 ⌃가 평소처럼 작동합니다. 또 Minecraft를 알아봅니다. Minecraft Launcher나 CurseForge를 게임에 추가하면 Minecraft 자체가 앞에 있을 때 게임 모드가 켜집니다.

**사용해 보기:** 설정 › 속도 테스트에서 ‘속도 측정’

**수정 사항**

- 직접 빌드한 pikapik 테스트 버전은 iCloud Drive에 설정을 따로 저장하고, 더 이상 사용자의 설정을 건드리지 않습니다.

---

## <a id="v1.23.0"></a>게임 모드: 방해 없이 플레이하세요

<sub>1.23.0 · 2026년 10월 7일</sub>

게임을 추가해 두면 Mac이 더 이상 게임에서 끌어내지 않습니다.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

플레이하는 동안 Spotlight, Siri, ⌘Tab, Mission Control, 데스크탑 간 쓸어넘기기가 게임 위에 열리지 않습니다. ⌘Q와 ⌘W로 게임이 실수로 닫히지 않고, 포인터는 게임 화면에 머물며, 화면도 꺼지지 않습니다.

게임을 끝내려면 ⇧⌘Q, 게임 윈도우를 닫으려면 ⇧⌘W를 누르세요. ⌥⌘Esc는 언제나 작동합니다. pikapik이 Mac에서 찾은 게임을 추천합니다. 게임 모드는 직접 켜기 전까지 꺼져 있습니다.

잠자기 방지에서 화면을 어떻게 할지 고를 수 있습니다. 화면 보호기와 잠금 화면 없이 계속 켜 두거나, Mac은 계속 일하면서 화면만 평소처럼 꺼지게 할 수 있습니다. 새 ‘지금 디스플레이 끄기’ 버튼은 화면을 바로 끄고, 마우스를 움직이거나 키를 누르면 다시 켜집니다.

**사용해 보기:** 설정 › 게임에서 ‘게임 추가…’

**수정 사항**

- 덮개가 없는 Mac에서는 잠자기 방지에 덮개를 닫았을 때의 옵션이 더 이상 나타나지 않습니다.

---

<p align="center"><sub>이전 버전은 <a href="../../CHANGELOG.md">변경 기록</a>(영어)에서 볼 수 있습니다.</sub></p>
