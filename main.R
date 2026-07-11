# ============================================================
# PROJECT:
# PHÂN TÍCH TÁC ĐỘNG CỦA USD/VND, GIÁ VÀNG VÀ GIÁ DẦU
# ĐẾN TỶ SUẤT SINH LỢI VN-INDEX BẰNG MÔ HÌNH OLS
#
# GIAI ĐOẠN: 2018 - 2025
# ============================================================


# ============================================================
# 1. LOAD PACKAGES
# ============================================================

library(car)
library(lmtest)


# ============================================================
# 2. CẤU HÌNH ĐƯỜNG DẪN
# ============================================================

DATA_FILE <- "data/return_data.csv"

OUTPUT_DIR <- "output"

dir.create(
  OUTPUT_DIR,
  showWarnings = FALSE
)


# ============================================================
# 3. ĐỌC DỮ LIỆU
# ============================================================

data <- read.csv(
  DATA_FILE,
  stringsAsFactors = FALSE
)

cat("\n")
cat("============================================================\n")
cat("1. ĐỌC DỮ LIỆU\n")
cat("============================================================\n")

cat("\nSố dòng:", nrow(data), "\n")
cat("Số cột:", ncol(data), "\n")


# ============================================================
# 4. XỬ LÝ CỘT THỜI GIAN
# ============================================================

data$month <- as.Date(data$month)

data <- data[
  order(data$month),
]


# ============================================================
# 5. KIỂM TRA DỮ LIỆU
# ============================================================

cat("\n")
cat("============================================================\n")
cat("2. KIỂM TRA DỮ LIỆU\n")
cat("============================================================\n")

cat("\n5 dòng đầu:\n")
print(head(data))

cat("\n5 dòng cuối:\n")
print(tail(data))

cat("\nCấu trúc dữ liệu:\n")
str(data)

cat("\nSố giá trị NA:\n")
print(colSums(is.na(data)))


# ============================================================
# 6. KHAI BÁO CÁC BIẾN NGHIÊN CỨU
# ============================================================

variables <- data[
  c(
    "VNINDEX_RETURN",
    "USD_VND_RETURN",
    "GOLD_RETURN",
    "OIL_RETURN"
  )
]


# ============================================================
# 7. THỐNG KÊ MÔ TẢ
# ============================================================

cat("\n")
cat("============================================================\n")
cat("3. THỐNG KÊ MÔ TẢ\n")
cat("============================================================\n")

print(summary(variables))


descriptive_statistics <- data.frame(
  Variable = names(variables),

  N = sapply(
    variables,
    function(x) sum(!is.na(x))
  ),

  Mean = sapply(
    variables,
    mean,
    na.rm = TRUE
  ),

  Median = sapply(
    variables,
    median,
    na.rm = TRUE
  ),

  Std_Dev = sapply(
    variables,
    sd,
    na.rm = TRUE
  ),

  Min = sapply(
    variables,
    min,
    na.rm = TRUE
  ),

  Max = sapply(
    variables,
    max,
    na.rm = TRUE
  )
)

rownames(descriptive_statistics) <- NULL

cat("\nBảng thống kê mô tả:\n")

print(
  descriptive_statistics,
  digits = 6
)


write.csv(
  descriptive_statistics,
  file.path(
    OUTPUT_DIR,
    "descriptive_statistics.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 8. MA TRẬN TƯƠNG QUAN
# ============================================================

cat("\n")
cat("============================================================\n")
cat("4. MA TRẬN TƯƠNG QUAN\n")
cat("============================================================\n")

correlation_matrix <- cor(
  variables,
  use = "complete.obs",
  method = "pearson"
)

print(
  round(
    correlation_matrix,
    4
  )
)

write.csv(
  correlation_matrix,
  file.path(
    OUTPUT_DIR,
    "correlation_matrix.csv"
  ),
  row.names = TRUE
)


# ============================================================
# 9. VẼ VN-INDEX RETURN THEO THỜI GIAN
# ============================================================

png(
  file.path(
    OUTPUT_DIR,
    "vnindex_return.png"
  ),
  width = 1400,
  height = 800
)

plot(
  data$month,
  data$VNINDEX_RETURN,
  type = "l",
  main = "Monthly Return of VN-Index",
  xlab = "Time",
  ylab = "VN-Index Return"
)

abline(
  h = 0,
  lty = 2
)

dev.off()


# ============================================================
# 10. HISTOGRAM VN-INDEX RETURN
# ============================================================

png(
  file.path(
    OUTPUT_DIR,
    "vnindex_return_histogram.png"
  ),
  width = 1200,
  height = 800
)

hist(
  data$VNINDEX_RETURN,
  breaks = 20,
  main = "Distribution of VN-Index Return",
  xlab = "VN-Index Return"
)

dev.off()


# ============================================================
# 11. XÂY DỰNG MÔ HÌNH OLS
# ============================================================

cat("\n")
cat("============================================================\n")
cat("5. MÔ HÌNH HỒI QUY OLS\n")
cat("============================================================\n")

model <- lm(
  VNINDEX_RETURN ~
    USD_VND_RETURN +
    GOLD_RETURN +
    OIL_RETURN,
  data = data
)

model_summary <- summary(model)

print(model_summary)


# ============================================================
# 12. PHƯƠNG TRÌNH HỒI QUY
# ============================================================

coefficients_model <- coef(model)

intercept <- coefficients_model[
  "(Intercept)"
]

beta_usd <- coefficients_model[
  "USD_VND_RETURN"
]

beta_gold <- coefficients_model[
  "GOLD_RETURN"
]

beta_oil <- coefficients_model[
  "OIL_RETURN"
]

cat("\n")
cat("PHƯƠNG TRÌNH HỒI QUY ƯỚC LƯỢNG:\n\n")

cat(
  "VNINDEX_RETURN =",
  round(intercept, 6),
  ifelse(beta_usd >= 0, "+", "-"),
  abs(round(beta_usd, 6)),
  "* USD_VND_RETURN",
  ifelse(beta_gold >= 0, "+", "-"),
  abs(round(beta_gold, 6)),
  "* GOLD_RETURN",
  ifelse(beta_oil >= 0, "+", "-"),
  abs(round(beta_oil, 6)),
  "* OIL_RETURN\n"
)


# ============================================================
# 13. TRÍCH XUẤT BẢNG HỆ SỐ
# ============================================================

coefficient_table <- data.frame(
  Variable = rownames(
    model_summary$coefficients
  ),

  Estimate = model_summary$coefficients[
    ,
    "Estimate"
  ],

  Std_Error = model_summary$coefficients[
    ,
    "Std. Error"
  ],

  T_Value = model_summary$coefficients[
    ,
    "t value"
  ],

  P_Value = model_summary$coefficients[
    ,
    "Pr(>|t|)"
  ]
)

rownames(coefficient_table) <- NULL


coefficient_table$Significance <- ifelse(
  coefficient_table$P_Value < 0.01,
  "***",

  ifelse(
    coefficient_table$P_Value < 0.05,
    "**",

    ifelse(
      coefficient_table$P_Value < 0.10,
      "*",
      ""
    )
  )
)

cat("\nBẢNG HỆ SỐ HỒI QUY:\n")

print(
  coefficient_table,
  digits = 6
)


write.csv(
  coefficient_table,
  file.path(
    OUTPUT_DIR,
    "ols_coefficients.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 14. CHỈ TIÊU ĐÁNH GIÁ MÔ HÌNH
# ============================================================

r_squared <- model_summary$r.squared

adjusted_r_squared <-
  model_summary$adj.r.squared

f_statistic <-
  model_summary$fstatistic[1]

f_df1 <-
  model_summary$fstatistic[2]

f_df2 <-
  model_summary$fstatistic[3]

f_p_value <- pf(
  f_statistic,
  f_df1,
  f_df2,
  lower.tail = FALSE
)


model_statistics <- data.frame(
  Statistic = c(
    "R-squared",
    "Adjusted R-squared",
    "F-statistic",
    "F p-value",
    "Residual Std Error"
  ),

  Value = c(
    r_squared,
    adjusted_r_squared,
    f_statistic,
    f_p_value,
    model_summary$sigma
  )
)

cat("\n")
cat("THỐNG KÊ MÔ HÌNH:\n")

print(
  model_statistics,
  digits = 6
)


write.csv(
  model_statistics,
  file.path(
    OUTPUT_DIR,
    "model_statistics.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 15. KIỂM TRA ĐA CỘNG TUYẾN - VIF
# ============================================================

cat("\n")
cat("============================================================\n")
cat("6. KIỂM TRA ĐA CỘNG TUYẾN - VIF\n")
cat("============================================================\n")

vif_result <- vif(model)

print(vif_result)


vif_table <- data.frame(
  Variable = names(vif_result),
  VIF = as.numeric(vif_result)
)


write.csv(
  vif_table,
  file.path(
    OUTPUT_DIR,
    "vif_result.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 16. KIỂM ĐỊNH PHƯƠNG SAI THAY ĐỔI
# BREUSCH-PAGAN
# ============================================================

cat("\n")
cat("============================================================\n")
cat("7. BREUSCH-PAGAN TEST\n")
cat("============================================================\n")

bp_test <- bptest(model)

print(bp_test)


bp_result <- data.frame(
  Test = "Breusch-Pagan",
  Statistic = as.numeric(
    bp_test$statistic
  ),
  DF = as.numeric(
    bp_test$parameter
  ),
  P_Value = bp_test$p.value
)


write.csv(
  bp_result,
  file.path(
    OUTPUT_DIR,
    "breusch_pagan_test.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 17. KIỂM ĐỊNH TỰ TƯƠNG QUAN
# DURBIN-WATSON
# ============================================================

cat("\n")
cat("============================================================\n")
cat("8. DURBIN-WATSON TEST\n")
cat("============================================================\n")

dw_test <- dwtest(model)

print(dw_test)


dw_result <- data.frame(
  Test = "Durbin-Watson",
  Statistic = as.numeric(
    dw_test$statistic
  ),
  P_Value = dw_test$p.value
)


write.csv(
  dw_result,
  file.path(
    OUTPUT_DIR,
    "durbin_watson_test.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 18. KIỂM ĐỊNH PHÂN PHỐI CHUẨN CỦA PHẦN DƯ
# SHAPIRO-WILK
# ============================================================

cat("\n")
cat("============================================================\n")
cat("9. SHAPIRO-WILK TEST\n")
cat("============================================================\n")

shapiro_test <- shapiro.test(
  residuals(model)
)

print(shapiro_test)


shapiro_result <- data.frame(
  Test = "Shapiro-Wilk",
  Statistic = as.numeric(
    shapiro_test$statistic
  ),
  P_Value = shapiro_test$p.value
)


write.csv(
  shapiro_result,
  file.path(
    OUTPUT_DIR,
    "shapiro_test.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 19. Q-Q PLOT PHẦN DƯ
# ============================================================

png(
  file.path(
    OUTPUT_DIR,
    "residual_qq_plot.png"
  ),
  width = 1200,
  height = 800
)

qqnorm(
  residuals(model),
  main = "Q-Q Plot of OLS Residuals"
)

qqline(
  residuals(model)
)

dev.off()


# ============================================================
# 20. RESIDUAL VS FITTED
# ============================================================

png(
  file.path(
    OUTPUT_DIR,
    "residual_vs_fitted.png"
  ),
  width = 1200,
  height = 800
)

plot(
  fitted(model),
  residuals(model),
  main = "Residuals vs Fitted Values",
  xlab = "Fitted Values",
  ylab = "Residuals"
)

abline(
  h = 0,
  lty = 2
)

dev.off()


# ============================================================
# 21. HỆ SỐ VỚI ROBUST STANDARD ERROR
# ============================================================

cat("\n")
cat("============================================================\n")
cat("10. ROBUST STANDARD ERROR - HC1\n")
cat("============================================================\n")

robust_result <- coeftest(
  model,
  vcov. = sandwich::vcovHC(
    model,
    type = "HC1"
  )
)

print(robust_result)


robust_table <- data.frame(
  Variable = rownames(
    robust_result
  ),

  Estimate = robust_result[
    ,
    1
  ],

  Robust_Std_Error = robust_result[
    ,
    2
  ],

  T_Value = robust_result[
    ,
    3
  ],

  P_Value = robust_result[
    ,
    4
  ]
)

rownames(robust_table) <- NULL


write.csv(
  robust_table,
  file.path(
    OUTPUT_DIR,
    "robust_standard_errors.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 22. DIỄN GIẢI TỰ ĐỘNG CÁC BIẾN
# ============================================================

cat("\n")
cat("============================================================\n")
cat("11. DIỄN GIẢI KẾT QUẢ\n")
cat("============================================================\n")


interpret_variable <- function(
    variable_name,
    coefficient,
    p_value
) {

  direction <- ifelse(
    coefficient > 0,
    "cùng chiều",
    "ngược chiều"
  )

  if (p_value < 0.01) {

    significance <-
      "có ý nghĩa thống kê ở mức 1%"

  } else if (p_value < 0.05) {

    significance <-
      "có ý nghĩa thống kê ở mức 5%"

  } else if (p_value < 0.10) {

    significance <-
      "có ý nghĩa thống kê ở mức 10%"

  } else {

    significance <-
      "không có ý nghĩa thống kê"

  }

  cat(
    "\n",
    variable_name,
    ": hệ số =",
    round(coefficient, 6),
    "- tác động",
    direction,
    "và",
    significance,
    ".\n"
  )
}


interpret_variable(
  "USD/VND",
  beta_usd,
  coefficient_table$P_Value[
    coefficient_table$Variable ==
      "USD_VND_RETURN"
  ]
)


interpret_variable(
  "GOLD",
  beta_gold,
  coefficient_table$P_Value[
    coefficient_table$Variable ==
      "GOLD_RETURN"
  ]
)


interpret_variable(
  "OIL",
  beta_oil,
  coefficient_table$P_Value[
    coefficient_table$Variable ==
      "OIL_RETURN"
  ]
)


# ============================================================
# 23. LƯU TOÀN BỘ KẾT QUẢ TEXT
# ============================================================

RESULT_FILE <- file.path(
  OUTPUT_DIR,
  "ols_full_result.txt"
)


sink(
  RESULT_FILE
)


cat(
  "PHÂN TÍCH TÁC ĐỘNG CỦA CÁC YẾU TỐ THỊ TRƯỜNG\n"
)

cat(
  "ĐẾN TỶ SUẤT SINH LỢI VN-INDEX\n"
)

cat(
  "GIAI ĐOẠN 2018 - 2025\n"
)

cat(
  "============================================================\n\n"
)


cat("SỐ QUAN SÁT\n")

cat(
  nrow(data),
  "\n\n"
)


cat(
  "============================================================\n"
)

cat(
  "THỐNG KÊ MÔ TẢ\n"
)

cat(
  "============================================================\n"
)

print(
  descriptive_statistics,
  digits = 6
)


cat("\n")

cat(
  "============================================================\n"
)

cat(
  "MA TRẬN TƯƠNG QUAN\n"
)

cat(
  "============================================================\n"
)

print(
  round(
    correlation_matrix,
    4
  )
)


cat("\n")

cat(
  "============================================================\n"
)

cat(
  "KẾT QUẢ HỒI QUY OLS\n"
)

cat(
  "============================================================\n"
)

print(
  summary(model)
)


cat("\n")

cat(
  "============================================================\n"
)

cat(
  "VIF\n"
)

cat(
  "============================================================\n"
)

print(
  vif_result
)


cat("\n")

cat(
  "============================================================\n"
)

cat(
  "BREUSCH-PAGAN TEST\n"
)

cat(
  "============================================================\n"
)

print(
  bp_test
)


cat("\n")

cat(
  "============================================================\n"
)

cat(
  "DURBIN-WATSON TEST\n"
)

cat(
  "============================================================\n"
)

print(
  dw_test
)


cat("\n")

cat(
  "============================================================\n"
)

cat(
  "SHAPIRO-WILK TEST\n"
)

cat(
  "============================================================\n"
)

print(
  shapiro_test
)


cat("\n")

cat(
  "============================================================\n"
)

cat(
  "ROBUST STANDARD ERROR\n"
)

cat(
  "============================================================\n"
)

print(
  robust_result
)


sink()


# ============================================================
# 24. HOÀN THÀNH
# ============================================================

cat("\n")
cat("============================================================\n")
cat("HOÀN THÀNH PHÂN TÍCH\n")
cat("============================================================\n")

cat("\nCác file đã xuất:\n")

cat(
  "- output/descriptive_statistics.csv\n"
)

cat(
  "- output/correlation_matrix.csv\n"
)

cat(
  "- output/ols_coefficients.csv\n"
)

cat(
  "- output/model_statistics.csv\n"
)

cat(
  "- output/vif_result.csv\n"
)

cat(
  "- output/breusch_pagan_test.csv\n"
)

cat(
  "- output/durbin_watson_test.csv\n"
)

cat(
  "- output/shapiro_test.csv\n"
)

cat(
  "- output/robust_standard_errors.csv\n"
)

cat(
  "- output/ols_full_result.txt\n"
)

cat(
  "- output/vnindex_return.png\n"
)

cat(
  "- output/vnindex_return_histogram.png\n"
)

cat(
  "- output/residual_qq_plot.png\n"
)

cat(
  "- output/residual_vs_fitted.png\n"
)

cat("\n✅ PHÂN TÍCH HOÀN TẤT\n")