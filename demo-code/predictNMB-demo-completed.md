# predictNMB-demo
Rex Parsons

If you haven’t already, please install the package.

``` r
install.packages("predictNMB", dependencies = "Suggests")
remotes::install_github("ropensci/predictNMB", dependencies = "Suggests")
```

``` r
library(predictNMB)
```

    Warning: package 'predictNMB' was built under R version 4.2.3

``` r
library(ggplot2)
library(parallel)
```

## pre-`{predictNMB}` primer on the distributions we will be using.

We will be using different distributions to sample different inputs for
our simulation. A gamma distribution is often appropriate when sampling
\$ and a beta distribution is often best when sampling QALYs due to the
shape and limits being sensible (the cost of treatment is unlikely be to
be negative and QALYs are bounded to be between 0 and 1, similar to a
probability of an event). We can sample from these distributions using R
code with the `rgamma()` and `rbeta()` functions:

``` r
data.frame(QALYs_lost = rbeta(10000, shape1 = 2.95, shape2 = 32.25)) |>
  ggplot(aes(x = QALYs_lost)) + 
  geom_histogram() +
  theme_bw() +
  labs(title = "QALYs lost associated with inpatient fall")
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-4-1.png)

``` r
data.frame(fall_costs = rgamma(10000, shape = 22.05, rate = 0.0033)) |>
  ggplot(aes(x = fall_costs)) + 
  geom_histogram() +
  theme_bw() +
  labs(title = "Healthcare costs associated with inpatient fall") +
  scale_x_continuous(labels = scales::dollar_format())
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-4-2.png)

## Example problem and inputs required - inpatient falls

- Falls leads to about 0.04 lost Quality-Adjusted Life Years (QALYs)
  (Latimer et al. 2013) and has an approximate beta distribution of:
  $$\mathrm{B}(\alpha = 2.95, \beta = 32.25)$$  

- There are also additional healthcare costs of about \$6669 (Morello et
  al. 2015) and follows an approximate gamma distribution of:
  $$\Gamma (\alpha = 22.05, \beta = 0.0033) $$

- Fall prevention education…

  - has a fixed, known cost of \$77.3 per patient (Hill et al. 2015)
  - reduces probability of fall by 45% (Haines et al. 2011) - the log
    hazard ratio follows an approximate normal distribution of:
    $$\mathcal{N}(\mu = -0.844, \sigma = 0.304) $$

- The willingness-to-pay (WTP) for us is \$28033 AUD

- Current practice: Everyone gets the fall prevention intervention
  (treat-all approach).

Calculations and code for using details in paper cited papers above is
described in (Parsons et al. 2023). We used `{fitdistrplus}` but you can
also use a shiny app by Nicole White and Robin Blythe: `ShinyPrior`
(White and Blythe 2023).

| Input                     | Distribution                                         | R code                                         |
|---------------------------|------------------------------------------------------|------------------------------------------------|
| QALYs lost                | $$\mathrm{B}(\alpha = 2.95, \beta = 32.25)$$         | `rbeta(n = 1, shape1 = 2.95, shape2 = 32.25`   |
| Healthcare costs          | $$\Gamma (\alpha = 22.05, \beta = 0.0033) $$         | `rgamma(n = 1, shape = 22.05, rate = 0.0033)`  |
| Treatment effect (hazard) | $$\exp(\mathcal{N}(\mu = -0.844, \sigma = 0.304)) $$ | `exp(rnorm(n = 1, mean = -0.844, sd = 0.304))` |
| Treatment cost            | \$77.30                                              | \-                                             |
| WTP                       | \$28033                                              | \-                                             |

We will be using these sampling functions within our NMB sampling
functions!

![](https://media1.giphy.com/media/7pHTiZYbAoq40/giphy.gif)

## Objectives/Questions

- We have a prediction model which has an AUC of about 0.8 and we want
  to know whether it’ll be worthwhile implementing it within a CDSS to
  reduce healthcare costs (giving people that are unlikely to fall the
  intervention at \$77.3 a pop!)

- We are currently in a geriatric ward where the fall rate is about 0.1
  (1 in 10 admitted patients have a fall) but are also interested in
  implementing the same model in the acute care ward (fall rate = 0.03).
  Would we expect to make the same conclusion?

- We think we can improve the performance of the model up to 0.95 with
  some extra effort by the models - would this change our conclusion?

## `{predictNMB}`

## Making our samplers

``` r
validation_sampler <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 77.3,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = FALSE
)


training_sampler <- get_nmb_sampler(
  outcome_cost = function()  rgamma(1, shape = 22.05, rate = 0.0033),
  wtp = 28033,
  qalys_lost = function() rbeta(1, shape1 = 2.95, shape2 = 32.25),
  high_risk_group_treatment_effect = function() exp(rnorm(1, mean = -0.844, sd = 0.304)),
  high_risk_group_treatment_cost = 77.3,
  low_risk_group_treatment_effect = 0,
  low_risk_group_treatment_cost = 0,
  use_expected_values = TRUE
)
```

## Primary analyses

### Running our simulation (primary use-case)

``` r
cl <- makeCluster(detectCores() - 1)

primary_sim <- do_nmb_sim(
  n_sims = 500,
  n_valid = 10000,
  sim_auc = 0.8,
  event_rate = 0.1,
  cutpoint_methods = c("all", "none", "youden", "value_optimising"),
  fx_nmb_training = training_sampler,
  fx_nmb_evaluation = validation_sampler,
  show_progress = TRUE,
  cl = cl
)
```

### Interpreting our results

``` r
summary(primary_sim)
```

    # A tibble: 4 × 3
      method           median `95% CI`         
      <chr>             <dbl> <chr>            
    1 all               -582. -937.2 to -289.3 
    2 none              -911. -1336.4 to -567.4
    3 value optimising  -583. -965 to -291.4   
    4 youden            -654. -1019.4 to -353.6

``` r
autoplot(primary_sim) + theme_sim()
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-7-1.png)

``` r
autoplot(primary_sim, what = "cutpoints") + theme_sim()
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-7-2.png)

``` r
autoplot(primary_sim, what = "inb", inb_ref_col = "all") + theme_sim()
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-7-3.png)

``` r
autoplot(primary_sim, what = "qalys") + theme_sim()
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-7-4.png)

``` r
autoplot(primary_sim, what = "costs") + theme_sim()
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-7-5.png)

``` r
ce_plot(primary_sim, ref_col = "all")
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-7-6.png)

``` r
ce_plot(primary_sim, ref_col = "all", add_prop_ce = TRUE)
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-7-7.png)

## Acute care setting?

``` r
acute_care_sim <- do_nmb_sim(
  n_sims = 500,
  n_valid = 10000,
  sim_auc = 0.8,
  event_rate = 0.03,
  cutpoint_methods = c("all", "none", "youden", "value_optimising"),
  fx_nmb_training = training_sampler,
  fx_nmb_evaluation = validation_sampler,
  show_progress = TRUE,
  cl = cl
)

summary(acute_care_sim)
```

    # A tibble: 4 × 3
      method           median `95% CI`        
      <chr>             <dbl> <chr>           
    1 all               -228. -334.2 to -135.4
    2 none              -271. -407.8 to -169.9
    3 value optimising  -209. -317.4 to -122.2
    4 youden            -213. -325.5 to -123.5

``` r
summary(acute_care_sim, what = "cutpoints")
```

    # A tibble: 4 × 3
      method           median `95% CI`
      <chr>             <dbl> <chr>   
    1 all                0    0 to 0  
    2 none               1    1 to 1  
    3 value optimising   0.02 0 to 0.1
    4 youden             0.03 0 to 0.1

``` r
autoplot(acute_care_sim) + theme_sim()
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-8-1.png)

``` r
ce_plot(acute_care_sim, ref_col = "all", add_prop_ce = TRUE)
```

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-8-2.png)

## What if we improve the model discrimination (AUC)?

``` r
auc_screen <- screen_simulation_inputs(
  n_sims = 500,
  n_valid = 10000,
  sim_auc = seq(0.8, 0.95, 0.05),
  event_rate = 0.1,
  cutpoint_methods = c("all", "none", "youden", "value_optimising"),
  fx_nmb_training = training_sampler,
  fx_nmb_evaluation = validation_sampler,
  show_progress = TRUE,
  cl = cl
)
```

    Running simulation: [1/4]

    Running simulation: [2/4]

    Running simulation: [3/4]

    Running simulation: [4/4]

``` r
autoplot(auc_screen)
```

    No value for 'x_axis_var' given.

    Screening over sim_auc by default

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-9-1.png)

## Bonus - What if our intervention were cheaper or more expensive?

``` r
# see 'demo-code/cost-of-treatment-screen.R' for code!
cost_screen <- readRDS(gzcon(url("https://github.com/RWParsons/rmed2023-predictNMB/raw/main/demo-code/saved-sims/cost_screen.rds")))

summary(cost_screen)
```

    # A tibble: 6 × 10
      fx_nmb_train…¹ fx_nm…² all_m…³ all_9…⁴ none_…⁵ none_…⁶ youde…⁷ youde…⁸ value…⁹
      <chr>          <chr>     <dbl> <chr>     <dbl> <chr>     <dbl> <chr>     <dbl>
    1 A-50           A-50      -546. -869.8…   -895. -1322.…   -633. -992 t…   -553.
    2 B-77.30        B-77.30   -568. -949.6…   -898. -1368.…   -636. -1041.…   -571.
    3 C-100          C-100     -594. -937.1…   -893. -1341.…   -653. -1014.…   -596.
    4 D-150          D-150     -644. -1016.…   -893. -1352.…   -669. -1054.…   -631.
    5 E-250          E-250     -743. -1075.…   -893. -1353.…   -690. -1062.…   -682.
    6 F-500          F-500     -991. -1334.…   -880. -1320.…   -764. -1106.…   -763.
    # … with 1 more variable: `value optimising_95% CI` <chr>, and abbreviated
    #   variable names ¹​fx_nmb_training, ²​fx_nmb_evaluation, ³​all_median,
    #   ⁴​`all_95% CI`, ⁵​none_median, ⁶​`none_95% CI`, ⁷​youden_median,
    #   ⁸​`youden_95% CI`, ⁹​`value optimising_median`

``` r
autoplot(cost_screen) +
  scale_x_discrete(labels = function(x) stringr::str_replace(x, "[A-Z]\\-", "$"))
```

    No value for 'x_axis_var' given.

    Screening over fx_nmb_training by default. Specify the variable in the 'x_axis_var' argument if you want to plot changes over:
    fx_nmb_evaluation



    Varying simulation inputs, other than fx_nmb_training, are being held constant:

![](predictNMB-demo-completed_files/figure-commonmark/unnamed-chunk-10-1.png)

# References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-haines2011patient" class="csl-entry">

Haines, Terry P, Anne-Marie Hill, Keith D Hill, Steven McPhail, David
Oliver, Sandra Brauer, Tammy Hoffmann, and Christopher Beer. 2011.
“Patient Education to Prevent Falls Among Older Hospital Inpatients: A
Randomized Controlled Trial.” *Archives of Internal Medicine* 171 (6):
516–24.

</div>

<div id="ref-hill2015fall" class="csl-entry">

Hill, Anne-Marie, Steven M McPhail, Nicholas Waldron, Christopher
Etherton-Beer, Katharine Ingram, Leon Flicker, Max Bulsara, and Terry P
Haines. 2015. “Fall Rates in Hospital Rehabilitation Units After
Individualised Patient and Staff Education Programmes: A Pragmatic,
Stepped-Wedge, Cluster-Randomised Controlled Trial.” *The Lancet* 385
(9987): 2592–99.

</div>

<div id="ref-latimer13" class="csl-entry">

Latimer, Nicholas, Simon Dixon, Amy Kim Drahota, and Martin Severs.
2013. “<span class="nocase">Cost–utility analysis of a shock-absorbing
floor intervention to prevent injuries from falls in hospital wards for
older people</span>.” *Age and Ageing* 42 (5): 641–45.
<https://doi.org/10.1093/ageing/aft076>.

</div>

<div id="ref-morello2015extra" class="csl-entry">

Morello, Renata T, Anna L Barker, Jennifer J Watts, Terry Haines, Silva
S Zavarsek, Keith D Hill, Caroline Brand, et al. 2015. “The Extra
Resource Burden of in-Hospital Falls: A Cost of Falls Study.” *Medical
Journal of Australia* 203 (9): 367–67.

</div>

<div id="ref-parsons2023cutpoints" class="csl-entry">

Parsons, Rex, Robin Blythe, Susanna M Cramb, and Steven M McPhail. 2023.
“Integrating Economic Considerations into Cutpoint Selection May Help
Align Clinical Decision Support Toward Value-Based Healthcare.” *Journal
of the American Medical Informatics Association*, March.
<https://doi.org/10.1093/jamia/ocad042>.

</div>

<div id="ref-white2023shinyprior" class="csl-entry">

White, Nicole, and Robin Blythe. 2023. “ShinyPrior: A Tool for
Estimating Probability Distributions Using Published Evidence.” OSF
Preprints zf62e. Center for Open Science.
<https://EconPapers.repec.org/RePEc:osf:osfxxx:zf62e>.

</div>

</div>
