# Nấc thang Độ hoàn thiện Harness (Harness Maturity Ladder)

Nấc thang này định nghĩa cách `repository-harness` nên phát triển từ các hướng dẫn agent tĩnh sang các cải tiến harness có thể đo lường được.

Các cấp độ này được thiết kế để có thể xác thực một cách có chủ ý. Một cấp độ chỉ được coi là đạt được khi các tiêu chí của nó có thể được kiểm tra trong các file kho lưu trữ, các bản ghi Harness lâu dài hoặc kết quả đầu ra benchmark.

## Các Cấp độ (Levels)

### H0 - Môi trường Thô sơ (Bare Environment)

Model hoạt động mà không có bất kỳ harness kho lưu trữ nào. Nó nhận được prompt và có thể tạo ra một bản vá (patch), nhưng repo không hướng dẫn nó cách phân loại, xác thực hoặc ghi lại công việc.

Tiêu chí (Criteria):

- Không tồn tại khối Harness `AGENTS.md`.
- Không tồn tại chính sách tiếp nhận tính năng (feature intake policy).
- Không tồn tại artifact story, quyết định kỹ thuật (decision), xác thực (validation) hoặc trace.

Các file bắt buộc:

- Không có.

Các chỉ số benchmark (Benchmark indicators):

- Điểm chức năng (Functional score) là số liệu có ý nghĩa duy nhất.
- Độ tuân thủ Harness: 0%.
- Chất lượng trace: 0/3.

Trạng thái hiện tại:

- Đã vượt qua. Kho lưu trữ này đã vượt qua H0.

Các trách nhiệm được kích hoạt:

- Không có.

### H1 - Khung sườn và Chính sách (Scaffolding And Policy)

Kho lưu trữ chứa các hướng dẫn vận hành tĩnh, các template, các làn rủi ro và các quy tắc nguồn sự thật. Các agent có thể làm theo một luồng công việc được tài liệu hóa, nhưng trạng thái bền vững vẫn có thể là thủ công hoặc chưa đầy đủ.

Tiêu chí (Criteria):

- File `AGENTS.md` trỏ agent đến tài liệu vận hành Harness.
- Các file `docs/HARNESS.md`, `docs/FEATURE_INTAKE.md` và `docs/ARCHITECTURE.md` tồn tại.
- Các template cho story, quyết định kỹ thuật và xác thực tồn tại trong thư mục `docs/templates/`.
- File `docs/TEST_MATRIX.md` định nghĩa các cột bằng chứng và ý nghĩa trạng thái.

Các file bắt buộc:

- `AGENTS.md`
- `docs/HARNESS.md`
- `docs/FEATURE_INTAKE.md`
- `docs/ARCHITECTURE.md`
- `docs/TEST_MATRIX.md`
- `docs/templates/story.md`
- `docs/templates/decision.md`
- `docs/templates/validation-report.md`

Các chỉ số benchmark:

- Độ tuân thủ Harness: 20-40%.
- Độ chính xác của làn rủi ro (lane accuracy) được cải thiện khi agent đọc chính sách tiếp nhận (intake policy).
- Chất lượng trace vẫn ở mức thấp trừ khi các trace được yêu cầu riêng biệt.

Trạng thái hiện tại:

- Đạt được. Các file H1 đã tồn tại và được sử dụng bởi các hướng dẫn Harness hiện tại.

Các trách nhiệm được kích hoạt:

- Đặc tả nhiệm vụ (Task specification).
- Quyền hạn (Permissions).
- Bộ nhớ dự án (Project memory).
- Xác thực (Verification).

### H2 - Trạng thái Bền vững và Khả năng Quan sát (Durable State And Observability)

Kho lưu trữ có các bản ghi vận hành có cấu trúc và các quy tắc quan sát rõ ràng. Các agent có thể ghi lại những gì đã xảy ra, kết nối công việc với các story và ghi lại trace với độ sâu có thể dự đoán trước.

Tiêu chí (Criteria):

- `scripts/bin/harness-cli` có thể ghi lại dữ liệu tiếp nhận (intake), story, quyết định kỹ thuật (decision), backlog và trace vào cơ sở dữ liệu `harness.db`.
- File `scripts/schema/001-init.sql` định nghĩa các bảng bền vững cho tiếp nhận, story, quyết định kỹ thuật, backlog và trace.
- File `docs/HARNESS_COMPONENTS.md` ánh xạ các file và trách nhiệm.
- File `docs/HARNESS_MATURITY.md` định nghĩa H0-H5 với các tiêu chí có thể đo lường được.
- File `docs/TRACE_SPEC.md` định nghĩa các trường của trace, các cấp chất lượng (quality tiers) và việc ghi nhận ma sát.
- File `docs/CONTEXT_RULES.md` định nghĩa các quy tắc ngữ cảnh theo giai đoạn và làn rủi ro.
- `AGENTS.md` và `docs/HARNESS.md` tham chiếu đến các tài liệu vận hành Phase 2.

Các file bắt buộc:

- `scripts/bin/harness-cli`
- `scripts/schema/001-init.sql`
- `docs/HARNESS_COMPONENTS.md`
- `docs/HARNESS_MATURITY.md`
- `docs/TRACE_SPEC.md`
- `docs/CONTEXT_RULES.md`

Các chỉ số benchmark:

- Độ tuân thủ Harness: 75-90%.
- Chất lượng trace: ít nhất đạt 2.0/3 đối với các tác vụ thuộc làn rủi ro bình thường (normal-lane).
- Độ chính xác làn rủi ro: 6/6 trên bộ suite benchmark hiện tại.
- Ghi nhận ma sát: ít nhất 4/6 tác vụ benchmark khi có ma sát xảy ra.

Trạng thái hiện tại:

- Đạt được. Trạng thái bền vững đã tồn tại, các tài liệu Phase 2 định nghĩa đặc tả khả năng quan sát và ngữ cảnh. Việc chấm điểm chủ động Phase 3 được xây dựng dựa trên lớp này.

Các trách nhiệm được kích hoạt:

- Trạng thái nhiệm vụ (Task state).
- Khả năng quan sát (Observability).
- Quy trách nhiệm lỗi (Failure attribution).
- Lựa chọn ngữ cảnh (Context selection).
- Kiểm toán entropy (Entropy auditing).

### H3 - Khả năng Quan sát Chủ động và Tiến hóa (Active Observability And Evolution)

Harness có thể tự đánh giá dữ liệu vận hành của riêng mình và biến các lỗi lặp đi lặp lại thành các cải tiến được ưu tiên.

Tiêu chí (Criteria):

- Chất lượng trace có thể được chấm điểm bằng một lệnh lặp lại hoặc một bước benchmark.
- Ma sát harness có thể được nhóm theo thành phần từ file `docs/HARNESS_COMPONENTS.md`.
- Các mục backlog bao gồm tác động dự kiến và kết quả thực tế sau khi hoàn thành.
- Kết quả so sánh benchmark xác định trách nhiệm harness nào đã thay đổi hoặc bị thoái lui (regressed).

Các file bắt buộc:

- Các file H2.
- Giao thức benchmark hoặc báo cáo tham chiếu đến các cấp độ hoàn thiện.
- Phương pháp chấm điểm chất lượng trace được tài liệu hóa.
- Vòng lặp đánh giá từ ma sát sang backlog được tài liệu hóa.

Các chỉ số benchmark:

- Độ tuân thủ Harness: 85-95%.
- Chất lượng trace: 2.3-2.7/3.
- Thu thập và phân loại ma sát theo thành phần cho hầu hết các nhiệm vụ thất bại hoặc gặp khó khăn.
- Các thoái lui (regressions) bao gồm việc quy trách nhiệm cho một thành phần harness cụ thể.

Trạng thái hiện tại:

- Đạt được một phần bởi Phase 3. Lệnh `scripts/bin/harness-cli score-trace` chấm điểm chất lượng trace theo các quy tắc cấp độ, `query friction` bao gồm ngữ cảnh tiếp nhận liên kết, lệnh `trace` in ra điểm số đó tại thời điểm ghi ghi nhận trace, và vòng lặp kết quả backlog ghi lại tác động dự kiến so với kết quả thực tế. H3 đầy đủ vẫn yêu cầu đầu ra so sánh benchmark quy trách nhiệm cho các phần bị thay đổi hoặc thoái lui.

Các trách nhiệm được kích hoạt:

- Khả năng quan sát.
- Quy trách nhiệm lỗi.
- Kiểm toán entropy.
- Ghi nhận sự can thiệp (Intervention recording).

### H4 - Xác thực Tự động (Automated Verification)

Harness có thể chạy hoặc điều phối các kiểm tra chứng thực (proof checks) một cách nhất quán và có thể từ chối hoặc gắn cờ công việc chưa hoàn thành trước khi đưa ra phản hồi cuối cùng.

Tiêu chí (Criteria):

- Một lệnh xác thực hoặc giao thức được tài liệu hóa chạy các kiểm tra kỳ vọng cho một story và làn rủi ro đã chọn.
- Các story có thể lưu trữ và thực thi một lệnh `verify_command`.
- Việc ghi trace đưa ra cảnh báo khi một story liên kết có lệnh xác thực chưa từng vượt qua.
- Các bằng chứng xác thực bị thiếu được phát hiện trước khi một nhiệm vụ được đánh dấu là đã triển khai.

Các file bắt buộc:

- Các file H3.
- Giao thức xác thực hoặc tài liệu tham chiếu lệnh.
- Các ví dụ báo cáo xác thực gắn liền với các cột bằng chứng của story.
- Tài liệu hướng dẫn lệnh xác thực story.

Các chỉ số benchmark:

- Điểm chức năng vẫn ổn định.
- Độ tuân thủ Harness: ít nhất đạt 90%.
- Giảm số lượng tuyên bố hoàn thành giả (false "done" claims) trong đánh giá benchmark.
- Thiếu bằng chứng được phát hiện trước khi merge hoặc trước phản hồi cuối cùng.

Trạng thái hiện tại:

- Đạt được bởi Phase 5. Lệnh `scripts/bin/harness-cli story verify <id>` chạy lệnh xác thực cấp độ story, ghi nhận trạng thái thành công/thất bại, cờ `trace --story` cảnh báo trước khi đóng trace khi việc xác thực chưa đạt, và lệnh `scripts/bin/harness-cli story verify-all` chạy tất cả các lệnh xác thực story đã cấu hình trong một lượt. Tự động hóa cột bằng chứng (proof-column automation) vẫn là một cải tiến trong tương lai, nhưng chốt chặn xác thực tự động yêu cầu bởi H4 hiện đã hiện diện.

Các trách nhiệm được kích hoạt:

- Xác thực (Verification).
- Trạng thái nhiệm vụ.
- Quyền hạn (Permissions).
- Ghi nhận sự can thiệp.

### H5 - Harness Tự cải tiến (Self-Improving Harness)

Harness có thể sử dụng các trace, kết quả benchmark và kết quả backlog để đề xuất hoặc áp dụng các cải tiến an toàn cho chính nó.

Tiêu chí (Criteria):

- Các mẫu ma sát lặp đi lặp lại được tóm tắt thành các đề xuất thay đổi harness.
- Các thay đổi đề xuất bao gồm tác động dự kiến, mức độ rủi ro, kế hoạch xác thực và tiêu chí khôi phục (rollback criteria).
- Các thay đổi đã hoàn thành so sánh tác động dự kiến với kết quả benchmark thực tế hoặc kết quả trace thực tế.
- Các thay đổi harness rủi ro cao phải tạm dừng để con người xác nhận trước khi thay đổi phân cấp nguồn, hướng đi kiến trúc hoặc các yêu cầu xác thực.

Các file bắt buộc:

- Các file H4.
- Giao thức tự cải tiến (Self-improvement protocol).
- Các báo cáo cải tiến lịch sử.
- Các đánh giá kết quả backlog.

Các chỉ số benchmark:

- Độ tuân thủ Harness duy trì ở mức ít nhất 90% qua các lượt chạy benchmark lặp đi lặp lại.
- Chất lượng trace duy trì ở mức ít nhất 2.5/3.
- Các cải tiến chỉ ra các thay đổi tích cực có thể đo lường được hoặc được khôi phục một cách rõ ràng.
- Việc phình to phạm vi (scope creep) và làm yếu đi các yêu cầu xác thực bị chốt chặn chính sách bắt giữ.

Trạng thái hiện tại:

- Đạt được một phần bởi Phase 5. Lệnh `scripts/bin/harness-cli audit` phát hiện sai lệch trạng thái bền vững, lệnh `scripts/bin/harness-cli propose` tạo ra các đề xuất cải tiến có cấu trúc từ ma sát, các can thiệp và kết quả kiểm toán, và file `docs/IMPROVEMENT_PROTOCOL.md` định nghĩa vòng lặp đánh giá. H5 chưa đạt được hoàn toàn cho đến khi kết quả benchmark lặp đi lặp lại chứng minh rằng các đề xuất cải tiến tạo ra các thay đổi tích cực có thể đo lường được hoặc được khôi phục một cách rõ ràng.

Các trách nhiệm được kích hoạt:

- Kiểm toán entropy.
- Quy trách nhiệm lỗi.
- Ghi nhận sự can thiệp.
- Quyền hạn.

## Đánh giá Hiện tại (Current Assessment)

| Cấp độ | Trạng thái | Bằng chứng |
| --- | --- | --- |
| H0 | Đã vượt qua | Tài liệu Harness, các template và các bản ghi lâu dài đã tồn tại. |
| H1 | Đạt được | `AGENTS.md`, `docs/HARNESS.md`, `docs/FEATURE_INTAKE.md`, `docs/ARCHITECTURE.md`, `docs/templates/*` và `docs/TEST_MATRIX.md` đã tồn tại. |
| H2 | Đạt được | `scripts/bin/harness-cli`, `scripts/schema/001-init.sql`, các bản ghi story lâu dài, `docs/HARNESS_COMPONENTS.md`, `docs/HARNESS_MATURITY.md`, `docs/TRACE_SPEC.md` và `docs/CONTEXT_RULES.md` định nghĩa bề mặt Phase 2. |
| H3 | Một phần | Phase 3 bổ sung lệnh `scripts/bin/harness-cli score-trace`, làm phong phú ngữ cảnh ma sát và vòng lặp kết quả backlog; Phase 4 tự động chấm điểm các trace khi ghi nhận. Việc quy trách nhiệm thoái lui benchmark ở cấp độ thành phần vẫn còn bỏ ngỏ. |
| H4 | Đạt được | Phase 4 bổ sung `verify_command` ở cấp độ story, `story verify` và các cảnh báo xác thực tại thời điểm ghi trace. Phase 5 bổ sung lệnh `story verify-all` cho kiểm chứng story hàng loạt. |
| H5 | Một phần | Phase 5 bổ sung `audit`, `score-context`, `intervention add/query`, `propose`, `docs/HARNESS_AUDIT.md` và `docs/IMPROVEMENT_PROTOCOL.md`; việc chứng thực kết quả benchmark lặp đi lặp lại vẫn còn bỏ ngỏ. |

## Kích hoạt Trách nhiệm (Responsibility Activation)

| Trách nhiệm | H0 | H1 | H2 | H3 | H4 | H5 |
| --- | --- | --- | --- | --- | --- | --- |
| Đặc tả nhiệm vụ | Còn thiếu | Đã bao phủ | Đã bao phủ | Đã bao phủ | Đã bao phủ | Đã bao phủ |
| Lựa chọn ngữ cảnh | Còn thiếu | Một phần | Đã bao phủ | Đã bao phủ | Đã bao phủ | Đã bao phủ |
| Truy cập công cụ | Còn thiếu | Một phần | Một phần | Một phần | Đã bao phủ | Đã bao phủ |
| Bộ nhớ dự án | Còn thiếu | Đã bao phủ | Đã bao phủ | Đã bao phủ | Đã bao phủ | Đã bao phủ |
| Trạng thái nhiệm vụ | Còn thiếu | Một phần | Đã bao phủ | Đã bao phủ | Đã bao phủ | Đã bao phủ |
| Khả năng quan sát | Còn thiếu | Còn thiếu | Một phần | Đã bao phủ | Đã bao phủ | Đã bao phủ |
| Quy trách nhiệm lỗi | Còn thiếu | Còn thiếu | Một phần | Đã bao phủ | Đã bao phủ | Đã bao phủ |
| Xác thực | Còn thiếu | Một phần | Một phần | Một phần | Đã bao phủ | Đã bao phủ |
| Quyền hạn | Còn thiếu | Một phần | Một phần | Một phần | Đã bao phủ | Đã bao phủ |
| Kiểm toán entropy | Còn thiếu | Còn thiếu | Một phần | Đã bao phủ | Đã bao phủ | Đã bao phủ |
| Ghi nhận sự can thiệp | Còn thiếu | Một phần | Một phần | Đã bao phủ | Đã bao phủ | Đã bao phủ |

## Giải thích Phase 3 (Phase 3 Interpretation)

Phase 3 bắt đầu quá trình chuyển dịch từ H2 sang H3. Nó tuyên bố đạt được chấm điểm trace chủ động và vòng lặp phản hồi cải tiến được tài liệu hóa, nhưng không tuyên bố đạt H3 đầy đủ vì so sánh benchmark và quy trách nhiệm thoái lui ở cấp độ thành phần rõ ràng nằm ngoài phạm vi Phase 3 của kho lưu trữ này.

## Giải thích Phase 4 (Phase 4 Interpretation)

Phase 4 bắt đầu quá trình chuyển dịch từ H3 sang H4. Nó cung cấp cho các story mẫu thiết kế xác thực cơ học tương tự như các quyết định kỹ thuật đã có, ghi lại kết quả xác thực story trong lớp lưu trữ bền vững, tự động chấm điểm các trace khi ghi nhận và cảnh báo trước khi đóng trace khi việc xác thực story liên kết chưa vượt qua. Nó không tuyên bố đạt H4 đầy đủ vì việc thực thi benchmark, xác thực hàng loạt và cập nhật cột chứng thực tự động vẫn là các công việc riêng biệt.

## Giải thích Phase 5 (Phase 5 Interpretation)

Phase 5 hoàn thành H4 bằng cách bổ sung xác thực story hàng loạt và bắt đầu H5 bằng cách bổ sung khả năng khám phá công cụ, các bản ghi can thiệp, chấm điểm ngữ cảnh, kiểm toán sai lệch và tạo đề xuất mang tính xác định. Kho lưu trữ có thể tuyên bố đạt H5 một phần khi các lệnh và tài liệu này hiện diện và được xác thực; nó không được phép tuyên bố đạt H5 đầy đủ cho đến khi các lượt chạy benchmark hoặc kết quả trace chứng minh vòng lặp đề xuất cải thiện harness theo thời gian.
