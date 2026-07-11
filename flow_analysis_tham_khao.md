# FLOW PHÂN TÍCH KẾT QUẢ HỒI QUY OLS

## 1. Mục tiêu

Sau khi `get_data.py` hoàn thành pipeline dữ liệu, ta có dataset gồm:

```text
month
VNINDEX_RETURN
USD_VND_RETURN
GOLD_RETURN
OIL_RETURN
```

Mô hình nghiên cứu:

[
R_{VNINDEX,t}
=============

\beta_0
+
\beta_1R_{USD/VND,t}
+
\beta_2R_{GOLD,t}
+
\beta_3R_{OIL,t}
+
\epsilon_t
]

Trong đó:

```text
Y  = VNINDEX_RETURN
X1 = USD_VND_RETURN
X2 = GOLD_RETURN
X3 = OIL_RETURN
```

Mục tiêu của bước phân tích không phải chỉ là chạy:

```r
lm()
```

rồi nhìn biến nào có dấu `*`.

Cần trả lời lần lượt:

```text
Dữ liệu có đặc điểm gì?
        ↓
Các biến có liên hệ ban đầu không?
        ↓
Mô hình tổng thể có ý nghĩa không?
        ↓
Biến nào thực sự tác động đến VN-Index?
        ↓
Tác động cùng chiều hay ngược chiều?
        ↓
Mức tác động bao nhiêu?
        ↓
Mô hình có vi phạm giả định OLS không?
        ↓
Kết luận có còn ổn khi dùng Robust SE không?
```

Dataset cuối có:

```text
95 observations
```

Giai đoạn nghiên cứu:

```text
02/2018 → 12/2025
```

Dữ liệu giá có 96 tháng nhưng khi tính:

```r
Return_t = Price_t / Price_(t-1) - 1
```

tháng đầu tiên không có dữ liệu kỳ trước.

Do đó:

```text
96 tháng
-
1
=
95 tỷ suất sinh lợi
```

---

# 2. Đọc thống kê mô tả

Kết quả:

```text
Variable          N       Mean       Median      Std_Dev
VNINDEX_RETURN   95     0.00695     0.01007      0.06179
USD_VND_RETURN   95     0.00160     0.00062      0.01013
GOLD_RETURN      95     0.01327     0.00864      0.03917
OIL_RETURN       95     0.00794     0.01129      0.13894
```

Đầu tiên cần nhớ:

```text
0.01 = 1%
```

Không được đọc:

```text
0.01 = 0.01%
```

## VN-Index

Mean:

```text
0.00695057
≈ 0.695% / tháng
```

Có nghĩa trong giai đoạn nghiên cứu, tỷ suất sinh lợi trung bình tháng của VN-Index khoảng:

```text
+0.695%
```

Median:

```text
≈ 1.007%
```

Standard deviation:

```text
≈ 6.18%
```

Min:

```text
-24.90%
```

Max:

```text
+16.09%
```

Điểm cần chú ý là:

```text
Std_Dev = 6.18%
```

lớn hơn khá nhiều so với:

```text
Mean = 0.695%
```

VN-Index có lợi nhuận trung bình dương nhưng biến động tháng tương đối lớn.

Không được kết luận:

> VN-Index tăng 0.695% mỗi tháng.

Mean chỉ là trung bình của 95 quan sát.

Nó không có nghĩa tháng nào VN-Index cũng tăng 0.695%.

---

## USD/VND

Mean:

```text
0.001597
≈ 0.160% / tháng
```

Standard deviation:

```text
≈ 1.01%
```

So với các biến còn lại, USD/VND có độ lệch chuẩn thấp nhất.

Có thể thấy tỷ giá biến động tương đối nhỏ hơn:

```text
VN-Index
Gold
Oil
```

trong dữ liệu nghiên cứu.

---

## Gold

Mean:

```text
0.013274
≈ 1.327% / tháng
```

Standard deviation:

```text
≈ 3.92%
```

Trong bốn chuỗi dữ liệu, vàng có tỷ suất sinh lợi trung bình tháng cao nhất.

Tuy nhiên:

```text
Mean cao
≠
có tác động đến VN-Index
```

Đây là hai câu hỏi khác nhau.

Thống kê mô tả chỉ cho biết đặc điểm riêng của biến.

Muốn biết vàng có tác động đến VN-Index hay không phải xem kết quả hồi quy.

---

## Oil

Mean:

```text
≈ 0.794% / tháng
```

Standard deviation:

```text
≈ 13.89%
```

Min:

```text
-54.24%
```

Max:

```text
+88.38%
```

Dầu là biến có độ biến động lớn nhất trong dataset.

So sánh standard deviation:

```text
USD/VND     1.01%
Gold        3.92%
VN-Index    6.18%
Oil        13.89%
```

Khi nhìn vào đây cần ghi nhận:

> Oil có mức biến động rất mạnh.

Nhưng chưa được kết luận:

> Oil tác động mạnh nhất đến VN-Index.

Muốn kết luận tác động phải xem:

```text
coefficient
p-value
```

trong mô hình hồi quy.

---

# 3. Đọc ma trận tương quan

Kết quả:

```text
               VNINDEX   USD/VND   GOLD     OIL
VNINDEX         1.0000   -0.2884   0.0739   0.4171
USD/VND        -0.2884    1.0000  -0.2097  -0.0919
GOLD            0.0739   -0.2097   1.0000  -0.0844
OIL             0.4171   -0.0919  -0.0844   1.0000
```

Hệ số tương quan nằm trong:

```text
-1 → +1
```

Cách đọc dấu:

```text
r > 0
→ cùng chiều

r < 0
→ ngược chiều
```

Giá trị tuyệt đối càng lớn thì mối liên hệ tuyến tính càng mạnh.

---

## VN-Index và USD/VND

```text
Correlation = -0.2884
```

Tương quan âm.

Trong dữ liệu nghiên cứu:

```text
USD/VND tăng
↕
VN-Index có xu hướng giảm
```

Mức tương quan không quá mạnh.

Cần dùng từ:

> có xu hướng

Không nên viết:

> USD/VND tăng làm VN-Index giảm.

Ma trận tương quan chưa chứng minh tác động trong mô hình đa biến.

---

## VN-Index và Gold

```text
Correlation = 0.0739
```

Giá trị rất gần 0.

Mối liên hệ tuyến tính giữa return vàng và return VN-Index trong mẫu khá yếu.

Đây là dấu hiệu ban đầu cho thấy vàng có thể không giải thích nhiều biến động của VN-Index.

Tuy nhiên vẫn cần kiểm tra OLS.

---

## VN-Index và Oil

```text
Correlation = 0.4171
```

Đây là tương quan lớn nhất giữa VN-Index và các biến X.

Dấu dương cho thấy:

```text
Oil tăng
↕
VN-Index có xu hướng tăng
```

Kết quả này mới chỉ là quan hệ hai biến.

OLS sẽ kiểm tra tác động của Oil khi đồng thời kiểm soát:

```text
USD/VND
Gold
```

---

# 4. Correlation không phải Regression

Đây là điểm cần phân biệt.

Correlation hỏi:

> Hai biến có biến động cùng nhau hay không?

Regression hỏi:

> Khi giữ các biến khác không đổi, X thay đổi thì Y thay đổi như thế nào?

Ví dụ:

```text
corr(VNINDEX, OIL)
=
0.4171
```

Chỉ cho biết VN-Index và Oil có tương quan dương.

Trong OLS:

```text
OIL coefficient
=
0.177867
```

Ta đang ước lượng tác động của Oil lên VN-Index sau khi đã đưa USD/VND và Gold vào mô hình.

Do đó không dùng ma trận tương quan để thay thế kết quả hồi quy.

---

# 5. Viết phương trình hồi quy ước lượng

Kết quả coefficient:

```text
Intercept         0.006671
USD_VND_RETURN   -1.461811
GOLD_RETURN       0.090610
OIL_RETURN        0.177867
```

Phương trình ước lượng:

[
\widehat{R}_{VNINDEX}
=====================

## 0.006671

1.461811R_{USD/VND}
+
0.090610R_{GOLD}
+
0.177867R_{OIL}
]

Đây là phương trình được ước lượng từ 95 quan sát trong dataset.

---

# 6. Đọc Intercept

```text
Estimate = 0.006671
p-value  = 0.2780
```

Hệ số chặn khoảng:

```text
0.6671%
```

Về mặt phương trình:

Khi:

```text
USD_VND_RETURN = 0
GOLD_RETURN = 0
OIL_RETURN = 0
```

mô hình ước lượng:

```text
VNINDEX_RETURN ≈ 0.6671%
```

Tuy nhiên:

```text
p-value = 0.2780 > 0.05
```

Hệ số chặn không có ý nghĩa thống kê ở mức 5%.

Intercept không phải trọng tâm của bài nghiên cứu này.

Ba biến thị trường mới là phần cần tập trung.

---

# 7. Phân tích USD/VND

Kết quả OLS:

```text
Estimate = -1.461811
p-value  = 0.0125
```

Dấu:

```text
âm
```

Có nghĩa USD/VND và VN-Index có quan hệ ngược chiều trong mô hình.

Do return được lưu dưới dạng số thập phân:

```text
USD/VND tăng 1%
=
USD_VND_RETURN tăng 0.01
```

Tác động ước lượng:

```text
-1.461811 × 0.01
=
-0.01461811
```

Tức:

```text
≈ -1.462%
```

Có thể diễn giải:

> Khi tỷ suất biến động USD/VND tăng 1%, tỷ suất sinh lợi VN-Index được ước lượng giảm khoảng 1.462%, trong điều kiện tỷ suất sinh lợi vàng và dầu không đổi.

P-value:

```text
0.0125 < 0.05
```

Theo standard error OLS thông thường, USD/VND có ý nghĩa thống kê ở mức 5%.

Kết quả ban đầu cho thấy tỷ giá là một yếu tố có khả năng giải thích biến động tỷ suất sinh lợi VN-Index.

---

# 8. Phân tích Gold

Kết quả:

```text
Estimate = 0.090610
p-value  = 0.5427
```

Hệ số mang dấu dương.

Nếu chỉ nhìn coefficient:

```text
Gold tăng 1%
→ VN-Index tăng khoảng 0.091%
```

Tuy nhiên:

```text
p-value = 0.5427
```

lớn hơn rất nhiều so với:

```text
0.05
```

Do đó không đủ bằng chứng thống kê để kết luận Gold Return có tác động đến VN-Index Return trong mô hình.

Đây là lỗi đọc output rất thường gặp:

```text
Estimate > 0
↓
kết luận tác động dương
```

Cách đọc này thiếu bước kiểm tra p-value.

Đúng phải là:

```text
Xem coefficient
↓
xác định chiều tác động

Xem p-value
↓
kiểm tra có đủ bằng chứng thống kê hay không
```

Với Gold:

```text
chiều ước lượng = dương
nhưng
không có ý nghĩa thống kê
```

Do đó kết luận nên viết:

> Chưa tìm thấy bằng chứng thống kê cho thấy biến động giá vàng có tác động đến tỷ suất sinh lợi VN-Index trong giai đoạn nghiên cứu.

Không nên viết:

> Vàng không tác động đến VN-Index.

Mô hình chỉ cho phép nói:

```text
chưa đủ bằng chứng trong dữ liệu và mô hình hiện tại
```

---

# 9. Phân tích Oil

Kết quả:

```text
Estimate = 0.177867
p-value  = 3.77e-05
```

Dấu hệ số:

```text
dương
```

Nếu Oil Return tăng:

```text
1%
```

thì tác động ước lượng lên VN-Index:

```text
0.177867 × 0.01
=
0.00177867
```

Tức khoảng:

```text
+0.178%
```

Có thể diễn giải:

> Khi tỷ suất sinh lợi giá dầu tăng 1%, tỷ suất sinh lợi VN-Index được ước lượng tăng khoảng 0.178%, trong điều kiện các biến còn lại không đổi.

P-value:

```text
0.0000377
```

nhỏ hơn:

```text
0.001
```

Oil có ý nghĩa thống kê rất cao trong mô hình OLS.

Trong ba biến nghiên cứu, Oil là biến có bằng chứng thống kê rõ nhất.

---

# 10. Đọc R-squared

Kết quả:

```text
Multiple R-squared = 0.2402
```

Tức:

```text
24.02%
```

Có thể diễn giải:

> Khoảng 24.02% biến động của tỷ suất sinh lợi VN-Index trong mẫu được giải thích bởi biến động USD/VND, giá vàng và giá dầu trong mô hình.

Phần còn lại:

```text
100%
-
24.02%
=
75.98%
```

liên quan đến các yếu tố chưa được mô hình giải thích.

Có thể bao gồm:

```text
lãi suất
cung tiền
lạm phát
dòng vốn nước ngoài
tâm lý nhà đầu tư
kết quả kinh doanh
chính sách tiền tệ
rủi ro chính trị
các cú sốc thị trường
```

Không được viết:

> 75.98% VN-Index do các yếu tố khác tác động.

R-squared nói về:

```text
mức độ giải thích biến thiên trong mẫu
```

Không trực tiếp chia nguyên nhân kinh tế thành tỷ trọng.

---

# 11. Adjusted R-squared

Kết quả:

```text
Adjusted R-squared = 0.2151
```

Tức:

```text
21.51%
```

Adjusted R-squared có điều chỉnh theo số lượng biến độc lập trong mô hình.

R-squared thông thường có đặc điểm:

```text
thêm biến X
↓
R² thường không giảm
```

Ngay cả khi biến mới không thực sự hữu ích.

Adjusted R-squared có cơ chế phạt việc thêm biến không cần thiết.

Trong project:

```text
R²          = 24.02%
Adjusted R² = 21.51%
```

Khoảng cách không quá lớn.

Tuy nhiên kết quả của Gold cho thấy không phải tất cả biến X đều có ý nghĩa thống kê riêng lẻ.

---

# 12. Kiểm định F

Kết quả:

```text
F-statistic = 9.589
p-value     = 1.451e-05
```

Giả thuyết:

```text
H0:
β1 = β2 = β3 = 0

H1:
Có ít nhất một β khác 0
```

P-value:

```text
0.00001451 < 0.05
```

Bác bỏ H0.

Kết luận:

> Mô hình hồi quy có ý nghĩa thống kê tổng thể ở mức ý nghĩa 5%.

Nói đơn giản:

```text
USD/VND
Gold
Oil
```

khi xét trong mô hình tổng thể có khả năng giải thích VN-Index tốt hơn mô hình không có các biến X.

Kiểm định F không nói:

> cả ba biến đều có ý nghĩa.

Thực tế:

```text
USD/VND → có ý nghĩa theo OLS thường
Gold    → không có ý nghĩa
Oil     → có ý nghĩa
```

F-test chỉ kiểm tra ý nghĩa chung của mô hình.

---

# 13. Tại sao phải kiểm tra giả định OLS?

Chạy được:

```r
lm()
```

không có nghĩa kết quả đã đáng tin.

OLS dựa trên một số giả định.

Trong project ta kiểm tra:

```text
Multicollinearity
        ↓
VIF

Heteroskedasticity
        ↓
Breusch-Pagan

Autocorrelation
        ↓
Durbin-Watson

Normality of residuals
        ↓
Shapiro-Wilk
```

Nếu không kiểm tra các giả định này, việc chỉ đọc:

```text
coefficient
p-value
```

là chưa đủ.

---

# 14. Kiểm tra đa cộng tuyến bằng VIF

Kết quả:

```text
USD_VND_RETURN    1.059408
GOLD_RETURN       1.058015
OIL_RETURN        1.020083
```

VIF đo mức độ một biến X có thể được giải thích tuyến tính bởi các biến X còn lại.

Rule of thumb thường dùng:

```text
VIF < 5
→ thường không đáng lo

VIF > 5
→ cần chú ý

VIF > 10
→ đa cộng tuyến nghiêm trọng
```

Trong project:

```text
VIF ≈ 1
```

Tất cả biến đều rất thấp.

Kết luận:

> Không phát hiện vấn đề đa cộng tuyến đáng kể giữa USD/VND Return, Gold Return và Oil Return.

Kết quả này cũng phù hợp với ma trận tương quan giữa các biến X.

Các tương quan:

```text
USD/VND - Gold = -0.2097
USD/VND - Oil  = -0.0919
Gold - Oil     = -0.0844
```

đều thấp.

---

# 15. Breusch-Pagan Test

Kết quả:

```text
BP      = 4.6433
p-value = 0.1999
```

Kiểm định Breusch-Pagan kiểm tra phương sai sai số thay đổi.

Giả thuyết:

```text
H0:
Phương sai sai số không đổi

H1:
Có hiện tượng phương sai sai số thay đổi
```

Kết quả:

```text
p-value = 0.1999 > 0.05
```

Không bác bỏ H0.

Kết luận:

> Chưa phát hiện bằng chứng về hiện tượng phương sai sai số thay đổi trong mô hình ở mức ý nghĩa 5%.

Cần chú ý cách dùng từ.

Không nên viết:

> Mô hình chắc chắn không có heteroskedasticity.

Kiểm định chỉ cho biết:

```text
không đủ bằng chứng để bác bỏ H0
```

---

# 16. Durbin-Watson Test

Kết quả:

```text
DW      = 2.1075
p-value = 0.692
```

Durbin-Watson dùng để kiểm tra tự tương quan của phần dư.

Giá trị DW thường nằm trong:

```text
0 → 4
```

Cách nhìn nhanh:

```text
DW ≈ 2
→ không có dấu hiệu tự tương quan bậc nhất rõ ràng

DW < 2
→ xu hướng tự tương quan dương

DW > 2
→ xu hướng tự tương quan âm
```

Trong project:

```text
DW = 2.1075
```

rất gần 2.

P-value:

```text
0.692 > 0.05
```

Với kiểm định đang chạy cho giả thuyết tự tương quan dương, ta không có đủ bằng chứng để kết luận phần dư có tự tương quan dương.

Kết quả này cho thấy chưa phát hiện vấn đề autocorrelation theo kiểm định hiện tại.

---

# 17. Shapiro-Wilk Test

Kết quả:

```text
W       = 0.99264
p-value = 0.8843
```

Giả thuyết:

```text
H0:
Phần dư có phân phối chuẩn

H1:
Phần dư không có phân phối chuẩn
```

P-value:

```text
0.8843 > 0.05
```

Không bác bỏ H0.

Kết luận:

> Chưa có bằng chứng thống kê cho thấy phần dư vi phạm giả định phân phối chuẩn.

Giá trị:

```text
W = 0.99264
```

cũng khá gần 1.

Kết quả kiểm định cho thấy phân phối phần dư tương đối phù hợp với giả định chuẩn.

---

# 18. Tổng hợp kiểm định giả định

Có thể tổng hợp:

| Kiểm định     | Kết quả                | Kết luận                                           |
| ------------- | ---------------------- | -------------------------------------------------- |
| VIF           | ≈ 1                    | Không có đa cộng tuyến đáng kể                     |
| Breusch-Pagan | p = 0.1999             | Chưa phát hiện phương sai sai số thay đổi          |
| Durbin-Watson | DW = 2.1075, p = 0.692 | Chưa phát hiện tự tương quan dương                 |
| Shapiro-Wilk  | p = 0.8843             | Chưa phát hiện vi phạm phân phối chuẩn của phần dư |

Nhìn chung, các kiểm định hiện tại chưa cho thấy mô hình vi phạm nghiêm trọng các giả định OLS được kiểm tra.

---

# 19. Tại sao vẫn chạy Robust Standard Error?

Mặc dù Breusch-Pagan cho kết quả:

```text
p = 0.1999
```

ta vẫn chạy Robust Standard Error.

Lý do là muốn kiểm tra:

> Kết luận về ý nghĩa thống kê có nhạy với cách ước lượng standard error hay không?

Điểm cần nhớ:

```text
Robust SE
không thay đổi coefficient
```

So sánh:

```text
OLS coefficient USD/VND = -1.4618107
Robust           = -1.4618107
```

Robust SE thay đổi:

```text
Standard Error
↓
t-value
↓
p-value
```

Nó kiểm tra độ vững của suy luận thống kê.

---

# 20. So sánh OLS và Robust SE

## USD/VND

OLS:

```text
Estimate = -1.461811
p-value  = 0.0125
```

Robust:

```text
Estimate = -1.461811
p-value  = 0.053753
```

Coefficient không đổi.

Nhưng p-value thay đổi:

```text
0.0125
↓
0.0538
```

Theo OLS thông thường:

```text
p < 0.05
→ có ý nghĩa thống kê
```

Theo Robust SE:

```text
p > 0.05
→ không đạt mức ý nghĩa 5%
```

Tuy nhiên:

```text
p ≈ 0.054
```

rất sát 5%.

Nếu sử dụng mức ý nghĩa 10%:

```text
0.0538 < 0.10
```

USD/VND có ý nghĩa ở mức 10%.

Do đó kết luận thận trọng nên là:

> USD/VND có tác động âm đến tỷ suất sinh lợi VN-Index. Tuy nhiên, ý nghĩa thống kê của biến này nhạy với phương pháp ước lượng sai số chuẩn. Biến có ý nghĩa ở mức 5% theo OLS thông thường nhưng chỉ đạt mức ý nghĩa 10% khi sử dụng Robust Standard Error.

Đây là kết quả cần chú ý.

Không nên chỉ lấy output OLS và bỏ qua Robust SE.

---

## Gold

OLS:

```text
p = 0.5427
```

Robust:

```text
p = 0.507293
```

Cả hai đều:

```text
> 0.05
```

Kết luận không thay đổi.

Chưa tìm thấy bằng chứng thống kê về tác động của Gold Return lên VN-Index Return.

---

## Oil

OLS:

```text
p = 0.0000377
```

Robust:

```text
p = 0.001429
```

P-value tăng khi dùng Robust SE.

Tuy nhiên:

```text
0.001429 < 0.01
```

Oil vẫn có ý nghĩa thống kê ở mức 1%.

Dấu coefficient vẫn dương:

```text
+0.177867
```

Kết luận về Oil tương đối ổn định giữa hai phương pháp.

Đây là biến có kết quả vững nhất trong mô hình hiện tại.

---

# 21. Kết quả chính của mô hình

Sau toàn bộ quá trình phân tích, có thể tóm tắt:

```text
USD/VND
↓
Tác động âm
OLS: có ý nghĩa 5%
Robust: có ý nghĩa 10%
Kết quả cần diễn giải thận trọng


GOLD
↓
Coefficient dương
Không có ý nghĩa thống kê
Chưa đủ bằng chứng về tác động


OIL
↓
Tác động dương
Có ý nghĩa thống kê mạnh
Kết quả vẫn giữ khi dùng Robust SE
```

Mô hình tổng thể:

```text
F-test p-value = 0.00001451
```

Có ý nghĩa thống kê.

Khả năng giải thích:

```text
R² = 24.02%
Adjusted R² = 21.51%
```

Các kiểm định hiện tại chưa phát hiện:

```text
đa cộng tuyến đáng kể
phương sai sai số thay đổi
tự tương quan dương
vi phạm phân phối chuẩn của phần dư
```

---

# 22. Cách kết luận nghiên cứu

Từ kết quả thực nghiệm, biến động tỷ giá USD/VND và giá dầu cho thấy mối liên hệ đáng chú ý với tỷ suất sinh lợi VN-Index trong giai đoạn 2018–2025.

Tỷ suất biến động USD/VND mang hệ số âm. Theo kết quả OLS thông thường, biến này có ý nghĩa thống kê ở mức 5%. Tuy nhiên, khi sử dụng Robust Standard Error, p-value tăng lên khoảng 0.054. Vì vậy, bằng chứng về tác động của tỷ giá cần được diễn giải thận trọng và chỉ đạt mức ý nghĩa 10% trong kết quả robust.

Tỷ suất sinh lợi giá dầu mang hệ số dương và duy trì ý nghĩa thống kê sau khi điều chỉnh sai số chuẩn robust. Kết quả cho thấy đây là biến có bằng chứng thực nghiệm ổn định nhất trong mô hình.

Đối với giá vàng, mô hình chưa tìm thấy bằng chứng thống kê cho thấy biến động giá vàng có tác động đến tỷ suất sinh lợi VN-Index trong giai đoạn nghiên cứu.

Ba biến USD/VND, vàng và dầu giải thích khoảng 24.02% biến động tỷ suất sinh lợi VN-Index trong mẫu. Điều này cho thấy tỷ suất sinh lợi thị trường chứng khoán Việt Nam còn liên quan đến nhiều yếu tố khác chưa được đưa vào mô hình.

---

# 23. Flow đọc một output OLS bất kỳ

Khi nhận một output hồi quy, không đọc ngẫu nhiên từng con số.

Đọc theo thứ tự:

```text
1. N
↓
Dataset có đủ observation không?


2. Descriptive Statistics
↓
Mean
Median
Std Dev
Min
Max


3. Correlation Matrix
↓
Chiều quan hệ ban đầu
Tương quan giữa các X


4. F-test
↓
Mô hình tổng thể có ý nghĩa không?


5. R² / Adjusted R²
↓
Mô hình giải thích được bao nhiêu biến thiên của Y?


6. Coefficient
↓
Dấu dương hay âm?


7. P-value
↓
Có đủ bằng chứng thống kê không?


8. VIF
↓
Có đa cộng tuyến không?


9. Breusch-Pagan
↓
Có heteroskedasticity không?


10. Durbin-Watson
↓
Có autocorrelation không?


11. Shapiro-Wilk
↓
Residual có phù hợp giả định chuẩn không?


12. Robust SE
↓
Kết luận có thay đổi không?
```

Không được làm:

```text
thấy ***
↓
kết luận biến quan trọng
```

Cần hiểu:

```text
Coefficient
=
chiều và mức tác động ước lượng

P-value
=
bằng chứng thống kê

R²
=
khả năng giải thích biến thiên Y trong mẫu

F-test
=
ý nghĩa tổng thể của mô hình

Diagnostic tests
=
kiểm tra giả định

Robust SE
=
kiểm tra độ vững của suy luận
```

---

# 24. Checklist trước khi viết kết luận

```text
[ ] Đã kiểm tra số observation
[ ] Đã đọc mean và standard deviation
[ ] Đã kiểm tra correlation
[ ] Đã viết phương trình hồi quy ước lượng
[ ] Đã kiểm tra F-test
[ ] Đã đọc R²
[ ] Đã đọc Adjusted R²
[ ] Đã xác định dấu từng coefficient
[ ] Đã kiểm tra p-value từng biến
[ ] Đã diễn giải coefficient đúng đơn vị %
[ ] Đã kiểm tra VIF
[ ] Đã kiểm tra Breusch-Pagan
[ ] Đã kiểm tra Durbin-Watson
[ ] Đã kiểm tra Shapiro-Wilk
[ ] Đã so sánh OLS với Robust SE
[ ] Không viết correlation thành causality
[ ] Không viết “không tác động” khi p-value > 0.05
[ ] Không diễn giải R² thành tỷ trọng nguyên nhân
```

---

# 25. Tư duy cuối cùng

Toàn bộ flow phân tích có thể nhớ bằng:

```text
DESCRIBE
RELATE
ESTIMATE
TEST
VALIDATE
INTERPRET
```

```text
DESCRIBE
↓
Dữ liệu có đặc điểm gì?

RELATE
↓
Các biến có quan hệ ban đầu như thế nào?

ESTIMATE
↓
Mô hình ước lượng coefficient bao nhiêu?

TEST
↓
Coefficient và mô hình có ý nghĩa thống kê không?

VALIDATE
↓
Các giả định và kết luận có đủ ổn định không?

INTERPRET
↓
Chuyển con số thống kê thành kết luận nghiên cứu
```

Mục tiêu cuối cùng không phải là đọc được output R.

Mục tiêu là nhìn một kết quả hồi quy và biết:

```text
Con số này đang trả lời câu hỏi gì?
Có được phép kết luận gì?
Và chưa được phép kết luận gì?
```
