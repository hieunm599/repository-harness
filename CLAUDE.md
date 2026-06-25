# Quy tắc Dự án (Project Rules)

<!-- HARNESS:BEGIN -->
## Harness

Claude Code tự động tải file này vào mỗi phiên làm việc (session), nhưng nó không tự động tải file `AGENTS.md`. Các dòng bắt đầu bằng `@` dưới đây sẽ import ngữ cảnh harness luôn cần thiết (tập hợp các quy tắc "Bắt buộc trong tất cả các làn/lane" từ file `docs/CONTEXT_RULES.md`) tại thời điểm tải ngữ cảnh. Không bao giờ bọc chúng trong dấu backtick; điều đó sẽ vô hiệu hóa chức năng import.

@AGENTS.md

@docs/FEATURE_INTAKE.md

Ngoài ra, hãy chạy lệnh `scripts/bin/harness-cli query matrix` trước khi bắt đầu làm việc.

Ngữ cảnh phụ thuộc vào làn/lane (`README.md`, `docs/HARNESS.md`, `docs/ARCHITECTURE.md`, `docs/CONTEXT_RULES.md`, tài liệu sản phẩm, story, quyết định kỹ thuật) cố tình không được import tự động — hãy tự đọc chúng theo từng lane, như file `docs/CONTEXT_RULES.md` hướng dẫn.
<!-- HARNESS:END -->
