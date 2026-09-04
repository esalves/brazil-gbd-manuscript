"""
figures.py
----------
Generate the age-specific mortality-rate figures for the GBD Brazil
manuscript. All age-standardised percentages and 95% UIs are computed
directly by analysis_standardised.py (WHO World Standard Population,
Monte Carlo n = 10,000; 95% uncertainty intervals). There are no manual overrides: every number shown
in a figure is reproduced by re-running the analysis script.

Output
------
figures/fig1_decreased.jpg  -- causes with the greatest standardised reductions
                               (incl. causes that fall only after standardisation)
figures/fig2_increased.jpg  -- causes with rising standardised burden
figures/fig3_trajectory.jpg -- GBD age-standardised rates by year, 1990-2023
                               (GBD world standard; all causes, Level-1 groups,
                               and respiratory infections & TB with/without COVID-19)
figures/fig4_selfharm.jpg   -- self-harm and interpersonal violence and its Level-3
                               components, GBD age-standardised rates by year

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
    LEVEL1_GROUPS,
    load_data,
    standardised_change,
)
from gbd_series import YEARS, SELF_HARM_L2, SELF_HARM_L3, load_series

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
LOG_FLOOR = 0.1   # deaths per 100,000; lower bound of the log axis


def _fmt_pct(v):
    return f"{'−' if v < 0 else '+'}{abs(v):.1f}%"


def _plot_panel(ax, cause, res, reclassified=False):
    r90 = np.array([DATA_1990.get(cause, {}).get(ag, (0, 0, 0))[0]
                    for ag in AGE_ORDER])
    r23 = np.array([DATA_2023.get(cause, {}).get(ag, (0, 0, 0))[0]
                    for ag in AGE_ORDER])
    x = np.arange(len(AGE_ORDER))

    # Age-specific mortality spans several orders of magnitude, so a
    # logarithmic axis keeps both the neonatal spike and the reductions at
    # young and middle ages legible. Rates below the floor are drawn at the
    # floor (this affects only a few near-zero paediatric values).
    r90p = np.maximum(r90, LOG_FLOOR)
    r23p = np.maximum(r23, LOG_FLOOR)

    ax.set_facecolor(GREY_BG)
    ax.fill_between(x, r90p, r23p, where=(r23 <= r90),
                    color=GREEN_FILL, alpha=0.5, linewidth=0)
    ax.fill_between(x, r90p, r23p, where=(r23 > r90),
                    color=PINK_FILL, alpha=0.5, linewidth=0)
    ax.plot(x, r90p, color=BLUE, linewidth=1.6, zorder=3)
    ax.plot(x, r23p, color=RED, linewidth=1.6, linestyle="--", zorder=3)
    ax.set_yscale("log")
    # Headroom (about one decade) so the annotation box never covers a curve.
    ax.set_ylim(bottom=LOG_FLOOR, top=max(r90p.max(), r23p.max()) * 12)

    ax.set_xticks(x)
    ax.set_xticklabels(AGE_LABELS, rotation=60, ha="right",
                       fontsize=7.0, color="#333333")
    ax.tick_params(axis="y", labelsize=7.5)
    ax.set_ylabel("Deaths / 100,000 (log scale)", fontsize=7.5)

    title = cause + ("\n★ falls only after standardisation"
                     if reclassified else "")
    ax.set_title(title, fontsize=8.5, fontweight="bold", pad=4, color="#1a1a1a")

    annot = (f"ASR: {_fmt_pct(res['std_pct'])}\n"
             f"(95% UI {_fmt_pct(res['std_lo'])} to {_fmt_pct(res['std_hi'])})")
    box_color = "#d4edda" if res["std_pct"] < 0 else "#fde8e8"
    ax.annotate(annot, xy=(0.97, 0.97), xycoords="axes fraction",
                ha="right", va="top", fontsize=7.0, fontweight="bold",
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
                             figsize=(ncols * 4.4, nrows * 3.9 + 0.5),
                             layout="constrained")
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
    # Legend in its own strip below the panels so it never overlaps an axis;
    # the title sits above the panels with explicit clearance.
    fig.legend(handles=handles, loc="outside lower center", fontsize=9.5,
               framealpha=0.9, ncol=2, edgecolor="#cccccc")
    fig.suptitle(suptitle, fontsize=11.5, fontweight="bold")

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

def make_trajectory_figure(outpath):
    """Figure 3: GBD's own age-standardised death rates by year, 1990-2023."""
    series = load_series()
    yrs = np.array([int(y) for y in YEARS])

    def asr(cause, y):
        return series.get((cause, y, "Age-standardized", "Rate"), (0.0,))[0]

    def group_asr(causes):
        return np.array([sum(asr(c, y) for c in causes) for y in YEARS])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.4), layout="constrained")
    for ax in (ax1, ax2):
        ax.set_facecolor(GREY_BG)
        ax.axvspan(2019.5, 2022.5, color="#e8e8e8", zorder=0, lw=0)
        ax.axvline(2019, color="#888888", lw=0.8, ls=":", zorder=1)
        ax.grid(axis="y", color="#dddddd", linewidth=0.5, zorder=0)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.tick_params(labelsize=8)
        ax.set_xlim(1989, 2024)
        ax.set_xlabel("Year", fontsize=8.5)

    # Panel A: all causes and the three Level-1 groups (log scale).
    ax1.plot(yrs, np.array([asr("All causes", y) for y in YEARS]),
             color="#1a1a1a", lw=2.0, label="All causes")
    palette = {"Communicable, maternal, neonatal & nutritional": "#1b9e77",
               "Non-communicable diseases": "#7570b3", "Injuries": "#d95f02"}
    for name, causes in LEVEL1_GROUPS.items():
        ax1.plot(yrs, group_asr(causes), color=palette[name], lw=1.7, label=name)
    ax1.set_yscale("log")
    # Extra headroom (about half a decade) so the legend sits above all lines.
    ax1.set_ylim(40, 9000)
    ax1.set_ylabel("Age-standardised deaths / 100,000 (log scale)", fontsize=8.5)
    ax1.set_title("A. All causes and GBD Level-1 groups", fontsize=9.5,
                  fontweight="bold", loc="left")
    ax1.legend(fontsize=7.5, framealpha=0.9, edgecolor="#cccccc",
               loc="upper left", ncol=1)

    # Panel B: respiratory infections & TB with and without COVID-19.
    resp = "Respiratory infections and tuberculosis"
    r_tot = np.array([asr(resp, y) for y in YEARS])
    covid = np.array([asr("COVID-19", y) for y in YEARS])
    ax2.plot(yrs, r_tot, color=RED, lw=1.8, label="Respiratory infections & TB (total, incl. COVID-19)")
    ax2.plot(yrs, r_tot - covid, color=BLUE, lw=1.8, ls="--",
             label="Respiratory infections & TB excluding COVID-19")
    ax2.plot(yrs, covid, color="#555555", lw=1.4, ls="-.", label="COVID-19 alone")
    ax2.set_ylim(0, r_tot.max() * 1.45)
    ax2.set_ylabel("Age-standardised deaths / 100,000", fontsize=8.5)
    ax2.set_title("B. Respiratory infections & TB and COVID-19", fontsize=9.5,
                  fontweight="bold", loc="left")
    ax2.legend(fontsize=7.5, framealpha=0.9, edgecolor="#cccccc", loc="upper left")

    fig.suptitle("Brazil — GBD age-standardised death rates by year, 1990–2023 "
                 "(GBD world standard population)", fontsize=10.5, fontweight="bold")
    fig.savefig(outpath, dpi=150, bbox_inches="tight", format="jpeg",
                pil_kwargs={"quality": 92})
    plt.close(fig)
    print(f"Saved -> {outpath}")


def make_selfharm_figure(outpath):
    """Figure 4: Level-3 components of self-harm and interpersonal violence."""
    series = load_series()
    yrs = np.array([int(y) for y in YEARS])

    def asr(cause, y):
        return series.get((cause, y, "Age-standardized", "Rate"), (0.0,))[0]

    def band(cause):
        v = np.array([series[(cause, y, "Age-standardized", "Rate")] for y in YEARS])
        return v[:, 0], v[:, 1], v[:, 2]

    fig, ax = plt.subplots(figsize=(7.2, 4.4), layout="constrained")
    ax.set_facecolor(GREY_BG)
    ax.axvspan(2019.5, 2022.5, color="#e8e8e8", zorder=0, lw=0)
    ax.axvline(2019, color="#888888", lw=0.8, ls=":", zorder=1)
    ax.grid(axis="y", color="#dddddd", linewidth=0.5, zorder=0)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(labelsize=8)
    ax.set_xlim(1989, 2024)
    ax.set_xlabel("Year", fontsize=8.5)

    styles = {
        SELF_HARM_L2: ("#1a1a1a", "-", 2.0, "Self-harm & interpersonal violence (Level 2 total)"),
        "Interpersonal violence": ("#d95f02", "-", 1.7, "Interpersonal violence"),
        "Self-harm": ("#7570b3", "--", 1.7, "Self-harm"),
        "Police conflict and executions": ("#1b9e77", "-.", 1.7, "Police conflict and executions"),
    }
    for cause, (col, ls, lw, label) in styles.items():
        v, lo, hi = band(cause)
        ax.plot(yrs, v, color=col, ls=ls, lw=lw, label=label, zorder=3)
        ax.fill_between(yrs, lo, hi, color=col, alpha=0.15, lw=0, zorder=2)
    # Conflict and terrorism is omitted from the plot: essentially zero
    # throughout (it is included in the Level-2 total).
    ax.set_yscale("log")
    # Extra headroom so the legend sits above the Level-2 total line.
    ax.set_ylim(0.1, 600)
    ax.set_ylabel("Age-standardised deaths / 100,000 (log scale)", fontsize=8.5)
    ax.legend(fontsize=7.5, framealpha=0.9, edgecolor="#cccccc",
              loc="upper left", ncol=2)
    ax.set_title("Brazil — Self-harm and interpersonal violence and its Level-3 components,\n"
                 "GBD age-standardised death rates by year, 1990–2023 (GBD world standard; shading = 95% UI)",
                 fontsize=9.5, fontweight="bold", loc="left")
    fig.savefig(outpath, dpi=150, bbox_inches="tight", format="jpeg",
                pil_kwargs={"quality": 92})
    plt.close(fig)
    print(f"Saved -> {outpath}")


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
    make_trajectory_figure(os.path.join(FIG_DIR, "fig3_trajectory.jpg"))
    make_selfharm_figure(os.path.join(FIG_DIR, "fig4_selfharm.jpg"))
    print("\nAll figures generated.")
