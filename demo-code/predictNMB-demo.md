# predictNMB-demo
Rex Parsons

## Example problem and inputs required - inpatient falls

- Falls leads to about 0.04 lost Quality-Adjusted Life Years (QALYs)
  (Latimer et al. 2013) and has an approximate beta distribution of:
  $$\mathrm{B}(\alpha = 3.07, \beta = 70.01) \times 2$$  

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
described in (Parsons et al. 2023).

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

## pre-`{predictNMB}` primer on the distributions we will be using.

## `{predictNMB}`

``` r
library(predictNMB)
```

## Making our samplers

``` r
training_sampler <- get_nmb_sampler()

validation_sampler <- get_nmb_sampler()
```

## Running our simulation (primary use-case)

``` r
primary_sim <- do_nmb_sim()
```

## Interpreting our results

``` r
autoplot(primary_sim)

ce_plot(primary_sim)
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

</div>
