from pathlib import Path

import pandas as pd
import yfinance as yf
from vnstock import Market


START_DATE = "2018-01-01"
END_DATE = "2025-12-31"

TICKERS = {
    "USD_VND": "VND=X",
    "GOLD": "GC=F",
    "OIL": "CL=F",
}

DATA_DIR = Path("data")
OUTPUT_FILE = DATA_DIR / "return_data.csv"


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

    print("VNINDEX columns:", data.columns.tolist())

    data["time"] = pd.to_datetime(data["time"]).dt.normalize()

    series = data.set_index("time")["close"]

    series.name = "VNINDEX"

    print(f"✅ VNINDEX: {len(series)} dòng")
    print(
        f"📅 VNINDEX: {series.index.min()} "
        f"-> {series.index.max()}"
    )

    return series

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

    # Ghép dữ liệu theo ngày
    df = pd.DataFrame(prices)

    # Chuyển sang dữ liệu tháng
    monthly = df.resample("ME").last()

    # Tính tỷ suất sinh lợi
    returns = monthly.pct_change()

    returns.columns = [
        f"{column}_RETURN"
        for column in returns.columns
    ]

    returns = returns.dropna()

    returns = returns.reset_index()

    returns.rename(
        columns={
            returns.columns[0]: "month"
        },
        inplace=True,
    )

    returns.to_csv(
        OUTPUT_FILE,
        index=False,
    )

    print("\n✅ HOÀN THÀNH")
    print(f"File: {OUTPUT_FILE}")

    print(f"\nSố quan sát: {len(returns)}")


if __name__ == "__main__":
    main()