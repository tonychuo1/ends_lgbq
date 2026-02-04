//
// (00): master script for "The Effects of E-Cigarette and Cigarette Policies on Queer Youth" project
//

// please contact Tony Chuo for questions related to the project's code (agc3823@my.utexas.edu)
// the code was written using VSCode and is easiest to read if all code chunks are "folded" when opening files (Ctrl+K, Ctrl+0 on Windows VSCode) 

// for replication, uncomment the below commands and set globals ${path_cheps_google} and ${path_cheps_system} to the SAME PARENT FOLDER
// the two are separated here because we have stored our code and data on separate drives for storage optimization purposes


// global path_cheps_google "<path/to/machine/location>"
// global path_cheps_system "<path/to/machine/location>"


cd "${path_cheps_google}/projects/ends_lgbq"
version 15.1

global stars star(* 0.1 ** 0.05 *** 0.01) 

// execute all other .do files by running this code chunk 
if 1 {
    do "${path_cheps_system}/projects/ends_lgbq/do/01_clean_yrbs_2023.do"
    do "${path_cheps_system}/projects/ends_lgbq/do/02_clean_master_2023.do"

    do "${path_cheps_system}/projects/ends_lgbq/do/03_reg_main.do"

    do "${path_cheps_system}/projects/ends_lgbq/do/04_figures.do"
    do "${path_cheps_system}/projects/ends_lgbq/do/04_tables.do"
}

// space for VSCode