"""
analysis_standardised.py
------------------------
Reproduces the age-standardised mortality-rate analysis for:
"Shifting Mortality Burden in Brazil, 1990–2023"

Method
------
Direct age-standardisation against the mean of Brazil's 1990 and 2023
populations (UN World Population Prospects 2024 approximation).
The age-standardised rate for each cause and year is:

    ASR = Σ_i (r_i × w_i)

where r_i is the age-specific death rate in GBD age group i and
w_i = P_i_std / Σ P_j_std is the normalised standard-population weight.

Uncertainty is propagated through all 25 GBD 95% confidence intervals
simultaneously via Monte Carlo simulation (n=10,000 draws per cause),
assuming log-normal distributions for each age-specific rate.
The 95% CI for the standardised % change is the 2.5th–97.5th percentile
of the 10,000 simulated % changes.

Usage
-----
    python scripts/analysis_standardised.py

Output
------
Prints a table of crude and age-standardised % changes for all causes,
sorted by standardised % change.
"""

import csv
import os
import numpy as np

# ── Paths ─────────────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR  = os.path.join(BASE_DIR, "data")

# ── GBD age groups ────────────────────────────────────────────────────────────
AGE_ORDER = [
    "0-6 days", "7-27 days", "1-5 months", "6-11 months", "12-23 months",
    "2-4 years", "5-9 years", "10-14 years", "15-19 years", "20-24 years",
    "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years",
    "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70-74 years",
    "75-79 years", "80-84 years", "85-89 years", "90-94 years", "95+ years",
]

# ── Standard population ───────────────────────────────────────────────────────
# Mean of Brazil 1990 + 2023 populations (UN WPP 2024, thousands).
# The 0–4 year UN WPP group is split proportionally by person-years into
# the six GBD sub-groups it contains.
_BRAZIL_5YR = {
    # (age_min, excl_max): (pop_1990_k, pop_2023_k)
    ( 0,   5): (17_000, 14_500),
    ( 5,  10): (16_000, 15_500),
    (10,  15): (15_000, 16_500),
    (15,  20): (14_000, 16_500),
    (20,  25): (13_000, 16_500),
    (25,  30): (11_500, 16_500),
    (30,  35): (10_000, 16_500),
    (35,  40): ( 8_500, 16_000),
    (40,  45): ( 7_000, 15_000),
    (45,  50): ( 5_700, 14_000),
    (50,  55): ( 4_500, 13_000),
    (55,  60): ( 3_600, 11_500),
    (60,  65): ( 2_900,  9_800),
    (65,  70): ( 2_200,  7_800),
    (70,  75): ( 1_600,  6_000),
    (75,  80): ( 1_000,  4_500),
    (80,  85): (   550,  3_000),
    (85,  90): (   260,  1_600),
    (90,  95): (    90,    600),
    (95, 120): (    25,    200),
}

# Duration (years) of each GBD sub-group within the 0–4 band
_SUBGROUP_DUR = {
    "0-6 days":      6 / 365.25,
    "7-27 days":    21 / 365.25,
    "1-5 months":    5 / 12,
    "6-11 months":   6 / 12,
    "12-23 months":  1.0,
    "2-4 years":     3.0,
}


def build_std_pop():
    """Return normalised population weights for the 25 GBD age groups."""
    mean_pop = {k: (v[0] + v[1]) / 2.0 for k, v in _BRAZIL_5YR.items()}
    total_dur_0_4 = sum(_SUBGROUP_DUR.values())
    pop_0_4 = mean_pop[(0, 5)]

    raw = {}
    for ag in AGE_ORDER:
        if ag in _SUBGROUP_DUR:
            raw[ag] = pop_0_4 * _SUBGROUP_DUR[ag] / total_dur_0_4
        else:
            age_str = ag.replace(" years", "")
            if "+" in age_str:
                lo, hi = int(age_str.replace("+", "")), 120
            else:
                lo_s, hi_s = age_str.split("-")
                lo, hi = int(lo_s), int(hi_s) + 1
            raw[ag] = mean_pop[(lo, hi)]

    total = sum(raw.values())
    return {ag: raw[ag] / total for ag in AGE_ORDER}


STD_WEIGHTS = build_std_pop()

# ── Data loading ──────────────────────────────────────────────────────────────
def load_data(filepath):
    """Return {cause: {age_group: (value, lower, upper)}}."""
    data = {}
    with open(filepath, newline="", encoding="utf-8") as fh:
        for row in csv.DictReader(fh):
            cause = (row.get("Cause of death or injury") or "").strip()
            age   = (row.get("Age") or "").strip()
            if not cause or not age:
                continue
            try:
                val = float(row["Value"])
                lo  = float(row["Lower bound"])
                hi  = float(row["Upper bound"])
            except (ValueError, KeyError):
                continue
            data.setdefault(cause, {})[age] = (val, lo, hi)
    return data

# ── Monte Carlo age-standardisation ──────────────────────────────────────────
N_MC = 10_000
RNG  = np.random.default_rng(42)


def mc_draws(cause_data, n=N_MC):
    """
    Draw n Monte Carlo samples of age-specific rates.
    Returns array of shape (n, 25).
    Log-normal distribution for positive rates; normal fallback for near-zero.
    """
    draws = np.zeros((n, len(AGE_ORDER)))
    for j, ag in enumerate(AGE_ORDER):
        if ag not in cause_data:
            continue
        val, lo, hi = cause_data[ag]
        if val <= 0 or lo <= 0:
            se = (hi - lo) / (2 * 1.96) if (hi - lo) > 0 else max(val * 0.1, 1e-9)
            draws[:, j] = np.maximum(0.0, RNG.normal(val, se, n))
        else:
            mu    = np.log(val)
            sigma = max((np.log(hi) - np.log(lo)) / (2 * 1.96), 1e-9)
            draws[:, j] = RNG.lognormal(mu, sigma, n)
    return draws


def standardised_pct_change(cause, data_1990, data_2023):
    """
    Compute age-standardised % change with 95% CI via Monte Carlo.

    Returns
    -------
    point : float   median % change across MC draws
    lo    : float   2.5th percentile
    hi    : float   97.5th percentile
    """
    weights = np.array([STD_WEIGHTS[ag] for ag in AGE_ORDER])

    d90 = mc_draws(data_1990.get(cause, {}))
    d23 = mc_draws(data_2023.get(cause, {}))

    asr90 = (d90 * weights).sum(axis=1)
    asr23 = (d23 * weights).sum(axis=1)

    valid = asr90 > 0
    pct   = np.where(valid, (asr23 - asr90) / asr90 * 100.0, np.nan)

    return (float(np.nanmedian(pct)),
            float(np.nanpercentile(pct, 2.5)),
            float(np.nanpercentile(pct, 97.5)))


def crude_pct_change(cause, data_1990, data_2023):
    """Arithmetic-mean (unweighted) % change, matching analysis.py."""
    def mean_rate(d):
        vals = [d.get(ag, (0,))[0] for ag in AGE_ORDER]
        return sum(vals) / len(vals)

    r90 = mean_rate(data_1990.get(cause, {}))
    r23 = mean_rate(data_2023.get(cause, {}))
    return (r23 - r90) / r90 * 100.0 if r90 else float("nan")


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    data_1990 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data1990.csv"))
    data_2023 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data2023.csv"))
    causes    = sorted(set(data_1990) | set(data_2023))

    print("Computing age-standardised rates via Monte Carlo "
          f"(n={N_MC:,}) …\n")

    results = []
    for cause in causes:
        crude = crude_pct_change(cause, data_1990, data_2023)
        std, lo, hi = standardised_pct_change(cause, data_1990, data_2023)
        results.append((cause, crude, std, lo, hi))

    results.sort(key=lambda x: x[2])   # sort by standardised % change

    hdr = (f"{'Cause':<52} {'Crude %':>8}  "
           f"{'Std %':>8}  {'95% CI':^22}  {'Direction change?'}")
    print(hdr)
    print("─" * len(hdr))

    for cause, crude, std, lo, hi in results:
        flip = ((crude > 0) != (std > 0))
        flag = "  ← REVERSED" if flip else ""
        crude_s = f"{'+' if crude >= 0 else ''}{crude:.1f}%"
        std_s   = f"{'+' if std   >= 0 else ''}{std:.1f}%"
        ci_s    = (f"[{'+' if lo >= 0 else ''}{lo:.1f}%, "
                   f"{'+' if hi >= 0 else ''}{hi:.1f}%]")
        print(f"{cause:<52} {crude_s:>8}  {std_s:>8}  {ci_s:<22}{flag}")

    print(f"\nTotal causes: {len(results)}")
    reversed_causes = [r for r in results if ((r[1] > 0) != (r[2] > 0))]
    print(f"Direction reversed under standardisation: {len(reversed_causes)}")
    for r in reversed_causes:
        print(f"  • {r[0]}: crude {r[1]:+.1f}% → std {r[2]:+.1f}% "
              f"(95% CI {r[3]:+.1f}% to {r[4]:+.1f}%)")


if __name__ == "__main__":
    main()
