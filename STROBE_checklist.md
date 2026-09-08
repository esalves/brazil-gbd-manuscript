# STROBE Statement — checklist for cross-sectional studies

Reporting of *"Shifting Mortality Burden in Brazil, 1990–2023: Age-Standardised
Changes Across Cause Categories from the Global Burden of Disease Study 2023."*
Item numbers follow von Elm et al., *Lancet* 2007;370:1453–7. Section/§ numbers
refer to `manuscript.typ`.

| # | STROBE item | Addressed in |
|---|-------------|--------------|
| 1a | Study design indicated in title/abstract | Subtitle ("Descriptive Cross-sectional Analysis"); Abstract and Resumo |
| 1b | Informative, balanced abstract | Abstract and Resumo (Background/Introdução, Methods/Métodos, Results/Resultados, Conclusions/Conclusões) |
| 2 | Background and rationale | §1 Introduction |
| 3 | Objectives / question | §1 Introduction (final paragraph) |
| 4 | Study design | §2 Methods (descriptive cross-sectional; STROBE-reported) |
| 5 | Setting, locations, dates | §2.1 (Brazil; 1990 and 2023; data extracted 4 June, 9 June, and 4 September 2026) |
| 6 | Eligibility / data units | §2.1 (21 of 22 GBD Level-2 causes; sense organs excluded; COVID-19 nested in resp_tb; 25 age groups; both sexes) |
| 7 | Variables | §2.3 (ASRs and % change); §2.4 (95% UIs); §2.5 (premature NCD mortality 30–69); §2.6 (unweighted mean); §2.7 (deaths and crude rates) |
| 8 | Data sources / measurement | §2.1 (IHME GBD 2023 extracts via GBD Compare / Results); §2.2 (GBD framework, SIM inputs, garbage code redistribution, CODEm) |
| 9 | Bias | §2.2 (modelling uncertainty, redistribution); §4.5 (COVID-19 impact); §4.8 (ecological design, endpoint limitations, independence assumptions) |
| 10 | Study size | Full census of available GBD cause categories; no sampling |
| 11 | Quantitative handling | §2.3 (Direct WHO standardisation; 0–4 age band apportionment); §2.5 (discrete life-table approximation); §2.6 (unweighted average) |
| 12a | Statistical methods | §2.3 (direct standardisation formula); §2.4 (Monte Carlo simulation, n = 10,000, deterministic seeding) |
| 12b | Subgroups / interactions | Cause-specific results; age-pattern figures (Figures 1–4, Tables 1–4) |
| 12c | Missing data | §2.1 (sense organ diseases carry no mortality estimate; mental disorders direct mortality near zero) |
| 12d | (Sensitivity / quantitative uncertainty) | §2.4 (Monte Carlo propagation of GBD 95% UIs, 10,000 draws per cause) |
| 13 | Participants / descriptive | §3.1 Overview, Table 1 (all 21 categories, 1990 and 2023) |
| 14 | Descriptive data | Tables 1–4; Figures 1–4 |
| 15 | Outcome data | Table 1 (ASR 1990, ASR 2023, Δ% with 95% UI) |
| 16 | Main results with precision | §3.1 (Overview), Table 1; §3.5 (Causes with greatest reductions); §3.6 (Causes with rising mortality burden) |
| 17 | Other analyses | §3.2 (Level-1 groups); §3.3 (Deaths and crude rates, Table 2); §3.4 (Premature NCD mortality); §3.7 (Agreement with GBD standard and trajectory, Table 3, Figure 3); §3.8 (Level-3 self-harm & interpersonal violence disaggregation, Table 4, Figure 4) |
| 18 | Key results | §4.1 Principal findings |
| 19 | Limitations | §4.8 Strengths and limitations |
| 20 | Interpretation | §4.2–4.7 (Successes, Challenges, Age-standardisation role, COVID-19, Historical trajectory, Policy and SUS priorities) |
| 21 | Generalisability | §4.8 Strengths and limitations (national scope, both sexes combined, lack of subnational resolution) |
| 22 | Funding | Declarations (no external funding received) |

**Reproducibility note.** Every numerical result, table value, and figure
annotation is produced by the open code in `scripts/` from the open data in
`data/`; there are no manual overrides. See `README.md` for the exact commands.
