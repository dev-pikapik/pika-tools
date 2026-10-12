<p align="center"><a href="../readme/README.vi.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">Có gì mới trong pikapik</h1>
<p align="center">Mỗi bản cập nhật gói trong vài lời và một bức hình, mới nhất ở trên cùng.</p>
<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <b>Tiếng Việt</b> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.38.1"></a>Menu Finder ổn định hơn

<sub>1.38.1 · 12 tháng 10 năm 2026</sub>

Các mục của pikapik trong menu bấm chuột phải của Finder không còn biến mất khi bạn kết nối ổ đĩa, mở ảnh đĩa, đánh thức máy Mac hoặc chuyển sang Finder.

Trước đây, trong một số ít trường hợp, chương trình trợ giúp hiển thị các mục này bị đóng ngay lúc đó.

---

## <a id="v1.38.0"></a>Mở và tạo tệp lưu trữ ngay trong Finder

<sub>1.38.0 · 12 tháng 10 năm 2026</sub>

“Tệp lưu trữ trong Finder” mới mở được RAR và các tệp lưu trữ khác mà macOS không mở được, đồng thời tạo ZIP và 7Z từ menu bấm chuột phải.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Mở Cài đặt › Finder và bật “Tệp lưu trữ trong Finder”. Bấm chuột phải vào một tệp lưu trữ và chọn “Giải nén”, các tệp của nó sẽ hiện ra ngay bên cạnh. Bấm chuột phải vào tệp hoặc thư mục khác và chọn “Tạo tệp lưu trữ…” để tạo ZIP, 7Z, TAR.GZ hoặc TAR.XZ. ZIP và 7Z có thể đặt mật khẩu, và tệp lưu trữ nào cũng có thể chia thành nhiều phần, chẳng hạn mỗi phần 15 MB để gửi email. ZIP tạo theo cách này không chứa các tệp ẩn do hệ thống thêm vào và giữ cho tên tệp ở mọi ngôn ngữ vẫn đọc được.

pikapik cũng mở được những gì macOS không mở được: RAR, kể cả khi chia thành nhiều tệp, 7Z khóa bằng mật khẩu, ZIPX, CAB, LZH, ARJ, ZST, WIM và nhiều loại khác. Bấm đúp là mở trong pikapik. Tên tệp trong các ZIP cũ, chẳng hạn bằng chữ Kirin, tiếng Nhật hay tiếng Trung, hiện ra đọc được. Công tắc “Mở tệp lưu trữ bằng ứng dụng này” cũng giao ZIP và 7Z cho pikapik, còn TAR và GZ vẫn thuộc về ứng dụng lưu trữ có sẵn, vốn đã xử lý chúng tốt.

Một cửa sổ sẽ hỏi mật khẩu, “Dừng” hủy bất kỳ tác vụ nào, và từ tệp lưu trữ bị hỏng, pikapik lấy ra những gì vẫn còn đọc được. pikapik hỏi trước khi giải nén một tệp lưu trữ sẽ phình ra kích thước khổng lồ, và chặn những tệp lưu trữ cố ghi ra ngoài thư mục của chính chúng. Không có trong phiên bản Mac App Store. Chọn một tệp lưu trữ rồi nhấn phím cách để xem bên trong có gì.

---

## <a id="v1.37.3"></a>Nhãn FPS giờ xin quyền đúng chỗ

<sub>1.37.3 · 12 tháng 10 năm 2026</sub>

Quyền Ghi màn hình cho nhãn FPS giờ được cho phép ở trang Quyền, cùng với tất cả các quyền khác.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Để đếm khung hình của một trò chơi, “Hiện FPS” có thể cần quyền Ghi màn hình. Trước đây pikapik xin quyền này ngay trên trang Trò chơi. Giờ nó nằm chung với mọi quyền khác: khi “Hiện FPS” cần đến, dòng “Ghi màn hình” sẽ hiện ra trong Cài đặt › Quyền, và bạn bấm “Cho phép” ở đó.

Trên trang Trò chơi, bạn giờ chỉ còn thấy dòng quen thuộc dưới công tắc: “Cần được cấp quyền. Bấm để cho phép.” Nút “Cho phép” trong dòng đó đưa bạn thẳng tới dòng “Ghi màn hình”. Bật “Hiện FPS” không còn tự bật lên câu hỏi nữa, và pikapik vẫn không bao giờ xin gì khi bạn đang chơi.

---

## <a id="v1.37.2"></a>Đã được Apple kiểm tra

<sub>1.37.2 · 12 tháng 10 năm 2026</sub>

pikapik giờ được ký bởi nhà phát triển Apple đã xác minh và được Apple kiểm tra. Vì vậy macOS không còn cảnh báo khi bạn mở lần đầu.

Sau bản cập nhật này, macOS có thể hỏi lại các quyền bạn đã cấp cho pikapik, như Trợ năng, Giám sát đầu vào hoặc Toàn quyền truy cập đĩa. Hãy cho phép lại một lần trong Cài đặt hệ thống › Quyền riêng tư & Bảo mật. Nếu bạn dùng điều khiển quạt, hãy cho phép lại trong cài đặt của pikapik, và macOS sẽ hỏi mật khẩu một lần.

---

## <a id="v1.37.1"></a>Nhãn FPS giờ bám sát trò chơi của bạn

<sub>1.37.1 · 12 tháng 10 năm 2026</sub>

Khi bạn kéo cửa sổ trò chơi, nhãn FPS sẽ di chuyển ngay cùng với nó.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Trước đây, nhãn chỉ đuổi kịp cửa sổ đang di chuyển khoảng một lần mỗi giây nên bị tụt lại phía sau. Giờ đây, nhãn kiểm tra cửa sổ ở mỗi khung hình của màn hình và chỉ chậm hơn tối đa vài phần nghìn giây. Khi cửa sổ đứng yên, nhãn kiểm tra thưa hơn, nên hầu như không làm nặng máy Mac khi bạn chơi. Nhãn cũng không còn nhảy sang chỗ khác khi một phần cửa sổ vượt ra ngoài mép màn hình.

Nếu một trò chơi tĩnh như cờ vua hiển thị 0 thì không có gì bất thường: những trò chơi như vậy chỉ vẽ hình mới khi có thứ gì đó chuyển động. Con số tăng lên khi một quân cờ trượt đi và trở về 0 khi bàn cờ đứng yên.

---

## <a id="v1.37.0"></a>Xem trò chơi chạy mượt đến đâu

<sub>1.37.0 · 12 tháng 10 năm 2026</sub>

Tính năng Hiện FPS mới đặt một bộ đếm nhỏ ở góc trò chơi, để bạn thấy ngay trò chơi chạy mượt đến đâu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Mở Cài đặt › Trò chơi rồi bật “Hiện FPS”. Khi Chế độ trò chơi đang bật, một nhãn nhỏ màu tối ghi con số xuất hiện ở một góc của bất kỳ trò chơi nào. FPS là số khung hình mỗi giây: số hình mà trò chơi vẽ ra trong mỗi giây, và con số càng cao thì trò chơi càng mượt. Nhấp vào một góc trên hình phía trên công tắc để chọn vị trí của nhãn.

Nhấp chuột đi xuyên qua nhãn, và nhãn đi theo cửa sổ trò chơi. Dấu gạch nghĩa là những khung hình đầu tiên chưa đến, còn số 0 mờ nghĩa là trò chơi đã ngừng vẽ. “Hiện FPS” tắt cho đến khi bạn bật nó.

Trên macOS 27, phần lớn trò chơi do chính macOS đếm, nên không cần quyền nào. Một số trò chơi, thường là trò cũ, chỉ đếm được qua tính năng ghi màn hình, và khi đó con số không thể cao hơn tần số làm tươi của màn hình. Trên macOS 14–26 và trong phiên bản Mac App Store, mọi trò chơi đều được đếm theo cách này, nên khi bạn bật “Hiện FPS”, pikapik sẽ xin quyền “Ghi màn hình”. Không có hình ảnh nào được lưu hay gửi đi.

---

## <a id="v1.36.0"></a>Gỡ ứng dụng không lo nghĩ

<sub>1.36.0 · 12 tháng 10 năm 2026</sub>

Tính năng Gỡ ứng dụng mới gỡ một ứng dụng cùng mọi tệp của nó, và đặt lại tất cả nếu bạn đổi ý.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Mở Cài đặt › Gỡ ứng dụng rồi chọn một ứng dụng, hoặc thả nó lên hình minh họa. pikapik cho bạn thấy mọi thứ ứng dụng đó lưu trên Mac của bạn, kèm lý do cho từng tệp. Những tệp rõ ràng thuộc về ứng dụng được đánh dấu chọn, còn những tệp chỉ có thể liên quan thì không. Nhấp “Chuyển vào Thùng rác”, mọi thứ sẽ vào Thùng rác, nên không có gì bị xóa vĩnh viễn.

Đổi ý rồi? Nhấp “Đặt lại chỗ cũ”, mọi thứ sẽ về đúng chỗ cũ. Mười lần gỡ gần nhất nằm trong “Đã gỡ gần đây” chừng nào các tệp của chúng còn trong Thùng rác. “Đặt lại ứng dụng” giữ nguyên ứng dụng và chỉ gỡ dữ liệu đã lưu, cài đặt và tệp tạm của nó, phòng khi nó trục trặc.

Tự chuyển ứng dụng vào Thùng rác? Trang này cũng liệt kê những ứng dụng đó cùng các tệp chúng để lại, và bạn có thể bật một công tắc để pikapik đề nghị dọn dẹp mỗi khi có ứng dụng vào Thùng rác. Không có gì bị gỡ cho đến khi bạn chọn. Để thấy được mọi thứ, trang này cần Truy cập toàn bộ ổ đĩa.

---

## <a id="v1.35.0"></a>Mặc đồ cho thú cưng

<sub>1.35.0 · 12 tháng 10 năm 2026</sub>

Thú cưng của bạn giờ có tủ quần áo, và bạn nhận thêm đồ để mặc khi cùng chơi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Mở Cài đặt › Thú cưng và chọn thú cưng sẽ mặc gì: mũ, kính, khăn, áo sơ mi, giày, áo choàng và cả đôi cánh. Nó mặc ngay lập tức. Vài món miễn phí, còn lại là giải thưởng đến khi hai bạn chơi cùng nhau: nhấc thú cưng lên rồi tung đi, đá bóng, xem nó trèo cửa sổ và trò chuyện, hoặc đơn giản là ở bên nó ngày này qua ngày khác. Khi bạn nhận được giải thưởng, thú cưng sẽ báo cho bạn.

Các trang phục làm sẵn mặc cho thú cưng từ đầu đến chân chỉ với một cú bấm: phù thủy, cướp biển, phi hành gia, siêu anh hùng, nhà vua và nhiều trang phục khác. Mỗi trang phục sẵn sàng khi bạn đã nhận đủ mọi món của nó.

Chỉ những con số đơn giản được lưu, như số bước, số lần tung và số ngày bên nhau. Chúng nằm lại trên máy Mac của bạn, không có gì được gửi đi đâu, và bạn có thể xóa chúng bất cứ lúc nào trong Cài đặt › Thú cưng.

---

## <a id="v1.34.0"></a>Chuột và bàn di chuột trong trò chơi

<sub>1.34.0 · 12 tháng 10 năm 2026</sub>

Vuốt, chụm và góc nóng giờ không còn đưa bạn ra khỏi trò chơi, giống như phím tắt bàn phím.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

Trong Cài đặt › Trò chơi › Thêm cài đặt trò chơi có nhóm “Chuột và bàn di chuột”. Nhóm này chỉ liệt kê những gì đang bật trong macOS trên Mac của bạn, với tên gọi của Apple và một hình vẽ nhỏ cho từng mục: phím tắt trên nút chuột, vuốt giữa các màn hình nền và ứng dụng toàn màn hình, Mission Control và App Exposé, chụm ngón tay cho ứng dụng và xòe ngón tay cho màn hình nền, vuốt từ cạnh phải cho Trung tâm thông báo và mỗi góc nóng cùng thao tác của nó. Khi trò chơi ở phía trước, tất cả được tạm dừng, nên một cú vuốt nhầm hay chạm vào góc màn hình sẽ không đưa bạn ra khỏi trò chơi. Các cử chỉ bên trong trò chơi vẫn hoạt động bình thường. Mỗi mục có thể đặt để hoạt động như bình thường.

---

## <a id="v1.33.2"></a>Nhóm phím tắt mở ngay lập tức

<sub>1.33.2 · 11 tháng 10 năm 2026</sub>

Ngay cả nhóm phím tắt hệ thống dài nhất cũng mở ngay, và dòng nào cũng có tên rõ ràng.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Trước đây cửa sổ cài đặt bị khựng một lúc khi mở một nhóm có hàng chục dòng, vì mọi dòng cùng ảnh xem trước động được tạo cùng lúc. Giờ chỉ những dòng đang hiện trên màn hình và vài dòng gần đó mới được tạo. Các dòng tên “Tác vụ hệ thống” kèm con số cũng biến mất: Đọc chính tả, Siri, các phím độ sáng và thu phóng hiện đúng tên thật, còn các tác vụ mà macOS không đặt tên sẽ bị ẩn nhưng vẫn được tạm dừng trong game như trước.

---

## <a id="v1.33.1"></a>Nhóm phím tắt mở ra không còn giật

<sub>1.33.1 · 11 tháng 10 năm 2026</sub>

Trang Trò chơi vẫn mượt khi mở một danh sách dài có nhiều bản xem trước.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Trước đây, mở một nhóm phím tắt bàn phím hệ thống làm cửa sổ cài đặt đứng hình tới ba giây, vì mỗi hàng cùng bản xem trước của nó bị tính toán nhiều lần. Giờ mỗi hàng chỉ được tính một lần, nên các nhóm mở ra gần như ngay lập tức.

---

## <a id="v1.33.0"></a>Mọi quyền gói gọn một chỗ

<sub>1.33.0 · 11 tháng 10 năm 2026</sub>

Cài đặt › Quyền giờ liệt kê mọi thứ pikapik dùng, và cho bạn thu hồi bất kỳ quyền nào.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Cài đặt › Quyền giờ hiển thị mọi quyền mà pikapik dùng, từ Trợ năng và Theo dõi đầu vào đến Điều khiển quạt, Tiện ích mở rộng của Finder, iCloud Drive và Truy cập toàn bộ ổ đĩa. Mỗi dòng nói bằng một câu quyền đó dùng để làm gì, kèm dấu tích xanh khi đang bật và dấu gạch chéo cam khi còn thiếu.

Mỗi dòng có một nút duy nhất: Cho phép khi còn thiếu, Tắt khi đang bật. Nhờ vậy bạn có thể thu hồi bất kỳ quyền nào ngay tại đó, không cần lục tìm trong Cài đặt hệ thống. Với Trợ năng và Theo dõi đầu vào, pikapik sẽ hỏi trước rồi khởi động lại mà không có chúng.

Một công cụ cần quyền bạn chưa cấp sẽ hiện mờ màu xám. Bấm vào nó, Quyền sẽ mở ra với đúng dòng được làm nổi bật, chỉ còn một lần bấm Cho phép.

**Thử ngay:** Mở Cài đặt › Quyền và xem từng dòng. Bấm vào một công cụ màu xám để đến thẳng quyền mà nó cần.

---

## <a id="v1.32.2"></a>Cài đặt an toàn hơn, cập nhật không bao giờ làm mất ứng dụng

<sub>1.32.2 · 11 tháng 10 năm 2026</sub>

Một loạt bản sửa giúp cài đặt, cập nhật và gỡ cài đặt an toàn hơn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Trình hỗ trợ quạt giờ được cài cẩn thận hơn và được kiểm tra trước khi chạy. Nếu bản cập nhật không sao chép được, pikapik hiện tại của bạn vẫn nằm nguyên đó. Khi gỡ cài đặt, trình hỗ trợ quạt cũng bị xoá, còn cài đặt lặp phím, các góc Dock và phím tắt hệ thống của bạn được khôi phục.

Phím đang giữ không còn bị kẹt khi một công cụ khởi động lại, và khi tắt “Lặp lại phím đang giữ”, cài đặt menu dấu của riêng bạn được trả lại. Thú cưng nghỉ ngơi khi màn hình ngủ hoặc bị khoá, và bản sao của archive.tar.gz giờ có tên archive 2.tar.gz.

---

## <a id="v1.32.1"></a>Tốc độ quạt thủ công có hiệu lực ngay lần đầu

<sub>1.32.1 · 11 tháng 10 năm 2026</sub>

Chọn Thủ công trong Quạt không còn bị quay lại Tự động.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Đôi khi lần chạm đầu tiên vào Thủ công khiến quạt quay về Tự động kèm cảnh báo an toàn, và chỉ lần thứ hai mới được. Giờ Thủ công giữ nguyên ngay từ lần đầu.

Nếu một quạt tự thoát khỏi chế độ Thủ công, pikapik sẽ đưa nó về Tự động thật sự, nên những gì bạn thấy luôn khớp với việc Mac đang làm.

Bạn không cần cho phép lại gì cả. Cập nhật là dùng được ngay.

**Thử ngay:** Mở Cài đặt › Quạt và chọn Thủ công.

---

## <a id="v1.32.0"></a>Xem quạt của bạn quay nhanh đến đâu

<sub>1.32.0 · 11 tháng 10 năm 2026</sub>

Thẻ Quạt mới hiển thị từng quạt trực tiếp và cho bạn chọn tốc độ.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Quạt giờ có thẻ riêng trong Cài đặt và một dòng trong menu. Bạn thấy ngay theo thời gian thực mỗi quạt đang quay nhanh thế nào, cùng một chiếc quạt nhỏ quay theo bên cạnh.

Để ở Tự động thì Mac tự quyết định như mọi khi. Hoặc chọn Thủ công và kéo một thanh trượt để đặt tốc độ bạn muốn. Lần đầu, bạn chỉ cần cho phép một lần bằng mật khẩu quản trị viên là xong.

Tính năng được làm để an toàn. Quạt trở về Tự động khi bạn thoát pikapik, khi Mac chuyển sang chế độ ngủ, nếu pikapik bị lỗi và đóng đột ngột, hoặc khi Mac nóng lên.

**Thử ngay:** Mở Cài đặt › Quạt và xem tốc độ. Chọn Thủ công để thử thanh trượt.

---

## <a id="v1.31.4"></a>Chi tiết khi bạn cần

<sub>1.31.4 · 11 tháng 10 năm 2026</sub>

Trang trò chơi gọn hơn và một ô tìm kiếm.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Mỗi chế độ giải thích cách hoạt động ngay trong danh sách thả xuống. Khi đóng danh sách, trang chỉ hiển thị tên đã chọn.

Đã bỏ mô tả lặp lại tên hành động. Thông tin bổ sung hữu ích vẫn được giữ lại.

Tìm kiếm chung tìm hành động hệ thống theo tên, ý nghĩa và phím. Chọn kết quả sẽ mở và làm nổi bật đúng cài đặt đó.

**Thử ngay:** Tìm hành động trong tìm kiếm chung và mở danh sách chế độ của nó.

---

## <a id="v1.31.3"></a>Giao diện thống nhất cho cài đặt trò chơi

<sub>1.31.3 · 11 tháng 10 năm 2026</sub>

Bản xem trước đồng bộ và tùy chọn phím tắt rõ ràng hơn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Mỗi phím tắt giờ có bản xem trước rộng giống phần bảo vệ trò chơi và các trang cài đặt khác. Bên dưới là mô tả, điều khiển và giải thích tùy chọn đã chọn.

«Theo quy tắc Chế độ trò chơi». Phím tắt ngắn đổi ngôn ngữ không cần menu. Giữ phím trò chơi ngăn đổi ngôn ngữ ngoài ý muốn.

«Tắt trong trò chơi». Hành động macOS này bị tắt khi trò chơi ở phía trước. Khi rời trò chơi, hành động hoạt động như trước. «Cho phép trong trò chơi». macOS chạy hành động bình thường, kể cả khi mở cửa sổ hoặc lấy tiêu điểm khỏi trò chơi.

**Thử ngay:** Mở cài đặt trò chơi bổ sung, mở rộng điều khiển hệ thống và chọn hành vi của hành động khi chơi.

---

## <a id="v1.31.2"></a>Cài đặt trò chơi rõ ràng hơn

<sub>1.31.2 · 11 tháng 10 năm 2026</sub>

Tinh chỉnh bảo vệ và khám phá phím tắt của Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Tám chủ đề rõ ràng thay thế các thư mục lặp lại. Mỗi tiêu đề có tên, giải thích, biểu tượng và số lượng. Bấm vào bất kỳ vị trí nào trong hàng để mở.

Mỗi hành động giải thích công dụng cạnh bản xem trước động. Các phím hiện tại và hành vi trong trò chơi có hàng riêng. Tìm kiếm cũng tìm được phần mô tả.

Các phím chưa được gán có liên kết rõ ràng đến Cài đặt hệ thống. Bảo vệ trò chơi chung nằm ở phần riêng và lựa chọn của bạn được giữ lại.

**Thử ngay:** Mở cài đặt trò chơi bổ sung, mở rộng một chủ đề rồi so sánh mô tả hành động với bản xem trước.

---

## <a id="v1.31.1"></a>Cử chỉ đổi ngôn ngữ trong trò chơi

<sub>1.31.1 · 11 tháng 10 năm 2026</sub>

Mặc định đơn giản, với toàn bộ danh mục hệ thống khi cần.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

Cử chỉ đổi ngôn ngữ của pikapik hoạt động trong trò chơi ngay cả khi phím tắt ngôn ngữ của macOS chưa được gán hoặc đã tắt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Tự động tạm dừng tác vụ mở cửa sổ hoặc chuyển tiêu điểm. Phím tắt ngôn ngữ nhanh có chủ ý đổi nguồn mà không mở cửa sổ hệ thống. Phím di chuyển được giữ có ưu tiên, nên chạy và nhảy không vô tình đổi ngôn ngữ.

Mỗi tác vụ có thể chỉnh trong danh mục có tìm kiếm. Ngôn ngữ có thể đổi trong nền; tác vụ khác có thể tạm dừng hoặc cho chạy bình thường. Lựa chọn được đồng bộ. Ứng dụng khác theo dõi phím hiển thị riêng. Buộc thoát vẫn khả dụng.

**Thử ngay:** Giữ ⌥ và nhấn ⇧: ngôn ngữ tiếp theo. Giữ ⇧ và nhấn ⌥: ngôn ngữ trước

---

## <a id="v1.31.0"></a>Chế độ trò chơi biết các phím tắt của Mac

<sub>1.31.0 · 11 tháng 10 năm 2026</sub>

Mặc định đơn giản, với toàn bộ danh mục hệ thống khi cần.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Bật Chế độ trò chơi và chơi. Thêm cài đặt trò chơi chứa danh mục Mac, các phím hiện tại và xem trước động cho mỗi tác vụ.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Tự động tạm dừng tác vụ mở cửa sổ hoặc chuyển tiêu điểm. Phím tắt ngôn ngữ nhanh có chủ ý đổi nguồn mà không mở cửa sổ hệ thống. Phím di chuyển được giữ có ưu tiên, nên chạy và nhảy không vô tình đổi ngôn ngữ.

Mỗi tác vụ có thể chỉnh trong danh mục có tìm kiếm. Ngôn ngữ có thể đổi trong nền; tác vụ khác có thể tạm dừng hoặc cho chạy bình thường. Lựa chọn được đồng bộ. Ứng dụng khác theo dõi phím hiển thị riêng. Buộc thoát vẫn khả dụng.

**Thử ngay:** Mở cài đặt bổ sung, tìm phím tắt chụp ảnh hoặc ngôn ngữ rồi so sánh xem trước có và không có bảo vệ.

---

## <a id="v1.30.14"></a>Liên kết phím tắt mở mà không bị lỗi

<sub>1.30.14 · 11 tháng 10 năm 2026</sub>

Nhấp vào phím tắt đang tắt không còn đóng pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Trên trang Trò chơi, bạn có thể nhấp phím tắt dù chưa có phím được gán. Cài đặt hệ thống mở an toàn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Trước đây pikapik có thể đọc cùng một hàng đang thay đổi hai lần khi cửa sổ mở. Nếu chữ biến mất giữa hai lần đọc, ứng dụng bị lỗi.

Mỗi hàng giờ chỉ được đọc một lần. Chữ bị thiếu sẽ được bỏ qua. Các liên kết phím tắt ở trang khác cũng được sửa.

**Thử ngay:** Nhấp vào phím tắt đang tắt trên trang Trò chơi.

---

## <a id="v1.30.13"></a>Giữ Control và tiếp tục chơi

<sub>1.30.13 · ngày 10 tháng 10, 2026</sub>

Control không còn để chuyển ngôn ngữ lấy mất phím cách của trò chơi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Giữ Control để chạy và nhấn phím cách để nhảy. Trong Chế độ trò chơi, chuyển ngôn ngữ bằng Control+phím cách và Control+Option+phím cách được tạm dừng.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Các phím tắt macOS khác dùng Control, hoặc Shift và Option không có Command, cũng tạm dừng, kể cả tổ hợp bạn tự đặt. Nhấn, thả và giữ phím vẫn cùng được truyền vào trò chơi.

Cử chỉ ngôn ngữ của pikapik và phím tắt thoát dùng phím bổ trợ trò chơi cũng không can thiệp. Khi rời trò chơi, phím tắt hệ thống trở lại đúng như trước.

**Thử ngay:** Giữ Control, di chuyển và nhấn phím cách vài lần. Sau đó rời trò chơi và chuyển ngôn ngữ như bình thường.

---

## <a id="v1.30.12"></a>Kéo trò chơi từ Giám sát hoạt động

<sub>1.30.12 · ngày 10 tháng 10, 2026</sub>

Chế độ trò chơi nhận tiến trình kéo từ Giám sát hoạt động.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Tìm tiến trình trò chơi rồi kéo hàng vào Trò chơi của bạn trong Cài đặt → Trò chơi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Trò chơi Java cũng dùng được khi không có biểu tượng thông thường trong Dock. Trước đây các hàng này bị bỏ qua vì chứa số và tên tiến trình thay vì tệp.

Trò chơi được lưu cho những lần mở sau. Minecraft hiện đúng tên. Số và tên phải khớp với tiến trình đang chạy.

**Thử ngay:** Kéo hàng java của Minecraft đang mở vào Trò chơi của bạn.

---

## <a id="v1.30.11"></a>Thêm trò chơi ngay khi đang chạy

<sub>1.30.11 · ngày 10 tháng 10, 2026</sub>

Các trò chơi đang mở giờ xuất hiện đầu tiên khi thêm trò chơi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Mở Cài đặt → Trò chơi → Thêm trò chơi rồi nhấp vào trò chơi đang chạy. Trò chơi qua Java và các môi trường khác cũng xuất hiện, ngay cả khi không có tệp .app. Minecraft hiển thị là Minecraft thay vì java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Các ứng dụng trong Dock giờ có danh sách thu gọn riêng, giúp bạn tìm ngay trò chơi đang mở.

Khác… và kéo thả cũng nhận tệp thực thi của trò chơi, ngoài ứng dụng. Sau khi thêm, Chế độ trò chơi bật khi bạn chuyển sang trò chơi.

**Thử ngay:** Để trò chơi mở, chọn Thêm trò chơi rồi nhấp vào biểu tượng. Không cần tìm trong thư mục.

---

## <a id="v1.30.10"></a>Thú cưng vẫn hiện khi nhảy

<sub>1.30.10 · ngày 10 tháng 10, 2026</sub>

Thú cưng không còn biến mất sau cửa sổ khi nhảy trên màn hình không có Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Trước đây, nếu Dock nằm ở màn hình khác hoặc đang ẩn, thú cưng nhảy ra sau cửa sổ và biến mất cho đến khi chạm đất. Giờ đây, ngay khi rời mặt đất, nó hiện trước cửa sổ trên mọi màn hình, dù có Dock hay không. Quả bóng cũng vậy.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Cửa sổ chỉ chạm vào mép thú cưng sẽ không còn che nó khi nhảy. Thú cưng chỉ ở sau cửa sổ khi cửa sổ thật sự che kín nó, như video bạn đang xem.

Trên mặt đất, thú cưng và quả bóng vẫn dạo chơi sau cửa sổ của bạn như trước.

**Thử ngay:** Cho Dock tự ẩn hoặc chuyển nó sang màn hình khác, rồi nhấn phím cách cạnh một cửa sổ. Thú cưng sẽ nhảy lên trước cửa sổ đó.

---

## <a id="v1.30.9"></a>Toàn màn hình là của bạn, và quả bóng chơi đẹp

<sub>1.30.9 · ngày 10 tháng 10, 2026</sub>

Thú cưng không còn chui vào video toàn màn hình, và quả bóng không còn va vào những thứ không hề có.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Trước đây, khi bạn xem video toàn màn hình, thú cưng thỉnh thoảng lại ló ra. Giờ pikapik hỏi thẳng macOS xem màn hình có đang ở chế độ toàn màn hình không, và kiểm tra lại một lần nữa khi chuyển xong. Thú cưng và quả bóng sẽ ẩn cho đến khi bạn thoát toàn màn hình.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Quả bóng không còn nảy ra từ khoảng không. Nó bay qua Dock thay vì đập vào một bức tường vô hình phía trên. Giờ chuột chỉ đánh trúng quả bóng khi con trỏ thật sự chạm vào nó. Chạm nhẹ thì bóng lăn, vung nhanh thì bóng bay. Còn nếu thú cưng hoặc quả bóng đang trốn sau một cửa sổ, chuột di trên cửa sổ đó sẽ để yên cho chúng.

Kéo một tệp trên màn hình nền không còn tạo bậc thang cho thú cưng nữa. Chỉ khung chọn mới làm được điều đó.

**Thử ngay:** Xem một video toàn màn hình và nhấn phím cách để tạm dừng vài lần. Thú cưng sẽ không xuất hiện. Sau đó vung chuột vào quả bóng.

---

## <a id="v1.30.8"></a>Góc màn hình yên lặng khi bạn chơi

<sub>1.30.8 · ngày 10 tháng 10, 2026</sub>

Ở Chế độ trò chơi, đưa chuột ra mép và góc màn hình không còn kích hoạt góc nóng hay kéo Dock đang ẩn ra nữa.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Trước đây, giữa ván chơi, chuột chạm góc hay mép màn hình có thể kích hoạt góc nóng hoặc kéo Dock đang ẩn ra.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Giờ đây, Chế độ trò chơi tắt góc nóng và Dock ẩn trong lúc bạn chơi. Vài giây sau khi bạn rời game, hoặc khi thoát pikapik, chúng trở lại y như cũ.

Và con trỏ không còn giật ở mép màn hình đang chạy game.

**Thử ngay:** Bật Chế độ trò chơi, mở một game rồi đưa chuột vào góc màn hình. Không có gì bật ra.

---

## <a id="v1.30.7"></a>Thú cưng không còn chen vào video của bạn

<sub>1.30.7 · ngày 10 tháng 10, 2026</sub>

Khi thú cưng hoặc quả bóng ở sau một cửa sổ, chúng vẫn ở đó kể cả khi nhảy hay bay.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Trước đây, nếu thú cưng hoặc quả bóng đang trốn sau video hay game, một cú nhảy hay bay có thể khiến chúng hiện ngay trên thứ bạn đang xem. Nhấn phím cách để tạm dừng video cũng làm thú cưng chui ra.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Giờ đây, dù làm gì, chúng vẫn ở sau cửa sổ đang che chúng. Và video toàn màn hình trong Firefox giấu chúng đi ngay.

Sau các cửa sổ thông thường, chúng vẫn ẩn như trước.

**Thử ngay:** Phát video trong một cửa sổ lớn che phần dưới màn hình rồi nhấn phím cách để tạm dừng. Thú cưng vẫn ở sau video.

---

## <a id="v1.30.6"></a>Khi toàn màn hình, thú cưng nghỉ ngơi ở mọi màn hình

<sub>1.30.6 · ngày 10 tháng 10, 2026</sub>

Khi có bất kỳ ứng dụng nào đang toàn màn hình, thú cưng và quả bóng giờ ẩn đi trên mọi màn hình.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Trước đây, khi bạn mở video hay game toàn màn hình, thú cưng và quả bóng đôi khi chạy sang màn hình khác và chơi tiếp ở đó.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Giờ đây, khi có ứng dụng đang toàn màn hình, chúng ẩn đi trên tất cả màn hình của bạn. Thoát toàn màn hình là chúng quay lại ngay.

Sau các cửa sổ thông thường, chúng vẫn ẩn như trước.

**Thử ngay:** Nếu bạn có hai màn hình, hãy mở một video toàn màn hình trên một trong hai. Thú cưng và quả bóng biến mất khỏi cả hai và quay lại khi bạn thoát toàn màn hình.

---

## <a id="v1.30.5"></a>Thú cưng tránh sang một bên khi bạn xem phim hay chơi game

<sub>1.30.5 · ngày 10 tháng 10, 2026</sub>

Thú cưng và quả bóng giờ sẽ ẩn đi khi một ứng dụng đang toàn màn hình, kể cả trên Mac có tai thỏ.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Trước đây, trên Mac có tai thỏ, thú cưng có thể nằm đè lên video hay game toàn màn hình, và quả bóng đôi khi bật lên trên ứng dụng toàn màn hình ở màn hình khác.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Giờ đây, khi một ứng dụng chiếm cả màn hình, thú cưng và quả bóng chờ ở chỗ khuất. Thoát toàn màn hình là chúng quay lại ngay.

Sau các cửa sổ thông thường, chúng vẫn ẩn như trước.

**Thử ngay:** Mở một video toàn màn hình hoặc bắt đầu một game. Thú cưng và quả bóng sẽ không làm phiền cho đến khi bạn xong.

---

## <a id="v1.30.4"></a>Thú cưng vẫn hiện rõ khi nhảy hay ngồi trên khung chọn đi lên

<sub>1.30.4 · ngày 10 tháng 10, 2026</sub>

Thú cưng và quả bóng không còn biến mất sau cửa sổ khi đang ở trên không.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Trước đây, khi thú cưng nhảy qua con trỏ hoặc ngồi trên khung chọn đi lên, cửa sổ được phóng to sẽ che mất nó, trông như thú cưng đã biến mất.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Giờ đây, khi thú cưng hoặc quả bóng ở cao hơn Dock, chúng hiện ra phía trước cửa sổ. Khi trở lại mặt đất, chúng lại đi ra sau cửa sổ.

Và thú cưng lại có thể đi dạo phía sau Dock, giống như trước.

**Thử ngay:** Phóng to một cửa sổ, bắt đầu vẽ khung chọn trên màn hình nền cạnh Dock để thú cưng trèo lên, rồi từ từ kéo lên trên. Thú cưng ngồi trên khung chọn đi lên phía trước cửa sổ.

---

## <a id="v1.30.3"></a>Thú cưng và quả bóng không còn chui xuống dưới Dock

<sub>1.30.3 · ngày 9 tháng 10, 2026</sub>

Thú cưng không còn đi dạo hay ngủ dưới Dock nữa, nên bạn luôn nhìn thấy nó.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Trước đây thú cưng và quả bóng hay đi dạo và nằm nghỉ ngay dưới Dock, nơi không ai nhìn thấy. Khi cửa sổ được phóng to, trông như thú cưng đã biến mất hẳn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Giờ Dock giống như một bức tường với chúng. Thú cưng quay lại ở mép Dock, còn quả bóng nảy ra khi chạm vào.

Vì vậy thú cưng luôn hiện rõ cạnh Dock, kể cả khi một cửa sổ chiếm cả màn hình.

**Thử ngay:** Phóng to một cửa sổ và quan sát vài phút. Thú cưng luôn hiện ở bên trái hoặc bên phải Dock.

---

## <a id="v1.30.2"></a>Thú cưng không còn biến mất sau cửa sổ

<sub>1.30.2 · ngày 9 tháng 10, 2026</sub>

Ngay cả khi bị cửa sổ che, thú cưng vẫn tiếp tục sống và rơi xuống đất khi bạn thả vùng chọn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Khi cửa sổ che kín cả dải nơi thú cưng sống, pikapik tạm dừng nó, và nó có thể đứng yên giữa không trung. Giờ thú cưng và quả bóng vẫn sống tiếp sau cửa sổ: đi lại, rơi xuống và chơi đùa. Chỉ có việc vẽ là tạm nghỉ.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Nếu khung chọn nhấc thú cưng lên sau một cửa sổ, nó sẽ rơi xuống ngay khi bạn thả ra và bạn lại thấy nó cạnh Dock.

Và khung chọn không còn nhấc thú cưng cao hơn dải của nó.

**Thử ngay:** Phóng to một cửa sổ, dùng khung chọn nhấc thú cưng lên phía sau nó rồi thả ra. Thú cưng rơi xuống và xuất hiện cạnh Dock.

---

## <a id="v1.30.1"></a>Khung chọn trên màn hình nền hoạt động trở lại

<sub>1.30.1 · ngày 9 tháng 10, 2026</sub>

Thú cưng và quả bóng lại nhảy lên khung chọn, còn danh sách ứng dụng chỉ sáng lên với ứng dụng.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Khi Dock hoặc một ứng dụng điều khiển máy từ xa che kín màn hình, pikapik không nhận ra khung chọn bạn vẽ trên màn hình nền. Giờ nó nhận ra trở lại, và thú cưng cùng quả bóng nhảy lên đó như trước.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Danh sách ứng dụng trong phần cài đặt chỉ sáng lên khi bạn kéo một ứng dụng tới. Các tệp khác bị bỏ qua: không hiện khung và không có gì thừa được thêm vào. Nếu bạn kéo ứng dụng cùng với các tệp khác, chỉ ứng dụng được thêm.

Và khung tắt ngay khi bạn thả ứng dụng hoặc đưa con trỏ đi chỗ khác.

**Thử ngay:** Vẽ một khung chọn trên màn hình nền và xem thú cưng nhảy lên đó.

---

## <a id="v1.30.0"></a>Thoát không còn tắt pikapik

<sub>1.30.0 · ngày 9 tháng 10, 2026</sub>

Lỡ bấm Thoát theo thói quen? Phím tắt, “Giữ máy thức” và thú cưng của bạn vẫn tiếp tục hoạt động.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

Khi bạn chọn “Thoát”, nhấn ⌘Q hoặc thoát pikapik từ Dock, ứng dụng đóng cửa sổ và ẩn biểu tượng trên thanh menu, nhưng vẫn lặng lẽ chạy nền: phím tắt, “Giữ máy thức” và thú cưng vẫn bật. Để biểu tượng quay lại, chỉ cần mở pikapik thêm lần nữa.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Muốn thoát hẳn? Giữ Option (⌥) rồi chọn “Thoát”, hoặc nhấn ⌥⌘Q. Lần đầu pikapik chuyển sang chạy nền, ứng dụng sẽ giải thích chuyện gì đã xảy ra và cho bạn thoát hẳn ngay tại đó.

Thích cách cũ hơn? Tắt “Tiếp tục chạy nền sau khi Thoát” trong Cài đặt › Cài đặt chung. Khi cập nhật, đổi ngôn ngữ, đăng xuất, khởi động lại và tắt máy, pikapik luôn thoát hẳn, nên chúng không bao giờ phải chờ nó.

**Thử ngay:** Nhấn ⌘Q, rồi mở lại pikapik để biểu tượng quay lại.

---

## <a id="v1.29.1"></a>Thú cưng dạo khắp mọi màn hình

<sub>1.29.1 · ngày 9 tháng 10, 2026</sub>

Có nhiều hơn một màn hình? Giờ thú cưng và quả bóng đi đến bất cứ đâu bạn nhìn, và không bao giờ bị lạc.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Khi đến mép một màn hình, thú cưng cứ thế bước sang màn hình bên cạnh, và quả bóng lăn theo sau. Bạn cũng có thể nhấc thú cưng hoặc quả bóng bằng chuột và mang sang bất kỳ màn hình nào. Nếu một ứng dụng chuyển sang toàn màn hình, chúng sang màn hình khác để khỏi vướng, còn nếu bạn rút một màn hình ra, chúng quay về màn hình chính.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Quả bóng không còn mắc kẹt trong góc. Thú cưng chạy tới, hất bóng ra sau qua đầu và chơi tiếp.

Và thú cưng không còn biến mất. Cứ hai giây nó kiểm tra xem mình còn trên màn hình không, và nếu có gì trục trặc sau khi ngủ, khóa Mac, đổi màn hình nền hay toàn màn hình, nó tự quay lại ngay.

**Thử ngay:** Mang thú cưng sang màn hình khác, hoặc lăn quả bóng vào góc.

**Đã sửa**

- Thú cưng bị ném không còn đáp xuống khung chọn cao hơn sức nhảy của nó, và không còn biến mất vì thế.

---

## <a id="v1.29.0"></a>Thú cưng đã có quả bóng

<sub>1.29.0 · ngày 9 tháng 10, 2026</sub>

Giờ có một quả bóng đá nhỏ lăn dọc mép dưới màn hình. Thú cưng chơi với nó, và bạn cũng chơi cùng được.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Quả bóng lăn và nảy như bóng thật. Thú cưng chạy theo, sút nó rồi lại đuổi theo. Lướt nhanh con trỏ vào quả bóng để tự sút, hoặc nhặt bóng lên, mang đi và ném, y như với thú cưng.

Có một mẹo nhỏ: bấm vào chỗ trống trên màn hình nền rồi kéo để vẽ khung chọn, có hoặc không giữ Shift. Khi bạn còn giữ nút chuột, khung chọn biến thành một cái kệ: thú cưng nhảy lên đó, và bóng cũng có thể rơi lên. Thả nút ra là kệ biến mất.

Muốn màn hình nền yên tĩnh hơn? Tắt Quả bóng trong cài đặt thú cưng, và nó lại tự đi dạo như trước.

**Thử ngay:** Cài đặt › Thú cưng › Quả bóng

**Đã sửa**

- Bên cạnh Dock, thú cưng lại nhảy cao bao nhiêu tùy thích. Nó chỉ ở thấp khi đang ngay phía trên Dock, nên không bao giờ ló lên trên Dock.

---

## <a id="v1.28.0"></a>Thêm ứng dụng chỉ bằng một cú bấm hoặc kéo thả

<sub>1.28.0 · ngày 9 tháng 10, 2026</sub>

Mỗi danh sách ứng dụng trong Cài đặt giờ hiển thị những gì có trong Dock và đang mở, và bạn có thể kéo ứng dụng vào đó từ Finder.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Một số tính năng cho bạn chọn những ứng dụng mà chúng sẽ đứng sang một bên, như nút xanh lá hay Home và End. Trước đây, “Thêm ứng dụng…” chỉ mở một thư mục dài chứa mọi thứ. Giờ đây sẽ hiện ra một chiếc kệ với các ứng dụng trong Dock và những ứng dụng đang mở. Bấm vào một ứng dụng để thêm, bấm lần nữa để bỏ ra. Những ứng dụng khác thì có “Khác…”.

Bạn cũng có thể kéo một ứng dụng từ Finder thẳng vào danh sách. Danh sách sẽ sáng lên để cho biết ứng dụng sẽ nằm ở đâu. Trò chơi của bạn cũng vậy, cùng một chiếc kệ.

Và nếu có gì trục trặc, biểu mẫu báo lỗi trên GitHub giờ cho bạn chọn phiên bản pikapik và macOS từ danh sách, nên báo cho chúng tôi nhanh hơn.

**Thử ngay:** Cài đặt › Cửa sổ, rồi “Thêm ứng dụng…”

**Đã sửa**

- Cuộn qua AnyDesk hoặc ứng dụng điều khiển từ xa khác không còn bị đảo hai lần khi cả hai máy Mac dùng hướng cuộn cổ điển. Giờ pikapik chỉ đảo hướng cuộn từ chuột hoặc bàn di chuột thật. Nếu một ứng dụng tự làm cuộn mượt, như Mos, hãy chọn hướng trong ứng dụng đó.
- Thú cưng ở lại phía sau Dock khi nhảy, giống như khi đi bộ, và tự quay lại sau khi bạn thoát ứng dụng toàn màn hình hoặc trò chơi.
- Những đường viền mảnh quanh các hình nhỏ trong Cài đặt không còn biến mất trên màn hình thường không có Retina.

---

## <a id="v1.27.3"></a>Thú cưng luôn trong tầm mắt, cửa sổ mở ra là dùng được ngay

<sub>1.27.3 · ngày 9 tháng 10, 2026</sub>

Thú cưng không còn trốn sau cửa sổ giữa chừng cú nhảy, và cửa sổ của pikapik mở ra là dùng được ngay.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Khi thú cưng nhảy qua con trỏ hoặc lộn nhào, nó có thể lọt ra sau cửa sổ của ứng dụng khác và biến mất giữa không trung. Giờ nó ở phía trước suốt cú nhảy và quay lại sau cửa sổ của bạn khi đáp xuống.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Khi pikapik lặng lẽ khởi động trong nền, lúc đăng nhập, sau khi cập nhật hoặc từ một liên kết pikapik://, cửa sổ của nó có thể mở ra màu xám và nằm sau các cửa sổ khác cho tới khi bạn bấm vào. Giờ Cài đặt và cửa sổ Tệp mới hiện ra phía trước, sẵn sàng để bạn gõ.

Thông báo sau Tạo bản sao nhỏ hơn và danh sách nơi bạn chọn ứng dụng để thêm cũng vậy. Bạn không cần làm gì cả.

**Thử ngay:** Cài đặt › Thú cưng

---

## <a id="v1.27.2"></a>Tệp mới đã trở lại, Cài đặt còn nhẹ hơn nữa

<sub>1.27.2 · ngày 9 tháng 10, 2026</sub>

Tệp mới đã có lại trong menu chuột phải của Finder cho mọi người, và Cài đặt càng ít làm nặng máy Mac hơn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Sau bản cập nhật trước, Finder có thể khởi động lại Tệp mới ở chế độ nền và quên mất nó hoạt động trong những thư mục nào, nên mục này lặng lẽ biến mất khỏi menu chuột phải. Giờ đây mỗi lần khởi động, Tệp mới nhắc lại cho Finder các thư mục của nó, và pikapik kiểm tra ngay sau khi mở rằng Finder đã ghi nhớ. Bạn không cần làm gì cả.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Các hình động trong Cài đặt giờ chỉ chuyển động khi ít nhất một nửa hình hiện trên màn hình. Trong hình trò chơi, nhân vật nhỏ vẫn chuyển động 30 lần mỗi giây, còn đồi và mặt đất phía sau thì 15 lần. Nhờ vậy trang Trò chơi làm nặng máy Mac ít hơn nhiều. Mọi thứ vẫn trông như cũ.

Sau khi cập nhật, pikapik không còn thêm lại các mục Finder của mình trừ khi ứng dụng thật sự được chuyển sang chỗ mới, nên Finder không phải tải lại chúng mỗi lần.

**Thử ngay:** Cài đặt › Trò chơi

---

## <a id="v1.27.1"></a>Êm hơn, nhẹ hơn, và Finder sẵn sàng ngay

<sub>1.27.1 · ngày 9 tháng 10, 2026</sub>

Cài đặt giờ gần như không làm Mac phải gắng sức, và các mục chuột phải trong Finder hoạt động ngay sau khi chuyển sang pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

Những hình động nhỏ trong Cài đặt trước đây vẽ lại cả trang nhiều lần mỗi giây, nên chỉ cần mở cửa sổ là Mac đã bận. Giờ mỗi hình chỉ vẽ lại chính nó, tối đa 30 lần mỗi giây, và nghỉ khi bạn cuộn qua hoặc ẩn cửa sổ. Trông vẫn y hệt.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Sau khi chuyển từ pika-tools sang pikapik, Finder có thể vẫn tìm ứng dụng cũ, nên “Tệp mới”, “Chuyển sang” và các mục chuột phải khác không làm gì cả. Giờ pikapik nhận ra điều này ở lần mở đầu tiên và tự khởi động lại Finder khi không có cửa sổ Finder nào đang mở và không có gì đang được sao chép. Nếu không, một dòng ngắn trên trang Finder sẽ có nút “Khởi động lại Finder”.

Trong Cài đặt hệ thống, giữa các ứng dụng mở khi đăng nhập, ứng dụng giờ hiện tên mới là pikapik và vẫn được bật.

**Thử ngay:** Cài đặt › Finder

---

## <a id="v1.27.0"></a>Làm quen với thú cưng trên màn hình nền

<sub>1.27.0 · ngày 9 tháng 10, 2026</sub>

Giờ đây có một người bạn nhỏ sống ở cạnh dưới màn hình của bạn, và ứng dụng có tên mới: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Bật nó trong Cài đặt › Thú cưng. Nó dạo bước sau các cửa sổ và Dock, nhảy qua con trỏ khi bị chắn đường và bật lên khi bạn nhấn phím cách. Bạn có thể nhấc nó lên, mang đi, tung nó và bắt lại ngay giữa cú nhảy.

Thỉnh thoảng nó ngồi xuống và nói một câu ngắn. Khi thật sự có phiên bản mới, nó báo cho bạn một lần, và bấm vào nó sẽ mở Cài đặt, nơi bản cập nhật đang chờ.

pika-tools giờ có tên là pikapik. Quyền, cài đặt và các liên kết trong Phím tắt vẫn giữ nguyên. Nếu bạn cài bằng Homebrew, hãy chạy một lần `brew update && brew upgrade --cask pikapik`.

**Thử ngay:** Cài đặt › Thú cưng

**Đã sửa**

- Việc kiểm tra cập nhật báo có phiên bản mới ngay cả khi bạn đã dùng bản mới nhất.
- Trang Quyền làm máy Mac bận rộn suốt lúc mở.

---

## <a id="v1.26.2"></a>Có gì mới, bằng ngôn ngữ của bạn

<sub>1.26.2 · ngày 8 tháng 10, 2026</sub>

“Có gì mới” trong cài đặt giờ mở trang này, cùng ngôn ngữ với ứng dụng.

<img src="../media/icon.png" width="128" height="128" alt="">

Mở Cài đặt › Giới thiệu và bấm “Có gì mới”. Bạn sẽ đến thẳng đây, trang có một hình cho mỗi bản cập nhật, bằng ngôn ngữ mà pika-tools đang dùng.

Danh sách thay đổi đầy đủ cũng gọn gàng hơn. Mỗi phiên bản ghi rõ ngày ra mắt, và mỗi số phiên bản mở trang tải về của nó.

Cách pika-tools hoạt động không có gì thay đổi. Bản cập nhật vẫn đến như trước, tự động hoặc qua Homebrew.

**Thử ngay:** Cài đặt › Giới thiệu › Có gì mới

**Đã sửa**

- “Có gì mới” từng mở một danh sách kỹ thuật dài bằng tiếng Anh thay vì trang này.
- Các liên kết trong danh sách thay đổi từng không dẫn đến đâu giờ mở đúng trang.

---

## <a id="v1.26.1"></a>Hình trò chơi đã sống động

<sub>1.26.1 · ngày 8 tháng 10, 2026</sub>

Hình trên trang “Trò chơi” giờ đã chuyển động, nên bạn thấy rõ mỗi công tắc chặn điều gì.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Sau mỗi công tắc trên trang “Trò chơi”, giờ có một trò chơi nhỏ đang chạy. Vài phím hiện ra và được nhấn, và bạn thấy thứ gì sẽ bật lên trên trò chơi, như Spotlight hay Mission Control, trong khi trò chơi dừng lại. Khi công tắc bật, các phím chỉ sáng lên nhẹ nhàng và trò chơi vẫn tiếp tục. Gạt một công tắc, hình sẽ cho thấy sự khác biệt ngay.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Trò chơi nhỏ theo giao diện của máy Mac: một ngày nắng đẹp ở chế độ sáng và một đêm yên tĩnh có trăng sao ở chế độ tối.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

Trong mọi hình của ứng dụng, con trỏ giờ di chuyển như một bàn tay: đi xa thì mất thêm chút thời gian, dừng lại rồi mới bấm. Khi hình bắt đầu lại, nó lướt nhẹ về đầu thay vì nhảy. Hình được nghỉ khi cửa sổ bị ẩn, và khi bật “Giảm chuyển động” thì hình đứng yên.

**Thử ngay:** Cài đặt › Trò chơi

---

## <a id="v1.26.0"></a>Biểu tượng mới, và dọn sạch quyền cũ

<sub>1.26.0 · ngày 8 tháng 10, 2026</sub>

pika-tools có diện mạo mới, và giờ có thể xóa các quyền mà ứng dụng đã xóa để lại.

<img src="../media/icon.png" width="128" height="128" alt="">

Biểu tượng mới là dấu pikapik màu xanh dương, tím và san hô trên một ô tối màu. Thanh menu hiển thị cùng hình đó, tự hợp với thanh menu sáng hoặc tối. Khi mọi công cụ đều tắt, hình sẽ nhạt đi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

Khi bạn xóa một ứng dụng, macOS vẫn giữ các quyền bạn đã cấp cho nó, và Cài đặt hệ thống không có cách nào để gỡ chúng. Giờ trang “Quyền” có một danh sách tên là “Còn lại từ ứng dụng đã xóa”: mỗi ứng dụng kèm biểu tượng, những gì nó từng được phép làm và khi nào. “Xóa” dọn một ứng dụng, “Xóa tất cả” dọn hết, còn ứng dụng bạn cài lại sẽ chỉ hỏi lại từ đầu. Để xem danh sách, hãy cấp cho pika-tools quyền Truy cập toàn bộ ổ đĩa: nó chỉ xem và không thay đổi gì cho đến khi bạn bấm “Xóa”.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Hình ảnh trên các trang “Hoạt ảnh” và “Trò chơi” được vẽ lại theo đúng kích thước thật, nên trông sắc nét. Cửa sổ thu nhỏ vào Dock với các góc bo tròn, và con trỏ bấm trước, rồi menu mới mở ra. Và ở cuối “Giới thiệu” giờ có một dòng nhẹ nhàng: “Làm bằng cả tấm lòng · Mời mình ly cà phê”. Không có gì bật lên hay nhắc nhở bạn cả.

**Thử ngay:** Cài đặt › Quyền, rồi “Còn lại từ ứng dụng đã xóa”

**Đã sửa**

- Bấm vào một phím tắt hệ thống sẽ mở thẳng mục của nó trong Cài đặt hệ thống, như Mission Control, chứ không chỉ “Bàn phím”.
- Gợi ý cạnh các phím không còn biến mất ngay khi Cài đặt hệ thống mở ra.

---

## <a id="v1.25.2"></a>Phím tắt mở đúng nơi bạn thay đổi nó

<sub>1.25.2 · ngày 8 tháng 10, 2026</sub>

Bấm vào một phím tắt trong Cài đặt, Cài đặt hệ thống sẽ mở đúng chỗ.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Trước đây, bấm vào một phím tắt, như phím tắt cho Spotlight, luôn đưa bạn tới “Phím bổ trợ”. Giờ các phím Spotlight mở thẳng Spotlight.

Với các phím tắt khác, Cài đặt hệ thống mở ở “Bàn phím”, và một gợi ý ngắn cạnh các phím cho bạn biết cần bấm vào đâu: “Phím tắt…”, rồi “Mission Control” hoặc mục khác.

Trang Trò chơi và “Cắt tệp trong Finder” cũng vậy. Khi cắt tệp, gợi ý sẽ đưa bạn tới “Phím tắt ứng dụng”.

**Thử ngay:** Cài đặt › Trò chơi, rồi bấm vào các phím cạnh “Tìm kiếm không bật lên”

**Đã sửa**

- Bấm vào phím tắt không còn mở “Phím bổ trợ” nữa.

---

## <a id="v1.25.1"></a>Hình lớn, và chọn trò chơi ngay từ Dock

<sub>1.25.1 · ngày 8 tháng 10, 2026</sub>

Mỗi công tắc giờ có một hình lớn, và “Thêm trò chơi…” cho thấy những gì có trong Dock của bạn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

Ở trang Hoạt ảnh và Trò chơi, mọi hình giờ đều lớn, giống hình ở đầu trang. Nhìn là biết ngay mỗi công tắc làm gì, và hình vẫn chuyển động theo tốc độ bạn chọn.

Nhấn “Thêm trò chơi…” là bạn thấy Dock của mình: các ứng dụng bạn giữ ở đó và các ứng dụng đang mở, theo đúng thứ tự. Trò chơi trong Dock vẫn hiện ra dù đang đóng, cả Minecraft cũng vậy. Một cú bấm là thêm, và dấu kiểm cho biết nó đã có trong danh sách. Bấm thêm lần nữa để bỏ ra.

Bạn vẫn có thể kéo trò chơi vào đây từ Finder. Không cần kéo nó ra khỏi Dock nữa, nên Dock sẽ không hỏi có xóa nó không.

**Thử ngay:** Cài đặt › Trò chơi, rồi “Thêm trò chơi…”

**Đã sửa**

- Trò chơi nằm trong Dock nhưng đang đóng giờ đã hiện trong danh sách để thêm.

---

## <a id="v1.25.0"></a>Thêm trò chơi chỉ với một cú bấm, và tự chọn phím

<sub>1.25.0 · ngày 8 tháng 10, 2026</sub>

Giờ bạn chọn trò chơi ngay trong các ứng dụng đang mở, và tự quyết định phím để thoát và đóng.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Nhấn “Thêm trò chơi…”, các ứng dụng đang mở sẽ hiện ra với biểu tượng lớn, giống trong Dock. Một cú bấm là thêm được trò chơi, hoặc kéo biểu tượng vào danh sách. Bạn cũng có thể thả trò chơi thẳng từ Finder hoặc Dock. Giờ ứng dụng nào cũng có thể là trò chơi, kể cả Minecraft chạy trên Java, và các trò chơi bạn thêm trước đây vẫn còn nguyên.

Công tắc của Chế độ trò chơi giờ nói bằng lời dễ hiểu, như “Trò chơi không đóng” hay “Tìm kiếm không bật lên”, và mỗi công tắc có một hình nhỏ về thứ nó chặn. Tên trong hệ thống, như Spotlight, nằm bên cạnh bằng màu xám.

Trong Cài đặt › Cửa sổ, bấm vào phím cạnh “Thoát ứng dụng” hoặc “Đóng cửa sổ” rồi nhấn phím mới. ⌫ đưa ⇧⌘Q và ⇧⌘W trở lại, và nếu phím đã được dùng, pika-tools sẽ hỏi bạn trước. Chế độ trò chơi cũng dùng phím của bạn. Và mọi phím tắt trong Cài đặt giờ hiện đúng cách chúng thật sự được đặt trên máy Mac của bạn: phím của bạn, hoặc Tắt.

**Thử ngay:** Cài đặt › Trò chơi, rồi “Thêm trò chơi…”

**Đã sửa**

- Cắt tệp trong Finder giờ theo phím tắt Cắt mà bạn đặt cho Finder trong Cài đặt hệ thống.
- Tên ứng dụng trong danh sách hiện không có “.app”.

---

## <a id="v1.24.1"></a>Thay đổi tốc độ thấy ngay

<sub>1.24.1 · ngày 8 tháng 10, 2026</sub>

Trang Hoạt ảnh giờ cho bạn biết thay đổi hiện ra ở đâu, và giữ an toàn cho các giá trị của riêng bạn.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

Dock chỉ có thể trượt nhanh hơn khi nó tự ẩn. Nếu Dock của bạn luôn hiện, công tắc “Tự động ẩn Dock” giờ nằm ngay dưới thanh trượt tốc độ.

Sau khi thay đổi, một dòng ở cuối trang cho biết ứng dụng sẽ áp dụng khi bạn mở lại. Finder chỉ hiện tốc độ mới của Xem nhanh và cột sau khi khởi động lại, nên dòng đó có nút “Khởi động lại Finder”.

Thanh trượt không bao giờ làm chậm thứ bạn đã tăng tốc từ trước, ví dụ bằng lệnh trong Terminal. Còn “Khôi phục mặc định” hay gỡ cài đặt pika-tools sẽ trả lại các giá trị bạn có trước đó, thay vì xóa chúng.

**Thử ngay:** Cài đặt › Hoạt ảnh

**Đã sửa**

- Dock không còn khởi động lại vô cớ khi nó không tự ẩn.

---

## <a id="v1.24.0"></a>Chọn tốc độ chuyển động cho máy Mac

<sub>1.24.0 · ngày 8 tháng 10, 2026</sub>

Trang Hoạt ảnh mới quyết định mọi thứ trên máy Mac mở ra, trượt vào và hiện lên nhanh đến đâu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

Một thanh trượt là đủ. Kéo nó, và Dock đang ẩn, cửa sổ mới, hộp thoại lưu, Xem nhanh và cột trong Finder cùng nhanh lên, từ “Như trong macOS” đến “Tức thì”.

Muốn chỉnh riêng một thứ? Mỗi hiệu ứng có cài đặt riêng, hiệu ứng thu nhỏ, biểu tượng nảy trong Dock và hoạt ảnh Finder cũng vậy. Cạnh mỗi cài đặt, một hình nhỏ chuyển động đúng với tốc độ bạn chọn.

“Khôi phục mặc định” chỉ hoàn tác những gì pika-tools đã đổi, gỡ cài đặt cũng vậy. Nếu bạn từng tự đặt một trong các giá trị này trong Terminal, pika-tools sẽ hiện nó đúng như vậy.

**Thử ngay:** Cài đặt › Hoạt ảnh

---

## <a id="v1.23.2"></a>Mỗi phím tắt một công tắc trong Chế độ trò chơi

<sub>1.23.2 · ngày 8 tháng 10, 2026</sub>

Giờ bạn tự quyết định, từng phím tắt một, Chế độ trò chơi sẽ chặn gì khi bạn chơi.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q và ⌘W giờ có công tắc riêng, Spotlight, Siri, ⌘Tab, Mission Control, thao tác vuốt, con trỏ, màn hình và mọi thứ còn lại cũng vậy. Các lựa chọn trước đây của bạn vẫn được giữ.

Mỗi hàng hiện đúng những phím mà nó chặn, nên bạn luôn biết một công tắc làm gì.

Cài đặt ngôn ngữ bàn phím đã rời khỏi Chế độ trò chơi. ⌃Dấu cách và các cách đổi ngôn ngữ khác luôn hoạt động, kể cả khi đang chơi.

**Thử ngay:** Cài đặt › Trò chơi

**Đã sửa**

- Các phím trong cùng một phím tắt nằm sát nhau hơn, và giữa các phím tắt khác nhau có thêm chút khoảng trống, nên dễ thấy chỗ một phím tắt kết thúc và phím tắt sau bắt đầu.

---

## <a id="v1.23.1"></a>Internet của bạn nhanh đến đâu, nói bằng lời dễ hiểu

<sub>1.23.1 · ngày 8 tháng 10, 2026</sub>

Kiểm tra tốc độ đo kết nối của bạn và nói đơn giản là nó đủ cho việc gì.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Nhấn “Kiểm tra tốc độ”, và sau khoảng nửa phút bạn sẽ thấy tải xuống, tải lên, ping và độ phản hồi. Dưới các con số, vài lời đơn giản cho biết như vậy có đủ để xem phim 4K, gọi video, chơi game trực tuyến và tải tệp lớn hay không.

Việc đo chạy trên máy chủ của Apple, và kết quả gần nhất được giữ đến lần đo sau. Kiểm tra tốc độ có trang riêng trong Cài đặt, một dòng trong bảng ở thanh menu và một liên kết cho ứng dụng Phím tắt: `pika-tools://speed-test`.

Chế độ trò chơi học thêm hai điều. Chặn phím tắt Control giờ là một phần của nó: trong trò chơi, ⌃-bấm vẫn là một cú bấm và phím tắt với ⌃ không chạy; ở mọi nơi khác, ⌃ hoạt động như thường. Và nó nhận ra Minecraft: thêm Minecraft Launcher hoặc CurseForge vào trò chơi của bạn, Chế độ trò chơi sẽ bật khi chính Minecraft ở phía trước.

**Thử ngay:** Cài đặt › Kiểm tra tốc độ, rồi “Kiểm tra tốc độ”

**Đã sửa**

- Các bản thử nghiệm pika-tools do mọi người tự build giờ lưu cài đặt riêng trong iCloud Drive và không còn đụng đến cài đặt của bạn.

---

## <a id="v1.23.0"></a>Chế độ trò chơi: chơi không bị gián đoạn

<sub>1.23.0 · ngày 7 tháng 10, 2026</sub>

Thêm trò chơi của bạn, và máy Mac sẽ thôi kéo bạn ra khỏi chúng.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Trong lúc bạn chơi, Spotlight, Siri, ⌘Tab, Mission Control và thao tác vuốt giữa các màn hình nền không mở đè lên trò chơi. ⌘Q và ⌘W không vô tình đóng trò chơi, con trỏ ở yên trên màn hình của trò chơi và màn hình luôn sáng.

Để thoát trò chơi, nhấn ⇧⌘Q; để đóng cửa sổ của nó, nhấn ⇧⌘W. ⌥⌘Esc luôn hoạt động. pika-tools gợi ý những trò chơi tìm thấy trên máy Mac của bạn. Chế độ trò chơi tắt cho đến khi bạn bật nó.

Giữ máy thức giờ cho bạn chọn màn hình sẽ làm gì: luôn sáng, không có trình bảo vệ màn hình hay màn hình khóa, hoặc tắt như thường trong khi máy Mac vẫn làm việc. Nút mới “Tắt màn hình ngay” làm tối màn hình lập tức; di chuột hoặc nhấn một phím để màn hình sáng lại.

**Thử ngay:** Cài đặt › Trò chơi, rồi “Thêm trò chơi…”

**Đã sửa**

- Trên máy Mac không có nắp gập, Giữ máy thức không còn hiện các tùy chọn khi gập nắp.

---

<p align="center"><sub>Các phiên bản cũ hơn có trong <a href="../../CHANGELOG.md">nhật ký thay đổi</a> (bằng tiếng Anh).</sub></p>
