# Tài liệu Hướng dẫn Demo Harness (Harness Demo Walkthrough)

Tài liệu hướng dẫn này chỉ ra loại hình chuyển đổi mà Harness v0 được thiết kế để hỗ trợ. Đây chỉ là một ví dụ minh họa và không phải là một đặc tả sản phẩm đã được phê duyệt cho kho lưu trữ này.

## Đầu vào (Input)

Con người đưa ra một ý tưởng sản phẩm nhỏ:

```text
Xây dựng một công cụ theo dõi nhiệm vụ của đội ngũ (team task tracker) đơn giản, nơi mọi người có thể tạo nhiệm vụ, giao chúng cho đồng đội, thay đổi trạng thái và xem nhiệm vụ nào quá hạn (overdue).
```

Nếu không có harness, một agent có thể nhảy trực tiếp vào việc lựa chọn framework, thiết kế lược đồ cơ sở dữ liệu, dựng khung giao diện UI và viết các bài kiểm thử cùng một lúc.

Harness v0 yêu cầu agent làm chậm công việc lại một chút để làm cho nó có thể kiểm tra được (inspectable).

## Tiếp nhận (Intake)

Đầu vào được phân loại là một đặc tả mới (new spec) vì nó giới thiệu một ý tưởng sản phẩm mới hoàn toàn mà chưa có đặc tả sản phẩm hiện tại nào.

Đầu ra đầu tiên không nên là mã nguồn ứng dụng. Nó nên là một bản ghi tiếp nhận đặc tả sử dụng mẫu `docs/templates/spec-intake.md`.

Ví dụ về dạng tiếp nhận (intake shape):

```text
Type (Loại hình): new spec
Lane (Làn rủi ro): normal
Reason (Lý do): tạo ra bề mặt sản phẩm mới nhưng chưa chạm đến xác thực (auth), thanh toán, di chuyển dữ liệu hoặc hành vi của nhà cung cấp bên ngoài.
Candidate product docs (Tài liệu sản phẩm ứng viên):
- docs/product/overview.md
- docs/product/tasks.md
- docs/product/assignment.md
Candidate epics (Epic ứng viên):
- E01 Ghi nhận nhiệm vụ và theo dõi trạng thái
- E02 Giao việc và quyền sở hữu
- E03 Hiển thị nhiệm vụ quá hạn
Validation shape (Dạng thức xác thực):
- Bằng chứng Unit test cho quy tắc trạng thái nhiệm vụ
- Bằng chứng Integration test cho việc lưu trữ nhiệm vụ
- Bằng chứng E2E test cho luồng tạo, giao và hoàn thành nhiệm vụ
```

## Đặc tả sản phẩm (Product Contract)

Sau khi tiếp nhận, agent trích xuất các tài liệu sản phẩm nhỏ thay vì coi prompt ban đầu là nguồn sự thật vĩnh viễn.

Ví dụ về các phân đoạn đặc tả sản phẩm:

```text
docs/product/tasks.md

Một nhiệm vụ bao gồm tiêu đề, trạng thái, người được giao, ngày hết hạn và nhãn thời gian.
Các trạng thái được hỗ trợ là todo, in_progress, done và canceled.
Chỉ các nhiệm vụ mở (open tasks) mới có thể trở thành quá hạn.
```

```text
docs/product/assignment.md

Một nhiệm vụ có thể được giao cho một đồng đội.
Các nhiệm vụ chưa được giao vẫn hiển thị trong backlog của đội ngũ.
Thay đổi người được giao không làm thay đổi trạng thái nhiệm vụ.
```

## Gói story packet (Story Packet)

Khi đặc tả sản phẩm đã đủ rõ ràng, agent tạo một gói story packet từ mẫu `docs/templates/story.md`.

Ví dụ về một story:

```text
Story: US-001 Tạo một nhiệm vụ
Lane: normal
Product contract: Một đồng đội có thể tạo một nhiệm vụ với tiêu đề, người được giao tùy chọn, ngày hết hạn tùy chọn và trạng thái mặc định là todo.
Acceptance criteria (Tiêu chí nghiệm thu):
- Tạo nhiệm vụ thành công khi có tiêu đề.
- Tạo nhiệm vụ không có tiêu đề sẽ thất bại kèm theo thông báo lỗi xác thực rõ ràng.
- Một nhiệm vụ mới bắt đầu ở trạng thái todo.
- Nhiệm vụ được tạo sẽ xuất hiện trong backlog của đội ngũ.
Validation (Xác thực):
- Unit: các quy tắc tạo nhiệm vụ
- Integration: việc lưu trữ và ranh giới xác thực
- E2E: tạo nhiệm vụ từ bề mặt nhiệm vụ hiển thị
```

## Ma trận Kiểm chứng (Proof Matrix)

Story sau đó sẽ xuất hiện trong ma trận kiểm chứng lâu dài để hành vi và bằng chứng xác thực luôn được liên kết:

```bash
scripts/bin/harness-cli story add --id US-001 --title "Create a task" --lane normal --contract docs/product/tasks.md
scripts/bin/harness-cli query matrix
```

Ví dụ một dòng trong ma trận:

```text
| US-001 Create a task | docs/product/tasks.md | yes | yes | yes | no | planned | none |
```

Dòng này không được đánh dấu là `implemented` cho đến khi có bằng chứng xác thực thực tế.

## Bản ghi Quyết định Kỹ thuật (Decision Record)

Nếu đội ngũ chọn một stack công nghệ, hướng đi mô hình dữ liệu hoặc một quy tắc sản phẩm quan trọng, agent sẽ ghi lại quyết định đó dưới thư mục `docs/decisions/`.

Ví dụ về quyết định:

```text
Quyết định: Nhiệm vụ sử dụng một tập hợp trạng thái rõ ràng thay vì các nhãn tự do.

Lý do: trạng thái điều hướng hành vi quá hạn, bộ lọc và xác thực, vì vậy phiên bản đầu tiên cần một mô hình trạng thái có thể dự đoán được.
```

## Triển khai thực tế (Implementation)

Chỉ sau khi đặc tả, story và dạng xác thực đã rõ ràng thì việc triển khai thực tế mới nên bắt đầu.

Đối với Harness v0, sự phân biệt đó rất quan trọng. Kho lưu trữ này cố ý không đi kèm với các thư mục ứng dụng, kịch bản package, cấu hình CI hoặc các lệnh kiểm thử. Chúng chỉ nên xuất hiện khi một câu chuyện thực tế lựa chọn một stack công nghệ thực tế và có nhu cầu sử dụng chúng.

## Thay đổi Harness (Harness Delta)

Mỗi nhiệm vụ cũng đặt câu hỏi liệu bản thân harness có cần cải tiến hay không.

Nếu bản demo này chỉ ra rằng nhiều dự án cần cùng một ví dụ tiếp nhận (intake example), hành động theo dõi phù hợp có thể là:

```text
Thêm một tài liệu hướng dẫn spec ví dụ có thể tái sử dụng hoặc cấu hình khởi đầu.
```

Các cải tiến nhỏ có thể được thực hiện trực tiếp. Các thay đổi quy trình lớn hơn nên được ghi lại bằng lệnh `scripts/bin/harness-cli backlog add`.
