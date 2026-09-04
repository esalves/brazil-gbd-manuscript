# Brazil Mortality Transition 1990–2023: A GBD Analysis

**Shifting Mortality Burden in Brazil, 1990–2023: Age-Standardised Changes Across Cause Categories from the Global Burden of Disease Study 2023**

Preprint prepared for deposit on [SciELO Preprints](https://preprints.scielo.org/).

---

## Overview

This repository contains the data, analysis code, and manuscript source for a
descriptive cross-sectional study of changes in cause-specific mortality in
Brazil between 1990 and 2023, using Global Burden of Disease (GBD) Study 2023
estimates from IHME.

The **primary metric is the age-standardised death rate (ASR)**, computed by
direct standardisation of GBD age-specific rates to the **WHO World Standard
Population**. Because Brazil's population aged substantially over the period,
ASRs (which hold age structure constant) are required to distinguish genuine
changes in age-specific risk from artefacts of demographic change. The
analysis also reports (i) the unconditional probability of death between ages
30 and 70 from the four major NCD groups (the SDG 3.4.1-style premature NCD
mortality indicator) and (ii), as a methodological comparison only, the
*unweighted mean of the 25 age-specific rates* — a summary an analyst obtains
by averaging the rows of an age-disaggregated extract, which is **not**
age-standardised and is **not** a metric published by GBD.

**Validation and trajectory.** A third extract (GBD Results tool: 22 Level-2
causes + COVID-19 + all causes, every year 1990–2023, all-ages and GBD
age-standardised) shows that (i) the Level-2 categories sum exactly to GBD's
all-cause totals in every year, so the aggregates are true all-cause figures;
(ii) COVID-19 is nested within *respiratory infections and tuberculosis*
(10,828 deaths in 2023; 794,693 over 2020–2023); (iii) GBD's own
age-standardised 1990–2023 changes agree in direction with the WHO-standard
changes for all 21 categories, differing by at most 3.1 percentage points;
and (iv) the all-cause age-standardised rate peaked in 2021 and by 2023 was
1.2% below its 2019 value.

Every number in the manuscript — every table cell and in-text figure — is
produced by the code in `scripts/` from the data in `data/` and read into the
Typst source at compile time from `build/results.json`. Nothing is typed by
hand, and there are no manual overrides. References are rendered by Typst from
`references/references.bib` (Vancouver style, numbered by first appearance);
the manuscript cites BibTeX keys with `@Key`.

## Repository structure

```
brazil-gbd-manuscript/
├── README.md
├── manuscript.typ                 # Typst manuscript source (main paper)
├── manuscript.pdf                 # Compiled manuscript
├── STROBE_checklist.md            # STROBE reporting checklist
├── data/
│   ├── GBD_Compare_Data1990.csv         # Age-specific death rates + 95% UIs, Brazil, 1990
│   ├── GBD_Compare_Data2023.csv         # Age-specific death rates + 95% UIs, Brazil, 2023
│   ├── IHME-GBD_2023_DATA-94d42f74-1.csv# All-ages death counts, crude rates & DALYs, 1990 & 2023
│   └── IHME-GBD_2023_DATA-64ec5dbd-1.csv# Annual series 1990–2023: 22 Level-2 causes + COVID-19 + all causes,
│                                        #   deaths & DALYs, all-ages and GBD age-standardised (Table 3, Fig 3)
├── figures/
│   ├── fig1_decreased.jpg         # Figure 1: greatest age-standardised reductions
│   ├── fig2_increased.jpg         # Figure 2: rising age-standardised burden
│   └── fig3_trajectory.jpg        # Figure 3: GBD age-standardised rates by year, 1990–2023
├── references/
│   └── references.bib             # Bibliography (single source; rendered by Typst; Zotero-ready)
├── build/
│   └── results.json              # Generated: all values the manuscript reads at compile time
└── scripts/
    ├── analysis.py                # Unweighted-mean comparison metric (naive, not age-standardised)
    ├── analysis_standardised.py   # PRIMARY: WHO age-standardised rates, premature NCD mortality, Monte Carlo UIs
    ├── analysis_counts.py         # Absolute deaths & crude rates vs ASR (Table 2)
    ├── gbd_series.py              # Loader for the annual GBD series (validation, COVID-19, trajectory)
    ├── build_results.py           # Writes build/results.json (single source for the manuscript)
    └── figures.py                 # Figure generation (imports analysis_standardised)
```

## Key findings (age-standardised, WHO World Standard)

Of 21 cause categories, 13 declined and five rose in age-standardised mortality
with 95% uncertainty intervals excluding zero; three (mental disorders,
self-harm & interpersonal violence, neurological disorders) showed no
detectable change.

| Direction | Cause | Δ% ASR (95% UI) |
|-----------|-------|------------------|
| ↓ Decreased | Enteric infections | −90.9% (−91.4, −90.4) |
| ↓ Decreased | Nutritional deficiencies | −82.1% (−83.3, −80.8) |
| ↓ Decreased | Neglected tropical diseases & malaria | −75.1% (−76.8, −71.4) |
| ↓ Decreased | Maternal & neonatal disorders | −60.8% (−63.1, −58.4) |
| ↓ Decreased | Cardiovascular diseases | −54.8% (−56.4, −53.1) |
| ↑ Increased | Skin & subcutaneous diseases | +206.8% (+191.9, +221.8) |
| ↑ Increased | Other non-communicable diseases | +65.0% (+58.2, +72.4) |
| ↑ Increased | Substance use disorders | +16.1% (+11.9, +20.5) |

**Direction reversed by standardisation** (rose on the unweighted-mean metric
but fell once age-standardised): unintentional injuries (+26.2% → −19.0%),
diabetes & kidney diseases (+16.3% → −10.0%), and neoplasms (+0.1% → −10.4%).

**Absolute burden vs risk.** Across all causes, deaths rose +70% (863,234 → 1,470,158) and the crude rate +19.9%, while the
age-standardised rate fell −34.6%. NCD deaths more than doubled (+112%) even as
the NCD age-standardised rate fell −32.1% — the demographic (growth + ageing)
effect that motivates the analysis.

**Premature NCD mortality.** The probability of dying between ages 30 and 70
from the four major NCD groups fell from 23.3% (1990) to 15.3% (2023), −34.4%
(95% UI −35.5% to −33.3%).

## Data source

> Institute for Health Metrics and Evaluation (IHME). GBD Compare / GBD Results tool. Global Burden of Disease (GBD) Study 2023. Seattle, WA: IHME, University of Washington, 2025. Available from https://vizhub.healthdata.org/gbd-compare/ and https://vizhub.healthdata.org/gbd-results/. (Accessed 4 June, 9 June, and 4 September 2026.)

Age-standardisation standard:

> Ahmad OB, Boschi-Pinto C, Lopez AD, Murray CJL, Lozano R, Inoue M. Age standardization of rates: a new WHO standard. GPE Discussion Paper No. 31. Geneva: WHO; 2001.

## Reproducing the analysis

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# Unweighted-mean comparison metric (standard library only)
python scripts/analysis.py

# Primary age-standardised analysis with Monte Carlo 95% UIs (+ premature NCD mortality)
python scripts/analysis_standardised.py
#   add --json results.json for machine-readable output

# Absolute deaths and crude rates vs age-standardised rates (Table 2)
python scripts/analysis_counts.py

# Regenerate both figures from the same code path
python scripts/figures.py
```

### Building the manuscript (reproducible pipeline)

The Typst source reads all values from `build/results.json`, so regenerate it
(and the figures) before compiling:

```bash
python scripts/build_results.py     # writes build/results.json
python scripts/figures.py           # writes figures/*.jpg
typst compile manuscript.typ manuscript.pdf
```

The Monte Carlo procedure is seeded deterministically per cause, so reported
intervals are reproduced exactly on every run, independent of execution order.
Compiling the manuscript requires [Typst](https://typst.app/) ≥ 0.12 (built-in Vancouver bibliography style).

## License

Data are subject to IHME terms and conditions: http://www.healthdata.org/about/terms-and-conditions

Code and manuscript text are licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Citation

If you use this analysis, please cite the GBD 2023 data source and the WHO
standard (above) and this repository.
