# Đặc tả Dấu vết thực thi (Trace Specification)

Bảng `trace` ghi lại những gì đã xảy ra trong một nhiệm vụ của Harness. Tài liệu này định nghĩa độ sâu và định dạng kỳ vọng cho từng trường dữ liệu để các trace hữu ích cho việc đánh giá, tính điểm benchmark, quy trách nhiệm lỗi và sự phát triển của harness trong tương lai.

Lược đồ cơ sở dữ liệu (schema) hiện tại nằm trong file `scripts/schema/001-init.sql` dưới bảng `trace`. Sơ đồ này không bị thay đổi bởi Phase 2.

## Tham chiếu các Trường dữ liệu (Field Reference)

| Trường (Field) | Kiểu dữ liệu | Bắt buộc | Định dạng | Ví dụ |
| --- | --- | --- | --- | --- |
| `id` | INTEGER | Tự động | Khóa chính tự động tăng của SQLite. Không được đặt thủ công. | `42` |
| `created_at` | TEXT | Tự động | Sử dụng lệnh `datetime('now')` của SQLite. Không được đặt thủ công. | `2026-05-27 09:24:37` |
| `task_summary` | TEXT | Có | Một câu, dài ít nhất 10 ký tự, nêu rõ kết quả hoặc kết quả dự kiến. | `Completed Phase 2 docs-only observability and taxonomy specification` |
| `intake_id` | INTEGER | Có (từ Tiêu chuẩn trở lên) | Số nguyên ID từ dòng liên quan trong bảng `intake`. | `36` |
| `story_id` | TEXT | Có (từ Tiêu chuẩn trở lên) | Story ID từ bảng `story`. Sử dụng ID story chính khi một trace bao gồm nhiều story; liệt kê các story còn lại trong trường `notes`. | `US-004` |
| `agent` | TEXT | Tùy chọn (Tối giản); Bắt buộc (Tiêu chuẩn trở lên) | Tên viết tắt của agent hoặc công cụ. | `codex` |
| `actions_taken` | TEXT | Tiêu chuẩn trở lên | Văn bản dạng mảng JSON. Với CLI hiện tại, truyền một danh sách phân tách bằng dấu phẩy và CLI sẽ lưu trữ dưới dạng văn bản JSON. | `["read PHASE2.md","drafted TRACE_SPEC.md","updated HARNESS.md"]` |
| `files_read` | TEXT | Tiêu chuẩn trở lên | Văn bản dạng mảng JSON chứa các đường dẫn hoặc tên lệnh. Với CLI hiện tại, truyền một danh sách phân tách bằng dấu phẩy. | `["PHASE2.md","docs/HARNESS.md","scripts/bin/harness-cli query matrix"]` |
| `files_changed` | TEXT | Tiêu chuẩn trở lên | Văn bản dạng mảng JSON chứa các đường dẫn file thay đổi. Với CLI hiện tại, truyền một danh sách phân tách bằng dấu phẩy; chỉ bỏ qua khi không có file nào thay đổi. | `["docs/TRACE_SPEC.md","docs/HARNESS.md"]` |
| `decisions_made` | TEXT | Chi tiết | Văn bản dạng mảng JSON chứa các chuỗi quyết định. Bao gồm các quyết định về phạm vi (scope decisions), lựa chọn xác thực và các phi mục tiêu (non-goals) rõ ràng. | `["Kept Phase 2 docs-only; installer propagation remains out of scope"]` |
| `errors` | TEXT | Tiêu chuẩn trở lên (khi lỗi xảy ra); Chi tiết (luôn bắt buộc) | Văn bản dạng mảng JSON chứa các chuỗi lỗi hoặc điểm nghẽn (blocker). Cho đến khi CLI hỗ trợ mảng trống trực tiếp, hãy sử dụng chuỗi `none` khi một trace chi tiết cần chỉ ra rõ không có lỗi. | `["git diff --check failed before whitespace fix"]` |
| `outcome` | TEXT | Có | Một trong các giá trị: `completed` (hoàn thành), `blocked` (bị chặn), `partial` (một phần) hoặc `failed` (thất bại). | `completed` |
| `duration_seconds` | INTEGER | Chi tiết khi có sẵn | Số nguyên dương ước lượng hoặc thời gian đo được. Để trống nếu không xác định. | `1800` |
| `token_estimate` | INTEGER | Chi tiết khi có sẵn | Số nguyên dương ước lượng token. Để trống nếu không xác định. | `24000` |
| `harness_friction` | TEXT | Tiêu chuẩn trở lên (khi có ma sát); Chi tiết (luôn bắt buộc) | Văn bản tự do nêu rõ những gì đã gây khó khăn, còn thiếu, mơ hồ hoặc lặp đi lặp lại. Chỉ sử dụng chuỗi `none` khi agent đã chủ động kiểm tra và không phát hiện thấy ma sát nào. | `New Phase 2 docs are not in installer copy list; recorded as out-of-scope follow-up.` |
| `notes` | TEXT | Tùy chọn | Văn bản tự do cung cấp ngữ cảnh đánh giá không phù hợp với các trường dữ liệu khác. | `Trace covers US-003, US-004, US-005, and US-006.` |

## Các Cấp độ Chất lượng (Quality Tiers)

### Tối giản (Minimal) (điểm: 1)

Các trường dữ liệu tối thiểu:

- `task_summary` được điền và dài ít nhất 10 ký tự.
- `outcome` được điền trước phản hồi cuối cùng.

Chấp nhận cho:

- Các tác vụ thuộc làn rủi ro nhỏ (tiny-lane) không thay đổi file hoặc chỉ chỉnh sửa văn bản/tài liệu rủi ro thấp.

Không chấp nhận cho:

- Công việc có mức độ rủi ro bình thường hoặc cao.
- Bất kỳ công việc nào phát hiện thấy ma sát, lỗi hoặc thiếu đường dẫn xác thực.

### Tiêu chuẩn (Standard) (điểm: 2)

Các trường dữ liệu tối thiểu:

- Tất cả các trường của cấp độ Tối giản.
- `intake_id` khi một intake được ghi lại.
- `story_id` khi công việc tương thích trực tiếp với một story.
- `agent`.
- `actions_taken` dưới dạng văn bản mảng JSON.
- `files_read` dưới dạng văn bản mảng JSON.
- `files_changed` dưới dạng văn bản mảng JSON.
- Ít nhất một trong hai trường `errors` hoặc `harness_friction`.

Yêu cầu cho:

- Các tác vụ thuộc làn rủi ro bình thường (normal-lane).
- Các tác vụ nhỏ (tiny tasks) làm thay đổi các hướng dẫn Harness, kỳ vọng xác thực hoặc các bản ghi lâu dài.

Các trace tiêu chuẩn có thể để trống các trường `duration_seconds`, `token_estimate` và `decisions_made` khi các chi tiết đó không hữu ích.

### Chi tiết (Detailed) (điểm: 3)

Các trường dữ liệu tối thiểu:

- Tất cả các trường của cấp độ Tiêu chuẩn.
- `decisions_made` dưới dạng văn bản mảng JSON.
- `errors` dưới dạng văn bản mảng JSON, sử dụng chuỗi `none` với CLI hiện tại khi không có lỗi xảy ra.
- `harness_friction`, chỉ sử dụng chuỗi `none` sau khi đã kiểm tra kỹ ma sát.
- `duration_seconds` hoặc một ghi chú giải thích tại sao không đo được thời gian.
- `token_estimate` hoặc một ghi chú giải thích tại sao không ước lượng được token.
- `notes` khi một trace bao gồm nhiều story, nhiều cờ rủi ro hoặc bỏ qua xác thực.

Yêu cầu cho:

- Các tác vụ rủi ro cao (high-risk).
- Các thay đổi chạm đến hướng đi kiến trúc, phân cấp nguồn sự thật, yêu cầu xác thực, xác thực (auth), phân quyền (authorization), mất mát dữ liệu, kiểm toán/bảo mật hoặc hành vi của nhà cung cấp bên ngoài.
- Công việc chạy benchmark hoặc phát hành (release) cần lưu trữ bằng chứng chính xác cho các đánh giá sau này.

Đối với công việc rủi ro cao, trường `decisions_made` trong trace tóm tắt những gì đã được quyết định. Nó không thay thế cho bản ghi quyết định kỹ thuật lâu dài. Nếu công việc thay đổi hành vi, kiến trúc, phân quyền, quyền sở hữu dữ liệu, cấu trúc API hoặc các yêu cầu xác thực, hãy thêm một file `docs/decisions/NNNN-*.md` và ghi lại nó bằng lệnh `scripts/bin/harness-cli decision add`.

## Áh xạ Làn rủi ro (Lane Mapping)

| Làn rủi ro (Lane) | Cấp độ kỳ vọng (Expected Tier) | Hành vi Trace Tối thiểu |
| --- | --- | --- |
| Nhỏ (Tiny) | Tối giản | Ghi lại tóm tắt và kết quả; sử dụng cấp Tiêu chuẩn nếu có ma sát hoặc thay đổi tài liệu Harness. |
| Bình thường (Normal) | Tiêu chuẩn | Ghi lại intake, hành động, các file đã đọc, các file đã thay đổi, kết quả và ma sát/lỗi. |
| Rủi ro cao (High-risk) | Chi tiết | Ghi lại tất cả các trường hoặc giải thích rõ ràng tại sao không ước lượng được thời gian/token. |

## Giao thức Ghi nhận Ma sát (Friction Capture Protocol)

Điền vào trường `harness_friction` khi xảy ra bất kỳ điều nào sau đây:

- Agent phải tự suy luận một quy tắc còn thiếu hoặc nguồn sự thật bị thiếu.
- Việc xác thực yêu cầu chưa rõ ràng, không có sẵn hoặc quá tốn kém để thực thi.
- Một tài liệu, bản ghi lâu dài hoặc gói story packet đã cũ hoặc mâu thuẫn.
- Nhiệm vụ làm lộ ra một bước thủ công lặp đi lặp lại đáng lẽ phải trở thành một template, lệnh hoặc danh sách kiểm tra.
- Một thay đổi được yêu cầu nằm ngoài phạm vi nhưng có khả năng sẽ quan trọng sau này.
- Một lỗi benchmark hoặc lỗi đánh giá không thể quy cho một thành phần cụ thể.

Cách viết ma sát:

- Nêu rõ khó khăn cụ thể, không viết cảm xúc mơ hồ.
- Bao gồm capability còn thiếu hoặc điểm mâu thuẫn.
- Nếu ma sát nên được đưa vào kế hoạch thực hiện, hãy thêm hoặc cập nhật một mục backlog bằng lệnh `scripts/bin/harness-cli backlog add`.
- Nếu không có ma sát, chỉ sử dụng chuỗi `none` cho các trace Chi tiết.

Ví dụ viết ma sát tốt:

```text
New Phase 2 docs are not copied by scripts/install-harness.sh, but installer propagation is out of scope for docs-only Phase 2.
```

Ví dụ viết ma sát kém:

```text
docs confusing
```

## Các Ví dụ (Examples)

### Trace tốt (Chi tiết)

```bash
scripts/bin/harness-cli trace \
  --summary "Completed high-risk auth role migration with audit proof" \
  --intake 51 \
  --story US-014 \
  --agent codex \
  --outcome completed \
  --duration 4200 \
  --tokens 52000 \
  --actions "read access-control docs,created migration,updated audit tests,ran integration suite" \
  --read "docs/product/permissions.md,docs/decisions/0008-auth-boundary.md,src/auth/roles.ts" \
  --changed "src/auth/roles.ts,src/audit/events.ts,tests/auth-roles.test.ts" \
  --decisions "kept manager role scoped to workspace,recorded audit event on every role change" \
  --errors "none" \
  --friction "Existing permission docs did not define delegated admin; added backlog item for role glossary." \
  --notes "Detailed trace required because the task touched authorization and audit behavior."
```

### Trace đầy đủ (Tiêu chuẩn)

```bash
scripts/bin/harness-cli trace \
  --summary "Added Phase 2 trace specification and Harness reference" \
  --intake 36 \
  --story US-004 \
  --agent codex \
  --outcome completed \
  --actions "read PHASE2.md,drafted TRACE_SPEC.md,updated HARNESS.md,ran rg checks" \
  --read "PHASE2.md,docs/HARNESS.md,scripts/schema/001-init.sql" \
  --changed "docs/TRACE_SPEC.md,docs/HARNESS.md" \
  --friction "none"
```

### Trace thiếu thông tin (Insufficient Trace)

```bash
scripts/bin/harness-cli trace \
  --summary "did phase 2" \
  --outcome completed
```

Lý do tại sao trace này không đầy đủ đối với công việc Phase 2 thuộc làn bình thường:

- Nó không xác định được các hành động đã thực hiện.
- Nó không liệt kê các file đã đọc hoặc đã thay đổi.
- Nó không kết nối với intake hoặc các story.
- Nó không cung cấp tín hiệu về ma sát hoặc lỗi.

## Danh sách Kiểm tra (Review Checklist)

Trước phản hồi cuối cùng, hãy kiểm tra:

- Cấp độ trace khớp với làn rủi ro của tác vụ.
- Đọc lại điểm số được in tự động bởi lệnh `scripts/bin/harness-cli trace`. Sử dụng lệnh `scripts/bin/harness-cli score-trace --id N` khi kiểm tra lại một trace lịch sử cụ thể.
- Trường `files_changed` khớp với tập hợp các file thực tế đã thay đổi ở mức độ hữu ích.
- Trường `errors` chỉ ra các điểm nghẽn thực sự hoặc là `none` đối với các trace Chi tiết khi sử dụng CLI hiện tại.
- Trường `harness_friction` chỉ ra một vấn đề cụ thể hoặc được cố ý đặt là `none`.
- Bất kỳ ma sát nào đáng lẽ trở thành công việc tương lai đều được ghi lại trong backlog.
