"""
build_results.py
----------------
Single build step that computes every quantity reported in the manuscript and
writes them, as preformatted display strings, to build/results.json. The Typst
manuscript reads this file (`json("build/results.json")`) so that every table
cell and in-text number is produced by the analysis code rather than typed by
hand.

Run this before compiling the manuscript:

    python scripts/build_results.py
    typst compile manuscript.typ manuscript.pdf

Output keys
-----------
summary          : counts of categories analysed / decreased / increased / reversed
causes           : list (sorted by ASR % change) for Table 1
by_slug          : dict keyed by short slug -> cause record (for in-text lookups)
groups           : GBD Level-1 super-group records
group_by_slug    : dict keyed by cmnn / ncd / injuries / all
table2           : ordered rows for Table 2 (all causes, groups, key causes)
"""

from __future__ import annotations

import json
import os

from analysis_standardised import (
    DATA_DIR,
    LEVEL1_GROUPS,
    compute_all,
    group_change,
    load_data,
)
from analysis_counts import load_counts

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD_DIR = os.path.join(BASE_DIR, "build")

MINUS = "−"  # U+2212 minus sign, matching the manuscript typography

# Short slugs (stable identifiers used in the Typst source) and table labels.
SHORT_SLUG = {
    "HIV/AIDS and sexually transmitted infections": "hiv",
    "Respiratory infections and tuberculosis": "resp_tb",
    "Enteric infections": "enteric",
    "Neglected tropical diseases and malaria": "ntd",
    "Other infectious diseases": "other_inf",
    "Maternal and neonatal disorders": "maternal",
    "Nutritional deficiencies": "nutritional",
    "Neoplasms": "neoplasms",
    "Cardiovascular diseases": "cvd",
    "Chronic respiratory diseases": "chronic_resp",
    "Digestive diseases": "digestive",
    "Neurological disorders": "neuro",
    "Mental disorders": "mental",
    "Substance use disorders": "substance",
    "Diabetes and kidney diseases": "diabetes",
    "Skin and subcutaneous diseases": "skin",
    "Musculoskeletal disorders": "musculo",
    "Other non-communicable diseases": "other_ncd",
    "Transport injuries": "transport",
    "Unintentional injuries": "unintentional",
    "Self-harm and interpersonal violence": "self_harm",
}

TABLE_NAME = {
    "Neglected tropical diseases and malaria": "Neglected tropical diseases & malaria",
    "Maternal and neonatal disorders": "Maternal & neonatal disorders",
    "Respiratory infections and tuberculosis": "Respiratory infections & tuberculosis",
    "Diabetes and kidney diseases": "Diabetes & kidney diseases",
    "Self-harm and interpersonal violence": "Self-harm & interpersonal violence",
    "HIV/AIDS and sexually transmitted infections": "HIV/AIDS & sexually transmitted infections",
    "Skin and subcutaneous diseases": "Skin & subcutaneous diseases",
}

GROUP_SLUG = {
    "Communicable, maternal, neonatal & nutritional": "cmnn",
    "Non-communicable diseases": "ncd",
    "Injuries": "injuries",
}


# ── Number formatting (one source of rounding) ───────────────────────────────
def s1(x: float) -> str:
    return f"{'+' if x >= 0 else MINUS}{abs(x):.1f}"


def s0(x: float) -> str:
    return f"{'+' if x >= 0 else MINUS}{abs(x):.0f}"


def p1(x: float) -> str:
    return s1(x) + "%"


def p0(x: float) -> str:
    return s0(x) + "%"


def f1(x: float) -> str:
    return "<0.01" if round(x, 1) == 0.0 else f"{x:.1f}"


def thou(n: float) -> str:
    return f"{round(n):,}"


# ── Build ────────────────────────────────────────────────────────────────────
def main() -> None:
    d90 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data1990.csv"))
    d23 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data2023.csv"))
    counts = load_counts()

    asr = compute_all(d90, d23)  # sorted by std_pct

    def deaths(cause, year):
        return counts.get((cause, year, "Number"))

    def crude_pct(cause):
        r90 = counts.get((cause, "1990", "Rate"))
        r23 = counts.get((cause, "2023", "Rate"))
        return (r23 - r90) / r90 * 100.0 if r90 else None

    def deaths_pct(cause):
        n90, n23 = deaths(cause, "1990"), deaths(cause, "2023")
        return (n23 - n90) / n90 * 100.0 if n90 else None

    causes, by_slug = [], {}
    for r in asr:
        c = r["cause"]
        discordant = (r["mean_pct"] > 0) != (r["std_pct"] > 0)
        rec = {
            "slug": SHORT_SLUG[c],
            "name": c,
            "name_short": TABLE_NAME.get(c, c),
            "asr90": f1(r["asr_1990"]),
            "asr23": f1(r["asr_2023"]),
            "asr_pct": p1(r["std_pct"]),
            "asr_ci": f"{p1(r['std_lo'])} to {p1(r['std_hi'])}",
            "asr_pct_ci_tbl": f"{s1(r['std_pct'])} ({s1(r['std_lo'])}, {s1(r['std_hi'])})",
            "mean_pct": p1(r["mean_pct"]),
            "mean_pct_tbl": s1(r["mean_pct"]),
            "discordant": discordant,
            "sup": "a" if SHORT_SLUG[c] == "mental" else "",
        }
        if deaths(c, "1990") is not None:
            rec |= {
                "deaths90": thou(deaths(c, "1990")),
                "deaths23": thou(deaths(c, "2023")),
                "deaths_pct": p0(deaths_pct(c)),
                "crude_pct": p1(crude_pct(c)),
            }
        causes.append(rec)
        by_slug[SHORT_SLUG[c]] = rec

    # GBD Level-1 groups + all causes
    groups, group_by_slug = [], {}
    everything = [c for cs in LEVEL1_GROUPS.values() for c in cs]
    group_defs = list(LEVEL1_GROUPS.items()) + [("All causes", everything)]
    for name, cs in group_defs:
        g = group_change(cs, d90, d23)
        n90 = sum(deaths(c, "1990") for c in cs)
        n23 = sum(deaths(c, "2023") for c in cs)
        r90 = sum(counts[(c, "1990", "Rate")] for c in cs)
        r23 = sum(counts[(c, "2023", "Rate")] for c in cs)
        slug = "all" if name == "All causes" else GROUP_SLUG[name]
        rec = {
            "slug": slug, "name": name,
            "asr90": f1(g["asr_1990"]), "asr23": f1(g["asr_2023"]),
            "asr_pct": p1(g["std_pct"]),
            "asr_ci": f"{p1(g['std_lo'])} to {p1(g['std_hi'])}",
            "deaths90": thou(n90), "deaths23": thou(n23),
            "deaths_pct": p0((n23 - n90) / n90 * 100.0),
            "crude_pct": p1((r23 - r90) / r90 * 100.0),
        }
        if name != "All causes":
            groups.append(rec)
        group_by_slug[slug] = rec

    # Table 2 rows: all causes, three groups, then key reversal causes.
    def t2_from_group(slug, bold=False):
        g = group_by_slug[slug]
        return {"name": g["name"], "bold": bold,
                "deaths90": g["deaths90"], "deaths23": g["deaths23"],
                "dn": g["deaths_pct"], "dc": g["crude_pct"], "da": g["asr_pct"]}

    def t2_from_cause(slug):
        c = by_slug[slug]
        return {"name": c["name_short"], "bold": False,
                "deaths90": c["deaths90"], "deaths23": c["deaths23"],
                "dn": c["deaths_pct"], "dc": c["crude_pct"], "da": c["asr_pct"]}

    table2 = [
        t2_from_group("all", bold=True),
        t2_from_group("cmnn"), t2_from_group("ncd"), t2_from_group("injuries"),
        t2_from_cause("cvd"), t2_from_cause("neoplasms"),
        t2_from_cause("diabetes"), t2_from_cause("unintentional"),
    ]

    n_dec = sum(1 for r in asr if r["std_pct"] < 0)
    n_inc = sum(1 for r in asr if r["std_pct"] > 0)
    n_rev = sum(1 for r in asr if (r["mean_pct"] > 0) != (r["std_pct"] > 0))

    out = {
        "summary": {"n_causes": len(asr), "n_decreased": n_dec,
                    "n_increased": n_inc, "n_reversed": n_rev},
        "causes": causes,
        "by_slug": by_slug,
        "groups": groups,
        "group_by_slug": group_by_slug,
        "table2": table2,
    }

    os.makedirs(BUILD_DIR, exist_ok=True)
    path = os.path.join(BUILD_DIR, "results.json")
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, ensure_ascii=False, indent=2)
    print(f"Wrote {path}")
    print(f"  {len(causes)} causes, {len(groups)} groups, "
          f"{len(table2)} Table 2 rows")


if __name__ == "__main__":
    main()
