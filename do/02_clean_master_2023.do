//
// (02): clean up control file and merge with YRBS to get final analytic dataset "master_set_2023.dta"
//

clear all
eststo clear
set more off
cap log close


// clean control file
{
	// pull control file
	use "${path_cheps_google}/datasets/cheps_controls/data/final/cheps_master_controls_2000to2023_11-11-24", clear
	rename (flavor menthol) (flavor_ban menthol_ban)

	drop if year==2024

	label var ends_tax_nom35_jcm    "Nominal ENDS tax, 35% retailer mark-up (old version)"
	label var ends_tax_nom35_closed "Nominal ENDS tax, 35% retailer mark-up (closed devices)"
	label var ends_tax_nom35_open   "Nominal ENDS tax, 35% retailer mark-up (open devices)"

	// closed system tax is our main independent variable
	rename ends_tax_nom35_closed ends_tax_nom35 

	// use cumulative death rate as main covid variable
	gen       coviddeaths = covid_deaths_cu_rate
	label var coviddeaths "Population-scaled current cumulative covid deaths within state"

	rename ecigs_lis_req_num ecigs_lis_require_num

	// license Laws
	gen       tobacco_lis_law2 = tobacco_lis_require_num & tobacco_renew_req_num & (tobacco_min_lis_fee_num>=50)
	label var tobacco_lis_law2 "Strong tobacco Licensure Law"
	gen       tobacco_lis_law1 = tobacco_lis_require_num & (tobacco_renew_req_num | (tobacco_min_lis_fee_num>=50)) & !(tobacco_renew_req_num & (tobacco_min_lis_fee_num>=50))
	label var tobacco_lis_law1 "Weak tobacco Licensure Law"

	gen       ecigs_lis_law2 = ecigs_lis_require_num & ecigs_renewal & (ecigs_min_lic_fee>=50)
	label var ecigs_lis_law2 "Strong ecigs Licensure Law"
	gen       ecigs_lis_law1 = ecigs_lis_require_num & (ecigs_renewal | (ecigs_min_lic_fee>=50)) & !(ecigs_renewal & (ecigs_min_lic_fee>=50))
	label var ecigs_lis_law1 "Weak ecigs Licensure Law"



	// create variables for any licensure law
	gen       ecigs_lis_law_any = 0
	replace   ecigs_lis_law_any = 1 if ecigs_lis_require_num == 1
	label var ecigs_lis_law_any "Presence of any e-cigarette licensure law"

	gen       tobacco_lis_law_any = 0
	replace   tobacco_lis_law_any = 1 if tobacco_lis_require_num == 1
	label var tobacco_lis_law_any "Presence of any tobacco licensure law"


	// create variables for ANY indoor air law
	gen       indoor_ban_vape = 0
	replace   indoor_ban_vape = 1 if (work_vape_ban == 1 | bar_vape_ban == 1 | rest_vape_ban == 1)
	label var indoor_ban_vape "Presence of any indoor vaping ban"

	gen       indoor_ban_smoke = 0
	replace   indoor_ban_smoke = 1 if (work_smoke_ban == 1 | bar_smoke_ban == 1 | rest_smoke_ban == 1)
	label var indoor_ban_smoke "Presence of any indoor smoking ban"

	* Create macros for variable groups
	global ecig_policy any_mlsa_vape t21 ends_tax_nom35 ecigs_lis_law1 ecigs_lis_law2 ecigs_lis_law_any ///
	work_vape_ban rest_vape_ban bar_vape_ban ecigban flavor_ban ends_tax_nom35_open ends_tax_nom35_jcm  ///
	ecigs_lic_weak ecigs_lic_moderate ecigs_lic_strong indoor_ban_vape

	global combust_policy cigarette_tax work_smoke_ban rest_smoke_ban ///
	bar_smoke_ban tobacban tobacco_lis_law1 tobacco_lis_law2 tobacco_lis_law_any menthol_ban indoor_ban_smoke

	global substance_policy beer_tax RML MML DML pdmp_must samaritan_drug ///
	samaritan_alc naloxone

	global econ_control uer pcinc

	global welfare_control minimum_wage eitc snap4 ACAexp_new tanf4

	global model_vars $ecig_policy $combust_policy $substance_policy $econ_control ///
	$welfare_control covid* governmentresponseindex containmenthealthindex ///
	stringencyindex economicsupportindex populationvaccinated
}


keep state_fips-semester povertyrate $model_vars cpi ///
/* tobacco_lis_require_num tobacco_renew_req_num  tobacco_min_lis_fee_num  ///
ecigs_lis_require_num ecigs_renew_req_num ecigs_min_lis_fee_num */

drop if year < 2009 
// as of now, don't need earlier dates & there are issues with merge pre-2006					
	

// convert all nominal vars to 2023/2021 dollars
{
	// 2023 dollars
	{
		local CPI2023 = 304.7008
		gen cpi_2023 = cpi/`CPI2023' 
		
		// closed devices
		gen       ends_tax_nom35_scale = ends_tax_nom35 / cpi_2023
		label var ends_tax_nom35_scale "ENDS Tax, 35% retailer markup (closed devices), 2023 $"

		// open devices
		gen       ends_tax_nom35_open_scale = ends_tax_nom35_open / cpi_2023
		label var ends_tax_nom35_open_scale "ENDS Tax, 35% retailer markup (open devices), 2023 $"

		// older measure
		gen       ends_tax_nom35_jcm_scale = ends_tax_nom35_jcm / cpi_2023
		label var ends_tax_nom35_jcm_scale "ENDS Tax, 35% retailer markup (old version), 2023 $"
		
		gen       cigarette_tax_scale = cigarette_tax / cpi_2023
		label var cigarette_tax_scale "Cig Tax, 2023 $"

		gen       pcinc_scale = pcinc / cpi_2023
		label var pcinc_scale "Per-Capita Personal Income, 2023 $"
		
		gen       minimum_wage_scale = minimum_wage / cpi_2023
		label var minimum_wage_scale "Quarterly State Average, 2023 $"
		
		gen       beer_tax_scale = beer_tax / cpi_2023
		label var beer_tax_scale "Beer Tax, 2023 $"
		
		gen       snap4_scale = snap4 / cpi_2023
		label var snap4_scale "FS/SNAP Benefit for 4-person family, 2023 $"
		
		gen       tanf4_scale = tanf4 / cpi_2023
		label var tanf4_scale "TANF maximum monthly benefit for 4-person family, 2023 $"
	}

	// 2021 dollars
	{
		local CPI2021 = 270.97101
   		gen cpi_2021 = cpi/`CPI2021' 

		// closed devices
		gen       ends_tax_nom35_scale1 = ends_tax_nom35 / cpi_2021
		label var ends_tax_nom35_scale1 "ENDS Tax, 35% retailer markup (closed devices), 2021 $"

		// open devices
		gen       ends_tax_nom35_open_scale1 = ends_tax_nom35_open / cpi_2021
		label var ends_tax_nom35_open_scale1 "ENDS Tax, 35% retailer markup (open devices), 2021 $"

		// older measure
		gen       ends_tax_nom35_jcm_scale1 = ends_tax_nom35_jcm / cpi_2021
		label var ends_tax_nom35_jcm_scale1 "ENDS Tax, 35% retailer markup (old version), 2021 $"
		
		gen       cigarette_tax_scale1 = cigarette_tax / cpi_2021
		label var cigarette_tax_scale1 "Cig Tax, 2021 $"

		gen       pcinc_scale1 = pcinc / cpi_2021
		label var pcinc_scale1 "Per-Capita Personal Income, 2021 $"
		
		gen       minimum_wage_scale1 = minimum_wage / cpi_2021
		label var minimum_wage_scale1 "Quarterly State Average, 2021 $"
		
		gen       beer_tax_scale1 = beer_tax / cpi_2021
		label var beer_tax_scale1 "Beer Tax, 2021 $"
		
		gen       snap4_scale1 = snap4 / cpi_2021
		label var snap4_scale1 "FS/SNAP Benefit for 4-person family, 2021 $"
		
		gen       tanf4_scale1 = tanf4 / cpi_2021
		label var tanf4_scale1 "TANF maximum monthly benefit for 4-person family, 2021 $"
	}
}


// collapse down to semester level
gcollapse (mean) pcinc-tanf4_scale1, ///
by(state_fips state_name year semester) labelformat(#sourcelabel#)


// merge endstax introduction
{
	preserve

	cap drop etax_intro
	gen etax_intro = yh(year, semester)
	format etax_intro %th

	collapse (min) etax_intro if ends_tax_nom35_scale>0 , by(state_fips)

	tempfile etax_intro
	save    `etax_intro'

	restore

	merge m:1 state_fips using `etax_intro'
	drop _merge
} 


// drop earlier years and rename vars
drop if year < 2010
rename state_fips fips // same name for merge below
rename year year_true

// generate logged econ variables
gen log_uer     = ln(uer)
gen log_povrate = ln(povertyrate)

// 2023,2022 good samaritan law = 2021 good samaritan law (except Maine)
{
	foreach var in samaritan_alc samaritan_drug {
		carryforward `var', replace
	}

	// Maine has 8/8/2022 alcohol extension
	replace samaritan_alc = 1 if year_true==2023 & fips==23
	replace samaritan_alc = ///
	(date("12/31/2022","MDY") - date("8/8/2022","MDY")) / ///
	(date("12/31/2022","MDY") - date("7/1/2022","MDY"))   ///
	if year_true==2022 & semester==2 & fips==23
}

// create quartiles of Covid vars
{
	// v1: 3 quartiles for 2020-2023 observations (with pre-2020 set to 0)
	local num_quan 3
	local varlist covid_cases_cu_rate covid_deaths_cu_rate governmentresponseindex populationvaccinated stringencyindex
	
	foreach var of local varlist {
		xtile   `var'_q`num_quan' = `var' if inrange(year_true, 2020, 2023), nquantiles(`num_quan')
		replace `var'_q`num_quan' = 0     if year_true < 2020
	}

	macro drop _num_quan _varlist
}

save "data/inter/master_control2023_semester.dta",replace


// ENDS tax leads and lags
{
	// semester-based, -10 to 5
	// state YRBS
	{
		use "data/inter/master_control2023_semester", clear
		keep fips year_true semester ends_tax_nom35_scale
		save "data/inter/mctemp", replace

		use "${path_cheps_google}/datasets/yrbs/data/clean/stateyrbs_timing_output", clear
		sort fips year
		drop if year_true == .

		merge 1:1 fips year_true semester using "data/inter/mctemp"
		erase "data/inter/mctemp.dta"
		drop _merge
		sort fips year_true semester

		replace year = 0 if year == .


		bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
		replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010

		* Lags
		forval i = 0/5 {
		bys fips: gen s1L`i'_ends = L0[_n - `i']
		replace s1L`i'_ends = 0 if s1L`i'_ends == . // no issue b/c no ends tax pre 2010
		// endpoints:
		if `i' == 5 {
			bys fips: gen sum_s1L`i'_ends = sum(s1L`i'_ends)
			replace s1L`i'_ends = sum_s1L`i'_ends
			drop sum_s1L`i'_ends
		}
		}

		* Leads
		forval i = 1/10 {
		bys fips: gen s1F`i'_ends = L0[_n + `i']
		replace s1F`i'_ends = 0 if s1F`i'_ends == . // assume future tax holds constant
		// endpoints:
		if `i' == 10 {
			gsort fips -year_true -semester
			bys fips: gen sum_s1F`i'_ends = sum(s1F`i'_ends)
			replace s1F`i'_ends = sum_s1F`i'_ends
			drop sum_s1F`i'_ends
		}
		sort fips year_true semester
		}
		order s1F10_ends s1F9_ends s1F8_ends s1F7_ends s1F6_ends s1F5_ends ///
		s1F4_ends s1F3_ends s1F2_ends s1F1_ends, after(L0)

		drop if year == 0
		//drop state_name_nospace
		drop L0

		gen national = 0

		//gcollapse (max) year (mean) ends_tax_nom35_scale, by(fips year_true)
		save "data/inter/etaxnew_leadlag_s1_2023", replace
	} 
	// national YRBS
	{
		use "data/inter/master_control2023_semester", clear
		keep fips year_true semester ends_tax_nom35_scale

		bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
		replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010]

		forval i = 0/5 {
		bys fips: gen s1L`i'_ends = L0[_n - `i']
		replace s1L`i'_ends = 0 if s1L`i'_ends == . // no issue b/c no ends tax pre 2010
		// endpoints:
		if `i' == 5 {
			bys fips: gen sum_s1L`i'_ends = sum(s1L`i'_ends)
			replace s1L`i'_ends = sum_s1L`i'_ends
			drop sum_s1L`i'_ends
		}
		}

		* Leads
		forval i = 1/10 {
		bys fips: gen s1F`i'_ends = L0[_n + `i']
		replace s1F`i'_ends = 0 if s1F`i'_ends == . // assume future tax holds constant
		// endpoints:
		if `i' == 10 {
			gsort fips -year_true -semester
			bys fips: gen sum_s1F`i'_ends = sum(s1F`i'_ends)
			replace s1F`i'_ends = sum_s1F`i'_ends
			drop sum_s1F`i'_ends
		}
		sort fips year_true semester
		}

		order s1F10_ends s1F9_ends s1F8_ends s1F7_ends s1F6_ends s1F5_ends ///
		s1F4_ends s1F3_ends s1F2_ends s1F1_ends, after(L0)

		drop L0

		keep if (semester == 1 & inlist(year_true,2011,2013,2015,2017,2019,2023)) ///
		| (semester == 2 & inlist(year_true,2021))

		rename year_true year

		gen national = 1
		save "data/inter/etaxnew_leadlag_nat_s1_2023", replace
	}  

	// semester-based, -7 to 3
	// state YRBS
	{
		use "data/inter/master_control2023_semester", clear
		keep fips year_true semester ends_tax_nom35_scale
		save "data/inter/mctemp", replace

		use "${path_cheps_google}/datasets/yrbs/data/clean/stateyrbs_timing_output", clear
		sort fips year
		drop if year_true == .

		merge 1:1 fips year_true semester using "data/inter/mctemp"
		erase "data/inter/mctemp.dta"
		drop _merge
		sort fips year_true semester

		replace year = 0 if year == .


		bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
		replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010

		* Lags
		forval i = 0/4 {
		bys fips: gen s2L`i'_ends = L0[_n - `i']
		replace s2L`i'_ends = 0 if s2L`i'_ends == . // no issue b/c no ends tax pre 2010
		// endpoints:
		if `i' == 4 {
			bys fips: gen sum_s2L`i'_ends = sum(s2L`i'_ends)
			replace s2L`i'_ends = sum_s2L`i'_ends
			drop sum_s2L`i'_ends
		}
		}

		* Leads
		forval i = 1/7 {
		bys fips: gen s2F`i'_ends = L0[_n + `i']
		replace s2F`i'_ends = 0 if s2F`i'_ends == . // assume future tax holds constant
		// endpoints:
		if `i' == 7 {
			gsort fips -year_true -semester
			bys fips: gen sum_s2F`i'_ends = sum(s2F`i'_ends)
			replace s2F`i'_ends = sum_s2F`i'_ends
			drop sum_s2F`i'_ends
		}
		sort fips year_true semester
		}
		order s2F7_ends s2F6_ends s2F5_ends s2F4_ends s2F3_ends s2F2_ends s2F1_ends, after(L0)

		drop if year == 0
		//drop state_name_nospace
		drop L0

		gen national = 0

		//gcollapse (max) year (mean) ends_tax_nom35_scale, by(fips year_true)
		save "data/inter/etaxnew_leadlag_s2_2023", replace
	}  
	// national YRBS
	{
		use "data/inter/master_control2023_semester", clear
		keep fips year_true semester ends_tax_nom35_scale

		bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
		replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010]

		forval i = 0/4 {
		bys fips: gen s2L`i'_ends = L0[_n - `i']
		replace s2L`i'_ends = 0 if s2L`i'_ends == . // no issue b/c no ends tax pre 2010
		// endpoints:
		if `i' == 4 {
			bys fips: gen sum_s2L`i'_ends = sum(s2L`i'_ends)
			replace s2L`i'_ends = sum_s2L`i'_ends
			drop sum_s2L`i'_ends
		}
		}

		* Leads
		forval i = 1/7 {
		bys fips: gen s2F`i'_ends = L0[_n + `i']
		replace s2F`i'_ends = 0 if s2F`i'_ends == . // assume future tax holds constant
		// endpoints:
		if `i' == 7 {
			gsort fips -year_true -semester
			bys fips: gen sum_s2F`i'_ends = sum(s2F`i'_ends)
			replace s2F`i'_ends = sum_s2F`i'_ends
			drop sum_s2F`i'_ends
		}
		sort fips year_true semester
		}

		order s2F7_ends s2F6_ends s2F5_ends s2F4_ends s2F3_ends s2F2_ends s2F1_ends, after(L0)


		drop L0

		keep if (semester == 1 & inlist(year_true,2011,2013,2015,2017,2019,2023)) ///
		| (semester == 2 & inlist(year_true,2021))

		rename year_true year

		gen national = 1
		save "data/inter/etaxnew_leadlag_nat_s2_2023", replace
	}   

	// semester-based, -13 to 8
	// state YRBS
	{
		use "data/inter/master_control2023_semester", clear
		keep fips year_true semester ends_tax_nom35_scale
		save "data/inter/mctemp", replace

		use "${path_cheps_google}/datasets/yrbs/data/clean/stateyrbs_timing_output", clear
		sort fips year
		drop if year_true == .

		merge 1:1 fips year_true semester using "data/inter/mctemp"
		erase "data/inter/mctemp.dta"
		drop _merge
		sort fips year_true semester

		replace year = 0 if year == .


		bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
		replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010

		* Lags
		forval i = 0/8 {
		bys fips: gen s3L`i'_ends = L0[_n - `i']
		replace s3L`i'_ends = 0 if s3L`i'_ends == . // no issue b/c no ends tax pre 2010
		// endpoints:
		if `i' == 8 {
			bys fips: gen sum_s3L`i'_ends = sum(s3L`i'_ends)
			replace s3L`i'_ends = sum_s3L`i'_ends
			drop sum_s3L`i'_ends
		}
		}

		* Leads
		forval i = 1/13 {
		bys fips: gen s3F`i'_ends = L0[_n + `i']
		replace s3F`i'_ends = 0 if s3F`i'_ends == . // assume future tax holds constant
		// endpoints:
		if `i' == 13 {
			gsort fips -year_true -semester
			bys fips: gen sum_s3F`i'_ends = sum(s3F`i'_ends)
			replace s3F`i'_ends = sum_s3F`i'_ends
			drop sum_s3F`i'_ends
		}
		sort fips year_true semester
		}
		order s3F13_ends s3F12_ends s3F11_ends s3F10_ends s3F9_ends s3F8_ends s3F7_ends s3F6_ends s3F5_ends ///
		s3F4_ends s3F3_ends s3F2_ends s3F1_ends, after(L0)

		drop if year == 0
		//drop state_name_nospace
		drop L0

		gen national = 0

		//gcollapse (max) year (mean) ends_tax_nom35_scale, by(fips year_true)
		save "data/inter/etaxnew_leadlag_s3_2023", replace
	}
	// national YRBS
	{
		use "data/inter/master_control2023_semester", clear
		keep fips year_true semester ends_tax_nom35_scale

		bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
		replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010]

		forval i = 0/8 {
		bys fips: gen s3L`i'_ends = L0[_n - `i']
		replace s3L`i'_ends = 0 if s3L`i'_ends == . // no issue b/c no ends tax pre 2010
		// endpoints:
		if `i' == 8 {
			bys fips: gen sum_s3L`i'_ends = sum(s3L`i'_ends)
			replace s3L`i'_ends = sum_s3L`i'_ends
			drop sum_s3L`i'_ends
		}
		}

		* Leads
		forval i = 1/13 {
		bys fips: gen s3F`i'_ends = L0[_n + `i']
		replace s3F`i'_ends = 0 if s3F`i'_ends == . // assume future tax holds constant
		// endpoints:
		if `i' == 13 {
			gsort fips -year_true -semester
			bys fips: gen sum_s3F`i'_ends = sum(s3F`i'_ends)
			replace s3F`i'_ends = sum_s3F`i'_ends
			drop sum_s3F`i'_ends
		}
		sort fips year_true semester
		}

		order s3F13_ends s3F12_ends s3F11_ends s3F10_ends s3F9_ends s3F8_ends s3F7_ends s3F6_ends s3F5_ends ///
		s3F4_ends s3F3_ends s3F2_ends s3F1_ends, after(L0)

		drop L0

		keep if (semester == 1 & inlist(year_true,2011,2013,2015,2017,2019,2023)) ///
		| (semester == 2 & inlist(year_true,2021))

		rename year_true year

		gen national = 1
		save "data/inter/etaxnew_leadlag_nat_s3_2023", replace
	}
}

//
// // merge with YRBS file survey data
//

// open combined YRBS, merge in 'exact' timing for state YRBS observations
{
    use "data/inter/yrbs-combined_2011-23.dta", clear // use 2011-2023 dataset

	merge m:1 fips year using "${path_cheps_google}/datasets/yrbs/data/clean/stateyrbs_timing_output"
	drop if _merge == 2
	drop _merge
	cap drop t21 // use our control file t21 indicator
		
	// adjust national yrbs timing - same for all states	
	replace year_true = year if (national == 1)
	replace semester  = 1    if (national == 1) & (year <  2021) 
	replace semester  = 1    if (national == 1) & (year == 2023) 
	replace semester  = 2    if (national == 1) & (year == 2021) 
	
	order state_abbrev fips year_true semester, after(year)
}
	
// merge in our controls - use exact true_year/semester timing for precision
{
	merge m:1 fips year_true semester using "data/inter/master_control2023_semester" 
		
	drop if _merge == 2
	drop _merge
	
	label var year      "Official Survey Year"
	label var year_true "Actual Year Surveyed"
	label var semester  "Semester (1-Spring, 2-Fall)"
}

// generate pre-treatment indicators
{
	gen    current_date = yh(year_true,semester) 
	format current_date %th

	gen     pre_etax_intro = (current_date < etax_intro) & !mi(etax_intro)
	replace pre_etax_intro = . if etax_intro == .
	
	drop current_date
}

// merge in new year lead lags
{
 	// semester based, 10 pre-periods, lag0 to lag5
	{
		// state
		merge m:1 fips year national using "data/inter/etaxnew_leadlag_s1_2023"
		drop if _merge == 2
		drop _merge
		// national
		merge m:1 fips year national using "data/inter/etaxnew_leadlag_nat_s1_2023", update
		drop if _merge == 2
		drop _merge
 	} 

 	// semester based, 7 pre-periods, lag0 to lag3
 	{
		// state
		merge m:1 fips year national using "data/inter/etaxnew_leadlag_s2_2023"
		drop if _merge == 2
		drop _merge
		// national
		merge m:1 fips year national using "data/inter/etaxnew_leadlag_nat_s2_2023", update
		drop if _merge == 2
		drop _merge
 	}  

 	// semester based, 13 pre-periods, lag0 to lag8
 	{
		// state
		merge m:1 fips year national using "data/inter/etaxnew_leadlag_s3_2023"
		drop if _merge == 2
		drop _merge
		// national
		merge m:1 fips year national using "data/inter/etaxnew_leadlag_nat_s3_2023", update
		drop if _merge == 2
		drop _merge
 	}
}

// generate lgbq variables/ drop grade missing & ungraded obs
{
	cap drop lgbq_1
	gen      lgbq_1 = inlist(sex_orientation,2,3,4,5,6)
	replace  lgbq_1 = . if sex_orientation == .

	cap drop lgbq_2
	gen      lgbq_2 = inlist(sex_orientation,2,3,4)
	replace  lgbq_2 = . if sex_orientation == .
	replace  lgbq_2 = . if inlist(sex_orientation,5,6)

	gen     id_gay_lesbian = sex_orientation==2
	replace id_gay_lesbian = . if sex_orientation == .

	gen     id_bisexual = sex_orientation==3
	replace id_bisexual = . if sex_orientation == .

	gen     id_questioning = inlist(sex_orientation,4,5,6)
	replace id_questioning = . if sex_orientation == .

	drop if grade == 5 | grade == .	
	* drop if missing(lgbq_1) | missing(lgbq_2) // Kyu ~ does this
}

// pull in MAP controls for state LGBQ policy (only 2015-2023 -- backfill 2015 values to 2011)
{
	// use 2011 values for 2010 administration states
	gen     year_true_map = year_true
	replace year_true_map = 2011      if (year_true == 2010) & (year == 2011)

	preserve
	
	use "${path_cheps_google}/datasets/map_lgbtq/data/clean/policy_tally", clear
	rename year year_true_map
	rename state_fips fips

	// create quantiles
	local num_quan 4
	foreach var in tally_sexualorientation tally_genderid tally_overall {
		xtile `var'_q`num_quan' = `var', nquantiles(`num_quan')
	}

	// backfill to 2011
	expand 5 if year_true_map==2015, gen(backfill)
	bys fips: egen subtract_yr = seq()                   if backfill==1
	replace year_true_map = year_true_map - subtract_yr  if backfill==1
	sort fips year_true_map
	drop backfill subtract_yr

	tempfile map_policy
	save    `map_policy'

	restore

	merge m:1 fips year_true_map using `map_policy'
	drop if _merge==2
	drop _merge year_true_map
}

compress
save "data/final/master_set_2023", replace

// create BRFSS dataset
{
	// prepare control file for merge
	// create quarterly control file 
	{
		use "${path_cheps_google}/datasets/cheps_controls/data/final/cheps_master_controls_2000to2023_11-11-24.dta", clear

		rename (flavor menthol) (flavor_ban menthol_ban)
		rename state_fips fips

		label var ends_tax_nom35_jcm    "Nominal ENDS tax, 35% retailer mark-up (old version)"
		label var ends_tax_nom35_closed "Nominal ENDS tax, 35% retailer mark-up (closed devices)"
		label var ends_tax_nom35_open   "Nominal ENDS tax, 35% retailer mark-up (open devices)"

		// closed system tax is our main independent variable
		rename ends_tax_nom35_closed ends_tax_nom35 
		
		* License Laws
		gen tobacco_lis_law2 = ///
		tobacco_lis_require_num & tobacco_renew_req_num & (tobacco_min_lis_fee_num>=50)
		label var tobacco_lis_law2 "Strong Tobacco Licensure Law"

		gen tobacco_lis_law1 = ///
		tobacco_lis_require_num & (tobacco_renew_req_num | (tobacco_min_lis_fee_num>=50)) ///
		& !(tobacco_renew_req_num & (tobacco_min_lis_fee_num>=50))
		label var tobacco_lis_law1 "Weak Tobacco Licensure Law"

		gen ecigs_lis_law2 = ///
		ecigs_lis_req_num & ecigs_renewal & (ecigs_min_lic_fee>=50)
		label var ecigs_lis_law2 "Strong ecigs Licensure Law"

		gen ecigs_lis_law1 = ///
		ecigs_lis_req_num & (ecigs_renewal | (ecigs_min_lic_fee>=50)) ///
		& !(ecigs_renewal & (ecigs_min_lic_fee>=50))
		label var ecigs_lis_law1 "Weak ecigs Licensure Law"


		// create variables for any licensure law
		gen ecigs_lis_law_any = 0
		replace ecigs_lis_law_any = 1 if (ecigs_lis_law1 == 1 | ecigs_lis_law2 == 1)

		gen tobacco_lis_law_any = 0
		replace tobacco_lis_law_any = 1 if (tobacco_lis_law1 == 1 | tobacco_lis_law2 == 1)


		* Scale to $2021
		{
			local CPI2021 = 270.97101
			gen cpi_2021 = cpi/`CPI2021' 

			gen ends_tax_nom35_scale1 = ends_tax_nom35 / cpi_2021
			label var ends_tax_nom35_scale1 "ENDS Tax, 35% retailer markup, 2021 $"

			gen cigarette_tax_scale1 = cigarette_tax / cpi_2021
			label var cigarette_tax_scale1 "Cig Tax, 2021 $"

			gen pcinc_scale1 = pcinc / cpi_2021
			label var pcinc_scale1 "Per-Capita Personal Income, 2021 $"

			gen beer_tax_scale1 = beer_tax / cpi_2021
			label var beer_tax_scale1 "Beer Tax, 2021 $"
			
			gen minimum_wage_scale1 = minimum_wage / cpi_2021
			label var minimum_wage_scale1 "Quarterly State Average, 2021 $"
			
			gen snap4_scale1 = snap4 / cpi_2021
			label var snap4_scale1 "FS/SNAP Benefit for 4-person family, 2021 $"
			
			gen tanf4_scale1 = tanf4 / cpi_2021
			label var tanf4_scale1 "TANF maximum monthly benefit for 4-person family, 2021 $"      
		}

		* Scale to $2023
		{
			local CPI2023 = 304.7008
			gen cpi_2023 = cpi/`CPI2023' 

			gen ends_tax_nom35_scale = ends_tax_nom35 / cpi_2023
			label var ends_tax_nom35_scale "ENDS Tax, 35% retailer markup, 2023 $"

			gen cigarette_tax_scale = cigarette_tax / cpi_2023
			label var cigarette_tax_scale "Cig Tax, 2023 $"

			gen pcinc_scale = pcinc / cpi_2023
			label var pcinc_scale "Per-Capita Personal Income, 2023 $"

			gen beer_tax_scale = beer_tax / cpi_2023
			label var beer_tax_scale "Beer Tax, 2023 $"
			
			gen minimum_wage_scale = minimum_wage / cpi_2023
			label var minimum_wage_scale "Quarterly State Average, 2023 $"
			
			gen snap4_scale = snap4 / cpi_2023
			label var snap4_scale "FS/SNAP Benefit for 4-person family, 2023 $"
			
			gen tanf4_scale = tanf4 / cpi_2023
			label var tanf4_scale "TANF maximum monthly benefit for 4-person family, 2023 $"      
		}


		* generate logged econ variables
		gen log_uer     = ln(uer)
		gen log_povrate = ln(povertyrate)

		compress
		
		tempfile controls_quarter_pre
		save    `controls_quarter_pre'
	}

	// ENDS tax introduction 
	{
		use `controls_quarter_pre', clear
		rename year year_true
		//drop _merge

		gen etax_intro = yq(year_true, quarter)
		format etax_intro %tq
		collapse (min) etax_intro if ends_tax_nom35_scale>0 & !mi(ends_tax_nom35_scale), by(fips) 
		tempfile etax_intro
		save    `etax_intro'

		// main control file
		use `controls_quarter_pre',clear
		rename year year_true
		
		merge m:1 fips using `etax_intro'
		drop _merge
	}

	save "data/inter/controls_quarterly_2023", replace

	// prepare MAP policy
	{
		use "${path_cheps_google}/datasets/map_lgbtq/data/clean/policy_tally", clear
		rename year year_true
		rename state_fips fips

		// create quantiles (should this be within year?)
		local num_quan 4
		foreach var in tally_sexualorientation tally_genderid tally_overall {
			xtile `var'_q`num_quan' = `var', nquantiles(`num_quan')
		}

		// backfill to 2011
		expand 5 if year_true==2015, gen(backfill)
		bys fips: egen subtract_yr = seq()           if backfill==1
		replace year_true = year_true - subtract_yr  if backfill==1
		sort fips year_true
		drop backfill subtract_yr

		tempfile map_policy
		save    `map_policy'
	}

	use "${path_cheps_google}/datasets/brfss/data/final/BRFSS_2011to2023.dta", clear

	gen     quarter = 1 if inrange(month,1,3)
	replace quarter = 2 if inrange(month,4,6)
	replace quarter = 3 if inrange(month,7,9)
	replace quarter = 4 if inrange(month,10,12)
	order   quarter, before(month)

	rename state_fips fips 
	drop if inlist(fips,66,72,78)

	// ENDS tax events
	{
		local versions = ""

		// version 1: 4 quarters of first differences in every year (17 leads and 17 lags for -5+ pre to 4+ post)
		{
			preserve 
			local version v1
			
			// referring to x-axis label (enactment year = year 0)
			local last_lead 17
			local last_lag  16

			//local L0_num_quarters 4

			use "data/inter/controls_quarterly_2023", clear

			keep fips year_true quarter ends_tax_nom35_scale
			sort fips year_true quarter
			
			bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
			replace L0 = 0 if L0 == . 
			

			* Leads
			forval i = 1/`last_lead' {
				bys fips: gen pre`version'_F`i'_etax = L0[_n + `i']
				replace pre`version'_F`i'_etax = 0 if pre`version'_F`i'_etax == . // assume future tax holds constant
				// endpoints:
				if `i' == `last_lead' {
				gsort fips -year_true -quarter
				bys fips: gen sum_pre`version'_F`i'_etax = sum(pre`version'_F`i'_etax)
				replace           pre`version'_F`i'_etax = sum_pre`version'_F`i'_etax
				drop          sum_pre`version'_F`i'_etax
				sort fips year_true quarter
				}

				if `i' != 1 order pre`version'_F`i'_etax, before(pre`version'_F`=`i'-1'_etax)
			}

			* Lags
			forval i = 0/`last_lag' {
				bys fips: gen pre`version'_L`i'_etax = L0[_n - `i']
				replace pre`version'_L`i'_etax = 0 if pre`version'_L`i'_etax == . // no issue b/c no ends tax pre 2010
				// endpoints:
				if `i' == `last_lag' {
				bys fips: gen sum_pre`version'_L`i'_etax = sum(pre`version'_L`i'_etax)
				replace           pre`version'_L`i'_etax = sum_pre`version'_L`i'_etax
				drop          sum_pre`version'_L`i'_etax
				}
			}

			// convert to yearly
			{
				// version 0: (lags 0,1,2,3,4+)
				{
					local j = 1

					// leads
					forval i = 1/5 {
						if `i' != 5 gen y_`version'_F`i'_etax = ///
						pre`version'_F`=`j'+0'_etax + pre`version'_F`=`j'+1'_etax + pre`version'_F`=`j'+2'_etax + pre`version'_F`=`j'+3'_etax
						
						if `i' == 5 gen y_`version'_F`i'_etax = ///
						pre`version'_F`=`j'+0'_etax

						if `i' != 1 order y_`version'_F`i'_etax, before(y_`version'_F`=`i'-1'_etax)
						
						local j = `j' + 4
					}

					local j = 0

					// lags
					forval i = 0/4 {
						if `i' != 4 gen y_`version'_L`i'_etax = ///
						pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax
						
						if `i' == 4 gen y_`version'_L`i'_etax = ///
						pre`version'_L`=`j'+0'_etax
				
						local j = `j' + 4
					}
				}

				// version 1: (lags 0,1,2,3+)
				{
					local j = 0

					// lags
					forval i = 0/3 {
						if `i' != 3 gen y1_`version'_L`i'_etax = ///
						pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax
						
						if `i' == 3 gen y1_`version'_L`i'_etax = ///
						pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax + ///
						pre`version'_L`=`j'+4'_etax
				
						local j = `j' + 4
					}
				}
			}


			// convert to biennial
			{
				// -3 pre to 2 post (+ enactment) biennial periods 
				{
				local pre_periods  3
				local post_periods 2

				// constructed version
				local version_c `version'_`pre_periods'_`post_periods'
				local j = 1

				// leads - sum quarterly changes
				forval i = 1/`pre_periods' {
					if `i' != `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax + pre`version'_F`=`j'+1'_etax + pre`version'_F`=`j'+2'_etax + pre`version'_F`=`j'+3'_etax + ///
					pre`version'_F`=`j'+4'_etax + pre`version'_F`=`j'+5'_etax + pre`version'_F`=`j'+6'_etax + pre`version'_F`=`j'+7'_etax

					if `i' == `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax

					if `i' != 1 order bi_`version_c'_F`i'_etax, before(bi_`version_c'_F`=`i'-1'_etax)
					
					local j = `j' + 8
				}
				
				local j = 0

				// lags
				forval i = 0/`post_periods' {
					if `i' != `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax + ///
					pre`version'_L`=`j'+4'_etax + pre`version'_L`=`j'+5'_etax + pre`version'_L`=`j'+6'_etax + pre`version'_L`=`j'+7'_etax

					if `i' == `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax
					
					local j = `j' + 8
				}
				}

				// -3 pre to 1 post (+ enactment) biennial periods
				{
				local pre_periods  3
				local post_periods 1

				local version_c `version'_`pre_periods'_`post_periods'
				local j = 1

				// leads - sum quarterly changes
				forval i = 1/`pre_periods' {
					if `i' != `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax + pre`version'_F`=`j'+1'_etax + pre`version'_F`=`j'+2'_etax + pre`version'_F`=`j'+3'_etax + ///
					pre`version'_F`=`j'+4'_etax + pre`version'_F`=`j'+5'_etax + pre`version'_F`=`j'+6'_etax + pre`version'_F`=`j'+7'_etax

					if `i' == `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax

					if `i' != 1 order bi_`version_c'_F`i'_etax, before(bi_`version_c'_F`=`i'-1'_etax)
					
					local j = `j' + 8
				}
				
				local j = 0

				// lags
				forval i = 0/`post_periods' {
					if `i' != `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax + ///
					pre`version'_L`=`j'+4'_etax + pre`version'_L`=`j'+5'_etax + pre`version'_L`=`j'+6'_etax + pre`version'_L`=`j'+7'_etax
					
					// use same initial quarterly events to create (0,1),2+ years instead of (0,1),(2,3),4+ years
					// sum 9 quarterly events for 2+ years events
					if `i' == `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax + ///
					pre`version'_L`=`j'+4'_etax + pre`version'_L`=`j'+5'_etax + pre`version'_L`=`j'+6'_etax + pre`version'_L`=`j'+7'_etax + ///
					pre`version'_L`=`j'+8'_etax 
					
					local j = `j' + 8
				}
				}
			}

			drop L0

			drop *pre`version'*

			tempfile events_brfss_`version'
			save    `events_brfss_`version''

			restore
		}
		
		local versions = "`versions' `version'"

		// version 2: 4 quarters of first differences in every year (17 leads and 9 lags for -5+ pre to 2+ post)
		{
			preserve 
			local version v2
			
			// referring to x-axis label (enactment year = year 0)
			local last_lead 17
			local last_lag  8

			local last_lead_yr = ceil(`last_lead'/4)
			local last_lag_yr  = `last_lag' / 4

			use "data/inter/controls_quarterly_2023", clear

			keep fips year_true quarter ends_tax_nom35_scale
			sort fips year_true quarter
			
			bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
			replace L0 = 0 if L0 == . 
			

			* Leads
			forval i = 1/`last_lead' {
				bys fips: gen pre`version'_F`i'_etax = L0[_n + `i']
				replace pre`version'_F`i'_etax = 0 if pre`version'_F`i'_etax == . // assume future tax holds constant
				// endpoints:
				if `i' == `last_lead' {
				gsort fips -year_true -quarter
				bys fips: gen sum_pre`version'_F`i'_etax = sum(pre`version'_F`i'_etax)
				replace           pre`version'_F`i'_etax = sum_pre`version'_F`i'_etax
				drop          sum_pre`version'_F`i'_etax
				sort fips year_true quarter
				}

				if `i' != 1 order pre`version'_F`i'_etax, before(pre`version'_F`=`i'-1'_etax)
			}

			* Lags
			forval i = 0/`last_lag' {
				bys fips: gen pre`version'_L`i'_etax = L0[_n - `i']
				replace pre`version'_L`i'_etax = 0 if pre`version'_L`i'_etax == . // no issue b/c no ends tax pre 2010
				// endpoints:
				if `i' == `last_lag' {
				bys fips: gen sum_pre`version'_L`i'_etax = sum(pre`version'_L`i'_etax)
				replace           pre`version'_L`i'_etax = sum_pre`version'_L`i'_etax
				drop          sum_pre`version'_L`i'_etax
				}
			}

			// convert to yearly
			{
				
				local j = 1

				// leads
				forval i = 1/`last_lead_yr' {
				if `i' != `last_lead_yr' gen y_`version'_F`i'_etax = ///
				pre`version'_F`=`j'+0'_etax + pre`version'_F`=`j'+1'_etax + pre`version'_F`=`j'+2'_etax + pre`version'_F`=`j'+3'_etax
				
				if `i' == `last_lead_yr' gen y_`version'_F`i'_etax = ///
				pre`version'_F`=`j'+0'_etax

				if `i' != 1 order y_`version'_F`i'_etax, before(y_`version'_F`=`i'-1'_etax)
				
				local j = `j' + 4
				}

				local j = 0

				// lags
				forval i = 0/`last_lag_yr' {
				if `i' != `last_lag_yr' gen y_`version'_L`i'_etax = ///
				pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax
				
				if `i' == `last_lag_yr' gen y_`version'_L`i'_etax = ///
				pre`version'_L`=`j'+0'_etax
			
				local j = `j' + 4
				}
			}

			// convert to biennial
			{
				// -3 pre to 1 post biennial periods
				{
				local pre_periods  3
				local post_periods 1

				local version_c `version'_`pre_periods'_`post_periods'
				local j = 1

				// leads - sum quarterly changes
				forval i = 1/`pre_periods' {
					if `i' != `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax + pre`version'_F`=`j'+1'_etax + pre`version'_F`=`j'+2'_etax + pre`version'_F`=`j'+3'_etax + ///
					pre`version'_F`=`j'+4'_etax + pre`version'_F`=`j'+5'_etax + pre`version'_F`=`j'+6'_etax + pre`version'_F`=`j'+7'_etax

					if `i' == `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax

					if `i' != 1 order bi_`version_c'_F`i'_etax, before(bi_`version_c'_F`=`i'-1'_etax)
					
					local j = `j' + 8
				}
				
				local j = 0

				// lags
				forval i = 0/`post_periods' {

					if `i' != `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax + ///
					pre`version'_L`=`j'+4'_etax + pre`version'_L`=`j'+5'_etax + pre`version'_L`=`j'+6'_etax + pre`version'_L`=`j'+7'_etax
					
					if `i' == `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax 
					
					local j = `j' + 8

				}
				}
			}

			drop L0

			drop *pre`version'*

			tempfile events_brfss_`version'
			save    `events_brfss_`version''

			restore
		}

		local versions = "`versions' `version'"

		// version 3: 4 quarters of first differences in every year (17 leads and 25 lags for -5+ pre and 6+ post)
		{
			preserve 
			local version v3
			
			// referring to x-axis label (enactment year = year 0)
			local last_lead 17
			local last_lag  24

			//local L0_num_quarters 4

			use "data/inter/controls_quarterly_2023", clear

			keep fips year_true quarter ends_tax_nom35_scale
			sort fips year_true quarter
			
			bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
			replace L0 = 0 if L0 == . 
			

			* Leads
			forval i = 1/`last_lead' {
				bys fips: gen pre`version'_F`i'_etax = L0[_n + `i']
				replace pre`version'_F`i'_etax = 0 if pre`version'_F`i'_etax == . // assume future tax holds constant
				// endpoints:
				if `i' == `last_lead' {
				gsort fips -year_true -quarter
				bys fips: gen sum_pre`version'_F`i'_etax = sum(pre`version'_F`i'_etax)
				replace           pre`version'_F`i'_etax = sum_pre`version'_F`i'_etax
				drop          sum_pre`version'_F`i'_etax
				sort fips year_true quarter
				}

				if `i' != 1 order pre`version'_F`i'_etax, before(pre`version'_F`=`i'-1'_etax)
			}

			* Lags
			forval i = 0/`last_lag' {
				bys fips: gen pre`version'_L`i'_etax = L0[_n - `i']
				replace pre`version'_L`i'_etax = 0 if pre`version'_L`i'_etax == . // no issue b/c no ends tax pre 2010
				// endpoints:
				if `i' == `last_lag' {
				bys fips: gen sum_pre`version'_L`i'_etax = sum(pre`version'_L`i'_etax)
				replace           pre`version'_L`i'_etax = sum_pre`version'_L`i'_etax
				drop          sum_pre`version'_L`i'_etax
				}
			}

			// convert to yearly
			{
				// -5 pre to 6 post (lags 0,1,2,3,4,5,6+)
				{
				local j = 1

				// leads
				forval i = 1/5 {
					if `i' != 5 gen y_`version'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax + pre`version'_F`=`j'+1'_etax + pre`version'_F`=`j'+2'_etax + pre`version'_F`=`j'+3'_etax
					
					if `i' == 5 gen y_`version'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax

					if `i' != 1 order y_`version'_F`i'_etax, before(y_`version'_F`=`i'-1'_etax)
					
					local j = `j' + 4
				}

				local j = 0

				// lags
				forval i = 0/6 {
					if `i' != 6 gen y_`version'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax
					
					if `i' == 6 gen y_`version'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax
			
					local j = `j' + 4
				}
				}
			}


			// convert to biennial
			{
				// -3 pre to 3 post (+ enactment) biennial periods 
				{
				local pre_periods  3
				local post_periods 3

				// constructed version
				local version_c `version'_`pre_periods'_`post_periods'
				local j = 1

				// leads - sum quarterly changes
				forval i = 1/`pre_periods' {
					if `i' != `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax + pre`version'_F`=`j'+1'_etax + pre`version'_F`=`j'+2'_etax + pre`version'_F`=`j'+3'_etax + ///
					pre`version'_F`=`j'+4'_etax + pre`version'_F`=`j'+5'_etax + pre`version'_F`=`j'+6'_etax + pre`version'_F`=`j'+7'_etax

					if `i' == `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax

					if `i' != 1 order bi_`version_c'_F`i'_etax, before(bi_`version_c'_F`=`i'-1'_etax)
					
					local j = `j' + 8
				}
				
				local j = 0

				// lags
				forval i = 0/`post_periods' {
					if `i' != `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax + ///
					pre`version'_L`=`j'+4'_etax + pre`version'_L`=`j'+5'_etax + pre`version'_L`=`j'+6'_etax + pre`version'_L`=`j'+7'_etax

					if `i' == `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax
					
					local j = `j' + 8
				}
				}


			}

			drop L0

			drop *pre`version'*

			tempfile events_brfss_`version'
			save    `events_brfss_`version''

			restore
		}

		local versions = "`versions' `version'"

		// version 4: 4 quarters of first differences in every year (25 leads and 17 lags for -7+ pre to 4+ post)
		{
			preserve 
			local version v4

			// referring to x-axis label (enactment year = year 0)
			local last_lead 25
			local last_lag  16

			//local L0_num_quarters 4

			use "data/inter/controls_quarterly_2023", clear

			keep fips year_true quarter ends_tax_nom35_scale
			sort fips year_true quarter
			
			bys fips: gen L0 = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n - 1]
			replace L0 = 0 if L0 == . 
			

			* Leads
			forval i = 1/`last_lead' {
				bys fips: gen pre`version'_F`i'_etax = L0[_n + `i']
				replace pre`version'_F`i'_etax = 0 if pre`version'_F`i'_etax == . // assume future tax holds constant
				// endpoints:
				if `i' == `last_lead' {
				gsort fips -year_true -quarter
				bys fips: gen sum_pre`version'_F`i'_etax = sum(pre`version'_F`i'_etax)
				replace           pre`version'_F`i'_etax = sum_pre`version'_F`i'_etax
				drop          sum_pre`version'_F`i'_etax
				sort fips year_true quarter
				}

				if `i' != 1 order pre`version'_F`i'_etax, before(pre`version'_F`=`i'-1'_etax)
			}

			* Lags
			forval i = 0/`last_lag' {
				bys fips: gen pre`version'_L`i'_etax = L0[_n - `i']
				replace pre`version'_L`i'_etax = 0 if pre`version'_L`i'_etax == . // no issue b/c no ends tax pre 2010
				// endpoints:
				if `i' == `last_lag' {
				bys fips: gen sum_pre`version'_L`i'_etax = sum(pre`version'_L`i'_etax)
				replace           pre`version'_L`i'_etax = sum_pre`version'_L`i'_etax
				drop          sum_pre`version'_L`i'_etax
				}
			}

			// convert to yearly
			{
				// version 0: (lags 0,1,2,3,4+)
				{
					local j = 1

					// leads
					forval i = 1/7 {
						if `i' != 7 gen y_`version'_F`i'_etax = ///
						pre`version'_F`=`j'+0'_etax + pre`version'_F`=`j'+1'_etax + pre`version'_F`=`j'+2'_etax + pre`version'_F`=`j'+3'_etax
						
						if `i' == 7 gen y_`version'_F`i'_etax = ///
						pre`version'_F`=`j'+0'_etax

						if `i' != 1 order y_`version'_F`i'_etax, before(y_`version'_F`=`i'-1'_etax)
						
						local j = `j' + 4
					}

					local j = 0

					// lags
					forval i = 0/4 {
						if `i' != 4 gen y_`version'_L`i'_etax = ///
						pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax
						
						if `i' == 4 gen y_`version'_L`i'_etax = ///
						pre`version'_L`=`j'+0'_etax
				
						local j = `j' + 4
					}
				}
			}


			// convert to biennial
			{
				// -4 pre to 2 post (+ enactment) biennial periods 
				{
				local pre_periods  4
				local post_periods 2

				// constructed version
				local version_c `version'_`pre_periods'_`post_periods'
				local j = 1

				// leads - sum quarterly changes
				forval i = 1/`pre_periods' {
					if `i' != `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax + pre`version'_F`=`j'+1'_etax + pre`version'_F`=`j'+2'_etax + pre`version'_F`=`j'+3'_etax + ///
					pre`version'_F`=`j'+4'_etax + pre`version'_F`=`j'+5'_etax + pre`version'_F`=`j'+6'_etax + pre`version'_F`=`j'+7'_etax

					if `i' == `pre_periods' gen bi_`version_c'_F`i'_etax = ///
					pre`version'_F`=`j'+0'_etax

					if `i' != 1 order bi_`version_c'_F`i'_etax, before(bi_`version_c'_F`=`i'-1'_etax)
					
					local j = `j' + 8
				}
				
				local j = 0

				// lags
				forval i = 0/`post_periods' {
					if `i' != `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax + pre`version'_L`=`j'+1'_etax + pre`version'_L`=`j'+2'_etax + pre`version'_L`=`j'+3'_etax + ///
					pre`version'_L`=`j'+4'_etax + pre`version'_L`=`j'+5'_etax + pre`version'_L`=`j'+6'_etax + pre`version'_L`=`j'+7'_etax

					if `i' == `post_periods' gen bi_`version_c'_L`i'_etax = ///
					pre`version'_L`=`j'+0'_etax
					
					local j = `j' + 8
				}
				}
			}

			drop L0

			drop *pre`version'*

			tempfile events_brfss_`version'
			save    `events_brfss_`version''

			restore
		}

		local versions = "`versions' `version'"
		
		macro drop _version _version_c _last_lead _last_lag _last_lead_yr _last_lag_yr _pre_periods _post_periods
	}

	// assign observations surveyed in Jan/Feb/Mar 2024 -> Dec 2023 control values
	gen     issue     = 1    if year_true == 2024 & year_survey == 2023
	replace year_true = 2023 if issue == 1
	replace quarter   = 4    if issue == 1 
	replace month     = 12   if issue == 1 

	// merge control file
	merge m:1 fips year_true quarter using "data/inter/controls_quarterly_2023"
	drop if _merge == 2 // drop pre-2011 and 2024 data -- and fips 12[2021q2,3,4],21[2023q2,3,4],34[2019q2,3,4],42[2023q2,3,4]
	drop _merge

	// merge ENDS tax events
	foreach version of local versions {
	merge m:1 fips year_true quarter using `events_brfss_`version''
	drop if _merge==2
	drop _merge
	}

	// adjust vars
	{
		// adjust smoke_current_v2 and smoke_daily_v2 to include post-2019 data
		replace smoke_current_v2 = smoke_current if year_survey>2019
		replace smoke_daily_v2   = smoke_daily   if year_survey>2019

		// rename to match yrbs var names
		rename ///
		(ecig_current ecig_daily smoke_current_v2 smoke_daily_v2 binge_current binge_multiple) ///
		(vape dvape smoke dsmoke binge binge_multiple)

		gen age_sq = age * age

		// new education variable
		gen     some_college_higher = .
		replace some_college_higher= 0 if hs==1 | no_hs==1
		replace some_college_higher=1 if some_college ==1 | college ==1

		/*
		// new ban variables
		gen     ban_vape = 0
		replace ban_vape = 1 if (work_vape_ban == 1 | bar_vape_ban == 1 | rest_vape_ban == 1)
		
		gen     ban_smoke = 0
		replace ban_smoke = 1 if (work_smoke_ban == 1 | bar_smoke_ban == 1 | rest_smoke_ban == 1)	  
		*/

		gen       indoor_ban_vape = 0
		replace   indoor_ban_vape = 1 if (work_vape_ban == 1 | bar_vape_ban == 1 | rest_vape_ban == 1)
		label var indoor_ban_vape "Presence of any indoor vaping ban"

		gen       indoor_ban_smoke = 0
		replace   indoor_ban_smoke = 1 if (work_smoke_ban == 1 | bar_smoke_ban == 1 | rest_smoke_ban == 1)
		label var indoor_ban_smoke "Presence of any indoor smoking ban"
		
		// use same covid variable as YRBS
		gen coviddeaths = covid_deaths_cu_rate
		label var coviddeaths "Population-scaled current cumulative covid deaths within state"
	}

	// generate pre-treatment indicator
	{
		gen current_date = yq(year_true,quarter) 
		format current_date %tq

		gen pre_etax_intro = (current_date < etax_intro) & !mi(etax_intro)
		replace pre_etax_intro = . if etax_intro == .
		drop current_date
	}

	// merge MAP policy
	merge m:1 fips year_true using `map_policy'
	drop if _merge==2
	drop    _merge

	compress

	save "data/final/brfss_master_set_2023", replace
}



// space for VSCode
