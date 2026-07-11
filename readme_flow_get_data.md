# FLOW LẤY DỮ LIỆU CHO PROJECT VNINDEX-MACRO-OLS

## 1. Mục tiêu của flow dữ liệu

Mục tiêu của `get_data.py` không phải chỉ là “tải dữ liệu về”.

Mục tiêu đúng là xây dựng một **pipeline dữ liệu có tư duy rõ ràng**:

```text
Xác định bài toán nghiên cứu
        ↓
Xác định biến Y và các biến X
        ↓
Xác định dữ liệu gốc cần lấy
        ↓
Chọn nguồn dữ liệu phù hợp cho từng biến
        ↓
Tải dữ liệu theo cùng giai đoạn nghiên cứu
        ↓
Chuẩn hóa thời gian
        ↓
Ghép các chuỗi dữ liệu
        ↓
Chuyển dữ liệu ngày thành dữ liệu tháng
        ↓
Tính tỷ suất sinh lợi
        ↓
Loại bỏ dữ liệu thiếu
        ↓
Kiểm tra số quan sát
        ↓
Xuất CSV cho R
```

Bắt đầu từ câu hỏi:

> Mô hình nghiên cứu cần biến gì, mỗi biến được đo bằng dữ liệu nào, và dữ liệu đó có thể lấy ở đâu?

---

# 2. Bắt đầu từ bài toán nghiên cứu

Đề tài:

> Phân tích mối quan hệ giữa biến động tỷ giá USD/VND, giá vàng và giá dầu với tỷ suất sinh lợi VN-Index bằng mô hình hồi quy OLS.

Mô hình:

```text
VNINDEX_RETURN
    =
USD_VND_RETURN
    +
GOLD_RETURN
    +
OIL_RETURN
```

Hay viết dưới dạng kinh tế lượng:

\[
R_{VNINDEX,t}
=
\beta_0
+
\beta_1R_{USD/VND,t}
+
\beta_2R_{GOLD,t}
+
\beta_3R_{OIL,t}
+
\epsilon_t
\]

Từ mô hình này, ta xác định ngay 4 chuỗi dữ liệu cần có:

| Biến | Vai trò | Dữ liệu gốc |
|---|---|---|
| `VNINDEX_RETURN` | Y | Giá VN-Index |
| `USD_VND_RETURN` | X1 | Tỷ giá USD/VND |
| `GOLD_RETURN` | X2 | Giá vàng |
| `OIL_RETURN` | X3 | Giá dầu |

## Tư duy quan trọng

Ta **không lấy trực tiếp `RETURN` từ nguồn dữ liệu**.

Ta lấy:

```text
PRICE
```

sau đó tự tính:

```text
RETURN
```

Lý do:

1. Chủ động kiểm soát công thức.
2. Các nguồn dữ liệu khác nhau có thể định nghĩa return khác nhau.
3. Ta cần đồng bộ toàn bộ biến về cùng tần suất tháng.
4. Dễ kiểm tra và tái lập nghiên cứu.

---

# 3. Tại sao lấy giá trước rồi mới tính return?

Ví dụ VN-Index:

```text
Tháng 1: 1,000 điểm
Tháng 2: 1,050 điểm
```

Tỷ suất sinh lợi:

\[
R_t = \frac{P_t}{P_{t-1}} - 1
\]

Kết quả:

```text
1050 / 1000 - 1 = 0.05
```

Tức:

```text
5%
```

Trong Python:

```python
returns = monthly.pct_change()
```

`pct_change()` thực hiện logic:

```text
giá hiện tại
÷
giá trước đó
-
1
```

## Tư duy

Khi làm mô hình tài chính, cần phân biệt:

```text
MỨC GIÁ
vs
TỶ SUẤT BIẾN ĐỘNG
```

Ví dụ:

```text
VN-Index = 1,200
Gold = 2,400
USD/VND = 25,000
Oil = 70
```

Các biến có đơn vị và độ lớn hoàn toàn khác nhau.

Nếu hồi quy trực tiếp mức giá, việc diễn giải sẽ khó hơn và dễ gặp vấn đề chuỗi thời gian.

Chuyển sang return:

```text
VN-Index: +2.1%
USD/VND: +0.3%
Gold: -1.2%
Oil: +4.5%
```

Các biến lúc này cùng mang ý nghĩa:

> mức biến động tương đối theo thời gian.

---

# 4. Chọn giai đoạn nghiên cứu

Project sử dụng:

```python
START_DATE = "2018-01-01"
END_DATE = "2025-12-31"
```

Tư duy chọn giai đoạn:

1. Các biến phải có dữ liệu tương đối đầy đủ.
2. Cùng một khoảng thời gian.
3. Số quan sát đủ để chạy OLS.
4. Không chọn giai đoạn quá dài nếu nguồn dữ liệu bị giới hạn lịch sử.

Ban đầu project thử lấy từ năm 2015.

Tuy nhiên dữ liệu VN-Index lấy qua `vnstock` chỉ cho tối đa 8 năm trong pipeline hiện tại.

Do đó ta điều chỉnh giai đoạn nghiên cứu thành:

```text
2018–2025
```

## Nguyên tắc

Không nên làm:

```text
VNINDEX: 2018–2025
USD/VND: 2015–2025
GOLD: 2015–2025
OIL: 2015–2025
```

rồi coi như toàn bộ mô hình có dữ liệu từ 2015.

Giai đoạn thực tế của mô hình phải dựa trên:

> khoảng thời gian chung mà tất cả biến đều có dữ liệu.

Trong project này:

```text
2018–2025
```

---

# 5. Tại sao dùng nhiều nguồn dữ liệu?

Ban đầu ta thử lấy toàn bộ dữ liệu từ Yahoo Finance.

Ticker VN-Index:

```text
^VNINDEX.VN
```

Code:

```python
yf.download(
    "^VNINDEX.VN",
    start=START_DATE,
    end=END_DATE,
)
```

Kết quả:

```text
possibly delisted
no price data found
```

Ta cũng thử qua R `tidyquant`.

Kết quả tương tự:

```text
Unable to import "^VNINDEX.VN"
```

Trong khi ticker như:

```text
AAPL
```

vẫn tải bình thường.

## Kết luận tư duy

Không nên cố ép:

> một nguồn dữ liệu phải cung cấp tất cả biến.

Thay vào đó:

```text
VNINDEX → vnstock
USD/VND → Yahoo Finance
GOLD → Yahoo Finance
OIL → Yahoo Finance
```

Đây là một tư duy rất quan trọng khi xây pipeline tài chính:

> Chọn nguồn phù hợp nhất cho từng loại tài sản.

Flow nguồn dữ liệu:

```text
                    ┌──────────────┐
VNINDEX ───────────→│   vnstock    │
                    └──────────────┘

                    ┌──────────────┐
USD/VND ───────────→│              │
GOLD ──────────────→│   yfinance   │
OIL ───────────────→│              │
                    └──────────────┘
```

---

# 6. Khai báo các ticker

Code:

```python
TICKERS = {
    "USD_VND": "VND=X",
    "GOLD": "GC=F",
    "OIL": "CL=F",
}
```

Ý nghĩa:

| Tên nội bộ | Ticker | Ý nghĩa |
|---|---|---|
| `USD_VND` | `VND=X` | USD/VND |
| `GOLD` | `GC=F` | Gold Futures |
| `OIL` | `CL=F` | WTI Crude Oil Futures |

## Tại sao dùng dictionary?

Thay vì viết:

```python
download("VND=X")
download("GC=F")
download("CL=F")
```

ta dùng:

```python
TICKERS = {
    "USD_VND": "VND=X",
    "GOLD": "GC=F",
    "OIL": "CL=F",
}
```

Sau đó loop:

```python
for name, ticker in TICKERS.items():
    ...
```

Lợi ích:

1. Dễ thêm biến.
2. Dễ đổi ticker.
3. Tránh copy-paste code.
4. Tên cột cuối cùng có ý nghĩa nghiên cứu.

Ví dụ muốn thêm Bitcoin:

```python
TICKERS = {
    "USD_VND": "VND=X",
    "GOLD": "GC=F",
    "OIL": "CL=F",
    "BITCOIN": "BTC-USD",
}
```

Pipeline gần như không cần sửa logic tải Yahoo.

---

# 7. Hàm lấy dữ liệu VN-Index

Code:

```python
def download_vnindex() -> pd.Series:
    print("Đang lấy VNINDEX bằng vnstock...")

    market = Market()

    data = market.index("VNINDEX").ohlcv(
        start=START_DATE,
        end=END_DATE,
        interval="1D",
        length=5000,
    )

    if data is None or data.empty:
        raise ValueError("Không lấy được dữ liệu VNINDEX")

    data["time"] = (
        pd.to_datetime(data["time"])
        .dt.normalize()
    )

    series = data.set_index("time")["close"]

    series.name = "VNINDEX"

    print(f"✅ VNINDEX: {len(series)} dòng")
    print(
        f"📅 VNINDEX: {series.index.min()} "
        f"-> {series.index.max()}"
    )

    return series
```

---

# 8. Phân tích tư duy từng dòng của `download_vnindex()`

## 8.1. Khởi tạo Market

```python
market = Market()
```

Ta tạo object dùng để truy cập dữ liệu thị trường.

Tư duy:

```text
Market
↓
Index
↓
VNINDEX
↓
OHLCV
```

---

## 8.2. Chọn chỉ số VNINDEX

```python
market.index("VNINDEX")
```

Ta đang nói với thư viện:

> Tôi cần dữ liệu của chỉ số VN-Index.

Không phải cổ phiếu:

```text
VCB
TCB
MBB
```

mà là:

```text
VNINDEX
```

---

## 8.3. Lấy OHLCV

```python
.ohlcv(
    start=START_DATE,
    end=END_DATE,
    interval="1D",
    length=5000,
)
```

OHLCV gồm:

```text
Open
High
Low
Close
Volume
```

Trong project này ta chỉ cần:

```text
Close
```

Nhưng nguồn trả về toàn bộ OHLCV.

### `interval="1D"`

Nghĩa là:

```text
1 quan sát / ngày giao dịch
```

Ví dụ:

```text
2018-01-02
2018-01-03
2018-01-04
...
```

### `length=5000`

Ban đầu không truyền `length`.

Kết quả:

```text
VNINDEX: 100 dòng
```

Đây là dấu hiệu bất thường.

Vì giai đoạn nhiều năm không thể chỉ có 100 phiên giao dịch.

Ta thêm:

```python
length=5000
```

Kết quả:

```text
VNINDEX: 1998 dòng
```

## Bài học

Luôn kiểm tra:

```python
len(data)
```

Không được suy nghĩ:

> API chạy không lỗi nghĩa là dữ liệu đúng.

API có thể trả:

```text
100 dòng
```

mà vẫn không báo exception.

Đó là lý do phải kiểm tra số lượng quan sát.

---

# 9. Kiểm tra dữ liệu rỗng

Code:

```python
if data is None or data.empty:
    raise ValueError("Không lấy được dữ liệu VNINDEX")
```

Tư duy:

```text
API request thành công
≠
dữ liệu hợp lệ
```

Có thể API:

```text
HTTP thành công
↓
DataFrame rỗng
```

Nếu không kiểm tra, code tiếp tục chạy:

```python
data["time"]
```

và lỗi ở vị trí khác.

Việc raise lỗi sớm giúp biết chính xác:

> nguồn VNINDEX không có dữ liệu.

---

# 10. Chuẩn hóa thời gian VN-Index

Dữ liệu VN-Index ban đầu có dạng:

```text
2018-01-02 07:00:00
```

Trong khi Yahoo Finance có dạng:

```text
2018-01-02 00:00:00
```

Nếu ghép trực tiếp:

```text
2018-01-02 00:00:00    Yahoo data
2018-01-02 07:00:00    VNINDEX data
```

Pandas xem đây là hai timestamp khác nhau.

Kết quả:

```text
                     VNINDEX  USD_VND   GOLD   OIL
2018-01-02 00:00:00      NaN   22384   1313   60
2018-01-02 07:00:00   995.77     NaN    NaN  NaN
```

Điều này cho thấy:

> cùng ngày nhưng không cùng timestamp.

Ta sửa:

```python
data["time"] = (
    pd.to_datetime(data["time"])
    .dt.normalize()
)
```

`normalize()` đưa:

```text
2018-01-02 07:00:00
```

về:

```text
2018-01-02 00:00:00
```

Sau đó các nguồn có thể ghép đúng theo ngày.

## Bài học

Khi merge dữ liệu nhiều nguồn:

> Kiểm tra timezone và timestamp trước khi kiểm tra giá trị.

Rất nhiều lỗi merge tài chính không nằm ở ticker.

Nó nằm ở:

```text
time
timezone
date format
```

---

# 11. Chuyển DataFrame thành Series

Code:

```python
series = data.set_index("time")["close"]
```

DataFrame ban đầu:

```text
time
open
high
low
close
volume
```

Ta chỉ cần:

```text
time → index
close → value
```

Kết quả:

```text
2018-01-02    995.77
2018-01-03   1005.67
...
```

Đây là `pd.Series`.

Tư duy:

> Mỗi biến nghiên cứu nên được chuẩn hóa thành một chuỗi giá theo thời gian.

Tất cả hàm tải dữ liệu cuối cùng đều trả:

```python
pd.Series
```

Ví dụ:

```text
VNINDEX Series
USD_VND Series
GOLD Series
OIL Series
```

Nhờ đó bước merge phía sau rất đơn giản.

---

# 12. Đặt tên Series

Code:

```python
series.name = "VNINDEX"
```

Điều này rất quan trọng.

Khi tạo:

```python
pd.DataFrame(prices)
```

ta muốn cột là:

```text
VNINDEX
USD_VND
GOLD
OIL
```

Không phải:

```text
Close
Close
Close
Close
```

Tên biến phải phản ánh ý nghĩa nghiên cứu.

---

# 13. Hàm lấy dữ liệu Yahoo Finance

Code:

```python
def download_yahoo(ticker: str, name: str) -> pd.Series:
    print(f"Đang lấy {name}: {ticker}")

    data = yf.download(
        ticker,
        start=START_DATE,
        end=END_DATE,
        auto_adjust=False,
        progress=False,
    )

    if data.empty:
        raise ValueError(
            f"Không lấy được dữ liệu {name} ({ticker})"
        )

    series = data["Close"].squeeze()

    series.index = pd.to_datetime(series.index)
    series.name = name

    print(f"✅ {name}: {len(series)} dòng")

    return series
```

---

# 14. Tại sao viết một hàm chung cho Yahoo?

Ba biến:

```text
USD/VND
GOLD
OIL
```

đều có cùng logic:

```text
ticker
↓
yf.download()
↓
Close
↓
Series
```

Nếu viết riêng:

```python
download_usd()
download_gold()
download_oil()
```

thì 3 hàm gần như giống nhau.

Ta tạo abstraction:

```python
download_yahoo(ticker, name)
```

Ví dụ:

```python
download_yahoo(
    ticker="VND=X",
    name="USD_VND",
)
```

hoặc:

```python
download_yahoo(
    ticker="GC=F",
    name="GOLD",
)
```

## Tư duy

Khi các biến khác nhau về dữ liệu nhưng giống nhau về quy trình:

> Viết một hàm tổng quát và truyền cấu hình vào.

---

# 15. `yf.download()` làm gì?

Code:

```python
data = yf.download(
    ticker,
    start=START_DATE,
    end=END_DATE,
    auto_adjust=False,
    progress=False,
)
```

### `ticker`

Mã tài sản.

Ví dụ:

```text
VND=X
GC=F
CL=F
```

### `start`

Ngày bắt đầu.

### `end`

Ngày kết thúc.

### `auto_adjust=False`

Giữ dữ liệu giá chưa tự động điều chỉnh bởi `yfinance`.

Trong project, ta chủ động lấy cột:

```text
Close
```

### `progress=False`

Ẩn progress bar.

Mục đích:

> log pipeline sạch hơn.

---

# 16. Tại sao dùng `Close`?

Code:

```python
series = data["Close"].squeeze()
```

Ta cần một mức giá đại diện cho mỗi phiên.

Project chọn:

```text
Close
```

Lý do:

1. Giá đóng cửa thường được sử dụng khi tính return lịch sử.
2. Ta sẽ lấy giá cuối tháng.
3. Đơn giản và dễ tái lập.

## `squeeze()` là gì?

Trong một số phiên bản dữ liệu Yahoo, đoạn:

```python
data["Close"]
```

có thể trả về cấu trúc gần DataFrame một cột.

`squeeze()` ép về:

```python
pd.Series
```

Mục tiêu cuối cùng:

```text
1 biến = 1 Series
```

---

# 17. Hàm `main()` bắt đầu pipeline

Code:

```python
def main() -> None:
    DATA_DIR.mkdir(exist_ok=True)

    prices = {
        "VNINDEX": download_vnindex()
    }

    for name, ticker in TICKERS.items():
        prices[name] = download_yahoo(
            ticker=ticker,
            name=name,
        )
```

## Tư duy

Đầu tiên tạo thư mục:

```python
DATA_DIR.mkdir(exist_ok=True)
```

Nếu `data/` chưa tồn tại:

```text
tạo data/
```

Nếu đã tồn tại:

```text
không lỗi
```

---

# 18. Dictionary `prices`

Sau khi tải xong:

```python
prices = {
    "VNINDEX": <Series>,
    "USD_VND": <Series>,
    "GOLD": <Series>,
    "OIL": <Series>,
}
```

Tư duy:

> Trước khi merge, lưu các biến thành dictionary tên → chuỗi thời gian.

Điều này giúp dễ debug.

Ví dụ:

```python
print(prices["VNINDEX"])
print(prices["GOLD"])
```

---

# 19. Ghép dữ liệu

Code:

```python
df = pd.DataFrame(prices)
```

Pandas sử dụng index thời gian của từng Series để ghép.

Ví dụ:

```text
VNINDEX:
2018-01-02    995.77
2018-01-03   1005.67

GOLD:
2018-01-02   1313.70
2018-01-03   1316.20
```

Kết quả:

```text
            VNINDEX    GOLD
2018-01-02   995.77  1313.70
2018-01-03  1005.67  1316.20
```

## Tư duy

Ta merge theo:

```text
DATE INDEX
```

Không merge theo số thứ tự dòng.

Sai:

```text
dòng 1 VNINDEX
ghép với
dòng 1 GOLD
```

Đúng:

```text
VNINDEX ngày 2018-01-02
ghép với
GOLD ngày 2018-01-02
```

---

# 20. Tại sao dữ liệu ngày vẫn có NaN?

Ngay cả khi chuẩn hóa timestamp, vẫn có thể có:

```text
NaN
```

Lý do:

```text
VNINDEX giao dịch tại Việt Nam
Gold Futures giao dịch quốc tế
Oil Futures giao dịch quốc tế
Forex có lịch dữ liệu khác
```

Ví dụ:

```text
Việt Nam nghỉ lễ
↓
VNINDEX không có dữ liệu

Nhưng
↓
Gold hoặc Oil vẫn giao dịch
```

Do đó dữ liệu ngày không hoàn toàn trùng nhau.

## Bài học

Không nên giả định:

> tất cả thị trường có cùng lịch giao dịch.

---

# 21. Tại sao chuyển dữ liệu ngày sang tháng?

Code:

```python
monthly = df.resample("ME").last()
```

`ME`:

```text
Month End
```

Ta nhóm toàn bộ dữ liệu theo tháng.

Sau đó:

```text
lấy giá cuối cùng có trong tháng
```

Ví dụ:

```text
2018-01-29    1100
2018-01-30    1110
2018-01-31    1120
```

Kết quả tháng 1:

```text
2018-01-31    1120
```

## Tại sao dùng dữ liệu tháng?

### Lý do 1: Đúng scope bài nghiên cứu

Project phân tích mối quan hệ trung hạn theo tháng.

### Lý do 2: Giảm khác biệt lịch giao dịch

Dữ liệu ngày:

```text
VNINDEX nghỉ
Gold chạy
Oil chạy
```

Dữ liệu tháng:

```text
mỗi biến có 1 giá cuối tháng
```

Dễ đồng bộ hơn.

### Lý do 3: Giảm nhiễu

Return ngày có thể biến động rất mạnh bởi tin tức ngắn hạn.

Return tháng phù hợp hơn với một bài OLS cơ bản.

---

# 22. `interval="1D"` nhưng tại sao chỉ còn 95 quan sát?

Đây là điểm dễ gây nhầm.

`interval="1D"` chỉ nói:

> dữ liệu đầu vào được lấy theo ngày.

Sau đó:

```python
monthly = df.resample("ME").last()
```

đã chuyển thành dữ liệu tháng.

Flow:

```text
1998 phiên VNINDEX
        ↓
resample("ME")
        ↓
96 tháng
```

Giai đoạn:

```text
01/2018 → 12/2025
```

Có:

```text
8 × 12 = 96 tháng
```

Sau đó tính return:

```python
returns = monthly.pct_change()
```

Tháng đầu tiên không có tháng trước.

Ví dụ:

```text
01/2018 → không tính được return
02/2018 → so với 01/2018
```

Do đó:

```text
96 tháng
-
1 tháng đầu
=
95 quan sát
```

Đây là lý do dataset cuối có:

```text
95 observations
```

---

# 23. Tính return

Code:

```python
returns = monthly.pct_change()
```

Ví dụ:

```text
VNINDEX tháng 1 = 1000
VNINDEX tháng 2 = 1050
```

Python tính:

```text
1050 / 1000 - 1
=
0.05
```

Tức:

```text
5%
```

Kết quả lưu trong dữ liệu là:

```text
0.05
```

Không phải:

```text
5
```

## Tư duy khi diễn giải OLS

Nếu:

```text
USD_VND_RETURN = 0.01
```

nghĩa là:

```text
USD/VND tăng 1%
```

Nếu hệ số OLS:

```text
-1.46
```

thì tác động ước lượng:

```text
-1.46 × 0.01
=
-0.0146
```

tức khoảng:

```text
-1.46%
```

---

# 24. Đổi tên cột return

Code:

```python
returns.columns = [
    f"{column}_RETURN"
    for column in returns.columns
]
```

Trước:

```text
VNINDEX
USD_VND
GOLD
OIL
```

Sau:

```text
VNINDEX_RETURN
USD_VND_RETURN
GOLD_RETURN
OIL_RETURN
```

## Tại sao?

Để tránh nhầm:

```text
VNINDEX
```

là mức điểm chỉ số.

Trong dataset cuối:

```text
VNINDEX_RETURN
```

là tỷ suất sinh lợi.

Tên biến phải thể hiện đúng dữ liệu.

---

# 25. Xóa dữ liệu thiếu

Code:

```python
returns = returns.dropna()
```

Sau `pct_change()`, dòng đầu tiên chắc chắn là:

```text
NaN
```

Ngoài ra có thể có tháng thiếu dữ liệu.

Ta chỉ giữ những dòng mà mô hình có đủ:

```text
Y
X1
X2
X3
```

## Tư duy OLS

Một observation cần đủ:

```text
VNINDEX_RETURN
USD_VND_RETURN
GOLD_RETURN
OIL_RETURN
```

Nếu thiếu một biến:

```text
không thể dùng observation đó cho mô hình hiện tại
```

---

# 26. Reset index

Code:

```python
returns = returns.reset_index()
```

Trước:

```text
index = Date
```

Sau:

```text
Date trở thành một cột
```

Ví dụ:

```text
       Date  VNINDEX_RETURN ...
2018-02-28         0.010069
```

Điều này giúp xuất CSV rõ ràng hơn.

---

# 27. Đổi tên cột thời gian thành `month`

Code:

```python
returns.rename(
    columns={
        returns.columns[0]: "month"
    },
    inplace=True,
)
```

Ta không phụ thuộc cứng vào tên:

```text
Date
time
index
```

Ta lấy cột đầu tiên sau `reset_index()` và đổi thành:

```text
month
```

Dataset cuối:

```text
month
VNINDEX_RETURN
USD_VND_RETURN
GOLD_RETURN
OIL_RETURN
```

---

# 28. Xuất CSV

Code:

```python
returns.to_csv(
    OUTPUT_FILE,
    index=False,
)
```

File:

```text
data/return_data.csv
```

Ví dụ:

```text
month,VNINDEX_RETURN,USD_VND_RETURN,GOLD_RETURN,OIL_RETURN
2018-02-28,0.010069,0.002515,-0.017550,-0.047737
2018-03-31,0.047185,0.001769,0.005549,0.053537
```

## Tại sao dùng CSV?

Python làm:

```text
Data Collection
Data Processing
```

R làm:

```text
Econometric Analysis
```

CSV là lớp trung gian:

```text
Python
↓
CSV
↓
R
```

Lợi ích:

1. Dễ kiểm tra bằng Excel.
2. R đọc trực tiếp.
3. Dễ commit Git.
4. Dễ tái lập kết quả.
5. Tách data pipeline khỏi model pipeline.

---

# 29. Flow code hoàn chỉnh

```text
START_DATE / END_DATE
        ↓
Xác định khoảng nghiên cứu
        ↓
download_vnindex()
        ↓
vnstock
        ↓
VNINDEX close daily Series
        │
        │
        ├────────────────────────┐
        │                        │
download_yahoo()                 │
        ↓                        │
USD/VND Series                   │
Gold Series                      │
Oil Series                       │
        │                        │
        └────────────┬───────────┘
                     ↓
             pd.DataFrame(prices)
                     ↓
            Merge theo Date Index
                     ↓
             Dữ liệu giá theo ngày
                     ↓
           resample("ME").last()
                     ↓
             Giá cuối mỗi tháng
                     ↓
                pct_change()
                     ↓
              Return theo tháng
                     ↓
               rename columns
                     ↓
                  dropna()
                     ↓
                reset_index()
                     ↓
              đổi Date → month
                     ↓
              return_data.csv
                     ↓
                     R
```

---

# 30. Các bước kiểm tra bắt buộc khi lấy dữ liệu

Một người mới thường chỉ kiểm tra:

```text
code có lỗi hay không
```

Cách tư duy đúng phải kiểm tra ít nhất 5 điểm.

## 30.1. Kiểm tra DataFrame có rỗng không

```python
if data.empty:
    raise ValueError(...)
```

## 30.2. Kiểm tra số dòng

```python
print(len(series))
```

Ví dụ:

```text
100 dòng cho 8 năm
```

là bất thường.

## 30.3. Kiểm tra khoảng ngày

```python
print(series.index.min())
print(series.index.max())
```

Ví dụ yêu cầu:

```text
2018–2025
```

nhưng data trả:

```text
2025-08 → 2025-12
```

thì không đạt.

## 30.4. Kiểm tra timestamp

```python
print(series.index[:5])
```

Tìm lỗi:

```text
00:00:00
vs
07:00:00
```

## 30.5. Kiểm tra số quan sát cuối

```python
print(len(returns))
```

Sau đó tính logic bằng tay:

```text
2018–2025
=
96 tháng

return
=
95 observations
```

Nếu code trả:

```text
11 observations
```

phải dừng lại kiểm tra.

---

# 31. Những lỗi đã gặp và bài học

## Lỗi 1: Yahoo không lấy được VNINDEX

Ticker:

```text
^VNINDEX.VN
```

Kết quả:

```text
possibly delisted
no price data found
```

### Bài học

Đổi nguồn dữ liệu.

Không cố sửa mô hình để phù hợp với nguồn lỗi.

---

## Lỗi 2: VNINDEX chỉ có 100 dòng

API chạy thành công.

Nhưng:

```text
100 rows
```

### Bài học

API không lỗi chưa chắc data đúng.

Phải kiểm tra:

```text
row count
date range
```

---

## Lỗi 3: Timestamp lệch 7 tiếng

VNINDEX:

```text
2018-01-02 07:00:00
```

Yahoo:

```text
2018-01-02 00:00:00
```

### Bài học

Chuẩn hóa datetime trước merge.

Giải pháp:

```python
.dt.normalize()
```

---

## Lỗi 4: Hiểu nhầm `1D` nghĩa là OLS dùng dữ liệu ngày

Code:

```python
interval="1D"
```

nhưng pipeline sau đó:

```python
resample("ME").last()
```

### Bài học

Phải nhìn toàn bộ pipeline.

Tần suất dữ liệu đầu vào không nhất thiết là tần suất dataset cuối.

---

# 32. Yêu cầu trả lời

## Câu 1

Biến nghiên cứu là gì?

Ví dụ:

```text
VNINDEX_RETURN
```

## Câu 2

Muốn tính biến đó cần dữ liệu gốc gì?

```text
VNINDEX close price
```

## Câu 3

Nguồn nào có dữ liệu?

```text
vnstock
```

## Câu 4

Dữ liệu gốc có tần suất gì?

```text
Daily
```

## Câu 5

Mô hình cần tần suất gì?

```text
Monthly
```

## Câu 6

Chuyển daily sang monthly như thế nào?

```text
Last price of month
```

## Câu 7

Từ price sang return thế nào?

```text
pct_change()
```

## Câu 8

Các biến đã cùng timeline chưa?

```text
Check date range
```

## Câu 9

Có missing data không?

```text
Check NaN
```

## Câu 10

Số quan sát cuối có hợp lý không?

```text
96 months
→ 95 returns
```

Nếu trả lời được 10 câu này thì mới bắt đầu viết pipeline.

---

# 33. Tư duy tổng quát để áp dụng cho project khác

Flow này không chỉ dùng cho VN-Index.

Ví dụ nghiên cứu:

> Tác động của Bitcoin và vàng đến S&P 500.

Ta đổi:

```text
Y = SP500_RETURN
X1 = BTC_RETURN
X2 = GOLD_RETURN
```

Pipeline vẫn là:

```text
xác định ticker
↓
download price
↓
chuẩn hóa datetime
↓
merge
↓
resample
↓
pct_change
↓
dropna
↓
export
```

Ví dụ nghiên cứu cổ phiếu ngân hàng:

```text
VCB
MBB
TCB
CTG
```

Flow vẫn có thể tái sử dụng.

Điểm cốt lõi không phải `yfinance` hay `vnstock`.

Điểm cốt lõi là:

> Chuẩn hóa tất cả dữ liệu về cùng một cấu trúc thời gian trước khi xây mô hình.

---

# 34. Checklist trước khi chuyển dữ liệu sang R

Trước khi chạy:

```text
Rscript.exe main.R
```

phải kiểm tra:

```text
[ ] Đúng biến nghiên cứu
[ ] Đúng ticker
[ ] Đúng nguồn dữ liệu
[ ] Data không rỗng
[ ] Số dòng dữ liệu gốc hợp lý
[ ] Khoảng ngày đúng
[ ] Datetime đã chuẩn hóa
[ ] Các chuỗi đã merge theo date
[ ] Đã chuyển về dữ liệu tháng
[ ] Đã tính return
[ ] Không còn NA trong dataset mô hình
[ ] Tên cột rõ ràng
[ ] Số observation hợp lý
[ ] CSV đã được xuất
```

---

# 35. Kết luận tư duy của `get_data.py`

Có thể tóm tắt toàn bộ tư duy bằng 5 từ:

```text
DEFINE
SOURCE
STANDARDIZE
TRANSFORM
VALIDATE
```

## DEFINE

Xác định biến cần nghiên cứu.

```text
Y
X1
X2
X3
```

## SOURCE

Chọn nguồn dữ liệu phù hợp.

```text
vnstock
yfinance
```

## STANDARDIZE

Chuẩn hóa dữ liệu.

```text
datetime
index
column names
```

## TRANSFORM

Biến đổi dữ liệu thành dạng mô hình cần.

```text
daily
↓
monthly
↓
return
```

## VALIDATE

Kiểm tra dữ liệu.

```text
row count
date range
NaN
observations
```