# Opportunity Convergence — Job Study

A Power BI Desktop project for comparing opportunities across two job-study spreadsheets. The PBIP project keeps the report, semantic model, and Deneb visual specifications in source-control-friendly text files.

## Report pages

1. **Opportunity Landscape** — study-wide overview and opportunity filters.
2. **Skills Convergence** — fit and opportunity comparison.
3. **Salary Spectrum** — recorded entry, mid, and senior compensation ranges, with salary-quality filters and detail rows.

## Screenshots

- [Opportunity Landscape](screenshots/01-opportunity-landscape.jpg)
- [Skills Convergence](screenshots/02-skills-convergence.jpg)
- [Salary Spectrum](screenshots/03-salary-spectrum.jpg)

Screenshots are reference captures from Power BI Desktop. Review their job, fit, and application details before making this repository public.

## Open the project

1. Install Power BI Desktop.
2. Open `Opportunity_Convergence.pbip`.
3. Before refreshing on a new computer, place the two source workbooks in a local folder:
   - `Get a Job - Study 1-100.xlsx`
   - `Get a Job - study 2 100-200.xlsx`
4. In Power BI Desktop, choose **Home → Transform data ▼ → Edit parameters** and set `SourceRoot` to that folder.
5. Choose **Apply changes**, then refresh the model.

The source workbooks are not included. The `SourceRoot` value is intentionally a placeholder so this project does not contain a machine-specific path. Keep personal source workbooks in `data/private/`; that folder is excluded by `.gitignore`.

## Project files

- `Opportunity_Convergence.pbip` — Power BI project entry point.
- `Opportunity_Convergence.Report/` — report page and visual definitions.
- `Opportunity_Convergence.SemanticModel/` — model, measures, parameter, and Power Query source.
- `visual_specs/` — readable Vega-Lite specifications used by the Deneb visuals.
- `Build_Report_Definitions.ps1` — regenerates report visual definitions from `visual_specs/`.
- `screenshots/` — page reference captures.

No license is declared. Add one only if you decide how this work may be reused.
