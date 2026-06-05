"""
analysis.py
-----------
Reproduces summary statistics for:
"Shifting Mortality Burden in Brazil: Age-Specific Trends Across Cause
Categories from the Global Burden of Disease Study 2023"

Usage:
    python scripts/analysis.py

Outputs a summary table to stdout.
"""

import csv
import os

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")

AGE_ORDER = [
    "0-6 days", "7-27 days", "1-5 months", "6-11 months", "12-23 months",
    "2-4 years", "5-9 years", "10-14 years", "15-19 years", "20-24 years",
    "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years",
    "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70-74 years",
    "75-79 years", "80-84 years", "85-89 years", "90-94 years", "95+ years",
]


def load_data(filepath: str) -> dict[str, list[float]]:
    """Load CSV and return {cause: [values across age groups]}."""
    data: dict[str, list[float]] = {}
    with open(filepath, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            cause = (row.get("Cause of death or injury") or "").strip()
            val_str = (row.get("Value") or "").strip()
            if cause and val_str:
                try:
                    data.setdefault(cause, []).append(float(val_str))
                except ValueError:
                    pass
    return data


def mean_rate(values: list[float]) -> float:
    return sum(values) / len(values) if values else 0.0


def pct_change(old: float, new: float) -> float:
    return (new - old) / old * 100 if old else float("nan")


def main():
    rates_1990 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data1990.csv"))
    rates_2023 = load_data(os.path.join(DATA_DIR, "GBD_Compare_Data2023.csv"))

    all_causes = sorted(set(rates_1990) | set(rates_2023))

    results = []
    for cause in all_causes:
        r90 = mean_rate(rates_1990.get(cause, []))
        r23 = mean_rate(rates_2023.get(cause, []))
        pct = pct_change(r90, r23)
        results.append((cause, r90, r23, pct))

    # Sort by % change
    results.sort(key=lambda x: x[3])

    header = f"{'Cause':<52} {'Mean 1990':>10} {'Mean 2023':>10} {'% Change':>10}"
    print(header)
    print("-" * len(header))
    for cause, r90, r23, pct in results:
        sign = "+" if pct >= 0 else ""
        print(f"{cause:<52} {r90:>10.1f} {r23:>10.1f} {sign}{pct:>9.1f}%")

    print(f"\nTotal causes analysed: {len(results)}")
    decreased = [r for r in results if r[3] < 0]
    increased = [r for r in results if r[3] > 0]
    print(f"Causes with decreased mortality burden: {len(decreased)}")
    print(f"Causes with increased mortality burden: {len(increased)}")


if __name__ == "__main__":
    main()
