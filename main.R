# ==========================================
# 1. CÀI PACKAGE NẾU CHƯA CÓ
# ==========================================

packages <- c(
  "car",
  "lmtest"
)

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}


# ==========================================
# 2. ĐỌC DỮ LIỆU
# ==========================================

data <- read.csv(
  "data/return_data.csv"
)

cat("\n===== 5 DÒNG ĐẦU =====\n")
print(head(data))

cat("\n===== CẤU TRÚC DỮ LIỆU =====\n")
str(data)


# ==========================================
# 3. THỐNG KÊ MÔ TẢ
# ==========================================

cat("\n===== THỐNG KÊ MÔ TẢ =====\n")

variables <- data[
  c(
    "VNINDEX_RETURN",
    "USD_VND_RETURN",
    "GOLD_RETURN",
    "OIL_RETURN"
  )
]

print(summary(variables))


# ==========================================
# 4. MA TRẬN TƯƠNG QUAN
# ==========================================

cat("\n===== MA TRẬN TƯƠNG QUAN =====\n")

correlation <- cor(
  variables,
  use = "complete.obs"
)

print(round(correlation, 4))


# ==========================================
# 5. XÂY DỰNG MÔ HÌNH OLS
# ==========================================

model <- lm(
  VNINDEX_RETURN ~
    USD_VND_RETURN +
    GOLD_RETURN +
    OIL_RETURN,
  data = data
)


# ==========================================
# 6. KẾT QUẢ HỒI QUY
# ==========================================

cat("\n===== KẾT QUẢ HỒI QUY OLS =====\n")

print(summary(model))


# ==========================================
# 7. KIỂM TRA ĐA CỘNG TUYẾN
# ==========================================

cat("\n===== KIỂM TRA ĐA CỘNG TUYẾN - VIF =====\n")

print(vif(model))


# ==========================================
# 8. KIỂM ĐỊNH PHƯƠNG SAI THAY ĐỔI
# BREUSCH-PAGAN TEST
# ==========================================

cat("\n===== BREUSCH-PAGAN TEST =====\n")

print(bptest(model))


# ==========================================
# 9. KIỂM ĐỊNH TỰ TƯƠNG QUAN
# DURBIN-WATSON TEST
# ==========================================

cat("\n===== DURBIN-WATSON TEST =====\n")

print(dwtest(model))


# ==========================================
# 10. LƯU KẾT QUẢ MÔ HÌNH
# ==========================================

dir.create(
  "output",
  showWarnings = FALSE
)

sink("output/ols_result.txt")

cat("===== KẾT QUẢ HỒI QUY OLS =====\n\n")
print(summary(model))

cat("\n===== VIF =====\n\n")
print(vif(model))

cat("\n===== BREUSCH-PAGAN TEST =====\n\n")
print(bptest(model))

cat("\n===== DURBIN-WATSON TEST =====\n\n")
print(dwtest(model))

sink()

cat(
  "\n✅ ĐÃ LƯU KẾT QUẢ: output/ols_result.txt\n"
)