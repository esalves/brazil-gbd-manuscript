// ─────────────────────────────────────────────────────────────────────────────
// Shifting Mortality Burden in Brazil, 1990–2023
// Typst manuscript source
// ─────────────────────────────────────────────────────────────────────────────

// ── Page & typography ────────────────────────────────────────────────────────
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
  numbering: "1",
  number-align: center,
)

#set text(font: "Linux Libertine", size: 11pt, lang: "en")
#set heading(numbering: "1.")
#set par(justify: true, leading: 0.65em, spacing: 1.2em)

// ── Colour helpers ───────────────────────────────────────────────────────────
#let green-dark = rgb("#1a7a4a")
#let red-dark = rgb("#c0392b")
#let grey-light = rgb("#f5f5f5")
#let grey-border = rgb("#cccccc")

// ── Reusable components ──────────────────────────────────────────────────────
#let note(body) = block(
  fill: grey-light,
  stroke: 1pt + grey-border,
  inset: 8pt,
  radius: 4pt,
  body,
)

// Bold percentage-change tags used inline
#let pct-up(v) = text(fill: red-dark, weight: "bold", v)
#let pct-down(v) = text(fill: green-dark, weight: "bold", v)

// ── Title block ──────────────────────────────────────────────────────────────
#align(center)[
  #text(size: 16pt, weight: "bold")[
    Shifting Mortality Burden in Brazil, 1990–2023:
    Age-Standardised Trends Across Cause Categories
    from the Global Burden of Disease Study 2023
  ]
  #v(0.6em)
  #text(size: 10.5pt, style: "italic")[
    Descriptive Cross-sectional Analysis of GBD 2023 Estimates (IHME)
  ]
  #v(0.4em)
  #text(size: 10pt)[June 2026 · Preprint, not yet peer reviewed]

  #v(0.8em)
  #text(size: 11pt, weight: "medium")[
    Eduardo S. A. Santos #footnote[Corresponding author: #link("mailto:esantos2@ualberta.ca")[esantos2\@ualberta.ca]]
  ] \
  #v(0.2em)
  #text(size: 9pt, fill: rgb("#555555"))[
    Department of Biological Sciences, Faculty of Science, University of Alberta, Edmonton, AB, Canada \
    #text(size: 8.5pt)[ORCID: #link("https://orcid.org/0000-0002-0434-3655")[0000-0002-0434-3655]]
  ]
]

#v(1.5em)
#line(length: 100%, stroke: 0.5pt)
#v(1em)

// ── Abstract ─────────────────────────────────────────────────────────────────
= Abstract

*Background.* Brazil has undergone a marked epidemiological transition over the
past three decades. Identifying which cause-of-death categories have driven
mortality improvements and which now impose a growing burden is essential for
health-system planning. Crucially, because Brazil's population has aged
substantially since 1990, summary mortality measures that do not account for
age structure can mislead.

*Methods.* Using age-specific death rates (deaths per 100,000) from the Global
Burden of Disease (GBD) Study 2023 for Brazil (1990 and 2023, both sexes, 25
age groups), we computed age-standardised death rates (ASRs) for 21 Level-2
cause categories by direct standardisation to the WHO World Standard
Population. The relative percent change in ASR between 1990 and 2023 was the
primary outcome; 95% uncertainty intervals were obtained by Monte Carlo
propagation of each age group's GBD interval (10,000 draws per cause). For
comparison we also computed the unweighted mean of the 25 age-specific rates —
the summary statistic displayed by the GBD Compare tool — which weights every
age band equally.

*Results.* Of 21 cause categories, 15 showed decreased and six showed increased
age-standardised mortality between 1990 and 2023. The largest standardised
reductions were in enteric infections (#pct-down[−90.9%], 95% CI −91.4% to
−90.4%), nutritional deficiencies (#pct-down[−82.1%]), neglected tropical
diseases and malaria (#pct-down[−75.1%]), maternal and neonatal disorders
(#pct-down[−60.8%]), and cardiovascular diseases (#pct-down[−54.8%]). The
largest standardised increases were in skin and subcutaneous diseases
(#pct-up[+206.8%], 95% CI +191.9% to +221.8%), other non-communicable diseases
(#pct-up[+65.0%]), and substance use disorders (#pct-up[+16.1%]). Three
categories — unintentional injuries, neoplasms, and diabetes and kidney
diseases — rose on the unweighted-mean metric but declined once
age-standardised (e.g. unintentional injuries: unweighted #pct-up[+26.2%] vs
standardised #pct-down[−19.0%], 95% CI −21.5% to −16.4%), indicating that their
apparent rise reflects population ageing rather than higher age-specific risk.

*Interpretation.* Brazil's mortality profile has shifted from communicable,
perinatal, and nutritional causes toward non-communicable diseases — a classic
epidemiological transition. Age standardisation reverses the apparent direction
of several trends, underscoring that age structure must be accounted for before
mortality changes are interpreted or acted upon.

*Keywords:* epidemiological transition; Brazil; mortality; Global Burden of
Disease; non-communicable diseases; age standardisation.

#v(1em)
#line(length: 100%, stroke: 0.5pt)
#v(1em)

// ── 1. Introduction ──────────────────────────────────────────────────────────
= Introduction

Brazil, Latin America's most populous country, has experienced one of the most
substantial public-health transformations of recent decades. The
implementation of the Unified Health System (Sistema Único de Saúde, SUS) from
1990 onward, successive improvements in water and sanitation infrastructure,
large-scale immunisation campaigns, and conditional cash-transfer programmes
such as Bolsa Família collectively drove steep reductions in child and
infectious-disease mortality [1]. Over the same period, urbanisation, dietary
change, reduced physical activity, and a rapidly ageing population fuelled a
growing non-communicable disease (NCD) burden [2].

The concept of epidemiological transition, articulated by Omran [3], describes
the shift from mortality dominated by infection and undernutrition toward
chronic, degenerative conditions and injuries. Brazil is frequently described
as undergoing a "polarised" or "protracted" transition, in which residual
communicable-disease mortality and a rising NCD burden coexist, often
concentrated in different age groups or regions [4].

Quantifying the magnitude and age-pattern of these shifts across all major
cause categories simultaneously, within a globally harmonised framework,
provides an evidence base for prioritising health investment. The Global Burden
of Disease (GBD) Study, produced by the Institute for Health Metrics and
Evaluation (IHME), offers the most comprehensive such assessment, covering 204
countries and territories and a hierarchy of diseases and injuries within a
common comparative framework [5].

A central methodological issue motivates this analysis. Brazil's population
aged dramatically between 1990 and 2023: the median age roughly doubled and the
share of the population aged 60 years and over more than doubled [6]. Because
mortality rates for most chronic diseases and many injuries rise steeply with
age, any summary measure that does not hold age structure constant can register
an apparent increase in mortality even when age-specific risk is falling. We
therefore make age-standardised death rates the primary outcome and contrast
them with the unweighted mean of age-specific rates that is displayed by the
widely used GBD Compare tool, to characterise both the true direction of change
and the cases in which the two measures disagree.

// ── 2. Methods ───────────────────────────────────────────────────────────────
= Methods

This descriptive cross-sectional study analyses aggregated, publicly available
mortality estimates; it is reported in accordance with the STROBE guideline for
cross-sectional studies [7] (checklist provided as Supplementary Material).

== Data Source

Age-specific death rates (deaths per 100,000 population) were obtained from the
IHME GBD Compare / GBD Results tool for Brazil, both sexes combined, for the
calendar years 1990 and 2023, across all 25 GBD age groups (0–6 days through
95+ years) and the 22 Level-2 cause categories of the GBD cause hierarchy. One
category (sense organ diseases) carried no mortality estimate and was excluded,
leaving 21 categories. For every age group the tool provides a point estimate
and a 95% uncertainty interval. Data were extracted on 4 June 2026. The
underlying data are cited as:

#note[
  Institute for Health Metrics and Evaluation (IHME). _GBD Compare / GBD
  Results tool. Global Burden of Disease (GBD) Study 2023._ Seattle, WA: IHME,
  University of Washington, 2025. Available from
  https://vizhub.healthdata.org/gbd-compare/ and
  https://vizhub.healthdata.org/gbd-results/. Accessed 4 June 2026.
]

== Primary analysis: age-standardised death rates

For each cause and year we computed the age-standardised death rate (ASR) by
direct standardisation to the WHO World Standard Population [8], an external,
fixed standard:

$ "ASR"_"cause, year" = sum_(i=1)^25 r_(i,"cause, year") dot w_i^"std" $

where $r_(i,"cause, year")$ is the GBD age-specific death rate (per 100,000) in
age group $i$ and $w_i^"std"$ is the normalised WHO World Standard weight for
that group. The WHO standard is specified in conventional five-year bands; its
0–4-year weight was apportioned across the six GBD sub-groups that span ages
0–4 in proportion to the person-years each represents, and its two open-ended
bands (95–99 and 100+) were combined to match the GBD "95+" group. Because the
same fixed standard is applied to both years, the 1990 and 2023 ASRs are
directly comparable and are unaffected by Brazil's changing age structure. The
primary outcome was the relative percent change in ASR:

$ Delta%_"std" = ("ASR"_"2023" - "ASR"_"1990") / "ASR"_"1990" times 100 $

Categories were classified as improving ($Delta%_"std" < 0$) or worsening
($Delta%_"std" > 0$).

== Uncertainty propagation

ASR point estimates were computed deterministically from the reported GBD point
rates. To propagate GBD estimation uncertainty into the percent change, we used
Monte Carlo simulation with 10,000 draws per cause. For each draw, every
age-specific rate was sampled independently from a log-normal distribution
whose median equalled the GBD point estimate and whose dispersion reproduced
the reported 95% interval; for the small number of age groups with a
non-positive lower bound, a normal distribution truncated at zero was used
instead. The 95% uncertainty interval for $Delta%_"std"$ is the 2.5th–97.5th
percentile of the simulated distribution. To guarantee exact reproducibility
irrespective of execution order, each cause–year simulation was seeded
deterministically from the cause label.

== Comparison metric

For comparison we computed the *unweighted mean of the 25 age-specific rates*,
$macron(r) = (1\/25) sum_i r_i$, which is the summary statistic displayed by
the GBD Compare tool. This metric assigns each age band equal weight regardless
of its share of the population and is reported only to identify causes whose
direction of change differs from the age-standardised result. It is not an
age-standardised rate and is not used for inference.

== Software and reproducibility

All analyses were performed in Python 3. The unweighted-mean metric is
reproduced by `scripts/analysis.py` (standard library only); the
age-standardised analysis and uncertainty propagation by
`scripts/analysis_standardised.py` (using NumPy); and the figures by
`scripts/figures.py`, which imports the analysis module so that every plotted
value is produced by the same code path. Data, code, and this manuscript source
are openly available (see Data and Code Availability).

== Ethics

This study uses publicly available, de-identified, aggregated data; no
individual-level data were collected or analysed. Institutional review board
approval was not required.

// ── 3. Results ───────────────────────────────────────────────────────────────
= Results

== Overview

Of the 21 cause categories analysed, 15 showed a decreased and six an increased
age-standardised mortality rate between 1990 and 2023 (Table 1). Three
categories — unintentional injuries, neoplasms, and diabetes and kidney
diseases — increased on the unweighted-mean metric but declined once
age-standardised; no category moved in the opposite direction. Reductions were
concentrated in communicable, perinatal, and nutritional causes, and increases
in non-communicable categories, consistent with an epidemiological transition.

#figure(
  caption: [Age-standardised death rates (deaths per 100,000, WHO World
    Standard Population) per cause category in Brazil, 1990 and 2023, sorted by
    percent change in the age-standardised rate. The final column also shows
    the change in the unweighted mean of the 25 age-specific rates (the GBD
    Compare display metric) for comparison. 95% uncertainty intervals are from
    Monte Carlo propagation of GBD intervals (n = 10,000). † Direction of change
    differs between the two metrics.],
  kind: table,
)[
  #set text(size: 9pt)
  #table(
    columns: (1.7fr, auto, auto, 1.5fr, auto),
    align: (left, right, right, right, right),
    stroke: none,
    fill: (col, row) => if row == 0 { rgb("#2c3e50") } else if calc.odd(row) { rgb("#f9f9f9") } else { white },
    inset: (x: 7pt, y: 4.5pt),

    text(fill: white, weight: "bold")[Cause of death or injury],
    text(fill: white, weight: "bold")[ASR 1990],
    text(fill: white, weight: "bold")[ASR 2023],
    text(fill: white, weight: "bold")[Δ% ASR (95% CI)],
    text(fill: white, weight: "bold")[Δ% mean],

    [Enteric infections], [27.3], [2.5], pct-down[−90.9 (−91.4, −90.4)], [−90.1],
    [Nutritional deficiencies], [10.0], [1.8], pct-down[−82.1 (−83.3, −80.8)], [−73.0],
    [Neglected tropical diseases & malaria], [13.6], [3.4], pct-down[−75.1 (−76.8, −71.4)], [−66.1],
    [Other infectious diseases], [7.4], [1.9], pct-down[−74.2 (−75.0, −73.3)], [−82.8],
    [Maternal & neonatal disorders], [29.9], [11.7], pct-down[−60.8 (−63.1, −58.4)], [−60.4],
    [Cardiovascular diseases], [293.7], [132.6], pct-down[−54.8 (−56.4, −53.1)], [−51.4],
    [Transport injuries], [31.1], [17.8], pct-down[−42.8 (−44.8, −40.8)], [−55.2],
    [Chronic respiratory diseases], [42.3], [25.3], pct-down[−40.2 (−43.2, −37.1)], [−34.6],
    [Digestive diseases], [39.3], [29.3], pct-down[−25.3 (−27.7, −22.7)], [−8.7],
    [Respiratory infections & tuberculosis], [52.9], [41.1], pct-down[−22.2 (−26.0, −18.3)], [−20.9],
    [Unintentional injuries †], [23.1], [18.7], pct-down[−19.0 (−21.5, −16.4)], pct-up[+26.2],
    [Mental disorders #super[a]], [\<0.01], [\<0.01], pct-down[−12.7 (−46.0, +34.1)], [−13.2],
    [Neoplasms †], [117.9], [105.6], pct-down[−10.4 (−12.7, −8.0)], pct-up[+0.1],
    [Diabetes & kidney diseases †], [44.9], [40.4], pct-down[−10.0 (−13.5, −6.2)], pct-up[+16.3],
    [Self-harm & interpersonal violence], [34.9], [34.4], pct-down[−1.6 (−4.9, +1.6)], [−15.5],
    [Neurological disorders], [28.6], [31.3], pct-up[+9.5 (−33.6, +72.5)], [+4.4],
    [Musculoskeletal disorders], [1.2], [1.4], pct-up[+11.3 (+7.4, +15.2)], [+10.0],
    [HIV/AIDS & sexually transmitted infections], [5.2], [6.1], pct-up[+15.6 (+10.5, +20.6)], [+2.4],
    [Substance use disorders], [3.8], [4.4], pct-up[+16.1 (+11.9, +20.5)], [+32.6],
    [Other non-communicable diseases], [14.8], [24.4], pct-up[+65.0 (+58.2, +72.4)], [+21.7],
    [Skin & subcutaneous diseases], [1.5], [4.7], pct-up[+206.8 (+191.9, +221.8)], [+232.7],
  )
  #v(0.3em)
  #text(size: 8pt, fill: rgb("#555555"))[
    #super[a] GBD attributes most deaths in people with mental disorders to
    associated physical causes or to substance use, so direct mental-disorder
    mortality is near zero and its percent change is statistically unstable
    (wide interval).
  ]
]

== Causes with the greatest mortality reductions

Figure 1 shows the cause categories with the largest age-standardised declines,
together with the three categories (unintentional injuries, neoplasms, and
diabetes and kidney diseases) that fall only after standardisation.

*Enteric infections* (#pct-down[−90.9%]) showed the most pronounced
improvement. Death rates that were very high in early infancy in 1990 (peaking
near 1,500 per 100,000 in the 1–5-month group) collapsed to near-zero across
all paediatric groups by 2023, so the standardised rate fell from 27.3 to 2.5
per 100,000.

*Maternal and neonatal disorders* (#pct-down[−60.8%]) showed extreme
concentration of risk in the neonatal period, with the standardised rate
falling from 29.9 to 11.7 per 100,000. *Nutritional deficiencies*
(#pct-down[−82.1%]) and *neglected tropical diseases and malaria*
(#pct-down[−75.1%]) showed similarly large reductions concentrated in early
childhood.

*Cardiovascular diseases* (#pct-down[−54.8%]), the largest single contributor
to standardised mortality in both years (ASR 293.7 per 100,000 in 1990),
declined by more than half, with the steepest absolute reductions in the older
age bands.

*Respiratory infections and tuberculosis* declined more modestly
(#pct-down[−22.2%], 95% CI −26.0% to −18.3%), with reductions in younger and
middle-aged groups partly offset by persistently high rates at the oldest ages.

Three categories rose on the unweighted-mean metric but declined once
age-standardised, and therefore appear in Figure 1: *unintentional injuries*
(unweighted #pct-up[+26.2%]; standardised #pct-down[−19.0%], 95% CI −21.5% to
−16.4%), *diabetes and kidney diseases* (unweighted #pct-up[+16.3%];
standardised #pct-down[−10.0%], 95% CI −13.5% to −6.2%), and *neoplasms*
(unweighted #pct-up[+0.1%]; standardised #pct-down[−10.4%], 95% CI −12.7% to
−8.0%). In each case, 2023 age-specific rates exceeded 1990 rates only in the
oldest age bands, which the unweighted mean over-weights relative to their
population share; once standardised, the broad-based reductions at younger and
middle ages dominate.

#figure(
  image("figures/fig1_decreased.jpg", width: 100%),
  caption: [
    *Brazil — causes with the greatest age-standardised mortality reductions,
    1990–2023.* Age-specific death rate (deaths per 100,000) by age group, both
    sexes. Solid blue line, 1990; dashed red line, 2023. Green shading marks age
    groups where the 2023 rate fell; pink shading where it rose. Each annotation
    gives the percent change in the WHO-standardised rate with its Monte Carlo
    95% CI (n = 10,000). The three categories marked ★ rose on the
    unweighted-mean metric but declined after standardisation. Source: GBD 2023
    (IHME).
  ],
)

== Causes with rising mortality burden

Figure 2 shows the six categories with rising age-standardised mortality.

*Skin and subcutaneous diseases* showed by far the largest relative increase
(#pct-up[+206.8%], 95% CI +191.9% to +221.8%), with the standardised rate rising
from 1.5 to 4.7 per 100,000. The increase was concentrated among the elderly;
plausible contributors include changes in diagnostic coding over time, an ageing
and more immunocompromised population, and rising melanoma incidence in a
high-ultraviolet setting [9]. Because this category is small and partly
dependent on cause-of-death coding, the estimate should be interpreted with
caution.

*Other non-communicable diseases* increased by #pct-up[+65.0%] (95% CI +58.2%
to +72.4%). This residual category is heterogeneous, and the rise should be
read as a signal to disaggregate rather than as a single coherent trend.

*Substance use disorders* increased by #pct-up[+16.1%] (95% CI +11.9% to
+20.5%), with the largest rises in middle age, consistent with documented
increases in alcohol- and drug-attributable mortality in Brazilian urban
centres [10].

*HIV/AIDS and sexually transmitted infections* (#pct-up[+15.6%]) and
*musculoskeletal disorders* (#pct-up[+11.3%]) showed smaller but precisely
estimated increases. *Neurological disorders* rose modestly in the point
estimate (#pct-up[+9.5%]) but with an interval spanning zero (95% CI −33.6% to
+72.5%), so the direction of change for this heterogeneous category is
uncertain.

#figure(
  image("figures/fig2_increased.jpg", width: 100%),
  caption: [
    *Brazil — causes with rising age-standardised mortality burden, 1990–2023.*
    Age-specific death rate (deaths per 100,000) by age group, both sexes. Solid
    blue line, 1990; dashed red line, 2023. Pink shading marks age groups where
    the 2023 rate exceeded 1990; green shading where it fell. Annotations give
    the percent change in the WHO-standardised rate with its Monte Carlo 95% CI
    (n = 10,000). Source: GBD 2023 (IHME).
  ],
)

// ── 4. Discussion ────────────────────────────────────────────────────────────
= Discussion

== Principal findings

Between 1990 and 2023, Brazil's age-standardised mortality burden shifted
markedly: communicable diseases, nutritional deficiencies, and perinatal
conditions declined steeply, while several non-communicable categories rose.
This pattern is consistent with the epidemiological-transition and
double-burden literature [4] and with previous national GBD-based assessments
[11]. The analysis also shows that the direction of change for three categories
depends entirely on whether age structure is accounted for.

== Successes: communicable, perinatal, and nutritional causes

The near-elimination of enteric-infection mortality in childhood
(#pct-down[−90.9%]) is among Brazil's most notable public-health achievements,
attributable to oral rehydration therapy, sanitation expansion, rotavirus
vaccination (introduced in 2006), and improved paediatric care [1]. The decline
in nutritional-deficiency mortality (#pct-down[−82.1%]) reflects food-security
and conditional cash-transfer programmes [12]. The cardiovascular reduction of
more than half (#pct-down[−54.8%]) aligns with documented improvements in
hypertension control, expanding cardiac-care capacity, and reduced smoking
prevalence [13].

== Challenges: non-communicable diseases

The large rise in skin and subcutaneous disease mortality (#pct-up[+206.8%]) is
not explained by a single mechanism; improved diagnostic ascertainment, an
ageing and more immunocompromised population, and rising melanoma incidence are
plausible contributors [9], and the category warrants disaggregation in future
work. The increase in substance use disorder mortality (#pct-up[+16.1%]) is
consistent with rising alcohol- and drug-attributable deaths in urban Brazil
[10]; prevention and treatment services remain comparatively underfunded.

== Why age standardisation changes the conclusions

Three categories illustrate why a population-weighted summary is essential.
Unintentional injuries rose by #pct-up[+26.2%] on the unweighted-mean metric
but fell by #pct-down[−19.0%] once standardised; diabetes and kidney diseases
moved from #pct-up[+16.3%] to #pct-down[−10.0%]; and neoplasms from a flat
#pct-up[+0.1%] to #pct-down[−10.4%]. In each case the 2023 age-specific rate
exceeded the 1990 rate only at the oldest ages. The unweighted mean gives each
of the 25 age bands equal weight, so it over-represents these small but
high-rate elderly bands; the WHO standard assigns them weights that reflect a
population age distribution, allowing the substantial reductions at younger and
middle ages to dominate. Because Brazil's elderly population grew rapidly over
the period [6], crude or count-based measures will register an apparent
increase for these causes even though within-age-group risk has fallen — a
classic confounding-by-age effect. For unintentional injuries, the standardised
decline is consistent with reduced road-traffic mortality among working-age
adults following road-safety legislation such as the 2008 "Dry Law," even as
fall-related deaths rise among the elderly.

This finding has a practical implication: the unweighted mean of age-specific
rates displayed by default in some visualisation tools can invert the apparent
direction of a trend. Mortality changes over periods of demographic change
should be interpreted using age-standardised or otherwise age-adjusted measures.

== Strengths and limitations

The analysis is fully reproducible: every reported number, including all
figures, is generated by the accompanying open code from the open data, with
no manual adjustments. Standardisation to the external WHO World Standard makes
the 1990 and 2023 rates directly comparable and the results comparable with
other studies that use the same standard.

Several limitations apply. First, the design is ecological and
cross-sectional: population-level associations cannot establish that specific
policies caused the observed changes, and the policy interpretations above are
contextual rather than causal. Second, the estimates are GBD modelled outputs
rather than directly observed deaths, and they carry uncertainty that is larger
for causes under-recorded in vital registration (for example skin and
subcutaneous diseases and the heterogeneous neurological and "other NCD"
categories); the wide interval for neurological disorders reflects this.
Third, the Monte Carlo procedure treats the 25 age-specific rates as
independent because the GBD posterior correlation structure is not available in
the public extract; the true correlation between age groups would alter the
width, though not the point estimate, of the intervals. Fourth, the WHO World
Standard is one of several possible standards, and absolute standardised rates
(though not the direction or approximate magnitude of change) would differ
under another standard, such as the GBD or European standard. Finally, the
analysis was restricted to both sexes combined and to two endpoint years;
sex-disaggregated and full time-series analyses would add resolution.

== Conclusions

Brazil's mortality profile has undergone a classic, though incomplete,
epidemiological transition. Reductions in communicable, nutritional, and
perinatal mortality represent major gains attributable to multi-sector social
investment, while the rising age-standardised burden of several
non-communicable categories — and the persistence of injury-related mortality —
underscores the need for sustained NCD prevention, mental health and addiction
services, and elderly care within the SUS. Methodologically, the reversal of
several trends under age standardisation is a reminder that age structure must
be accounted for before mortality changes are interpreted.

// ── Declarations ─────────────────────────────────────────────────────────────
= Declarations

*Data and code availability.* All data analysed are publicly available from the
IHME GBD Compare / GBD Results tool (https://vizhub.healthdata.org/gbd-compare/).
The extracted CSV files, all analysis and figure-generation code, the STROBE
checklist, and this manuscript source are provided in the accompanying
repository and may be re-run to reproduce every value and figure reported here.

*Ethics approval.* Not required; the study uses de-identified aggregated public
data.

*Competing interests.* The author declares no competing interests.

*Funding.* No external funding was received for this study.

*Author contributions.* E.S.A.S. conceived the study, extracted and analysed
the data, produced the figures, and wrote the manuscript.

*Use of the GBD 2023 citation.* The data were extracted from the IHME GBD 2023
release; the corresponding GBD 2023 collaborator capstone reference should be
inserted as [5] once its final bibliographic details are confirmed.

// ── References ───────────────────────────────────────────────────────────────
= References

#set par(hanging-indent: 1.5em)
#set text(size: 10pt)

#block[*\[1\]* Victora CG, Barreto ML, do Carmo Leal M, et al. Health conditions and
  health-policy innovations in Brazil: the way forward. _Lancet._
  2011;377(9782):2042–2053.]

#block[*\[2\]* Schmidt MI, Duncan BB, Azevedo e Silva G, et al. Chronic non-communicable
  diseases in Brazil: burden and current challenges. _Lancet._
  2011;377(9781):1949–1961.]

#block[*\[3\]* Omran AR. The epidemiologic transition: a theory of the epidemiology of
  population change. _Milbank Mem Fund Q._ 1971;49(4):509–538.]

#block[*\[4\]* Frenk J, Bobadilla JL, Stern C, et al. Elements for a theory of the health
  transition. _Health Transit Rev._ 1991;1(1):21–38.]

#block[*\[5\]* GBD 2023 Diseases and Injuries Collaborators. Global burden of diseases and
  injuries, 1990–2023: a systematic analysis for the Global Burden of Disease
  Study 2023. _Lancet._ (citation to be confirmed). IHME, University of
  Washington, Seattle, WA.]

#block[*\[6\]* United Nations, Department of Economic and Social Affairs, Population
  Division. _World Population Prospects 2024._ New York: United Nations; 2024.
  Available from https://population.un.org/wpp/.]

#block[*\[7\]* von Elm E, Altman DG, Egger M, et al. The Strengthening the Reporting of
  Observational Studies in Epidemiology (STROBE) statement: guidelines for
  reporting observational studies. _Lancet._ 2007;370(9596):1453–1457.]

#block[*\[8\]* Ahmad OB, Boschi-Pinto C, Lopez AD, Murray CJL, Lozano R, Inoue M. _Age
  standardization of rates: a new WHO standard._ GPE Discussion Paper No. 31.
  Geneva: World Health Organization; 2001.]

#block[*\[9\]* Bray F, Laversanne M, Sung H, et al. Global cancer statistics 2022:
  GLOBOCAN estimates of incidence and mortality worldwide for 36 cancers in 185
  countries. _CA Cancer J Clin._ 2024;74(3):229–263.]

#block[*\[10\]* Carlini EA, Noto AR, Sanchez ZM, et al. _VI Levantamento Nacional Sobre o
  Consumo de Drogas Psicotrópicas entre Estudantes do Ensino Fundamental e Médio
  das Redes Pública e Privada de Ensino nas 27 Capitais Brasileiras._
  CEBRID/UNIFESP; 2012.]

#block[*\[11\]* Malta DC, França EB, Abreu DMX, et al. Mortality due to noncommunicable
  diseases in Brazil, 1990 to 2015, according to the Global Burden of Disease
  study. _Sao Paulo Med J._ 2017;135(2):141–148.]

#block[*\[12\]* Rasella D, Aquino R, Santos CA, et al. Effect of a conditional cash transfer
  programme on childhood mortality: a nationwide analysis of Brazilian
  municipalities. _Lancet._ 2013;382(9886):57–64.]

#block[*\[13\]* Chor D, Pinho Ribeiro AL, Sá Carvalho M, et al. Prevalence, awareness,
  treatment and influence of socioeconomic variables on control of high blood
  pressure: results from the ELSA-Brasil study. _PLoS One._
  2015;10(6):e0127382.]
