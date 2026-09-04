"""
gbd_series.py
-------------
Loader for the GBD Results tool extract
data/IHME-GBD_2023_DATA-64ec5dbd-1.csv, which reports, for Brazil, both
sexes, every year 1990-2023:

  * the 22 Level-2 cause categories, COVID-19 (Level 3) and "All causes";
  * Deaths and DALYs; Number, Percent and Rate;
  * "All ages" and "Age-standardized" (GBD 2023 world standard population).

This extract is used for three purposes in the manuscript:
  1. to validate that the Level-2 extract is exhaustive (the Level-2 sum
     reproduces GBD's all-cause totals) and to locate COVID-19 in the
     hierarchy (it is nested under respiratory infections and tuberculosis);
  2. to compare the WHO-standard percent changes computed in
     analysis_standardised.py with GBD's own age-standardised changes;
  3. to describe the annual trajectory of age-standardised mortality,
     including the pandemic years, in Table 3 and Figure 3.
"""

from __future__ import annotations

import csv
import os

DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")
SERIES_FILE = os.path.join(DATA_DIR, "IHME-GBD_2023_DATA-64ec5dbd-1.csv")

YEARS = [str(y) for y in range(1990, 2024)]


def load_series(path: str = SERIES_FILE) -> dict:
    """Return {(cause, year, age_name, metric): (val, lower, upper)} for Deaths."""
    out = {}
    with open(path, newline="", encoding="utf-8") as fh:
        for r in csv.DictReader(fh):
            if r["measure_name"] != "Deaths":
                continue
            key = (r["cause_name"], r["year"], r["age_name"], r["metric_name"])
            out[key] = (float(r["val"]), float(r["lower"]), float(r["upper"]))
    return out


def level2_causes(series: dict) -> list:
    """Level-2 causes with death estimates (excludes 'All causes' and COVID-19)."""
    return sorted({c for (c, _y, _a, _m) in series} - {"All causes", "COVID-19"})


def asr(series: dict, cause: str, year: str) -> float:
    """GBD age-standardised death rate per 100,000 (GBD world standard)."""
    return series[(cause, year, "Age-standardized", "Rate")][0]


def deaths(series: dict, cause: str, year: str) -> float:
    return series[(cause, year, "All ages", "Number")][0]


def crude(series: dict, cause: str, year: str) -> float:
    return series[(cause, year, "All ages", "Rate")][0]
