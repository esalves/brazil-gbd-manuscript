# Brazil Mortality Transition 1990–2023: A GBD Analysis

**Shifting Mortality Burden in Brazil: Age-Specific Trends Across Cause Categories from the Global Burden of Disease Study 2023**

---

## Overview

This repository contains data, analysis scripts, and the manuscript source for a cross-sectional ecological study examining changes in age-specific mortality rates across 22 cause-of-death categories in Brazil between 1990 and 2023, using data from the Global Burden of Disease (GBD) Study 2023.

## Repository Structure

```
brazil-gbd-manuscript/
├── README.md
├── manuscript.typ          # Typst manuscript source (main paper)
├── data/
│   ├── GBD_Compare_Data1990.csv    # Age-specific death rates, Brazil, 1990
│   └── GBD_Compare_Data2023.csv    # Age-specific death rates, Brazil, 2023
├── figures/
│   ├── fig1_decreased.png          # Figure 1: Causes with greatest mortality reductions
│   └── fig2_increased.png          # Figure 2: Causes with rising mortality burden
└── scripts/
    └── analysis.py                 # Data processing and summary statistics
```

## Key Findings

| Direction | Cause | % Change (1990–2023) |
|-----------|-------|----------------------|
| ↓ Decreased | Enteric Infections | −90.1% |
| ↓ Decreased | Maternal & Neonatal Disorders | −60.4% |
| ↓ Decreased | Nutritional Deficiencies | −73.0% |
| ↓ Decreased | Cardiovascular Diseases | −51.4% |
| ↑ Increased | Skin & Subcutaneous Diseases | +232.7% |
| ↑ Increased | Substance Use Disorders | +32.6% |
| ↑ Increased | Unintentional Injuries | +26.2% |
| ↑ Increased | Diabetes & Kidney Diseases | +16.3% |

## Data Source

> Institute for Health Metrics and Evaluation (IHME). GBD Compare Data Visualization. Global Burden of Disease (GBD) Study 2023. Seattle, WA: IHME, University of Washington, 2025. Available from https://vizhub.healthdata.org/gbd-compare/. (Accessed 6/4/2026).

## Requirements

### Manuscript Compilation
- [Typst](https://typst.app/) ≥ 0.11

```bash
typst compile manuscript.typ manuscript.pdf
```

### Analysis Scripts
- Python ≥ 3.9
- pandas, matplotlib, numpy

```bash
pip install pandas matplotlib numpy
python scripts/analysis.py
```

## License

Data are subject to IHME terms and conditions: http://www.healthdata.org/about/terms-and-conditions

Code and manuscript text are licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Citation

If using this analysis, please cite the original GBD 2023 data source (above) and this repository.
