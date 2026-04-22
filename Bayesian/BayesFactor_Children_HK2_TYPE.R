library(brms)
library(dplyr)
library(writexl)

setwd("~/Desktop")

PRIOR_SIGMA <- 0.5
CHAINS      <- 4
ITER        <- 6000
WARMUP      <- 2000
SEED        <- 42
CORES       <- 4

# Savage-Dickey via Normal approximation (Bernstein-von Mises; more stable than KDE in tails)
savage_dickey <- function(post_logit_samples, null_logit, prior_sigma) {
  prior_dens <- dnorm(null_logit, mean = null_logit, sd = prior_sigma)
  post_dens  <- dnorm(null_logit,
                      mean = mean(post_logit_samples),
                      sd   = sd(post_logit_samples))
  bf01 <- if (prior_dens > 0) post_dens / prior_dens else NA
  bf10 <- if (!is.na(bf01) && post_dens > 0) prior_dens / post_dens else Inf
  list(bf01 = bf01, bf10 = bf10, prior_dens = prior_dens, post_dens = post_dens)
}

# HelexKids 2.0 TYPE proportions — grade-specific
# maN cells sourced as =1-0.000001 / =0.000001 in xlsx, clamped to 0.99999 / 0.00001
hk2_type <- list(

  Grade3 = tibble(
    Suffix   = c("aF",  "aF",  "iF",  "iF",  "iN",  "iN",
                 "isM", "isM", "maN", "maN", "oN",  "oN",  "osM", "osM"),
    Property = c("APU", "PU",  "APU", "PU",  "APU", "PU",
                 "APU", "PU",  "APU", "PU",  "APU", "PU",  "APU", "PU"),
    p0_raw   = c(0.1671554252199413,   0.6715542521994134,
                 0.4677419354838709,   0.2258064516129032,
                 0.004166666666666667, 0.9875,
                 0.05555555555555555,  0.6666666666666666,
                 0.99999,              0.00001,
                 0.6309523809523809,   0.2976190476190476,
                 0.5730337078651685,   0.1404494382022472)
  ),

  Grade6 = tibble(
    Suffix   = c("aF",  "aF",  "iF",  "iF",  "iN",  "iN",
                 "isM", "isM", "maN", "maN", "oN",  "oN",  "osM", "osM"),
    Property = c("APU", "PU",  "APU", "PU",  "APU", "PU",
                 "APU", "PU",  "APU", "PU",  "APU", "PU",  "APU", "PU"),
    p0_raw   = c(0.1544991511035654,   0.6943972835314092,
                 0.5847255369928401,   0.1837708830548926,
                 0.01169590643274854,  0.9824561403508771,
                 0.053475935828877,    0.6470588235294118,
                 0.99999,              0.00001,
                 0.6539589442815249,   0.2668621700879765,
                 0.4664429530201342,   0.1677852348993289)
  )
)

# Grade 3: n = 27 * 9 = 243; Grade 6: n = 17 * 9 = 153 (U responses treated as failures)
children_data <- list(

  Grade3 = tibble(
    Suffix    = c("aF",  "aF",  "iF",  "iF",  "iN",  "iN",
                  "isM", "isM", "maN", "maN", "oN",  "oN",  "osM", "osM"),
    Property  = c("APU", "PU",  "APU", "PU",  "APU", "PU",
                  "APU", "PU",  "APU", "PU",  "APU", "PU",  "APU", "PU"),
    successes = c(56,  176, 48,  165, 37,  184, 31,  164,
                  126, 112, 90,  135, 92,  111),
    total     = rep(27 * 9, 14)
  ),

  Grade6 = tibble(
    Suffix    = c("aF",  "aF",  "iF",  "iF",  "iN",  "iN",
                  "isM", "isM", "maN", "maN", "oN",  "oN",  "osM", "osM"),
    Property  = c("APU", "PU",  "APU", "PU",  "APU", "PU",
                  "APU", "PU",  "APU", "PU",  "APU", "PU",  "APU", "PU"),
    successes = c(27,  123, 21,  115, 10,  138, 7,   114,
                  85,  64,  64,  80,  51,  84),
    total     = rep(17 * 9, 14)
  )
)

all_results <- list()

for (grade in names(children_data)) {

  cat(sprintf("\n%s  |  HelexKids 2.0 TYPE\n", grade))

  df_grade <- children_data[[grade]]
  p0_grade <- hk2_type[[grade]]
  results  <- vector("list", nrow(df_grade))

  for (i in seq_len(nrow(df_grade))) {

    row        <- df_grade[i, ]
    p0_raw     <- (p0_grade %>% filter(Suffix == row$Suffix, Property == row$Property))$p0_raw
    p0         <- max(min(p0_raw, 0.99999), 0.00001)
    null_logit <- log(p0 / (1 - p0))

    cat(sprintf("  %s %s  p0=%.8f  logit=%.4f  k=%d  n=%d\n",
                row$Suffix, row$Property, p0_raw, null_logit,
                row$successes, row$total))

    my_prior <- get_prior(successes | trials(total) ~ 1,
                          data   = row,
                          family = binomial(link = "logit"))
    my_prior$prior[my_prior$class == "Intercept"] <-
      sprintf("normal(%f, %f)", null_logit, PRIOR_SIGMA)

    fit <- brm(
      formula = successes | trials(total) ~ 1,
      data    = row,
      family  = binomial(link = "logit"),
      prior   = my_prior,
      chains  = CHAINS,
      iter    = ITER,
      warmup  = WARMUP,
      seed    = SEED,
      cores   = CORES,
      silent  = 2,
      refresh = 0
    )

    post_logit <- as.vector(as_draws_matrix(fit, variable = "b_Intercept"))
    sd_res     <- savage_dickey(post_logit, null_logit, PRIOR_SIGMA)
    post_p     <- plogis(post_logit)

    cat(sprintf("    post_dens=%.6f  prior_dens=%.6f  BF01=%.4f  BF10=%.4f\n",
                sd_res$post_dens, sd_res$prior_dens, sd_res$bf01, sd_res$bf10))

    results[[i]] <- tibble(
      Grade               = grade,
      Class               = row$Suffix,
      Property            = row$Property,
      Lexical_p0_HK2_type = p0_raw,
      Raw_successes       = row$successes,
      raw_total           = row$total,
      observed_proportion = row$successes / row$total,
      posterior_mean_p    = mean(post_p),
      posterior_median_p  = median(post_p),
      ci_95_p_lower       = quantile(post_p, 0.025),
      ci_95_p_upper       = quantile(post_p, 0.975),
      BF01                = sd_res$bf01,
      BF10                = sd_res$bf10
    )
  }

  all_results[[grade]] <- bind_rows(results)
}

write_xlsx(all_results, "BayesFactor_Results_Children_HK2_TYPE.xlsx")

for (grade in names(all_results)) {
  cat(sprintf("\n%s\n", grade))
  print(all_results[[grade]], n = Inf, width = Inf)
}
