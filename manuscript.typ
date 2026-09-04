// ─────────────────────────────────────────────────────────────────────────────
// Shifting Mortality Burden in Brazil, 1990–2023
// Typst manuscript source (SciELO Preprints submission)
//
// All numerical values (tables and in-text figures) are read at compile time
// from build/results.json, which is produced by `python scripts/build_results.py`.
// No statistic is typed by hand. References are rendered by Typst from
// references/references.bib (Vancouver style, numbered by first appearance).
// Build order:
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

#set text(font: "Libertinus Serif", size: 11pt, lang: "en", hyphenate: true)
#set heading(numbering: "1.")
#set par(justify: true, leading: 0.65em, spacing: 1.2em)

#set document(
  title: "Shifting Mortality Burden in Brazil, 1990–2023: Age-Standardised Changes Across Cause Categories from the Global Burden of Disease Study 2023",
  author: "Eduardo S. A. Santos",
)

// Hyperlinks, cross-references and citations rendered as coloured links.
#let link-blue = rgb("#1a4f8a")
#show link: it => text(fill: link-blue, it)
#show ref: it => text(fill: link-blue, it)
#show cite: it => text(fill: link-blue, it)

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
#let P = R.premature       // probability of death at 30–69 from four NCD groups

// Colour a preformatted change string by its sign (− green, + red).
#let vcol(s) = if s.starts-with("−") { green-dark } else if s.starts-with("+") { red-dark } else { rgb("#333333") }
#let cv(s) = text(fill: vcol(s), weight: "bold", s)
#let drop(s) = text(fill: green-dark, weight: "bold", s.replace("−", ""))

// Portuguese number formatting for the Resumo (decimal comma).
#let pt(s) = s.replace(".", ",")

// Table-cell builders driven by the JSON records.
#let hcell(b) = text(fill: white, weight: "bold", b)
#let name-cell(c) = {
  [#c.name_short]
  if c.sup != "" { [#super[#c.sup]] }
  if c.discordant { [ †] }
  if c.spans_zero { [ ‡] }
}
#let t2-name(r) = if r.bold { text(weight: "bold", r.name) } else { [#r.name] }

// ── Title block ──────────────────────────────────────────────────────────────
#align(center)[
  #text(size: 16pt, weight: "bold")[
    Shifting Mortality Burden in Brazil, 1990–2023:
    Age-Standardised Changes Across Cause Categories
    from the Global Burden of Disease Study 2023
  ]
  #v(0.6em)
  #text(size: 10.5pt, style: "italic")[
    Descriptive Cross-sectional Analysis of GBD 2023 Estimates (IHME)
  ]
  #v(0.4em)
  #text(size: 10pt)[September 2026 · Preprint submitted to SciELO Preprints · Not yet peer reviewed]

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
#heading(numbering: none)[Abstract]

*Background.* Brazil has undergone a marked epidemiological transition over the
past three decades. Because its population has aged substantially since 1990,
summary mortality measures that do not account for age structure can mislead.
We quantified age-standardised changes in cause-specific mortality and
contrasted them with changes in death counts and crude rates.

*Methods.* Using age-specific death rates (deaths per 100,000) from the Global
Burden of Disease (GBD) Study 2023 for Brazil (1990 and 2023, both sexes, 25
age groups), we computed age-standardised death rates (ASRs) for #S.n_causes
Level-2 cause categories by direct standardisation to the WHO World Standard
Population. The primary outcome was the relative percent change in ASR between
1990 and 2023; 95% uncertainty intervals (UIs) were obtained by Monte Carlo
propagation of the GBD age-specific intervals (10,000 draws per cause). We also
computed the unconditional probability of death between ages 30 and 70 from the
four major non-communicable disease (NCD) groups, and, as a methodological
comparison, the unweighted mean of the 25 age-specific rates. GBD's own
age-standardised rates (GBD world standard) for every year 1990–2023 were used
for external validation and to describe the trajectory through the COVID-19
pandemic.

*Results.* Of the #S.n_causes categories, #S.n_decreased_sig showed a decrease
and #S.n_increased_sig an increase in age-standardised mortality whose 95% UI
excluded zero; #S.w_indeterminate (#S.indeterminate_list) showed no detectable
change. The largest standardised reductions were in enteric infections
(#cv(C.enteric.asr_pct), 95% UI #C.enteric.asr_ci), nutritional deficiencies
(#cv(C.nutritional.asr_pct)), neglected tropical diseases and malaria
(#cv(C.ntd.asr_pct)), maternal and neonatal disorders (#cv(C.maternal.asr_pct)),
and cardiovascular diseases (#cv(C.cvd.asr_pct)). The largest increases were in
skin and subcutaneous diseases (#cv(C.skin.asr_pct), 95% UI #C.skin.asr_ci),
other non-communicable diseases (#cv(C.other_ncd.asr_pct)), and substance use
disorders (#cv(C.substance.asr_pct)). #S.W_reversed categories (unintentional
injuries, neoplasms, and diabetes and kidney diseases) rose on the
unweighted-mean metric but declined once age-standardised. Across the
#S.n_causes categories combined, deaths rose #cv(G.all.deaths_pct) and the crude
rate #cv(G.all.crude_pct) while the age-standardised rate fell by
#drop(G.all.asr_pct); for NCDs, deaths more than doubled (#cv(G.ncd.deaths_pct))
while the standardised rate fell by #drop(G.ncd.asr_pct). The probability of dying
between ages 30 and 70 from the four major NCD groups fell from #P.p90 to
#P.p23 (#drop(P.pct)). WHO-standard changes agreed in direction with GBD's own
age-standardised changes for all #R.gbd.n_total categories (maximum absolute
difference #R.gbd.max_abs_diff percentage points). The all-cause
age-standardised rate peaked in #R.gbd.pandemic_peak_year and by 2023 was
#cv(R.gbd.all_2023_vs_2019_pct) relative to 2019.

*Conclusions.* Brazil's mortality profile has shifted from communicable,
perinatal, and nutritional causes toward NCDs. Rising death counts and crude
rates coexist with falling age-standardised rates, so age structure must be
accounted for before mortality changes are interpreted or acted upon.

*Keywords:* Health Transition; Brazil; Mortality; Global Burden of Disease;
Noncommunicable Diseases; Epidemiologic Methods.

#v(0.6em)

#heading(numbering: none)[Resumo]

*Introdução.* O Brasil passou por uma acentuada transição epidemiológica nas
últimas três décadas. Como a população envelheceu substancialmente desde 1990,
medidas-resumo de mortalidade que não consideram a estrutura etária podem
induzir a interpretações equivocadas. Quantificamos as variações padronizadas
por idade da mortalidade por causa e as contrastamos com as variações do número
de óbitos e das taxas brutas.

*Métodos.* A partir de taxas de mortalidade específicas por idade (óbitos por
100 mil habitantes) do estudo Global Burden of Disease (GBD) 2023 para o Brasil
(1990 e 2023, ambos os sexos, 25 faixas etárias), calcularam-se taxas de
mortalidade padronizadas por idade (TMPI) para #S.n_causes categorias de causas
de nível 2, por padronização direta pela população-padrão mundial da OMS. O
desfecho primário foi a variação percentual relativa da TMPI entre 1990 e 2023;
intervalos de incerteza (II) de 95% foram obtidos por propagação de Monte Carlo
dos intervalos do GBD por faixa etária (10 mil sorteios por causa). Calculou-se
também a probabilidade incondicional de morte entre 30 e 70 anos pelos quatro
principais grupos de doenças crônicas não transmissíveis (DCNT) e, como
comparação metodológica, a média não ponderada das 25 taxas específicas por
idade. As taxas padronizadas do próprio GBD (população-padrão mundial do GBD)
para todos os anos de 1990 a 2023 foram usadas para validação externa e para
descrever a trajetória durante a pandemia de COVID-19.

*Resultados.* Das #S.n_causes categorias, #S.n_decreased_sig apresentaram
redução e cinco, aumento da mortalidade padronizada com II de 95% que excluem o
zero; três (transtornos mentais, autoagressão e violência interpessoal, e
doenças neurológicas) não apresentaram variação detectável.
As maiores reduções padronizadas ocorreram em infecções entéricas
(#cv(pt(C.enteric.asr_pct))), deficiências nutricionais
(#cv(pt(C.nutritional.asr_pct))), doenças tropicais negligenciadas e malária
(#cv(pt(C.ntd.asr_pct))), distúrbios maternos e neonatais
(#cv(pt(C.maternal.asr_pct))) e doenças cardiovasculares (#cv(pt(C.cvd.asr_pct))).
Os maiores aumentos ocorreram em doenças da pele e do tecido subcutâneo
(#cv(pt(C.skin.asr_pct))), outras DCNT (#cv(pt(C.other_ncd.asr_pct))) e
transtornos por uso de substâncias (#cv(pt(C.substance.asr_pct))). Três
categorias (lesões não intencionais, neoplasias, e diabetes e doenças renais)
aumentaram pela média não ponderada, mas diminuíram após padronização. No
conjunto das #S.n_causes categorias, os óbitos aumentaram
#cv(pt(G.all.deaths_pct)) e a taxa bruta #cv(pt(G.all.crude_pct)), enquanto a
taxa padronizada caiu #drop(pt(G.all.asr_pct)); para as DCNT, os óbitos mais que
dobraram (#cv(pt(G.ncd.deaths_pct))) enquanto a taxa padronizada caiu
#drop(pt(G.ncd.asr_pct)). A probabilidade de morte entre 30 e 70 anos pelos quatro
principais grupos de DCNT caiu de #pt(P.p90) para #pt(P.p23) (#drop(pt(P.pct))).
As variações pelo padrão da OMS concordaram em direção com as variações
padronizadas do próprio GBD para todas as #R.gbd.n_total categorias (diferença
absoluta máxima de #pt(R.gbd.max_abs_diff) pontos percentuais). A taxa
padronizada por todas as causas atingiu o pico em #R.gbd.pandemic_peak_year e,
em 2023, estava #cv(pt(R.gbd.all_2023_vs_2019_pct)) em relação a 2019.


*Conclusões.* O perfil de mortalidade brasileiro deslocou-se das causas
transmissíveis, perinatais e nutricionais para as DCNT. Aumentos do número de
óbitos e das taxas brutas coexistem com quedas das taxas padronizadas por idade,
de modo que a estrutura etária deve ser considerada antes que variações de
mortalidade sejam interpretadas ou orientem decisões.

*Palavras-chave:* Transição Epidemiológica; Brasil; Mortalidade; Carga Global
da Doença; Doenças não Transmissíveis; Métodos Epidemiológicos.

#v(1em)
#line(length: 100%, stroke: 0.5pt)
#v(1em)

// ── 1. Introduction ──────────────────────────────────────────────────────────
= Introduction

Brazil, Latin America's most populous country, has experienced one of the most
substantial public-health transformations of recent decades. The consolidation
of the Unified Health System (Sistema Único de Saúde, SUS) from 1990 onward,
successive improvements in water and sanitation infrastructure, large-scale
immunisation campaigns, and conditional cash-transfer programmes such as Bolsa
Família collectively drove steep reductions in child and infectious-disease
mortality @Victora2011 @Souza2018. Over the same period, urbanisation, dietary
change, reduced physical activity, and a rapidly ageing population fuelled a
growing non-communicable disease (NCD) burden @Schmidt2011.

The concept of epidemiological transition, articulated by Omran @Omran1971,
describes the shift from mortality dominated by infection and undernutrition
toward chronic, degenerative conditions and injuries. Brazil is frequently
described as undergoing a "polarised" or "protracted" transition, in which
residual communicable-disease mortality and a rising NCD burden coexist, often
concentrated in different age groups or regions @Frenk1991 @Schramm2004.
Successive rounds of the Global Burden of Disease (GBD) Study have documented
this transition for Brazil and its states, including the national and
subnational analysis of GBD 2016 @GBD2016Brazil2018, the assessment of 30 years
of the SUS @Souza2018, and NCD-specific trend and projection analyses
@Malta2017 @Malta2020. The GBD Study, produced by the Institute for Health
Metrics and Evaluation (IHME), offers the most comprehensive such assessment;
its 2023 round estimated the burden of 375 diseases and injuries across 204
countries and territories (and 660 subnational locations) within a common
comparative framework @GBD2023Collaborators2025.

Monitoring these shifts has direct policy salience. NCDs account for about
three-quarters of deaths worldwide @WHO2023NCDFacts. The World Health
Organization's Global Action Plan for the Prevention and Control of NCDs set a
target of a 25% relative reduction in premature NCD mortality by 2025
@WHO2013, reinforced by Sustainable Development Goal (SDG) target 3.4 (a
one-third reduction by 2030) @UNSDG341 and by Brazil's successive national NCD
plans for 2011–2022 and 2021–2030 @Malta2017 @Brasil2021PlanoDANT. Tracking
whether age-standardised mortality is in fact falling, and for which causes, is
therefore essential to assessing progress against these commitments.

A central methodological issue motivates this analysis. Brazil's population
aged markedly between 1990 and 2023: the median age rose by roughly half, from
about 22 to about 33 years, and the share of the population aged 60 years and
over more than doubled @UN2024. Because mortality rates for most chronic
diseases and many injuries rise steeply with age, any summary measure that does
not hold age structure constant can register an apparent increase in mortality
even when age-specific risk is falling. Earlier GBD-based work for Brazil has
shown exactly this divergence at the aggregate level for NCDs @Malta2017; the
present study extends it to every major cause category and to the post-pandemic
year 2023.

The objectives of this study were therefore to (i) quantify the
age-standardised change in mortality for each major cause category in Brazil
between 1990 and 2023; (ii) characterise the underlying age-pattern of these
changes; (iii) contrast standardised changes with changes in death counts and
crude rates; (iv) estimate the change in premature NCD mortality as defined by
the global targets; (v) identify the causes for which the direction of change
depends on whether age structure is taken into account; and (vi) validate the
results against GBD's own age-standardised rates and place the 2023 endpoint in
the context of the annual trajectory, including the COVID-19 pandemic.

// ── 2. Methods ───────────────────────────────────────────────────────────────
= Methods

This descriptive cross-sectional study analyses aggregated, publicly available
mortality estimates; it is reported in accordance with the STROBE guideline for
cross-sectional studies @vonElm2007 (checklist provided as Supplementary
Material).

== Data source

Age-specific death rates (deaths per 100,000 population) were obtained from the
IHME GBD Compare / GBD Results tool for Brazil, both sexes combined, for the
calendar years 1990 and 2023, across all 25 GBD age groups (0–6 days through
95+ years) and the 22 Level-2 cause categories of the GBD cause hierarchy as
implemented in the tool @IHME2025_GBDCompare. One category (sense organ
diseases) carries no mortality estimate and was excluded, leaving #S.n_causes
categories. For every age group the tool provides a point estimate and a 95%
uncertainty interval. A second extract, for Brazil, both sexes, all ages
combined, provided the absolute number of deaths and the crude (all-ages) death
rate per 100,000 for the same categories in 1990 and 2023; these are used in
the absolute-burden analysis (@tab:burden). A third extract, from the GBD
Results tool, provided deaths (number and crude rate) and GBD's own
age-standardised death rates (GBD 2023 world standard population) for Brazil,
both sexes, for every year from 1990 to 2023, for the 22 Level-2 categories,
for COVID-19, and for all causes combined. It serves three purposes. First, it
validates that the Level-2 extract is exhaustive: in every year the sum of the
Level-2 categories reproduces GBD's all-cause totals for deaths and crude rates
(maximum absolute difference #R.validation.max_abs_diff_deaths deaths), so the
aggregates reported here are true all-cause figures. The same check locates
COVID-19, which the GBD 2023 capstone paper displays alongside the Level-2
causes @GBD2023Collaborators2025: because the Level-2 sum equals the all-cause
total without adding COVID-19, and because the 2019–2021 jump in respiratory
infections and tuberculosis (#R.covid.resp_jump2021 deaths) matches the
COVID-19 count for 2021 (#R.covid.deaths2021), COVID-19 is nested within that
category in the tool's hierarchy, as in GBD 2021 @GBD2021CausesOfDeath2024.
Second, GBD's age-standardised changes provide an external check on the
WHO-standard changes computed here. Third, the annual series describes the
trajectory through the pandemic years. Data were extracted on 4 June 2026
(age-specific rates), 9 June 2026 (all-ages counts and crude rates), and
4 September 2026 (annual series).

#note[
  Institute for Health Metrics and Evaluation (IHME). _GBD Compare / GBD
  Results tool. Global Burden of Disease (GBD) Study 2023._ Seattle, WA: IHME,
  University of Washington, 2025. Available from
  #link("https://vizhub.healthdata.org/gbd-compare/") and
  #link("https://vizhub.healthdata.org/gbd-results/"). Accessed 4 June, 9 June,
  and 4 September 2026.
]

== GBD estimation framework

The estimates analysed here are modelled outputs of the GBD study rather than
raw death counts, and the GBD methodology has been described in detail
elsewhere @GBD2023Collaborators2025 @GBD2021CausesOfDeath2024. In brief, for
Brazil the principal input is the national Mortality Information System
(Sistema de Informação sobre Mortalidade, SIM), supplemented by other
vital-registration and survey sources @GBD2016Brazil2018. GBD applies
standardised procedures to correct for under-registration of deaths and to
redistribute "garbage codes" (deaths assigned to causes that cannot be an
underlying cause of death) to their most probable true causes, and it models
cause-specific mortality with the Cause of Death Ensemble model (CODEm),
constraining cause-specific estimates so that they sum to all-cause mortality
@GBD2021CausesOfDeath2024. GBD reports each estimate with a 95% uncertainty
interval derived from the percentiles of its posterior draw distribution; our
uncertainty propagation (below) resamples these published intervals. GBD also
publishes age-standardised rates using its own world standard population
@GBD2023Collaborators2025; the present analysis uses the WHO World Standard
instead (below) so that results are comparable with the wider literature that
uses that standard. These corrections substantially improve cross-national and
temporal comparability relative to unadjusted vital statistics, but they also
mean the estimates carry modelling uncertainty that is larger for causes that
are under-recorded or frequently miscertified (addressed in the Discussion).

== Primary analysis: age-standardised death rates

For each cause and year we computed the age-standardised death rate (ASR) by
direct standardisation to the WHO World Standard Population @Ahmad2001, an
external, fixed standard:

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

A category was classified as having decreased or increased when the 95%
uncertainty interval of $Delta%_"std"$ excluded zero, and as showing no
detectable change otherwise. Level-1 aggregates (communicable, maternal,
neonatal, and nutritional causes; NCDs; injuries; and all #S.n_causes
categories combined) were obtained by summing the constituent age-specific
rates, which are additive across mutually exclusive causes, before
standardisation.

== Uncertainty propagation

ASR point estimates were computed deterministically from the reported GBD point
rates. To propagate GBD estimation uncertainty into the percent change, we used
Monte Carlo simulation with 10,000 draws per cause. For each draw, every
age-specific rate was sampled independently from a log-normal distribution
whose median equalled the GBD point estimate and whose dispersion reproduced
the reported 95% interval; for the small number of age groups with a
non-positive lower bound, a normal distribution with negative draws set to zero
(a censored normal) was used instead. Draws for 1990 and for 2023 were also
treated as independent. The 95% uncertainty interval for $Delta%_"std"$ is the
2.5th–97.5th percentile of the simulated distribution. To guarantee exact
reproducibility irrespective of execution order, each cause–year simulation was
seeded deterministically from the cause label. We use the term "uncertainty
interval" throughout, following GBD, because these intervals propagate modelled
estimation uncertainty rather than sampling error.

== Premature NCD mortality

To relate the findings to the WHO Global Action Plan and SDG target 3.4, which
are framed in terms of premature mortality, we computed the unconditional
probability of dying between exact ages 30 and 70 from the four major NCD
groups (cardiovascular diseases, neoplasms, chronic respiratory diseases, and
diabetes) using the standard life-table approach of the SDG indicator 3.4.1
metadata @UNSDG341: for each of the eight five-year age groups from 30–34 to
65–69, $q_i = 1 - exp(-5 m_i)$ where $m_i$ is the summed age-specific death
rate of the four groups, and $P_(30-70) = 1 - product_i (1 - q_i)$. Because the
GBD Level-2 category combines diabetes with chronic kidney disease, the
indicator computed here includes kidney-disease deaths and is therefore a close
approximation to, not an exact reproduction of, the official indicator.
Uncertainty was propagated with the same Monte Carlo procedure.

== Comparison metric

For comparison we computed the *unweighted mean of the 25 age-specific rates*,
$macron(r) = (1\/25) sum_i r_i$. This is not a metric published by GBD or used
in standard epidemiology; it is a didactic benchmark illustrating the pitfall
an analyst encounters by naively averaging the rows of an age-disaggregated
extract without weighting by population structure. It assigns each age band
equal weight regardless of its demographic share, thereby over-representing the
very old and neonatal age groups. It is reported strictly to identify causes
whose direction of change is inverted by omitting demographic weights and is not
used for substantive epidemiological inference.

== Absolute burden

To place the rate analysis in context, we report the absolute number of deaths
and the crude (all-ages) death rate for each cause and Level-1 group in 1990
and 2023, with their relative changes. The crude rate uses Brazil's actual
population age structure in each year, so, unlike the age-standardised rate, it
is affected by population growth and ageing; juxtaposing the two isolates the
demographic contribution to the change in burden. Counts and crude rates are
reported as GBD point estimates.

== External validation and annual trajectory

For each category and for all causes we compared the 1990–2023 percent change
in GBD's own age-standardised rate, which uses the GBD world standard
population, with the WHO-standard change computed here. The two standards
weight ages differently, so the absolute rates differ, but the relative
changes should agree closely if the standardisation is correct; we report the
direction agreement and the maximum absolute difference in percentage points.
GBD's annual age-standardised rates (1990–2023) for all causes, the three
Level-1 groups (summed from their constituent categories), and respiratory
infections and tuberculosis with and without COVID-19 are shown to place the
two endpoints in context (@tab:gbd, @fig:trajectory). These GBD rates are used
descriptively; the primary WHO-standard analysis was not repeated for
intermediate years because age-specific extracts were obtained only for 1990
and 2023.

== Software and reproducibility

All analyses were performed in Python 3. The unweighted-mean metric is
reproduced by `scripts/analysis.py` (standard library only); the
age-standardised analysis, premature-mortality indicator, and uncertainty
propagation by `scripts/analysis_standardised.py` (using NumPy); the
absolute-burden analysis by `scripts/analysis_counts.py`; the GBD annual series
by `scripts/gbd_series.py`; and the figures by `scripts/figures.py`. A single build step, `scripts/build_results.py`, writes
every reported quantity to `build/results.json`, which this manuscript reads at
compile time; consequently no statistic in the text or tables is entered by
hand. Data, code, and the manuscript source are openly available (see Data and
Code Availability).

== Ethics

This study uses publicly available, de-identified, aggregated data; no
individual-level data were collected or analysed. Institutional review board
approval was not required.

// ── 3. Results ───────────────────────────────────────────────────────────────
= Results

== Overview

Of the #S.n_causes cause categories analysed, #S.n_decreased_sig showed a
decrease and #S.n_increased_sig an increase in age-standardised mortality
between 1990 and 2023 with a 95% UI excluding zero; the remaining
#S.w_indeterminate (#S.indeterminate_list) showed no detectable change
(@tab:asr). #S.W_reversed categories (unintentional injuries, neoplasms, and
diabetes and kidney diseases) increased on the unweighted-mean metric but
declined once age-standardised; no category moved in the opposite direction.
Reductions were concentrated in communicable, perinatal, and nutritional causes,
and increases in non-communicable categories.

#figure(
  caption: [Age-standardised death rates (deaths per 100,000, WHO World
    Standard Population) per cause category in Brazil, 1990 and 2023, sorted by
    percent change in the age-standardised rate. The final column shows the
    change in the unweighted mean of the 25 age-specific rates for comparison.
    95% uncertainty intervals (UI) are from Monte Carlo propagation of GBD
    intervals (n = 10,000). † Direction of change differs between the two
    metrics. ‡ 95% UI includes zero (no detectable change).],
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
    hcell[Δ% ASR (95% UI)], hcell[Δ% mean],

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
    #super[a] Within the mental disorders category GBD assigns deaths only to
    eating disorders; suicide is counted under self-harm and interpersonal
    violence. Direct mental-disorder mortality is therefore near zero and its
    percent change is unstable (wide interval).
  ]
] <tab:asr>

== Burden by GBD Level-1 group

Aggregating the #S.n_causes categories into the three GBD Level-1 groups, the
age-standardised death rate fell in all three between 1990 and 2023:
communicable, maternal, neonatal, and nutritional causes by
#cv(G.cmnn.asr_pct) (from #G.cmnn.asr90 to #G.cmnn.asr23 per 100,000; 95% UI
#G.cmnn.asr_ci), non-communicable diseases by #cv(G.ncd.asr_pct)
(#G.ncd.asr90 to #G.ncd.asr23; 95% UI #G.ncd.asr_ci), and injuries by
#cv(G.injuries.asr_pct) (#G.injuries.asr90 to #G.injuries.asr23; 95% UI
#G.injuries.asr_ci). The communicable group declined fastest, so its share of
the total contracted while the NCD share expanded, the proportional shift that
defines the epidemiological transition. The NCD group's age-standardised rate
fell substantially even though several of its constituent categories rose
(@tab:asr): the decline of the dominant cardiovascular category outweighs the
increases in smaller NCD categories.

== Absolute burden: deaths and crude rates versus standardised rates

The number of deaths and the crude death rate tell a markedly different story
from the age-standardised rate (@tab:burden). Across the #S.n_causes categories
combined, the number of deaths rose #cv(G.all.deaths_pct), from
#G.all.deaths90 in 1990 to #G.all.deaths23 in 2023, and the crude death rate
rose #cv(G.all.crude_pct), even though the age-standardised rate fell by
#drop(G.all.asr_pct) (95% UI #G.all.asr_ci). The contrast is largest for
non-communicable diseases, where the number of deaths more than doubled
(#cv(G.ncd.deaths_pct), from #G.ncd.deaths90 to #G.ncd.deaths23) and the crude
rate rose #cv(G.ncd.crude_pct), yet the age-standardised rate fell by
#drop(G.ncd.asr_pct). Among individual causes, cardiovascular deaths rose
#cv(C.cvd.deaths_pct) (#C.cvd.deaths90 to #C.cvd.deaths23) and neoplasm deaths
#cv(C.neoplasms.deaths_pct) even as their age-standardised rates fell by
#drop(C.cvd.asr_pct) and #drop(C.neoplasms.asr_pct) respectively; diabetes and
kidney disease deaths nearly tripled (#cv(C.diabetes.deaths_pct)) while the
age-standardised rate fell by #drop(C.diabetes.asr_pct). In every such case the
growth in deaths reflects a larger, older population rather than rising
age-specific risk.

#figure(
  caption: [Absolute deaths, crude (all-ages) death rate, and age-standardised
    rate: percent change in Brazil, 1990–2023, both sexes. Death counts and
    crude rates are GBD point estimates for all ages; age-standardised changes
    (WHO World Standard) are reproduced from @tab:asr (causes) and the main text
    (groups), where 95% uncertainty intervals are given. The first row is the sum
    of the extracted Level-2 categories, which equals GBD's all-cause total.
    Δ = percent change 1990–2023.],
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

== Premature NCD mortality

The unconditional probability of dying between ages 30 and 70 from the four
major NCD groups fell from #P.p90 (95% UI #P.p90_ci) in 1990 to #P.p23 (95% UI
#P.p23_ci) in 2023, a relative reduction of #cv(P.pct) (95% UI #P.ci). This
indicator is, by construction, independent of population ageing, and its
decline is of the same order as the fall in the NCD age-standardised rate.

== Causes with the greatest mortality reductions

@fig:decreased shows the cause categories with the largest age-standardised
declines, together with the three categories that fall only after
standardisation.

*Enteric infections* (#cv(C.enteric.asr_pct)) showed the most pronounced
improvement. Death rates that were very high in early infancy in 1990 (peaking
near 1,500 per 100,000 in the 1–5-month group) collapsed to near-zero across
all paediatric groups by 2023, so the standardised rate fell from
#C.enteric.asr90 to #C.enteric.asr23 per 100,000.

*Maternal and neonatal disorders* (#cv(C.maternal.asr_pct)) showed extreme
concentration of risk in the neonatal period, with the standardised rate
falling from #C.maternal.asr90 to #C.maternal.asr23 per 100,000; maternal
mortality at reproductive ages, visible on the logarithmic scale of
@fig:decreased, also fell. *Nutritional deficiencies*
(#cv(C.nutritional.asr_pct)) and *neglected tropical diseases and malaria*
(#cv(C.ntd.asr_pct)) showed similarly large reductions concentrated in early
childhood.

*Cardiovascular diseases* (#cv(C.cvd.asr_pct)), the largest single contributor
to standardised mortality in both years (ASR #C.cvd.asr90 per 100,000 in 1990),
declined by more than half, with reductions at every age and the steepest
absolute reductions in the older age bands.

*Respiratory infections and tuberculosis* declined more modestly
(#cv(C.resp_tb.asr_pct), 95% UI #C.resp_tb.asr_ci), with reductions in younger
and middle-aged groups partly offset by higher 2023 rates from age 65 upward.
The 2023 rates for this category include COVID-19 deaths, which GBD nests
within it (see below).

The three categories that rose on the unweighted-mean metric but declined once
age-standardised were *unintentional injuries* (unweighted
#cv(C.unintentional.mean_pct); standardised #cv(C.unintentional.asr_pct), 95% UI
#C.unintentional.asr_ci), *diabetes and kidney diseases* (unweighted
#cv(C.diabetes.mean_pct); standardised #cv(C.diabetes.asr_pct), 95% UI
#C.diabetes.asr_ci), and *neoplasms* (unweighted #cv(C.neoplasms.mean_pct);
standardised #cv(C.neoplasms.asr_pct), 95% UI #C.neoplasms.asr_ci). For
unintentional injuries and diabetes and kidney diseases, 2023 age-specific
rates exceeded 1990 rates only from age 60 and age 85 upward, respectively;
for neoplasms they materially exceeded 1990 rates only at 90 years and over,
with marginal excesses at 15–34 years. The unweighted mean over-weights these
small, high-rate elderly bands relative to their population share; once
standardised, the broad-based reductions at younger and middle ages dominate.

#figure(
  image("figures/fig1_decreased.jpg", width: 100%),
  caption: [
    *Brazil: causes with the greatest age-standardised mortality reductions,
    1990–2023.* Age-specific death rate (deaths per 100,000, logarithmic scale)
    by age group, both sexes. Solid blue line, 1990; dashed red line, 2023.
    Green shading marks age groups where the 2023 rate fell; pink shading where
    it rose. Rates below 0.1 per 100,000 are drawn at 0.1. Each annotation gives
    the percent change in the WHO-standardised rate with its Monte Carlo 95%
    uncertainty interval (n = 10,000). The three categories marked ★ rose on
    the unweighted-mean metric but declined after standardisation. Source: GBD
    2023 (IHME).
  ],
) <fig:decreased>

== Causes with rising mortality burden

@fig:increased shows the six categories whose age-standardised point estimate
rose; for one of them (neurological disorders) the interval includes zero.

*Skin and subcutaneous diseases* showed by far the largest relative increase
(#cv(C.skin.asr_pct), 95% UI #C.skin.asr_ci), with the standardised rate rising
from #C.skin.asr90 to #C.skin.asr23 per 100,000. In the GBD hierarchy this
category comprises non-malignant conditions (principally bacterial skin
infections such as cellulitis and pyoderma, decubitus ulcers, and fungal and
viral skin diseases); skin cancers, including melanoma, are counted under
neoplasms @GBD2021CausesOfDeath2024. The increase was concentrated at 75 years
and over, the age pattern expected of pressure ulcers and skin infections in
frail, bed-bound, or institutionalised older people. Because the category is
small and its assignment depends on certification and garbage-code
redistribution practices that may have changed over time, the estimate should
be interpreted with caution.

*Other non-communicable diseases* increased by #cv(C.other_ncd.asr_pct) (95% UI
#C.other_ncd.asr_ci). This residual category is heterogeneous, and the rise
should be read as a signal to disaggregate rather than as a single coherent
trend.

*Substance use disorders* increased by #cv(C.substance.asr_pct) (95% UI
#C.substance.asr_ci). Rates fell at 30–44 years and rose from 45 years upward,
with the largest absolute rises at 55–69 years, an age pattern more consistent
with alcohol-related mortality in older adults than with illicit drug use among
the young; Level-3 disaggregation into alcohol and drug use disorders is needed
to confirm this.

*HIV/AIDS and sexually transmitted infections* (#cv(C.hiv.asr_pct)) and
*musculoskeletal disorders* (#cv(C.musculo.asr_pct)) showed smaller but
precisely estimated increases. *Neurological disorders* rose modestly in the
point estimate (#cv(C.neuro.asr_pct)) but with an interval spanning zero (95% UI
#C.neuro.asr_ci), so the direction of change for this heterogeneous category is
uncertain.

#figure(
  image("figures/fig2_increased.jpg", width: 100%),
  caption: [
    *Brazil: causes with rising age-standardised mortality burden, 1990–2023.*
    Age-specific death rate (deaths per 100,000, logarithmic scale) by age
    group, both sexes. Solid blue line, 1990; dashed red line, 2023. Pink
    shading marks age groups where the 2023 rate exceeded 1990; green shading
    where it fell. Rates below 0.1 per 100,000 are drawn at 0.1. Annotations
    give the percent change in the WHO-standardised rate with its Monte Carlo
    95% uncertainty interval (n = 10,000). Source: GBD 2023 (IHME).
  ],
) <fig:increased>

== Agreement with GBD's age-standardised rates and trajectory, 1990–2023

GBD's own age-standardised percent changes agreed in direction with the
WHO-standard changes for all #R.gbd.n_total categories, including the three
whose direction reverses under standardisation; the largest absolute difference
was #R.gbd.max_abs_diff percentage points (#R.gbd.max_abs_diff_cause), and for
all causes GBD's change was #cv(R.gbd.all_pct) against our #cv(G.all.asr_pct)
(@tab:gbd). The annual series (@fig:trajectory) shows that the all-cause
age-standardised rate fell steadily from #R.gbd.all_asr1990 per 100,000 in 1990
to #R.gbd.all_asr2019 in 2019 (#cv(R.gbd.all_1990_2019_pct)), rose to
#R.gbd.all_asr2021 in 2021 at the height of the COVID-19 pandemic, and had
returned to #R.gbd.all_asr2023 by 2023, #cv(R.gbd.all_2023_vs_2019_pct)
relative to 2019. COVID-19 accounted for #R.covid.deaths2020,
#R.covid.deaths2021, #R.covid.deaths2022, and #R.covid.deaths2023 deaths in
2020–2023, all nested within respiratory infections and tuberculosis; in 2023
it represented #R.covid.share_resp2023 of that category's deaths, and the
category's deaths excluding COVID-19 (#R.covid.resp2023_excl) were
#cv(R.covid.resp2023_excl_vs2019_pct) relative to 2019. The rise in skin and
subcutaneous disease mortality was monotonic across decades (GBD
age-standardised rate #R.gbd.skin_asr.at("1990"), #R.gbd.skin_asr.at("2000"),
#R.gbd.skin_asr.at("2010"), #R.gbd.skin_asr.at("2019"), and
#R.gbd.skin_asr.at("2023") per 100,000 in 1990, 2000, 2010, 2019, and 2023),
so it is not a pandemic-period artefact. Unintentional injury mortality, by
contrast, fell before 2010 (#R.gbd.unint_asr2010 in 2010), was flat to 2019
(#R.gbd.unint_asr2019), and rose slightly to #R.gbd.unint_asr2023 in 2023.

#figure(
  caption: [GBD's own age-standardised death rates (deaths per 100,000, GBD
    2023 world standard population) by cause category in Brazil for selected
    years, with the 1990–2023 percent change under the GBD standard and under
    the WHO World Standard as computed in this study (@tab:asr). Ordering as in
    @tab:asr. COVID-19 is nested within respiratory infections and
    tuberculosis. Source: GBD Results tool, extracted 4 September 2026.],
  kind: table,
)[
  #set text(size: 8.5pt)
  #table(
    columns: (1.9fr, auto, auto, auto, auto, auto, auto, auto),
    align: (left, right, right, right, right, right, right, right),
    stroke: none,
    fill: (col, row) => if row == 0 { rgb("#2c3e50") } else if calc.odd(row) { rgb("#f9f9f9") } else { white },
    inset: (x: 5pt, y: 4pt),

    hcell[Cause / group], hcell[1990], hcell[2000], hcell[2010], hcell[2019],
    hcell[2023], hcell[Δ% GBD std], hcell[Δ% WHO std],

    ..R.table3.map(r => (
      t2-name(r),
      [#r.a1990], [#r.a2000], [#r.a2010], [#r.a2019], [#r.a2023],
      cv(r.gbd_pct),
      cv(r.who_pct),
    )).flatten()
  )
] <tab:gbd>

#figure(
  image("figures/fig3_trajectory.jpg", width: 100%),
  caption: [
    *Brazil: GBD age-standardised death rates by year, 1990–2023 (GBD world
    standard population).* (A) All causes and the three GBD Level-1 groups
    (logarithmic scale). (B) Respiratory infections and tuberculosis, total and
    excluding COVID-19, and COVID-19 alone (linear scale). The dotted line marks
    2019, the last pre-pandemic year; the grey band marks 2020–2022. Source: GBD
    Results tool (IHME).
  ],
) <fig:trajectory>

// ── 4. Discussion ────────────────────────────────────────────────────────────
= Discussion

== Principal findings

Between 1990 and 2023, Brazil's age-standardised mortality burden shifted
markedly: communicable diseases, nutritional deficiencies, and perinatal
conditions declined steeply, while several non-communicable categories rose.
This pattern is consistent with the epidemiological-transition and
double-burden literature @Frenk1991 @Schramm2004 and with previous national
GBD-based assessments @GBD2016Brazil2018 @Souza2018 @Malta2017. Deaths and
crude rates rose while age-standardised rates and premature NCD mortality fell,
and for #S.w_reversed categories the direction of change depended entirely on
whether age structure was accounted for.

== Successes: communicable, perinatal, and nutritional causes

The near-elimination of enteric-infection mortality in childhood
(#cv(C.enteric.asr_pct)) is among Brazil's most notable public-health
achievements, attributable to oral rehydration therapy, sanitation expansion,
rotavirus vaccination (introduced into the national programme in 2006, and
followed by a measurable fall in diarrhoeal deaths and admissions @doCarmo2011),
and improved paediatric care @Victora2011. The decline in
nutritional-deficiency mortality (#cv(C.nutritional.asr_pct)) is consistent
with the effects of food-security and conditional cash-transfer programmes on
child mortality @Rasella2013. The cardiovascular reduction of more than half
(#cv(C.cvd.asr_pct)) aligns with documented declines in smoking prevalence under
strong tobacco-control policy @Levy2012, expanding access to hypertension
treatment through primary care, and growing cardiac-care capacity @Ribeiro2016;
notably, this halving of age-specific risk occurred even as the absolute number
of cardiovascular deaths rose by #cv(C.cvd.deaths_pct) (#C.cvd.deaths90 to
#C.cvd.deaths23), a divergence driven by demographic change.

== Challenges: non-communicable diseases and residual causes

The large rise in skin and subcutaneous disease mortality (#cv(C.skin.asr_pct))
is concentrated in the very old, has been monotonic across every decade since
1990 (@tab:gbd), and, given the composition of the GBD category, plausibly
reflects deaths from pressure ulcers and severe skin infections in frail older
people. However, the magnitude of this increase (+206.8% in the age-standardised
rate and an 855% rise in absolute deaths) strongly points to certification and
coding artifacts alongside genuine geriatric frailty. In earlier decades of
Brazil's Mortality Information System (SIM), terminal events in bed-bound
elderly individuals were frequently assigned to non-specific garbage codes such
as septicemia or cardiorespiratory arrest without documenting the cutaneous
origin. Over the last two decades, nationwide death-investigation programs by
the Ministry of Health and GBD's redistribution algorithms have progressively
reassigned these secondary deaths to their underlying dermatological causes,
chiefly decubitus ulcers. While the clinical vulnerability of the expanding
oldest-old population remains an authentic priority for long-term and home-care
services, the finding should be interpreted primarily as an evolving surveillance
and redistribution artifact rather than a pure biological tripling of disease
risk. It does not indicate skin cancer, which GBD classifies under neoplasms.

*HIV/AIDS and sexually transmitted infections* increased in age-standardised
mortality by #cv(C.hiv.asr_pct) (95% UI #C.hiv.asr_ci), a result that requires
careful epidemiological interpretation within Brazil's public-health history.
This positive relative change does not signify an uncontrolled epidemic. In
1990, the HIV epidemic in Brazil was in its earlier expansion phase and marked
by substantial under-notification. Brazil subsequently emerged as a global
pioneer in HIV response through Federal Law 9,313/1996, which established free,
universal access to antiretroviral therapy (ART) through the SUS @Greco2007
@Victora2011. AIDS mortality in Brazil peaked in 1995–1996 and collapsed by
roughly half by the late 1990s as ART coverage expanded. By 2023, the mortality
profile reflects a mature, chronic epidemic where people living with HIV survive
to older ages, while persistent challenges remain in late clinical presentation
among historically marginalized groups (including men who have sex with men,
transgender persons, and young Black Brazilians) and subnational disparities
affecting the North and Northeast regions @Souza2018. The comparison between
1990 and 2023 completely misses the 1995–1996 peak and the hundreds of thousands
of lives saved by universal ART.

*Self-harm and interpersonal violence* exhibited an aggregate age-standardised
change of #cv(C.self_harm.asr_pct) with an uncertainty interval spanning zero
(95% UI #C.self_harm.asr_ci), appearing stable at Level 2. However, this
stability conceals two diametrically opposed secular trends. Interpersonal
violence (homicides) accounts for more than 80% of deaths in this category and
represents an ongoing humanitarian tragedy in Brazil, concentrated
disproportionately among young Black and mixed-race men aged 15–29 in urban
peripheries @Reichenheim2011. National homicide rates experienced dramatic
fluctuations over the 33-year period: a temporary containment following the
2003 Disarmament Statute (Estatuto do Desarmamento), a sharp escalation peaking
around 2016–2017 driven by violent disputes between organized-crime factions in
the North and Northeast, and a subsequent decline. Conversely, self-harm
(suicide) has exhibited a sustained secular increase across Brazil over the last
two decades, with growing rates among adolescents, young adults, and indigenous
populations. Because homicides and suicides moved in opposite directions, the
Level-2 summary remains essentially flat, illustrating the necessity of Level-3
disaggregation for targeted policy intervention.

*Substance use disorders* increased by #cv(C.substance.asr_pct) (95% UI
#C.substance.asr_ci), with risk concentrated at 45–69 years. This age pattern is
characteristic of chronic alcohol-induced organ pathology rather than youth
illicit drug overdoses, highlighting persistent underfunding of psychosocial and
addiction care networks (Rede de Atenção Psicossocial, RAPS) within the SUS.

== Why age standardisation changes the conclusions

#S.W_reversed categories illustrate why a population-weighted summary is
essential. Unintentional injuries rose by #cv(C.unintentional.mean_pct) on the
unweighted-mean metric but fell by #drop(C.unintentional.asr_pct) once
standardised; diabetes and kidney diseases moved from #cv(C.diabetes.mean_pct)
to #cv(C.diabetes.asr_pct); and neoplasms from a flat #cv(C.neoplasms.mean_pct)
to #cv(C.neoplasms.asr_pct). In each case the 2023 age-specific rate exceeded
the 1990 rate only at the oldest ages. The unweighted mean gives each of the 25
age bands equal weight, so it over-represents these small but high-rate elderly
bands; the WHO standard assigns them weights that reflect a population age
distribution, allowing the substantial reductions at younger and middle ages to
dominate. Because Brazil's elderly population grew rapidly over the period
@UN2024, crude or count-based measures will register an apparent increase for
these causes even though within-age-group risk has fallen, a classic
confounding-by-age effect. The unweighted mean serves as a cautionary
methodological demonstration of how naive averaging across spreadsheet rows can
invert the apparent direction of a trend, whereas the practical contrast faced
by health systems is between crude rates and counts (which define absolute
service demand) and age-standardised rates (which reflect underlying
epidemiological risk). For unintentional injuries, the standardised decline
occurred largely before 2010 and has since stalled (@tab:gbd); it is consistent
with reduced road-traffic mortality among working-age adults following the
2008 "Lei Seca" drink-driving legislation @Andreuccetti2011, even as
fall-related deaths rise among the elderly. The practical implication is
that mortality changes over periods of demographic change must be interpreted
using age-standardised or otherwise age-adjusted measures, and that summaries
computed casually from age-disaggregated extracts can invert the apparent
direction of a trend.

The same phenomenon has been documented for Brazil at the aggregate level.
Analysing GBD 2015 estimates, Malta and colleagues reported that the absolute
number of NCD deaths rose by about 90% between 1990 and 2015 while the
age-standardised NCD death rate fell by 25.3%, attributing the divergence to
population growth and changes in age structure @Malta2017. Our data reproduce
and extend that pattern to 2023 (@tab:burden) and show where the same
demographic confounding flips the apparent direction of individual causes. The
two analyses agree closely on direction and approximate magnitude for the
largest categories despite different GBD cycles, endpoint years, and
standard populations: Malta and colleagues reported a cardiovascular decline of
40.4% (1990–2015) against our #cv(C.cvd.asr_pct) (1990–2023), and a broadly
stable neoplasm rate (their −6.5%) against our #cv(C.neoplasms.asr_pct). More
directly, GBD's own age-standardised changes for 1990–2023 agree in direction
with ours for every category and differ by at most #R.gbd.max_abs_diff
percentage points (@tab:gbd), confirming that the WHO-standard results are not
an artefact of the standard chosen. GBD 2023 itself frames its headline global finding in the same terms, contrasting a
6.1% rise in absolute disability-adjusted life-years between 2010 and 2023 with
a 12.6% fall in the age-standardised rate @GBD2023Collaborators2025; the
Brazilian results are a national instance of that pattern.

== The COVID-19 pandemic and the 2023 endpoint

The endpoint year follows the most severe mortality shock in Brazil's recent
history. Brazil recorded one of the world's largest COVID-19 death tolls, with
excess mortality concentrated in 2020–2021 @Castro2021 @Msemburi2023. In the
GBD 2023 all-cause series for Brazil, deaths rose from #R.allcause.d2019 in 2019
to #R.allcause.d2020 in 2020 and #R.allcause.d2021 in 2021, then fell to
#R.allcause.d2022 in 2022 and #R.allcause.d2023 in 2023, a count still
#R.allcause.excess2023 (#R.allcause.excess2023_pct) above the 2019 level. The
age-standardised series (@fig:trajectory) shows that this residual excess in
counts is a demographic effect: the all-cause age-standardised rate in 2023
(#R.gbd.all_asr2023 per 100,000) was #cv(R.gbd.all_2023_vs_2019_pct) relative
to 2019, so age-specific risk had returned to, and slightly below, its
pre-pandemic level. GBD assigned #R.covid.deaths_total deaths to COVID-19 in
Brazil over 2020–2023, nested within respiratory infections and tuberculosis.
Three consequences follow for the present analysis. First, the 2023 age-specific
rates for that category include #R.covid.deaths2023 COVID-19 deaths
(#R.covid.share_resp2023 of the category); even excluding them, the category's
deaths in 2023 were #cv(R.covid.resp2023_excl_vs2019_pct) relative to 2019, so
its comparatively modest standardised decline over 1990–2023
(#cv(C.resp_tb.asr_pct)) reflects both residual COVID-19 mortality and a
post-pandemic elevation of other respiratory infection deaths at old ages, and
should not be read as the long-term trend of lower respiratory infections and
tuberculosis alone. Second, the pandemic may have altered 2023 rates for other
causes indirectly, through disrupted care for chronic conditions, mortality
displacement among the frail elderly (which would lower 2023 rates for causes
such as cardiovascular and neurological disease), and changes in certification
practice; the flattening of the cardiovascular and neoplasm series after 2019
(@tab:gbd) is consistent with such effects and warrants monitoring. Third, for
the categories with the largest changes, the annual series confirms that the
1990–2023 comparison captures long-term movements rather than pandemic-period
disturbance: the enteric, nutritional, maternal and neonatal, and
cardiovascular declines and the skin-disease increase were all well established
by 2019.

== Progress against policy targets and historical trajectory

The 33-year trajectory from 1990 to 2023 does not represent a steady, uniform
progression, but rather four distinct socioeconomic and sanitary phases.
Between 1990 and 2002, the formative period of the SUS established municipal
decentralization and launched the Family Health Strategy (Estratégia Saúde da
Família, ESF). The second phase (2003–2014) saw rapid poverty reduction, the
expansion of conditional cash transfers (Bolsa Família), universal free
essential medications through Farmácia Popular (2004), emergency medical care
(SAMU 192, 2003), and the First National NCD Plan (2011–2022) @Brasil2021PlanoDANT
@Souza2018. These coordinated investments accelerated the historic decline in
infant mortality, undernutrition, and cardiovascular disease.

However, the third phase (2015–2019) marked an inflection point: a severe
economic recession compounded by strict fiscal austerity, institutionalised by
Constitutional Amendment 95 (EC 95/2016, the federal spending cap), which froze
real social and healthcare spending. Previous studies demonstrated that this
austerity shock halted or decelerated progress against chronic diseases, stalled
cardiovascular mortality declines, and contributed to rising infant mortality in
vulnerable municipalities @Massuda2018 @Malta2020. The fourth phase (2020–2022)
brought the catastrophic shock of COVID-19, which overwhelmed hospitals,
disrupted routine primary care, deferred cancer screenings, and caused over
700,000 deaths @Castro2021. The 2023 endpoint analysed here reflects a resilient
return to pre-pandemic baseline risk (age-standardised all-cause rate
#cv(R.gbd.all_2023_vs_2019_pct) relative to 2019), but one that inherits
substantial backlogs in chronic disease surveillance and care.

The WHO Global Action Plan and SDG target 3.4 are framed in terms of premature
NCD mortality, the probability of dying between ages 30 and 70 from
cardiovascular disease, cancer, diabetes, or chronic respiratory disease, with
baselines in 2010 and 2015 respectively @WHO2013 @UNSDG341. Over the longer
1990–2023 window analysed here, that probability fell from #P.p90 to #P.p23
(#drop(P.pct)), and the age-standardised rate fell for all three Level-1 groups,
including a #drop(G.ncd.asr_pct) reduction for NCDs as a whole. Whether the pace
since the 2015 baseline is sufficient to reach a one-third reduction by 2030
cannot be judged from two endpoints alone; national projections based on GBD
trends suggest that Brazil is unlikely to meet the SDG target without renewed
acceleration @Malta2020, which Brazil's current national plan for 2021–2030 has
re-adopted as its central objective @Brasil2021PlanoDANT.

Progress is also deeply uneven across conditions and regions. The steep fall in
nutritional deficiencies (#drop(C.nutritional.asr_pct)) coexists with an alarming
nutritional transition: adult overweight and obesity have surged across Brazil,
driven by consumption of ultra-processed foods, creating a metabolic burden that
threatens future cardiovascular and oncological gains @Schmidt2011. Furthermore,
mortality declines have been socially patterned, with faster gains in wealthier
municipalities widening relative inequalities @Malta2017 @GBD2016Brazil2018.
The national estimates analysed here cannot capture these subnational gradients,
underscoring the importance of regional and socioeconomic disaggregation.

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
contextual rather than causal. Second, the primary WHO-standard
analysis compares two endpoint years; the annual GBD series (@tab:gbd,
@fig:trajectory) is used to check that the changes are long-term rather than
pandemic-period disturbances, but the WHO-standard and Monte Carlo analysis was
not repeated for intermediate years. Third, COVID-19 is nested within
respiratory infections and tuberculosis in the age-specific extract, so the
2023 age-specific rates and the WHO-standard change for that category include
COVID-19 deaths; the aggregate series allows the COVID-19 contribution to be
quantified (see above) but not removed from the age-specific analysis. Fourth, the estimates are GBD modelled
outputs rather than directly observed deaths. The garbage-code redistribution
and under-registration corrections that GBD applies improve comparability but
rest on modelling assumptions that can bias estimates, particularly for
ill-defined, small, or frequently miscertified causes @Malta2017; this is most
relevant to the categories where our estimates are least certain (skin and
subcutaneous diseases, the residual "other NCD" group, and neurological
disorders, whose standardised interval spans zero), and the large relative
increases in these categories should be read with corresponding caution and as
a prompt to disaggregate rather than as settled findings. Fifth, the Monte Carlo
procedure treats the 25 age-specific rates, and the 1990 and 2023 estimates, as
independent because the GBD posterior correlation structure is not available in
the public extract; positive correlation between years would make the true
intervals for the change narrower than those reported, whereas correlation
across age groups would widen them, and neither affects the point estimates.
Sixth, the WHO World Standard is one of several possible standards, and
absolute standardised rates differ under another standard, as the comparison
with the GBD standard shows (@tab:gbd); the direction and approximate magnitude
of change, however, were robust to the choice of standard. Finally, the analysis
was restricted to both sexes combined; sex-disaggregated and subnational
analyses would add resolution.

== Conclusions

Brazil's mortality profile has undergone a classic, though incomplete,
epidemiological transition. Reductions in communicable, nutritional, and
perinatal mortality represent major gains consistent with multi-sector social
investment, and premature NCD mortality has fallen by about a third since 1990.
At the same time, the rising age-standardised burden of several
non-communicable categories and the persistence of injury-related mortality
underscore the need for sustained NCD prevention, mental health and addiction
services, and care for a growing older population within the SUS.
Methodologically, the reversal of several trends under age standardisation is
a reminder that age structure must be accounted for before mortality changes
are interpreted.

// ── Declarations ─────────────────────────────────────────────────────────────
#heading(numbering: none)[Declarations]

*Preprint statement.* This manuscript is a preprint deposited on SciELO
Preprints. It has not been peer reviewed and has not been submitted to a
journal at the time of deposit.

*Data and code availability.* All data analysed are publicly available from the
IHME GBD Compare / GBD Results tool (#link("https://vizhub.healthdata.org/gbd-compare/")).
The extracted CSV files, all analysis and figure-generation code, the STROBE
checklist, the bibliography, and this manuscript source are openly available in
the GitHub repository at #link("https://github.com/esalves/brazil-gbd-manuscript")
and may be re-run to reproduce every value and figure reported here.

*Ethics approval and informed consent.* Not required. This study relies exclusively
on publicly accessible, aggregated, and de-identified secondary data from the Global
Burden of Disease Study 2023, exempt from institutional research ethics committee
review and individual informed consent in accordance with Brazilian Resolution
CNS/CONEP 510/2016 (Article 1, sole paragraph) and international ethical standards
for observational research.

*Competing interests.* The author declares no competing interests.

*Funding.* No external funding was received for this study.

*Use of artificial intelligence.* The author used the generative AI tool Claude
(Anthropic; Claude Opus 4.8 and Claude Fable 5.1) for assistance in implementing
the analytical Python scripts, generating the figures, performing an internal
pre-submission review, and reviewing typographical and grammatical style. The
author conceived the study design, interpreted all epidemiological results,
verified all underlying data against primary sources, validated the analytical
pipeline, and takes full responsibility for the content, integrity, and
scientific conclusions of the manuscript.

*Author contributions (CRediT).* Eduardo S. A. Santos (E.S.A.S.): Conceptualization,
Methodology, Software, Formal analysis, Data curation, Visualization, Writing –
original draft, Writing – review & editing.

*Data provenance.* The estimates analysed here are from the GBD 2023 release,
published in October 2025 @GBD2023Collaborators2025, and were extracted via the
IHME GBD Compare / GBD Results tool on 4 June 2026 (age-specific rates), 9 June
2026 (all-ages counts and crude rates), and 4 September 2026 (annual series,
including GBD age-standardised rates and COVID-19).

// ── References ───────────────────────────────────────────────────────────────
#set text(size: 10pt)
#bibliography("references/references.bib", style: "vancouver", title: "References")
