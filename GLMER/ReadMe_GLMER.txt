ReadMe_GLMER 

# GLMER Analysis — Greek Nominal Stress Acquisition

This folder contains the scripts, input and output files for the 
generalized linear mixed-effects model (GLMER) analyses 
reported in the article.

## Contents of the GLMER folder

### Step 1 — Bayesian GLMM estimation (Python)
`GLM_Bayesian.ipynb` reads the experimental data and
fits an intercept-only Bayesian binomial mixed GLM
(statsmodels BinomialBayesMixedGLM, estimated via
variational Bayes). The script is written for adults and
run separately for each group by replacing the input file.

| Input | Output |
|---|---|
| `data_adults_glmer_dummies.xlsx` | `GLM_Adults_intercept_probabilities.xlsx` |
| `data_children_grade3_glmer_dummies.xlsx` | `GLM_GradeC_intercept_probabilities.xlsx` |
| `data_children_grade6_glmer_dummies.xlsx` | `GLM_GradeF_intercept_probabilities.xlsx` |

Each output file contains posterior mean intercept
probabilities and 95% credible intervals (on the
probability scale) for APU and PU responses per
inflection class.

### Step 2 — Figure generation (Python and R)
`GLM_Bayesian_Figures.ipynb` and `GLM_Bayesian_Figures.R`
produce scatter plots displaying the Bayesian GLMM 95% CI
rectangles together with type and token lexical frequency
reference points per inflection class. Each figure plots
APU probability on the x-axis and PU probability on the
y-axis, with one panel per inflection class/suffix.

The `ForSimulation_*` files provide the lexical reference
points (type frequency from GreekLex 2 / HelexKids 2.0,
token frequency from HNC Golden Corpus / HelexKids 2.0)
used in the figures.

| Input | Output |
|---|---|
| `GLM_Adults_intercept_probabilities.xlsx` + `ForSimulation_Adults_With_Tokens.xlsx` | `GLM_Figure_Adults_color.pdf/jpg`, `GLM_Figure_Adults_grayscale.pdf/jpg` |
| `GLM_GradeC_intercept_probabilities.xlsx` + `ForSimulation_Grade3_with_Tokens.xlsx` | `GLM_Figure_Children_color.pdf/jpg`, `GLM_Figure_Children_grayscale.pdf/jpg` |
| `GLM_GradeF_intercept_probabilities.xlsx` + `ForSimulation_Grade6_with_Tokens.xlsx` | (combined with Grade 3 above) |


### Step 3 — Frequentist GLMER (R)
`GLMER.R` fits an intercept-only frequentist GLMER with
lme4 (Bates et al., 2015) with crossed random effects for
participant and item. The fixed-effect intercept (b0) is
tested against the log-odds of the lexical type-frequency
baseline (p₀) via a Wald z-test. Lexical baselines are
drawn from GreekLex 2 (adults) and HelexKids 2.0
(Grades 3 and 6). Results are reported in the paper
footnote.

| Input | Output |
|---|---|
| `data_adults_glmer_dummies.xlsx` | `GLMER_Results_Adults_TYPE.xlsx` |
| `data_children_grade3_glmer_dummies.xlsx` | `GLMER_Results_Grade3_TYPE.xlsx` |
| `data_children_grade6_glmer_dummies.xlsx` | `GLMER_Results_Grade6_TYPE.xlsx` |

Important note on GLMER (R): 
Singular fits (random-effect variance collapsing to
zero) were detected in two Grade 3 cells (-iN APU,
-osM PU) and five Grade 6 cells (-iF APU, -iF PU,
-isM APU, -maN APU, -oN PU). They are probably due to the
smaller sample sizes of the child groups. These are reported
in the `singular` column of the corresponding output files.
In these cells results should be interpreted with appropriate 
caution. No singular fits were detected for adults.

## Relationship between the Python and R GLMER analyses

The two GLMER scripts address the same research question
but they also present differences. Point estimates
(mean intercept probabilities) do not differ in the results 
of both scripts. The standard deviations of the fixed-effect 
intercept differ between the two implementations because 
R (lme4) uses Laplace approximation, whereas Python (statsmodels)
uses variational Bayes (VB). VB tends to produce smaller
standard deviations and consequently narrower credible
intervals than Laplace-based estimates.

The Bayesian Python analysis (GLM_Bayesian.ipynb) is the
primary model-based analysis reported in Section 5.4 of
the paper.The frequentist R GLMER (GLMER.R) serves as a 
secondary verification of the ICC-corrected z-test results 
and is reported in a footnote.

## Software and dependencies

**R:** lme4, dplyr, tidyr, ggplot2, patchwork, readxl,
writexl
**Python:** numpy, pandas, statsmodels, matplotlib,
seaborn, openpyxl

## References

Bates, D., Mächler, M., Bolker, B., & Walker, S. (2015). 
Fitting linear mixed-effects models using lme4. *Journal 
of Statistical Software*, 67(1), 1–48.
