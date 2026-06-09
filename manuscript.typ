// ─────────────────────────────────────────────────────────────────────────────
// Shifting Mortality Burden in Brazil, 1990–2023
// Typst manuscript source
//
// All numerical values (tables and in-text figures) are read at compile time
// from build/results.json, which is produced by `python scripts/build_results.py`.
// No statistic is typed by hand. Build order:
//     python scripts/build_results.py     # writes build/results.json
//     python scripts/figures.py           # writes figures/*.jpg
//     typst compile manuscript.typ manuscript.pdf
// ─────────────────────────────────────────────────────────────────────────────

// ── Page & typography ────────────────────────────────────────────────────────
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
  numbering: "1",
  number-align: center,
)

#set text(font: "Linux Libertine", size: 11pt, lang: "en", hyphenate: true)
#set heading(numbering: "1.")
#set par(justify: true, leading: 0.65em)
#show par: set block(spacing: 1.2em)

#set document(
  title: "Shifting Mortality Burden in Brazil, 1990–2023: Age-Standardised Trends Across Cause Categories from the Global Burden of Disease Study 2023",
  author: "Eduardo S. A. Santos",
)

// Hyperlinks and cross-references rendered as coloured, clickable links.
#let link-blue = rgb("#1a4f8a")
#show link: it => text(fill: link-blue, it)
#show ref: it => text(fill: link-blue, it)

// ── Colour helpers ───────────────────────────────────────────────────────────
#let green-dark = rgb("#1a7a4a")
#let red-dark = rgb("#c0392b")
#let grey-light = rgb("#f5f5f5")
#let grey-border = rgb("#cccccc")

#let note(body) = block(
  fill: grey-light,
  stroke: 1pt + grey-border,
  inset: 8pt,
  radius: 4pt,
  body,
)

// ── Results data (single source of truth) ────────────────────────────────────
#let R = json("build/results.json")
#let C = R.by_slug         // cause records, keyed by short slug
#let G = R.group_by_slug   // Level-1 groups + "all", keyed by slug
#let S = R.summary

// Colour a preformatted change string by its sign (− green, + red).
#let vcol(s) = if s.starts-with("−") { green-dark } else if s.starts-with("+") { red-dark } else { rgb("#333333") }
#let cv(s) = text(fill: vcol(s), weight: "bold", s)

// Retained for any literal use.
#let pct-up(v) = text(fill: red-dark, weight: "bold", v)
#let pct-down(v) = text(fill: green-dark, weight: "bold", v)

// Table-cell builders driven by the JSON records.
#let hcell(b) = text(fill: white, weight: "bold", b)
#let name-cell(c) = {
  [#c.name_short]
  if c.sup != "" { [#super[#c.sup]] }
  if c.discordant { [ †] }
}
#let t2-name(r) = if r.bold { text(weight: "bold", r.name) } else { [#r.name] }

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
age groups), we computed age-standardised death rates (ASRs) for #S.n_causes
Level-2 cause categories by direct standardisation to the WHO World Standard
Population. The relative percent change in ASR between 1990 and 2023 was the
primary outcome; 95% uncertainty intervals were obtained by Monte Carlo
propagation of each age group's GBD interval (10,000 draws per cause). For
comparison we also computed the unweighted mean of the 25 age-specific rates —
the summary statistic displayed by the GBD Compare tool — which weights every
age band equally.

*Results.* Of #S.n_causes cause categories, #S.n_decreased showed decreased and
#S.n_increased showed increased age-standardised mortality between 1990 and
2023. The largest standardised reductions were in enteric infections
(#cv(C.enteric.asr_pct), 95% CI #C.enteric.asr_ci), nutritional deficiencies
(#cv(C.nutritional.asr_pct)), neglected tropical diseases and malaria
(#cv(C.ntd.asr_pct)), maternal and neonatal disorders (#cv(C.maternal.asr_pct)),
and cardiovascular diseases (#cv(C.cvd.asr_pct)). The largest standardised
increases were in skin and subcutaneous diseases (#cv(C.skin.asr_pct), 95% CI
#C.skin.asr_ci), other non-communicable diseases (#cv(C.other_ncd.asr_pct)), and
substance use disorders (#cv(C.substance.asr_pct)). #S.n_reversed categories —
unintentional injuries, neoplasms, and diabetes and kidney diseases — rose on
the unweighted-mean metric but declined once age-standardised (e.g.
unintentional injuries: unweighted #cv(C.unintentional.mean_pct) vs standardised
#cv(C.unintentional.asr_pct), 95% CI #C.unintentional.asr_ci), indicating that
their apparent rise reflects population ageing rather than higher age-specific
risk.

The contrast with absolute burden was stark: the total number of deaths rose
#cv(G.all.deaths_pct) and the crude rate #cv(G.all.crude_pct) over the period,
even as the all-cause age-standardised rate fell #cv(G.all.asr_pct); for
non-communicable diseases, deaths more than doubled (#cv(G.ncd.deaths_pct))
while the standardised rate fell #cv(G.ncd.asr_pct).

*Interpretation.* Brazil's mortality profile has shifted from communicable,
perinatal, and nutritional causes toward non-communicable diseases — a classic
epidemiological transition. Rising death counts and crude rates coexist with
falling age-standardised rates, underscoring that age structure must be
accounted for before mortality changes are interpreted or acted upon.

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
Evaluation (IHME), offers the most comprehensive such assessment; its 2023
round estimated the burden of 375 diseases and injuries across 204 countries
and territories (and 660 subnational locations) within a common comparative
framework [5].

Monitoring these shifts has direct policy salience. Non-communicable diseases
account for roughly 70% of deaths worldwide, and the World Health Organization's
Global Action Plan for the Prevention and Control of NCDs set a target of a 25%
relative reduction in premature NCD mortality by 2025, reinforced by Sustainable
Development Goal target 3.4 (a one-third reduction by 2030) and Brazil's
National Plan to Combat NCDs 2011–2022 [14, 11]. Tracking whether
age-standardised mortality is in fact falling — and for which causes — is
therefore essential to assessing progress against these commitments.

A central methodological issue motivates this analysis. Brazil's population
aged dramatically between 1990 and 2023: the median age roughly doubled and the
share of the population aged 60 years and over more than doubled [6]. Because
mortality rates for most chronic diseases and many injuries rise steeply with
age, any summary measure that does not hold age structure constant can register
an apparent increase in mortality even when age-specific risk is falling. This
distinction is not merely technical: a previous GBD-based analysis found that
NCD deaths in Brazil rose by about 90% in absolute number between 1990 and 2015
even as the age-standardised NCD death rate fell by a quarter, the divergence
being attributed to population growth and ageing [11].

The objectives of this study were therefore to (i) quantify the
age-standardised change in mortality for each major cause category in Brazil
between 1990 and 2023; (ii) characterise the underlying age-pattern of these
changes; and (iii) identify the causes for which the direction of change
depends on whether age structure is taken into account. To do so we make
age-standardised death rates the primary outcome and contrast them with the
unweighted mean of age-specific rates displayed by the widely used GBD Compare
tool.

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
leaving #S.n_causes categories. For every age group the tool provides a point
estimate and a 95% uncertainty interval. A second extract, for Brazil, both
sexes, all ages combined, provided the absolute number of deaths and the crude
(all-ages) death rate per 100,000 for the same 22 categories in 1990 and 2023;
these are used in the absolute-burden analysis (@tab:burden). Data were
extracted on 4 June 2026. The underlying data are cited as:

#note[
  Institute for Health Metrics and Evaluation (IHME). _GBD Compare / GBD
  Results tool. Global Burden of Disease (GBD) Study 2023._ Seattle, WA: IHME,
  University of Washington, 2025. Available from
  #link("https://vizhub.healthdata.org/gbd-compare/") and
  #link("https://vizhub.healthdata.org/gbd-results/"). Accessed 4 June 2026.
]

== GBD estimation framework

The estimates analysed here are modelled outputs of the GBD study rather than
raw death counts, and the GBD methodology has been described in detail elsewhere
[5]. In brief, for Brazil the principal input is the national Mortality
Information System (Sistema de Informação sobre Mortalidade), supplemented by
other vital-registration and survey sources. GBD applies standardised
procedures to correct for under-registration of deaths and to redistribute
"garbage codes" — deaths assigned to causes that cannot be an underlying cause
of death — to their most probable true causes, and it models cause-specific
mortality with the Cause of Death Ensemble model (CODEm), constraining
cause-specific estimates so that they sum to all-cause mortality [15]. Causes
are organised in a four-level hierarchy; this analysis uses the 22 Level-2
categories (of which #S.n_causes carry mortality estimates for Brazil). GBD
reports each estimate with a 95% uncertainty interval derived from the
percentiles of its posterior draw distribution; our uncertainty propagation
(below) resamples these published intervals. These corrections substantially
improve cross-national and temporal comparability relative to unadjusted vital
statistics, but they also mean the estimates carry modelling uncertainty that is
larger for causes that are under-recorded or frequently miscertified (addressed
in the Discussion).

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

== Absolute burden

To place the rate analysis in context, we report the absolute number of deaths
and the crude (all-ages) death rate for each cause and Level-1 group in 1990
and 2023, with their relative changes. The crude rate uses Brazil's actual
population age structure in each year, so — unlike the age-standardised rate —
it is affected by population growth and ageing; juxtaposing the two isolates
the demographic contribution to the change in burden. Counts and crude rates
are reported as GBD point estimates.

== Software and reproducibility

All analyses were performed in Python 3. The unweighted-mean metric is
reproduced by `scripts/analysis.py` (standard library only); the
age-standardised analysis and uncertainty propagation by
`scripts/analysis_standardised.py` (using NumPy); the absolute-burden analysis
by `scripts/analysis_counts.py`; and the figures by `scripts/figures.py`. A
single build step, `scripts/build_results.py`, writes every reported quantity to
`build/results.json`, which this manuscript reads at compile time; consequently
no statistic in the text or tables is entered by hand. Data, code, and the
manuscript source are openly available (see Data and Code Availability).

== Ethics

This study uses publicly available, de-identified, aggregated data; no
individual-level data were collected or analysed. Institutional review board
approval was not required.

// ── 3. Results ───────────────────────────────────────────────────────────────
= Results

== Overview

Of the #S.n_causes cause categories analysed, #S.n_decreased showed a decreased
and #S.n_increased an increased age-standardised mortality rate between 1990 and
2023 (@tab:asr). #S.n_reversed categories — unintentional injuries, neoplasms,
and diabetes and kidney diseases — increased on the unweighted-mean metric but
declined once age-standardised; no category moved in the opposite direction.
Reductions were concentrated in communicable, perinatal, and nutritional causes,
and increases in non-communicable categories, consistent with an epidemiological
transition.

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

    hcell[Cause of death or injury], hcell[ASR 1990], hcell[ASR 2023],
    hcell[Δ% ASR (95% CI)], hcell[Δ% mean],

    ..R.causes.map(c => (
      name-cell(c),
      [#c.asr90],
      [#c.asr23],
      cv(c.asr_pct_ci_tbl),
      cv(c.mean_pct_tbl),
    )).flatten()
  )
  #v(0.3em)
  #text(size: 8pt, fill: rgb("#555555"))[
    #super[a] GBD attributes most deaths in people with mental disorders to
    associated physical causes or to substance use, so direct mental-disorder
    mortality is near zero and its percent change is statistically unstable
    (wide interval).
  ]
] <tab:asr>

== Burden by GBD Level-1 group

Aggregating the #S.n_causes categories into the three GBD Level-1 super-groups,
the age-standardised death rate fell in all three between 1990 and 2023:
communicable, maternal, neonatal, and nutritional causes by
#cv(G.cmnn.asr_pct) (from #G.cmnn.asr90 to #G.cmnn.asr23 per 100,000; 95% CI
#G.cmnn.asr_ci), non-communicable diseases by #cv(G.ncd.asr_pct)
(#G.ncd.asr90 to #G.ncd.asr23; 95% CI #G.ncd.asr_ci), and injuries by
#cv(G.injuries.asr_pct) (#G.injuries.asr90 to #G.injuries.asr23; 95% CI
#G.injuries.asr_ci). The communicable group declined fastest, so its share of
the total contracted while the NCD share expanded — the proportional shift that
defines the epidemiological transition. Critically, the NCD super-group's
age-standardised rate fell substantially even though several of its constituent
categories rose (@tab:asr): the decline of the dominant cardiovascular category
outweighs the increases in smaller NCD categories. This illustrates, at the
aggregate level, the same principle seen for individual causes — proportional
or count-based increases can coexist with falling age-specific risk.

== Absolute burden: deaths and crude rates versus standardised rates

The number of deaths and the crude death rate tell a markedly different story
from the age-standardised rate (@tab:burden). The total number of deaths in
Brazil rose #cv(G.all.deaths_pct), from #G.all.deaths90 in 1990 to
#G.all.deaths23 in 2023, and the crude all-ages death rate rose
#cv(G.all.crude_pct), even though the all-cause age-standardised rate fell
#cv(G.all.asr_pct) (95% CI #G.all.asr_ci). The contrast is starkest for
non-communicable diseases, where the number of deaths more than doubled
(#cv(G.ncd.deaths_pct), from #G.ncd.deaths90 to #G.ncd.deaths23) and the crude
rate rose #cv(G.ncd.crude_pct), yet the age-standardised rate fell
#cv(G.ncd.asr_pct). Among individual causes, cardiovascular deaths rose
#cv(C.cvd.deaths_pct) (#C.cvd.deaths90 to #C.cvd.deaths23) and neoplasm deaths
#cv(C.neoplasms.deaths_pct) even as their age-standardised rates fell by
#cv(C.cvd.asr_pct) and #cv(C.neoplasms.asr_pct) respectively; diabetes and
kidney disease deaths nearly tripled (#cv(C.diabetes.deaths_pct)) while the
age-standardised rate fell #cv(C.diabetes.asr_pct). In every such case the
growth in deaths is a product of a larger, older population rather than of
rising age-specific risk.

#figure(
  caption: [Absolute deaths, crude (all-ages) death rate, and age-standardised
    rate: percent change in Brazil, 1990–2023, both sexes. Death counts and
    crude rates are GBD point estimates for all ages; age-standardised changes
    (WHO World Standard) are reproduced from @tab:asr (causes) and the main text
    (groups), where 95% uncertainty intervals are given. Δ = percent change
    1990–2023.],
  kind: table,
)[
  #set text(size: 9pt)
  #table(
    columns: (1.9fr, auto, auto, auto, auto, auto),
    align: (left, right, right, right, right, right),
    stroke: none,
    fill: (col, row) => if row == 0 { rgb("#2c3e50") } else if calc.odd(row) { rgb("#f9f9f9") } else { white },
    inset: (x: 6pt, y: 4.5pt),

    hcell[Cause / group], hcell[Deaths 1990], hcell[Deaths 2023],
    hcell[Δ deaths], hcell[Δ crude], hcell[Δ ASR],

    ..R.table2.map(r => (
      t2-name(r),
      [#r.deaths90],
      [#r.deaths23],
      cv(r.dn),
      cv(r.dc),
      cv(r.da),
    )).flatten()
  )
] <tab:burden>

== Causes with the greatest mortality reductions

@fig:decreased shows the cause categories with the largest age-standardised
declines, together with the three categories (unintentional injuries,
neoplasms, and diabetes and kidney diseases) that fall only after
standardisation.

*Enteric infections* (#cv(C.enteric.asr_pct)) showed the most pronounced
improvement. Death rates that were very high in early infancy in 1990 (peaking
near 1,500 per 100,000 in the 1–5-month group) collapsed to near-zero across
all paediatric groups by 2023, so the standardised rate fell from
#C.enteric.asr90 to #C.enteric.asr23 per 100,000.

*Maternal and neonatal disorders* (#cv(C.maternal.asr_pct)) showed extreme
concentration of risk in the neonatal period, with the standardised rate
falling from #C.maternal.asr90 to #C.maternal.asr23 per 100,000.
*Nutritional deficiencies* (#cv(C.nutritional.asr_pct)) and *neglected tropical
diseases and malaria* (#cv(C.ntd.asr_pct)) showed similarly large reductions
concentrated in early childhood.

*Cardiovascular diseases* (#cv(C.cvd.asr_pct)), the largest single contributor
to standardised mortality in both years (ASR #C.cvd.asr90 per 100,000 in 1990),
declined by more than half, with the steepest absolute reductions in the older
age bands.

*Respiratory infections and tuberculosis* declined more modestly
(#cv(C.resp_tb.asr_pct), 95% CI #C.resp_tb.asr_ci), with reductions in younger
and middle-aged groups partly offset by persistently high rates at the oldest
ages.

Three categories rose on the unweighted-mean metric but declined once
age-standardised, and therefore appear in @fig:decreased: *unintentional
injuries* (unweighted #cv(C.unintentional.mean_pct); standardised
#cv(C.unintentional.asr_pct), 95% CI #C.unintentional.asr_ci), *diabetes and
kidney diseases* (unweighted #cv(C.diabetes.mean_pct); standardised
#cv(C.diabetes.asr_pct), 95% CI #C.diabetes.asr_ci), and *neoplasms* (unweighted
#cv(C.neoplasms.mean_pct); standardised #cv(C.neoplasms.asr_pct), 95% CI
#C.neoplasms.asr_ci). In each case, 2023 age-specific rates exceeded 1990 rates
only in the oldest age bands, which the unweighted mean over-weights relative to
their population share; once standardised, the broad-based reductions at younger
and middle ages dominate.

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
) <fig:decreased>

== Causes with rising mortality burden

@fig:increased shows the six categories with rising age-standardised mortality.

*Skin and subcutaneous diseases* showed by far the largest relative increase
(#cv(C.skin.asr_pct), 95% CI #C.skin.asr_ci), with the standardised rate rising
from #C.skin.asr90 to #C.skin.asr23 per 100,000. The increase was concentrated
among the elderly; plausible contributors include changes in diagnostic coding
over time, an ageing and more immunocompromised population, and rising melanoma
incidence in a high-ultraviolet setting [9]. Because this category is small and
partly dependent on cause-of-death coding, the estimate should be interpreted
with caution.

*Other non-communicable diseases* increased by #cv(C.other_ncd.asr_pct) (95% CI
#C.other_ncd.asr_ci). This residual category is heterogeneous, and the rise
should be read as a signal to disaggregate rather than as a single coherent
trend.

*Substance use disorders* increased by #cv(C.substance.asr_pct) (95% CI
#C.substance.asr_ci), with the largest rises in middle age, consistent with
documented increases in alcohol- and drug-attributable mortality in Brazilian
urban centres [10].

*HIV/AIDS and sexually transmitted infections* (#cv(C.hiv.asr_pct)) and
*musculoskeletal disorders* (#cv(C.musculo.asr_pct)) showed smaller but
precisely estimated increases. *Neurological disorders* rose modestly in the
point estimate (#cv(C.neuro.asr_pct)) but with an interval spanning zero (95% CI
#C.neuro.asr_ci), so the direction of change for this heterogeneous category is
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
) <fig:increased>

// ── 4. Discussion ────────────────────────────────────────────────────────────
= Discussion

== Principal findings

Between 1990 and 2023, Brazil's age-standardised mortality burden shifted
markedly: communicable diseases, nutritional deficiencies, and perinatal
conditions declined steeply, while several non-communicable categories rose.
This pattern is consistent with the epidemiological-transition and
double-burden literature [4] and with previous national GBD-based assessments
[11]. The analysis also shows that the direction of change for #S.n_reversed
categories depends entirely on whether age structure is accounted for.

== Successes: communicable, perinatal, and nutritional causes

The near-elimination of enteric-infection mortality in childhood
(#cv(C.enteric.asr_pct)) is among Brazil's most notable public-health
achievements, attributable to oral rehydration therapy, sanitation expansion,
rotavirus vaccination (introduced in 2006), and improved paediatric care [1].
The decline in nutritional-deficiency mortality (#cv(C.nutritional.asr_pct))
reflects food-security and conditional cash-transfer programmes [12]. The
cardiovascular reduction of more than half (#cv(C.cvd.asr_pct)) aligns with
documented improvements in hypertension control, expanding cardiac-care
capacity, and reduced smoking prevalence [13, 16]; notably, this halving of
age-specific risk occurred even as the absolute number of cardiovascular deaths
rose by #cv(C.cvd.deaths_pct) (#C.cvd.deaths90 to #C.cvd.deaths23), a divergence
driven entirely by demographic change.

== Challenges: non-communicable diseases

The large rise in skin and subcutaneous disease mortality
(#cv(C.skin.asr_pct)) is not explained by a single mechanism; improved
diagnostic ascertainment, an ageing and more immunocompromised population, and
rising melanoma incidence are plausible contributors [9], and the category
warrants disaggregation in future work. The increase in substance use disorder
mortality (#cv(C.substance.asr_pct)) is consistent with rising alcohol- and
drug-attributable deaths in urban Brazil [10]; prevention and treatment services
remain comparatively underfunded.

== Why age standardisation changes the conclusions

#S.n_reversed categories illustrate why a population-weighted summary is
essential. Unintentional injuries rose by #cv(C.unintentional.mean_pct) on the
unweighted-mean metric but fell by #cv(C.unintentional.asr_pct) once
standardised; diabetes and kidney diseases moved from #cv(C.diabetes.mean_pct)
to #cv(C.diabetes.asr_pct); and neoplasms from a flat #cv(C.neoplasms.mean_pct)
to #cv(C.neoplasms.asr_pct). In each case the 2023 age-specific rate exceeded
the 1990 rate only at the oldest ages. The unweighted mean gives each of the 25
age bands equal weight, so it over-represents these small but high-rate elderly
bands; the WHO standard assigns them weights that reflect a population age
distribution, allowing the substantial reductions at younger and middle ages to
dominate. Because Brazil's elderly population grew rapidly over the period [6],
crude or count-based measures will register an apparent increase for these
causes even though within-age-group risk has fallen — a classic
confounding-by-age effect. For unintentional injuries, the standardised decline
is consistent with reduced road-traffic mortality among working-age adults
following road-safety legislation such as the 2008 "Dry Law," even as
fall-related deaths rise among the elderly.

This finding has a practical implication: the unweighted mean of age-specific
rates displayed by default in some visualisation tools can invert the apparent
direction of a trend. Mortality changes over periods of demographic change
should be interpreted using age-standardised or otherwise age-adjusted measures.

The same phenomenon has been documented for Brazil at the aggregate level.
Analysing GBD 2015 estimates, Malta and colleagues reported that the absolute
number of NCD deaths rose by about 90% between 1990 and 2015 while the
age-standardised NCD death rate fell by 25.3%, explicitly attributing the
divergence to population growth and ageing [11]. Our data reproduce and extend
that pattern to 2023: NCD deaths more than doubled (#cv(G.ncd.deaths_pct), from
#G.ncd.deaths90 to #G.ncd.deaths23) and the crude rate rose #cv(G.ncd.crude_pct),
yet the age-standardised NCD rate fell #cv(G.ncd.asr_pct); across all causes,
deaths rose #cv(G.all.deaths_pct) against a #cv(G.all.asr_pct) standardised
decline (@tab:burden). Our cause-level analysis then shows where the same
demographic confounding can flip the apparent direction of individual causes.
The two analyses also agree closely on direction and approximate magnitude for
the largest categories despite using different GBD cycles, endpoint years, and
age-standardisation conventions: Malta reported cardiovascular declines of
−40.4% (1990–2015) against our #cv(C.cvd.asr_pct) (1990–2023), and a broadly
stable neoplasm rate (their −6.5%) against our standardised
#cv(C.neoplasms.asr_pct). This concordance provides external validation of the
present estimates.

The same principle is central to GBD 2023 itself. Its headline global finding
contrasts a 6.1% rise in the absolute number of disability-adjusted life-years
between 2010 and 2023 with a 12.6% fall in the corresponding age-standardised
rate — a measure that, in the authors' words, accounts for population growth
and ageing — and frames this divergence as a manifestation of the global
epidemiological transition [5]. Our cause- and group-level mortality results
for Brazil are a national instance of that same pattern, in which count- or
composition-based measures and age-standardised rates can move in opposite
directions.

== Progress against policy targets

Read against the WHO Global Action Plan target of a 25% relative reduction in
premature NCD mortality and SDG target 3.4 [14, 11], the trajectory is broadly
encouraging: the age-standardised rate fell for all three Level-1 groups,
including a #cv(G.ncd.asr_pct) reduction for NCDs as a whole and a more than
halving of cardiovascular mortality, the single largest contributor. Progress
is uneven, however. The rising age-standardised burden of substance use
disorders, skin and subcutaneous diseases, and the heterogeneous "other NCD"
category identifies where prevention and treatment are not keeping pace, and
the persistence of interpersonal violence and self-harm (standardised rate
essentially unchanged) marks injuries as a continuing priority that sits
outside the classic NCD-target framing and that earlier work has flagged as a
major and socially concentrated source of premature mortality in Brazil [17].
Reductions in mortality have also been shown to be socially patterned in Brazil,
declining faster in wealthier regions and thereby widening relative inequalities
[11]; the national estimates analysed here cannot capture that gradient and
should be complemented by subnational and socioeconomic analyses.

== Strengths and limitations

The analysis is fully reproducible: every reported number, including all
figures and table cells, is generated by the accompanying open code from the
open data and read into this document at compile time, with no manual
adjustments. Standardisation to the external WHO World Standard makes the 1990
and 2023 rates directly comparable and the results comparable with other studies
that use the same standard.

Several limitations apply. First, the design is ecological and
cross-sectional: population-level associations cannot establish that specific
policies caused the observed changes, and the policy interpretations above are
contextual rather than causal. Second, the estimates are GBD modelled outputs
rather than directly observed deaths. The garbage-code redistribution and
under-registration corrections that GBD applies improve comparability but rest
on modelling assumptions that can bias estimates, particularly for ill-defined,
small, or frequently miscertified causes [11]; this is most relevant to the
categories where our estimates are least certain — skin and subcutaneous
diseases, the residual "other NCD" group, and neurological disorders, whose
standardised interval spans zero — and the large relative increases in these
categories should be read with corresponding caution and as a prompt to
disaggregate rather than as settled findings.
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
IHME GBD Compare / GBD Results tool (#link("https://vizhub.healthdata.org/gbd-compare/")).
The extracted CSV files, all analysis and figure-generation code, the STROBE
checklist, and this manuscript source are provided in the accompanying
repository and may be re-run to reproduce every value and figure reported here.

*Ethics approval.* Not required; the study uses de-identified aggregated public
data.

*Competing interests.* The author declares no competing interests.

*Funding.* No external funding was received for this study.

*Author contributions.* E.S.A.S. conceived the study, extracted and analysed
the data, produced the figures, and wrote the manuscript.

*Data provenance.* The estimates analysed here are from the GBD 2023 release,
published in October 2025 [5], and were extracted via the IHME GBD Compare /
GBD Results tool on 4 June 2026.

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

#block[*\[5\]* GBD 2023 Disease and Injury and Risk Factor Collaborators. Burden of 375
  diseases and injuries, risk-attributable burden of 88 risk factors, and
  healthy life expectancy in 204 countries and territories, including 660
  subnational locations, 1990–2023: a systematic analysis for the Global Burden
  of Disease Study 2023. _Lancet._ 2025;406:1873–1922.
  doi:10.1016/S0140-6736(25)01637-X.]

#block[*\[6\]* United Nations, Department of Economic and Social Affairs, Population
  Division. _World Population Prospects 2024._ New York: United Nations; 2024.
  Available from #link("https://population.un.org/wpp/").]

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

#block[*\[14\]* World Health Organization. _Global action plan for the prevention and
  control of noncommunicable diseases 2013–2020._ Geneva: World Health
  Organization; 2013.]

#block[*\[15\]* GBD 2021 Causes of Death Collaborators. Global burden of 288 causes of
  death and life expectancy decomposition in 204 countries and territories and
  811 subnational locations, 1990–2021: a systematic analysis for the Global
  Burden of Disease Study 2021. _Lancet._ 2024;403(10440):2100–2132.]

#block[*\[16\]* Ribeiro AL, Duncan BB, Brant LCC, Lotufo PA, Mill JG, Barreto SM.
  Cardiovascular health in Brazil: trends and perspectives. _Circulation._
  2016;133(4):422–433.]

#block[*\[17\]* Reichenheim ME, de Souza ER, Moraes CL, et al. Violence and injuries in
  Brazil: the effect, progress made, and challenges ahead. _Lancet._
  2011;377(9781):1962–1975.]
