"""
figures.py
----------
Generate the age-specific mortality-rate figures for the GBD Brazil
manuscript. All age-standardised percentages and 95% CIs are computed
directly by analysis_standardised.py (WHO World Standard Population,
Monte Carlo n = 10,000). There are no manual overrides: every number shown
in a figure is reproduced by re-running the analysis script.

Output
------
figures/fig1_decreased.jpg  -- causes with the greatest standardised reductions
                               (incl. causes that fall only after standardisation)
figures/fig2_increased.jpg  -- causes with rising standardised burden

Usage
-----
    python scripts/figures.py
"""

import os

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

from analysis_standardised import (
    AGE_ORDER,
    DATA_DIR,
    load_data,
    standardised_change,
)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIG_DIR = os.path.join(BASE_DIR, "figures")

AGE_LABELS = [
    "0-6d", "7-27d", "1-5m", "6-11m", "12-23m",
    "2-4y", "5-9y", "10-14y", "15-19y", "20-24y",
    "25-29y", "30-34y", "35-39y", "40-44y", "45-49y",
    "50-54y", "55-59y", "60-64y", "65-69y", "70-74y",
    "75-79y", "80-84y", "85-89y", "90-94y", "95+y",
]

DATA_1990 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data1990.csv"))
DATA_2023 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data2023.csv"))

# Colour palette
BLUE = "#2166ac"
RED = "#d6604d"
GREEN_FILL = "#b8e186"
PINK_FILL = "#fddbc7"
GREY_BG = "#f7f7f7"


def _fmt_pct(v):
    return f"{'−' if v < 0 else '+'}{abs(v):.1f}%"


def _plot_panel(ax, cause, res, reclassified=False):
    r90 = np.array([DATA_1990.get(cause, {}).get(ag, (0, 0, 0))[0]
                    for ag in AGE_ORDER])
    r23 = np.array([DATA_2023.get(cause, {}).get(ag, (0, 0, 0))[0]
                    for ag in AGE_ORDER])
    x = np.arange(len(AGE_ORDER))

    ax.set_facecolor(GREY_BG)
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

    title = cause + ("\n★ falls only after standardisation"
                     if reclassified else "")
    ax.set_title(title, fontsize=7.5, fontweight="bold", pad=4, color="#1a1a1a")

    annot = (f"ASR: {_fmt_pct(res['std_pct'])}\n"
             f"(95% CI {_fmt_pct(res['std_lo'])} to {_fmt_pct(res['std_hi'])})")
    box_color = "#d4edda" if res["std_pct"] < 0 else "#fde8e8"
    ax.annotate(annot, xy=(0.97, 0.97), xycoords="axes fraction",
                ha="right", va="top", fontsize=6.0, fontweight="bold",
                bbox=dict(boxstyle="round,pad=0.35", fc=box_color,
                          alpha=0.85, ec="#aaaaaa", lw=0.6))

    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color("#cccccc")
    ax.spines["bottom"].set_color("#cccccc")
    ax.grid(axis="y", color="#dddddd", linewidth=0.5, zorder=0)


def make_figure(causes, outpath, suptitle, ncols, reclassified=None):
    reclassified = reclassified or []
    n = len(causes)
    nrows = (n + ncols - 1) // ncols
    fig, axes = plt.subplots(nrows, ncols,
                             figsize=(ncols * 4.4, nrows * 3.9),
                             constrained_layout=True)
    axes_flat = np.array(axes).flatten()

    print(f"\n{'-'*64}\nFigure: {os.path.basename(outpath)}\n{'-'*64}")
    for i, cause in enumerate(causes):
        res = standardised_change(cause, DATA_1990, DATA_2023)
        print(f"  {cause:<44} {_fmt_pct(res['std_pct']):>8}  "
              f"[{_fmt_pct(res['std_lo'])}, {_fmt_pct(res['std_hi'])}]")
        _plot_panel(axes_flat[i], cause, res, cause in reclassified)

    for j in range(len(causes), len(axes_flat)):
        axes_flat[j].set_visible(False)

    handles = [
        Line2D([0], [0], color=BLUE, lw=2.0, label="1990 rate"),
        Line2D([0], [0], color=RED, lw=2.0, linestyle="--", label="2023 rate"),
    ]
    fig.legend(handles=handles, loc="lower right", fontsize=9,
               framealpha=0.9, ncol=2, edgecolor="#cccccc")
    fig.suptitle(suptitle, fontsize=10.5, fontweight="bold", y=1.01)

    os.makedirs(FIG_DIR, exist_ok=True)
    fig.savefig(outpath, dpi=150, bbox_inches="tight",
                format="jpeg", pil_kwargs={"quality": 92})
    plt.close(fig)
    print(f"Saved -> {outpath}")


# Causes that decline under WHO age standardisation. The three marked with a
# star show an apparent rise in the unweighted-mean metric but a genuine
# standardised decline.
FIG1_CAUSES = [
    "Enteric infections",
    "Nutritional deficiencies",
    "Neglected tropical diseases and malaria",
    "Maternal and neonatal disorders",
    "Cardiovascular diseases",
    "Respiratory infections and tuberculosis",
    "Unintentional injuries",        # reclassified
    "Neoplasms",                     # reclassified
    "Diabetes and kidney diseases",  # reclassified
]

# Causes with a rising age-standardised burden.
FIG2_CAUSES = [
    "Skin and subcutaneous diseases",
    "Other non-communicable diseases",
    "Substance use disorders",
    "HIV/AIDS and sexually transmitted infections",
    "Musculoskeletal disorders",
    "Neurological disorders",
]

if __name__ == "__main__":
    print("Age-standardised figures (WHO World Standard, Monte Carlo n=10,000)")
    make_figure(
        FIG1_CAUSES,
        os.path.join(FIG_DIR, "fig1_decreased.jpg"),
        "Brazil — Causes with Greatest Age-Standardised Mortality "
        "Reductions, 1990–2023",
        ncols=3,
        reclassified=["Unintentional injuries", "Neoplasms",
                      "Diabetes and kidney diseases"],
    )
    make_figure(
        FIG2_CAUSES,
        os.path.join(FIG_DIR, "fig2_increased.jpg"),
        "Brazil — Causes with Rising Age-Standardised Mortality "
        "Burden, 1990–2023",
        ncols=3,
    )
    print("\nAll figures generated.")
