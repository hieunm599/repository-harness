# US-XXX Tiêu đề Story

## Trạng thái (Status)

planned (lên kế hoạch)

## Làn rủi ro (Lane)

tiny | normal | high-risk

## Đặc tả sản phẩm (Product Contract)

Mô tả hành vi mà story này phải làm cho đúng/trở thành sự thật.

## Tài liệu Sản phẩm liên quan (Relevant Product Docs)

- `harness-docs/product/...`

## Tiêu chí Nghiệm thu (Acceptance Criteria)

- Tiêu chí 1.
- Tiêu chí 2.
- Tiêu chí 3.

## Ghi chú Thiết kế (Design Notes)

- Commands (Lệnh thay đổi trạng thái):
- Queries (Lệnh truy vấn đọc trạng thái):
- API (Giao diện API):
- Tables (Các bảng cơ sở dữ liệu):
- Domain rules (Quy tắc miền):
- UI surfaces (Bề mặt giao diện người dùng):

## Xác thực (Validation)

Khi cập nhật trạng thái chứng thực lâu dài, hãy sử dụng các giá trị boolean dạng số:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 0 --platform 0`.

| Phân lớp (Layer) | Bằng chứng xác thực kỳ vọng (Expected proof) |
| --- | --- |
| Unit | |
| Integration | |
| E2E | |
| Platform | |
| Release | |

## Thay đổi Harness (Harness Delta)

Ghi nhận bất kỳ bản cập nhật harness nào đã thực hiện hoặc đề xuất do story này mang lại.

## Bằng chứng (Evidence)

Thêm các lệnh chạy, báo cáo, ảnh chụp màn hình hoặc các liên kết sau khi đã có bằng chứng xác thực.
