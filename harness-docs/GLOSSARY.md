# Thuật ngữ chuyên ngành (Glossary)

## Agent

Một AI coding collaborator (cộng tác viên lập trình trí tuệ nhân tạo) hoạt động bên trong kho lưu trữ mã nguồn (repository).

## Harness

Hệ thống vận hành cấp độ repo hướng dẫn con người và các agent cách chuyển đổi ý tưởng thành các thay đổi sản phẩm an toàn.

## Đặc tả sản phẩm (Product Contract)

Hành vi kỳ vọng hiện tại của sản phẩm. Các tài liệu sản phẩm cùng với các bài kiểm thử có thể thực thi (executable tests) sẽ trở thành contract sống ngay khi quá trình triển khai tồn tại.

## Gói story packet (Story Packet)

Một file hoặc thư mục công việc có kích thước phù hợp với một story mô tả contract sản phẩm, các tài liệu bị ảnh hưởng, ghi chú thiết kế và kỳ vọng xác thực (validation expectations) cho một tính năng.

## Tiếp nhận tính năng (Feature Intake)

Bước phân loại giúp chuyển đổi một prompt thành các phần việc nhỏ (tiny), bình thường (normal) hoặc rủi ro cao (high-risk) trước khi bắt đầu triển khai thực tế.

## Phân loại thành phần (Component Taxonomy)

Bản đồ liên kết từ các file Harness và các capability đến trách nhiệm mà chúng đảm nhận, được sử dụng để đánh giá độ bao phủ, quy trách nhiệm lỗi và xác định các capability harness còn thiếu.

## Mức độ trưởng thành / Độ hoàn thiện (Maturity Level)

Một giai đoạn có thể xác thực trong capability của Harness, từ H0 (môi trường thô sơ) đến H5 (harness tự cải tiến). Mỗi mức độ đều có các file bắt buộc, tiêu chí và chỉ số benchmark tương ứng.

## Cấp độ chất lượng trace (Trace Quality Tier)

Độ sâu kỳ vọng của một trace nhiệm vụ: tối giản (minimal) cho công việc nhỏ, tiêu chuẩn (standard) cho công việc bình thường và chi tiết (detailed) cho công việc rủi ro cao.

## Chốt chặn xác thực (Verification Gate)

Một kiểm tra Harness mang tính khuyến nghị nhằm chạy hoặc kiểm tra bằng chứng cơ học trước khi một nhiệm vụ được đóng lại. Trong Phase 4, lệnh `story verify <id>` chạy lệnh `verify_command` của một story, lệnh `story verify-all` chạy tất cả các lệnh chứng thực story được cấu hình và lệnh `trace --story <id>` sẽ đưa ra cảnh báo khi việc xác thực của story đó chưa vượt qua.

## Hệ thống Đăng ký Công cụ (Tool Registry)

Danh mục công cụ được biên dịch và đăng ký, hiển thị thông qua lệnh `scripts/bin/harness-cli query tools`. Nó giúp các agent khám phá các lệnh có sẵn, đối số, trách nhiệm và các công cụ tùy biến của dự án.

## Sự can thiệp (Intervention)

Một bản ghi lâu dài về phản hồi từ con người, người đánh giá (reviewer), hệ thống CI hoặc agent nhằm sửa đổi, ghi đè, báo cáo khẩn cấp hoặc phê duyệt công việc. Các intervention được lưu trữ riêng biệt với các trace và làm đầu vào cho các đề xuất cải tiến.

## Điểm ngữ cảnh (Context Score)

Kết quả khuyến nghị từ lệnh `scripts/bin/harness-cli score-context <trace-id>`. Nó so sánh danh sách `files_read` được ghi lại của một trace với các quy tắc ngữ cảnh và bộ kích hoạt truy xuất đã được biên dịch.

## Điểm Entropy (Entropy Score)

Điểm số sai lệch (drift score) được in ra bởi lệnh `scripts/bin/harness-cli audit`. Điểm số càng thấp càng tốt. Nó đếm số lượng các bản ghi lâu dài cũ hoặc chưa hoàn thiện như các story bị mồ côi (orphaned stories), các lệnh kiểm chứng chưa được xác thực, các kết quả backlog bị thiếu và các công cụ đăng ký bị lỗi.

## Đề xuất cải tiến (Improvement Proposal)

Một khuyến nghị có cấu trúc được tạo ra bởi lệnh `scripts/bin/harness-cli propose` từ các độ ma sát (friction) lặp đi lặp lại, các mẫu intervention và phát hiện kiểm toán. Các đề xuất này mang tính chất tham khảo trừ khi được đưa vào backlog bằng cờ `--commit`.

## Giai đoạn ngữ cảnh (Context Phase)

Một giai đoạn của nhiệm vụ agent làm thay đổi ngữ cảnh cần đọc, chẳng hạn như giai đoạn tiếp nhận (intake), lên kế hoạch (planning), triển khai (implementation), xác thực (validation) hoặc ghi lại dấu vết (trace recording).

## Bộ kích hoạt truy xuất (Retrieval Trigger)

Một điều kiện hướng dẫn agent truy xuất thêm ngữ cảnh, chẳng hạn như khi chạm đến một database schema, thay đổi một contract công khai hoặc phát hiện thiếu xác thực.

## Thay đổi Harness (Harness Delta)

Một bản cập nhật tài liệu, template, xác thực, backlog hoặc quyết định kỹ thuật giúp công việc của các agent trong tương lai an toàn hoặc dễ dàng hơn.

## Vòng lặp kết quả backlog (Backlog Outcome Loop)

Quy trình phản hồi cho các cải tiến Harness: ghi lại tác động dự kiến khi một mục backlog được tạo, sau đó ghi lại kết quả thực tế đo được khi mục đó được đóng lại để các agent tương lai có thể so sánh giữa kỳ vọng và kết quả thực tế.

## Lớp lưu trữ bền vững (Durable Layer)

Cơ sở dữ liệu SQLite và CLI (`scripts/bin/harness-cli`) lưu trữ các bản ghi vận hành (intake, story, quyết định kỹ thuật, backlog, trace) dưới dạng dữ liệu có cấu trúc và có thể truy vấn được. Các tài liệu chính sách mô tả cách làm việc; còn lớp lưu trữ bền vững ghi lại những gì đã thực sự xảy ra.

## Thay đổi Sản phẩm (Product Delta)

Một thay đổi hướng về sản phẩm như code, kiểm thử, cấu trúc API, mô hình dữ liệu hoặc tài liệu sản phẩm.

## Trace (Dấu vết thực thi)

Một bản ghi có cấu trúc về những gì agent đã làm trong một nhiệm vụ: các hành động đã thực hiện, các file đã đọc, các file đã thay đổi, các quyết định đã đưa ra, các lỗi gặp phải, kết quả và bất kỳ độ ma sát harness nào được phát hiện.
