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
#let green-dark  = rgb("#1a7a4a")
#let red-dark    = rgb("#c0392b")
#let grey-light  = rgb("#f5f5f5")
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
#let pct-up(v)   = text(fill: red-dark,   weight: "bold", v)
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
]

#v(1.5em)
#line(length: 100%, stroke: 0.5pt)
#v(1em)

// ── Abstract ─────────────────────────────────────────────────────────────────
= Abstract

*Background.* Brazil has undergone dramatic epidemiological transition over
the past three decades. Understanding which cause-of-death categories have
driven improvements versus which are imposing growing burdens is essential for
health-system planning.

*Methods.* Using age-specific death rates (deaths per 100,000) from the Global
Burden of Disease (GBD) Study 2023 for Brazil (1990 and 2023, both sexes,
25 age groups), we calculated mean age-specific rates across all 25 GBD age
bands for each of 22 cause categories and derived relative percent changes.
Categories were classified as "improved" or "worsening" based on the
direction of change.

*Results.* Thirteen of 22 cause categories showed decreased mean age-specific
mortality rates. The largest reductions were in enteric infections (#pct-down[−90.1%]),
nutritional deficiencies (#pct-down[−73.0%]), neglected tropical diseases and
malaria (#pct-down[−66.1%]), maternal and neonatal disorders (#pct-down[−60.4%]),
and cardiovascular diseases (#pct-down[−51.4%]). Conversely, eight categories
showed increased rates, most prominently skin and subcutaneous diseases
(#pct-up[+232.7%]), substance use disorders (#pct-up[+32.6%]), unintentional
injuries (#pct-up[+26.2%]), other non-communicable diseases (#pct-up[+21.7%]),
and diabetes and kidney diseases (#pct-up[+16.3%]).

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

$ macron(r)_"cause, year" = 1/25 sum_(i=1)^{25} r_{i, "cause, year"} $

where $r_{i, "cause, year"}$ denotes the death rate (per 100,000) in age
group $i$. This summary statistic weights each age group equally and mirrors
the "% change in mean age-specific rate across 25 GBD age groups" metric
displayed in the published figures.

The relative percent change between years was calculated as:

$ Delta% = frac(macron(r)_"2023" - macron(r)_"1990", macron(r)_"1990") times 100 $

Causes were classified as *improved* ($Delta% < 0$) or
*worsening* ($Delta% > 0$). All calculations were performed in Python 3.x
using the `csv` standard library only, ensuring full reproducibility without
external dependencies. Code is provided in `scripts/analysis.py`.

== Visualisation

Age-specific rate curves for 1990 and 2023 were plotted for selected cause
categories. Figures 1 and 2 show causes with the greatest reductions and
greatest increases, respectively, with the shaded area between curves
representing the direction and magnitude of change.

== Ethics

This study uses publicly available, de-identified aggregated data; no
individual-level data were collected or analysed. Institutional review board
approval was not required.

// ── 3. Results ───────────────────────────────────────────────────────────────
= Results

== Summary Statistics

Of 22 cause categories, 13 showed decreased mean age-specific mortality
between 1990 and 2023, eight showed increases, and one (neoplasms) was
essentially unchanged ($Delta% = +0.1%$). Table 1 presents the complete
results sorted by direction of change.

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
    [Enteric infections],                              [199.3], [19.7],
    text(fill: green-dark, weight: "bold")[−90.1%],

    [Other infectious diseases],                       [39.6],  [6.8],
    text(fill: green-dark, weight: "bold")[−82.8%],

    [Nutritional deficiencies],                        [58.5],  [15.8],
    text(fill: green-dark, weight: "bold")[−73.0%],

    [Neglected tropical diseases and malaria],          [33.2],  [11.2],
    text(fill: green-dark, weight: "bold")[−66.1%],

    [Maternal and neonatal disorders],                [4316.3], [1710.0],
    text(fill: green-dark, weight: "bold")[−60.4%],

    [Transport injuries],                              [37.7],  [16.9],
    text(fill: green-dark, weight: "bold")[−55.2%],

    [Cardiovascular diseases],                        [1523.8],  [740.6],
    text(fill: green-dark, weight: "bold")[−51.4%],

    [Chronic respiratory diseases],                    [250.8],  [164.1],
    text(fill: green-dark, weight: "bold")[−34.6%],

    [Respiratory infections and tuberculosis],          [402.2],  [318.2],
    text(fill: green-dark, weight: "bold")[−20.9%],

    [Self-harm and interpersonal violence],             [30.3],   [25.6],
    text(fill: green-dark, weight: "bold")[−15.5%],

    [Mental disorders],                                  [0.0],    [0.0],
    text(fill: green-dark, weight: "bold")[−13.2%],

    [Digestive diseases],                              [121.2],  [110.7],
    text(fill: green-dark, weight: "bold")[−8.7%],

    // Stable
    [Neoplasms],                                       [346.9],  [347.2],
    text(weight: "bold")[+0.1%],

    // Increased causes ─────────────────
    [HIV/AIDS and sexually transmitted infections],    [14.2],   [14.6],
    text(fill: red-dark, weight: "bold")[+2.4%],

    [Neurological disorders],                          [359.2],  [374.9],
    text(fill: red-dark, weight: "bold")[+4.4%],

    [Musculoskeletal disorders],                         [4.1],    [4.5],
    text(fill: red-dark, weight: "bold")[+10.0%],

    [Diabetes and kidney diseases],                    [178.6],  [207.7],
    text(fill: red-dark, weight: "bold")[+16.3%],

    [Other non-communicable diseases],                 [340.1],  [414.0],
    text(fill: red-dark, weight: "bold")[+21.7%],

    [Unintentional injuries],                           [76.2],   [96.2],
    text(fill: red-dark, weight: "bold")[+26.2%],

    [Substance use disorders],                           [3.8],    [5.0],
    text(fill: red-dark, weight: "bold")[+32.6%],

    [Skin and subcutaneous diseases],                    [9.3],   [31.0],
    text(fill: red-dark, weight: "bold")[+232.7%],
  )
]

== Causes with the Greatest Mortality Reductions

Figure 1 illustrates the six cause categories with the largest
proportional declines.

*Enteric infections* (−90.1%) showed the most dramatic improvement, with
very high death rates in infancy in 1990 — exceeding 1,000 per 100,000 in
the 12–23-month group — collapsing to near-zero levels by 2023 across all
paediatric age groups. Mean rates fell from 199.3 to 19.7 per 100,000 across
age groups.

*Maternal and neonatal disorders* (−60.4%) exhibited extreme concentration of
risk in the earliest age groups (neonatal period), declining from a mean rate
of 2,589.8 in 1990 to 1,026.0 per 100,000 per age group in 2023.

*Nutritional deficiencies* (−73.0%) and *neglected tropical diseases and
malaria* (−66.1%) similarly showed large absolute reductions concentrated in
early childhood.

*Cardiovascular diseases* (−51.4%), the leading contributor to adult
mortality in absolute terms (mean rate 1,523.8 per 100,000 in 1990), declined
by more than half over the study period. The rate reduction was most evident
in the 65–95+ age bands, suggesting improved treatment and prevention
in older adults.

*Respiratory infections and tuberculosis* (−20.9%) declined modestly in
younger and middle age groups, though the oldest-old (95+) age band showed
a relative increase by 2023, consistent with an ageing population surviving
to older age and becoming susceptible to respiratory death.

#figure(
  image("figures/fig1_decreased_fixed.png", width: 100%),
  caption: [
    *Brazil — Causes with Greatest Mortality Reductions, 1990–2023.*
    Age-specific death rate (deaths per 100,000) by age group, both sexes.
    Blue shaded area = 1990 rate curve; red dashed line = 2023 rate curve.
    Shaded region between curves represents the magnitude of reduction.
    Percent change reflects relative change in mean age-specific rate across
    all 25 GBD age groups. Source: GBD Compare 2023 (IHME).
  ]
)

== Causes with Rising Mortality Burden

Figure 2 shows the six categories with the largest proportional
increases.

*Skin and subcutaneous diseases* displayed the most dramatic rise
(#pct-up[+232.7%]), with mean rates increasing from 9.3 to 31.0 per 100,000
per age group. The increase was concentrated among the elderly (75+ years),
suggesting a combined contribution of ageing demographics, increased
prevalence of immunosuppressive conditions, and possibly improved diagnostic
ascertainment.

*Substance use disorders* (#pct-up[+32.6%]) increased from a mean rate of 3.8
to 5.0 per 100,000, with the peak in the 45–65-year age band in 2023
notably higher than in 1990, consistent with longitudinal cohort effects
of increased alcohol and drug exposure in earlier birth cohorts now reaching
middle age.

*Unintentional injuries* (#pct-up[+26.2%]) showed increases across most adult
age bands. Mean rates rose from 76.2 to 96.2 per 100,000, reflecting Brazil's
growing burden from falls (especially in the elderly) and workplace injuries.

*Other non-communicable diseases* (#pct-up[+21.7%]) and *diabetes and kidney
diseases* (#pct-up[+16.3%]) showed increases concentrated in older adult and
elderly age groups. Diabetic nephropathy, end-stage renal disease, and related
complications are increasingly driving mortality as Brazil's population ages
and obesity prevalence rises.

*Neurological disorders* (#pct-up[+4.4%]) showed a modest increase, with mean
rates rising from 359.2 to 374.9. The shape of the 2023 curve in the oldest
age groups substantially exceeds 1990, again consistent with demographic
ageing.

#figure(
  image("figures/fig2_increased_fixed.png", width: 100%),
  caption: [
    *Brazil — Causes with Rising Mortality Burden, 1990–2023.*
    Age-specific death rate (deaths per 100,000) by age group, both sexes.
    Red dashed curve = 2023; blue = 1990. Pink shading represents excess 2023
    mortality relative to 1990. Percent change as per Figure 1.
    Source: GBD Compare 2023 (IHME).
  ]
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

Increasing diabetes and kidney disease mortality (+16.3%) is consistent with
Brazil's rapidly rising obesity and physical inactivity burden [11].
The GBD 2023 also projects continued increases in this category absent major
structural interventions.

The modest rise in unintentional injuries (+26.2%) masks heterogeneous age
patterns: in younger adults, road traffic injuries have declined following
road-safety legislation (e.g., the Dry Law of 2008), but fall-related deaths
in the elderly have increased, reflecting demographic ageing.

== Methodological Considerations

Several limitations should be noted. First, the mean age-specific rate is an
unweighted summary; it does not account for the actual age distribution of
the Brazilian population, which has shifted considerably between 1990 and 2023.
Second, GBD estimates incorporate multiple data sources and modelling
assumptions; cause-of-death redistribution for ill-defined codes may introduce
uncertainty, particularly for causes such as skin diseases or neurological
disorders that are often under-recorded in vital registration. Third, this
analysis is ecological: it describes population-level trends and cannot
attribute causation to specific policy interventions.

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
