"""
figures.py
----------
Generate age-specific mortality rate figures for the GBD Brazil manuscript.

Age-standardised percentage changes use direct standardisation against the
mean of Brazil's 1990 and 2023 populations (UN WPP 2024 approximation).
Uncertainty is propagated via Monte Carlo (n=10,000) through GBD 95% CIs,
assuming log-normal distributions for each age-specific rate.

User-verified values (from independent analysis) override MC estimates for
five key causes where direction reversal or large correction occurs.

Output
------
figures/fig1_decreased.jpg  — eight causes with greatest standardised reductions
figures/fig2_increased.jpg  — four causes with largest standardised increases

Usage
-----
    python scripts/figures.py
"""

import csv
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

# ── Paths ─────────────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR  = os.path.join(BASE_DIR, "data")
FIG_DIR   = os.path.join(BASE_DIR, "figures")

# ── GBD age groups ────────────────────────────────────────────────────────────
AGE_ORDER = [
    "0-6 days", "7-27 days", "1-5 months", "6-11 months", "12-23 months",
    "2-4 years", "5-9 years", "10-14 years", "15-19 years", "20-24 years",
    "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years",
    "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70-74 years",
    "75-79 years", "80-84 years", "85-89 years", "90-94 years", "95+ years",
]

AGE_LABELS = [
    "0-6d", "7-27d", "1-5m", "6-11m", "12-23m",
    "2-4y", "5-9y", "10-14y", "15-19y", "20-24y",
    "25-29y", "30-34y", "35-39y", "40-44y", "45-49y",
    "50-54y", "55-59y", "60-64y", "65-69y", "70-74y",
    "75-79y", "80-84y", "85-89y", "90-94y", "95+y",
]

# ── Standard population ───────────────────────────────────────────────────────
# Mean of Brazil 1990 + 2023 populations (UN WPP 2024 approx., thousands)
# 5-year age bands; 0–4 band is later split proportionally by person-years.
_BRAZIL_5YR = {
    # key: (min_age, excl_max_age)  value: (pop_1990_k, pop_2023_k)
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

# Duration (years) for each GBD sub-group that falls inside the 0–4 band
_SUBGROUP_DUR = {
    "0-6 days":      6 / 365.25,
    "7-27 days":    21 / 365.25,
    "1-5 months":    5 / 12,
    "6-11 months":   6 / 12,
    "12-23 months":  1.0,
    "2-4 years":     3.0,
}


def _build_std_pop():
    mean_pop = {k: (v[0] + v[1]) / 2 for k, v in _BRAZIL_5YR.items()}
    total_dur_0_4 = sum(_SUBGROUP_DUR.values())   # ≈ 5 years
    pop_0_4 = mean_pop[(0, 5)]

    std_pop = {}
    for ag in AGE_ORDER:
        if ag in _SUBGROUP_DUR:
            std_pop[ag] = pop_0_4 * _SUBGROUP_DUR[ag] / total_dur_0_4
        else:
            age_str = ag.replace(" years", "")
            if "+" in age_str:
                lo, hi = int(age_str.replace("+", "")), 120
            else:
                parts = age_str.split("-")
                lo, hi = int(parts[0]), int(parts[1]) + 1
            std_pop[ag] = mean_pop[(lo, hi)]
    return std_pop


STD_POP     = _build_std_pop()
_total_pop  = sum(STD_POP.values())
POP_WEIGHTS = {ag: STD_POP[ag] / _total_pop for ag in AGE_ORDER}

# ── User-verified standardised values (point %, lo_ci %, hi_ci %) ─────────────
# These come from an independent analysis and take precedence over MC estimates.
VERIFIED = {
    "Unintentional injuries":                 (-13.7, -16.6, -10.6),
    "Diabetes and kidney diseases":            (-7.9, -11.8,  -3.9),
    "Other non-communicable diseases":        (100.6,  91.9, 109.2),
    "Respiratory infections and tuberculosis": (-10.0, -14.8,  -5.1),
}

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


DATA_1990 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data1990.csv"))
DATA_2023 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data2023.csv"))

# ── Monte Carlo age-standardisation ──────────────────────────────────────────
N_MC = 10_000
RNG  = np.random.default_rng(42)


def _mc_draws(cause_data, n):
    """Draw n MC samples of age-specific rates; returns (n, 25) array."""
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
            sigma = (np.log(hi) - np.log(lo)) / (2 * 1.96)
            sigma = max(sigma, 1e-9)
            draws[:, j] = RNG.lognormal(mu, sigma, n)
    return draws


def compute_std_pct(cause):
    """Return (point%, lo_ci%, hi_ci%) age-standardised % change."""
    if cause in VERIFIED:
        return VERIFIED[cause]

    weights = np.array([POP_WEIGHTS[ag] for ag in AGE_ORDER])

    d90 = _mc_draws(DATA_1990.get(cause, {}), N_MC)
    d23 = _mc_draws(DATA_2023.get(cause, {}), N_MC)

    asr90 = (d90 * weights).sum(axis=1)
    asr23 = (d23 * weights).sum(axis=1)

    valid = asr90 > 0
    pct   = np.where(valid, (asr23 - asr90) / asr90 * 100, np.nan)

    return (float(np.nanmedian(pct)),
            float(np.nanpercentile(pct, 2.5)),
            float(np.nanpercentile(pct, 97.5)))

# ── Colour palette ────────────────────────────────────────────────────────────
BLUE       = "#2166ac"
RED        = "#d6604d"
GREEN_FILL = "#b8e186"
PINK_FILL  = "#fddbc7"
GREY_BG    = "#f7f7f7"


def _fmt_pct(v):
    """Format a percentage value with sign and one decimal."""
    return f"{'−' if v < 0 else '+'}{abs(v):.1f}%"


def _plot_panel(ax, cause, std_pct, lo_ci, hi_ci, reclassified=False):
    """Render one subplot panel."""
    r90 = np.array([DATA_1990.get(cause, {}).get(ag, (0, 0, 0))[0]
                    for ag in AGE_ORDER])
    r23 = np.array([DATA_2023.get(cause, {}).get(ag, (0, 0, 0))[0]
                    for ag in AGE_ORDER])
    x = np.arange(len(AGE_ORDER))

    ax.set_facecolor(GREY_BG)

    # Shading: green where 2023 improved, pink where 2023 worsened
    ax.fill_between(x, r90, r23, where=(r23 <= r90),
                    color=GREEN_FILL, alpha=0.5, linewidth=0)
    ax.fill_between(x, r90, r23, where=(r23 > r90),
                    color=PINK_FILL, alpha=0.5, linewidth=0)

    ax.plot(x, r90, color=BLUE, linewidth=1.6, zorder=3)
    ax.plot(x, r23, color=RED, linewidth=1.6, linestyle="--", zorder=3)

    ax.set_xticks(x)
    ax.set_xticklabels(AGE_LABELS, rotation=60, ha="right",
                       fontsize=5.5, color="#333333")
    ax.tick_params(axis="y", labelsize=6.5)
    ax.set_ylabel("Deaths / 100,000", fontsize=6.5)

    # Title
    title = cause + ("\n★ reclassified" if reclassified else "")
    ax.set_title(title, fontsize=7.5, fontweight="bold", pad=4,
                 color="#1a1a1a")

    # Annotation box
    pct_str = _fmt_pct(std_pct)
    if lo_ci is not None and hi_ci is not None:
        ci_str = f"95% CI {_fmt_pct(lo_ci)} to {_fmt_pct(hi_ci)}"
        annot  = f"Std: {pct_str}\n({ci_str})"
    else:
        annot = f"Std: {pct_str}"

    box_color = "#d4edda" if std_pct < 0 else "#fde8e8"
    ax.annotate(
        annot,
        xy=(0.97, 0.97), xycoords="axes fraction",
        ha="right", va="top", fontsize=6.0, fontweight="bold",
        bbox=dict(boxstyle="round,pad=0.35", fc=box_color,
                  alpha=0.85, ec="#aaaaaa", lw=0.6),
    )

    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#cccccc")
    ax.spines["bottom"].set_color("#cccccc")
    ax.grid(axis="y", color="#dddddd", linewidth=0.5, zorder=0)


def make_figure(causes, outpath, suptitle, reclassified=None):
    """Generate and save a multi-panel figure."""
    reclassified = reclassified or []
    n     = len(causes)
    ncols = 4 if n > 4 else 2
    nrows = (n + ncols - 1) // ncols

    fig, axes = plt.subplots(
        nrows, ncols,
        figsize=(ncols * 4.8, nrows * 4.2),
        constrained_layout=True,
    )
    axes_flat = np.array(axes).flatten()

    print(f"\n{'─'*60}")
    print(f"Figure: {os.path.basename(outpath)}")
    print(f"{'Cause':<46} {'Std %':>8}  {'95% CI'}")
    print(f"{'─'*60}")

    for i, cause in enumerate(causes):
        std_pct, lo_ci, hi_ci = compute_std_pct(cause)
        sign = VERIFIED.get(cause, None)
        src = "verified" if sign else "computed"
        print(f"  {cause:<44} {_fmt_pct(std_pct):>8}  "
              f"[{_fmt_pct(lo_ci)}, {_fmt_pct(hi_ci)}]  ({src})")
        _plot_panel(axes_flat[i], cause, std_pct, lo_ci, hi_ci,
                    reclassified=(cause in reclassified))

    for j in range(len(causes), len(axes_flat)):
        axes_flat[j].set_visible(False)

    # Shared legend
    legend_handles = [
        Line2D([0], [0], color=BLUE, linewidth=2.0, label="1990 rate"),
        Line2D([0], [0], color=RED,  linewidth=2.0, linestyle="--", label="2023 rate"),
    ]
    fig.legend(handles=legend_handles, loc="lower right",
               fontsize=9, framealpha=0.9, ncol=2, edgecolor="#cccccc")

    fig.suptitle(suptitle, fontsize=10, fontweight="bold", y=1.015)

    os.makedirs(FIG_DIR, exist_ok=True)
    fig.savefig(outpath, dpi=150, bbox_inches="tight",
                format="jpeg", pil_kwargs={"quality": 92})
    plt.close(fig)
    print(f"\nSaved → {outpath}")


# ── Cause lists ───────────────────────────────────────────────────────────────
FIG1_CAUSES = [
    "Enteric infections",
    "Nutritional deficiencies",
    "Neglected tropical diseases and malaria",
    "Maternal and neonatal disorders",
    "Cardiovascular diseases",
    "Respiratory infections and tuberculosis",
    "Unintentional injuries",        # ★ reclassified: crude +26.2%, std −13.7%
    "Diabetes and kidney diseases",  # ★ reclassified: crude +16.3%, std −7.9%
]

FIG2_CAUSES = [
    "Skin and subcutaneous diseases",
    "Other non-communicable diseases",
    "Substance use disorders",
    "Neurological disorders",
]

if __name__ == "__main__":
    print("Age-standardised rate analysis — Monte Carlo (n=10,000)\n")

    make_figure(
        FIG1_CAUSES,
        os.path.join(FIG_DIR, "fig1_decreased.jpg"),
        "Brazil — Causes with Greatest Age-Standardised Mortality Reductions, 1990–2023",
        reclassified=["Unintentional injuries", "Diabetes and kidney diseases"],
    )

    make_figure(
        FIG2_CAUSES,
        os.path.join(FIG_DIR, "fig2_increased.jpg"),
        "Brazil — Causes with Rising Age-Standardised Mortality Burden, 1990–2023",
    )

    print("\nAll figures generated.")
