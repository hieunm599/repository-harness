# Kiểm toán Harness (Harness Audit)

Lệnh `scripts/bin/harness-cli audit` phát hiện sự sai lệch (drift) trong trạng thái bền vững của Harness và in ra điểm entropy. Điểm số càng thấp càng tốt.

## Các Hạng mục Kiểm tra (Checks)

| Danh mục | Ý nghĩa | Trọng số (Weight) |
| --- | --- | --- |
| Các story bị mồ côi (Orphaned stories) | Các story đang lên kế hoạch hoặc đang triển khai nhưng không có trace nào liên kết. | 10 |
| Các story chưa xác thực (Unverified stories) | Các story đang hoạt động (active) hoặc đã triển khai (implemented) có cấu hình `verify_command` nhưng chưa có kết quả xác thực nào được ghi lại. Các story đã ngừng (retired) là bản ghi lịch sử và không được tính. | 5 |
| Quyết định chưa xác thực | Các quyết định kỹ thuật có cấu hình `verify_command` nhưng chưa có kết quả xác thực nào được ghi lại. | 5 |
| Backlog mở thiếu kết quả thực tế | Các mục cải tiến có khóa (keyed) đã triển khai nhưng không có quan sát kết quả chỉ-thêm (append-only outcome observation), cộng với các mục tương thích cũ (legacy) không có khóa mà cột `actual_outcome` bị thiếu. | 2 |
| Các story bị cũ (Stale stories) | Các story chưa được triển khai mà trace liên kết gần nhất đã quá 30 ngày. | 3 |
| Các công cụ bị hỏng (Broken tools) | Các công cụ đã đăng ký nhưng lệnh thực thi của chúng không tìm thấy trên đĩa hoặc trong biến môi trường `PATH`. | 8 |

## Điểm số (Score)

```text
score = orphaned_stories * 10
      + unverified_stories * 5
      + unverified_decisions * 5
      + backlog_without_outcomes * 2
      + stale_stories * 3
      + broken_tools * 8
```

Điểm số tối đa được giới hạn ở mức 100.

| Khoảng điểm | Ý nghĩa giải thích |
| --- | --- |
| 0 | Hoàn hảo: các bản ghi được theo dõi, xác thực và khỏe mạnh. |
| 1-25 | Khỏe mạnh: chỉ còn một vài công việc dọn dẹp nhỏ. |
| 26-50 | Cần chú ý: sự sai lệch (drift) đang tích tụ dần. |
| 51-100 | Yêu cầu hành động: trạng thái cũ làm giảm giá trị của Harness. |

Các phát hiện kiểm toán (audit findings) làm đầu vào cho lệnh `scripts/bin/harness-cli propose`, lệnh này có thể chuyển đổi các sai lệch lặp đi lặp lại thành các mục backlog đề xuất.

Bằng chứng triển khai (implementation proof) và tác động đo được (measured impact) được cố tình tách biệt. Đối với các mục cải tiến có khóa (keyed improvement occurrences), bất kỳ bản ghi nào trong `backlog_outcome_observation` đều thỏa mãn kiểm tra kiểm toán, bao gồm cả bản ghi `legacy_recorded` trung lập được bảo tồn bởi quá trình hòa giải di sản (legacy reconciliation). Cột `actual_outcome` di sản có thể thay đổi (mutable) chỉ được tham vấn cho các hàng tương thích không có khóa (unkeyed compatibility rows).
