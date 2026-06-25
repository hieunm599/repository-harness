# Các Quyết định Kỹ thuật (Decisions)

Các bản ghi quyết định kỹ thuật giải thích lý do tại sao các lựa chọn quan trọng về sản phẩm, kiến trúc hoặc harness được đưa ra.

Sử dụng mẫu `docs/templates/decision.md` khi thêm một quyết định kỹ thuật mới.

Sau khi thêm hoặc cập nhật một file quyết định kỹ thuật định dạng markdown, hãy thêm hoặc làm mới dòng bản ghi quyết định kỹ thuật lâu dài trong cơ sở dữ liệu:

```bash
scripts/bin/harness-cli decision add \
  --id 0008-auth-boundary \
  --title "Auth Boundary" \
  --doc docs/decisions/0008-auth-boundary.md
```

Các trường trong trace như `--decisions` chỉ tóm tắt các lựa chọn ở cấp độ nhiệm vụ. Chúng không được tính là nhật ký quyết định kỹ thuật của Harness.

Thêm một quyết định kỹ thuật khi:

- Một lựa chọn kỹ thuật cố định bị thay đổi.
- Một quy tắc sản phẩm thay đổi một cách có ý nghĩa.
- Một yêu cầu xác thực được thêm vào, loại bỏ hoặc bị làm yếu đi.
- Một tính năng rủi ro cao lựa chọn thiết kế này thay vì thiết kế khác.
- Xác thực (auth), phân quyền (authorization), quyền sở hữu dữ liệu, kiểm toán/bảo mật hoặc hành vi API thay đổi.
- Phân cấp nguồn sự thật thay đổi.
