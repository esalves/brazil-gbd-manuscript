"""
analysis_counts.py
------------------
Absolute burden (death counts) and crude all-ages death rates for:
"Shifting Mortality Burden in Brazil, 1990-2023"

This script loads the GBD 2023 all-ages extract
(data/IHME-GBD_2023_DATA-94d42f74-1.csv), which reports, for Brazil, both
sexes, all ages, 1990 and 2023:

  * Deaths -- Number   (absolute count of deaths)
  * Deaths -- Rate     (crude death rate per 100,000, using Brazil's actual
                        age structure in each year)

It computes the percent change 1990->2023 in (a) the number of deaths and
(b) the crude rate, for each cause, for the three GBD Level-1 super-groups,
and for all causes combined. For context it also prints the age-standardised
percent change from analysis_standardised.py (WHO World Standard).

The contrast between the three measures is the central message of the paper:
absolute deaths and crude rates can rise -- driven by population growth and
ageing -- even where the age-standardised rate (the measure of underlying
risk) falls.

Usage
-----
    python scripts/analysis_counts.py
"""

from __future__ import annotations

import csv
import os

# Reuse the age-standardised results (single source of truth for ASR).
from analysis_standardised import (
    DATA_DIR,
    LEVEL1_GROUPS,
    compute_all,
    group_change,
    load_data as load_age_specific,
)

COUNTS_FILE = os.path.join(DATA_DIR, "IHME-GBD_2023_DATA-94d42f74-1.csv")


def load_counts(path: str = COUNTS_FILE) -> dict:
    """Return {(cause, year, metric): value} for Deaths Number and Rate."""
    out = {}
    with open(path, newline="", encoding="utf-8") as fh:
        for r in csv.DictReader(fh):
            if r["measure_name"] != "Deaths":
                continue
            if r["metric_name"] not in ("Number", "Rate"):
                continue
            out[(r["cause_name"], r["year"], r["metric_name"])] = float(r["val"])
    return out


def pct(old: float, new: float) -> float:
    return (new - old) / old * 100.0 if old else float("nan")


def cause_rows(counts: dict) -> list:
    causes = sorted({c for (c, _y, _m) in counts})
    rows = []
    for c in causes:
        n90 = counts.get((c, "1990", "Number"))
        n23 = counts.get((c, "2023", "Number"))
        r90 = counts.get((c, "1990", "Rate"))
        r23 = counts.get((c, "2023", "Rate"))
        if n90 is None or n23 is None:
            continue
        rows.append({
            "cause": c,
            "deaths_1990": n90, "deaths_2023": n23, "deaths_pct": pct(n90, n23),
            "crude_1990": r90, "crude_2023": r23, "crude_pct": pct(r90, r23),
        })
    return rows


def group_rows(counts: dict) -> list:
    rows = []
    everything = [c for cs in LEVEL1_GROUPS.values() for c in cs]
    groups = list(LEVEL1_GROUPS.items()) + [("All causes", everything)]
    for name, causes in groups:
        n90 = sum(counts[(c, "1990", "Number")] for c in causes)
        n23 = sum(counts[(c, "2023", "Number")] for c in causes)
        r90 = sum(counts[(c, "1990", "Rate")] for c in causes)
        r23 = sum(counts[(c, "2023", "Rate")] for c in causes)
        rows.append({
            "group": name,
            "deaths_1990": n90, "deaths_2023": n23, "deaths_pct": pct(n90, n23),
            "crude_1990": r90, "crude_2023": r23, "crude_pct": pct(r90, r23),
        })
    return rows


def main() -> None:
    counts = load_counts()
    d90 = load_age_specific(os.path.join(DATA_DIR, "GBD_Compare_Data1990.csv"))
    d23 = load_age_specific(os.path.join(DATA_DIR, "GBD_Compare_Data2023.csv"))
    asr = {r["cause"]: r["std_pct"] for r in compute_all(d90, d23)}

    print("Absolute deaths, crude rate, and age-standardised rate "
          "(% change 1990->2023)\n")
    hdr = (f"{'Cause':<46}{'Deaths 1990':>12}{'Deaths 2023':>12}"
           f"{'ΔN%':>7}{'Δcrude%':>9}{'ΔASR%':>8}")
    print(hdr)
    print("-" * len(hdr))
    for row in cause_rows(counts):
        a = asr.get(row["cause"])
        a_s = f"{a:+.1f}" if a is not None else "  n/a"
        print(f"{row['cause']:<46}{row['deaths_1990']:>12,.0f}"
              f"{row['deaths_2023']:>12,.0f}{row['deaths_pct']:>+7.0f}"
              f"{row['crude_pct']:>+9.1f}{a_s:>8}")

    print("\nGBD Level-1 groups and all causes")
    print("-" * len(hdr))
    # ASR for groups + all causes
    grp_asr = {}
    for name, causes in LEVEL1_GROUPS.items():
        grp_asr[name] = group_change(causes, d90, d23)["std_pct"]
    everything = [c for cs in LEVEL1_GROUPS.values() for c in cs]
    grp_asr["All causes"] = group_change(everything, d90, d23)["std_pct"]
    for row in group_rows(counts):
        a = grp_asr.get(row["group"])
        print(f"{row['group']:<46}{row['deaths_1990']:>12,.0f}"
              f"{row['deaths_2023']:>12,.0f}{row['deaths_pct']:>+7.0f}"
              f"{row['crude_pct']:>+9.1f}{a:>+8.1f}")


if __name__ == "__main__":
    main()
