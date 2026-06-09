# Brazil Mortality Transition 1990–2023: A GBD Analysis

**Shifting Mortality Burden in Brazil, 1990–2023: Age-Standardised Trends Across Cause Categories from the Global Burden of Disease Study 2023**

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
changes in age-specific risk from artefacts of demographic change. For
comparison the analysis also reports the *unweighted mean of the 25
age-specific rates* — the summary statistic shown by the GBD Compare tool —
which is **not** age-standardised.

Every number in the manuscript — every table cell and in-text figure — is
produced by the code in `scripts/` from the data in `data/` and read into the
Typst source at compile time from `build/results.json`. Nothing is typed by
hand, and there are no manual overrides.

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
│   └── IHME-GBD_2023_DATA-94d42f74-1.csv# All-ages death counts, crude rates & DALYs, 1990 & 2023
├── figures/
│   ├── fig1_decreased.jpg         # Figure 1: greatest age-standardised reductions
│   └── fig2_increased.jpg         # Figure 2: rising age-standardised burden
├── build/
│   └── results.json              # Generated: all values the manuscript reads at compile time
└── scripts/
    ├── analysis.py                # Unweighted-mean metric (GBD Compare display metric)
    ├── analysis_standardised.py   # PRIMARY: WHO age-standardised rates + Monte Carlo CIs
    ├── analysis_counts.py         # Absolute deaths & crude rates vs ASR (Table 2)
    ├── build_results.py           # Writes build/results.json (single source for the manuscript)
    └── figures.py                 # Figure generation (imports analysis_standardised)
```

## Key findings (age-standardised, WHO World Standard)

Of 21 cause categories, 15 declined and six rose in age-standardised mortality.

| Direction | Cause | Δ% ASR (95% CI) |
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

**Absolute burden vs risk.** Total deaths rose +70% (863,234 → 1,470,158) and
the crude rate +19.9%, while the all-cause age-standardised rate fell −34.6%.
NCD deaths more than doubled (+112%) even as the NCD age-standardised rate fell
−32.1% — the demographic (growth + ageing) effect that motivates the analysis.

## Data source

> Institute for Health Metrics and Evaluation (IHME). GBD Compare / GBD Results tool. Global Burden of Disease (GBD) Study 2023. Seattle, WA: IHME, University of Washington, 2025. Available from https://vizhub.healthdata.org/gbd-compare/ and https://vizhub.healthdata.org/gbd-results/. (Accessed 4 June 2026.)

Age-standardisation standard:

> Ahmad OB, Boschi-Pinto C, Lopez AD, Murray CJL, Lozano R, Inoue M. Age standardization of rates: a new WHO standard. GPE Discussion Paper No. 31. Geneva: WHO; 2001.

## Reproducing the analysis

```bash
python -m venv .venv && source .venv/bin/activate
pip install numpy matplotlib

# Unweighted-mean comparison metric (standard library only)
python scripts/analysis.py

# Primary age-standardised analysis with Monte Carlo 95% CIs
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
Compiling the manuscript requires [Typst](https://typst.app/) ≥ 0.11.

## License

Data are subject to IHME terms and conditions: http://www.healthdata.org/about/terms-and-conditions

Code and manuscript text are licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Citation

If you use this analysis, please cite the GBD 2023 data source and the WHO
standard (above) and this repository.
