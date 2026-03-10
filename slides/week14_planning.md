# Week 14 Lecture Planning Notes
**Date:** 4/21 — one week before presentations, two weeks before final papers due
**Context:** Week 13 covers moderation/interactions (Thompson & Keith); many students proposed mediation in paper proposals

---

## Option A: Mediation as a Standalone Lecture

**Working title:** "How and Why: Mediation Analysis"

Could stand alone given the level of conceptual work required and the R implementation.

### Main concepts

1. **Moderation vs. mediation — the key distinction**
   - Moderation: *for whom* does X affect Y? (interaction between X and a third variable)
   - Mediation: *how* or *why* does X affect Y? (X → M → Y)
   - Students consistently conflate these; worth a full side-by-side comparison slide
   - Real example: Does education affect income *through* occupation? (mediation). Does education affect income *differently* for men vs. women? (moderation)

2. **Conceptual framework: direct, indirect, and total effects**
   - Path diagram showing X → Y (direct), X → M → Y (indirect), and total
   - Total effect = direct + indirect
   - Introduce notation: *a* path (X→M), *b* path (M→Y), *c* path (X→Y direct), *c'* (total)

3. **Baron & Kenny four-step approach**
   - Step 1: X significantly predicts Y
   - Step 2: X significantly predicts M
   - Step 3: M significantly predicts Y (controlling for X)
   - Step 4: X→Y relationship weakens or disappears when M is included
   - Full vs. partial mediation distinction

4. **Implementation in R**
   - Three sequential `lm()` calls — no special package needed
   - `mediation` package for indirect effects and confidence intervals (bootstrapped)
   - Interpreting the output: coefficients, indirect effect size

5. **Limitations and causal interpretation**
   - Mediation doesn't prove causation — temporal ordering matters
   - Cross-sectional data limitations
   - Unmeasured confounders of M→Y path
   - Brief intro to why experiments are the gold standard for mediation

---

## Option B: Mediation + Regression Diagnostics

**Working title:** "Getting It Right: Regression Diagnostics and Mediation"

Most intellectually coherent pairing — "what to check, and then what to ask."

### Main concepts

#### Part 1: Regression Diagnostics (~40 min)

1. **Why diagnostics matter**
   - Regression assumptions: linearity, independence, homoskedasticity, normality of residuals
   - Violations don't always invalidate results, but you need to know when they do

2. **Residual plots**
   - Fitted vs. residuals plot: checking linearity and homoskedasticity
   - Q-Q plot: checking normality of residuals
   - In R: `plot(model)` gives all four diagnostic plots; or `ggplot` with `augment()` from `broom`

3. **Outliers and influential observations**
   - Leverage vs. influence distinction
   - Cook's distance — identifying influential points
   - What to do: investigate, don't automatically delete

4. **Multicollinearity**
   - When predictors are highly correlated with each other
   - VIF (Variance Inflation Factor) — `vif()` from `car` package
   - Rule of thumb: VIF > 5 or 10 is a problem
   - Consequences: inflated standard errors, unstable coefficients

5. **Heteroskedasticity**
   - What it is, why it matters (biases standard errors)
   - Visual detection vs. Breusch-Pagan test
   - Fix: robust standard errors — `coeftest()` with `vcovHC()` from `sandwich` package

#### Part 2: Mediation (~40 min)
*(same structure as Option A above)*

---

## Option C: Mediation + Causal Inference / DAGs

**Working title:** "Asking Why: Causal Thinking and Mediation"

More conceptual and theory-forward; connects to how sociologists actually reason.

### Main concepts

1. **Correlation vs. causation — revisited**
   - Review confounding: a third variable causes both X and Y
   - Why regression controls "work" and when they don't
   - Omitted variable bias: what happens when you leave out an important confounder

2. **Introduction to DAGs (Directed Acyclic Graphs)**
   - Nodes = variables, arrows = causal relationships
   - Backdoor paths and how confounders create them
   - The logic of "controlling for" a variable in DAG terms
   - What NOT to control for: colliders and mediators (controlling for M blocks the path you care about)
   - Tools: `dagitty` package or draw on paper

3. **Mediation in a causal framework**
   - Mediation as a specific DAG structure: X → M → Y
   - Why you shouldn't control for M if you want the total effect
   - Why you should control for M if you want the direct effect
   - Connects Baron & Kenny to causal logic

4. **Identification strategies (brief overview)**
   - Randomized experiments: the gold standard
   - Natural experiments, instrumental variables (name-drop only)
   - Difference-in-differences (name-drop)
   - Goal: show students that sociologists have tools beyond OLS for causal questions

5. **Implications for their papers**
   - Drawing a DAG for their own research question
   - What can they claim causally with cross-sectional survey data?
   - How to qualify causal language appropriately

---

## Option D: Mediation + Writing and Presenting Results

**Working title:** "Finishing Strong: Mediation and Communicating Your Results"

Most practically useful given timing (week before presentations, 2 weeks before papers).

### Main concepts

#### Part 1: Mediation (~50 min)
*(same structure as Option A above)*

#### Part 2: Writing and Presenting Results (~30 min)

1. **Presenting regression results in a paper**
   - Anatomy of a regression table: coefficients, standard errors (not t-stats), stars
   - `modelsummary` or `stargazer` packages in R
   - What goes in the text vs. what goes in a table
   - Describing effect size, not just significance

2. **Visualizing regression results**
   - Coefficient plots as an alternative to tables (`ggplot` + `broom::tidy()`)
   - Predicted values plots — showing the relationship, not just the slope
   - `ggeffects` or `marginaleffects` package for marginal effects plots

3. **Writing about results for a sociological audience**
   - Lead with the sociological finding, not the statistic
   - "A one-unit increase in X is associated with a 0.3-unit increase in Y, holding other variables constant" — make this sociologically meaningful
   - How to discuss limitations honestly without undermining your argument

4. **Presentation tips for week 15**
   - Structure: question → motivation → data → results → so what
   - How to present a regression table to a general audience (hint: don't show the whole table)
   - Anticipating questions

---

## Recommendation

**First choice: Option A (mediation standalone)** if week 13 runs long or interactions need extra time to sink in. The moderation vs. mediation comparison alone justifies a full class.

**Second choice: Option B (mediation + diagnostics)** if you want to add practical value for paper-writing and the R component feels thin with mediation alone. Diagnostics are something students should be doing anyway.

**Dark horse: Option D (mediation + writing results)** — least "stats" but probably highest direct payoff for students in the final two weeks of the semester.
