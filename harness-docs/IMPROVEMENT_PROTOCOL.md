# Giao thức Cải tiến (Improvement Protocol)

> **Tài liệu tương thích (Compatibility reference) — không thuộc luồng công việc mặc định.** Vòng đời đề xuất tiếp tục được hỗ trợ cho trạng thái tầng điều khiển lịch sử. Công việc cải tiến hiện tại ưu tiên các phát hiện cơ học cụ thể và các thay đổi dọn dẹp có giới hạn được hỗ trợ bởi bằng chứng repository.

Phase 5 bắt đầu vòng lặp tự cải tiến (self-improvement loop):

```text
độ ma sát (friction) + can thiệp (interventions) + phát hiện kiểm toán (audit findings)
  -> harness-cli propose
  -> con người chấp nhận hoặc từ chối một khóa đề xuất ổn định (stable proposal key)
  -> mục backlog đã chấp nhận (accepted backlog occurrence) cộng lịch trình đánh giá kết quả (outcome-review schedule)
  -> triển khai với tác động dự kiến (predicted impact)
  -> đóng với bằng chứng triển khai (implementation proof)
  -> sau đó thêm các quan sát kết quả đo được (measured outcome observations)
```

## Tạo Đề xuất (Generate Proposals)

```bash
scripts/bin/harness-cli propose
```

Lệnh này dựa trên quy tắc. Nó tìm kiếm:

- độ ma sát trace lặp lại,
- các mẫu can thiệp (intervention) lặp lại,
- các danh mục kiểm toán khác không.

Mỗi đề xuất bao gồm khóa phiên bản ổn định (stable versioned key), trạng thái vòng đời (lifecycle state), tiêu đề, thành phần, bằng chứng, tác động dự kiến, rủi ro, hành động đề xuất, kế hoạch xác thực và mức độ tin cậy. Chạy `propose` mà không có cờ quyết định là chỉ đọc (read-only).

Trạng thái vòng đời nhận biết bằng chứng (evidence-aware):

- `new`: chưa có mục nào có khóa tồn tại.
- `pending`: một mục đề xuất đã tồn tại; ID backlog hiện có được hiển thị.
- `accepted`: công việc đang hoạt động đã tồn tại và không thể tạo mục mở thứ hai.
- `suppressed`: một mục đã triển khai hoặc bị từ chối bao phủ tất cả bằng chứng ổn định hiện tại. Các hàng này bị ẩn theo mặc định.
- `regression`: bằng chứng không được bao phủ bởi chuỗi mục (occurrence lineage) xuất hiện sau một mục đã triển khai.
- `reconsideration`: bằng chứng không được bao phủ bởi chuỗi mục xuất hiện sau một mục bị từ chối.

Kiểm tra bằng chứng đã xử lý mà không mở lại:

```bash
scripts/bin/harness-cli propose --show-suppressed
```

Giải thích bao gồm mục kết thúc (terminal occurrence), bộ giải quyết (resolver), bằng chứng đóng (closure proof) và lý do tại sao không còn bằng chứng nào chưa được bao phủ. Các kết quả khớp di sản (legacy) không có khóa được báo cáo là `legacy-unclassified` cho đến khi operator chạy hòa giải rõ ràng (explicit reconciliation).

## Hòa giải Cải tiến Di sản (Reconcile Legacy Improvements)

Xem trước mọi cải tiến lịch sử không có khóa trước khi thay đổi:

```bash
scripts/bin/harness-cli backlog reconcile \
  --action backfill-lifecycle-identity --dry-run
```

Báo cáo gán nhãn mỗi hàng là `derivable`, `manual`, `ambiguous` hoặc `duplicate_candidate`. Chỉ các hàng `derivable` đủ điều kiện áp dụng rõ ràng:

```bash
scripts/bin/harness-cli backlog reconcile \
  --action backfill-lifecycle-identity --apply
```

Lệnh apply chỉ điền danh tính vòng đời (lifecycle identity) còn thiếu, nhúng các ảnh chụp bất biến (immutable snapshots) cho bằng chứng trace/intervention không có UID, và bảo toàn trạng thái kết thúc, dấu thời gian, bằng chứng thô và `actual_outcome`. Kết quả di sản kết thúc không trống (nonblank) được sao chép một lần vào quan sát chỉ-thêm (append-only) trung lập `legacy_recorded`; đó không phải là xác nhận đo lường. Chạy lại apply không có tác dụng (no-op). Các ứng viên manual, ambiguous và duplicate yêu cầu con người lựa chọn và giữ nguyên.

## Quyết định Một Đề xuất (Decide One Proposal)

```bash
scripts/bin/harness-cli propose --accept <proposal-key> --outcome-manual
scripts/bin/harness-cli propose --accept <proposal-key> --outcome-due <RFC3339>
scripts/bin/harness-cli propose --accept <proposal-key> --outcome-after-traces <positive-integer>

# Hoặc giữ lại quyết định kết thúc của con người mà không tạo công việc triển khai.
scripts/bin/harness-cli propose --reject <proposal-key> --reason "Not worth the added complexity"
```

Chấp nhận sẽ tạo hoặc tái sử dụng một mục backlog `accepted` và in lệnh intake `harness_improvement` tiếp theo. Từ chối ghi lại một lý do kết thúc (terminal reason) và bằng chứng đã bao phủ mà không tạo intake, story hoặc lần chạy điều phối (orchestrated run). `propose --commit` bị từ chối có chủ đích; Harness không bao giờ ghi hàng loạt mọi đề xuất đang hiển thị.

Các đề xuất dựa trên kiểm toán yêu cầu các tập kiểm toán ổn định (stable audit episodes) trước bất kỳ quyết định nào. Nếu bản xem trước báo cáo bằng chứng kiểm toán chưa được ghi lại, hãy chạy `scripts/bin/harness-cli audit --record-evidence` và quyết định khóa ổn định mới hiển thị; các quyết định đề xuất không bao giờ tạo bằng chứng kiểm toán như hiệu ứng phụ. Lý do từ chối được lưu trữ và so sánh dưới dạng giá trị chính xác, vì vậy tiền tố hoặc tập cha (superset) không được coi là lần thử lặp lại bất biến (idempotent retry).

Chấp nhận hoặc từ chối một ứng viên `regression` hoặc `reconsideration` sẽ thêm một mục mới với uid mới, cùng khóa đề xuất, mục kết thúc ngay trước đó là `predecessor_uid`, và chỉ bằng chứng ổn định chưa được bao phủ. Mục tiền nhiệm không bao giờ được mở lại hoặc thay đổi. Các ứng viên tái xuất (recurrence candidates) vẫn ở trạng thái chỉ đọc cho đến khi có quyết định rõ ràng của con người.

Con người xem xét công việc đã chấp nhận bằng:

```bash
scripts/bin/harness-cli query backlog --open
```

## Chạy Vòng lặp Sức khỏe Hàng ngày (Run The Daily Health Loop)

Bắt đầu với chế độ xem sức khỏe chỉ đọc:

```bash
scripts/bin/harness-cli audit --record-evidence
scripts/bin/harness-cli query improvement-health
```

Lệnh đầu tiên ghi lại rõ ràng các chuyển đổi bằng chứng kiểm toán. Lệnh thứ hai không ghi gì: nó kết hợp entropy kiểm toán hiện tại, các quyết định đề xuất, công việc đã chấp nhận, lịch trình đánh giá kết quả đã lên lịch, kết quả đo được và ứng viên tái xuất theo thứ tự xác định. Mỗi hàng cho biết hành động operator tiếp theo chính xác.

Ví dụ, một mục đã triển khai với lịch trình đếm trace là 20 và baseline hoàn thành là 100 sẽ ở trạng thái `scheduled_not_due` tại 112 trace có uid với 8 trace còn lại. Tại 120 trace nó trở thành `due`. Nếu số đếm hiện tại là 99, hàng đó là `schedule_error` vì Harness từ chối đoán sau khi số đếm bền vững giảm xuống dưới baseline.

## Hoàn thành Công việc Đã Chấp nhận (Complete Accepted Work)

Sau khi triển khai, story giải quyết tuân theo một trình tự rõ ràng:

```text
story vào trạng thái in_progress hoặc changed
  -> triển khai hoàn thành
  -> trace triển khai hoàn thành phù hợp được ghi lại
  -> story complete chạy xác thực mới
  -> bằng chứng đạt (passing proof) đánh dấu story là implemented
  -> các mục backlog resolver đã chấp nhận đủ điều kiện đóng trong cùng giao dịch
```

```bash
scripts/bin/harness-cli story complete <US-NNN>
```

Thất bại giữ story ở trạng thái đủ điều kiện hoàn thành và không đóng gì. Hoàn thành lặp lại hoặc đồng thời là bất biến (idempotent). Bằng chứng giải quyết ghi lại story, lệnh proof, danh tính hoàn thành và thời gian hoàn thành; nó không tuyên bố kết quả đo được sau đó.

Các liên kết resolver và trace mới mang metadata thứ tự nano giây được phát lại (replayed nanosecond ordering). Hoàn thành chỉ chấp nhận trace đủ điều kiện được ghi lại nghiêm ngặt sau liên kết resolver mới nhất. Các liên kết di sản không có metadata thứ tự sử dụng so sánh dấu thời gian nghiêm ngặt bảo thủ. Phát lại ngữ nghĩa (semantic replay) bảo toàn chính xác các dấu thời gian liên kết, xác thực, hoàn thành và đóng thay vì thay thế bằng thời gian rebuild.

## Ghi nhận Kết quả Đo được (Record Measured Outcomes)

Sau khi triển khai, ghi lại những gì thực sự xảy ra mà không thay đổi bằng chứng hoàn thành hoặc trường `actual_outcome` di sản:

```bash
scripts/bin/harness-cli backlog outcome record --id <local-id> \
  --status confirmed --outcome "Repeated friction fell from 4/5 to 0/5 traces" \
  --evidence "trace uids trc_... through trc_..."
```

Các trạng thái được phép là `confirmed`, `ineffective` và `reverted`. Mỗi lệnh thêm số thứ tự tiếp theo cho mỗi mục (per-occurrence ordinal). Quan sát `reverted` sau trở thành đánh giá hiện tại trong khi hàng `confirmed` trước đó vẫn bất biến. Công việc đã chấp nhận hoặc đề xuất bị từ chối vì bằng chứng triển khai đạt phải tồn tại trước khi có thể tuyên bố tác động đo được. Lịch trình là lời nhắc, vì vậy bằng chứng có thể được ghi lại trước ngày đến hạn hoặc mục tiêu trace.

## Quy tắc Xem xét (Review Rules)

- Đề xuất nhỏ (tiny) có thể được triển khai trực tiếp khi chúng chỉ làm rõ tài liệu.
- Đề xuất bình thường (normal) cần một story packet hoặc sự chấp nhận backlog rõ ràng.
- Đề xuất rủi ro cao (high-risk) cần một bản ghi quyết định bền vững (durable decision record) trước khi thay đổi phân cấp nguồn, hướng kiến trúc, yêu cầu xác thực hoặc chính sách rủi ro.
- Công việc đã chấp nhận có khóa được đóng bởi vòng đời hoàn thành story rõ ràng (explicit story-completion lifecycle), không phải `backlog close`; quan sát kết quả sau này vẫn tách biệt khỏi bằng chứng triển khai.

## Xác thực (Validation)

Sau khi triển khai, so sánh tác động dự kiến với:

- `scripts/bin/harness-cli audit`,
- `scripts/bin/harness-cli query friction`,
- `scripts/bin/harness-cli query interventions`,
- chất lượng trace benchmark và tuân thủ harness khi bằng chứng benchmark áp dụng.
