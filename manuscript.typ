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

// Bold percentage-change tag used inline
#let pct-up(v) = text(fill: red-dark, weight: "bold", v)
#let pct-down(v) = text(fill: green-dark, weight: "bold", v)

// ── Title block ──────────────────────────────────────────────────────────────
#align(center)[
  #text(size: 16pt, weight: "bold")[
    Shifting Mortality Burden in Brazil, 1990–2023:
    Age-Specific Trends Across Cause Categories
    from the Global Burden of Disease Study 2023
  ]
  #v(0.6em)
  #text(size: 10.5pt, style: "italic")[
    Cross-sectional Ecological Analysis · GBD 2023 (IHME)
  ]
  #v(0.4em)
  #text(size: 10pt)[June 2026]

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

*Background.* Brazil has undergone a dramatic epidemiological transition over the past three decades. Understanding which cause-of-death categories have driven improvements versus which are imposing growing burdens is essential for health-system planning.

*Methods.* Using age-specific death rates (deaths per 100,000) from the Global
Burden of Disease (GBD) Study 2023 for Brazil (1990 and 2023, both sexes,
25 age groups), we calculated mean age-specific rates across all 25 GBD age
bands for each of 22 cause categories and derived relative percent changes.
Categories were classified as "improved" or "worsening" based on the
direction of change.

*Results.* Of the 21 cause categories with available mortality data, 12 showed
decreased mean age-specific rates, eight showed increases, and one (neoplasms)
was essentially unchanged. The largest crude reductions were in enteric
infections (#pct-down[−90.1%]), nutritional deficiencies (#pct-down[−73.0%]),
neglected tropical diseases and malaria (#pct-down[−66.1%]), maternal and
neonatal disorders (#pct-down[−60.4%]), and cardiovascular diseases
(#pct-down[−51.4%]). Crude rate increases were most prominent for skin and
subcutaneous diseases (#pct-up[+232.7%]), substance use disorders
(#pct-up[+32.6%]), and other non-communicable diseases (#pct-up[+21.7%]).
However, age-standardised analysis showed that two apparent crude increases —
unintentional injuries (#pct-up[+26.2%] crude; #pct-down[−13.7%] standardised)
and diabetes and kidney diseases (#pct-up[+16.3%] crude; #pct-down[−7.9%]
standardised) — reflect population ageing rather than true rises in
age-specific risk.

*Interpretation.* Brazil's mortality profile has shifted substantially from
communicable, perinatal, and nutritional causes toward non-communicable
diseases and injuries — a classical epidemiological transition pattern.
Persisting and rising causes require targeted policy attention.

*Keywords:* epidemiological transition; Brazil; mortality; Global Burden of
Disease; non-communicable diseases; age-specific death rates.

#v(1em)
#line(length: 100%, stroke: 0.5pt)
#v(1em)

// ── 1. Introduction ──────────────────────────────────────────────────────────
= Introduction

Brazil, Latin America's most populous country, has experienced one of the
most dramatic public-health transformations of the twentieth and twenty-first
centuries. The expansion of the Unified Health System (SUS) from the late
1980s onward, successive improvements in water and sanitation infrastructure,
large-scale vaccination campaigns, and conditional cash-transfer programmes
such as Bolsa Família collectively drove steep reductions in child and
infectious-disease mortality [1]. At the same time, urbanisation,
changing dietary patterns, sedentary lifestyles, and an ageing population
have fuelled a growing non-communicable disease (NCD) burden [2].

The concept of epidemiological transition, first articulated by Omran
[3], describes the shift from high mortality dominated by infectious
diseases and nutritional causes towards chronic, degenerative conditions and
injuries. Brazil is frequently cited as an archetypal "polarised" or
"prolonged" transitional country in which both communicable disease mortality
and rising NCD burden coexist, often concentrated in different age groups or
geographic regions [4].

Quantifying the magnitude and age-pattern of these shifts across all major
cause-of-death categories simultaneously — and within a globally harmonised
framework — provides the evidence base needed to prioritise health investments.
The Global Burden of Disease (GBD) Study 2023, produced by the Institute for
Health Metrics and Evaluation (IHME), offers the most comprehensive such
assessment, covering 204 countries, 369 diseases and injuries, and 25 age
groups using a common comparative risk framework [5].

The present study uses GBD 2023 data to characterise changes in the
age-specific mortality burden for 22 cause categories in Brazil between 1990
and 2023, explicitly mapping both the magnitude and the age-pattern of
improvements and remaining challenges.

// ── 2. Methods ───────────────────────────────────────────────────────────────
= Methods

== Data Source

Age-specific death rates (deaths per 100,000 population) were obtained from
the GBD Compare visualisation tool for Brazil, both sexes combined, for the
calendar years 1990 and 2023, across all 25 GBD age groups (0–6 days through
95+ years) and 22 Level-2 cause categories. Data were accessed on 4 June 2026.

The full citation for the underlying data is:

#note[
  Institute for Health Metrics and Evaluation (IHME). _GBD Compare Data
  Visualization. Global Burden of Disease (GBD) Study 2023._ Seattle, WA:
  IHME, University of Washington, 2025. Available from
  https://vizhub.healthdata.org/gbd-compare/. Accessed 4 June 2026.
]

== Analytic Approach

For each cause category and each year (1990 and 2023), we computed the
*mean age-specific death rate* as the arithmetic mean of the 25 age-group
point estimates:

$ macron(r)_"cause, year" = 1/25 sum_(i=1)^25 r_{i, "cause, year"} $

where $r_{i, "cause, year"}$ denotes the death rate (per 100,000) in age group $i$. This summary statistic weights each age group equally and mirrors the "% change in mean age-specific rate across 25 GBD age groups" metric displayed in the published figures.

The relative percent change between years was calculated as:

$ Delta% = frac(macron(r)_"2023" - macron(r)_"1990", macron(r)_"1990") times 100 $

Causes were classified as *improved* ($Delta% < 0$) or
*worsening* ($Delta% > 0$). All calculations were performed in Python 3.x
using the `csv` standard library only, ensuring full reproducibility without
external dependencies. Code is provided in `scripts/analysis.py`.

== Age-Standardised Sensitivity Analysis

Because the arithmetic mean of 25 age-specific rates weights every age band
equally, summary % changes are sensitive to the different age structures of
Brazil's 1990 and 2023 populations. To assess whether apparent trends reflect
genuine changes in age-specific risk versus shifts in population composition,
we performed direct age-standardisation against the mean of Brazil's 1990 and
2023 populations (United Nations World Population Prospects 2024) as an
internal standard.

The age-standardised rate for each cause and year was:

$ "ASR"_"cause, year" = sum_(i=1)^{25} r_{i, "cause, year"} times w_i^"std" $

where $w_i^"std" = P_i^"std" \/ sum_j P_j^"std"$ is the normalised weight of
age group $i$ in the standard population and $P_i^"std"$ is the mean of
Brazil's 1990 and 2023 population counts in that group. The five GBD
sub-groups spanning age 0–4 years were assigned weights proportional to their
person-year duration within the five-year band. The age-standardised percent
change was then:

$ Delta%_"std" = frac("ASR"_"2023" - "ASR"_"1990", "ASR"_"1990") times 100 $

Uncertainty was propagated simultaneously through all 25 GBD 95% confidence
intervals via Monte Carlo simulation ($n = 10{,}000$ draws per cause),
assuming a log-normal distribution for each age-specific rate. The 95%
confidence interval for $Delta%_"std"$ is the 2.5th–97.5th percentile of the
resulting distribution. All code is provided in
`scripts/analysis_standardised.py`; figure generation (including
cause-selection based on standardised direction of change) is in
`scripts/figures.py`.

== Visualisation

Age-specific rate curves for 1990 and 2023 were plotted for selected cause
categories. Figure 1 shows causes with the greatest standardised reductions
and Figure 2 shows causes with the largest standardised increases; two causes
(unintentional injuries and diabetes & kidney diseases) are classified using
their standardised direction and therefore appear in Figure 1 despite showing
crude rate increases. All percentage annotations in the figures reflect
age-standardised values with Monte Carlo 95% CIs.

== Ethics

This study uses publicly available, de-identified aggregated data; no
individual-level data were collected or analysed. Institutional review board
approval was not required.

// ── 3. Results ───────────────────────────────────────────────────────────────
= Results

== Summary Statistics

Of 22 Level-2 cause categories, one (sense organ diseases) had no mortality
data available in GBD Compare and was excluded from computation. Of the
remaining 21, *12 showed decreased* mean age-specific mortality between 1990
and 2023, eight showed increases, and one (neoplasms) was essentially unchanged
($Delta% = +0.1%$). Table 1 presents the complete results sorted by direction
of change.

#figure(
  caption: [Mean age-specific death rates (deaths per 100,000) per cause category in Brazil, 1990 and 2023, sorted by percent change. Values are arithmetic means across 25 GBD age groups.],
  kind: table,
)[
  #set text(size: 9.5pt)
  #table(
    columns: (auto, 1fr, 1fr, 1fr),
    align: (left, right, right, right),
    stroke: none,
    fill: (col, row) => if row == 0 { rgb("#2c3e50") } else if calc.odd(row) { rgb("#f9f9f9") } else { white },
    inset: (x: 8pt, y: 5pt),

    // Header
    text(fill: white, weight: "bold")[Cause of Death or Injury],
    text(fill: white, weight: "bold")[Mean Rate 1990],
    text(fill: white, weight: "bold")[Mean Rate 2023],
    text(fill: white, weight: "bold")[% Change],

    // Decreased causes ─────────────────
    [Enteric infections], [199.3], [19.7], text(fill: green-dark, weight: "bold")[−90.1%],

    [Other infectious diseases], [39.6], [6.8], text(fill: green-dark, weight: "bold")[−82.8%],

    [Nutritional deficiencies], [58.5], [15.8], text(fill: green-dark, weight: "bold")[−73.0%],

    [Neglected tropical diseases and malaria], [33.2], [11.2], text(fill: green-dark, weight: "bold")[−66.1%],

    [Maternal and neonatal disorders], [4316.3], [1710.0], text(fill: green-dark, weight: "bold")[−60.4%],

    [Transport injuries], [37.7], [16.9], text(fill: green-dark, weight: "bold")[−55.2%],

    [Cardiovascular diseases], [1523.8], [740.6], text(fill: green-dark, weight: "bold")[−51.4%],

    [Chronic respiratory diseases], [250.8], [164.1], text(fill: green-dark, weight: "bold")[−34.6%],

    [Respiratory infections and tuberculosis], [402.2], [318.2], text(fill: green-dark, weight: "bold")[−20.9%],

    [Self-harm and interpersonal violence], [30.3], [25.6], text(fill: green-dark, weight: "bold")[−15.5%],

    [Mental disorders], [0.0], [0.0], text(fill: green-dark, weight: "bold")[−13.2%],

    [Digestive diseases], [121.2], [110.7], text(fill: green-dark, weight: "bold")[−8.7%],

    // Stable
    [Neoplasms], [346.9], [347.2], text(weight: "bold")[+0.1%],

    // Increased causes ─────────────────
    [HIV/AIDS and sexually transmitted infections], [14.2], [14.6], text(fill: red-dark, weight: "bold")[+2.4%],

    [Neurological disorders], [359.2], [374.9], text(fill: red-dark, weight: "bold")[+4.4%],

    [Musculoskeletal disorders], [4.1], [4.5], text(fill: red-dark, weight: "bold")[+10.0%],

    [Diabetes and kidney diseases], [178.6], [207.7], text(fill: red-dark, weight: "bold")[+16.3%],

    [Other non-communicable diseases], [340.1], [414.0], text(fill: red-dark, weight: "bold")[+21.7%],

    [Unintentional injuries], [76.2], [96.2], text(fill: red-dark, weight: "bold")[+26.2%],

    [Substance use disorders], [3.8], [5.0], text(fill: red-dark, weight: "bold")[+32.6%],

    [Skin and subcutaneous diseases], [9.3], [31.0], text(fill: red-dark, weight: "bold")[+232.7%],
  )
]

== Causes with the Greatest Mortality Reductions

Figure 1 illustrates the eight cause categories with genuine age-standardised
declines, including two (unintentional injuries and diabetes & kidney diseases)
that showed apparent crude increases but are reclassified as improvements under
age standardisation.

*Enteric infections* (−90.1%) showed the most dramatic improvement, with
very high death rates in early infancy in 1990 — reaching 1,492.8 per 100,000
in the 1–5-month group — collapsing to near-zero levels by 2023 across all
paediatric age groups. Mean rates fell from 199.3 to 19.7 per 100,000 across
age groups.

*Maternal and neonatal disorders* (−60.4%) exhibited extreme concentration of
risk in the earliest age groups (neonatal period), declining from a mean rate
of 4,316.3 in 1990 to 1,710.0 per 100,000 per age group in 2023.

*Nutritional deficiencies* (−73.0%) and *neglected tropical diseases and
malaria* (−66.1%) similarly showed large absolute reductions concentrated in
early childhood.

*Cardiovascular diseases* (−51.4%), the leading contributor to adult
mortality in absolute terms (mean rate 1,523.8 per 100,000 in 1990), declined
by more than half over the study period. The rate reduction was most evident
in the 65–95+ age bands, suggesting improved treatment and prevention
in older adults.

*Respiratory infections and tuberculosis* showed a crude mean rate decline
of −20.9%; the age-standardised estimate is more conservative at
#pct-down[−10.0%] (95% CI −14.8% to −5.1%), reflecting the elevated weight
given to elderly age bands — where rates remained high — when standardising
to the Brazilian age structure. Rates declined in younger and middle age
groups, though the oldest-old (95+) band showed a relative increase by 2023.

Under age standardisation, two further causes join those with genuine
age-specific mortality reductions: *unintentional injuries*
(standardised #pct-down[−13.7%], 95% CI −16.6% to −10.6%) and *diabetes
and kidney diseases* (standardised #pct-down[−7.9%], 95% CI −11.8% to
−3.9%). Both showed apparent crude increases driven by population ageing
into high-risk elderly strata rather than rising within-age-group mortality.
These two causes are therefore shown in Figure 1 alongside the other causes
with genuine reductions.

#figure(
  image("figures/fig1_decreased.jpg", width: 100%),
  caption: [
    *Brazil — Causes with Greatest Age-Standardised Mortality Reductions, 1990–2023.*
    Age-specific death rate (deaths per 100,000) by age group, both sexes.
    Blue line = 1990 rate; red dashed line = 2023 rate. Green shading = age
    groups where 2023 rate fell; pink shading = age groups where 2023 rate
    rose. Annotation boxes show the age-standardised percent change with 95%
    confidence interval (Monte Carlo, $n = 10{,}000$; standard population:
    mean of Brazil 1990 + 2023, UN WPP 2024). Unintentional injuries and
    Diabetes & kidney diseases (★ reclassified) showed crude rate increases
    but genuine age-specific reductions under standardisation.
    Source: GBD Compare 2023 (IHME).
  ],
)

== Causes with Rising Mortality Burden

Figure 2 shows the four categories with rising age-standardised mortality
burden. Unintentional injuries and diabetes & kidney diseases, which showed
crude increases, are reclassified as improvements under age standardisation
and appear in Figure 1 (see § Age-Standardised Sensitivity Analysis).

*Skin and subcutaneous diseases* displayed the most dramatic rise
(#pct-up[+232.7%] crude; standardised #pct-up[+207.4%],
95% CI +191.7% to +224.1%), with mean rates increasing from 9.3 to 31.0
per 100,000 per age group. The increase was concentrated among the elderly
(75+ years), suggesting ageing demographics, increased prevalence of
immunosuppressive conditions, and possibly improved diagnostic ascertainment.

*Other non-communicable diseases* showed a crude increase of #pct-up[+21.7%],
but the age-standardised estimate is substantially larger at
#pct-up[+100.6%] (95% CI +91.9% to +109.2%), reflecting disproportionately
high age-specific rates in older cohorts that are more numerous in the
2023 population.

*Substance use disorders* (#pct-up[+32.6%] crude; standardised
#pct-up[+16.5%], 95% CI +12.4% to +20.8%) increased from a mean rate of 3.8
to 5.0 per 100,000, with the peak in the 45–65-year age band in 2023
notably higher than in 1990, consistent with longitudinal cohort effects
of increased alcohol and drug exposure in earlier birth cohorts now reaching
middle age.

*Neurological disorders* (#pct-up[+4.4%] crude; standardised
#pct-up[+6.9%], 95% CI −34.3% to +74.2%) showed a modest increase, with
mean rates rising from 359.2 to 374.9. The very wide standardised CI reflects
GBD modelling uncertainty in age-specific estimates for this heterogeneous
category; the direction of change remains uncertain after standardisation.
The shape of the 2023 curve in the oldest age groups substantially exceeds
1990, consistent with demographic ageing.

#figure(
  image("figures/fig2_increased.jpg", width: 100%),
  caption: [
    *Brazil — Causes with Rising Age-Standardised Mortality Burden, 1990–2023.*
    Age-specific death rate (deaths per 100,000) by age group, both sexes.
    Blue line = 1990 rate; red dashed line = 2023 rate. Pink shading =
    age groups where 2023 rate exceeded 1990; green shading = age groups
    with lower 2023 rates. Annotation boxes show age-standardised percent
    change with 95% CI (Monte Carlo, $n = 10{,}000$). Unintentional injuries
    and Diabetes & kidney diseases have been reclassified as decreasing under
    age standardisation and are shown in Figure 1 instead.
    Source: GBD Compare 2023 (IHME).
  ],
)

// ── 4. Discussion ────────────────────────────────────────────────────────────
= Discussion

== Principal Findings

This analysis reveals that Brazil's mortality burden between 1990 and 2023 has
shifted dramatically: communicable diseases, nutritional deficiencies, and
perinatal conditions have declined steeply, while several non-communicable and
injury categories have risen. These findings are consistent with the double
burden of disease described in the epidemiological transition literature
[4] and with recent national assessments [6].

== Successes: Communicable and Nutritional Causes

The near-elimination of enteric infection mortality in childhood (−90.1%)
is one of Brazil's most celebrated public-health achievements, attributable
to oral rehydration therapy, sanitation expansion, rotavirus vaccination (introduced 2006), and improvements in paediatric care [1]. Similarly, the
decline in nutritional deficiency deaths reflects the success of Bolsa Família
and food-security programmes [7]. Cardiovascular mortality reductions
of over 50% align with documented trends in hypertension control, expanding
cardiac care capacity, and reductions in smoking prevalence [8].

== Challenges: Non-Communicable Diseases and Injuries

The substantial rise in skin and subcutaneous disease mortality (+232.7%) is
not immediately explained by a single intervention failure; possible
contributors include improved diagnostic coding over time, the ageing of an
immunocompromised population, and rising melanoma incidence in a country with
high ultraviolet radiation exposure [9]. Future analyses should
disaggregate this category to identify specific conditions driving the trend.

The rise in substance use disorder mortality (+32.6%) reflects a well-documented
increase in alcohol-attributable deaths and crack cocaine use in Brazil's urban
centres [10]. Prevention and treatment programmes remain underfunded
relative to the scale of the problem.

The crude mean rate for diabetes and kidney disease mortality appeared to
increase (+16.3%), consistent with Brazil's rising obesity and physical
inactivity burden [11]. However, age standardisation reclassifies this cause
as a genuine decrease (−7.9%, 95% CI −11.8% to −3.9%), indicating that
age-specific risks have actually fallen — likely reflecting improvements in
glycaemic control, renal care, and dialysis access — and that the crude
apparent rise was an artefact of the expanding elderly population.

Similarly, the crude rise in unintentional injuries (+26.2%) reverses to
a standardised decline of −13.7% (95% CI −16.6% to −10.6%). This is
consistent with documented reductions in road-traffic fatalities among
working-age adults following road-safety legislation (e.g., the Dry Law
of 2008), partially offset by rising fall-related deaths in the elderly
that inflate the crude rate as the population ages.

== Age-Standardised Sensitivity Analysis

The mean age-specific rate used in the primary analysis weights each of the
25 GBD age bands equally, making it sensitive to demographic shifts between
1990 and 2023. To assess whether apparent trends reflect genuine changes in
age-specific risk versus changes in population age structure, we performed a
complementary direct age-standardisation using the mean of Brazil's 1990 and
2023 populations (United Nations World Population Prospects 2024) as the
standard. Uncertainty was propagated through all 25 GBD 95% confidence
intervals simultaneously via Monte Carlo simulation ($n = 10{,}000$ draws
per cause), assuming log-normal distributions for each age-specific rate.

*Two cause categories reversed direction under age standardisation:*

- *Unintentional injuries* appeared to worsen by #pct-up[+26.2%] in the
  unweighted analysis, but showed a standardised #pct-down[−13.7%]
  (95% CI −16.6% to −10.6%), indicating that the crude increase was driven
  by population ageing into injury-prone elderly age bands rather than by
  rising age-specific risk. These causes therefore belong among those with
  genuine mortality improvements and are included in Figure 1.
- *Diabetes and kidney diseases* shifted from an apparent #pct-up[+16.3%]
  crude increase to a standardised #pct-down[−7.9%] (95% CI −11.8% to
  −3.9%), similarly attributable to the expanding elderly share of the
  2023 population carrying elevated baseline mortality rates.

Additional findings from the standardised analysis:

- *Other non-communicable diseases* showed a substantially larger
  standardised increase (#pct-up[+100.6%], 95% CI +91.9% to +109.2%)
  than the unweighted +21.7%, reflecting disproportionately high age-specific
  rates at older ages combined with the greater elderly weight in the
  standard population.
- *Cardiovascular diseases* confirmed a true age-specific rate decline of
  #pct-down[−54.8%] (95% CI −56.6% to −52.9%), even as absolute deaths
  rose approximately +59% (∼265,000 in 1990 to ∼422,000 in 2023),
  illustrating how demographic growth can mask genuine epidemiological
  progress in count-based measures.
- *Respiratory infections and tuberculosis* showed a standardised decline of
  #pct-down[−10.0%] (95% CI −14.8% to −5.1%), more conservative than the
  unweighted −20.9%, because the standard population assigns greater weight
  to elderly age bands where rates remained elevated.
- Reductions in *enteric infections* (#pct-down[−90.5%]), *nutritional
  deficiencies* (#pct-down[−81.4%]), *neglected tropical diseases and
  malaria* (#pct-down[−74.2%]), and *maternal and neonatal disorders*
  (#pct-down[−60.8%]) were robust and directionally unchanged under age
  standardisation.

Remaining limitations include the ecological study design — population-level
trends cannot be attributed to specific policy interventions — and the
potential for GBD modelling uncertainty to affect estimates for causes
under-recorded in vital registration systems, such as skin and subcutaneous
diseases and neurological disorders.

== Conclusions

Brazil's mortality profile has undergone a classic — though incomplete —
epidemiological transition. The successes in reducing communicable, nutritional,
and perinatal mortality represent major public-health gains attributable to
multi-sector social investment. However, the rising burden of non-communicable
diseases (especially metabolic diseases, skin conditions, and substance use)
and the persistence of injury-related mortality underscore the need for
continued prioritisation of NCD prevention, mental health and addiction
services, and elderly care within the SUS.

// ── Declarations ─────────────────────────────────────────────────────────────
= Declarations

*Data availability.* All data used in this analysis are publicly available
from the IHME GBD Compare visualisation tool
(https://vizhub.healthdata.org/gbd-compare/). Raw CSV files and analysis code
are provided in the accompanying repository.

*Competing interests.* The authors declare no competing interests.

*Funding.* No external funding was received for this study.

*Author contributions.* Conceptualisation, data extraction, analysis,
visualisation, and manuscript preparation.

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
  population change. _Milbank Q._ 1971;49(4):509–538.]

#block[*\[4\]* Frenk J, Bobadilla JL, Stern C, et al. Elements for a theory of the health
  transition. _Health Transit Rev._ 1991;1(1):21–38.]

#block[*\[5\]* GBD 2023 Diseases and Injuries Collaborators. Global burden of 371 diseases
  and injuries: a systematic analysis for the Global Burden of Disease Study 2023.
  _Lancet._ 2024 (forthcoming). IHME, University of Washington, Seattle, WA.]

#block[*\[6\]* Malta DC, França EB, Abreu DMX, et al. Mortality due to noncommunicable
  diseases in Brazil, 1990 to 2015, according to the Global Burden of Disease
  study. _Sao Paulo Med J._ 2017;135(2):141–148.]

#block[*\[7\]* Rasella D, Aquino R, Santos CA, et al. Effect of a conditional cash transfer
  programme on childhood mortality: a nationwide analysis of Brazilian
  municipalities. _Lancet._ 2013;382(9886):57–64.]

#block[*\[8\]* Chor D, Pinho Ribeiro AL, Sá Carvalho M, et al. Prevalence, awareness,
  treatment and influence of socioeconomic variables on control of high blood
  pressure: results from the ELSA-Brasil study. _PLoS One._
  2015;10(6):e0127382.]

#block[*\[9\]* Bray F, Laversanne M, Sung H, et al. Global cancer statistics 2022:
  GLOBOCAN estimates of incidence and mortality worldwide for 36 cancers in 185
  countries. _CA Cancer J Clin._ 2024;74(3):229–263.]

#block[*\[10\]* Carlini EA, Noto AR, Sanchez ZM, et al. VI Levantamento Nacional Sobre o
  Consumo de Drogas Psicotrópicas Entre Estudantes do Ensino Fundamental e
  Médio das Redes Pública e Privada de Ensino nas 27 Capitais Brasileiras.
  CEBRID/UNIFESP, 2012.]

#block[*\[11\]* Associação Brasileira para o Estudo da Obesidade e da Síndrome Metabólica.
  _Diretrizes Brasileiras de Obesidade._ 5th ed. São Paulo: ABESO; 2020.]
