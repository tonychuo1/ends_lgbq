# The effects of e-cigarette and cigarette policies on queer youth

This repository hosts replication code files for the _Journal of Health Economics_ article
"[The effects of e-cigarette and cigarette policies on queer youth](https://doi.org/10.1016/j.jhealeco.2026.103116)" by Tony Chuo,
Charles Courtemanche, Erik Nesson, Chad Cotti, Johanna Catherine Maclean, and Joseph J. Sabia.

## Notes

This analysis uses the state-administered Youth Risk Behavior Surveillance
System (YRBS) data from the CDC.
The exact analytic YRBS dataset we use in this project cannot be shared publicly:
the state-administered survey file has been constructed
by harmonizing files (for the 2021 survey wave) 
provided privately by state health departments
and files publicly available on the CDC's [YRBS webpage](https://www.cdc.gov/yrbs/data/index.html) (under the name "Combined high school").
However, a near exact replica can be constructed by (1) downloading the 1991-2019, 1991-2021, and 1991-2023 Combined high school files, 
(2) keeping only the 2021 survey wave data from the 1991-2021 file and only the 2023 survey wave data from the 1991-2023 file, 
(3) appending the three files together. 
This procedure is needed because the question language regarding sexual orientation changed between 2019 and 2021, 
and (to the best of our knowledge) CDC’s public files post-2021 treat sexual orientation information as missing for those earlier years. 

Further, the exact semester in which state health departments
administer their YRBS survey (which we use to link the survey to our policy control file) is available only through contacting the CDC
privately. Auxiliary analysis combines the state- and nationally-administered YRBS data, and
national YRBS data that contains state-level identifiers require permission from the CDC to access.
The project's analysis code is provided in its entirety to allow replication by those with access to the underlying data.

Data files related to policy impacts among adults using
Behavioral Risk Factor Surveillance System (BRFSS) have not
been provided due to file size limitations. The exact BRFSS survey data are publicly
accessible through the CDC's [BRFSS webpage](https://www.cdc.gov/brfss/annual_data/annual_data.htm); contact us if interested in the code we have used to clean these "raw" files.

And for those interested in the exact policy control dataset we use for the project, please contact Tony Chuo (agc3823@my.utexas.edu).

## Replication instructions

For replications to correctly match the project's file setup,
clone this GitHub repository into the `${path_cheps_google}/projects/` directory
on your machine. This can be any location on your machine whose parent folder is named `projects` (for example `Desktop/projects`, `C:/Users/user1/economics/projects`, `G:/My Drive/jhe_replication/projects` are all valid). `${path_cheps_google}` just references the Stata macro that stores
the root directory's location throughout the project code.

After cloning the repository, unzipping files, and creating the necessary folders, your directory should look like this:

<details open>

<summary>Directory schematic </summary>

```
${path_cheps_google}
 ┣ projects
 ┃ ┗ ends_lgbq
 ┃   ┣ data
 ┃   ┃ ┣ final
 ┃   ┃ ┣ inter
 ┃   ┃ ┗ raw
 ┃   ┃   ┗ map
 ┃   ┃     ┣ stateUS_bound.dta
 ┃   ┃     ┗ stateUS_coord.dta
 ┃   ┣ do
 ┃   ┃ ┣ 00_master.do
 ┃   ┃ ┣ 01_clean_yrbs_2023.do
 ┃   ┃ ┣ 02_clean_master_2023.do
 ┃   ┃ ┣ 03_reg_main.do
 ┃   ┃ ┣ 04_figures.do
 ┃   ┃ ┣ 04_tables.do
 ┃   ┃ ┗ README.md
 ┃   ┣ log
 ┃   ┃ ┣ estimates
 ┃   ┃ ┗ regressions
 ┃   ┗ output
 ┃     ┗ etax
 ┃       ┣ figures
 ┃       ┃ ┣ final
 ┃       ┃ ┗ inter
 ┃       ┗ graphs
 ┃         ┣ final
 ┃         ┗ inter
 ┗ datasets
   ┣ brfss
   ┃ ┗ data
   ┃   ┗ final
   ┃     ┗ BRFSS_2011to2023.dta
   ┣ cheps_controls
   ┃ ┗ data
   ┃   ┗ final
   ┃     ┗ cheps_master_controls_2000to2023_11-11-24.dta
   ┣ map_lgbtq
   ┃ ┗ data
   ┃   ┗ clean
   ┃     ┗ policy_tally.dta
   ┗ yrbs
     ┗ data
       ┣ clean
       ┃ ┗ stateyrbs_timing_output.dta
       ┗ final
         ┗ YRBS_combined_2003-2023.dta
```

</details>

As noted above, we do not provide `YRBS_combined_2003-2023.dta`, `BRFSS_2011to2023.dta`, `cheps_master_controls_2000to2023_11-11-24.dta`, and
`stateyrbs_timing_output.dta`.
This repository's `/zip/` subfolder does include compressed versions of
`stateUS_bound.dta`, `stateUS_coord.dta`, and `policy_tally.dta`.
Place these three files in their corresponding directory location once they've been unzipped. Again, for questions regarding data access, please contact Tony Chuo.

Within the `projects/ends_lgbq/` subfolder, `00_master.do`
is a "meta-script" that is used to execute
all the project's other scripts from one place.
Those scripts perform tasks related to their file name:
`01_clean_yrbs_2023.do` generates the project's relevant outcome variables
from the YRBS survey file; `02_clean_master_2023.do` prepares our
state-level policy controls file before merging it together with the
YRBS data to create our "final" `master_set_2023.dta` and combines
the BRFSS data with control to generate `brfss_master_set_2023.dta`;
`03_reg_main.do` estimates most all of the regressions for the project,
saving them as `.sters` files; `04_figures.do` creates the trend lines, maps,
heterogeneity figures, and estimates and creates event study figures; and
`04_tables.do` tabulates summary statistics and regression results.

From this setup, the scripts inside the `/ends_lgbq/do/` subfolder should be able to populate everything else related to the project.
Notice also that the `output/etax/figures/` subfolder refers to _tabulated results_ and the `output/etax/graphs/`
subfolder refers to .png type visualization files. We understand the project's file architecture may leave
a bit to be desired in terms of efficiency, but we have focused on a well-understood workflow that can be replicated.

### Stata

The project was written using Stata 15.1 MP, but the code should be
executable on other Stata versions too.

We use various user-written packages that must be installed
by running `ssc install <package_name>` in Stata. These packages
include: `coefplot`, `estout`, `esttab`, `gtools`, `lassopack`, `reghdfe`, `spmap`, and `xlincom`
(please let me know if there are others I haven't included).
