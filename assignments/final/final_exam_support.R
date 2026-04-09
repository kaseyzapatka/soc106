suppressPackageStartupMessages({
  library(tidyverse)
  library(haven)
  library(here)
  library(modelsummary)
  library(survey)
  library(knitr)
  library(kableExtra)
  library(glue)
})

options(scipen = 999)
options(survey.lonely.psu = "adjust")

show_answers <- get0("show_answers", ifnotfound = FALSE)
exam_display_title <- get0("exam_display_title", ifnotfound = "SOC 106 Final Exam")
exam_display_date <- get0("exam_display_date", ifnotfound = "April 8, 2026")

fmt_num <- function(x, digits = 2) {
  formatC(x, digits = digits, format = "f")
}

fmt_pct <- function(x, digits = 1) {
  paste0(fmt_num(100 * x, digits), "%")
}

fmt_p <- function(x) {
  if (is.na(x)) {
    return(NA_character_)
  }

  if (x < 0.001) {
    "< 0.001"
  } else {
    fmt_num(x, 3)
  }
}

fmt_ci <- function(low, high, digits = 2, percent = FALSE) {
  if (percent) {
    glue("[{fmt_pct(low, digits)}, {fmt_pct(high, digits)}]")
  } else {
    glue("[{fmt_num(low, digits)}, {fmt_num(high, digits)}]")
  }
}

emit_mc_key <- function(letter, explanation = NULL) {
  if (!isTRUE(show_answers)) {
    return(invisible(NULL))
  }

  cat(glue("\n**Correct answer: {letter}.**"))
  if (!is.null(explanation)) {
    cat(glue(" {explanation}"))
  }
  cat("\n\n")
}

emit_sa_answer <- function(answer, rubric = NULL, space = 0.85) {
  if (isTRUE(show_answers)) {
    cat("\n**Template answer:** ", answer, "\n\n", sep = "")
    if (!is.null(rubric)) {
      cat("*Rubric:* ", rubric, "\n\n", sep = "")
    }
  } else {
    cat("\n\\vspace{", fmt_num(space, 2), "in}\n\n", sep = "")
  }
}

emit_exam_header <- function(title = exam_display_title, date = exam_display_date) {
  if (knitr::is_latex_output()) {
    cat(
      "\\noindent\\begin{minipage}[t]{0.62\\textwidth}\n",
      "{\\Large\\textbf{", title, "}}\\\\\n",
      date, "\n",
      "\\end{minipage}\\hfill\n",
      "\\begin{minipage}[t]{0.33\\textwidth}\n",
      "\\raggedleft\\textbf{Name:} \\rule{2.0in}{0.4pt}\n",
      "\\end{minipage}\n\n",
      "\\vspace{0.6em}\n\n",
      sep = ""
    )
  } else if (knitr::is_html_output()) {
    cat(
      "<table style=\"width:100%; border-collapse:collapse; margin-bottom:0.75rem;\">",
      "<tr>",
      "<td style=\"width:62%; vertical-align:top;\">",
      "<div style=\"font-size:1.5rem; font-weight:700;\">", title, "</div>",
      "<div>", date, "</div>",
      "</td>",
      "<td style=\"width:38%; text-align:right; vertical-align:top;\">",
      "<strong>Name:</strong> ________________________________",
      "</td>",
      "</tr>",
      "</table>\n\n",
      sep = ""
    )
  }
}

begin_indent <- function(amount = "1.25em") {
  if (knitr::is_latex_output()) {
    cat("\\begingroup\\leftskip=", amount, "\n", sep = "")
  } else if (knitr::is_html_output()) {
    cat("<div style=\"margin-left:", amount, ";\">\n", sep = "")
  }
}

end_indent <- function() {
  if (knitr::is_latex_output()) {
    cat("\\par\\endgroup\n\n")
  } else if (knitr::is_html_output()) {
    cat("</div>\n\n")
  }
}

begin_samepage <- function() {
  invisible(NULL)
}

end_samepage <- function() {
  invisible(NULL)
}

emit_table_note <- function() {
  if (knitr::is_latex_output()) {
    cat(
      "\\begin{center}\n",
      "\\begin{minipage}{0.58\\linewidth}\n",
      "\\raggedright\\footnotesize\\textit{Note.} * p < .05, ** p < .01, *** p < .001.\n",
      "\\end{minipage}\n",
      "\\end{center}\n\n",
      sep = ""
    )
  } else if (knitr::is_html_output()) {
    cat(
      "<div style=\"width:58%; margin:0 auto 1rem auto; text-align:left; font-size:0.9em;\">",
      "<em>Note.</em> * p &lt; .05, ** p &lt; .01, *** p &lt; .001.",
      "</div>\n\n",
      sep = ""
    )
  } else {
    cat("Note. * p < .05, ** p < .01, *** p < .001.\n\n")
  }
}

emit_manual_table_caption <- function(caption) {
  if (knitr::is_latex_output()) {
    cat("\\begin{center}\\textbf{", caption, "}\\end{center}\n", sep = "")
  } else if (knitr::is_html_output()) {
    cat(
      "<div style=\"text-align:center; font-weight:600; margin:0.2rem 0 0.4rem 0;\">",
      caption,
      "</div>\n",
      sep = ""
    )
  } else {
    cat(caption, "\n\n", sep = "")
  }
}

style_exam_table <- function(tbl, latex_widths = c("4.35in", "1.60in"), html_widths = c("72%", "28%")) {
  if (knitr::is_latex_output()) {
    tbl <- kableExtra::kable_styling(
      tbl,
      position = "center",
      latex_options = "hold_position"
    )
    if (length(latex_widths) > 0) {
      for (i in seq_along(latex_widths)) {
        tbl <- kableExtra::column_spec(tbl, i, width = latex_widths[i])
      }
    }
  } else if (knitr::is_html_output()) {
    tbl <- kableExtra::kable_styling(
      tbl,
      position = "center",
      full_width = FALSE
    )
    if (length(html_widths) > 0) {
      for (i in seq_along(html_widths)) {
        tbl <- kableExtra::column_spec(tbl, i, width = html_widths[i])
      }
    }
  }

  tbl
}

emit_regression_table <- function(x, align, caption) {
  emit_manual_table_caption(caption)

  tbl <- knitr::kable(
    x,
    align = align,
    booktabs = knitr::is_latex_output()
  )

  tbl <- style_exam_table(tbl)

  tbl <- kableExtra::footnote(
    tbl,
    general = "* p < .05, ** p < .01, *** p < .001.",
    general_title = "Note. ",
    footnote_as_chunk = TRUE,
    threeparttable = TRUE,
    escape = FALSE
  )

  print(tbl)
  invisible(NULL)
}

emit_simple_table <- function(x,
                              align,
                              caption,
                              latex_widths = c("2.75in", "2.75in"),
                              html_widths = c("50%", "50%")) {
  emit_manual_table_caption(caption)

  tbl <- knitr::kable(
    x,
    align = align,
    booktabs = knitr::is_latex_output()
  )

  tbl <- style_exam_table(tbl, latex_widths = latex_widths, html_widths = html_widths)

  print(tbl)
  invisible(NULL)
}

emit_console_block <- function(text) {
  cat("```text\n", text, "\n```\n\n", sep = "")
}

make_design <- function(data) {
  survey::svydesign(ids = ~1, weights = ~wtssnrps_as, data = as.data.frame(data))
}

make_model_table_df <- function(model,
                                model_name = "Model",
                                coef_map = NULL,
                                exponentiate = FALSE,
                                gof_keep = c("Num.Obs.", "R2", "R2 Adj.", "AIC")) {
  raw <- suppressWarnings(
    modelsummary(
      model,
      output = "data.frame",
      estimate = "{estimate}{stars}",
      statistic = "({std.error})",
      fmt = 2,
      exponentiate = exponentiate,
      coef_map = coef_map
    )
  )

  value_col <- setdiff(names(raw), c("part", "term", "statistic"))[1]

  est_df <- raw |>
    filter(part == "estimates") |>
    transmute(
      Term = if_else(statistic == "estimate", term, ""),
      !!model_name := .data[[value_col]]
    )

  gof_df <- raw |>
    filter(part == "gof", term %in% gof_keep) |>
    transmute(
      Term = recode(
        term,
        "Num.Obs." = "Num. Obs.",
        "R2 Adj." = "Adj. R2"
      ),
      !!model_name := .data[[value_col]]
    )

  bind_rows(est_df, gof_df)
}

dta_path <- here("data", "gss", "gss_2024.dta")
cache_path <- here("data", "gss", "gss_2024_exam_cache.csv")

build_exam_cache <- function() {
  read_dta(dta_path) |>
    zap_missing() |>
    transmute(
      wtssnrps_as = as.numeric(wtssnrps_as),
      sex = str_to_lower(str_squish(as.character(as_factor(sex)))),
      race = str_to_lower(str_squish(as.character(as_factor(race)))),
      marital = str_to_lower(str_squish(as.character(as_factor(marital)))),
      dwelown = str_to_lower(str_squish(as.character(as_factor(dwelown)))),
      owngun = str_to_lower(str_squish(as.character(as_factor(owngun)))),
      educ = as.numeric(educ),
      age = as.numeric(age),
      hrs1 = as.numeric(hrs1),
      prestg10 = as.numeric(prestg10),
      female = case_when(
        sex == "female" ~ 1,
        sex == "male" ~ 0,
        TRUE ~ NA_real_
      ),
      black = case_when(
        race == "black" ~ 1,
        race == "white" ~ 0,
        TRUE ~ NA_real_
      ),
      homeowner = case_when(
        dwelown == "own or is buying" ~ 1,
        dwelown == "pays rent" ~ 0,
        TRUE ~ NA_real_
      ),
      gun_owner = case_when(
        owngun == "yes" ~ 1,
        owngun == "no" ~ 0,
        TRUE ~ NA_real_
      ),
      married = case_when(
        marital == "married" ~ 1,
        marital %in% c("widowed", "divorced", "separated", "never married") ~ 0,
        TRUE ~ NA_real_
      )
    )
}

cache_is_stale <- !file.exists(cache_path) ||
  file.info(cache_path)$mtime < file.info(dta_path)$mtime

if (cache_is_stale) {
  gss <- build_exam_cache()
  readr::write_csv(gss, cache_path)
} else {
  gss <- readr::read_csv(cache_path, show_col_types = FALSE)
}

gss <- gss |>
  mutate(
    degree4 = case_when(
      is.na(educ) ~ NA_character_,
      educ <= 12 ~ "HS or less",
      educ >= 13 & educ <= 15 ~ "Some college",
      educ == 16 ~ "College graduate",
      educ >= 17 ~ "Graduate degree",
      TRUE ~ NA_character_
    ),
    degree4 = factor(
      degree4,
      levels = c("College graduate", "HS or less", "Some college", "Graduate degree")
    ),
    age_c45 = age - 45,
    educ_c12 = educ - 12
  )

dist_plot_data <- bind_rows(
  tibble(panel = "A", x = rnorm(1200, mean = 0, sd = 1)),
  tibble(panel = "B", x = 6 - rexp(1200, rate = 1)),
  tibble(panel = "C", x = rexp(1200, rate = 1)),
  tibble(panel = "D", x = runif(1200, min = -2.5, max = 2.5))
) |>
  mutate(panel = factor(panel, levels = c("A", "B", "C", "D")))

distribution_plot <- ggplot(dist_plot_data, aes(x = x)) +
  geom_histogram(bins = 18, fill = "#5c7cfa", color = "white", linewidth = 0.2) +
  facet_wrap(~panel, nrow = 1, scales = "free_x") +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 11) +
  theme(
    strip.text = element_text(face = "bold", size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )

ttest_data <- gss |>
  filter(
    is.na(wtssnrps_as) == FALSE,
    is.na(hrs1) == FALSE,
    sex %in% c("male", "female")
  ) |>
  mutate(
    sex = factor(sex, levels = c("male", "female"), labels = c("Men", "Women"))
  )

ttest_design <- make_design(ttest_data)
ttest_means_raw <- as_tibble(svyby(~hrs1, ~sex, ttest_design, svymean, vartype = c("ci")))
ttest_mean_col <- setdiff(
  names(ttest_means_raw),
  c("sex", grep("^se\\.|^ci_", names(ttest_means_raw), value = TRUE))
)[1]

ttest_lookup <- setNames(ttest_means_raw[[ttest_mean_col]], as.character(ttest_means_raw$sex))
ttest_result <- svyttest(hrs1 ~ sex, ttest_design)
ttest_diff <- unname(ttest_lookup["Women"] - ttest_lookup["Men"])
ttest_t <- unname(ttest_result$statistic)
ttest_p <- unname(ttest_result$p.value)
ttest_df <- unname(ttest_result$parameter)
ttest_diff_ci <- unname(ttest_result$conf.int)

ttest_console_output <- glue(
  "Two Sample t-test\n\n",
  "data: hrs1 by sex\n",
  "t = {fmt_num(ttest_t, 2)}, df = {round(ttest_df)}, p-value {ifelse(ttest_p < 0.001, '< 0.001', paste0('= ', fmt_num(ttest_p, 3)))}\n",
  "alternative hypothesis: true difference in mean is not equal to 0\n",
  "95 percent confidence interval:\n",
  " {fmt_num(ttest_diff_ci[1], 2)} {fmt_num(ttest_diff_ci[2], 2)}\n",
  "sample estimates:\n",
  "mean in group Men   {fmt_num(ttest_lookup['Men'], 1)}\n",
  "mean in group Women {fmt_num(ttest_lookup['Women'], 1)}"
)

ols_cat_data <- gss |>
  filter(
    is.na(prestg10) == FALSE,
    is.na(degree4) == FALSE,
    is.na(age) == FALSE,
    is.na(female) == FALSE,
    is.na(wtssnrps_as) == FALSE
  )

ols_cat_model <- lm(
  prestg10 ~ degree4 + age + female,
  data = ols_cat_data,
  weights = wtssnrps_as
)

ols_cat_coef <- coef(ols_cat_model)
ols_cat_r2 <- summary(ols_cat_model)$r.squared

ols_cat_table <- make_model_table_df(
  model = ols_cat_model,
  model_name = "Prestige score",
  coef_map = c(
    "(Intercept)" = "Intercept",
    "age" = "Age",
    "female" = "Female (1 = yes)",
    "degree4HS or less" = "HS or less",
    "degree4Some college" = "Some college",
    "degree4Graduate degree" = "Graduate degree"
  )
)

logit_data <- gss |>
  filter(
    is.na(homeowner) == FALSE,
    is.na(educ) == FALSE,
    is.na(age) == FALSE,
    is.na(female) == FALSE,
    is.na(wtssnrps_as) == FALSE
  )

logit_model <- suppressWarnings(
  glm(
    homeowner ~ educ + age + female,
    data = logit_data,
    family = binomial(),
    weights = wtssnrps_as
  )
)

logit_or <- exp(coef(logit_model))

logit_table <- make_model_table_df(
  model = logit_model,
  model_name = "Odds ratio",
  coef_map = c(
    "(Intercept)" = "Intercept",
    "educ" = "Education (years)",
    "age" = "Age",
    "female" = "Female (1 = yes)"
  ),
  exponentiate = TRUE,
  gof_keep = c("Num.Obs.", "AIC")
)

interact_cc_data <- gss |>
  filter(
    is.na(hrs1) == FALSE,
    is.na(educ) == FALSE,
    is.na(age) == FALSE,
    is.na(female) == FALSE,
    is.na(wtssnrps_as) == FALSE
  )

interact_cc_model <- lm(
  hrs1 ~ educ + age + educ:age + female,
  data = interact_cc_data,
  weights = wtssnrps_as
)

interact_cc_coef <- coef(interact_cc_model)

interact_cc_table <- make_model_table_df(
  model = interact_cc_model,
  model_name = "Hours worked",
  coef_map = c(
    "(Intercept)" = "Intercept",
    "educ" = "Education (years)",
    "age" = "Age",
    "educ:age" = "Education x Age",
    "female" = "Female (1 = yes)"
  )
)

interact_cb_data <- gss |>
  filter(
    is.na(prestg10) == FALSE,
    is.na(educ) == FALSE,
    is.na(age) == FALSE,
    is.na(married) == FALSE,
    is.na(female) == FALSE,
    is.na(wtssnrps_as) == FALSE
  )

interact_cb_model <- lm(
  prestg10 ~ age + female + educ + married + educ:married,
  data = interact_cb_data,
  weights = wtssnrps_as
)

interact_cb_coef <- coef(interact_cb_model)

interact_cb_table <- make_model_table_df(
  model = interact_cb_model,
  model_name = "Prestige score",
  coef_map = c(
    "(Intercept)" = "Intercept",
    "age" = "Age",
    "female" = "Female (1 = yes)",
    "educ" = "Education (years)",
    "married" = "Married (1 = yes)",
    "educ:married" = "Education x Married"
  )
)

margins_cc_data <- expand_grid(
  educ = c(8, 12, 16),
  age = c(30, 45, 60),
  female = 0
)

margins_cc_pred <- as_tibble(predict(interact_cc_model, newdata = margins_cc_data, interval = "confidence"))

margins_cc_plot_data <- bind_cols(margins_cc_data, margins_cc_pred) |>
  mutate(age_group = factor(age, levels = c(30, 45, 60), labels = c("Age 30", "Age 45", "Age 60")))

margins_cc_plot <- ggplot(
  margins_cc_plot_data,
  aes(x = educ, y = fit, color = age_group, linetype = age_group, group = age_group)
) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2.3) +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.25, linewidth = 0.4) +
  scale_color_manual(values = c("Age 30" = "#0b6e4f", "Age 45" = "#1d4e89", "Age 60" = "#a63a50")) +
  scale_linetype_manual(values = c("Age 30" = "solid", "Age 45" = "dashed", "Age 60" = "dotdash")) +
  scale_x_continuous(breaks = c(8, 12, 16)) +
  labs(
    x = "Years of education",
    y = "Predicted hours worked last week",
    color = "Age",
    linetype = "Age"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "top",
    panel.grid.minor = element_blank()
  )

age30_preds <- margins_cc_plot_data |>
  filter(age_group == "Age 30") |>
  pull(fit)

age60_preds <- margins_cc_plot_data |>
  filter(age_group == "Age 60") |>
  pull(fit)

flawed_data <- gss |>
  filter(
    is.na(wtssnrps_as) == FALSE,
    is.na(homeowner) == FALSE,
    sex %in% c("male", "female")
  ) |>
  mutate(
    sex = factor(sex, levels = c("male", "female"), labels = c("Men", "Women"))
  )

flawed_props_raw <- as_tibble(svyby(~homeowner, ~sex, make_design(flawed_data), svymean))
flawed_home_col <- setdiff(names(flawed_props_raw), "sex")[1]

flawed_props <- flawed_props_raw |>
  transmute(
    sex = as.character(sex),
    pct = 100 * .data[[flawed_home_col]]
  )

flawed_plot <- ggplot(flawed_props, aes(x = sex, y = pct, group = 1)) +
  geom_line(color = "#b22222", linewidth = 1.2) +
  geom_point(color = "#b22222", size = 3) +
  scale_y_continuous(limits = c(60, 75), breaks = seq(60, 75, 5)) +
  labs(
    title = "Women Are Much More Likely to Own Their Homes",
    x = "",
    y = "Number of homeowners"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    panel.grid.minor = element_blank()
  )

married_ci_data <- gss |>
  filter(
    is.na(wtssnrps_as) == FALSE,
    is.na(married) == FALSE
  )

married_prop_ci <- svyciprop(~I(married == 1), design = make_design(married_ci_data), method = "logit")
married_estimate <- as.numeric(coef(married_prop_ci))
married_interval <- as.numeric(confint(married_prop_ci))

married_ci_table <- tibble(
  `Point estimate` = fmt_pct(married_estimate, 1),
  `95% confidence interval` = fmt_ci(
    married_interval[1],
    married_interval[2],
    digits = 1,
    percent = TRUE
  )
)
