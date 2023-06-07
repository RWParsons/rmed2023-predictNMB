# cost-of-treatment-screen.R

library(predictNMB)
library(parallel)

validation_sampler50 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 50,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = FALSE
)


training_sampler50 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 50,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = TRUE
)

validation_sampler77 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 77.3,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = FALSE
)


training_sampler77 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 77.3,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = TRUE
)

validation_sampler100 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 100,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = FALSE
)


training_sampler100 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 100,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = TRUE
)

validation_sampler150 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 150,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = FALSE
)


training_sampler150 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 150,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = TRUE
)

validation_sampler250 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 250,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = FALSE
)


training_sampler250 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 250,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = TRUE
)

validation_sampler500 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 500,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = FALSE
)


training_sampler500 <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 500,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = TRUE
)

cl <- makeCluster(detectCores())
cost_screen <- screen_simulation_inputs(
  n_sims = 1000,
  n_valid = 10000,
  sim_auc = 0.8,
  event_rate = 0.1,
  cutpoint_methods = c("all", "none", "youden", "value_optimising"),
  fx_nmb_training = list(
    "A-50"=training_sampler50,
    "B-77.30"=training_sampler77,
    "C-100"=training_sampler100,
    "D-150"=training_sampler150,
    "E-250"=training_sampler250,
    "F-500"=training_sampler500
  ),
  fx_nmb_evaluation = list(
    "A-50"=validation_sampler50,
    "B-77.30"=validation_sampler77,
    "C-100"=validation_sampler100,
    "D-150"=validation_sampler150,
    "E-250"=validation_sampler250,
    "F-500"=validation_sampler500
  ),
  pair_nmb_train_and_evaluation_functions = TRUE,
  show_progress = TRUE,
  cl = cl
)

saveRDS(cost_screen, file.path(here::here("demo-code", "saved-sims"), "cost_screen.rds"))
