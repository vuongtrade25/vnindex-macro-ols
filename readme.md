# VN-Index Macro Factors OLS Analysis

Phân tích mối quan hệ giữa biến động tỷ giá USD/VND, giá vàng và giá dầu với tỷ suất sinh lợi VN-Index bằng mô hình hồi quy OLS.

Nghiên cứu sử dụng dữ liệu theo tháng trong giai đoạn **2018–2025**.

## 1. Mục tiêu nghiên cứu

Mục tiêu của project là phân tích mối quan hệ giữa các yếu tố thị trường và tỷ suất sinh lợi của VN-Index.

Các yếu tố được sử dụng gồm:

- Tỷ giá USD/VND
- Giá vàng
- Giá dầu
- Tỷ suất sinh lợi VN-Index

Mô hình nghiên cứu:

\[
R_{VNINDEX,t}
=
\beta_0
+
\beta_1 R_{USD/VND,t}
+
\beta_2 R_{GOLD,t}
+
\beta_3 R_{OIL,t}
+
\epsilon_t
\]

Trong đó:

| Biến | Vai trò | Ý nghĩa |
|---|---|---|
| `VNINDEX_RETURN` | Biến phụ thuộc | Tỷ suất sinh lợi VN-Index |
| `USD_VND_RETURN` | Biến độc lập | Tỷ lệ biến động tỷ giá USD/VND |
| `GOLD_RETURN` | Biến độc lập | Tỷ suất sinh lợi giá vàng |
| `OIL_RETURN` | Biến độc lập | Tỷ suất sinh lợi giá dầu |

## 2. Quy trình nghiên cứu

Project sử dụng kết hợp **Python** và **R**.

```text
Python
   │
   ├── Thu thập dữ liệu
   │
   ├── Đồng bộ dữ liệu
   │
   ├── Chuyển dữ liệu ngày sang tháng
   │
   └── Tính tỷ suất sinh lợi
   │
   ▼
return_data.csv
   │
   ▼
R
   │
   ├── Thống kê mô tả
   ├── Ma trận tương quan
   ├── Hồi quy OLS
   ├── Kiểm tra đa cộng tuyến
   ├── Kiểm định phương sai thay đổi
   ├── Kiểm định tự tương quan
   ├── Kiểm định phần dư
   └── Robust Standard Error
```

## 3. Nguồn dữ liệu

### VN-Index

Dữ liệu VN-Index được thu thập bằng thư viện `vnstock`.

Mã chỉ số:

```text
VNINDEX
```

### USD/VND

Dữ liệu tỷ giá USD/VND được thu thập thông qua `yfinance`.

Ticker:

```text
VND=X
```

### Giá vàng

Dữ liệu giá vàng sử dụng Gold Futures.

Ticker:

```text
GC=F
```

### Giá dầu

Dữ liệu giá dầu sử dụng WTI Crude Oil Futures.

Ticker:

```text
CL=F
```

## 4. Giai đoạn nghiên cứu

```text
01/2018 - 12/2025
```

Dữ liệu gốc được thu thập theo ngày.

Sau đó dữ liệu được chuyển thành dữ liệu tháng bằng cách lấy giá cuối tháng.

Tổng số quan sát sau khi tính tỷ suất sinh lợi:

```text
95 observations
```

## 5. Tính tỷ suất sinh lợi

Tỷ suất sinh lợi được tính theo công thức:

\[
R_t = \frac{P_t}{P_{t-1}} - 1
\]

Trong đó:

- \(R_t\): tỷ suất sinh lợi tại thời điểm \(t\)
- \(P_t\): giá tại thời điểm \(t\)
- \(P_{t-1}\): giá tại thời điểm trước đó

Trong Python, tỷ suất sinh lợi được tính bằng:

```python
returns = monthly.pct_change()
```

## 6. Cấu trúc project

```text
vnindex-macro-ols/
│
├── get_data.py
├── main.R
├── requirements.txt
│
├── data/
│   └── return_data.csv
│
└── output/
    ├── descriptive_statistics.csv
    ├── correlation_matrix.csv
    ├── ols_coefficients.csv
    ├── model_statistics.csv
    ├── vif_result.csv
    ├── breusch_pagan_test.csv
    ├── durbin_watson_test.csv
    ├── shapiro_test.csv
    ├── robust_standard_errors.csv
    ├── ols_full_result.txt
    ├── vnindex_return.png
    ├── vnindex_return_histogram.png
    ├── residual_qq_plot.png
    └── residual_vs_fitted.png
```

## 7. Công nghệ sử dụng

### Python

Python được sử dụng để thu thập và xử lý dữ liệu.

Các thư viện chính:

```text
pandas
yfinance
vnstock
```

### R

R được sử dụng để thực hiện phân tích kinh tế lượng.

Các package chính:

```text
car
lmtest
sandwich
```

## 8. Cài đặt

Clone repository:

```bash
git clone <repository-url>
```

Di chuyển vào project:

```bash
cd vnindex-macro-ols
```

Tạo Python virtual environment:

```bash
py -m venv venv
```

Kích hoạt môi trường trên Windows:

```powershell
.\venv\Scripts\activate
```

Cài đặt thư viện Python:

```bash
pip install -r requirements.txt
```

Cài đặt package R:

```powershell
Rscript.exe -e "install.packages(c('car','lmtest','sandwich'), repos='https://cloud.r-project.org')"
```

## 9. Chạy project

### Bước 1: Thu thập và xử lý dữ liệu

```bash
py get_data.py
```

Python thực hiện:

```text
Thu thập dữ liệu
        ↓
Đồng bộ dữ liệu
        ↓
Chuyển dữ liệu ngày sang tháng
        ↓
Lấy giá cuối tháng
        ↓
Tính tỷ suất sinh lợi
        ↓
data/return_data.csv
```

### Bước 2: Phân tích bằng R

```bash
Rscript.exe main.R
```

R thực hiện toàn bộ quá trình phân tích và xuất kết quả vào thư mục:

```text
output/
```

## 10. Phương pháp phân tích

### Thống kê mô tả

Các chỉ tiêu được tính gồm:

- Số quan sát
- Trung bình
- Trung vị
- Độ lệch chuẩn
- Giá trị nhỏ nhất
- Giá trị lớn nhất

### Ma trận tương quan Pearson

Ma trận tương quan được sử dụng để đánh giá mối quan hệ tuyến tính ban đầu giữa các biến.

### Hồi quy OLS

Mô hình hồi quy:

\[
VNINDEX\_RETURN
=
\beta_0
+
\beta_1 USD\_VND\_RETURN
+
\beta_2 GOLD\_RETURN
+
\beta_3 OIL\_RETURN
+
\epsilon
\]

### Variance Inflation Factor

VIF được sử dụng để kiểm tra hiện tượng đa cộng tuyến giữa các biến độc lập.

### Breusch-Pagan Test

Kiểm định Breusch-Pagan được sử dụng để kiểm tra hiện tượng phương sai sai số thay đổi.

Giả thuyết:

```text
H0: Phương sai sai số không đổi
H1: Phương sai sai số thay đổi
```

### Durbin-Watson Test

Kiểm định Durbin-Watson được sử dụng để kiểm tra tự tương quan của phần dư.

### Shapiro-Wilk Test

Kiểm định Shapiro-Wilk được sử dụng để đánh giá giả định phân phối chuẩn của phần dư.

### Robust Standard Error

Mô hình sử dụng thêm HC1 Robust Standard Error nhằm đánh giá độ bền của kết quả ước lượng.