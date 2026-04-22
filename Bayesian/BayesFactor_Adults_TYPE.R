library(brms)
library(dplyr)
library(writexl)

setwd("~/Desktop")

PRIOR_SIGMA <- 0.5
N_TRIALS    <- 945
CHAINS      <- 4
ITER        <- 6000
WARMUP      <- 2000
SEED        <- 42
CORES       <- 4

# Savage-Dickey density ratio via Normal approximation to the posterior.
# With n=945 the Bernstein-von Mises approximation is very accurate and
# more stable than KDE in the tails.

savage_dickey <- function(post_logit_samples, null_logit, prior_sigma) {
  prior_dens <- dnorm(null_logit, mean = null_logit, sd = prior_sigma)
  post_dens  <- dnorm(null_logit,
                      mean = mean(post_logit_samples),
                      sd   = sd(post_logit_samples))
  bf01 <- if (prior_dens > 0) post_dens / prior_dens else NA
  bf10 <- if (!is.na(bf01) && post_dens > 0) prior_dens / post_dens else Inf
  list(bf01 = bf01, bf10 = bf10, prior_dens = prior_dens, post_dens = post_dens)
}

data_cells <- tibble(
  Class     = c("aF",  "aF",  "iF",  "iF",  "iN",  "iN",
                "isM", "isM", "maN", "maN", "oN",  "oN",  "osM", "osM"),
  Property  = c("APU", "PU",  "APU", "PU",  "APU", "PU",
                "APU", "PU",  "APU", "PU",  "APU", "PU",  "APU", "PU"),
  p0_raw    = c(0.2259,  0.5810,  0.6017,  0.1576,
                0.0097,  0.9542,  0.0150,  0.5415,
                0.99999, 0.00001, 0.6256,  0.2650,
                0.3565,  0.1682),
  successes = c(255, 672, 133, 719,  80, 813,  43, 713,
                849,  90, 569, 318, 457, 345)
) %>%
  mutate(
    total      = N_TRIALS,
    p0         = pmax(pmin(p0_raw, 0.99999), 0.00001),
    null_logit = log(p0 / (1 - p0))
  )

results <- vector("list", nrow(data_cells))

for (i in seq_len(nrow(data_cells))) {

  row        <- data_cells[i, ]
  null_logit <- row$null_logit
  cat(sprintf("\n%s %s  p0 = %.5f  logit = %.4f\n",
              row$Class, row$Property, row$p0_raw, null_logit))

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

  cat(sprintf("  post_dens=%.6f  prior_dens=%.6f  BF01=%.4f  BF10=%.4f\n",
              sd_res$post_dens, sd_res$prior_dens, sd_res$bf01, sd_res$bf10))

  results[[i]] <- tibble(
    Class               = row$Class,
    Property            = row$Property,
    Lexical_p0_type     = row$p0_raw,
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

df_results <- bind_rows(results)
print(df_results, n = Inf, width = Inf)

write_xlsx(df_results, "BayesFactor_Results_Adults_TYPE.xlsx")
