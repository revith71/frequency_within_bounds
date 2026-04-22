library(lme4)
library(dplyr)
library(readxl)
library(writexl)

OUT_DIR <- "~/Desktop/GLMER"

clamp_p0 <- function(p) pmax(pmin(p, 0.99999), 0.00001)

fit_glmer_cell <- function(dat, suffix, property, p0_raw, baseline_label) {
  
  p0         <- clamp_p0(p0_raw)
  null_logit <- log(p0 / (1 - p0))
  clamped    <- (p0_raw <= 0.00001 | p0_raw >= 0.99999)
  
  dat$y <- dat[[if (property == "APU") "Response_apu" else "Response_pu"]]
  
  fit <- tryCatch(
    glmer(y ~ 1 + (1 | Subject) + (1 | Item),
          data   = dat,
          family = binomial(link = "logit")),
    error = function(e) {
      message(sprintf("ERROR – %s %s (%s): %s", suffix, property, baseline_label, e$message))
      NULL
    }
  )
  
  if (is.null(fit)) {
    return(data.frame(
      Suffix = suffix, Property = property, Baseline = baseline_label,
      p0_raw = p0_raw, p0_clamped = p0, clamped_flag = clamped,
      b0 = NA, SE = NA,
      CI_lower_logodds = NA, CI_upper_logodds = NA,
      null_logit = null_logit, null_in_CI = NA,
      z_stat = NA, p_value = NA,
      posterior_mean_p = NA, CI_lower_p = NA, CI_upper_p = NA,
      singular = NA
    ))
  }
  
  if (isSingular(fit))
    message(sprintf("singular fit – %s %s (%s)", suffix, property, baseline_label))
  
  coefs <- summary(fit)$coefficients
  b0    <- coefs["(Intercept)", "Estimate"]
  SE    <- coefs["(Intercept)", "Std. Error"]
  ci_lo <- b0 - 1.96 * SE
  ci_hi <- b0 + 1.96 * SE
  z_stat  <- (b0 - null_logit) / SE
  
  data.frame(
    Suffix           = suffix,
    Property         = property,
    Baseline         = baseline_label,
    p0_raw           = p0_raw,
    p0_clamped       = p0,
    clamped_flag     = clamped,
    b0               = b0,
    SE               = SE,
    CI_lower_logodds = ci_lo,
    CI_upper_logodds = ci_hi,
    null_logit       = null_logit,
    null_in_CI       = (null_logit >= ci_lo & null_logit <= ci_hi),
    z_stat           = z_stat,
    p_value          = 2 * (1 - pnorm(abs(z_stat))),
    posterior_mean_p = plogis(b0),
    CI_lower_p       = plogis(ci_lo),
    CI_upper_p       = plogis(ci_hi),
    singular         = isSingular(fit)
  )
}

run_group <- function(dat, baselines, group_label, baseline_label) {
  cat(sprintf("\n%s | %s\n", group_label, baseline_label))
  results <- vector("list", nrow(baselines))
  for (i in seq_len(nrow(baselines))) {
    row <- baselines[i, ]
    cat(sprintf("  %s %s  p0 = %.6f\n", row$Suffix, row$Property, row$p0))
    results[[i]] <- fit_glmer_cell(
      dat %>% filter(Suffix == row$Suffix),
      row$Suffix, row$Property, row$p0, baseline_label
    )
  }
  bind_rows(results)
}

# Adults – GreekLex 2 types

df_adults <- read_xlsx(file.path(OUT_DIR, "data_adults_glmer_dummies.xlsx"))

adults_type <- tribble(
  ~Suffix, ~Property, ~p0,
  "aF",  "APU", 0.2259,
  "aF",  "PU",  0.5810,
  "iF",  "APU", 0.6017,
  "iF",  "PU",  0.1576,
  "iN",  "APU", 0.009708738,
  "iN",  "PU",  0.9542,
  "isM", "APU", 0.011461318,
  "isM", "PU",  0.5415,
  "maN", "APU", 1.00000,   # clamped
  "maN", "PU",  0.00000,   # clamped
  "oN",  "APU", 0.6256,
  "oN",  "PU",  0.2650,
  "osM", "APU", 0.3565,
  "osM", "PU",  0.1682
)

res_adults_type <- run_group(df_adults, adults_type, "Adults", "GreekLex2_TYPE")
write_xlsx(res_adults_type, file.path(OUT_DIR, "GLMER_Results_Adults_TYPE.xlsx"))

# Grade 3 – HelexKids 2.0 types

df_grade3 <- read_xlsx(file.path(OUT_DIR, "data_children_grade3_glmer_dummies.xlsx"))

grade3_type <- tribble(
  ~Suffix, ~Property, ~p0,
  "aF",  "APU", 0.167155,
  "aF",  "PU",  0.671554,
  "iF",  "APU", 0.467742,
  "iF",  "PU",  0.225806,
  "iN",  "APU", 0.004167,
  "iN",  "PU",  0.987500,
  "isM", "APU", 0.055556,
  "isM", "PU",  0.666667,
  "maN", "APU", 0.999999,
  "maN", "PU",  0.000001,
  "oN",  "APU", 0.630952,
  "oN",  "PU",  0.297619,
  "osM", "APU", 0.573034,
  "osM", "PU",  0.140449
)

res_grade3_type <- run_group(df_grade3, grade3_type, "Grade3", "HelexKids2_TYPE")
write_xlsx(res_grade3_type, file.path(OUT_DIR, "GLMER_Results_Grade3_TYPE.xlsx"))

# Grade 6 – HelexKids 2.0 types

df_grade6 <- read_xlsx(file.path(OUT_DIR, "data_children_grade6_glmer_dummies.xlsx"))

grade6_type <- tribble(
  ~Suffix, ~Property, ~p0,
  "aF",  "APU", 0.154499,
  "aF",  "PU",  0.694397,
  "iF",  "APU", 0.584726,
  "iF",  "PU",  0.183771,
  "iN",  "APU", 0.011696,
  "iN",  "PU",  0.982456,
  "isM", "APU", 0.053476,
  "isM", "PU",  0.647059,
  "maN", "APU", 0.999999,
  "maN", "PU",  0.000001,
  "oN",  "APU", 0.653959,
  "oN",  "PU",  0.266862,
  "osM", "APU", 0.466443,
  "osM", "PU",  0.167785
)

res_grade6_type <- run_group(df_grade6, grade6_type, "Grade6", "HelexKids2_TYPE")
write_xlsx(res_grade6_type, file.path(OUT_DIR, "GLMER_Results_Grade6_TYPE.xlsx"))

# clamped cells summary
all_res <- bind_rows(
  res_adults_type,
  res_grade3_type,
  res_grade6_type
)
cat("\nClamped cells:\n")
print(all_res %>%
        filter(clamped_flag) %>%
        select(Suffix, Property, Baseline, p0_raw, p0_clamped, null_logit))
