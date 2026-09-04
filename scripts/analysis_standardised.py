"""
analysis_standardised.py
------------------------
Age-standardised mortality-rate analysis for:
"Shifting Mortality Burden in Brazil, 1990-2023"

Method
------
Direct age standardisation of GBD 2023 age-specific death rates for Brazil
to the WHO World Standard Population (Ahmad OB, Boschi-Pinto C, Lopez AD,
et al. Age standardization of rates: a new WHO standard. GPE Discussion
Paper No. 31. Geneva: WHO; 2001). The WHO World Standard is an external,
published, fixed standard, so standardised rates for 1990 and 2023 are
directly comparable and are not influenced by Brazil's changing age
structure.

The age-standardised death rate (ASR) for each cause and year is

    ASR = sum_i ( r_i * w_i )

where r_i is the GBD age-specific death rate (per 100,000) in age group i
and w_i is the normalised WHO World Standard weight for that group.

This script also reproduces, for comparison, the *unweighted mean of the 25
age-specific rates* -- a naive summary an analyst obtains by averaging the rows
of an age-disaggregated extract (it is NOT a metric published by GBD). It
weights every age band equally regardless of its share of the population and
is reported here only to show how it can diverge from a properly standardised
rate.

Point estimates are computed deterministically from the reported GBD point
rates. 95% uncertainty intervals for the standardised percent change are
obtained by Monte Carlo simulation (n = 10,000) that propagates each age
group's GBD 95% interval, assuming an independent log-normal distribution
per age-specific rate (a normal distribution censored at zero is used as a
fallback for groups whose lower bound is zero or negative). Independence
across age groups is a simplifying assumption; the GBD posterior correlation
structure is not published in the extract and this is noted as a limitation.

Usage
-----
    python scripts/analysis_standardised.py
    python scripts/analysis_standardised.py --json results.json   # machine-readable

Output
------
Prints a table of unweighted-mean and age-standardised percent changes for
all causes, sorted by standardised percent change, and flags direction
reversals. With --json, also writes a results file consumed by figures.py.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import sys

import numpy as np

# -- Paths --------------------------------------------------------------------
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")

# -- GBD age groups (25, in order) --------------------------------------------
AGE_ORDER = [
    "0-6 days", "7-27 days", "1-5 months", "6-11 months", "12-23 months",
    "2-4 years", "5-9 years", "10-14 years", "15-19 years", "20-24 years",
    "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years",
    "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70-74 years",
    "75-79 years", "80-84 years", "85-89 years", "90-94 years", "95+ years",
]

# -- WHO World Standard Population --------------------------------------------
# Ahmad OB, Boschi-Pinto C, Lopez AD, Murray CJL, Lozano R, Inoue M.
# Age standardization of rates: a new WHO standard. GPE Discussion Paper
# No. 31. Geneva: World Health Organization; 2001, Table 1.
# Values are the relative weight (%) of each conventional 5-year age band.
WHO_WORLD_STD = {
    (0, 5): 8.86,
    (5, 10): 8.69,
    (10, 15): 8.60,
    (15, 20): 8.47,
    (20, 25): 8.22,
    (25, 30): 7.93,
    (30, 35): 7.61,
    (35, 40): 7.15,
    (40, 45): 6.59,
    (45, 50): 6.04,
    (50, 55): 5.37,
    (55, 60): 4.55,
    (60, 65): 3.72,
    (65, 70): 2.96,
    (70, 75): 2.21,
    (75, 80): 1.52,
    (80, 85): 0.91,
    (85, 90): 0.44,
    (90, 95): 0.15,
    (95, 100): 0.04,
    (100, 120): 0.005,
}

# The GBD extract splits the 0-4 band into six sub-groups. The WHO 0-4 weight
# is apportioned among them in proportion to the person-years each spans.
_SUBGROUP_DUR = {
    "0-6 days":      6 / 365.25,
    "7-27 days":    21 / 365.25,
    "1-5 months":    5 / 12,
    "6-11 months":   6 / 12,
    "12-23 months":  1.0,
    "2-4 years":     3.0,
}


def build_std_weights() -> dict:
    """Map the WHO World Standard onto the 25 GBD age groups (normalised)."""
    # Merge the two open-ended WHO bands (95-99, 100+) into GBD's "95+".
    band_95plus = WHO_WORLD_STD[(95, 100)] + WHO_WORLD_STD[(100, 120)]
    weight_0_4 = WHO_WORLD_STD[(0, 5)]
    total_dur_0_4 = sum(_SUBGROUP_DUR.values())  # ~= 5 years

    raw = {}
    for ag in AGE_ORDER:
        if ag in _SUBGROUP_DUR:
            raw[ag] = weight_0_4 * _SUBGROUP_DUR[ag] / total_dur_0_4
        elif ag == "95+ years":
            raw[ag] = band_95plus
        else:
            lo_s, hi_s = ag.replace(" years", "").split("-")
            lo, hi = int(lo_s), int(hi_s) + 1
            raw[ag] = WHO_WORLD_STD[(lo, hi)]

    total = sum(raw.values())
    return {ag: raw[ag] / total for ag in AGE_ORDER}


STD_WEIGHTS = build_std_weights()


# -- Data loading -------------------------------------------------------------
def load_data(filepath: str) -> dict:
    """Return {cause: {age_group: (value, lower, upper)}}."""
    data = {}
    with open(filepath, newline="", encoding="utf-8") as fh:
        for row in csv.DictReader(fh):
            cause = (row.get("Cause of death or injury") or "").strip()
            age = (row.get("Age") or "").strip()
            if not cause or not age:
                continue
            try:
                val = float(row["Value"])
                lo = float(row["Lower bound"])
                hi = float(row["Upper bound"])
            except (ValueError, KeyError, TypeError):
                continue
            data.setdefault(cause, {})[age] = (val, lo, hi)
    return data


# -- Core calculations --------------------------------------------------------
N_MC = 10_000
SEED = 42


def _rng_for(label: str) -> np.random.Generator:
    """Deterministic, call-order-independent RNG keyed on a label.

    Seeding per (cause, year) guarantees the Monte Carlo intervals are
    identical no matter which script or in what order standardised_change is
    invoked, so every published number is exactly reproducible.
    """
    digest = hashlib.md5(f"{SEED}:{label}".encode()).digest()
    return np.random.default_rng(int.from_bytes(digest[:8], "little"))


def _weights_vector() -> np.ndarray:
    return np.array([STD_WEIGHTS[ag] for ag in AGE_ORDER])


def asr_point(cause_data: dict) -> float:
    """Deterministic age-standardised rate from the reported point rates."""
    w = _weights_vector()
    r = np.array([cause_data.get(ag, (0.0, 0.0, 0.0))[0] for ag in AGE_ORDER])
    return float((r * w).sum())


def mean_age_specific(cause_data: dict) -> float:
    """Unweighted mean of the 25 age-specific rates (naive comparison metric)."""
    r = [cause_data.get(ag, (0.0,))[0] for ag in AGE_ORDER]
    return sum(r) / len(r)


def _mc_draws(cause_data: dict, n: int, rng: np.random.Generator) -> np.ndarray:
    """Draw n Monte Carlo samples of the 25 age-specific rates -> (n, 25)."""
    draws = np.zeros((n, len(AGE_ORDER)))
    for j, ag in enumerate(AGE_ORDER):
        if ag not in cause_data:
            continue
        val, lo, hi = cause_data[ag]
        if val <= 0 or lo <= 0:
            se = (hi - lo) / (2 * 1.96) if (hi - lo) > 0 else max(val * 0.1, 1e-9)
            draws[:, j] = np.maximum(0.0, rng.normal(val, se, n))
        else:
            mu = np.log(val)
            sigma = max((np.log(hi) - np.log(lo)) / (2 * 1.96), 1e-9)
            draws[:, j] = rng.lognormal(mu, sigma, n)
    return draws


def standardised_change(cause: str, data_1990: dict, data_2023: dict) -> dict:
    """Age-standardised rates and percent change with Monte Carlo 95% UI."""
    w = _weights_vector()
    d90 = data_1990.get(cause, {})
    d23 = data_2023.get(cause, {})

    asr90 = asr_point(d90)
    asr23 = asr_point(d23)
    pct_point = (asr23 - asr90) / asr90 * 100.0 if asr90 else float("nan")

    sim90 = (_mc_draws(d90, N_MC, _rng_for(f"{cause}|1990")) * w).sum(axis=1)
    sim23 = (_mc_draws(d23, N_MC, _rng_for(f"{cause}|2023")) * w).sum(axis=1)
    valid = sim90 > 0
    pct = np.where(valid, (sim23 - sim90) / sim90 * 100.0, np.nan)

    m90 = mean_age_specific(d90)
    m23 = mean_age_specific(d23)
    return {
        "cause": cause,
        "asr_1990": asr90,
        "asr_2023": asr23,
        "std_pct": pct_point,
        "std_lo": float(np.nanpercentile(pct, 2.5)),
        "std_hi": float(np.nanpercentile(pct, 97.5)),
        "mean_1990": m90,
        "mean_2023": m23,
        "mean_pct": (m23 - m90) / m90 * 100.0 if m90 else float("nan"),
    }


# -- GBD Level-1 super-groups -------------------------------------------------
# Mapping of the 21 analysed Level-2 categories to the three GBD Level-1
# groups. (Sense organ diseases carry no mortality estimate and are excluded.)
LEVEL1_GROUPS = {
    "Communicable, maternal, neonatal & nutritional": [
        "HIV/AIDS and sexually transmitted infections",
        "Respiratory infections and tuberculosis",
        "Enteric infections",
        "Neglected tropical diseases and malaria",
        "Other infectious diseases",
        "Maternal and neonatal disorders",
        "Nutritional deficiencies",
    ],
    "Non-communicable diseases": [
        "Neoplasms",
        "Cardiovascular diseases",
        "Chronic respiratory diseases",
        "Digestive diseases",
        "Neurological disorders",
        "Mental disorders",
        "Substance use disorders",
        "Diabetes and kidney diseases",
        "Skin and subcutaneous diseases",
        "Musculoskeletal disorders",
        "Other non-communicable diseases",
    ],
    "Injuries": [
        "Transport injuries",
        "Unintentional injuries",
        "Self-harm and interpersonal violence",
    ],
}


def _sum_age_specific(causes, year_data):
    """Sum age-specific point rates across a set of causes (rates are additive)."""
    out = {}
    for ag in AGE_ORDER:
        out[ag] = (sum(year_data.get(c, {}).get(ag, (0.0,))[0] for c in causes),
                   0.0, 0.0)
    return out


def group_change(group_causes, data_1990, data_2023) -> dict:
    """
    Age-standardised rate and % change for a Level-1 group.

    Point estimates sum the constituent age-specific rates (which are additive
    across mutually exclusive causes) and standardise to the WHO standard.
    Monte Carlo CIs sum independent draws across both causes and age groups,
    consistent with the independence assumption used elsewhere.
    """
    w = _weights_vector()
    agg90 = _sum_age_specific(group_causes, data_1990)
    agg23 = _sum_age_specific(group_causes, data_2023)
    asr90 = asr_point(agg90)
    asr23 = asr_point(agg23)
    pct_point = (asr23 - asr90) / asr90 * 100.0 if asr90 else float("nan")

    sim90 = np.zeros(N_MC)
    sim23 = np.zeros(N_MC)
    for c in group_causes:
        sim90 += (_mc_draws(data_1990.get(c, {}), N_MC, _rng_for(f"{c}|1990")) * w).sum(axis=1)
        sim23 += (_mc_draws(data_2023.get(c, {}), N_MC, _rng_for(f"{c}|2023")) * w).sum(axis=1)
    pct = (sim23 - sim90) / sim90 * 100.0

    return {
        "group": "",
        "asr_1990": asr90,
        "asr_2023": asr23,
        "std_pct": pct_point,
        "std_lo": float(np.nanpercentile(pct, 2.5)),
        "std_hi": float(np.nanpercentile(pct, 97.5)),
    }


def compute_groups(data_1990: dict, data_2023: dict) -> list:
    out = []
    for name, causes in LEVEL1_GROUPS.items():
        r = group_change(causes, data_1990, data_2023)
        r["group"] = name
        out.append(r)
    return out


def compute_all(data_1990: dict, data_2023: dict) -> list:
    causes = sorted(
        c for c in (set(data_1990) | set(data_2023))
        if data_1990.get(c) or data_2023.get(c)
    )
    results = [standardised_change(c, data_1990, data_2023) for c in causes]
    results.sort(key=lambda d: d["std_pct"])
    return results


# -- Premature NCD mortality (SDG 3.4.1-style indicator) ----------------------
# Unconditional probability of dying between exact ages 30 and 70 from the
# four major NCD groups, computed from the age-specific death rates of the
# eight 5-year GBD age groups spanning 30-69 using the standard life-table
# approximation q_i = 1 - exp(-5 m_i), P = 1 - prod(1 - q_i)
# (WHO Global Action Plan 2013-2020; UN SDG indicator 3.4.1 metadata).
# Note: the GBD Level-2 extract combines diabetes with chronic kidney disease,
# so the indicator here is an approximation that includes kidney deaths.
PREMATURE_NCD_CAUSES = [
    "Cardiovascular diseases",
    "Neoplasms",
    "Chronic respiratory diseases",
    "Diabetes and kidney diseases",
]
PREMATURE_AGE_GROUPS = [
    "30-34 years", "35-39 years", "40-44 years", "45-49 years",
    "50-54 years", "55-59 years", "60-64 years", "65-69 years",
]


def _prob_30_70(rates_by_age: np.ndarray) -> np.ndarray:
    """rates_by_age: (..., 8) array of deaths per 100,000 -> probability (%)."""
    m = rates_by_age / 100_000.0
    q = 1.0 - np.exp(-5.0 * m)
    return (1.0 - np.prod(1.0 - q, axis=-1)) * 100.0


def premature_ncd_probability(data_1990: dict, data_2023: dict,
                              causes=PREMATURE_NCD_CAUSES) -> dict:
    """Probability (%) of dying at 30-69 from the four major NCD groups."""
    idx = [AGE_ORDER.index(ag) for ag in PREMATURE_AGE_GROUPS]

    def point(year_data):
        r = np.array([sum(year_data.get(c, {}).get(ag, (0.0,))[0] for c in causes)
                      for ag in PREMATURE_AGE_GROUPS])
        return float(_prob_30_70(r))

    def sims(year_data, year):
        tot = np.zeros((N_MC, len(idx)))
        for c in causes:
            tot += _mc_draws(year_data.get(c, {}), N_MC,
                             _rng_for(f"{c}|{year}"))[:, idx]
        return _prob_30_70(tot)

    p90, p23 = point(data_1990), point(data_2023)
    s90, s23 = sims(data_1990, "1990"), sims(data_2023, "2023")
    pct = (s23 - s90) / s90 * 100.0
    return {
        "p_1990": p90, "p_2023": p23,
        "pct": (p23 - p90) / p90 * 100.0,
        "pct_lo": float(np.percentile(pct, 2.5)),
        "pct_hi": float(np.percentile(pct, 97.5)),
        "p90_lo": float(np.percentile(s90, 2.5)), "p90_hi": float(np.percentile(s90, 97.5)),
        "p23_lo": float(np.percentile(s23, 2.5)), "p23_hi": float(np.percentile(s23, 97.5)),
    }


# -- CLI ----------------------------------------------------------------------
def _fmt(v: float) -> str:
    return f"{'+' if v >= 0 else ''}{v:.1f}%"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", metavar="PATH",
                        help="write machine-readable results to PATH")
    args = parser.parse_args()

    data_1990 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data1990.csv"))
    data_2023 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data2023.csv"))
    results = compute_all(data_1990, data_2023)

    print("Age standardisation to the WHO World Standard Population.")
    print(f"Monte Carlo n = {N_MC:,} draws per cause; seed = 42.\n")

    print("GBD Level-1 super-groups (age-standardised):")
    for g in compute_groups(data_1990, data_2023):
        print(f"  {g['group']:<48} {g['asr_1990']:>8.1f} -> {g['asr_2023']:>7.1f}  "
              f"{_fmt(g['std_pct'])} ({_fmt(g['std_lo'])}, {_fmt(g['std_hi'])})")
    print()

    hdr = (f"{'Cause':<46} {'ASR 1990':>9} {'ASR 2023':>9} "
           f"{'Std %':>8} {'95% UI':^20} {'Mean %':>8}")
    print(hdr)
    print("-" * len(hdr))
    for r in results:
        flip = (r["mean_pct"] > 0) != (r["std_pct"] > 0)
        flag = "  <- REVERSED" if flip else ""
        ci = f"[{_fmt(r['std_lo'])}, {_fmt(r['std_hi'])}]"
        print(f"{r['cause']:<46} {r['asr_1990']:>9.1f} {r['asr_2023']:>9.1f} "
              f"{_fmt(r['std_pct']):>8} {ci:^20} {_fmt(r['mean_pct']):>8}{flag}")

    pn = premature_ncd_probability(data_1990, data_2023)
    print(f"\nPremature NCD mortality (probability of death at 30-69, four NCD groups):")
    print(f"  1990: {pn['p_1990']:.1f}%   2023: {pn['p_2023']:.1f}%   "
          f"change {_fmt(pn['pct'])} ({_fmt(pn['pct_lo'])}, {_fmt(pn['pct_hi'])})")

    dec = sum(1 for r in results if r["std_pct"] < 0)
    inc = sum(1 for r in results if r["std_pct"] > 0)
    rev = [r for r in results if (r["mean_pct"] > 0) != (r["std_pct"] > 0)]
    print(f"\nCauses analysed: {len(results)}")
    print(f"Age-standardised decrease: {dec}   increase: {inc}")
    print(f"Direction differs between unweighted mean and standardised rate: "
          f"{len(rev)}")
    for r in rev:
        print(f"  - {r['cause']}: mean {_fmt(r['mean_pct'])} "
              f"-> std {_fmt(r['std_pct'])} "
              f"(95% UI {_fmt(r["std_lo"])} to {_fmt(r["std_hi"])})")

    if args.json:
        with open(args.json, "w", encoding="utf-8") as fh:
            json.dump(results, fh, indent=2)
        print(f"\nWrote {args.json}", file=sys.stderr)


if __name__ == "__main__":
    main()
