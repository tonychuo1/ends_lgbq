//
// (01): clean up the YRBS data file (ignore alcohol and marijuana variable creation -- not used in this project)
//

clear all
 
// pull in YRBS file
{ 
	use ///
	year survyear national bweight state_fips aweight cweight original_state_weight pop1418 age_* ///
	age grade sex female sex_orientation race4 marij fmarij binge fbinge bullied e_bullied *_lifetime pain_med ///
	sad suicide* *30days *ever* binge_alc source_vape *alc* chain_smoke age_marij gradesinschool ///
	using "${path_cheps_google}/datasets/yrbs/data/final/YRBS_combined_2003-2023.dta", clear	 
}

keep if inrange(year, 2011, 2023)

// rename variables, code up female
{ 
	rename state_fips fips 
	rename marij  caterina_marij
	rename fmarij caterina_fmarij
	rename binge  caterina_binge
	rename fbinge caterina_fbinge

	cap drop female
	gen      female = .
	replace  female = 1 if sex == 1
	replace  female = 0 if sex == 2
}

// code up substance use variables
{ 
	rename (*cigarette* *marijuana* *alcohol*) (*smoke* *marij* *alc*) // standardizing naming
	rename (binge_alc) (binge_alc30days)

	// cigarette smoking 
	{
		// Current Use
		cap drop smoke
		gen      smoke = smoke30days!=1 if !mi(smoke30days)
		lab var  smoke "Smokes cigarettes currently (>0 days in last month)"

		// Frequent Use
		cap drop fsmoke
		gen      fsmoke = inrange(smoke30days,6,7) if !mi(smoke30days)
		lab var  fsmoke "Smokes cigarettes frequently (>=20 days in last month)"
		
		// Daily Use
		cap drop dsmoke
		gen      dsmoke = smoke30days==7 if !mi(smoke30days)
		lab var  dsmoke "Smokes cigarettes everyday (all 30 days in last month)"
	}
	local smoke smoke fsmoke dsmoke

	// cigar smoking 
	{
		// Current Use
		cap drop cigar
		gen      cigar = cigar30days!=1 if !mi(cigar30days)
		lab var  cigar "Smokes cigars currently (>0 days in last month)"

		// Frequent Use
		cap drop fcigar
		gen      fcigar = inrange(cigar30days,6,7) if !mi(cigar30days)
		lab var  fcigar "Smokes cigars frequently (>=20 days in last month)"
		
		// Daily Use
		cap drop dcigar
		gen      dcigar = cigar30days==7 if !mi(cigar30days)
		lab var  dcigar "Smokes cigars everyday (all 30 days in last month)"
	}
	local cigar cigar fcigar dcigar

	// ENDS usage 
	{
		// Current Use
		cap drop vape
		gen      vape = vape30days!=1 if !mi(vape30days)
		lab var  vape "Uses vapes currently (>0 days in last month)"

		// Frequent Use
		cap drop fvape
		gen      fvape = inrange(vape30days,6,7) if !mi(vape30days)
		lab var  fvape "Uses vapes frequently (>=20 days in last month)"
		
		// Daily Use
		cap drop dvape
		gen      dvape = vape30days==7 if !mi(vape30days)
		lab var  dvape "Uses vapes everyday (all 30 days in last month)"
	}
	local vape vape fvape dvape

	// alcohol consumption 
	{
		// Current Use
		cap drop alc
		gen      alc = alc30days!=1 if !mi(alc30days)
		lab var  alc "Drinks alcohol currently (>0 days in last month)"

		// Frequent Use
		cap drop falc
		gen      falc = inrange(alc30days,4,7) if !mi(alc30days)
		lab var  falc "Frequent alcohol use (>5 days in last month)"
		
		// Daily Use
		cap drop dalc
		gen      dalc = alc30days==7 if !mi(alc30days)
		lab var  dalc "Drinks alcohol everyday (all 30 days in last month)"

		// Number drinks | drink
		cap drop numdrink_pre
		recode   number_alc (1 = 0) (2 = 1.5) (3 = 3) (4 = 4) (5 = 5) (6 = 6.5) (7 = 8.5) (8 = 10), gen(numdrink_pre)
		replace  numdrink_pre = 0 if alc == 0
		
		cap drop numdrink
		gen      numdrink = numdrink_pre if alc == 1
		
		// turn all remaining 0's --> missing
		replace numdrink = . if numdrink == 0
		lab var numdrink "Largest number of drinks in a row in past month, given alc==1"
	}
	local alc alc falc dalc numdrink

	// binge alcohol (unconditional)
	{ 
		// Current Use
		cap drop binge_alc
		gen      binge_alc = binge_alc30days!=1 if !mi(binge_alc30days) & inrange(year,2017,2021)
		lab var  binge_alc "Binge drinks alcohol currently (>0 days in last month)"

		// Frequent Use -- different from others (2+ instances in last 30 days)
		cap drop fbinge_alc
		gen      fbinge_alc = inrange(binge_alc30days,3,7) if !mi(binge_alc30days) & inrange(year,2017,2021)
		lab var  fbinge_alc "Binge drinks alcohol multiple times (>=2 days in last month)"
	}
	local binge_alc binge_alc fbinge_alc
	
	// marijuana smoking 
	{
		// Current Use
		cap drop marij
		gen      marij = marij30days!=1 if !mi(marij30days)
		lab var  marij "Smokes marijuana currently (>0 time in last month)"

		// Frequent Use
		cap drop fmarij
		gen      fmarij = inrange(marij30days,5,6) if !mi(marij30days)
		lab var  fmarij "Smokes marijuana frequently (>=20 times in last month)"
			
		// Daily Use
		cap drop dmarij
		gen      dmarij = marij30days==6 if !mi(marij30days)
		lab var  dmarij "Smokes marijuana everyday (>=40 times in last month)"
	}
	local marij marij fmarij dmarij

	// cigarette or cigar smoking 
	{
		// Current Use
		cap drop combust
        gen      combust = .
		replace  combust = 1 if cigar == 1 
		replace  combust = 1 if smoke == 1
		replace  combust = 0 if cigar == 0 & smoke == 0
		lab var  combust "Smokes cigarettes or cigars currently (>0 days in last month)"

		// Frequent Use
		cap drop fcombust
	    gen      fcombust = .
		replace  fcombust = 1 if fcigar == 1 
		replace  fcombust = 1 if fsmoke == 1
		replace  fcombust = 0 if fcigar == 0 & fsmoke == 0
		lab var  fcombust "Smokes cigarettes or cigars frequently (>=20 days in last month)"

		// Daily Use
		cap drop dcombust
	    gen      dcombust = .
		replace  dcombust = 1 if dcigar == 1 
		replace  dcombust = 1 if dsmoke == 1
		replace  dcombust = 0 if dcigar == 0 & dsmoke == 0
		lab var  dcombust "Smokes cigarettes or cigars daily (all days in last month)"	

		
		// secondary combustible variable: only missing when both smoke & cigar are missing
		// Current Use
		cap drop combust_2
        gen      combust_2 = 0
		replace  combust_2 = 1 if cigar == 1 
		replace  combust_2 = 1 if smoke == 1
		replace  combust_2 = . if cigar == . & smoke == .
		lab var  combust_2 "Smokes cigarettes or cigars currently (>0 days in last month)"

		// Frequent Use
		cap drop fcombust_2
        gen      fcombust_2 = 0
		replace  fcombust_2 = 1 if fcigar == 1 
		replace  fcombust_2 = 1 if fsmoke == 1
		replace  fcombust_2 = . if fcigar == . & fsmoke == .
		lab var  fcombust_2 "Smokes cigarettes or cigars frequently (>=20 days in last month)"

		// Daily Use
		cap drop dcombust_2
        gen      dcombust_2 = 0
		replace  dcombust_2 = 1 if dcigar == 1 
		replace  dcombust_2 = 1 if dsmoke == 1
		replace  dcombust_2 = . if dcigar == . & dsmoke == .
		lab var  dcombust_2 "Smokes cigarettes or cigars daily (all days in last month)"	
	}
	local combust combust fcombust dcombust combust_2 fcombust_2 dcombust_2
}
local drugs `smoke' `cigar' `combust' `vape' `alc' `binge_alc' `marij' 

// code up mental health variables	
{ 
    rename ///
    (sad  suicide_ideation  suicide_plan  suicide_attempt  suicide_injury) ///
    (sadi suicide_ideationi suicide_plani suicide_attempti suicide_injuryi)
	
	cap drop sad
	gen      sad = sadi==1 if !mi(sadi)
	lab var  sad "Felt sad/hopeless for almost every day for 2 weeks or more in the past 12 months"
	
	cap drop s_ideation
	gen      s_ideation = suicide_ideationi==1 if !mi(suicide_ideationi)
	lab var  s_ideation "Seriously considered attempting suicide in the past 12 months"
	
	cap drop s_plan
	gen      s_plan = suicide_plani==1 if !mi(suicide_plani)
	lab var  s_plan "Made a plan to attempt suicide in the past 12 months"
		
	cap drop s_attempt
	gen      s_attempt = suicide_attempti!=1 if !mi(suicide_attempti)
	lab var  s_attempt "Attempted suicide at least once in the past 12 months"
		
	cap drop s_injury
	gen      s_injury = suicide_injuryi==2 if (!mi(suicide_injuryi) | suicide_injuryi!=1)
	lab var  s_injury "Injured, if  attempted to commit suicide, in the past 12 months"

	// turn to (0/1)
	replace bullied = 0   if bullied == 2	
	replace e_bullied = 0 if e_bullied == 2
}
local mental sad s_ideation s_plan s_attempt s_injury bullied e_bullied


keep year survyear national bweight fips aweight cweight original_state_weight pop1418 age_* ///
age grade sex female sex_orientation race4 *30days* number_alc source_vape chain_smoke age_marij *caterina* *_lifetime pain_med ///
`drugs' `mental' gradesinschool


save "data/inter/yrbs-combined_2011-23.dta", replace

// give time for OneDrive to sync (60 seconds)
sleep 60000


// space for VSCode