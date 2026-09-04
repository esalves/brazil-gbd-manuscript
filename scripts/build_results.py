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
premature        : probability of death at 30-69 from the four major NCD groups
validation       : Level-2 sum == GBD all-cause check (exhaustiveness)
allcause, covid  : GBD annual all-cause series and COVID-19 placement/counts
gbd, table3      : comparison of WHO-standard changes with GBD's own ASRs
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
    premature_ncd_probability,
)
from analysis_counts import load_counts
from gbd_series import load_series, level2_causes, asr as gbd_asr, deaths as gbd_deaths

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
    if round(x) == 0:          # avoid a signed zero such as "−0"
        return "0"
    return f"{'+' if x >= 0 else MINUS}{abs(x):.0f}"


NUM_WORDS = ["zero", "one", "two", "three", "four", "five", "six", "seven",
             "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen",
             "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty",
             "twenty-one", "twenty-two", "twenty-three"]


def word(n: int) -> str:
    """Spell out small counts so sentences never start with a numeral."""
    return NUM_WORDS[n] if 0 <= n < len(NUM_WORDS) else str(n)


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
        spans_zero = r["std_lo"] < 0 < r["std_hi"]
        rec = {
            "spans_zero": spans_zero,
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
        # The "all causes" aggregate is the sum of the extracted Level-2
        # categories; the build validates that it equals GBD's all-cause total.
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
    # Uncertainty-aware classification: a change counts as a decrease or an
    # increase only when its 95% interval excludes zero.
    n_dec_sig = sum(1 for r in asr if r["std_hi"] < 0)
    n_inc_sig = sum(1 for r in asr if r["std_lo"] > 0)
    indeterminate = [TABLE_NAME.get(r["cause"], r["cause"]).lower()
                     for r in asr if r["std_lo"] < 0 < r["std_hi"]]
    n_ind = len(indeterminate)

    # Premature NCD mortality (probability of death at ages 30-69).
    pn = premature_ncd_probability(d90, d23)
    premature = {
        "p90": f"{pn['p_1990']:.1f}%", "p23": f"{pn['p_2023']:.1f}%",
        "p90_ci": f"{pn['p90_lo']:.1f}% to {pn['p90_hi']:.1f}%",
        "p23_ci": f"{pn['p23_lo']:.1f}% to {pn['p23_hi']:.1f}%",
        "pct": p1(pn["pct"]),
        "ci": f"{p1(pn['pct_lo'])} to {p1(pn['pct_hi'])}",
    }

    # ── GBD annual series: exhaustiveness check, COVID-19 placement, external
    #    validation against GBD's own age-standardised rates, trajectory ──────
    series = load_series()
    l2 = level2_causes(series)
    allcause = {(y, m): series[("All causes", y, "All ages", m)][0]
                for y in (str(yy) for yy in range(1990, 2024)) for m in ("Number", "Rate")}

    # Exhaustiveness: sum of Level-2 categories == GBD all causes, every year,
    # deaths and crude rate (COVID-19 is NOT added: it is nested in Level 2).
    validation = {"exhaustive": True, "max_abs_diff_deaths": 0.0}
    for y in (str(yy) for yy in range(1990, 2024)):
        for m in ("Number", "Rate"):
            l2_sum = sum(series[(c, y, "All ages", m)][0] for c in l2)
            diff = l2_sum - allcause[(y, m)]
            if m == "Number":
                validation["max_abs_diff_deaths"] = max(validation["max_abs_diff_deaths"], abs(diff))
            if abs(diff) > (0.5 if m == "Number" else 0.01):
                validation["exhaustive"] = False
                print(f"WARNING: Level-2 sum != GBD all-cause for {y} {m}: {diff:+.3f}")
    validation["max_abs_diff_deaths"] = f"{validation['max_abs_diff_deaths']:.3f}"
    # Cross-check the 1990/2023 counts extract against the series extract.
    for y in ("1990", "2023"):
        for c in l2:
            assert abs(counts[(c, y, "Number")] - gbd_deaths(series, c, y)) < 0.5, (c, y)

    def d(y):
        return allcause[(y, "Number")]
    allcause_rec = {
        **{f"d{y}": thou(d(y)) for y in ("2018", "2019", "2020", "2021", "2022", "2023")},
        **{f"crude{y}": f"{allcause[(y, 'Rate')]:.1f}" for y in ("2019", "2021", "2023")},
        "excess2020": thou(d("2020") - d("2019")),
        "excess2021": thou(d("2021") - d("2019")),
        "excess2022": thou(d("2022") - d("2019")),
        "excess2023": thou(d("2023") - d("2019")),
        "excess2023_pct": p0((d("2023") - d("2019")) / d("2019") * 100.0),
    }

    # COVID-19: nested under respiratory infections and tuberculosis. The
    # 2019->2021 jump in that category should equal COVID-19 deaths in 2021
    # up to the change in the other members of the category.
    RESP = "Respiratory infections and tuberculosis"
    cov = {y: gbd_deaths(series, "COVID-19", y) for y in ("2020", "2021", "2022", "2023")}
    resp = {y: gbd_deaths(series, RESP, y) for y in ("2019", "2020", "2021", "2022", "2023")}
    covid_rec = {
        **{f"deaths{y}": thou(v) for y, v in cov.items()},
        "deaths_total": thou(sum(cov.values())),
        "resp2019": thou(resp["2019"]), "resp2021": thou(resp["2021"]),
        "resp2023": thou(resp["2023"]),
        "resp2023_excl": thou(resp["2023"] - cov["2023"]),
        "resp2023_excl_vs2019_pct": p0((resp["2023"] - cov["2023"] - resp["2019"]) / resp["2019"] * 100.0),
        "share_resp2023": f"{cov['2023'] / resp['2023'] * 100:.0f}%",
        "resp_jump2021": thou(resp["2021"] - resp["2019"]),
        "resp_asr2019": f"{gbd_asr(series, RESP, '2019'):.1f}",
        "resp_asr2023": f"{gbd_asr(series, RESP, '2023'):.1f}",
        "covid_asr2023": f"{gbd_asr(series, 'COVID-19', '2023'):.1f}",
    }

    # External validation: GBD's own age-standardised % change vs ours (WHO).
    def ours_pct(c):
        return float(by_slug[SHORT_SLUG[c]]["asr_pct"].replace(MINUS, "-").replace("%", ""))

    YRS = ("1990", "2000", "2010", "2019", "2023")
    gbd_rows, diffs, agree = [], [], 0
    order = [r["cause"] for r in asr]  # same order as Table 1
    for c in order:
        g90, g23 = gbd_asr(series, c, "1990"), gbd_asr(series, c, "2023")
        gpct = (g23 - g90) / g90 * 100.0
        opct = ours_pct(c)
        diffs.append(abs(gpct - opct))
        agree += (gpct > 0) == (opct > 0)
        gbd_rows.append({
            "name": TABLE_NAME.get(c, c), "bold": False,
            **{f"a{y}": f1(gbd_asr(series, c, y)) for y in YRS},
            "gbd_pct": s1(gpct), "who_pct": by_slug[SHORT_SLUG[c]]["asr_pct"].replace("%", ""),
        })
    ga90, ga23 = gbd_asr(series, "All causes", "1990"), gbd_asr(series, "All causes", "2023")
    gall = (ga23 - ga90) / ga90 * 100.0
    all_row = {"name": "All causes", "bold": True,
               **{f"a{y}": f1(gbd_asr(series, "All causes", y)) for y in YRS},
               "gbd_pct": s1(gall),
               "who_pct": group_by_slug["all"]["asr_pct"].replace("%", "")}
    ga = {y: gbd_asr(series, "All causes", y) for y in (str(yy) for yy in range(1990, 2024))}
    peak_year = max(ga, key=ga.get) if max(ga.values()) > ga["1990"] else max((y for y in ga if int(y) >= 2019), key=ga.get)
    gbd_summary = {
        "max_abs_diff": f"{max(diffs):.1f}",
        "max_abs_diff_cause": TABLE_NAME.get(order[diffs.index(max(diffs))], order[diffs.index(max(diffs))]).lower(),
        "n_agree": agree, "n_total": len(order), "all_agree": agree == len(order),
        "all_pct": p1(gall), "all_asr1990": f1(ga90), "all_asr2019": f1(ga["2019"]),
        "all_asr2021": f1(ga["2021"]), "all_asr2023": f1(ga23),
        "pandemic_peak_year": peak_year,
        "all_2023_vs_2019_pct": p1((ga23 - ga["2019"]) / ga["2019"] * 100.0),
        "all_1990_2019_pct": p1((ga["2019"] - ga90) / ga90 * 100.0),
        "skin_asr": {y: f1(gbd_asr(series, "Skin and subcutaneous diseases", y)) for y in YRS},
        "unint_asr2010": f1(gbd_asr(series, "Unintentional injuries", "2010")),
        "unint_asr2019": f1(gbd_asr(series, "Unintentional injuries", "2019")),
        "unint_asr2023": f1(gbd_asr(series, "Unintentional injuries", "2023")),
    }
    table3 = [all_row] + gbd_rows

    def join_words(items):
        return items[0] if len(items) == 1 else ", ".join(items[:-1]) + ", and " + items[-1]

    out = {
        "summary": {"n_causes": len(asr), "n_decreased": n_dec,
                    "n_increased": n_inc, "n_reversed": n_rev,
                    "n_decreased_sig": n_dec_sig, "n_increased_sig": n_inc_sig,
                    "n_indeterminate": n_ind,
                    "indeterminate_list": join_words(indeterminate),
                    # spelled-out versions for sentence-initial use
                    "w_causes": word(len(asr)), "w_decreased": word(n_dec),
                    "w_increased": word(n_inc), "w_reversed": word(n_rev),
                    "w_decreased_sig": word(n_dec_sig),
                    "w_increased_sig": word(n_inc_sig),
                    "w_indeterminate": word(n_ind),
                    "W_reversed": word(n_rev).capitalize(),
                    "W_indeterminate": word(n_ind).capitalize()},
        "premature": premature,
        "validation": validation,
        "allcause": allcause_rec,
        "covid": covid_rec,
        "gbd": gbd_summary,
        "table3": table3,
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
