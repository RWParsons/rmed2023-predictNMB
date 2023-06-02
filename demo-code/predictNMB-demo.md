# predictNMB-demo
Rex Parsons

If you haven’t already, please install the package.

``` r
install.packages("predictNMB", dependencies = "Suggests")
remotes::install_github("ropensci/predictNMB", dependencies = "Suggests")
```

``` r
library(predictNMB)
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

![](predictNMB-demo_files/figure-commonmark/unnamed-chunk-4-1.png)

``` r
data.frame(fall_costs = rgamma(10000, shape = 22.05, rate = 0.0033)) |>
  ggplot(aes(x = fall_costs)) + 
  geom_histogram() +
  theme_bw() +
  labs(title = "Healthcare costs associated with inpatient fall") +
  scale_x_continuous(labels = scales::dollar_format())
```

![](predictNMB-demo_files/figure-commonmark/unnamed-chunk-4-2.png)

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
validation_sampler <- get_nmb_sampler()

training_sampler <- get_nmb_sampler()
```

## Primary analyses

### Running our simulation (primary use-case)

``` r
cl <- makeCluster(detectCores() - 1)

primary_sim <- do_nmb_sim()

# primary_sim <- readRDS(file.path(here::here("demo-code", "saved-sims"), "primary_sim.rds"))
```

### Interpreting our results

``` r
summary(primary_sim)
autoplot(primary_sim) + theme_sim()
ce_plot(primary_sim)
```

## Acute care setting?

``` r
acute_care_sim <- do_nmb_sim()

# acute_care_sim <- readRDS(file.path(here::here("demo-code", "saved-sims"), "acute_care_sim.rds"))

summary(acute_care_sim)
autoplot(acute_care_sim)
ce_plot(acute_care_sim)
```

## What if we improve the model discrimination (AUC)?

``` r
auc_screen <- screen_simulation_inputs()

# auc_screen <- readRDS(file.path(here::here("demo-code", "saved-sims"), "auc_screen.rds"))
```

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
