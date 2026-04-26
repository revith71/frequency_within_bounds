# Supplementary Materials

## Article

**Lexical frequency within grammatical bounds: Phonological default and inflection-class conditioning in Greek nominal stress**

Anthi Revithiadou, Giorgos Markopoulos, Kosmas Kosmidis, Ilias Mittas, Maria Soukalopoulou, Vassiliki Apostolouda


---

## Overview

This folder contains all data, scripts, and output files supporting the statistical analyses reported in the paper. The study investigates whether lexical frequency drives stress assignment in Greek, a morphology-dependent stress system. Trisyllabic pseudo-nouns from seven inflection classes (-aF, -iF, -iN, -isM, -maN, -oN, -osM) were elicited from 105 adults and 105 elementary school children (Grades 3 and 6). Experimental stress distributions were compared to those found in three lexical databases, that is, GreekLex 2, the HNC Golden Corpus, and HelexKids 2.0, using four complementary statistical methods: ICC-adjusted proportion tests, a Bayesian generalized linear mixed-effects model (GLMER), Bayes Factor analysis, and Monte Carlo simulations.

---

## Folder Structure

```
Supplementary_materials/

    README.md                                   ← this file
    Experimental_results.xlsx                   ← raw experimental data (all groups)

    Hypothesis_testing_results/                 ← ICC-adjusted proportion tests
        Adults_tests_with_ICC_FORMULAS_Wilson.xlsx
        Grade2_tests_with_ICC_FORMULAS_Wilson.xlsx
        Grade3_tests_with_ICC_FORMULAS_Wilson.xlsx
        Grade4_tests_with_ICC_FORMULAS_Wilson.xlsx
        Grade5_tests_with_ICC_FORMULAS_Wilson.xlsx
        Grade6_tests_with_ICC_FORMULAS_Wilson.xlsx

    GLMER/                                      ← Bayesian and frequentist GLMER
        ReadMe_GLMER.txt                        ← detailed README for this folder
        glmer_Py/                               ← Bayesian GLMM (Python/statsmodels)
            GLM_Bayesian.ipynb
            GLM_Bayesian_Figures.ipynb
            GLM_Bayesian_Figures.R
            GLM_Adults_intercept_probabilities.xlsx
            GLM_GradeC_intercept_probabilities.xlsx
            GLM_GradeF_intercept_probabilities.xlsx
            ForSimulation_Adults_With_Tokens.xlsx
            ForSimulation_Grade3_with_Tokens.xlsx
            ForSimulation_Grade6_with_Tokens.xlsx
            data_adults_glmer_dummies.xlsx
            data_children_grade3_glmer_dummies.xlsx
            data_children_grade6_glmer_dummies.xlsx
        glmer_R/                                ← Frequentist GLMER (R/lme4)
            GLMER.R
            GLMER_Results_Adults_TYPE.xlsx
            GLMER_Results_Grade3_TYPE.xlsx
            GLMER_Results_Grade6_TYPE.xlsx
            data_adults_glmer_dummies.xlsx
            data_children_grade3_glmer_dummies.xlsx
            data_children_grade6_glmer_dummies.xlsx

    Bayesian/                                   ← Bayes Factor analysis (R/brms)
        BayesFactor_Adults_TYPE.R
        BayesFactor_Children_HK2_TYPE.R
        BayesFactor_Results_Adults_TYPE.xlsx
        BayesFactor_Results_Children_HK2_TYPE.xlsx

    MC_simulation/                              ← Monte Carlo simulations (Python)
        MC_simulation_types/                    ← type-frequency baselines
            Simulation_Adults.ipynb
            Simulation_Grades.ipynb
            ForSimulation_Adults.xlsx
            ForSimulation_Grade3.xlsx
            ForSimulation_Grade6.xlsx
        MC_simulation_tokens/                   ← token-frequency baselines
            Simulation_Grade3_tokens.ipynb
            ForSimulation_Adults_With_Tokens.xlsx
            Simulation_Adults_tokens.pdf
            Simulation_Adults_tokens.jpg
            Simulation_Grade3_tokens.pdf
            Simulation_Grade3_tokens.jpg
            Simulation_Grade6_tokens.pdf
            Simulation_Grade6_tokens.jpg

---

## File and Folder Descriptions

### `Experimental_results.xlsx`

Raw experimental stress responses (APU, PU, U) for all participants across the seven inflection classes. Columns identify participant group (Adults, Grade 3, Grade 6), suffix type, pseudo-noun item, and stress response. This file provides the data for all analyses reported in the article.
---

### `Hypothesis_testing_results/`

Contains the complete results of the ICC-adjusted proportion tests reported in Sections 5.1–5.3 and the paper Appendix (Tables D1–D6). For each speaker group, each suffix category, and each stress pattern (APU and PU), the spreadsheets report the lexical baseline proportion (*p*₀), the experimental proportion (*p̂*), raw success counts, the ICC-adjusted Z-statistic, the two-sided *p*-value, and the Wilson 95% confidence interval.

Three equivalent calculations are provided side by side for methodological transparency (Appendix, Section C):

- **Conservative** (*n* = number of participants only; ρ = 1): treats each participant as contributing a single observation.
- **Liberal** (*n* = total tokens; ρ = 0): treats all tokens as independent observations.
- **ICC-adjusted** (*n* = *n*eff; ρ = 0.20): the primary analysis reported in the paper, using the design-effect formula to obtain effective sample sizes of *n*eff = 363.46 (Adults), 93.46 (Grade 3), and 58.85 (Grade 6).

Lexical baselines are drawn from GreekLex 2 type frequencies (Adults) and HelexKids 2.0 type frequencies (Grades 3 and 6).

| File | Group |
`Adults_tests_with_ICC_FORMULAS_Wilson.xlsx` | Adults (*N* = 105) |
`Grade3_tests_with_ICC_FORMULAS_Wilson.xlsx` | Grade 3 children (*N* = 27) |
`Grade6_tests_with_ICC_FORMULAS_Wilson.xlsx` | Grade 6 children (*N* = 17) |

---

### `GLMER/`

Contains all scripts and output files for the two GLMER analyses reported in Section 5.4. A separate detailed README (`ReadMe_GLMER.txt`) is included inside this folder.

#### `GLMER/glmer_Py/` — Bayesian GLMM (Python, primary analysis)

Fits an intercept-only Bayesian binomial mixed GLM via variational Bayes (Python `statsmodels`: `BinomialBayesMixedGLM`), with crossed random effects for participant and item. This is the primary model-based analysis reported in Section 5.4 and displayed in Figures 3 and 4.

**Input data files** (one per group; dummy-coded for suffix and stress pattern):

| File | Group |
`data_adults_glmer_dummies.xlsx` | Adults |
`data_children_grade3_glmer_dummies.xlsx` | Grade 3 |
`data_children_grade6_glmer_dummies.xlsx` | Grade 6 |

**Scripts:**

| Script | Purpose |
`GLM_Bayesian.ipynb` | Fits the Bayesian GLMM and exports posterior intercept probabilities |
`GLM_Bayesian_Figures.ipynb` | Python figure generation (scatter plots, Figures 3–4) |
`GLM_Bayesian_Figures.R` | R figure generation (alternative; same plots) |

**Model output files** (posterior mean intercept probabilities and 95% credible intervals per suffix and stress pattern):

| File | Group |
`GLM_Adults_intercept_probabilities.xlsx` | Adults |
`GLM_GradeC_intercept_probabilities.xlsx` | Grade 3 |
`GLM_GradeF_intercept_probabilities.xlsx` | Grade 6 |

**Lexical reference files** (type and token frequencies used as reference points in the figures; not used in GLMM estimation):

| File | Group | Sources |
`ForSimulation_Adults_With_Tokens.xlsx` | Adults | GreekLex 2 (types), HNC Golden (tokens) |
`ForSimulation_Grade3_with_Tokens.xlsx` | Grade 3 | HelexKids 2.0 (types and tokens) |
`ForSimulation_Grade6_with_Tokens.xlsx` | Grade 6 | HelexKids 2.0 (types and tokens) |

#### `GLMER/glmer_R/` — Frequentist GLMER (R, secondary verification)

Fits an intercept-only frequentist GLMER with crossed random effects for participant and item (R `lme4`; Bates et al., 2015). The fixed-effect intercept (*b*₀) is tested against the log-odds of the lexical type-frequency baseline via a Wald *z*-test. This analysis serves as secondary verification and is reported in a paper footnote. Point estimates (mean intercept probabilities) are consistent with those from the Bayesian Python model.

**Input data files:** identical to `glmer_Py/` (same three xlsx files).

**Script:**

| Script | Purpose |
`GLMER.R` | Fits the frequentist GLMER and runs Wald z-tests against lexical baselines |

**Output files:**

| File | Group |
`GLMER_Results_Adults_TYPE.xlsx` | Adults |
`GLMER_Results_Grade3_TYPE.xlsx` | Grade 3 |
`GLMER_Results_Grade6_TYPE.xlsx` | Grade 6 |

---

### `Bayesian/`

Contains the R scripts and output spreadsheets for the Bayes Factor analysis reported in Section 5.4. Bayes Factors (BF₀₁) were computed via the Savage-Dickey density ratio using a Normal approximation to the posterior (R package `brms`; Bürkner, 2017). The prior distribution was centered on the lexical type-frequency proportion for each suffix–stress pattern cell, with ±0.5 logit units of uncertainty.

BF₀₁ quantifies evidence for alignment with the lexical baseline (H₀: *p* = *p*₀) relative to departure from it (H₁: *p* ≠ *p*₀), and is interpreted following Lee & Wagenmakers (2014). Values above 1 indicate evidence for lexical alignment; values below 1 indicate evidence for departure. Lexical baselines are drawn from GreekLex 2 type frequencies (Adults) and HelexKids 2.0 type frequencies (children).

| File | Contents |
`BayesFactor_Adults_TYPE.R` | R script: Bayes Factor computation for adults (GreekLex 2 baseline) |
`BayesFactor_Children_HK2_TYPE.R` | R script: Bayes Factor computation for Grade 3 and Grade 6 children (HelexKids 2.0 baseline) 
`BayesFactor_Results_Adults_TYPE.xlsx` | BF₀₁ values per suffix and stress pattern — Adults |
`BayesFactor_Results_Children_HK2_TYPE.xlsx` | BF₀₁ values per suffix and stress pattern — Grade 3 and Grade 6 |

---

### `MC_simulation/`

Contains the Python scripts and output files for the Monte Carlo simulations described in Section 6. Each simulation generates 1,000 synthetic experiments, each comprising *N* "digital speakers" (Adults: *N* = 105; Grade 3: *N* = 27; Grade 6: *N* = 17). Each digital speaker is assigned individualized stress probabilities by adding Gaussian noise (*σ* = 0.1) to the lexical baseline proportions (APU and PU), with U determined by normalization. Each digital speaker then produces *m* = 9 pseudo-nouns per suffix using a multinomial draw. The resulting 1,000 simulated experimental outcomes form a reference distribution against which the actual experimental result (a yellow star in the figures) is evaluated.

Two subfolders correspond to the two sets of lexical baselines:

#### `MC_simulation/MC_simulation_types/` — type-frequency baselines (reported in the article; Section 6)

Baselines: GreekLex 2 type frequencies (Adults); HelexKids 2.0 type frequencies (Grades 3 and 6).

| File | Description |
`Simulation_Adults.ipynb` | Monte Carlo simulation for Adults |
`Simulation_Grades.ipynb` | Monte Carlo simulation for Grade 3 and Grade 6 |
`ForSimulation_Adults.xlsx` | Input: GreekLex 2 type proportions per suffix (Adults) |
`ForSimulation_Grade3.xlsx` | Input: HelexKids 2.0 type proportions per suffix (Grade 3) |
`ForSimulation_Grade6.xlsx` | Input: HelexKids 2.0 type proportions per suffix (Grade 6) |

#### `MC_simulation/MC_simulation_tokens/` — token-frequency baselines (complementary; not reported in the article)

Baselines: HNC Golden Corpus token frequencies (Adults); HelexKids 2.0 token frequencies (Grades 3 and 6). Results were fully consistent with those obtained using type-frequency baselines (see Section 6).

| File | Description |
`Simulation_Grade3_tokens.ipynb` | Monte Carlo simulation script (token-frequency baseline; adaptable to all groups) |
`ForSimulation_Adults_With_Tokens.xlsx` | Input: HNC Golden token proportions per suffix (Adults) |
`Simulation_Adults_tokens.pdf` | Output figure: Adults (Figures 5 variant) |
`Simulation_Adults_tokens.jpg` | Output figure: Adults (high-resolution image) |
`Simulation_Grade3_tokens.pdf` | Output figure: Grade 3 (Figure 6a variant) |
`Simulation_Grade3_tokens.jpg` | Output figure: Grade 3 (high-resolution image) |
`Simulation_Grade6_tokens.pdf` | Output figure: Grade 6 (Figure 6b variant) |
`Simulation_Grade6_tokens.jpg` | Output figure: Grade 6 (high-resolution image) |

---

## Lexical Resources and Abbreviations

| Abbreviation | Full name | Role in analyses |
 GreekLex 2 | Kyparissiadis et al. (2017) | Adult lexical type-frequency baseline |
HNC Golden | Hellenic National Corpus, Golden PoS Corpus (ILSP 2021) | Adult lexical token-frequency reference |
| HelexKids 2.0 | Revithiadou et al. (2026) | Children's lexical baseline (types and tokens, Grades 3 and 6) |

Inflection classes: **-aF** (feminine -a), **-iF** (feminine -i), **-iN** (neuter -i), **-isM** (masculine -is), **-maN** (neuter -ma), **-oN** (neuter -o), **-osM** (masculine -os). Stress positions: **APU** = antepenultimate, **PU** = penultimate, **U** = ultimate.

---

## Software and Dependencies

**R** (≥ 4.0): `lme4`, `brms`, `dplyr`, `tidyr`, `ggplot2`, `patchwork`, `readxl`, `writexl`

**Python** (≥ 3.8): `numpy`, `pandas`, `statsmodels`, `scipy`, `matplotlib`, `seaborn`, `openpyxl`

---

## Data Availability

The scripts, input and output files of our analyses are openly available at:
<https://github.com/revith71/frequency_within_bounds>

---

*Prepared in connection with the GRADIENCE project (H.F.R.I. ID: 015053), funded by the European Union – NextGenerationEU within the framework of the National Recovery and Resilience Plan Greece 2.0.*
