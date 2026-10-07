# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · **Tiếng Việt** · [ไทย](README.th.md)

[![Bản phát hành mới nhất](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Giấy phép: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Lượt tải](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Một ứng dụng nhỏ trên thanh menu macOS giúp phím, cửa sổ và Dock dễ dùng hơn: bảo vệ ⌘Q và ⌘W, chuyển ngôn ngữ bằng Option+Shift, lặp lại phím đang giữ, tắt gia tốc chuột, cuộn bánh xe chuột theo dòng, cho các nút bên của chuột lùi và tiến, thoát ứng dụng khi bạn đóng cửa sổ cuối cùng, ẩn ứng dụng chỉ bằng một lần bấm trong Dock và giữ cho máy Mac luôn thức.

## Cài đặt

Với [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Không dùng Homebrew: mở Terminal, dán dòng này rồi nhấn Return:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Hoặc tải về [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), mở tệp và kéo ứng dụng vào thư mục Ứng dụng.

Cả Homebrew và tập lệnh đều đặt ứng dụng vào `/Applications`, mở ứng dụng, xin quyền và bật “Mở khi đăng nhập”. Sau đó ứng dụng tự cập nhật, xem [Cập nhật](#cập-nhật). Để gỡ bỏ, xem [Gỡ cài đặt](#gỡ-cài-đặt).

## Lần mở đầu tiên

pika-tools cần hai quyền. Lần đầu mở, ứng dụng hiện phần cài đặt ở trang Quyền để hướng dẫn bạn từng bước, và macOS hiện các yêu cầu của riêng nó. Vào **Cài đặt hệ thống › Quyền riêng tư & Bảo mật** và bật pika-tools trong:

- **Trợ năng**, để ứng dụng có thể thay đổi một lần nhấn phím hoặc lần bấm trước khi nó đến các ứng dụng khác.
- **Theo dõi đầu vào**, để ứng dụng có thể thấy các lần nhấn phím và lần bấm.

Ứng dụng nhận ra thay đổi trong vài giây, không cần khởi động lại.

pika-tools không ghi lại, không lưu và không gửi bất cứ thứ gì bạn gõ hay bấm. Các sự kiện được xử lý trong bộ nhớ và chuyển tiếp ngay. Yêu cầu mạng duy nhất là kiểm tra cập nhật, hỏi GitHub phiên bản mới nhất.

## Tính năng

**Bảo vệ ⌘Q và ⌘W.** Chỉ nhấn ⌘Q hoặc ⌘W thì không có gì xảy ra, nên bạn sẽ không vô tình thoát ứng dụng hay đóng cửa sổ. Thêm Shift khi bạn thật sự muốn: ⇧⌘Q để thoát, ⇧⌘W để đóng. Hoạt động trong mọi ứng dụng. Mỗi phím có công tắc riêng. Tắt theo mặc định.

**Chuyển ngôn ngữ bằng Option+Shift.** Giữ Option và nhấn Shift: macOS chuyển sang nguồn đầu vào tiếp theo. Vẫn giữ Option và nhấn Shift lần nữa để đi tiếp. Giữ Shift và nhấn Option để quay lại. Nếu ở giữa chừng bạn nhấn phím khác, bấm chuột, hoặc thêm Command, Control hay Fn, ngôn ngữ sẽ không đổi, nên các phím tắt như Option+Shift+mũi tên vẫn hoạt động như trước. Tắt theo mặc định.

**Lặp lại phím khi giữ.** Giữ một phím là chữ được gõ lặp lại liên tục thay vì hiện menu dấu. Rất tiện khi chơi game và khi gõ. Các app đang mở sẵn sẽ áp dụng sau khi khởi động lại. Tắt đi là macOS hoạt động như bình thường. Tắt theo mặc định.

**Home và End đến đầu và cuối dòng.** Khi bạn gõ, Home đưa con trỏ về đầu dòng và End đến cuối dòng, thay vì cuộn trang. Kèm ⇧ sẽ chọn đến đó, kèm ⌘ sẽ đến đầu hoặc cuối toàn bộ văn bản. Bên ngoài ô văn bản, cũng như trong terminal, máy ảo và ứng dụng màn hình từ xa, các phím vẫn hoạt động như trước. Bạn có thể thêm các ứng dụng khác mà phím cần hoạt động như bình thường. Mặc định tắt.

**Tắt tăng tốc con trỏ.** Con trỏ di chuyển đúng bằng quãng đường của chuột, dù bạn di chuyển nhanh đến đâu, giống như LinearMouse. Thanh trượt **Tốc độ di chuyển** đặt tốc độ của con trỏ. Chỉ hoạt động với chuột, bàn di chuột vẫn giữ nguyên. Tắt tính năng hoặc thoát pika-tools, macOS sẽ lấy lại cài đặt của chính nó. Tắt theo mặc định.

**Cuộn theo dòng.** Mỗi lần bấm bánh xe chuột sẽ cuộn cùng một số dòng, dù bạn xoay nhanh đến đâu. Chọn từ 1 đến 10 dòng mỗi lần bấm, mặc định là 3. Cuộn tự nhiên vẫn giữ như bạn đã đặt trong Cài đặt hệ thống. Chỉ áp dụng cho chuột, bàn di chuột giữ nguyên. Tắt theo mặc định. Bên cạnh thanh trượt **Quãng mỗi lần bấm**, một trang nhỏ cuộn đúng quãng bạn chọn, và một chấm đánh dấu giá trị mặc định.

Một số ứng dụng và trò chơi đếm thao tác cuộn bằng pixel chính xác: với chúng, hãy chuyển chính cài đặt này sang pixel và chọn từ 1 đến 200 pixel mỗi lần bấm, mặc định là 40. Thanh trượt cũng cho biết quãng đó bằng bao nhiêu phần chiều cao màn hình.

**Hướng cuộn cho bàn di chuột và chuột.** macOS chỉ có một công tắc cuộn tự nhiên dùng chung cho bàn di chuột và chuột. Bật tính năng này và chọn hướng cho từng thứ: **Tự nhiên**, trang đi theo ngón tay như trên iPhone, hoặc **Cổ điển**, khi trang di chuyển theo chiều ngược lại. Lựa chọn cho bàn di chuột cũng áp dụng cho cuộn ngang và đà trượt sau khi bạn nhấc ngón tay. Magic Mouse cuộn bằng cảm ứng nên đi theo lựa chọn cho bàn di chuột. Chọn giống nhau trên mọi máy Mac của bạn để cuộn ở đâu cũng như nhau, kể cả khi bạn đưa chuột sang máy Mac khác bằng Điều khiển chung. Mặc định tắt. Khi bật, cả hai bắt đầu giống như trong Cài đặt hệ thống, nên không có gì thay đổi cho đến khi bạn chọn khác.

**Nút bên để quay lại và tiếp.** Nút chuột 4 và 5 giúp lùi và tiến trong Safari, Finder và các ứng dụng khác của Apple, trong Firefox, Opera và ForkLift, giống như vuốt trên bàn di chuột. Các ứng dụng khác, như IDE của JetBrains, nhận các nút nguyên trạng và tự xử lý theo cách riêng. Nếu chuột của bạn có hai nút này ngược nhau, hãy bật **Đổi chỗ nút bên**. Tắt theo mặc định.

**Thoát khi đóng cửa sổ cuối cùng.** Đóng cửa sổ cuối cùng của một ứng dụng và ứng dụng sẽ thoát. Finder vẫn mở, các ứng dụng có cửa sổ ở màn hình nền khác hoặc trong Dock cũng vậy. Bạn có thể lập danh sách những ứng dụng không bao giờ thoát theo cách này. Tắt theo mặc định.

**Ẩn bằng một lần bấm trong Dock.** Bấm vào biểu tượng trong Dock của ứng dụng bạn đang dùng, ứng dụng sẽ ẩn đi. Bấm lần nữa để hiện lại. Tắt theo mặc định.

**Nút xanh lá phóng to cửa sổ.** Bấm vào nút xanh lá của cửa sổ, cửa sổ sẽ lấp đầy màn hình mà không vào chế độ toàn màn hình. Bấm lần nữa để trở lại kích thước cũ. Giữ ⌥ thì nút hoạt động như bình thường. Chế độ toàn màn hình vẫn có trong menu của nút và ở ⌃⌘F. Bạn có thể lập danh sách các ứng dụng mà nút xanh lá cần hoạt động như bình thường. Tắt theo mặc định.

**Tệp mới trong Finder.** Bấm chuột phải trong cửa sổ Finder hoặc trên màn hình nền, chọn **Tệp mới**, nhập tên là có ngay một tệp trống. Mặc định là .txt. Mặc định tắt.

**Enter mở tệp trong Finder.** Chọn tệp trong cửa sổ Finder hoặc trên màn hình nền rồi nhấn Return hoặc Enter, tệp sẽ mở ra. F2 hoặc fn F2 đổi tên tệp đã chọn. Trong ô nhập văn bản, chẳng hạn khi gõ tên, các phím vẫn hoạt động như bình thường. Mặc định tắt.

**⌘X cắt tệp trong Finder.** Chọn tệp rồi nhấn ⌘X, mở thư mục muốn đến rồi nhấn ⌘V, tệp sẽ được chuyển đến đó thay vì sao chép. ⌘C hủy thao tác cắt. Mặc định tắt.

**Delete xóa tệp trong Finder.** Chọn tệp rồi nhấn ⌫ hoặc ⌦ (fn ⌫ trên máy tính xách tay), tệp sẽ vào Thùng rác, giống như ⌘⌫. Khi bạn đang đổi tên tệp, tìm kiếm hoặc gõ trong ô khác, các phím xóa chữ như bình thường. Mặc định tắt.

**Bản sao nhỏ hơn trong Finder.** Bấm chuột phải vào tệp trong Finder và chọn **Tạo bản sao nhỏ hơn**. Một bản nhẹ hơn của ảnh, GIF, PDF hoặc video được lưu ngay bên cạnh, thường nhỏ hơn nhiều lần. Âm thanh chưa nén như WAV hoặc AIFF sẽ thành tệp M4A gọn nhẹ. Nếu tệp không thể nhỏ hơn nữa, sẽ không có bản sao nào và pika-tools sẽ báo cho bạn. Tệp gốc vẫn giữ nguyên và không có gì rời khỏi máy Mac của bạn. Mặc định tắt.

**Chuyển đổi trong Finder.** Bấm chuột phải vào tệp trong Finder và chọn **Chuyển sang** để lưu tệp ở định dạng khác: ảnh thành JPEG, PNG, HEIC, GIF, TIFF hoặc PDF, video thành MP4, MOV hoặc chỉ lấy âm thanh, nhạc thành M4A, WAV hoặc AIFF. Tệp gốc vẫn giữ nguyên và không có gì rời khỏi máy Mac của bạn. Bật riêng với bản sao nhỏ hơn. Mặc định tắt.

**Chế độ trò chơi.** Thêm trò chơi của bạn, và trong lúc bạn chơi, máy Mac không kéo bạn ra khỏi trò chơi. Spotlight, Siri, ⌘Tab, Mission Control và thao tác vuốt giữa các màn hình nền không mở đè lên trò chơi, ⌘Q và ⌘W không vô tình đóng trò chơi, con trỏ không trượt sang Dock, thanh menu hay màn hình khác, và màn hình luôn sáng. Mỗi mục có công tắc riêng trên trang Trò chơi, và pika-tools gợi ý những trò chơi tìm thấy trên máy Mac của bạn. Trong trò chơi, Control-bấm vẫn là một cú bấm bình thường, còn Control với phím mũi tên không đổi màn hình nền. Minecraft cũng được nhận ra: thêm Minecraft Launcher hoặc CurseForge, và chế độ sẽ bật ngay trong Minecraft. Để thoát trò chơi, hãy nhấn ⇧⌘Q; để đóng cửa sổ của nó, nhấn ⇧⌘W. ⌥⌘Esc luôn hoạt động. Ngay khi bạn rời trò chơi, mọi thứ hoạt động như bình thường. Mặc định tắt.

Mỗi công cụ có công tắc riêng trong menu và trong cài đặt.

Biểu tượng trên thanh menu cho biết trạng thái chỉ trong nháy mắt: mũi tên có dấu bấm khi các công cụ đang chạy, mũi tên bị gạch khi mọi thứ đều tắt, và tam giác cảnh báo khi một công cụ đang bật nhưng thiếu quyền.

Bảng điều khiển trên thanh menu ban đầu chỉ có vài hàng. Bạn tự chọn hàng nào được hiện: nhấp nút hình bút chì ở phía dưới, chọn những gì bạn muốn thấy rồi nhấp **Xong**. Các hàng bị ẩn vẫn hoạt động và vẫn nằm trong Cài đặt. Nếu bảng không vừa màn hình, bạn có thể cuộn nó.

Ứng dụng dùng ngôn ngữ của hệ thống hoặc ngôn ngữ bạn chọn trong cài đặt. Có sẵn cả 23 ngôn ngữ trong danh sách ở đầu trang này.

## Giữ máy thức

Ngăn máy Mac chuyển sang chế độ ngủ khi bạn rời bàn phím: trong khoảng thời gian bất kỳ từ 1 giây đến 365 ngày, hoặc cho đến khi bạn tắt. Bật từ menu và đặt thời lượng trong cài đặt: nhập ngày, giờ, phút và giây, dùng ↑ và ↓, hoặc bấm một lựa chọn có sẵn từ 15 phút đến 8 giờ. Menu hiển thị thời gian còn lại và khi nào kết thúc. **Màn hình** có hai lựa chọn. **Luôn bật**: không tắt, không có trình bảo vệ màn hình hay màn hình khóa. **Tắt như bình thường**: tắt theo hẹn giờ riêng trong khi máy Mac vẫn làm việc. **Tắt màn hình ngay** (có cả trong menu) tắt màn hình tức thì, máy Mac vẫn làm việc: di chuột hoặc nhấn một phím để màn hình sáng lại. Thoát pika-tools sẽ kết thúc Giữ máy thức.

Trên MacBook, bạn cũng có thể bật **Hoạt động khi gập nắp**. macOS không có công tắc cho việc này, nên pika-tools chạy `pmset -a disablesleep 1` và yêu cầu mật khẩu quản trị viên: chỉ quản trị viên mới có thể thay đổi cách máy Mac ngủ. Cài đặt tự trở lại bình thường khi Giữ máy thức kết thúc, khi bạn thoát ứng dụng hoặc nếu ứng dụng bị treo. Nếu bạn không nhập mật khẩu, không có gì thay đổi. Hãy để máy Mac được thông thoáng khi gập nắp. **Dừng khi pin dưới 20%** kết thúc phiên trước khi pin cạn.

Keep Awake, chế độ màn hình và chế độ đóng nắp có thể đặt lên một nút trong Trung tâm điều khiển, thanh menu hoặc widget trên màn hình nền qua app Phím tắt, với liên kết bạn sao chép từ Cài đặt › Giữ máy thức.

## Kiểm tra tốc độ

Cho biết internet của bạn đang nhanh đến đâu. Bấm **Kiểm tra tốc độ** trong Cài đặt › Kiểm tra tốc độ, hoặc **Kiểm tra** trong menu sau khi thêm hàng bằng nút bút chì. Sau khoảng nửa phút, bạn thấy tốc độ tải xuống, tải lên, ping và độ phản hồi: mọi thứ phản hồi nhanh thế nào khi kết nối đang bận. Bên dưới là lời giải thích đơn giản về việc kết nối phù hợp cho gì: phim 4K, gọi video, trò chơi trực tuyến và tải tệp lớn. Việc đo dùng networkQuality có sẵn trong macOS và máy chủ của Apple. Kết quả gần nhất được giữ đến lần đo sau, và một liên kết cho Phím tắt bắt đầu đo từ Trung tâm điều khiển.

## Cài đặt ứng dụng

Mở cài đặt từ menu bằng **Cài đặt…** hoặc ⌘, hoặc mở lại pika-tools từ Finder, Launchpad hay Spotlight. Khi cửa sổ đang mở, ứng dụng hiện trong Dock và trong ⌘Tab.

- **Cài đặt chung**: mở khi đăng nhập, giao diện (Hệ thống, Sáng hoặc Tối), ngôn ngữ, cập nhật và sao lưu: xuất và nhập cài đặt thành tệp, hoặc đồng bộ qua iCloud Drive.
- **Giữ máy thức**: thời lượng, tùy chọn màn hình và nắp.
- **Kiểm tra tốc độ**: đo internet và xem nó phù hợp cho gì.
- **Bàn phím**: chuyển ngôn ngữ, lặp phím, Home và End.
- **Chuột**: gia tốc con trỏ và tốc độ di chuyển, cuộn theo dòng, hướng cuộn, các nút bên.
- **Cửa sổ**: phóng to cửa sổ bằng nút xanh lá (có danh sách ngoại lệ), bảo vệ ⌘Q và ⌘W, và thoát khi đóng cửa sổ cuối cùng (có danh sách ngoại lệ).
- **Dock**: ẩn bằng một lần bấm trong Dock.
- **Finder**: tạo tệp mới, bản sao nhỏ hơn và chuyển định dạng, mở bằng Return, cắt bằng ⌘X và xóa bằng ⌫.
- **Quyền**: trạng thái của cả hai quyền, và của iCloud Drive khi bật đồng bộ, kèm nút mở đúng chỗ trong Cài đặt hệ thống.
- **Giới thiệu**: phiên bản, liên kết đến nhật ký thay đổi và để báo cáo sự cố.

Nhiều cài đặt có một hình nhỏ cho thấy chúng làm gì, chẳng hạn một chiếc Mac không ngủ hoặc một cửa sổ ẩn sau Dock. Hình thay đổi cùng công tắc và đứng yên khi “Giảm chuyển động” được bật trong Cài đặt hệ thống.

Mỗi trang đều có nút **Khôi phục mặc định…** ở cuối. Nút này hỏi trước, sau đó tắt các công cụ trên trang đó và đưa tùy chọn của chúng về như cũ, như thể pika-tools chưa từng chạm vào.

**Đồng bộ hóa cài đặt với iCloud** giữ pika-tools giống nhau trên mọi máy Mac của bạn. Cài đặt nằm trong thư mục pika-tools ở iCloud Drive, và thay đổi mới nhất sẽ được áp dụng. Tính năng này tắt theo mặc định và cần bật iCloud Drive. Quyền không được đồng bộ: mỗi máy Mac tự hỏi quyền của mình.

## Cập nhật

pika-tools kiểm tra phiên bản mới khi mở và cứ mỗi 6 giờ. Bạn có thể tắt việc này trong Cài đặt › Cài đặt chung. Khi có phiên bản mới, nút **Cập nhật lên …** xuất hiện trong menu: chỉ một lần bấm, ứng dụng sẽ tải bản cập nhật, cài đặt và khởi động lại. Bạn cũng có thể tự kiểm tra bằng **Kiểm tra ngay** trong Cài đặt › Cài đặt chung.

Với Homebrew, bạn cũng có thể chạy `brew upgrade --cask pika-tools`.

Từ phiên bản 1.3, các quyền vẫn được giữ sau khi cập nhật.

## Gỡ cài đặt

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

Nếu bạn cài bằng Homebrew: `brew uninstall --cask --zap pika-tools`.

Cả hai cách đều thoát ứng dụng, gỡ nó khỏi các mục đăng nhập và xóa nó. Tập lệnh còn đặt lại các quyền của ứng dụng.

## Câu hỏi thường gặp

**Vì sao cần hai quyền?**
macOS chia quyền truy cập bàn phím và chuột làm hai. Theo dõi đầu vào cho phép ứng dụng thấy các sự kiện, còn Trợ năng cho phép thay đổi chúng. Muốn chặn một phím tắt thì cần cả hai.

**macOS báo ứng dụng đến từ nhà phát triển không xác định.**
pika-tools đã được ký, nhưng chưa được Apple công chứng. Homebrew và tập lệnh cài đặt sẽ lo việc này cho bạn. Nếu bạn dùng tệp dmg, hãy mở **Cài đặt hệ thống › Quyền riêng tư & Bảo mật** và bấm **Vẫn mở**, hoặc chạy:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Có chạy trên máy Mac dùng chip Intel không?**
Có. Đây là ứng dụng universal cho Apple silicon và Intel, chạy trên macOS 14 Sonoma trở lên.

**Đã bật quyền nhưng không có gì hoạt động.**
Trong **Cài đặt hệ thống › Quyền riêng tư & Bảo mật**, xóa pika-tools khỏi cả hai danh sách bằng nút −, rồi thêm lại. Trang Quyền trong cài đặt của pika-tools có các nút mở đúng chỗ.

## Đóng góp

Cách build từ mã nguồn và phát hành được mô tả trong [CONTRIBUTING.md](../../CONTRIBUTING.md). Các thay đổi được liệt kê trong [CHANGELOG.md](../../CHANGELOG.md).

## Giấy phép

MIT, © 2026 pikapik. Xem [LICENSE](../../LICENSE).
