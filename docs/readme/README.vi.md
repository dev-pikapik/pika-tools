# pika-tools

[English](../../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Español](README.es.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [한국어](README.ko.md) · [Română](README.ro.md) · [Polski](README.pl.md) · [Türkçe](README.tr.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Čeština](README.cs.md) · [繁體中文](README.zh-Hant.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · **Tiếng Việt** · [ไทย](README.th.md)

[![Bản phát hành mới nhất](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![Giấy phép: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](../../LICENSE)
[![Lượt tải](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

Một ứng dụng nhỏ trên thanh menu macOS giúp phím, cửa sổ và Dock dễ dùng hơn: chặn các phím tắt Control, bảo vệ ⌘Q và ⌘W, chuyển ngôn ngữ bằng Option+Shift giống như Alt+Shift trên Windows, lặp lại phím đang giữ như trên Windows, tắt gia tốc chuột, cuộn bánh xe chuột theo dòng như Windows, cho các nút bên của chuột lùi và tiến, thoát ứng dụng khi bạn đóng cửa sổ cuối cùng, ẩn ứng dụng chỉ bằng một lần bấm trong Dock và giữ cho máy Mac luôn thức.

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

**Chặn phím tắt Control.** Control trở thành một phím bình thường. Các ứng dụng vẫn biết phím đang được giữ, nhưng macOS không còn biến nó thành phím tắt: Control+Phím cách không đổi nguồn đầu vào, Control+phím mũi tên không chuyển màn hình nền, và Control-bấm là một lần bấm bình thường thay vì mở menu ngữ cảnh. Bấm chuột phải và chạm bằng hai ngón vẫn hoạt động như thường. Hữu ích khi chơi game và dùng máy tính từ xa, nơi Control có việc riêng của nó.

**Bảo vệ ⌘Q và ⌘W.** Chỉ nhấn ⌘Q hoặc ⌘W thì không có gì xảy ra, nên bạn sẽ không vô tình thoát ứng dụng hay đóng cửa sổ. Thêm Shift khi bạn thật sự muốn: ⇧⌘Q để thoát, ⇧⌘W để đóng. Hoạt động trong mọi ứng dụng. Mỗi phím có công tắc riêng. Tắt theo mặc định.

**Chuyển ngôn ngữ bằng Option+Shift.** Giữ Option và nhấn Shift: macOS chuyển sang nguồn đầu vào tiếp theo. Vẫn giữ Option và nhấn Shift lần nữa để đi tiếp. Giữ Shift và nhấn Option để quay lại. Nếu ở giữa chừng bạn nhấn phím khác, bấm chuột, hoặc thêm Command, Control hay Fn, ngôn ngữ sẽ không đổi, nên các phím tắt như Option+Shift+mũi tên vẫn hoạt động như trước. Tắt theo mặc định.

**Lặp lại phím khi giữ.** Giữ một phím là chữ được gõ lặp lại liên tục như trên Windows, thay vì hiện menu dấu. Rất tiện khi chơi game và khi gõ. Các app đang mở sẵn sẽ áp dụng sau khi khởi động lại. Tắt đi là macOS hoạt động như bình thường. Tắt theo mặc định.

**Tắt tăng tốc con trỏ.** Con trỏ di chuyển đúng bằng quãng đường của chuột, dù bạn di chuyển nhanh đến đâu, giống như LinearMouse. Thanh trượt **Tốc độ di chuyển** đặt tốc độ của con trỏ. Chỉ hoạt động với chuột, bàn di chuột vẫn giữ nguyên. Tắt tính năng hoặc thoát pika-tools, macOS sẽ lấy lại cài đặt của chính nó. Tắt theo mặc định.

**Cuộn theo dòng.** Mỗi lần bấm bánh xe chuột sẽ cuộn cùng một số dòng, dù bạn xoay nhanh đến đâu, giống như trên Windows. Chọn từ 1 đến 10 dòng mỗi lần bấm, mặc định là 3. Cuộn tự nhiên vẫn giữ như bạn đã đặt trong Cài đặt hệ thống. Chỉ áp dụng cho chuột, bàn di chuột giữ nguyên. Tắt theo mặc định.

**Nút bên để quay lại và tiếp.** Nút chuột 4 và 5 giúp lùi và tiến trong Safari, Finder và các ứng dụng khác của Apple, trong Firefox, Opera và ForkLift, giống như vuốt trên bàn di chuột. Các ứng dụng khác, như IDE của JetBrains, nhận các nút nguyên trạng và tự xử lý theo cách riêng. Nếu chuột của bạn có hai nút này ngược nhau, hãy bật **Đổi chỗ nút bên**. Tắt theo mặc định.

**Thoát khi đóng cửa sổ cuối cùng.** Đóng cửa sổ cuối cùng của một ứng dụng và ứng dụng sẽ thoát, giống như trên Windows. Finder vẫn mở, các ứng dụng có cửa sổ ở màn hình nền khác hoặc trong Dock cũng vậy. Bạn có thể lập danh sách những ứng dụng không bao giờ thoát theo cách này. Tắt theo mặc định.

**Ẩn bằng một lần bấm trong Dock.** Bấm vào biểu tượng trong Dock của ứng dụng bạn đang dùng, ứng dụng sẽ ẩn đi. Bấm lần nữa để hiện lại. Tắt theo mặc định.

**Tệp mới trong Finder.** Bấm chuột phải trong cửa sổ Finder hoặc trên màn hình nền, chọn **Tệp mới**, nhập tên là có ngay một tệp trống, giống New › Text Document trên Windows. Mặc định là .txt. Mặc định tắt.

Mỗi công cụ có công tắc riêng trong menu và trong cài đặt. Cần dùng lại Control+C bình thường? Tắt công cụ đó.

Biểu tượng trên thanh menu cho biết trạng thái chỉ trong nháy mắt: mũi tên có dấu bấm khi các công cụ đang chạy, mũi tên bị gạch khi mọi thứ đều tắt, và tam giác cảnh báo khi một công cụ đang bật nhưng thiếu quyền.

Ứng dụng dùng ngôn ngữ của hệ thống hoặc ngôn ngữ bạn chọn trong cài đặt. Có sẵn cả 23 ngôn ngữ trong danh sách ở đầu trang này.

## Giữ máy thức

Ngăn máy Mac chuyển sang chế độ ngủ khi bạn rời bàn phím: trong khoảng thời gian bất kỳ từ 1 phút đến 12 tháng, hoặc cho đến khi bạn tắt. Bật từ menu và đặt thời lượng trong cài đặt theo phút, giờ, ngày, tuần hoặc tháng. Menu hiển thị thời gian còn lại và khi nào kết thúc. **Giữ màn hình luôn bật** còn ngăn màn hình bị tối đi. Thoát pika-tools sẽ kết thúc Giữ máy thức.

Trên MacBook, bạn cũng có thể bật **Hoạt động khi gập nắp**. macOS không có công tắc cho việc này, nên pika-tools chạy `pmset -a disablesleep 1` và yêu cầu mật khẩu quản trị viên: chỉ quản trị viên mới có thể thay đổi cách máy Mac ngủ. Cài đặt tự trở lại bình thường khi Giữ máy thức kết thúc, khi bạn thoát ứng dụng hoặc nếu ứng dụng bị treo. Nếu bạn không nhập mật khẩu, không có gì thay đổi. Hãy để máy Mac được thông thoáng khi gập nắp. **Dừng khi pin dưới 20%** kết thúc phiên trước khi pin cạn.

## Cài đặt ứng dụng

Mở cài đặt từ menu bằng **Cài đặt…** hoặc ⌘, hoặc mở lại pika-tools từ Finder, Launchpad hay Spotlight. Khi cửa sổ đang mở, ứng dụng hiện trong Dock và trong ⌘Tab.

- **Cài đặt chung**: mở khi đăng nhập, giao diện (Hệ thống, Sáng hoặc Tối), ngôn ngữ, cập nhật và sao lưu: xuất và nhập cài đặt thành tệp, hoặc đồng bộ qua iCloud Drive.
- **Bàn phím**: phím tắt Control, ⌘Q và ⌘W, chuyển ngôn ngữ.
- **Chuột**: gia tốc con trỏ và tốc độ di chuyển, cuộn theo dòng, các nút bên.
- **Cửa sổ & Ứng dụng**: thoát khi đóng cửa sổ cuối cùng, kèm danh sách ngoại lệ, và ẩn bằng một lần bấm trong Dock.
- **Giữ máy thức**: thời lượng, tùy chọn màn hình và nắp.
- **Quyền**: trạng thái của cả hai quyền, và của iCloud Drive khi bật đồng bộ, kèm nút mở đúng chỗ trong Cài đặt hệ thống.
- **Giới thiệu**: phiên bản, liên kết đến nhật ký thay đổi và để báo cáo sự cố.

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
