# 0028 Mã hóa Bất biến có Thẩm quyền (Authoritative Invariant Encoding)

Ngày: 2026-08-11

## Trạng thái

Đã chấp nhận.

## Bối cảnh

Harness đã yêu cầu quyền thẩm quyền repository trước khi thay đổi chính sách có thể quan sát từ bên ngoài. Tuy nhiên, nó chưa cung cấp cho người dùng mới một lộ trình trực tiếp để chuyển đổi một ranh giới kiến trúc, độ tin cậy, bảo mật hoặc chất lượng đã được chấp nhận thành một kiểm tra cơ học. Nó cũng chưa yêu cầu quá trình onboard so sánh các bất biến đã được tài liệu hóa với xác thực thực thi được.

Nếu không có lộ trình đó, các agent có thể để các quy tắc đã chấp nhận ở dạng văn bản thuần, tự tạo chính sách từ quy ước, thêm một framework xác thực song song, hoặc phóng đại kiểm tra cục bộ hay CI thành quy tắc merge.

## Quyết định

1. Điểm vào agent gọn nhẹ định tuyến công việc bất biến đến một pattern đã cài đặt.
2. Luồng công việc yêu cầu thẩm quyền đã chấp nhận trước, chủ sở hữu xác thực gốc của repository, kiểm tra cơ học nhỏ nhất, chẩn đoán có thể hành động, và cả bằng chứng thuận (positive proof) lẫn bằng chứng nghịch (negative proof).
3. Lõi cài đặt `$encode-invariant`. Điều kiện kích hoạt bao gồm các yêu cầu thực thi ranh giới, ngăn chặn tái phát, thêm bảo vệ cấu trúc, hoặc chuyển đổi các quy tắc đã chấp nhận thành xác thực. Các yêu cầu phù hợp có thể gọi nó một cách ngầm định; nó không thể suy diễn chính sách từ quy ước, mẫu mã nguồn, kiểm thử, giá trị mặc định hoặc các tùy chọn chưa được tài liệu hóa.
4. `$onboard-repository` so sánh các bất biến đã chấp nhận với các kiểm tra thực thi được trong phiên đề xuất chỉ đọc. Nó báo cáo các quy tắc chưa được thực thi và các kiểm tra thiếu thẩm quyền mà không chỉnh sửa, thực thi, kích hoạt hoặc loại bỏ các bảo vệ.
5. Báo cáo phân biệt xác thực cục bộ, hook tùy chọn, lệnh gọi CI đã check-in, kết quả CI đã quan sát và bảo vệ nhánh bên ngoài. Không cấp độ nào chứng minh cấp độ khác.
6. Hướng dẫn duy trì tính trung lập về triển khai. Nó không quy định kiến trúc ứng dụng, ngôn ngữ, linter, hook, nhà cung cấp CI, chính sách merge hoặc bảo vệ nhánh và không thay đổi các cài đặt bên ngoài.

## Các Phương án Đã Xem xét

1. **Coi kiểm thử hoặc quy ước là chính sách.** Bị từ chối vì sự thật thực thi được và quan sát được không thể giải quyết một lựa chọn chuẩn tắc bị thiếu.
2. **Đặt toàn bộ phương pháp trong `AGENTS.md`.** Bị từ chối vì mọi nhiệm vụ sẽ phải trả chi phí ngữ cảnh cho công việc bất biến chuyên biệt.
3. **Tạo một trình xác thực phổ quát.** Bị từ chối vì các repository consumer sở hữu ngôn ngữ, công cụ, lệnh xác thực và cấu trúc thực thi của riêng mình.
4. **Cho phép onboard âm thầm sửa lỗi.** Bị từ chối vì khám phá (discovery) vẫn ở chế độ chỉ đọc và không thể cấp quyền thẩm quyền để thay đổi những gì nó tìm thấy.

## Hệ quả

- Người dùng mới có thể khám phá và áp dụng một luồng bất biến được kiểm soát bởi thẩm quyền.
- Văn bản đã chấp nhận có thể có bằng chứng chống tái phát mà không cần hệ thống xác thực thứ hai.
- Onboard phát hiện sự trôi dạt giữa tài liệu và kiểm tra trong khi giữ nguyên phiên chỉ đọc đầu tiên.
- Agent phải báo cáo việc thực thi bên ngoài chưa được xác minh thay vì suy diễn chặn merge từ các file đã check-in.
- Payload lõi và ứng viên phát hành tăng thêm một pattern và một skill.
