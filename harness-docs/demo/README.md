# Hướng dẫn Luồng công việc Tập trung vào Repository (Repository-Centered Workflow Demo)

Tài liệu hướng dẫn này chỉ ra cách cùng một repository xử lý bốn loại yêu cầu khác nhau mà không bắt buộc tất cả phải đi qua một quy trình đơn lẻ.

## Đặc tả sản phẩm mẫu

Giả sử một ứng dụng theo dõi nhiệm vụ nhỏ với quy tắc sản phẩm trong `harness-docs/product/tasks.md`:

```text
Một nhiệm vụ có tiêu đề, trạng thái, người được giao và ngày đến hạn tùy chọn.
Các trạng thái được hỗ trợ là todo, in_progress, done và canceled.
Chỉ một nhiệm vụ chưa hoàn thành có ngày đến hạn đã qua mới là quá hạn (overdue).
```

## 1. Câu hỏi Chỉ đọc (Read-Only Question)

Yêu cầu:

```text
Khi nào một nhiệm vụ trở thành quá hạn?
```

Từng bước thực hiện:

1. Đọc `AGENTS.md`, file chỉ tới bản đồ repository.
2. Mở đặc tả sản phẩm liên quan, `harness-docs/product/tasks.md`.
3. Trả lời từ quy tắc đó và trích dẫn file.
4. Không bootstrap database, không tạo intake, không ghi trace hoặc chỉnh sửa repository.

Nguyên nhân và kết quả: câu hỏi cần bằng chứng, không cần trạng thái quy trình lâu dài. Đường dẫn chỉ đọc giúp câu trả lời nhanh hơn và ngăn một lời giải thích làm thay đổi ngầm dự án.

## 2. Thay đổi Có giới hạn (Bounded Change)

Yêu cầu:

```text
Sửa danh sách nhiệm vụ sao cho các nhiệm vụ đã hủy (canceled) không bị đánh dấu là quá hạn.
```

Từng bước thực hiện:

1. Đọc quy tắc quá hạn và tìm đoạn tính toán danh sách nhiệm vụ.
2. Kiểm tra các bài kiểm thử và lệnh xác thực repository gần nhất.
3. Giữ một kế hoạch làm việc ngắn hạn trong phiên hiện tại.
4. Thay đổi đoạn tính toán để yêu cầu một nhiệm vụ chưa hoàn thành và không phải bị hủy.
5. Thêm hoặc cập nhật bài kiểm thử hồi quy cho một nhiệm vụ bị hủy có ngày đến hạn đã qua.
6. Chạy bài kiểm thử tập trung, sau đó là cổng xác thực liên quan của repository.
7. Báo cáo hành vi đã thay đổi và bằng chứng.

Nguyên nhân và kết quả: phạm vi mang tính cục bộ và có thể phục hồi từ diff. Việc tạo một kế hoạch lâu dài hoặc hàng cơ sở dữ liệu sẽ thêm công việc đồng bộ hóa mà không giữ lại thông tin nào mà Git và bài kiểm thử chưa có.

## 3. Thay đổi Lâu dài (Durable Change)

Yêu cầu:

```text
Thay thế xử lý ngày đến hạn cục bộ bằng múi giờ của đội ngũ trên toàn bộ API, worker, UI và dữ liệu lưu trữ.
```

Từng bước thực hiện:

1. Kiểm tra các bề mặt sản phẩm, kiến trúc, migration và xác thực.
2. Sao chép `harness-docs/templates/exec-plan.md` thành một file mô tả dưới `harness-docs/plans/active/`.
3. Ghi lại mục tiêu, phi mục tiêu, ranh giới bị ảnh hưởng, các giai đoạn, rủi ro, phục hồi và các lệnh kiểm thử.
4. Commit kế hoạch để một phiên khác có thể tiếp tục từ trạng thái repository.
5. Triển khai theo từng nhóm có thể review. Sau mỗi nhóm, cập nhật tiến độ và bằng chứng xác thực trong kế hoạch và commit cả công việc lẫn bộ nhớ lâu dài của nó.
6. Ghi lại một quyết định dưới `harness-docs/decisions/` nếu mô hình múi giờ là một lựa chọn kiến trúc mà công việc trong tương lai phải kế thừa.
7. Chạy kiểm thử end-to-end trên ranh giới ứng dụng hiển thị.
8. Đánh dấu kế hoạch hoàn thành và di chuyển nó sang `harness-docs/plans/completed/`.

Nguyên nhân và kết quả: thay đổi này trải dài qua các ranh giới và có thể kéo dài hơn một phiên. Một kế hoạch được quản lý phiên bản ngăn lịch sử chat trở thành bản ghi duy nhất về trình tự, sự đánh đổi, phục hồi và công việc còn lại.

## 4. Sự Mơ hồ có Hệ quả (Consequential Ambiguity)

Yêu cầu:

```text
Đơn giản hóa quyền hạn nhiệm vụ (Simplify task permissions).
```

Repository tiết lộ ít nhất hai cách hiểu khả thi:

- allow every teammate to edit every task; hoặc
- keep ownership restrictions but simplify the permission code.

Từng bước thực hiện:

1. Kiểm tra contract phân quyền hiện tại và các nơi gọi.
2. Nhận diện rằng một cách hiểu làm thay đổi người có thể sửa dữ liệu người dùng.
3. Tạm dừng trước khi sửa code.
4. Trình bày hai lựa chọn với tác động cụ thể: mở rộng quyền truy cập so với refactor chỉ ở cấp triển khai.
5. Chỉ tiếp tục khi hành vi sản phẩm được yêu cầu có thẩm quyền rõ ràng.

Nguyên nhân và kết quả: sự không chắc chắn không được giải quyết bằng cách thêm nhiều bản ghi quy trình. Nó được giải quyết bằng cách giữ một quyết định sản phẩm có hệ quả với con người làm chủ nó.

## Những gì Cố ý Vắng mặt (What Is Deliberately Absent)

Không có luồng mặc định nào ở trên yêu cầu hàng story, ma trận kiểm chứng, điểm trace, bản ghi kiểm toán, đề xuất hoặc cơ sở dữ liệu SQLite cục bộ. Chúng tiếp tục khả dụng như một tầng điều khiển tương thích khi một runner điều phối bên ngoài cần rõ ràng; chúng không đứng giữa một yêu cầu thông thường và công việc repository.
