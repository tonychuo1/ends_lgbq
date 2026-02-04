//
// (04): produce trend line, policy map, heterogeneity, and event study figures
//

use "data/final/master_set_2023", clear

// trend lines
if 1 {
    // substance use vars
    foreach vari in vape smoke cigar combust {
    foreach yr in 1 5 {

        if ("`vari'" == "vape")                       & (`yr'==1) continue
        if inlist("`vari'","smoke","cigar","combust") & (`yr'==5) continue 
        
        preserve

        keep if !national
        keep if inrange(year,201`yr',2023)

        gcollapse `vari' f`vari' d`vari' [aw=aweight], by(year lgbq_1)

        foreach var in `vari' f`vari' d`vari' {
            // parameters
            { 
                local leg "legend(order(2 1) label(1 "Heterosexual") label(2 "LGBQ") cols(1) pos(6)) legend(size(medium))"
                local ylab "ylab(0(.1).3, labsize(medium))"

                if "`var'" == "fvape"      local ylab "ylab(0(0.05)0.1)"
                if "`var'" == "dvape"      local ylab "ylab(0(0.05)0.1)"	
                if "`var'" == "combust"    local ylab "ylab(0(0.1)0.5)"			 
                if "`var'" == "fcombust"   local ylab "ylab(0(0.1)0.2)"			 
                if "`var'" == "dcombust"   local ylab "ylab(0(0.1)0.2)"			 
                if "`var'" == "fsmoke"     local ylab "ylab(0(0.05)0.15)"		 	
                if "`var'" == "dsmoke"     local ylab "ylab(0(0.05)0.15)"			
                if "`var'" == "fcigar"     local ylab "ylab(0(0.025)0.05)"			 	  
                if "`var'" == "dcigar"     local ylab "ylab(0(0.025)0.05)"		
                if "`var'" == "binge_alc"  local ylab "ylab(0(0.1)0.3)"	
                if "`var'" == "fbinge_alc" local ylab "ylab(0(0.1)0.3)"			 		 	 	  		 
            }

            #delimit;
            twoway (connected `var' year if lgbq_1 == 0,  lpattern(solid) lwidth(medthick)
            msize(small) msymbol(O)) 
            (connected `var' year if lgbq_1 == 1, lpattern(dash) lwidth(medthick)
            msize(small) msymbol(D))
            , 
            `ylab' xlab(201`yr'(2)2023, labsize(medium)) scheme(s2manual)
            ytitle("Proportion of Users", size(medium))
            xtitle("Year", size(medium))
            `leg'
            graphregion(color(white))
            ysize(2.5) xsize(4.4)
            ;
            #delimit cr;

            graph export "output/etax/graphs/final/trendline_`var'_y`yr'.png", replace	 
            graph close
        }
        restore
    }
    }

    // sexual orientation identification
    foreach yr in 1 /*5*/ {
        preserve

        keep if !national
        keep if inrange(year,201`yr',2023)
        gcollapse lgbq_1 id_gay_lesbian id_bisexual id_questioning [aw=aweight], by(year)

        // % increase in those identifying as lgbq
        di (lgbq_1[7] - lgbq_1[1]) / lgbq_1[1]

        // % increase in gay/lesbian
        di (id_gay_lesbian[7] - id_gay_lesbian[1]) / id_gay_lesbian[1]

        // % increase in those identifying as bisexual
        di (id_bisexual[7] - id_bisexual[1]) / id_bisexual[1] 

        // % increase in those identifying as questioning
        di (id_questioning[7] - id_questioning[1]) / id_questioning[1] 	 


        { // Set titles with locals
            local leg "legend(order(- "" 3 1 4 - "" 2) label(1 "LGBQ") label(2 "Gay or Lesbian") label(3 "Bisexual") label(4 "Questioning") cols(2) pos(6)) legend(size(small))"
            local ylab "ylab(0(.1).3)"
        }

        #delimit;
        twoway (connected lgbq_1 year, lpattern(solid) lwidth(medthick)
        msize(small) msymbol(O)) 
        (connected id_gay_lesbian year, lpattern(dash) lwidth(medthick)
        msize(small) msymbol(D))
        (connected id_bisexual year, lpattern(shortdash_dot) lwidth(medthick)
        msize(small) msymbol(T))
        (connected id_questioning year, lpattern(longdash_dot) lwidth(medthick)
        msize(small) msymbol(S))	 	 
        , 
        `ylab' xlab(201`yr'(2)2023) scheme(s2manual)
        ytitle("Proportion Identifying as Sexual Minority")
        xtitle("Year")
        `leg'
        graphregion(color(white))
        name(app_lgbq, replace)

        ;
        #delimit cr;
        graph export "output/etax/graphs/final/trendline_lgbq_y`yr'.png", replace	 
        graph close


        restore
    }
}

// map
if 1 {
    // ENDS tax v1: with Alaska, Hawaii
    {
        preserve

        use "data/raw/map/stateUS_bound", clear

        merge 1:m fips using "data/inter/master_control2023_semester.dta" 

        gcollapse ends_tax_nom35_scale, by(id year_true)
        replace   ends_tax_nom35_scale = . if ends_tax_nom35_scale == 0

        forval i = 0/1 {
            // i-specific
            {
                if `i' == 1 {
                local leg "legend(size(vlarge) lab(1 "[$0.00]") lab(2 "($0.00,$1.00]") lab(3 "($1.00,$2.00]") lab(4 "($2.00,$3.00]") lab(5 "($3.00,$4.00]") title("Real ENDS Tax in 2023 $")) legend(ring(2) pos(6) rows(1) order(1 2 3 4 5))"
                local asp_ratio "xsize(3.5) ysize(2)"
                local leg_name 1
                }
                if `i' == 0 {
                local leg legend(off)
                local asp_ratio "xsize(3) ysize(2.2)"
                local leg_name
                }
            }
        foreach yr in 2010 2015 2016 2017 2018 2019 2020 2021 2022 2023 {
            if `i'==1 & `yr'!=2023 continue

            spmap ends_tax_nom35_scale using "data/raw/map/stateUS_coord" ///
            if year_true == `yr', /// 
            id(id) fcolor(gs14 gs10 gs5 gs1) clmethod(custom) clbreaks(0 1 2 3 4) ///
            `leg' ndpattern(dash) ocolor(gs4) `asp_ratio'
	
            graph export "output/etax/graphs/final/map_v1_`yr'`leg_name'.png", replace            
            graph close
        }
        }
        restore
    }

    // cigarette tax/ flavor ban/ MLSA
    {
        use "data/raw/map/stateUS_bound", clear

        merge 1:m fips using "data/inter/master_control2023_semester.dta" 

        // Washington and Montana's flavor bans were enacted with limited lifetimes (temporary by design)
        replace flavor_ban=-1 if fips==53 & flavor_ban>0 // WA
        replace flavor_ban=-1 if fips==30 & flavor_ban>0 // MT

        gcollapse cigarette_tax_scale flavor_ban any_mlsa_vape, by(id year_true)

        // turn all MLSA's to binary 0/1
        replace any_mlsa_vape=1 if any_mlsa_vape>0 & !mi(any_mlsa_vape)
        
        foreach ind_var in cigarette_tax_scale flavor_ban any_mlsa_vape {
            preserve
            
            // ind_var-specific
            {
                if "`ind_var'"=="cigarette_tax_scale" {
                    local ind_var_name cigtax
                    local year_list 2010 2015 2016 2017 2018 2019 2020 2021 2022 2023
                    local clmethod custom
                    local clbreaks clbreaks(0 1.50 3 4.50 6)
                    local legend "legend(size(medlarge) lab(1 "[$0.00]") lab(2 "($0.00,$1.50]") lab(3 "($1.50,$3.00]") lab(4 "($3.00,$4.50]") lab(5 "($4.50,$6.00]") title("Real Cig Tax in 2023 $")) legend(ring(2) pos(6) rows(1) order(1 2 3 4 5))"
                    local fcolor gs14 gs10 gs5 gs1
                }
                if "`ind_var'"=="flavor_ban" {
                    local ind_var_name flav
                    local year_list 2010 2015 2016 2017 2018 2019 2020 2021 2022 2023

                    local clmethod custom
                    local clbreaks clbreaks(-1 0 0.50 1)
                    local legend "legend(size(large) lab(1 "[0]") lab(2 "Temporary Ban") lab(3 "(0,0.50]") lab(4 "(0.50,1.00]") title("ENDS Flavor Ban")) legend(ring(2) pos(6) rows(1) order(1 2 3 4 5))"
                    local fcolor gs14 gs10 gs5 gs1
                }
                if "`ind_var'"=="any_mlsa_vape" {
                    local ind_var_name mlsa
                    local year_list 2010 2011 2012 2013 2014 2015 2016 2018 2020

                    local clmethod unique
                    local clbreaks 
                    local legend "legend(size(vlarge) lab(1 "0") lab(2 "1") title("ENDS MLSA")) legend(ring(2) pos(6) rows(1) order(1 2))"
                    local fcolor gs10
                }
            }

            replace   `ind_var' = . if `ind_var' == 0

            foreach yr of local year_list {

                forval legend_iter = 0/1 {
                    // legend_iter-specific
                    {
                        if `legend_iter'==0 local legend_name
                        if `legend_iter'==1 local legend_name 1

                        if "`ind_var'"=="any_mlsa_vape" & `yr'!=2010 & `legend_iter'==1 continue
                        if "`ind_var'"!="any_mlsa_vape" & `yr'!=2023 & `legend_iter'==1 continue
                        
                        if "`ind_var'"!="any_mlsa_vape" {
                            if `legend_iter' == 1 {
                                local legend_di `legend'
                                local asp_ratio "xsize(3.5) ysize(2)"
                            }
                            if `legend_iter' == 0 {
                                local legend_di legend(off)
                                local asp_ratio "xsize(3) ysize(2.2)"
                                * plotregion(margin(zero)) graphregion(margin(zero))
                            }
                        }
                        if "`ind_var'"=="any_mlsa_vape" {
                                if `legend_iter' == 1 {
                                local legend_di `legend'
                                local asp_ratio "xsize(3.5) ysize(2)"
                            }
                            if `legend_iter' == 0 {
                                local legend_di legend(off)
                                local asp_ratio "xsize(3) ysize(2.2)"
                            }
                        }
                    }
                    
                    spmap `ind_var' using "data/raw/map/stateUS_coord" ///
                    if year_true == `yr', /// 
                    id(id) fcolor(`fcolor') clmethod(`clmethod') `clbreaks' ///
                    `legend_di' ndpattern(dash) ocolor(gs4) `asp_ratio'

                    graph export "output/etax/graphs/final/map_`ind_var_name'_`yr'`legend_name'.png", replace
                    graph close
                }
            }
            
            restore
        }
    }

    // notes
    /*
        for regular maps:
        Set ‘spmap’ aspect ratio to 2.2x3. 
        Paste .png files into Word doc. 
        Then size up .png to 2.8 x 3. 
        Then crop margins.

        for maps with legend:
        Set ‘spmap’ ratio to 2x3.5. 
        Paste .png into Word. 
        Then size up to 2.8x3.5. 
        Then crop margins to get back to 2x3.5
    */
}

// TWFE event study (w/ reg code)
if 1 {
    // ENDS taxes, VERSION 42 - construct from semester-based (-5+ to 2+)
    if 1 {
        use "data/final/master_set_2023", clear

        global dem_control i.sex i.grade i.age i.race4

        // denote essential controls (***)
        {
            local vars_essential_coef1 /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale
            local vars_essential_coef0 c.uer c.coviddeaths c.populationvaccinated $dem_control

            local events     s2wF3_ends s2wF2_ends s2wF1_ends    s2wL0_ends s2wL1_ends
            local events_adj s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends
            tokenize "`events'"
        }
        
        local samp_event "lgbq_1==0 lgbq_1==1 !mi(lgbq_1)"		
       
        eststo    clear
        estimates clear

        
        foreach survey in st com nat {
            // survey-specifics
            {
                if "`survey'"=="st" {
                    local weight aweight
                    local technical
                }
                if "`survey'"=="com" {
                    local weight cweight
                    local technical i.national
                }
                if "`survey'"=="nat" {
                    local weight bweight
                    local technical 
                }
            }
        foreach yr in 5 1 {
        foreach vari in vape smoke combust {
            // skip patterns
            {
                if ("`vari'"=="vape") & (`yr'==1 | "`survey'"=="com") continue
                
                if "`survey'"=="nat" & "`vari'"!="vape" continue 
            }

            use "data/final/master_set_2023", clear
            
            // trim data
            {
                if "`survey'"=="st"  keep if !national
                if "`survey'"=="nat" keep if  national

                if "`vari'"=="vape"  keep if inrange(year,2015,2023)
                if "`vari'"=="smoke" keep if inrange(year,201`yr',2023)
            }

            // gen biennial events
            {
                gen     s2wF3_ends = s1F10_ends + s1F9_ends					     	// [-5+]
                gen     s2wF2_ends = s1F8_ends  + s1F7_ends + s1F6_ends + s1F5_ends // [-4,-3]
                gen     s2wF1_ends = s1F4_ends  + s1F3_ends + s1F2_ends + s1F1_ends // [-2,-1]
                gen     s2wL0_ends = s1L0_ends  + s1L1_ends + s1L2_ends + s1L3_ends // [0,1]
                gen     s2wL1_ends = s1L4_ends  + s1L5_ends	         		     	// [2+]

                gen     s2wF1_ends_og = s2wF1_ends                                  // [-2-1] not to zero
                replace s2wF1_ends = 0                                              // [-2-1] --> zero
            }

            // create hetero indicator for differential
            {
                gen     hetero = .
                replace hetero = 0 if lgbq_1==1
                replace hetero = 1 if lgbq_1==0
            }

            foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "lgbq_1==0" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq_1==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"
                
                    // shortened name for combined yrbs
                    if "`survey'"=="com" local sname nh1
                    }
                    if "`subsample'"=="!mi(lgbq_1)" {
                    local sname "all"

                    if inlist("`survey'","com","nat") | `yr'==1 | inlist("`vari'","smoke","combust") ///
                    continue
                    }
                }

                foreach var in `vari' f`vari' d`vari' {
                    // denote LASSO controls (***)
                    {
                        if inlist("`var'","vape","fvape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'}

                        else ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'y`yr'}
                    }
                forval m = 1/3 {       
                    if "`sname'"=="all" & `m'!=1 continue         
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel'

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel' c.tally_sexualorientation 
                    }
                    
                    if 1 { // estimation
                        if "`sname'"!="all" {
                        // OLS
                        _eststo eso_`survey'y`yr'_`var'_`m'_`sname': ///
                        reghdfe `var' ///
                        `events' /// 
                        `vars_controls' ///
                        if `subsample' ///
                        [aw=`weight'], ///
                        absorb(fips year_true semester `technical') ///
                        vce(cluster fips) nosample

                        // logit
                        logit `var' ///
                        `events' /// 
                        `vars_controls' ///
                        i.fips i.year_true i.semester `technical' if `subsample' ///
                        [pw=`weight'], vce(cluster fips) iterate(15)

                        scalar converge_pre = e(converged)
                        local converge = e(converged)

                        _eststo es_`survey'y`yr'_`var'_`m'_`sname': ///
                        margins, dydx(`events') post
                        estadd scalar converge = converge_pre

                        // delta method averaging
                        {
                            xlincom ///
                            ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -5+   lead
                            (          (_b[`2'] + _b[`3']) / 2) /// -4,-3 lead
                            (                    (_b[`3']) / 1) /// -2,-1 lead
                            ((_b[`4'])                     / 1) ///  0,1  lag   
                            ((_b[`4'] + _b[`5'])           / 2) ///  2+  lag
                            , post level(95)
                            _eststo esd_`survey'y`yr'_`var'_`m'_`sname'
                        }

                        // average of pre-treatment period as reference (logit)
                        {
                            // a0: don't include -2-1 in average
                            estimates restore es_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[`1'] + _b[`2']) / 2)

                            xlincom ///
                            (_b[`1'] - `preavg') /// -5+  lead
                            (_b[`2'] - `preavg') /// -4-3 lead
                            (_b[`3'])            /// -2-1 lead
                            (_b[`4'] - `preavg') /// 01   lag
                            (_b[`5'] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo esa0_`survey'y`yr'_`var'_`m'_`sname'


                            // a1: include -2-1 in average
                            estimates restore es_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg  = ((_b[`1'] + _b[`2'] + _b[`3']) / 3)

                            xlincom ///
                            (_b[`1'] - `preavg') /// -5+  lead
                            (_b[`2'] - `preavg') /// -4-3 lead
                            (_b[`3'])            /// -2-1 lead
                            (_b[`4'] - `preavg') /// 01   lag
                            (_b[`5'] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo esa1_`survey'y`yr'_`var'_`m'_`sname'

                            macro drop _preavg
                        }
                        }
                        
                        // constrained linear regression ('cnsreg')
                        {
                            constraint 1 (s2wF3_ends + s2wF2_ends + s2wF1_ends_og) / 3 = 0

                            _eststo esc_`survey'y`yr'_`var'_`m'_`sname': ///
                            cnsreg `var' ///
                            `events_adj' /// 
                            `vars_controls' ///
                            i.fips i.year_true i.semester `technical' if `subsample' ///
                            [pw=`weight'], constraints(1) vce(cluster fips)
                        }
                    }
                }
                }
            }	
            graph drop _all	

            if inlist("`survey'","st","com") estwrite _all using "log/estimates/eventstudy_v42.sters", append
            if "`survey'"=="nat"             estwrite _all using "log/estimates/eventstudy_v42_nat.sters", append

            eststo clear
            estimates clear
        }
        }
        }

        // graphing
        if 0 {
            eststo clear
            estimates clear                

            foreach survey in st com nat {
            foreach yr in 5 1 {
            foreach subsample in id_ht id_nh1 all {

                if ("`survey'"!="st" | `yr'!=5) & "`subsample'"=="all" continue
                
                if "`survey'"=="nat" {
                    estread *`survey'y`yr'*`subsample' using "log/estimates/eventstudy_v42_nat.sters"
                } 

                else {
                    estread *`survey'y`yr'*`subsample' using "log/estimates/eventstudy_v42.sters"
                    if "`subsample'"=="id_nh1" estread *`survey'y`yr'*nh1 using "log/estimates/eventstudy_v42.sters"
                }

                // subsample-specific
                {
                    local sname `subsample'
                    if "`survey'"=="com" & "`subsample'"=="id_nh1" local sname nh1
                }
                foreach var in vape fvape dvape smoke fsmoke dsmoke combust fcombust dcombust {
                    if inlist("`var'","vape","fvape","dvape") & ("`survey'"=="com" | `yr'==1) continue
                    if "`survey'"=="nat" & !inlist("`var'","vape","fvape","dvape") continue
                forval m = 1/3 {
                foreach adj of numlist 0 1 4 5 8 {
                    if "`subsample'"=="all" & (!inlist("`var'","vape","fvape","dvape") | `m'!=1 | `adj'!=4) continue

                    // adj-specifics
                    {
                        if `adj'==0 {
                            local name_adj
                            local list_events s2wF3_ends s2wF2_ends s2wF1_ends s2wL0_ends s2wL1_ends
                        }
                        if `adj'==1 {
                            local name_adj d
                        }
                        if `adj'==2 {
                            local name_adj a0
                        }
                        if `adj'==3 {
                            local name_adj a1
                        }
                        if `adj'==4 {
                            local name_adj c
                            local list_events s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends
                        }
                        if `adj'==5 {
                            local name_adj o
                            local list_events s2wF3_ends s2wF2_ends s2wF1_ends s2wL0_ends s2wL1_ends
                        }
                        if `adj'==6 { // OLS pre-treat reference, exclusive
                            // o0: don't include -2-1 in average
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[s2wF3_ends] + _b[s2wF2_ends]) / 2)

                            xlincom ///
                            (_b[s2wF3_ends] - `preavg') /// -5+  lead
                            (_b[s2wF2_ends] - `preavg') /// -4-3 lead
                            (_b[s2wF1_ends])            /// -2-1 lead
                            (_b[s2wL0_ends] - `preavg') /// 01   lag
                            (_b[s2wL1_ends] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo eso0_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj o0
                        }
                        if `adj'==7 { // OLS pre-treat reference, inclusive
                            // o1: include -2-1 in average
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[s2wF3_ends] + _b[s2wF2_ends] + _b[s2wF1_ends]) / 3)

                            xlincom ///
                            (_b[s2wF3_ends] - `preavg') /// -5+  lead
                            (_b[s2wF2_ends] - `preavg') /// -4-3 lead
                            (_b[s2wF1_ends])            /// -2-1 lead
                            (_b[s2wL0_ends] - `preavg') /// 01   lag
                            (_b[s2wL1_ends] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo eso1_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj o1
                        }
                        if `adj'==8 { // od: OLS "delta method"
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            xlincom ///
                            ((_b[s2wF3_ends] + _b[s2wF2_ends] + _b[s2wF1_ends]) / 3) /// -5+   lead
                            (                 (_b[s2wF2_ends] + _b[s2wF1_ends]) / 2) /// -4,-3 lead
                            (                                  (_b[s2wF1_ends]) / 1) /// -2,-1 lead
                            ((_b[s2wL0_ends])                                   / 1) ///  0,1  lag   
                            ((_b[s2wL0_ends] + _b[s2wL1_ends])                  / 2) ///  2+  lag
                            , post level(95)
                            _eststo esod_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj od
                        }

                        if inlist(`adj',1,2,3,6,7,8) local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                    }

                    // parameters
                    {
                        // y-axis
                        if "`var'" == "vape" local ysca yla(-0.150(0.050)0.150, nogrid) 
                        if "`var'" != "vape" local ysca yla(-0.075(0.025)0.075, nogrid)

                        if "`subsample'"=="all" {
                            if "`var'" == "vape" local ysca yla(-0.100(0.050)0.100, nogrid) 
                            if "`var'" != "vape" local ysca yla(-0.050(0.025)0.050, nogrid)
                        }

                        if "`survey'"=="com" & `yr'==1 & inlist("`var'","fsmoke","dsmoke") local ysca yla(-0.03(0.010)0.03, nogrid)
                        if "`survey'"=="st"  & `yr'==1 & inlist("`var'","fsmoke","dsmoke") local ysca yla(-0.02(0.005)0.02, nogrid)

                        ***if "`var'" == "combust" local ysca yla()

                        // display convergence
                        estimates restore es`name_adj'_`survey'y`yr'_`var'_`m'_`sname'
                        if e(converge) == 0 local converge_title "Does not converge"
                        else                local converge_title ""
                    }

                    coefplot(es`name_adj'_`survey'y`yr'_`var'_`m'_`sname', ///
                    keep(`list_events') omitted ///
                    recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                    vertical ///
                    title("`converge_local'",) ///
                    graphregion(color(white)) ///
                    ytitle("Estimated Effect of ENDS Tax", size(medium)) ///
                    yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                    xtitle("Years Before/After ENDS Tax Increase", size(medium)) ///
                    xline(3.5, lpattern(dash) lcolor(black)) ///
                    xlabel(1 "{&le} -5" 2 "-4,-3" 3 "-2,1" 4 "0,1" 5 "{&ge} 2", labsize(medium)) ///
                    legend(off) ///
                    ciopts(recast(rcap) lwidth(thin)) 

                    if "`survey'"=="nat" graph export "output/etax/graphs/final/es_nat`name_adj'_v42_`survey'y`yr'_m`m'_`var'_`subsample'.png", replace
                    else                 graph export "output/etax/graphs/final/es`name_adj'_v42_`survey'y`yr'_m`m'_`var'_`subsample'.png", replace
                    graph close		
                }
                }
                }
                estimates clear
            }
            }
            }
        }

        use "data/final/master_set_2023", clear	

        macro drop _name_adj _sname
    }

    // ENDS MLSA event study - relative timing based [v42] (-5+ to 2+)
    if 1 {
        // create events
        {
            use "data/inter/master_control2023_semester", clear
            gen semester_date = yh(year_true, semester)
            format semester_date %th
            keep fips year_true semester semester_date any_mlsa_vape
            sort fips semester_date

            // semester-based, relative time --> biennial (don't assume -1 as reference)
            local version s2w
            foreach main_iv in any_mlsa_vape {
                // find introduction date
                {
                    // first differences
                    bys fips: gen `main_iv'_intro_ = `main_iv'[_n] - `main_iv'[_n-1]
                    replace       `main_iv'_intro_ = 0 if missing(`main_iv'_intro_)

                    // grab dates w/ variation
                    replace `main_iv'_intro_ = semester_date if `main_iv'_intro_ != 0
                    replace `main_iv'_intro_ = .             if `main_iv'_intro_ == 0
                    format  `main_iv'_intro_ %th

                    // take earliest date w/ variation
                    bys fips: egen `main_iv'_intro = min(`main_iv'_intro_)
                    drop           `main_iv'_intro_
                }
                gen `version' = semester_date - `main_iv'_intro

                recode `version'                          ///
                (. = 99)                                  /// code missing as 99
                (-1000/-9 = -3) (-8/-5 = -2) (-4/-1 = -1) ///
                (0/3 = 0)       (4/1000 = 1)

                xi i.`version', noomit

                rename (_I*) (`main_iv'_*)
                rename `main_iv'_`version'_1 `main_iv'_`version'_F3
                rename `main_iv'_`version'_2 `main_iv'_`version'_F2
                rename `main_iv'_`version'_3 `main_iv'_`version'_F1
                rename `main_iv'_`version'_4 `main_iv'_`version'_L0
                rename `main_iv'_`version'_5 `main_iv'_`version'_L1
                // missing as `main_iv'_`version'_6

                drop `version'
            }

            tempfile events_mlsa
            save    `events_mlsa'
        }

        global dem_control i.sex i.grade i.age i.race4

        // denote essential controls (***)
        {
            local vars_essential_coef1 c.ends_tax_nom35_scale c.flavor_ban /*c.any_mlsa_vape*/ i.t21 c.cigarette_tax_scale
            local vars_essential_coef0 c.uer c.coviddeaths c.populationvaccinated $dem_control

            local events     any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1    any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1
            local events_adj any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1
            tokenize "`events'"
        }
        
        local samp_event "lgbq_1==0 lgbq_1==1"		

        eststo    clear
        estimates clear

        foreach survey in st {
            // survey-specifics
            {
                if "`survey'"=="st" {
                    local weight aweight
                    local technical
                }
                if "`survey'"=="com" {
                    local weight cweight
                    local technical i.national
                }
            }
        foreach yr in 5 1 {
        foreach vari in vape smoke {
            // skip patterns
            {
                if ("`vari'"=="vape") & (`yr'==1 | "`survey'"=="com") continue
                if "`vari'"=="vape" & `yr'==1 continue
                if "`vari'"=="smoke" & `yr'==5 continue
            }

            use "data/final/master_set_2023", clear
            
            // trim data
            {
                if "`survey'"=="st"  keep if !national
                if "`vari'"=="vape"  keep if inrange(year,2015,2023)
                if "`vari'"=="smoke" keep if inrange(year,201`yr',2023)
            }

            // merge events, set reference
            {
                merge m:1 fips year_true semester using `events_mlsa'
                drop if _merge==2
                drop    _merge

                gen any_mlsa_vape_s2w_F1_og = any_mlsa_vape_s2w_F1
                replace any_mlsa_vape_s2w_F1 = 0
            }

            foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "lgbq_1==0" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq_1==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"

                    // shortened name for combined yrbs
                    if "`survey'"=="com" local sname nh1
                    }
                }

                foreach var in `vari' f`vari' d`vari' {
                    // denote LASSO controls (***)
                    {
                        if inlist("`var'","vape","fvape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'}

                        else ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'y`yr'}
                    }
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel'

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel' c.tally_sexualorientation 
                    }
                    
                    if 1 { // estimation
                        // OLS
                        _eststo eso_`survey'y`yr'_`var'_`m'_`sname': ///
                        reghdfe `var' ///
                        `events' /// 
                        `vars_controls' ///
                        if `subsample' ///
                        [aw=`weight'], ///
                        absorb(fips year_true semester `technical') ///
                        vce(cluster fips) nosample

                        // logit
                        logit `var' ///
                        `events' /// 
                        `vars_controls' ///
                        i.fips i.year_true i.semester `technical' if `subsample' ///
                        [pw=`weight'], vce(cluster fips) iterate(15)

                        scalar converge_pre = e(converged)
                        local converge = e(converged)

                        _eststo es_`survey'y`yr'_`var'_`m'_`sname': ///
                        margins, dydx(`events') post
                        estadd scalar converge = converge_pre

                        // delta method averaging
                        {
                            xlincom ///
                            ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -5+   lead
                            (          (_b[`2'] + _b[`3']) / 2) /// -4,-3 lead
                            (                    (_b[`3']) / 1) /// -2,-1 lead
                            ((_b[`4'])                     / 1) ///  0,1  lag   
                            ((_b[`4'] + _b[`5'])           / 2) ///  2+  lag
                            , post level(95)
                            _eststo esd_`survey'y`yr'_`var'_`m'_`sname'
                        }

                        // average of pre-treatment period as reference (logit)
                        {
                            // a0: don't include -2-1 in average
                            estimates restore es_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[`1'] + _b[`2']) / 2)

                            xlincom ///
                            (_b[`1'] - `preavg') /// -5+  lead
                            (_b[`2'] - `preavg') /// -4-3 lead
                            (_b[`3'])            /// -2-1 lead
                            (_b[`4'] - `preavg') /// 01   lag
                            (_b[`5'] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo esa0_`survey'y`yr'_`var'_`m'_`sname'


                            // a1: include -2-1 in average
                            estimates restore es_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg  = ((_b[`1'] + _b[`2'] + _b[`3']) / 3)

                            xlincom ///
                            (_b[`1'] - `preavg') /// -5+  lead
                            (_b[`2'] - `preavg') /// -4-3 lead
                            (_b[`3'])            /// -2-1 lead
                            (_b[`4'] - `preavg') /// 01   lag
                            (_b[`5'] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo esa1_`survey'y`yr'_`var'_`m'_`sname'

                            macro drop _preavg
                        }
                        
                        // constrained linear regression ('cnsreg')
                        {
                            constraint 1 (any_mlsa_vape_s2w_F3 + any_mlsa_vape_s2w_F2 + any_mlsa_vape_s2w_F1_og) / 3 = 0

                            _eststo esc_`survey'y`yr'_`var'_`m'_`sname': ///
                            cnsreg `var' ///
                            `events_adj' /// 
                            `vars_controls' ///
                            i.fips i.year_true i.semester `technical' if `subsample' ///
                            [pw=`weight'], constraints(1) vce(cluster fips)
                        }
                    }
                }
                }
            }	
            graph drop _all	

            estwrite _all using "log/estimates/eventstudy_mlsa_v42.sters", append
            
            eststo clear
            estimates clear
        }
        }
        }


        // graphing 
        if 0 {
            eststo clear
            estimates clear                

            foreach survey in st {
            foreach yr in 5 {
            foreach subsample in id_ht id_nh1 {

                estread *`survey'y`yr'*`subsample' using "log/estimates/eventstudy_mlsa_v42.sters"
                if "`subsample'"=="id_nh1" estread *`survey'y`yr'*nh1 using "log/estimates/eventstudy_mlsa_v42.sters"

                // subsample-specific
                {
                    local sname `subsample'
                    if "`survey'"=="com" & "`subsample'"=="id_nh1" local sname nh1
                }
                foreach var in vape fvape dvape {
                    if inlist("`var'","vape","fvape","dvape") & ("`survey'"=="com" | `yr'==1) continue
                forval m = 1/3 {
                foreach adj of numlist 0 1 4 5 8 {
                    // adj-specifics
                    {
                        if `adj'==0 {
                            local name_adj
                            local list_events any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1 any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1
                        }
                        if `adj'==1 {
                            local name_adj d
                        }
                        if `adj'==2 {
                            local name_adj a0
                        }
                        if `adj'==3 {
                            local name_adj a1
                        }
                        if `adj'==4 {
                            local name_adj c
                            local list_events any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1
                        }
                        if `adj'==5 {
                            local name_adj o
                            local list_events any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1 any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1
                        }
                        if `adj'==6 { // OLS pre-treat reference, exclusive
                            // o0: don't include -2-1 in average
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[any_mlsa_vape_s2w_F3] + _b[any_mlsa_vape_s2w_F2]) / 2)

                            xlincom ///
                            (_b[any_mlsa_vape_s2w_F3] - `preavg') /// -5+  lead
                            (_b[any_mlsa_vape_s2w_F2] - `preavg') /// -4-3 lead
                            (_b[any_mlsa_vape_s2w_F1])            /// -2-1 lead
                            (_b[any_mlsa_vape_s2w_L0] - `preavg') /// 01   lag
                            (_b[any_mlsa_vape_s2w_L1] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo eso0_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj o0
                        }
                        if `adj'==7 { // OLS pre-treat reference, inclusive
                            // o1: include -2-1 in average
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[any_mlsa_vape_s2w_F3] + _b[any_mlsa_vape_s2w_F2] + _b[any_mlsa_vape_s2w_F1]) / 3)

                            xlincom ///
                            (_b[any_mlsa_vape_s2w_F3] - `preavg') /// -5+  lead
                            (_b[any_mlsa_vape_s2w_F2] - `preavg') /// -4-3 lead
                            (_b[any_mlsa_vape_s2w_F1])            /// -2-1 lead
                            (_b[any_mlsa_vape_s2w_L0] - `preavg') /// 01   lag
                            (_b[any_mlsa_vape_s2w_L1] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo eso1_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj o1
                        }
                        if `adj'==8 { // od: OLS "delta method"
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            xlincom ///
                            ((_b[any_mlsa_vape_s2w_F3] + _b[any_mlsa_vape_s2w_F2] + _b[any_mlsa_vape_s2w_F1]) / 3) /// -5+   lead
                            (                           (_b[any_mlsa_vape_s2w_F2] + _b[any_mlsa_vape_s2w_F1]) / 2) /// -4,-3 lead
                            (                                                      (_b[any_mlsa_vape_s2w_F1]) / 1) /// -2,-1 lead
                            ((_b[any_mlsa_vape_s2w_L0])                                                       / 1) ///  0,1  lag   
                            ((_b[any_mlsa_vape_s2w_L0] + _b[any_mlsa_vape_s2w_L1])                            / 2) ///  2+  lag
                            , post level(95)
                            _eststo esod_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj od
                        }

                        if inlist(`adj',1,2,3,6,7,8) local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                    }

                    // parameters
                    {
                        // y-axis
                        if "`var'" == "vape" local ysca yla(-0.150(0.050)0.150, nogrid) 
                        if "`var'" != "vape" local ysca yla(-0.075(0.025)0.075, nogrid)

                        ***if "`var'" == "combust" local ysca yla()

                        // display convergence
                        estimates restore es`name_adj'_`survey'y`yr'_`var'_`m'_`sname'
                        if e(converge) == 0 local converge_title "Does not converge"
                        else                local converge_title ""
                    }

                    coefplot(es`name_adj'_`survey'y`yr'_`var'_`m'_`sname', ///
                    keep(`list_events') omitted ///
                    recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                    vertical ///
                    title("`converge_local'",) ///
                    graphregion(color(white)) ///
                    ytitle("Estimated Effect of ENDS MLSA", size(medium)) ///
                    yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                    xtitle("Years Before/After ENDS Tax Increase", size(medium)) ///
                    xline(3.5, lpattern(dash) lcolor(black)) ///
                    xlabel(1 "{&le} -5" 2 "-4,-3" 3 "-2,1" 4 "0,1" 5 "{&ge} 2", labsize(medium)) ///
                    legend(off) ///
                    ciopts(recast(rcap) lwidth(thin)) 

                    graph export "output/etax/graphs/final/es`name_adj'_mlsa_v42_`survey'y`yr'_m`m'_`var'_`subsample'.png", replace
                    graph close		
                }
                }
                }
                estimates clear
            }
            }
            }
        }

        use "data/final/master_set_2023", clear
    }

    // flavor ban event study (regression run in '03_reg_main.do')
    if 0 {
        // graphing 
        {
            eststo clear
            estimates clear                

            foreach survey in st {
            foreach yr in 5 {
            foreach subsample in id_ht id_nh1 {
                
                forval model = 1/3 {
                estread *_?l4l_`subsample'* using "log/estimates/other_pol_v2_y`yr'3`survey'`model'l" // logit
                estread *_?4l_`subsample'*  using "log/estimates/other_pol_v2_y`yr'3`survey'`model'"  // ols
                estread *_?c4l_`subsample'* using "log/estimates/other_pol_v2_y`yr'3`survey'`model'c" // cnsreg
                }

                // subsample-specific
                {
                    local sname `subsample'
                    if "`survey'"=="com" & "`subsample'"=="id_nh1" local sname nh1
                }

                foreach var in vape fvape dvape {
                    if inlist("`var'","vape","fvape","dvape") & ("`survey'"=="com" | `yr'==1) continue
                forval m = 1/3 {
                foreach adj of numlist 0 1 4 5 8 {
                    // adj-specifics
                    {
                        if `adj'==0 { // logit
                            local name_adj l
                            local name_disp  
                            local list_events flav_lead5_plus flav_lead4_3 flav_lead2_1 flav_lag0_1 flav_lag2_plus
                        }
                        if `adj'==1 { // logit "delta method"
                            estimates restore `var'_`m'l4l_`sname'y`yr'3_`survey'

                            xlincom ///
                            ((_b[flav_lead5_plus] + _b[flav_lead4_3] + _b[flav_lead2_1]) / 3) /// -5+   lead
                            (                      (_b[flav_lead4_3] + _b[flav_lead2_1]) / 2) /// -4,-3 lead
                            (                                         (_b[flav_lead2_1]) / 1) /// -2,-1 lead
                            ((_b[flav_lag0_1])                                           / 1) ///  0,1  lag   
                            ((_b[flav_lag0_1] + _b[flav_lag2_plus])                      / 2) ///  2+  lag
                            , post level(95)
                            _eststo `var'_`m'ld4l_`sname'y`yr'3_`survey'

                            local name_adj ld
                            local name_disp d
                        }
                        if `adj'==4 { // cnsreg
                            local name_adj c
                            local name_disp c
                            local list_events flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus
                        }
                        if `adj'==5 { // OLS
                            local name_adj
                            local name_disp o
                            local list_events flav_lead5_plus flav_lead4_3 flav_lead2_1 flav_lag0_1 flav_lag2_plus
                        }
                        if `adj'==8 { // od: OLS "delta method"
                            estimates restore `var'_`m'4l_`sname'y`yr'3_`survey'

                            xlincom ///
                            ((_b[flav_lead5_plus] + _b[flav_lead4_3] + _b[flav_lead2_1]) / 3) /// -5+   lead
                            (                      (_b[flav_lead4_3] + _b[flav_lead2_1]) / 2) /// -4,-3 lead
                            (                                         (_b[flav_lead2_1]) / 1) /// -2,-1 lead
                            ((_b[flav_lag0_1])                                           / 1) ///  0,1  lag   
                            ((_b[flav_lag0_1] + _b[flav_lag2_plus])                      / 2) ///  2+  lag
                            , post level(95)
                            _eststo `var'_`m'd4l_`sname'y`yr'3_`survey'

                            local name_adj d
                            local name_disp od
                        }

                        // use 'name_adj' and 'name_disp' to accommodate differences b/w main ES regs and other_pol regs

                        if inlist(`adj',1,2,3,6,7,8) local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                    }

                    // parameters
                    {
                        // y-axis
                        if "`var'" == "vape" local ysca yla(-0.150(0.050)0.150, nogrid) 
                        if "`var'" != "vape" local ysca yla(-0.075(0.025)0.075, nogrid)

                        ***if "`var'" == "combust" local ysca yla()

                        // display convergence
                        estimates restore `var'_`m'`name_adj'4l_`sname'y`yr'3_`survey'
                        if e(converge) == 0 local converge_title "Does not converge"
                        else                local converge_title ""
                    }

                    coefplot(`var'_`m'`name_adj'4l_`sname'y`yr'3_`survey', ///
                    keep(`list_events') omitted ///
                    recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                    vertical ///
                    title("`converge_local'",) ///
                    graphregion(color(white)) ///
                    ytitle("Estimated Effect of ENDS Flavor Bans", size(medium)) ///
                    yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                    xtitle("Years Before/After ENDS Tax Increase", size(medium)) ///
                    xline(3.5, lpattern(dash) lcolor(black)) ///
                    xlabel(1 "{&le} -5" 2 "-4,-3" 3 "-2,1" 4 "0,1" 5 "{&ge} 2", labsize(medium)) ///
                    legend(off) ///
                    ciopts(recast(rcap) lwidth(thin)) 

                    graph export "output/etax/graphs/final/es`name_disp'_flavor_v42_`survey'y`yr'_m`m'_`var'_`subsample'.png", replace
                    graph close		
                }
                }
                }
                estimates clear
            }
            }
            }
        }
    }

    // cigarette tax event study
    if 1 {
        // create events
        {
            use "data/inter/master_control2023_semester", clear
            gen semester_date = yh(year_true, semester)
            format semester_date %th
            keep fips year_true semester semester_date cigarette_tax_scale
            sort fips semester_date

            // semester-based (-10+ to 5+), schmidheiny and siegloch
            foreach main_iv in cigarette_tax_scale {
                bys fips: gen L0 = `main_iv'[_n] - `main_iv'[_n-1]
                replace       L0 = 0 if mi(L0)

                // lags
                forval i = 0/5 {
                    bys fips: gen `main_iv'_s1L`i' = L0[_n - `i']
                    replace       `main_iv'_s1L`i' = 0 if mi(`main_iv'_s1L`i')
                    if `i'==5 { // endpoint
                        bys fips: gen sum_`main_iv'_s1L`i' = sum(`main_iv'_s1L`i')
                        replace           `main_iv'_s1L`i' = sum_`main_iv'_s1L`i'
                        drop          sum_`main_iv'_s1L`i'
                    }
                }

                // leads
                forval i = 1/10 {
                    bys fips: gen `main_iv'_s1F`i' = L0[_n + `i']
                    replace       `main_iv'_s1F`i' = 0 if mi(`main_iv'_s1F`i')
                    if `i'==10 { // endpoint
                        gsort fips -year_true -semester
                        
                        bys fips: gen sum_`main_iv'_s1F`i' = sum(`main_iv'_s1F`i')
                        replace           `main_iv'_s1F`i' = sum_`main_iv'_s1F`i'
                        drop          sum_`main_iv'_s1F`i' 
                    }
                    sort fips year_true semester
                }

                order ///
                `main_iv'_s1F10 `main_iv'_s1F9 `main_iv'_s1F8 `main_iv'_s1F7 `main_iv'_s1F6 ///
                `main_iv'_s1F5  `main_iv'_s1F4 `main_iv'_s1F3 `main_iv'_s1F2 `main_iv'_s1F1 ///
                , after(L0)

                drop L0

            }

            tempfile events_cigtax
            save    `events_cigtax'
        }

        global dem_control i.sex i.grade i.age i.race4

        // denote essential controls (***)
        {
            local vars_essential_coef1 c.ends_tax_nom35_scale c.flavor_ban c.any_mlsa_vape i.t21 /*c.cigarette_tax_scale*/
            local vars_essential_coef0 c.uer c.coviddeaths c.populationvaccinated $dem_control

            local events     cigarette_tax_scale_s2w_F3 cigarette_tax_scale_s2w_F2 cigarette_tax_scale_s2w_F1    cigarette_tax_scale_s2w_L0 cigarette_tax_scale_s2w_L1
            local events_adj cigarette_tax_scale_s2w_F3 cigarette_tax_scale_s2w_F2 cigarette_tax_scale_s2w_F1_og cigarette_tax_scale_s2w_L0 cigarette_tax_scale_s2w_L1
            tokenize "`events'"
        }
        
        local samp_event "lgbq_1==0 lgbq_1==1"		

        eststo    clear
        estimates clear

        foreach survey in st {
            // survey-specifics
            {
                if "`survey'"=="st" {
                    local weight aweight
                    local technical
                }
                if "`survey'"=="com" {
                    local weight cweight
                    local technical i.national
                }
            }
        foreach yr in 5 1 {
        foreach vari in vape smoke {
            // skip patterns
            {
                if ("`vari'"=="vape") & (`yr'==1 | "`survey'"=="com") continue
                if "`vari'"=="vape" & `yr'==1 continue
                if "`vari'"=="smoke" & `yr'==5 continue
            }

            use "data/final/master_set_2023", clear
            
            // trim data
            {
                if "`survey'"=="st"  keep if !national
                if "`vari'"=="vape"  keep if inrange(year,2015,2023)
                if "`vari'"=="smoke" keep if inrange(year,201`yr',2023)
            }

            // merge events, create biennial events, set reference
            {
                // merge
                merge m:1 fips year_true semester using `events_cigtax'
                drop if _merge==2
                drop    _merge

                // create
                gen cigarette_tax_scale_s2w_F3 = cigarette_tax_scale_s1F10 + cigarette_tax_scale_s1F9					     	                            // [-5+]
                gen cigarette_tax_scale_s2w_F2 = cigarette_tax_scale_s1F8  + cigarette_tax_scale_s1F7 + cigarette_tax_scale_s1F6 + cigarette_tax_scale_s1F5 // [-4,-3]
                gen cigarette_tax_scale_s2w_F1 = cigarette_tax_scale_s1F4  + cigarette_tax_scale_s1F3 + cigarette_tax_scale_s1F2 + cigarette_tax_scale_s1F1 // [-2,-1]
                gen cigarette_tax_scale_s2w_L0 = cigarette_tax_scale_s1L0  + cigarette_tax_scale_s1L1 + cigarette_tax_scale_s1L2 + cigarette_tax_scale_s1L3 // [0,1]
                gen cigarette_tax_scale_s2w_L1 = cigarette_tax_scale_s1L4  + cigarette_tax_scale_s1L5	         		     	                            // [2+]

                // set reference
                gen cigarette_tax_scale_s2w_F1_og = cigarette_tax_scale_s2w_F1
                replace cigarette_tax_scale_s2w_F1 = 0
            }

            foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "lgbq_1==0" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq_1==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"

                    // shortened name for combined yrbs
                    if "`survey'"=="com" local sname nh1
                    }
                }

                foreach var in `vari' f`vari' d`vari' {
                    // denote LASSO controls (***)
                    {
                        if inlist("`var'","vape","fvape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'}

                        else ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'y`yr'}
                    }
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel'

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel' c.tally_sexualorientation 
                    }
                    
                    if 1 { // estimation
                        // OLS
                        _eststo eso_`survey'y`yr'_`var'_`m'_`sname': ///
                        reghdfe `var' ///
                        `events' /// 
                        `vars_controls' ///
                        if `subsample' ///
                        [aw=`weight'], ///
                        absorb(fips year_true semester `technical') ///
                        vce(cluster fips) nosample

                        // logit
                        logit `var' ///
                        `events' /// 
                        `vars_controls' ///
                        i.fips i.year_true i.semester `technical' if `subsample' ///
                        [pw=`weight'], vce(cluster fips) iterate(15)

                        scalar converge_pre = e(converged)
                        local converge = e(converged)

                        _eststo es_`survey'y`yr'_`var'_`m'_`sname': ///
                        margins, dydx(`events') post
                        estadd scalar converge = converge_pre

                        // delta method averaging
                        {
                            xlincom ///
                            ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -5+   lead
                            (          (_b[`2'] + _b[`3']) / 2) /// -4,-3 lead
                            (                    (_b[`3']) / 1) /// -2,-1 lead
                            ((_b[`4'])                     / 1) ///  0,1  lag   
                            ((_b[`4'] + _b[`5'])           / 2) ///  2+  lag
                            , post level(95)
                            _eststo esd_`survey'y`yr'_`var'_`m'_`sname'
                        }

                        // average of pre-treatment period as reference (logit)
                        {
                            // a0: don't include -2-1 in average
                            estimates restore es_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[`1'] + _b[`2']) / 2)

                            xlincom ///
                            (_b[`1'] - `preavg') /// -5+  lead
                            (_b[`2'] - `preavg') /// -4-3 lead
                            (_b[`3'])            /// -2-1 lead
                            (_b[`4'] - `preavg') /// 01   lag
                            (_b[`5'] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo esa0_`survey'y`yr'_`var'_`m'_`sname'


                            // a1: include -2-1 in average
                            estimates restore es_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg  = ((_b[`1'] + _b[`2'] + _b[`3']) / 3)

                            xlincom ///
                            (_b[`1'] - `preavg') /// -5+  lead
                            (_b[`2'] - `preavg') /// -4-3 lead
                            (_b[`3'])            /// -2-1 lead
                            (_b[`4'] - `preavg') /// 01   lag
                            (_b[`5'] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo esa1_`survey'y`yr'_`var'_`m'_`sname'

                            macro drop _preavg
                        }
                        
                        // constrained linear regression ('cnsreg')
                        {
                            constraint 1 (cigarette_tax_scale_s2w_F3 + cigarette_tax_scale_s2w_F2 + cigarette_tax_scale_s2w_F1_og) / 3 = 0

                            _eststo esc_`survey'y`yr'_`var'_`m'_`sname': ///
                            cnsreg `var' ///
                            `events_adj' /// 
                            `vars_controls' ///
                            i.fips i.year_true i.semester `technical' if `subsample' ///
                            [pw=`weight'], constraints(1) vce(cluster fips)
                        }
                    }
                }
                }
            }	
            graph drop _all	
            estwrite _all using "log/estimates/eventstudy_cigtax_v42.sters", append
            
            eststo clear
            estimates clear
        }
        }
        }


        // graphing 
        if 0 {
            eststo clear
            estimates clear                

            foreach survey in st {
            foreach yr in 5 {
            foreach subsample in id_ht id_nh1 {

                estread *`survey'y`yr'*`subsample' using "log/estimates/eventstudy_cigtax_v42.sters"
                if "`subsample'"=="id_nh1" estread *`survey'y`yr'*nh1 using "log/estimates/eventstudy_cigtax_v42.sters"

                // subsample-specific
                {
                    local sname `subsample'
                    if "`survey'"=="com" & "`subsample'"=="id_nh1" local sname nh1
                }
                foreach var in vape fvape dvape {
                    if inlist("`var'","vape","fvape","dvape") & ("`survey'"=="com" | `yr'==1) continue
                forval m = 1/3 {
                foreach adj of numlist 0 1 4 5 8 {
                    // adj-specifics
                    {
                        if `adj'==0 {
                            local name_adj
                            local list_events any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1 any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1
                        }
                        if `adj'==1 {
                            local name_adj d
                        }
                        if `adj'==2 {
                            local name_adj a0
                        }
                        if `adj'==3 {
                            local name_adj a1
                        }
                        if `adj'==4 {
                            local name_adj c
                            local list_events any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1
                        }
                        if `adj'==5 {
                            local name_adj o
                            local list_events any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1 any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1
                        }
                        if `adj'==6 { // OLS pre-treat reference, exclusive
                            // o0: don't include -2-1 in average
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[any_mlsa_vape_s2w_F3] + _b[any_mlsa_vape_s2w_F2]) / 2)

                            xlincom ///
                            (_b[any_mlsa_vape_s2w_F3] - `preavg') /// -5+  lead
                            (_b[any_mlsa_vape_s2w_F2] - `preavg') /// -4-3 lead
                            (_b[any_mlsa_vape_s2w_F1])            /// -2-1 lead
                            (_b[any_mlsa_vape_s2w_L0] - `preavg') /// 01   lag
                            (_b[any_mlsa_vape_s2w_L1] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo eso0_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj o0
                        }
                        if `adj'==7 { // OLS pre-treat reference, inclusive
                            // o1: include -2-1 in average
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[any_mlsa_vape_s2w_F3] + _b[any_mlsa_vape_s2w_F2] + _b[any_mlsa_vape_s2w_F1]) / 3)

                            xlincom ///
                            (_b[any_mlsa_vape_s2w_F3] - `preavg') /// -5+  lead
                            (_b[any_mlsa_vape_s2w_F2] - `preavg') /// -4-3 lead
                            (_b[any_mlsa_vape_s2w_F1])            /// -2-1 lead
                            (_b[any_mlsa_vape_s2w_L0] - `preavg') /// 01   lag
                            (_b[any_mlsa_vape_s2w_L1] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo eso1_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj o1
                        }
                        if `adj'==8 { // od: OLS "delta method"
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            xlincom ///
                            ((_b[any_mlsa_vape_s2w_F3] + _b[any_mlsa_vape_s2w_F2] + _b[any_mlsa_vape_s2w_F1]) / 3) /// -5+   lead
                            (                           (_b[any_mlsa_vape_s2w_F2] + _b[any_mlsa_vape_s2w_F1]) / 2) /// -4,-3 lead
                            (                                                      (_b[any_mlsa_vape_s2w_F1]) / 1) /// -2,-1 lead
                            ((_b[any_mlsa_vape_s2w_L0])                                                       / 1) ///  0,1  lag   
                            ((_b[any_mlsa_vape_s2w_L0] + _b[any_mlsa_vape_s2w_L1])                            / 2) ///  2+  lag
                            , post level(95)
                            _eststo esod_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj od
                        }

                        if inlist(`adj',1,2,3,6,7,8) local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                    }

                    // parameters
                    {
                        // y-axis
                        if "`var'" == "vape" local ysca yla(-0.150(0.050)0.150, nogrid) 
                        if "`var'" != "vape" local ysca yla(-0.075(0.025)0.075, nogrid)

                        ***if "`var'" == "combust" local ysca yla()

                        // display convergence
                        estimates restore es`name_adj'_`survey'y`yr'_`var'_`m'_`sname'
                        if e(converge) == 0 local converge_title "Does not converge"
                        else                local converge_title ""
                    }

                    coefplot(es`name_adj'_`survey'y`yr'_`var'_`m'_`sname', ///
                    keep(`list_events') omitted ///
                    recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                    vertical ///
                    title("`converge_local'",) ///
                    graphregion(color(white)) ///
                    ytitle("Estimated Effect of ENDS MLSA", size(medium)) ///
                    yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                    xtitle("Years Before/After ENDS Tax Increase", size(medium)) ///
                    xline(3.5, lpattern(dash) lcolor(black)) ///
                    xlabel(1 "{&le} -5" 2 "-4,-3" 3 "-2,1" 4 "0,1" 5 "{&ge} 2", labsize(medium)) ///
                    legend(off) ///
                    ciopts(recast(rcap) lwidth(thin)) 

                    graph export "output/etax/graphs/final/es`name_adj'_cigtax_v42_`survey'y`yr'_m`m'_`var'_`subsample'.png", replace
                    graph close		
                }
                }
                }
                estimates clear
            }
            }
            }
        }

        use "data/final/master_set_2023", clear
    }

    // unweighted ES - construct from semester-based [v42] (-5+ to 2+)
    if 1 {
        use "data/final/master_set_2023", clear

        global dem_control i.sex i.grade i.age i.race4

        // denote essential controls (***)
        {
            local vars_essential_coef1 /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale
            local vars_essential_coef0 c.uer c.coviddeaths c.populationvaccinated $dem_control

            local events     c.s2wF3_ends c.s2wF2_ends c.s2wF1_ends    c.s2wL0_ends c.s2wL1_ends
            local events_adj c.s2wF3_ends c.s2wF2_ends c.s2wF1_ends_og c.s2wL0_ends c.s2wL1_ends
            tokenize "`events'"
        }
        
        local samp_event "1 !mi(lgbq_1)"

        eststo    clear
        estimates clear

        
        foreach survey in st {
            // survey-specifics
            {
                if "`survey'"=="st" {
                    local weight aweight
                    local technical
                }
                if "`survey'"=="com" {
                    local weight cweight
                    local technical i.national
                }
            }
        foreach yr in 5 1 {
        foreach vari in vape smoke {
            // skip patterns
            {
                if ("`vari'"=="vape") & (`yr'==1 | "`survey'"=="com") continue
                if "`vari'"=="vape" & `yr'==1 continue
                if "`vari'"=="smoke" & `yr'==5 continue
            }

            use "data/final/master_set_2023", clear
            
            // trim data
            {
                if "`survey'"=="st"  keep if !national
                if "`vari'"=="vape"  keep if inrange(year,2015,2023)
                if "`vari'"=="smoke" keep if inrange(year,201`yr',2023)
            }

            // gen biennial events
            {
                gen     s2wF3_ends = s1F10_ends + s1F9_ends					     	// [-5+]
                gen     s2wF2_ends = s1F8_ends  + s1F7_ends + s1F6_ends + s1F5_ends // [-4,-3]
                gen     s2wF1_ends = s1F4_ends  + s1F3_ends + s1F2_ends + s1F1_ends // [-2,-1]
                gen     s2wL0_ends = s1L0_ends  + s1L1_ends + s1L2_ends + s1L3_ends // [0,1]
                gen     s2wL1_ends = s1L4_ends  + s1L5_ends	         		     	// [2+]

                gen     s2wF1_ends_og = s2wF1_ends                                  // [-2-1] not to zero
                replace s2wF1_ends = 0                                              // [-2-1] --> zero
            }

            // create hetero indicator for differential
            {
                gen     hetero = .
                replace hetero = 0 if lgbq_1==1
                replace hetero = 1 if lgbq_1==0
            }

            foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'"=="1" {
                    local sname "all_u"
                    local stit "All unrestricted"
                    }
                    if "`subsample'"=="!mi(lgbq_1)" {
                    local sname "all"
                    local stit "All"
                    }
                    if "`subsample'" == "lgbq_1==0" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq_1==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"

                    // shortened name for combined yrbs
                    if "`survey'"=="com" local sname nh1
                    }
                }

                foreach var in `vari' f`vari' d`vari' {
                    // denote LASSO controls (***)
                    {
                        if inlist("`var'","vape","fvape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'}

                        else ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'y`yr'}
                    }
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel'

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel' c.tally_sexualorientation 
                    }
                    
                    if 1 { // estimation

                        // OLS
                        _eststo eso_`survey'y`yr'_`var'_`m'_`sname': ///
                        reghdfe `var' ///
                        `events' /// 
                        `vars_controls' ///
                        if `subsample' ///
                        , ///
                        absorb(fips year_true semester `technical') ///
                        vce(cluster fips) nosample

                        // logit
                        logit `var' ///
                        `events' /// 
                        `vars_controls' ///
                        i.fips i.year_true i.semester `technical' if `subsample' ///
                        , vce(cluster fips) iterate(15)

                        scalar converge_pre = e(converged)
                        local converge = e(converged)

                        _eststo es_`survey'y`yr'_`var'_`m'_`sname': ///
                        margins, dydx(`events') post
                        estadd scalar converge = converge_pre

                        /*
                        // delta method averaging (not preferred)
                        {
                            xlincom ///
                            ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -5+   lead
                            (          (_b[`2'] + _b[`3']) / 3) /// -4,-3 lead
                            (                    (_b[`3']) / 2) /// -2,-1 lead
                            ((_b[`4'])                     / 1) ///  0,1  lag   
                            ((_b[`4'] + _b[`5'])           / 2) ///  2+  lag
                            , post level(95)
                            _eststo esd_`survey'y`yr'_`var'_`m'_`sname'
                        }

                        // average of pre-treatment period as reference (logit)
                        {
                            // a0: don't include -2-1 in average
                            estimates restore es_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[`1'] + _b[`2']) / 2)

                            xlincom ///
                            (_b[`1'] - `preavg') /// -5+  lead
                            (_b[`2'] - `preavg') /// -4-3 lead
                            (_b[`3'])            /// -2-1 lead
                            (_b[`4'] - `preavg') /// 01   lag
                            (_b[`5'] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo esa0_`survey'y`yr'_`var'_`m'_`sname'


                            // a1: include -2-1 in average
                            estimates restore es_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg  = ((_b[`1'] + _b[`2'] + _b[`3']) / 3)

                            xlincom ///
                            (_b[`1'] - `preavg') /// -5+  lead
                            (_b[`2'] - `preavg') /// -4-3 lead
                            (_b[`3'])            /// -2-1 lead
                            (_b[`4'] - `preavg') /// 01   lag
                            (_b[`5'] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo esa1_`survey'y`yr'_`var'_`m'_`sname'

                            macro drop _preavg
                        }
                        */

                        // constrained linear regression ('cnsreg')
                        {
                            constraint 1 (s2wF3_ends + s2wF2_ends + s2wF1_ends_og) / 3 = 0
                            constraint 2 (1.hetero#c.s2wF3_ends + 1.hetero#c.s2wF2_ends + 1.hetero#c.s2wF1_ends_og) / 3 = 0

                            _eststo esc_`survey'y`yr'_`var'_`m'_`sname': ///
                            cnsreg `var' ///
                            `events_adj' /// 
                            `vars_controls' ///
                            i.fips i.year_true i.semester `technical' if `subsample' ///
                            , constraints(1) vce(cluster fips)

                            // fully interacted event study
                            if "`subsample'"=="!mi(lgbq_1)" {
                            _eststo esci_`survey'y`yr'_`var'_`m'_`sname': ///
                            cnsreg `var' ///
                            hetero##(`events_adj' /// 
                            `vars_controls' ///
                            i.fips i.year_true i.semester ///
                            `technical') if `subsample' ///
                            , constraints(1 2) vce(cluster fips)

                            // weighted -- for comparison
                            _eststo esciw_`survey'y`yr'_`var'_`m'_`sname': ///
                            cnsreg `var' ///
                            hetero##(`events_adj' /// 
                            `vars_controls' ///
                            i.fips i.year_true i.semester ///
                            `technical') if `subsample' [aw=`weight'] ///
                            , constraints(1 2) vce(cluster fips)
                            }
                        }    
                    }
                }
                }
            }	
            graph drop _all	

            estwrite _all using "log/estimates/eventstudy_v42uw.sters", replace
            estimates clear
            eststo clear
        }
        }
        }

        // graphing
        if 0 {
            eststo clear
            estimates clear                

            foreach survey in st {
            foreach yr in 5 {
                estread *`survey'y`yr'* using "log/estimates/eventstudy_v42uw.sters"
            foreach subsample in all_u all {
                // subsample-specific
                {
                    local sname `subsample'
                    if "`survey'"=="com" & "`subsample'"=="id_nh1" local sname nh1
                }
                foreach var in vape fvape dvape {
                    if inlist("`var'","vape","fvape","dvape") & ("`survey'"=="com" | `yr'==1) continue
                forval m = 1/3 {
                foreach adj of numlist 0 4 5 8 9 {
                    // adj-specifics
                    {
                        if `adj'==0 {
                            local name_adj
                            local list_events s2wF3_ends s2wF2_ends s2wF1_ends s2wL0_ends s2wL1_ends
                        }
                        if `adj'==1 {
                            local name_adj d
                        }
                        if `adj'==2 {
                            local name_adj a0
                        }
                        if `adj'==3 {
                            local name_adj a1
                        }
                        if `adj'==4 {
                            local name_adj c
                            local list_events s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends
                        }
                        if `adj'==5 {
                            local name_adj o
                            local list_events s2wF3_ends s2wF2_ends s2wF1_ends s2wL0_ends s2wL1_ends
                        }
                        if `adj'==6 { // OLS pre-treat reference, exclusive
                            // o0: don't include -2-1 in average
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[s2wF3_ends] + _b[s2wF2_ends]) / 2)

                            xlincom ///
                            (_b[s2wF3_ends] - `preavg') /// -5+  lead
                            (_b[s2wF2_ends] - `preavg') /// -4-3 lead
                            (_b[s2wF1_ends])            /// -2-1 lead
                            (_b[s2wL0_ends] - `preavg') /// 01   lag
                            (_b[s2wL1_ends] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo eso0_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj o0
                        }
                        if `adj'==7 { // OLS pre-treat reference, inclusive
                            // o1: include -2-1 in average
                            estimates restore eso_`survey'y`yr'_`var'_`m'_`sname'

                            local preavg = ((_b[s2wF3_ends] + _b[s2wF2_ends] + _b[s2wF1_ends]) / 3)

                            xlincom ///
                            (_b[s2wF3_ends] - `preavg') /// -5+  lead
                            (_b[s2wF2_ends] - `preavg') /// -4-3 lead
                            (_b[s2wF1_ends])            /// -2-1 lead
                            (_b[s2wL0_ends] - `preavg') /// 01   lag
                            (_b[s2wL1_ends] - `preavg') /// 2+   lag
                            , post level(95)
                            _eststo eso1_`survey'y`yr'_`var'_`m'_`sname'

                            local name_adj o1
                        }
                        if `adj'==8 { // fully interacted model, cnsreg
                            if "`subsample'"!="all" continue
                            local name_adj ci
                            local list_events 1.hetero#c.s2wF3_ends 1.hetero#c.s2wF2_ends 1.hetero#c.s2wF1_ends_og 1.hetero#c.s2wL0_ends 1.hetero#c.s2wL1_ends
                        }
                        if `adj'==9 { // fully interacted model, cnsreg (weighted for comparison)
                            if "`subsample'"!="all" continue
                            local name_adj ciw
                            local list_events 1.hetero#c.s2wF3_ends 1.hetero#c.s2wF2_ends 1.hetero#c.s2wF1_ends_og 1.hetero#c.s2wL0_ends 1.hetero#c.s2wL1_ends
                        }

                        if inlist(`adj',1,2,3,6,7) local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                    }

                    // parameters
                    {
                        // y-axis
                        if "`var'" == "vape" local ysca yla(-0.150(0.050)0.150, nogrid) 
                        if "`var'" != "vape" local ysca yla(-0.075(0.025)0.075, nogrid)

                        if inlist(`adj',4,8,9) {
                            if "`var'"=="vape"   local ysca yla(-0.100(0.050)0.100, nogrid) 
                            if "`var'" != "vape" local ysca yla(-0.050(0.025)0.050, nogrid)
                        }

                        ***if "`var'" == "combust" local ysca yla()

                        // display convergence
                        estimates restore es`name_adj'_`survey'y`yr'_`var'_`m'_`sname'
                        if e(converge) == 0 local converge_title "Does not converge"
                        else                local converge_title ""
                    }

                    coefplot(es`name_adj'_`survey'y`yr'_`var'_`m'_`sname', ///
                    keep(`list_events') omitted ///
                    recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                    vertical ///
                    title("`converge_local'",) ///
                    graphregion(color(white)) ///
                    ytitle("Estimated Effect of ENDS Tax", size(medium)) ///
                    yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                    xtitle("Years Before/After ENDS Tax Increase", size(medium)) ///
                    xline(3.5, lpattern(dash) lcolor(black)) ///
                    xlabel(1 "{&le} -5" 2 "-4,-3" 3 "-2,1" 4 "0,1" 5 "{&ge} 2", labsize(medium)) ///
                    legend(off) ///
                    ciopts(recast(rcap) lwidth(thin)) 

                    graph export "output/etax/graphs/final/es`name_adj'_v42uw_`survey'y`yr'_m`m'_`var'_`subsample'.png", replace
                    graph close		
                }
                }
                }
            }
                estimates clear
            }
            }
        }

        use "data/final/master_set_2023", clear	

        macro drop _name_adj _sname
    }    
}

// BRFSS event studies
if 1 {
    // v1: -3+ to 2+ years; 18-30 year olds
    if 1 {
        cap log close
        log using "log/regressions/eventstudy_brfss_v1.smcl", replace

        use "data/final/brfss_master_set_2023", clear

        // adjust already created yearly events -- bin leads to -3+
        {
            gen     y_v2a_F3_etax = y_v2_F5_etax + y_v2_F4_etax + y_v2_F3_etax 
            gen     y_v2a_F2_etax = y_v2_F2_etax
            gen     y_v2a_F1_etax = y_v2_F1_etax
            gen     y_v2a_L0_etax = y_v2_L0_etax
            gen     y_v2a_L1_etax = y_v2_L1_etax
            gen     y_v2a_L2_etax = y_v2_L2_etax

            gen     y_v2a_F1_etax_og = y_v2a_F1_etax // unadjusted -1 year
            replace y_v2a_F1_etax = 0 // -1 year to zero
        }

        global brfss_dem_control i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college /*c.white*/ c.black c.hispanic c.other_race

        // denote essential controls (***)
        {
            local vars_essential_coef1_b /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape c.t21 c.cigarette_tax_scale
            local vars_essential_coef0_b c.uer c.coviddeaths c.populationvaccinated ${brfss_dem_control}

            local events     y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax    y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
            local events_adj y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax_og y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
            tokenize "`events'"
        }
        
        keep if inrange(year_survey,2014,2023)
        
        eststo    clear
        estimates clear

        // estimation
        {
            local samp_event "heterosexual==1 lgbq==1"	
            foreach vari in vape smoke {

                foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "heterosexual==1" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"
                    }
                }

                foreach var in `vari' d`vari' {
                    // denote LASSO controls (***)
                    {
                        if inlist("`var'","vape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'_b}
                    }
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' `vars_lasso_sel'

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' `vars_lasso_sel' c.tally_sexualorientation 
                    }
                    
                    // estimation
                    logit `var' ///
                    `events' /// 
                    `vars_controls' ///
                    i.fips i.year_true i.quarter if `subsample' ///
                    & inrange(age,18,30) ///
                    [pw=sample_weight1], vce(cluster fips)

                    scalar converge_pre = e(converged)

                    _eststo es_`var'_`m'_`sname': ///
                    margins, dydx(`events') post
                    estadd scalar converge = converge_pre
                    
                    // constrained linear regression ('cnsreg')
                    {
                        constraint 1 (y_v2a_F3_etax + y_v2a_F2_etax + y_v2a_F1_etax_og) / 3 = 0

                        _eststo esc_`var'_`m'_`sname': ///
                        cnsreg `var' ///
                        `events_adj' ///
                        `vars_controls' ///
                        i.fips i.year_true i.quarter ///
                        if `subsample' & inrange(age,18,30) [pw=sample_weight1], ///
                        constraints(1) vce(cluster fips)
                    }

                    // OLS
                    _eststo eso_`var'_`m'_`sname': ///
                    reghdfe `var' ///
                    `events' /// 
                    `vars_controls' ///
                    if `subsample' ///
                    & inrange(age,18,30) ///
                    [aw=sample_weight1], ///
                    vce(cluster fips) absorb(fips year_true quarter)
                }
                }
                }	
                graph drop _all	
            }

            // "delta smoothing" method
            {    
                foreach sname in id_ht id_nh1 {
                foreach var in vape dvape smoke dsmoke {
                forval m = 1/3 {
                    estimates restore es_`var'_`m'_`sname'

                    xlincom ///
                    ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -3+ lead
                    (          (_b[`2'] + _b[`3']) / 2) /// -2 lead
                    (                    (_b[`3']) / 1) /// -1 lead
                    ((_b[`4'])                     / 1) ///  0 lag   
                    ((_b[`4'] + _b[`5'])           / 2) ///  1 lag
                    ((_b[`4'] + _b[`5'] + _b[`6']) / 3) ///  2+ lag
                    , post level(95)
                    eststo esd_`var'_`m'_`sname'
                }
                }
                }
            }   

            estwrite _all using "log/estimates/brfss_eventstudy_v1.sters", replace
        }

        // graphing
        if 0 {
            estread _all using "log/estimates/brfss_eventstudy_v1.sters"

            foreach subsample in id_ht id_nh1 {
                foreach var in vape dvape {
                forval m = 1/3 {
                forval adj = 0/6 {
                    // adj-specifics
                    {
                        if `adj'==0 {
                            local name_adj
                            local list_events y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
                        }
                        if `adj'==1 {
                            local name_adj d
                            local list_events lc_1 lc_2 lc_3 lc_4 lc_5 lc_6
                        }
                        if `adj'==2 { // a0: pre-treatment avg as reference, exclude -1 in avg
                            estimates restore es_`var'_`m'_`subsample'

                            local preavg = ((_b[y_v2a_F3_etax] + _b[y_v2a_F2_etax]) / 2)

                            xlincom ///
                            (_b[y_v2a_F3_etax] - `preavg') /// -3+ lead
                            (_b[y_v2a_F2_etax] - `preavg') /// -2 lead
                            (_b[y_v2a_F1_etax])            /// -1 lead
                            (_b[y_v2a_L0_etax] - `preavg') /// 0 lag
                            (_b[y_v2a_L1_etax] - `preavg') /// 1 lag
                            (_b[y_v2a_L2_etax] - `preavg') /// 2+ lag
                            , post level(95)
                            _eststo esa0_`var'_`m'_`subsample'

                            local name_adj a0
                            local list_events lc_1 lc_2 lc_3 lc_4 lc_5 lc_6
                        }
                        if `adj'==3 { // a1: pre-treatment avg as reference, include -1 in avg
                            estimates restore es_`var'_`m'_`subsample'

                            local preavg = ((_b[y_v2a_F3_etax] + _b[y_v2a_F2_etax] + _b[y_v2a_F1_etax]) / 3)

                            xlincom ///
                            (_b[y_v2a_F3_etax] - `preavg') /// -3+ lead
                            (_b[y_v2a_F2_etax] - `preavg') /// -2 lead
                            (_b[y_v2a_F1_etax] - `preavg') /// -1 lead
                            (_b[y_v2a_L0_etax] - `preavg') /// 0 lag
                            (_b[y_v2a_L1_etax] - `preavg') /// 1 lag
                            (_b[y_v2a_L2_etax] - `preavg') /// 2+ lag
                            , post level(95)
                            _eststo esa1_`var'_`m'_`subsample'

                            local name_adj a1
                            local list_events lc_1 lc_2 lc_3 lc_4 lc_5 lc_6
                        }
                        if `adj'==4 {
                            local name_adj c
                            local list_events y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax_og y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
                        }
                        if `adj'==5 { // OLS
                            local name_adj o
                            local list_events y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
                        }
                        if `adj'==6 { // od: OLS "delta method"
                            estimates restore eso_`var'_`m'_`subsample'

                            xlincom ///
                            ((_b[y_v2a_F3_etax] + _b[y_v2a_F2_etax] + _b[y_v2a_F1_etax]) / 3) /// -3+ lead
                            (                    (_b[y_v2a_F2_etax] + _b[y_v2a_F1_etax]) / 2) /// -2 lead
                            (                                        (_b[y_v2a_F1_etax]) / 1) /// -1 lead
                            ((_b[y_v2a_L0_etax])                                         / 1) ///  0 lag   
                            ((_b[y_v2a_L0_etax] + _b[y_v2a_L1_etax])                     / 2) ///  1 lag
                            ((_b[y_v2a_L0_etax] + _b[y_v2a_L1_etax] + _b[y_v2a_L2_etax]) / 3) ///  2+ lag
                            , post level(95)
                            _eststo esod_`var'_`m'_`subsample'

                            local name_adj od
                            local list_events lc_1 lc_2 lc_3 lc_4 lc_5 lc_6
                        }
                    }

                    // parameters
                    {
                        // y-axis
                        if "`var'" == "vape" local ysca yla(-0.100(0.025)0.100, nogrid) 
                        if "`var'" != "vape" local ysca yla(-0.075(0.025)0.075, nogrid)
                    }

                    coefplot(es`name_adj'_`var'_`m'_`subsample', ///
                    omitted keep(`list_events') ///
                    recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                    vertical ///
                    graphregion(color(white)) ///
                    ytitle("Estimated Effect of ENDS Tax", size(medium)) ///
                    yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                    xtitle("Years Before/After ENDS Tax Increase", size(medium)) ///
                    xline(3.5, lpattern(dash) lcolor(black)) ///
                    xlabel(1 "{&le} -3" 2 "-2" 3 "-1" 4 "0" 5 "1" 6 "{&ge} 2", labsize(medium)) ///
                    legend(off) ///
                    ciopts(recast(rcap) lwidth(thin)) 

                    graph export "output/etax/graphs/final/brfss_es`name_adj'_v1_m`m'_`var'_`subsample'.png", replace
                    graph close		
                }
                }
                }
            }
        }

        use "data/final/brfss_master_set_2023", clear	

        macro drop _name_delta

        cap log close
    }

    // v1.1  (v1), 31+ year olds
    if 1 {
        cap log close
        log using "log/regressions/eventstudy_brfss_v1_1.smcl", replace

        use "data/final/brfss_master_set_2023", clear

        // adjust already created yearly events -- bin leads to -3+
        {
            gen     y_v2a_F3_etax = y_v2_F5_etax + y_v2_F4_etax + y_v2_F3_etax 
            gen     y_v2a_F2_etax = y_v2_F2_etax
            gen     y_v2a_F1_etax = y_v2_F1_etax
            gen     y_v2a_L0_etax = y_v2_L0_etax
            gen     y_v2a_L1_etax = y_v2_L1_etax
            gen     y_v2a_L2_etax = y_v2_L2_etax

            gen     y_v2a_F1_etax_og = y_v2a_F1_etax // unadjusted -1 year
            replace y_v2a_F1_etax = 0 // -1 year to zero
        }

        global brfss_dem_control i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college /*c.white*/ c.black c.hispanic c.other_race

        // denote essential controls (***)
        {
            local vars_essential_coef1_b /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape c.t21 c.cigarette_tax_scale
            local vars_essential_coef0_b c.uer c.coviddeaths c.populationvaccinated ${brfss_dem_control}

            local events     y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax    y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
            local events_adj y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax_og y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
            tokenize "`events'"
        }
        
        keep if inrange(year_survey,2014,2023)
        
        eststo    clear
        estimates clear

        // estimation
        {
            local samp_event "heterosexual==1 lgbq==1"	
            foreach vari in vape smoke {

                foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "heterosexual==1" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"
                    }
                }

                foreach var in `vari' d`vari' {
                    // denote LASSO controls (***)
                    {
                        if inlist("`var'","vape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'_b}
                    }
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' `vars_lasso_sel'

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' `vars_lasso_sel' c.tally_sexualorientation 
                    }
                    
                    // estimation
                    logit `var' ///
                    `events' /// 
                    `vars_controls' ///
                    i.fips i.year_true i.quarter if `subsample' ///
                    & inrange(age,31,80) ///
                    [pw=sample_weight1], vce(cluster fips)

                    scalar converge_pre = e(converged)

                    _eststo es1_`var'_`m'_`sname': ///
                    margins, dydx(`events') post
                    estadd scalar converge = converge_pre
                    
                    // constrained linear regression ('cnsreg')
                    {
                        constraint 1 (y_v2a_F3_etax + y_v2a_F2_etax + y_v2a_F1_etax_og) / 3 = 0

                        _eststo esc1_`var'_`m'_`sname': ///
                        cnsreg `var' ///
                        `events_adj' ///
                        `vars_controls' ///
                        i.fips i.year_true i.quarter ///
                        if `subsample' & inrange(age,31,80) [pw=sample_weight1], ///
                        constraints(1) vce(cluster fips)
                    }

                    // OLS
                    _eststo eso1_`var'_`m'_`sname': ///
                    reghdfe `var' ///
                    `events' /// 
                    `vars_controls' ///
                    if `subsample' ///
                    & inrange(age,31,80) ///
                    [aw=sample_weight1], ///
                    vce(cluster fips) absorb(fips year_true quarter)
                }
                }
                }	
                graph drop _all	
            }

            // "delta smoothing" method
            {    
                foreach sname in id_ht id_nh1 {
                foreach var in vape dvape smoke dsmoke {
                forval m = 1/3 {
                    estimates restore es1_`var'_`m'_`sname'

                    xlincom ///
                    ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -3+ lead
                    (          (_b[`2'] + _b[`3']) / 2) /// -2 lead
                    (                    (_b[`3']) / 1) /// -1 lead
                    ((_b[`4'])                     / 1) ///  0 lag   
                    ((_b[`4'] + _b[`5'])           / 2) ///  1 lag
                    ((_b[`4'] + _b[`5'] + _b[`6']) / 3) ///  2+ lag
                    , post level(95)
                    eststo es1d_`var'_`m'_`sname'
                }
                }
                }
            }   

            estwrite _all using "log/estimates/brfss_eventstudy_v1_1.sters", replace
        }

        // graphing
        if 0 {
            estread _all using "log/estimates/brfss_eventstudy_v1_1.sters"

            foreach subsample in id_ht id_nh1 {
                foreach var in vape dvape {
                forval m = 1/3 {
                forval adj = 0/6 {
                    // adj-specifics
                    {
                        if `adj'==0 {
                            local name_adj
                            local list_events y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
                        }
                        if `adj'==1 {
                            local name_adj d
                            local list_events lc_1 lc_2 lc_3 lc_4 lc_5 lc_6
                        }
                        if `adj'==2 { // a0: pre-treatment avg as reference, exclude -1 in avg
                            estimates restore es_`var'_`m'_`subsample'

                            local preavg = ((_b[y_v2a_F3_etax] + _b[y_v2a_F2_etax]) / 2)

                            xlincom ///
                            (_b[y_v2a_F3_etax] - `preavg') /// -3+ lead
                            (_b[y_v2a_F2_etax] - `preavg') /// -2 lead
                            (_b[y_v2a_F1_etax])            /// -1 lead
                            (_b[y_v2a_L0_etax] - `preavg') /// 0 lag
                            (_b[y_v2a_L1_etax] - `preavg') /// 1 lag
                            (_b[y_v2a_L2_etax] - `preavg') /// 2+ lag
                            , post level(95)
                            _eststo esa0_`var'_`m'_`subsample'

                            local name_adj a0
                            local list_events lc_1 lc_2 lc_3 lc_4 lc_5 lc_6
                        }
                        if `adj'==3 { // a1: pre-treatment avg as reference, include -1 in avg
                            estimates restore es_`var'_`m'_`subsample'

                            local preavg = ((_b[y_v2a_F3_etax] + _b[y_v2a_F2_etax] + _b[y_v2a_F1_etax]) / 3)

                            xlincom ///
                            (_b[y_v2a_F3_etax] - `preavg') /// -3+ lead
                            (_b[y_v2a_F2_etax] - `preavg') /// -2 lead
                            (_b[y_v2a_F1_etax] - `preavg') /// -1 lead
                            (_b[y_v2a_L0_etax] - `preavg') /// 0 lag
                            (_b[y_v2a_L1_etax] - `preavg') /// 1 lag
                            (_b[y_v2a_L2_etax] - `preavg') /// 2+ lag
                            , post level(95)
                            _eststo esa1_`var'_`m'_`subsample'

                            local name_adj a1
                            local list_events lc_1 lc_2 lc_3 lc_4 lc_5 lc_6
                        }
                        if `adj'==4 {
                            local name_adj c
                            local list_events y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax_og y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
                        }
                        if `adj'==5 { // OLS
                            local name_adj o
                            local list_events y_v2a_F3_etax y_v2a_F2_etax y_v2a_F1_etax y_v2a_L0_etax y_v2a_L1_etax y_v2a_L2_etax
                        }
                        if `adj'==6 { // od: OLS "delta method"
                            estimates restore eso_`var'_`m'_`subsample'

                            xlincom ///
                            ((_b[y_v2a_F3_etax] + _b[y_v2a_F2_etax] + _b[y_v2a_F1_etax]) / 3) /// -3+ lead
                            (                    (_b[y_v2a_F2_etax] + _b[y_v2a_F1_etax]) / 2) /// -2 lead
                            (                                        (_b[y_v2a_F1_etax]) / 1) /// -1 lead
                            ((_b[y_v2a_L0_etax])                                         / 1) ///  0 lag   
                            ((_b[y_v2a_L0_etax] + _b[y_v2a_L1_etax])                     / 2) ///  1 lag
                            ((_b[y_v2a_L0_etax] + _b[y_v2a_L1_etax] + _b[y_v2a_L2_etax]) / 3) ///  2+ lag
                            , post level(95)
                            _eststo esod_`var'_`m'_`subsample'

                            local name_adj od
                            local list_events lc_1 lc_2 lc_3 lc_4 lc_5 lc_6
                        }
                    }

                    // parameters
                    {
                        // y-axis
                        if "`var'" == "vape" local ysca yla(-0.100(0.025)0.100, nogrid) 
                        if "`var'" != "vape" local ysca yla(-0.075(0.025)0.075, nogrid)
                    }

                    coefplot(es`name_adj'_`var'_`m'_`subsample', ///
                    omitted keep(`list_events') ///
                    recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                    vertical ///
                    graphregion(color(white)) ///
                    ytitle("Estimated Effect of ENDS Tax", size(medium)) ///
                    yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                    xtitle("Years Before/After ENDS Tax Increase", size(medium)) ///
                    xline(3.5, lpattern(dash) lcolor(black)) ///
                    xlabel(1 "{&le} -3" 2 "-2" 3 "-1" 4 "0" 5 "1" 6 "{&ge} 2", labsize(medium)) ///
                    legend(off) ///
                    ciopts(recast(rcap) lwidth(thin)) 

                    graph export "output/etax/graphs/final/brfss_es`name_adj'_v1_1_m`m'_`var'_`subsample'.png", replace
                    graph close		
                }
                }
                }
            }
        }

        use "data/final/brfss_master_set_2023", clear	

        macro drop _name_delta

        cap log close
    }

    // v1.2: (v1), cigarette tax/flavor ban/mlsa
    if 1 {
        cap log close
        log using "log/regressions/eventstudy_brfss_v1_2.smcl", replace

        // create events
        {
            local version v2
            use "data/inter/controls_quarterly_2023", clear

            keep fips state_abbrev year_true quarter flavor_ban cigarette_tax_scale any_mlsa_vape
            gen quarter_date = yq(year_true, quarter)
            format quarter_date %tq
            sort fips quarter_date

            // set flavor ban to zero for PA
            replace flavor_ban = 0 if state_abbrev=="PA"

            local last_lead 17
            local last_lag 8

            local last_lead_yr = ceil(`last_lead'/4)
            local last_lag_yr  = `last_lag' / 4

            foreach ind_var in flavor_ban cigarette_tax_scale any_mlsa_vape { 
                // version 2: 4 quarters of first differences in every year (17 leads and 9 lags for -5+ pre to 2+ post) then adjust
                if inlist("`ind_var'","flavor_ban","cigarette_tax_scale") {
                    bys fips: gen L0 = `ind_var'[_n] - `ind_var'[_n - 1] 
                    replace       L0 = 0 if mi(L0)

                    // leads
                    forval i = 1/`last_lead' {
                        bys fips: gen p`version'_F`i'_`ind_var' = L0[_n + `i']
                        replace p`version'_F`i'_`ind_var' = 0 if mi(p`version'_F`i'_`ind_var')

                        // endpoints
                        if `i'==`last_lead' {
                            gsort fips -year_true -quarter
                            bys fips: gen sum_p`version'_F`i'_`ind_var' = sum(p`version'_F`i'_`ind_var')
                            replace           p`version'_F`i'_`ind_var' = sum_p`version'_F`i'_`ind_var'
                            drop          sum_p`version'_F`i'_`ind_var'
                            sort fips year_true quarter
                        }
                    }

                    // lags
                    forval i = 0/`last_lag' {
                        bys fips: gen p`version'_L`i'_`ind_var' = L0[_n - `i']
                        replace       p`version'_L`i'_`ind_var' = 0 if mi(p`version'_L`i'_`ind_var')
                        
                        // endpoints
                        if `i'==`last_lag' {
                            bys fips: gen sum_p`version'_L`i'_`ind_var' = sum(p`version'_L`i'_`ind_var')
                            replace           p`version'_L`i'_`ind_var' = sum_p`version'_L`i'_`ind_var'
                            drop          sum_p`version'_L`i'_`ind_var'
                        }
                    }

                    drop L0

                    // convert to yearly and adjust for -3+
                    {
                        local j = 1

                        // leads
                        forval i=1/`last_lead_yr' {
                            if `i'!=`last_lead_yr' ///
                            gen y_`version'_F`i'_`ind_var' = ///
                            p`version'_F`=`j'+0'_`ind_var' + p`version'_F`=`j'+1'_`ind_var' + p`version'_F`=`j'+2'_`ind_var' + p`version'_F`=`j'+3'_`ind_var'
                            
                            if `i' == `last_lead_yr' gen y_`version'_F`i'_`ind_var' = ///
                            p`version'_F`=`j'+0'_`ind_var'

                            if `i' != 1 order y_`version'_F`i'_`ind_var', before(y_`version'_F`=`i'-1'_`ind_var')
                            
                            local j = `j' + 4
                        }

                        local j=0

                        // lags
                        forval i = 0/`last_lag_yr' {
                            if `i' != `last_lag_yr' gen y_`version'_L`i'_`ind_var' = ///
                            p`version'_L`=`j'+0'_`ind_var' + p`version'_L`=`j'+1'_`ind_var' + p`version'_L`=`j'+2'_`ind_var' + p`version'_L`=`j'+3'_`ind_var'
                            
                            if `i' == `last_lag_yr' gen y_`version'_L`i'_`ind_var' = ///
                            p`version'_L`=`j'+0'_`ind_var'
                        
                            local j = `j' + 4
                        }

                        // adjust
                        {
                            gen     y_v2a_F3_`ind_var' = y_v2_F5_`ind_var' + y_v2_F4_`ind_var' + y_v2_F3_`ind_var' 
                            gen     y_v2a_F2_`ind_var' = y_v2_F2_`ind_var'
                            gen     y_v2a_F1_`ind_var' = y_v2_F1_`ind_var'
                            gen     y_v2a_L0_`ind_var' = y_v2_L0_`ind_var'
                            gen     y_v2a_L1_`ind_var' = y_v2_L1_`ind_var'
                            gen     y_v2a_L2_`ind_var' = y_v2_L2_`ind_var'

                            gen     y_v2a_F1_`ind_var'_og = y_v2a_F1_`ind_var' // unadjusted -1 year [[12 char + ]]
                            replace y_v2a_F1_`ind_var' = 0                // -1 year to zero
                        }
                    }

                    drop *p`version'*
                }

                else {
                    // find introduction date
                    {
                        // first differences
                        bys fips: gen `ind_var'_intro_ = `ind_var'[_n] - `ind_var'[_n-1]
                        replace       `ind_var'_intro_ = 0 if missing(`ind_var'_intro_)

                        // grab dates w/ variation
                        replace `ind_var'_intro_ = quarter_date if `ind_var'_intro_ != 0
                        replace `ind_var'_intro_ = .            if `ind_var'_intro_ == 0
                        format  `ind_var'_intro_ %tq

                        // take earliest date w/ variation
                        bys fips: egen `ind_var'_intro = min(`ind_var'_intro_)
                        drop           `ind_var'_intro_
                    }
                    gen `version' = quarter_date - `ind_var'_intro

                    // convert to annual
                    recode `version' ///
                    (. = 99)                                  /// code missing as 99
                    (-1000/-9 = -3) (-8/-5 = -2) (-4/-1 = -1) ///
                    (0/3 = 0)       (4/7 = 1)    (8/1000 = 2)

                    xi i.`version', noomit

                    rename (_I*) (`ind_var'_*)
                    rename `ind_var'_`version'_1 y_`version'a_F3_`ind_var'
                    rename `ind_var'_`version'_2 y_`version'a_F2_`ind_var'
                    rename `ind_var'_`version'_3 y_`version'a_F1_`ind_var'
                    rename `ind_var'_`version'_4 y_`version'a_L0_`ind_var'
                    rename `ind_var'_`version'_5 y_`version'a_L1_`ind_var'
                    rename `ind_var'_`version'_6 y_`version'a_L2_`ind_var'
                    // missing as `ind_var'_`version'_7

                    // set reference as -1
                    {
                        gen     y_`version'a_F1_`ind_var'_og = y_`version'a_F1_`ind_var'
                        replace y_`version'a_F1_`ind_var'    = 0
                    }

                    drop `version'
                }
            }

            tempfile brfss_other_pol
            save    `brfss_other_pol'
        }

        use "data/final/brfss_master_set_2023", clear
        
        merge m:1 fips year_true quarter using `brfss_other_pol'
        drop if _merge==2
        drop _merge

        global brfss_dem_control i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college /*c.white*/ c.black c.hispanic c.other_race

        keep if inrange(year_survey,2014,2023)

        // estimation
        foreach ind_var in any_mlsa_vape flavor_ban cigarette_tax_scale {
            // ind_var-specific
            {
                if "`ind_var'"=="any_mlsa_vape" {
                    local name_ind_var 2
                    local vars_essential_coef1_b c.ends_tax_nom35_scale c.flavor_ban /*c.any_mlsa_vape*/ c.t21 c.cigarette_tax_scale
                    local sample_flavor 1
                }
                if "`ind_var'"=="flavor_ban" {
                    local name_ind_var 3
                    local vars_essential_coef1_b c.ends_tax_nom35_scale /*c.flavor_ban*/ c.any_mlsa_vape c.t21 c.cigarette_tax_scale
                    local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR
                }
                if "`ind_var'"=="cigarette_tax_scale" {
                    local name_ind_var 4
                    local vars_essential_coef1_b c.ends_tax_nom35_scale c.flavor_ban c.any_mlsa_vape c.t21 /*c.cigarette_tax_scale*/
                    local sample_flavor 1
                }
            }
            // denote essential controls (***)
            {
                local vars_essential_coef0_b c.uer c.coviddeaths c.populationvaccinated ${brfss_dem_control}

                local events     y_v2a_F3_`ind_var' y_v2a_F2_`ind_var' y_v2a_F1_`ind_var'    y_v2a_L0_`ind_var' y_v2a_L1_`ind_var' y_v2a_L2_`ind_var'
                local events_adj y_v2a_F3_`ind_var' y_v2a_F2_`ind_var' y_v2a_F1_`ind_var'_og y_v2a_L0_`ind_var' y_v2a_L1_`ind_var' y_v2a_L2_`ind_var'
                tokenize "`events'"
            }

            foreach age_range in inrange(age,18,30) inrange(age,31,80) {
                eststo    clear
                estimates clear

                // age_range-specific
                {
                    if "`age_range'"=="inrange(age,18,30)" local name_age
                    if "`age_range'"=="inrange(age,31,80)" local name_age 1
                }
            local samp_event "heterosexual==1 lgbq==1"	
            foreach vari in vape smoke {

                foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "heterosexual==1" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"
                    }
                }

                foreach var in `vari' d`vari' {
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' ${vars_lasso_sel_`var'_b}

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' ${vars_lasso_sel_`var'_b} c.tally_sexualorientation 
                    }
                    
                    // estimation
                    logit `var' ///
                    `events' /// 
                    `vars_controls' ///
                    i.fips i.year_true i.quarter if `subsample' ///
                    & `age_range' & `sample_flavor' ///
                    [pw=sample_weight1], vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)

                    _eststo es`name_age'_`name_ind_var'_`var'_`m'_`sname': ///
                    margins, dydx(`events') post
                    estadd scalar converge = converge_pre
                    matrix B = J(1,6,.)
                    forval b = 1/6 {
                        matrix B[1,`b'] = converge_pre
                    }
                    estadd matrix B
                    
                    // constrained linear regression ('cnsreg')
                    {
                        constraint 1 (y_v2a_F3_`ind_var' + y_v2a_F2_`ind_var' + y_v2a_F1_`ind_var'_og) / 3 = 0

                        _eststo esc`name_age'_`name_ind_var'_`var'_`m'_`sname': ///
                        cnsreg `var' ///
                        `events_adj' ///
                        `vars_controls' ///
                        i.fips i.year_true i.quarter ///
                        if `subsample' & `age_range' & `sample_flavor' [pw=sample_weight1], ///
                        constraints(1) vce(cluster fips)
                    }

                    // OLS
                    _eststo eso`name_age'_`name_ind_var'_`var'_`m'_`sname': ///
                    reghdfe `var' ///
                    `events' /// 
                    `vars_controls' ///
                    if `subsample' ///
                    & `age_range' & `sample_flavor' ///
                    [aw=sample_weight1], ///
                    vce(cluster fips) absorb(fips year_true quarter)
                }
                }
                }	
                graph drop _all	
            }

            // "delta smoothing" method
            {    
                foreach sname in id_ht id_nh1 {
                foreach var in vape dvape smoke dsmoke {
                forval m = 1/3 {
                    estimates restore es`name_age'_`name_ind_var'_`var'_`m'_`sname'
                    scalar converge_pre = e(converge)

                    xlincom ///
                    ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -3+ lead
                    (          (_b[`2'] + _b[`3']) / 2) /// -2 lead
                    (                    (_b[`3']) / 1) /// -1 lead
                    ((_b[`4'])                     / 1) ///  0 lag   
                    ((_b[`4'] + _b[`5'])           / 2) ///  1 lag
                    ((_b[`4'] + _b[`5'] + _b[`6']) / 3) ///  2+ lag
                    , post level(95)
                    eststo esd`name_age'_`name_ind_var'_`var'_`m'_`sname'
                    matrix B = J(1,6,.)
                    forval b = 1/6 {
                        matrix B[1,`b'] = converge_pre
                    }
                    estadd matrix B
                }
                }
                }
            }   

            estwrite _all using "log/estimates/brfss_eventstudy_v1_2_`ind_var'_`name_age'.sters", replace
            }
        }
        cap log close
    }

    /*
    // v2: estimate -4+ to 3+ (maybe don't present endpoints); 18-30 year olds
    if 0 {
        use "data/final/brfss_master_set_2023", clear

        keep if inrange(year_survey,2016,2023)
        
        eststo    clear
        estimates clear

        // adjust already created yearly events (y1_v1_[]_etax) -- bin leads to -4+, lags to 3+
        {
            gen     y_v1a_F4_etax = y_v1_F5_etax + y_v1_F4_etax
            gen     y_v1a_F3_etax = y_v1_F3_etax 
            gen     y_v1a_F2_etax = y_v1_F2_etax
            gen     y_v1a_F1_etax = y_v1_F1_etax
            gen     y_v1a_L0_etax = y_v1_L0_etax
            gen     y_v1a_L1_etax = y_v1_L1_etax
            gen     y_v1a_L2_etax = y_v1_L2_etax
            gen     y_v1a_L3_etax = y_v1_L3_etax + y_v1_L4_etax

            replace y_v1a_F1_etax = 0 // -1 year to zero
        }

        global brfss_dem_control i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college /*c.white*/ c.black c.hispanic c.other_race

        // denote essential controls (***)
        {
            local vars_essential_coef1_b /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape c.t21 c.cigarette_tax_scale
            local vars_essential_coef0_b c.uer c.coviddeaths c.populationvaccinated ${brfss_dem_control}

            local events y_v1a_F4_etax y_v1a_F3_etax y_v1a_F2_etax y_v1a_F1_etax y_v1a_L0_etax y_v1a_L1_etax y_v1a_L2_etax y_v1a_L3_etax
            tokenize "`events'"
        }

        // estimation
        {
            local samp_event "heterosexual==1 lgbq==1"	
            foreach vari in vape {

                foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "heterosexual==1" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"
                    }
                }

                foreach var in `vari' d`vari' {
                    // denote LASSO controls (***)
                    {
                        if inlist("`var'","vape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'_b}
                    }
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' `vars_lasso_sel'

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' `vars_lasso_sel' c.tally_sexualorientation 
                    }

                    logit `var' ///
                    `events' /// 
                    `vars_controls' ///
                    i.fips i.year_true i.quarter if `subsample' ///
                    & inrange(age,18,30) ///
                    [pw=sample_weight1], vce(cluster fips)

                    scalar converge_pre = e(converged)

                    _eststo es_`var'_`m'_`sname': ///
                    margins, dydx(`events') post
                    estadd scalar converge = converge_pre                
                }
                }
                }	
                graph drop _all	
            }

            // delta method
            {    
                foreach sname in id_ht id_nh1 {
                    foreach var in vape dvape {
                    forval m = 1/3 {
                    
                    estimates restore es_`var'_`m'_`sname'

                    xlincom ///
                    ((_b[`1'] + _b[`2'] + _b[`3'] + _b[`4']) / 4) /// -4+ lead
                    (          (_b[`2'] + _b[`3'] + _b[`4']) / 3) /// -3 lead
                    (                    (_b[`3'] + _b[`4']) / 2) /// -2 lead
                    (                              (_b[`4']) / 1) /// -1 lead
                    ((_b[`5'])                               / 1) ///  0 lag   
                    ((_b[`5'] + _b[`6'])                     / 2) ///  1 lag
                    ((_b[`5'] + _b[`6'] + _b[`7'])           / 3) ///  2 lag
                    ((_b[`5'] + _b[`6'] + _b[`7'] + _b[`8']) / 4) ///  3+ lag
                    , post level(95)
                    eststo esd_`var'_`m'_`sname'
                    }
                    }
                }
            }

            estwrite _all using "log/estimates/etax/brfss_eventstudy_v2.sters", replace
        }

        // graphing
        {
            estread _all using "log/estimates/etax/brfss_eventstudy_v2.sters"

            foreach subsample in id_ht id_nh1 {
                foreach var in vape dvape {
                forval m = 1/3 {
                forval adj = 0/3 {
                    // adj-specifics
                    {
                        if `adj'==0 {
                            local name_adj
                            local list_events y_v1a_F3_etax y_v1a_F2_etax y_v1a_F1_etax y_v1a_L0_etax y_v1a_L1_etax y_v1a_L2_etax
                        }
                        if `adj'==1 {
                            local name_adj d
                            local list_events lc_2 lc_3 lc_4 lc_5 lc_6 lc_7
                        }
                        if `adj'==2 { // a0: pre-treatment avg as reference, exclude -1 in avg
                            estimates restore es_`var'_`m'_`subsample'

                            local preavg = ((_b[y_v1a_F4_etax] + _b[y_v1a_F3_etax] + _b[y_v1a_F2_etax]) / 3)

                            xlincom ///
                            (_b[y_v1a_F4_etax] - `preavg') /// -4+ lead
                            (_b[y_v1a_F3_etax] - `preavg') /// -3 lead
                            (_b[y_v1a_F2_etax] - `preavg') /// -2 lead
                            (_b[y_v1a_F1_etax])            /// -1 lead
                            (_b[y_v1a_L0_etax] - `preavg') /// 0 lag
                            (_b[y_v1a_L1_etax] - `preavg') /// 1 lag
                            (_b[y_v1a_L2_etax] - `preavg') /// 2 lag
                            (_b[y_v1a_L3_etax] - `preavg') /// 3+ lag
                            , post level(95)
                            _eststo esa0_`var'_`m'_`subsample'

                            local name_adj a0
                            local list_events lc_2 lc_3 lc_4 lc_5 lc_6 lc_7
                        }
                        if `adj'==3 { // a1: pre-treatment avg as reference, include -1 in avg
                            estimates restore es_`var'_`m'_`subsample'

                            local preavg = ((_b[y_v1a_F4_etax] + _b[y_v1a_F3_etax] + _b[y_v1a_F2_etax] + _b[y_v1a_F1_etax]) / 4)

                            xlincom ///
                            (_b[y_v1a_F4_etax] - `preavg') /// -4+ lead
                            (_b[y_v1a_F3_etax] - `preavg') /// -3 lead
                            (_b[y_v1a_F2_etax] - `preavg') /// -2 lead
                            (_b[y_v1a_F1_etax] - `preavg') /// -1 lead
                            (_b[y_v1a_L0_etax] - `preavg') /// 0 lag
                            (_b[y_v1a_L1_etax] - `preavg') /// 1 lag
                            (_b[y_v1a_L2_etax] - `preavg') /// 2 lag
                            (_b[y_v1a_L3_etax] - `preavg') /// 3+ lag
                            , post level(95)
                            _eststo esa1_`var'_`m'_`subsample'

                            local name_adj a1
                            local list_events lc_2 lc_3 lc_4 lc_5 lc_6 lc_7
                        }
                    }

                    // parameters
                    {
                        // y-axis
                        if "`var'" == "vape" local ysca yla(-0.100(0.025)0.100, nogrid) 
                        if "`var'" != "vape" local ysca yla(-0.075(0.025)0.075, nogrid)
                    }

                    coefplot(es`name_adj'_`var'_`m'_`subsample', ///
                    omitted keep(`list_events') ///
                    recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                    vertical ///
                    graphregion(color(white)) ///
                    ytitle("Estimated Effect of ENDS Tax", size(medium)) ///
                    yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                    xtitle("Years Before/After ENDS Tax Increase", size(medium)) ///
                    xline(3.5, lpattern(dash) lcolor(black)) ///
                    xlabel(1 "-3" 2 "-2" 3 "-1" 4 "0" 5 "1" 6 "2", labsize(medium)) ///
                    legend(off) ///
                    ciopts(recast(rcap) lwidth(thin)) 

                    graph export "output/etax/graphs/final/brfss_es`name_adj'_v2_m`m'_`var'_`subsample'.png", replace
                    graph close		
                }
                }
                }
            }
        }
        use "data/final/brfss_master_set_2023", clear	

        macro drop _name_delta
    }

    // v3: estimate -7+ to 4+ (don't present endpoints); 18-30 year olds
    if 0 {
        use "data/final/brfss_master_set_2023", clear

        keep if inrange(year_survey,2016,2023)
        
        eststo    clear
        estimates clear

        global brfss_dem_control i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college /*c.white*/ c.black c.hispanic c.other_race

        // denote essential controls (***)
        {
            local vars_essential_coef1_b /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape c.t21 c.cigarette_tax_scale
            local vars_essential_coef0_b c.uer c.coviddeaths c.populationvaccinated ${brfss_dem_control}

            local events y_v4_F7_etax y_v4_F6_etax y_v4_F5_etax y_v4_F4_etax y_v4_F3_etax y_v4_F2_etax y_v4_F1_etax y_v4_L0_etax y_v4_L1_etax y_v4_L2_etax y_v4_L3_etax y_v4_L4_etax
            tokenize "`events'"
        }

        replace y_v4_F1_etax = 0

        // estimation
        {
            local samp_event "heterosexual==1 lgbq==1"	
            foreach vari in vape {

                foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "heterosexual==1" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"
                    }
                }

                foreach var in `vari' d`vari' {
                    // denote LASSO controls (***)
                    {
                        if inlist("`var'","vape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'_b}
                    }
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' `vars_lasso_sel'

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' `vars_lasso_sel' c.tally_sexualorientation 
                    }

                    logit `var' ///
                    `events' /// 
                    `vars_controls' ///
                    i.fips i.year_true i.quarter if `subsample' ///
                    & inrange(age,18,30) ///
                    [pw=sample_weight1], vce(cluster fips)

                    scalar converge_pre = e(converged)

                    _eststo es_`var'_`m'_`sname': ///
                    margins, dydx(`events') post
                    estadd scalar converge = converge_pre                
                }
                }
                }	
                graph drop _all	
            }

            // delta method
            {    
                foreach sname in id_ht id_nh1 {
                    foreach var in vape dvape {
                    forval m = 1/3 {
                    
                    estimates restore es_`var'_`m'_`sname'

                    xlincom ///
                    ((_b[`1'] + _b[`2'] + _b[`3'] + _b[`4'] + _b[`5'] + _b[`6'] + _b[`7']) / 7) /// -7+ lead
                    (          (_b[`2'] + _b[`3'] + _b[`4'] + _b[`5'] + _b[`6'] + _b[`7']) / 6) /// -6  lead
                    (                    (_b[`3'] + _b[`4'] + _b[`5'] + _b[`6'] + _b[`7']) / 5) /// -5  lead
                    (                              (_b[`4'] + _b[`5'] + _b[`6'] + _b[`7']) / 4) /// -4  lead
                    (                                        (_b[`5'] + _b[`6'] + _b[`7']) / 3) /// -3  lead
                    (                                                  (_b[`6'] + _b[`7']) / 2) /// -2  lead
                    (                                                            (_b[`7']) / 1) /// -1  lead
                    ((_b[`8'])                                                             / 1) ///  0  lag   
                    ((_b[`8'] + _b[`9'])                                                   / 2) ///  1  lag
                    ((_b[`8'] + _b[`9'] + _b[`10'])                                        / 3) ///  2  lag
                    ((_b[`8'] + _b[`9'] + _b[`10'] + _b[`11'])                             / 4) ///  3  lag
                    ((_b[`8'] + _b[`9'] + _b[`10'] + _b[`11'] + _b[`12'])                  / 5) ///  4+ lag
                    , post level(95)
                    eststo esd_`var'_`m'_`sname'
                    }
                    }
                }
            }

            estwrite _all using "log/estimates/etax/brfss_eventstudy_v3.sters", replace
        }

        // graphing
        {
            estread _all using "log/estimates/etax/brfss_eventstudy_v3.sters"

            foreach subsample in id_ht id_nh1 {
                foreach var in vape dvape {
                forval m = 1/3 {
                forval delta = 0/1 {
                    // delta-specifics
                    {
                        if `delta'==0 {
                            local name_delta
                            local list_events y_v1a_F6_etax y_v1a_F5_etax y_v1a_F4_etax y_v1a_F3_etax y_v1a_F2_etax y_v1a_F1_etax y_v1a_L0_etax y_v1a_L1_etax y_v1a_L2_etax y_v1a_L3_etax
                        }
                        if `delta'==1 {
                            local name_delta d
                            local list_events lc_2 lc_3 lc_4 lc_5 lc_6 lc_7 lc_8 lc_9 lc_10 lc_11
                        }
                    }

                    // parameters
                    {
                        // y-axis
                        if "`var'" == "vape" local ysca yla(-0.100(0.025)0.100, nogrid) 
                        if "`var'" != "vape" local ysca yla(-0.075(0.025)0.075, nogrid)
                    }

                    coefplot(es`name_delta'_`var'_`m'_`subsample', ///
                    omitted keep(`list_events') ///
                    recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                    vertical ///
                    graphregion(color(white)) ///
                    ytitle("Estimated Effect of ENDS Tax", size(medium)) ///
                    yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                    xtitle("Years Before/After ENDS Tax Increase", size(medium)) ///
                    xline(6.5, lpattern(dash) lcolor(black)) ///
                    xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3", labsize(medium)) ///
                    legend(off) ///
                    ciopts(recast(rcap) lwidth(thin)) 

                    graph export "output/etax/graphs/final/brfss_es`name_delta'_v3_m`m'_`var'_`subsample'.png", replace
                    graph close		
                }
                }
                }
            }
        }
        use "data/final/brfss_master_set_2023", clear	

        macro drop _name_delta
    }
    */

    // v4: all policies 18-80
    if 1 {
        cap log close
        log using "log/regressions/eventstudy_brfss_v4.smcl", replace

        // create events
        {
            local version v2
            use "data/inter/controls_quarterly_2023", clear

            keep fips state_abbrev year_true quarter flavor_ban cigarette_tax_scale any_mlsa_vape
            gen quarter_date = yq(year_true, quarter)
            format quarter_date %tq
            sort fips quarter_date

            // set flavor ban to zero for PA
            replace flavor_ban = 0 if state_abbrev=="PA"

            local last_lead 17
            local last_lag 8

            local last_lead_yr = ceil(`last_lead'/4)
            local last_lag_yr  = `last_lag' / 4

            foreach ind_var in flavor_ban cigarette_tax_scale any_mlsa_vape { 
                // version 2: 4 quarters of first differences in every year (17 leads and 9 lags for -5+ pre to 2+ post) then adjust
                if inlist("`ind_var'","flavor_ban","cigarette_tax_scale") {
                    bys fips: gen L0 = `ind_var'[_n] - `ind_var'[_n - 1] 
                    replace       L0 = 0 if mi(L0)

                    // leads
                    forval i = 1/`last_lead' {
                        bys fips: gen p`version'_F`i'_`ind_var' = L0[_n + `i']
                        replace p`version'_F`i'_`ind_var' = 0 if mi(p`version'_F`i'_`ind_var')

                        // endpoints
                        if `i'==`last_lead' {
                            gsort fips -year_true -quarter
                            bys fips: gen sum_p`version'_F`i'_`ind_var' = sum(p`version'_F`i'_`ind_var')
                            replace           p`version'_F`i'_`ind_var' = sum_p`version'_F`i'_`ind_var'
                            drop          sum_p`version'_F`i'_`ind_var'
                            sort fips year_true quarter
                        }
                    }

                    // lags
                    forval i = 0/`last_lag' {
                        bys fips: gen p`version'_L`i'_`ind_var' = L0[_n - `i']
                        replace       p`version'_L`i'_`ind_var' = 0 if mi(p`version'_L`i'_`ind_var')
                        
                        // endpoints
                        if `i'==`last_lag' {
                            bys fips: gen sum_p`version'_L`i'_`ind_var' = sum(p`version'_L`i'_`ind_var')
                            replace           p`version'_L`i'_`ind_var' = sum_p`version'_L`i'_`ind_var'
                            drop          sum_p`version'_L`i'_`ind_var'
                        }
                    }

                    drop L0

                    // convert to yearly and adjust for -3+
                    {
                        local j = 1

                        // leads
                        forval i=1/`last_lead_yr' {
                            if `i'!=`last_lead_yr' ///
                            gen y_`version'_F`i'_`ind_var' = ///
                            p`version'_F`=`j'+0'_`ind_var' + p`version'_F`=`j'+1'_`ind_var' + p`version'_F`=`j'+2'_`ind_var' + p`version'_F`=`j'+3'_`ind_var'
                            
                            if `i' == `last_lead_yr' gen y_`version'_F`i'_`ind_var' = ///
                            p`version'_F`=`j'+0'_`ind_var'

                            if `i' != 1 order y_`version'_F`i'_`ind_var', before(y_`version'_F`=`i'-1'_`ind_var')
                            
                            local j = `j' + 4
                        }

                        local j=0

                        // lags
                        forval i = 0/`last_lag_yr' {
                            if `i' != `last_lag_yr' gen y_`version'_L`i'_`ind_var' = ///
                            p`version'_L`=`j'+0'_`ind_var' + p`version'_L`=`j'+1'_`ind_var' + p`version'_L`=`j'+2'_`ind_var' + p`version'_L`=`j'+3'_`ind_var'
                            
                            if `i' == `last_lag_yr' gen y_`version'_L`i'_`ind_var' = ///
                            p`version'_L`=`j'+0'_`ind_var'
                        
                            local j = `j' + 4
                        }

                        // adjust
                        {
                            gen     y_v2a_F3_`ind_var' = y_v2_F5_`ind_var' + y_v2_F4_`ind_var' + y_v2_F3_`ind_var' 
                            gen     y_v2a_F2_`ind_var' = y_v2_F2_`ind_var'
                            gen     y_v2a_F1_`ind_var' = y_v2_F1_`ind_var'
                            gen     y_v2a_L0_`ind_var' = y_v2_L0_`ind_var'
                            gen     y_v2a_L1_`ind_var' = y_v2_L1_`ind_var'
                            gen     y_v2a_L2_`ind_var' = y_v2_L2_`ind_var'

                            gen     y_v2a_F1_`ind_var'_og = y_v2a_F1_`ind_var' // unadjusted -1 year [[12 char + ]]
                            replace y_v2a_F1_`ind_var' = 0                // -1 year to zero
                        }
                    }

                    drop *p`version'*
                }

                else {
                    // find introduction date
                    {
                        // first differences
                        bys fips: gen `ind_var'_intro_ = `ind_var'[_n] - `ind_var'[_n-1]
                        replace       `ind_var'_intro_ = 0 if missing(`ind_var'_intro_)

                        // grab dates w/ variation
                        replace `ind_var'_intro_ = quarter_date if `ind_var'_intro_ != 0
                        replace `ind_var'_intro_ = .            if `ind_var'_intro_ == 0
                        format  `ind_var'_intro_ %tq

                        // take earliest date w/ variation
                        bys fips: egen `ind_var'_intro = min(`ind_var'_intro_)
                        drop           `ind_var'_intro_
                    }
                    gen `version' = quarter_date - `ind_var'_intro

                    // convert to annual
                    recode `version' ///
                    (. = 99)                                  /// code missing as 99
                    (-1000/-9 = -3) (-8/-5 = -2) (-4/-1 = -1) ///
                    (0/3 = 0)       (4/7 = 1)    (8/1000 = 2)

                    xi i.`version', noomit

                    rename (_I*) (`ind_var'_*)
                    rename `ind_var'_`version'_1 y_`version'a_F3_`ind_var'
                    rename `ind_var'_`version'_2 y_`version'a_F2_`ind_var'
                    rename `ind_var'_`version'_3 y_`version'a_F1_`ind_var'
                    rename `ind_var'_`version'_4 y_`version'a_L0_`ind_var'
                    rename `ind_var'_`version'_5 y_`version'a_L1_`ind_var'
                    rename `ind_var'_`version'_6 y_`version'a_L2_`ind_var'
                    // missing as `ind_var'_`version'_7

                    // set reference as -1
                    {
                        gen     y_`version'a_F1_`ind_var'_og = y_`version'a_F1_`ind_var'
                        replace y_`version'a_F1_`ind_var'    = 0
                    }

                    drop `version'
                }
            }

            tempfile brfss_other_pol
            save    `brfss_other_pol'
        }

        use "data/final/brfss_master_set_2023", clear
        
        merge m:1 fips year_true quarter using `brfss_other_pol'
        drop if _merge==2
        drop _merge

        // adjust already created endstax events -- bin leads to -3+
        {
            gen     y_v2a_F3_etax = y_v2_F5_etax + y_v2_F4_etax + y_v2_F3_etax 
            gen     y_v2a_F2_etax = y_v2_F2_etax
            gen     y_v2a_F1_etax = y_v2_F1_etax
            gen     y_v2a_L0_etax = y_v2_L0_etax
            gen     y_v2a_L1_etax = y_v2_L1_etax
            gen     y_v2a_L2_etax = y_v2_L2_etax

            gen     y_v2a_F1_etax_og = y_v2a_F1_etax // unadjusted -1 year
            replace y_v2a_F1_etax = 0 // -1 year to zero
        }

        global brfss_dem_control i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college /*c.white*/ c.black c.hispanic c.other_race

        keep if inrange(year_survey,2014,2023)

        // estimation
        foreach ind_var in ends_tax_nom35_scale any_mlsa_vape flavor_ban cigarette_tax_scale {
            // ind_var-specific
            {
                if "`ind_var'"=="ends_tax_nom35_scale" {
                    local name_ind_var 1
                    local vars_essential_coef1_b /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape c.t21 c.cigarette_tax_scale
                    local sample_flavor 1
                    local name_event etax
                }
                if "`ind_var'"=="any_mlsa_vape" {
                    local name_ind_var 2
                    local vars_essential_coef1_b c.ends_tax_nom35_scale c.flavor_ban /*c.any_mlsa_vape*/ c.t21 c.cigarette_tax_scale
                    local sample_flavor 1
                    local name_event `ind_var'
                }
                if "`ind_var'"=="flavor_ban" {
                    local name_ind_var 3
                    local vars_essential_coef1_b c.ends_tax_nom35_scale /*c.flavor_ban*/ c.any_mlsa_vape c.t21 c.cigarette_tax_scale
                    local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR
                    local name_event `ind_var'
                }
                if "`ind_var'"=="cigarette_tax_scale" {
                    local name_ind_var 4
                    local vars_essential_coef1_b c.ends_tax_nom35_scale c.flavor_ban c.any_mlsa_vape c.t21 /*c.cigarette_tax_scale*/
                    local sample_flavor 1
                    local name_event `ind_var'
                }
            }
            // denote essential controls (***)
            {
                local vars_essential_coef0_b c.uer c.coviddeaths c.populationvaccinated ${brfss_dem_control}

                local events     y_v2a_F3_`name_event' y_v2a_F2_`name_event' y_v2a_F1_`name_event'    y_v2a_L0_`name_event' y_v2a_L1_`name_event' y_v2a_L2_`name_event'
                local events_adj y_v2a_F3_`name_event' y_v2a_F2_`name_event' y_v2a_F1_`name_event'_og y_v2a_L0_`name_event' y_v2a_L1_`name_event' y_v2a_L2_`name_event'
                tokenize "`events'"
            }

                eststo    clear
                estimates clear

            local samp_event "heterosexual==1 lgbq==1"	
            foreach vari in vape smoke {

                foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "heterosexual==1" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"
                    }
                }

                foreach var in `vari' d`vari' {
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' ${vars_lasso_sel_`var'_b}

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' ${vars_lasso_sel_`var'_b} c.tally_sexualorientation 
                    }
                    
                    // estimation
                    logit `var' ///
                    `events' /// 
                    `vars_controls' ///
                    i.fips i.year_true i.quarter if `subsample' ///
                    & `sample_flavor' ///
                    [pw=sample_weight1], vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)

                    _eststo es_`name_ind_var'_`var'_`m'_`sname': ///
                    margins, dydx(`events') post
                    estadd scalar converge = converge_pre
                    matrix B = J(1,6,.)
                    forval b = 1/6 {
                        matrix B[1,`b'] = converge_pre
                    }
                    estadd matrix B
                    
                    // constrained linear regression ('cnsreg')
                    {
                        constraint 1 (y_v2a_F3_`name_event' + y_v2a_F2_`name_event' + y_v2a_F1_`name_event'_og) / 3 = 0

                        _eststo esc_`name_ind_var'_`var'_`m'_`sname': ///
                        cnsreg `var' ///
                        `events_adj' ///
                        `vars_controls' ///
                        i.fips i.year_true i.quarter ///
                        if `subsample' & `sample_flavor' [pw=sample_weight1], ///
                        constraints(1) vce(cluster fips)
                    }

                    // OLS
                    _eststo eso_`name_ind_var'_`var'_`m'_`sname': ///
                    reghdfe `var' ///
                    `events' /// 
                    `vars_controls' ///
                    if `subsample' ///
                    & `sample_flavor' ///
                    [aw=sample_weight1], ///
                    vce(cluster fips) absorb(fips year_true quarter)
                }
                }
                }	
                graph drop _all	
            }

            // "delta smoothing" method
            {    
                foreach sname in id_ht id_nh1 {
                foreach var in vape dvape smoke dsmoke {
                forval m = 1/3 {
                    estimates restore es_`name_ind_var'_`var'_`m'_`sname'
                    scalar converge_pre = e(converge)

                    xlincom ///
                    ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -3+ lead
                    (          (_b[`2'] + _b[`3']) / 2) /// -2 lead
                    (                    (_b[`3']) / 1) /// -1 lead
                    ((_b[`4'])                     / 1) ///  0 lag   
                    ((_b[`4'] + _b[`5'])           / 2) ///  1 lag
                    ((_b[`4'] + _b[`5'] + _b[`6']) / 3) ///  2+ lag
                    , post level(95)
                    eststo esd_`name_ind_var'_`var'_`m'_`sname'
                    matrix B = J(1,6,.)
                    forval b = 1/6 {
                        matrix B[1,`b'] = converge_pre
                    }
                    estadd matrix B
                }
                }
                }
            }   

            estwrite _all using "log/estimates/brfss_eventstudy_v4_`ind_var'.sters", replace
        }
        cap log close
    }

    // v5: flavor ban turning off temporary bans
    if 0 {
        cap log close
        log using "log/regressions/eventstudy_brfss_v5.smcl", replace

        // create events
        {
            local version v2
            use "data/inter/controls_quarterly_2023", clear

            keep fips state_abbrev year_true quarter flavor_ban cigarette_tax_scale any_mlsa_vape
            gen quarter_date = yq(year_true, quarter)
            format quarter_date %tq
            sort fips quarter_date

            // set flavor ban to zero for PA
            replace flavor_ban = 0 if state_abbrev=="PA"

            // turn off WA flavor ban
            replace flavor_ban=0 if fips==53
            // turn off MT flavor ban
            replace flavor_ban=0 if fips==30

            local last_lead 17
            local last_lag 8

            local last_lead_yr = ceil(`last_lead'/4)
            local last_lag_yr  = `last_lag' / 4

            foreach ind_var in flavor_ban cigarette_tax_scale any_mlsa_vape { 
                // version 2: 4 quarters of first differences in every year (17 leads and 9 lags for -5+ pre to 2+ post) then adjust
                if inlist("`ind_var'","flavor_ban","cigarette_tax_scale") {
                    bys fips: gen L0 = `ind_var'[_n] - `ind_var'[_n - 1] 
                    replace       L0 = 0 if mi(L0)

                    // leads
                    forval i = 1/`last_lead' {
                        bys fips: gen p`version'_F`i'_`ind_var' = L0[_n + `i']
                        replace p`version'_F`i'_`ind_var' = 0 if mi(p`version'_F`i'_`ind_var')

                        // endpoints
                        if `i'==`last_lead' {
                            gsort fips -year_true -quarter
                            bys fips: gen sum_p`version'_F`i'_`ind_var' = sum(p`version'_F`i'_`ind_var')
                            replace           p`version'_F`i'_`ind_var' = sum_p`version'_F`i'_`ind_var'
                            drop          sum_p`version'_F`i'_`ind_var'
                            sort fips year_true quarter
                        }
                    }

                    // lags
                    forval i = 0/`last_lag' {
                        bys fips: gen p`version'_L`i'_`ind_var' = L0[_n - `i']
                        replace       p`version'_L`i'_`ind_var' = 0 if mi(p`version'_L`i'_`ind_var')
                        
                        // endpoints
                        if `i'==`last_lag' {
                            bys fips: gen sum_p`version'_L`i'_`ind_var' = sum(p`version'_L`i'_`ind_var')
                            replace           p`version'_L`i'_`ind_var' = sum_p`version'_L`i'_`ind_var'
                            drop          sum_p`version'_L`i'_`ind_var'
                        }
                    }

                    drop L0

                    // convert to yearly and adjust for -3+
                    {
                        local j = 1

                        // leads
                        forval i=1/`last_lead_yr' {
                            if `i'!=`last_lead_yr' ///
                            gen y_`version'_F`i'_`ind_var' = ///
                            p`version'_F`=`j'+0'_`ind_var' + p`version'_F`=`j'+1'_`ind_var' + p`version'_F`=`j'+2'_`ind_var' + p`version'_F`=`j'+3'_`ind_var'
                            
                            if `i' == `last_lead_yr' gen y_`version'_F`i'_`ind_var' = ///
                            p`version'_F`=`j'+0'_`ind_var'

                            if `i' != 1 order y_`version'_F`i'_`ind_var', before(y_`version'_F`=`i'-1'_`ind_var')
                            
                            local j = `j' + 4
                        }

                        local j=0

                        // lags
                        forval i = 0/`last_lag_yr' {
                            if `i' != `last_lag_yr' gen y_`version'_L`i'_`ind_var' = ///
                            p`version'_L`=`j'+0'_`ind_var' + p`version'_L`=`j'+1'_`ind_var' + p`version'_L`=`j'+2'_`ind_var' + p`version'_L`=`j'+3'_`ind_var'
                            
                            if `i' == `last_lag_yr' gen y_`version'_L`i'_`ind_var' = ///
                            p`version'_L`=`j'+0'_`ind_var'
                        
                            local j = `j' + 4
                        }

                        // adjust
                        {
                            gen     y_v2a_F3_`ind_var' = y_v2_F5_`ind_var' + y_v2_F4_`ind_var' + y_v2_F3_`ind_var' 
                            gen     y_v2a_F2_`ind_var' = y_v2_F2_`ind_var'
                            gen     y_v2a_F1_`ind_var' = y_v2_F1_`ind_var'
                            gen     y_v2a_L0_`ind_var' = y_v2_L0_`ind_var'
                            gen     y_v2a_L1_`ind_var' = y_v2_L1_`ind_var'
                            gen     y_v2a_L2_`ind_var' = y_v2_L2_`ind_var'

                            gen     y_v2a_F1_`ind_var'_og = y_v2a_F1_`ind_var' // unadjusted -1 year [[12 char + ]]
                            replace y_v2a_F1_`ind_var' = 0                // -1 year to zero
                        }
                    }

                    drop *p`version'*
                }

                else {
                    // find introduction date
                    {
                        // first differences
                        bys fips: gen `ind_var'_intro_ = `ind_var'[_n] - `ind_var'[_n-1]
                        replace       `ind_var'_intro_ = 0 if missing(`ind_var'_intro_)

                        // grab dates w/ variation
                        replace `ind_var'_intro_ = quarter_date if `ind_var'_intro_ != 0
                        replace `ind_var'_intro_ = .            if `ind_var'_intro_ == 0
                        format  `ind_var'_intro_ %tq

                        // take earliest date w/ variation
                        bys fips: egen `ind_var'_intro = min(`ind_var'_intro_)
                        drop           `ind_var'_intro_
                    }
                    gen `version' = quarter_date - `ind_var'_intro

                    // convert to annual
                    recode `version' ///
                    (. = 99)                                  /// code missing as 99
                    (-1000/-9 = -3) (-8/-5 = -2) (-4/-1 = -1) ///
                    (0/3 = 0)       (4/7 = 1)    (8/1000 = 2)

                    xi i.`version', noomit

                    rename (_I*) (`ind_var'_*)
                    rename `ind_var'_`version'_1 y_`version'a_F3_`ind_var'
                    rename `ind_var'_`version'_2 y_`version'a_F2_`ind_var'
                    rename `ind_var'_`version'_3 y_`version'a_F1_`ind_var'
                    rename `ind_var'_`version'_4 y_`version'a_L0_`ind_var'
                    rename `ind_var'_`version'_5 y_`version'a_L1_`ind_var'
                    rename `ind_var'_`version'_6 y_`version'a_L2_`ind_var'
                    // missing as `ind_var'_`version'_7

                    // set reference as -1
                    {
                        gen     y_`version'a_F1_`ind_var'_og = y_`version'a_F1_`ind_var'
                        replace y_`version'a_F1_`ind_var'    = 0
                    }

                    drop `version'
                }
            }

            tempfile brfss_other_pol
            save    `brfss_other_pol'
        }

        use "data/final/brfss_master_set_2023", clear
        
        merge m:1 fips year_true quarter using `brfss_other_pol'
        drop if _merge==2
        drop _merge

        // turn off WA flavor ban
        replace flavor_ban=0 if fips==53
        // turn off MT flavor ban
        replace flavor_ban=0 if fips==30

        global brfss_dem_control i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college /*c.white*/ c.black c.hispanic c.other_race

        keep if inrange(year_survey,2014,2023)

        // estimation
        foreach ind_var in flavor_ban {
            // ind_var-specific
            {
                if "`ind_var'"=="any_mlsa_vape" {
                    local name_ind_var 2
                    local vars_essential_coef1_b c.ends_tax_nom35_scale c.flavor_ban /*c.any_mlsa_vape*/ c.t21 c.cigarette_tax_scale
                    local sample_flavor 1
                }
                if "`ind_var'"=="flavor_ban" {
                    local name_ind_var 3
                    local vars_essential_coef1_b c.ends_tax_nom35_scale /*c.flavor_ban*/ c.any_mlsa_vape c.t21 c.cigarette_tax_scale
                    local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR
                }
                if "`ind_var'"=="cigarette_tax_scale" {
                    local name_ind_var 4
                    local vars_essential_coef1_b c.ends_tax_nom35_scale c.flavor_ban c.any_mlsa_vape c.t21 /*c.cigarette_tax_scale*/
                    local sample_flavor 1
                }
            }
            // denote essential controls (***)
            {
                local vars_essential_coef0_b c.uer c.coviddeaths c.populationvaccinated ${brfss_dem_control}

                local events     y_v2a_F3_`ind_var' y_v2a_F2_`ind_var' y_v2a_F1_`ind_var'    y_v2a_L0_`ind_var' y_v2a_L1_`ind_var' y_v2a_L2_`ind_var'
                local events_adj y_v2a_F3_`ind_var' y_v2a_F2_`ind_var' y_v2a_F1_`ind_var'_og y_v2a_L0_`ind_var' y_v2a_L1_`ind_var' y_v2a_L2_`ind_var'
                tokenize "`events'"
            }

            foreach age_range in inrange(age,18,30) inrange(age,31,80) {
                eststo    clear
                estimates clear

                // age_range-specific
                {
                    if "`age_range'"=="inrange(age,18,30)" local name_age
                    if "`age_range'"=="inrange(age,31,80)" local name_age 1
                }
            local samp_event "heterosexual==1 lgbq==1"	
            foreach vari in vape smoke {

                foreach subsample of local samp_event {
                
                // subsample-specifics
                {
                    if "`subsample'" == "heterosexual==1" {
                    local sname "id_ht"
                    local stit "Heterosexual"
                    }
                    if "`subsample'" == "lgbq==1" {
                    local sname "id_nh1"
                    local stit "LGBQ"
                    }
                }

                foreach var in `vari' d`vari' {
                forval m = 1/3 {                
                    // model-specific (***)
                    {
                        if `m'==1 /// essential vars
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b'

                        if `m'==2 /// essential vars + LASSO
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' ${vars_lasso_sel_`var'_b}

                        if `m'==3 /// essential vars + LASSO + LGBQ policy
                        local vars_controls `vars_essential_coef1_b' `vars_essential_coef0_b' ${vars_lasso_sel_`var'_b} c.tally_sexualorientation 
                    }
                    
                    // estimation
                    logit `var' ///
                    `events' /// 
                    `vars_controls' ///
                    i.fips i.year_true i.quarter if `subsample' ///
                    & `age_range' & `sample_flavor' ///
                    [pw=sample_weight1], vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)

                    _eststo es`name_age'_`name_ind_var'_`var'_`m'_`sname': ///
                    margins, dydx(`events') post
                    estadd scalar converge = converge_pre
                    matrix B = J(1,6,.)
                    forval b = 1/6 {
                        matrix B[1,`b'] = converge_pre
                    }
                    estadd matrix B
                    
                    // constrained linear regression ('cnsreg')
                    {
                        constraint 1 (y_v2a_F3_`ind_var' + y_v2a_F2_`ind_var' + y_v2a_F1_`ind_var'_og) / 3 = 0

                        _eststo esc`name_age'_`name_ind_var'_`var'_`m'_`sname': ///
                        cnsreg `var' ///
                        `events_adj' ///
                        `vars_controls' ///
                        i.fips i.year_true i.quarter ///
                        if `subsample' & `age_range' & `sample_flavor' [pw=sample_weight1], ///
                        constraints(1) vce(cluster fips)
                    }

                    // OLS
                    _eststo eso`name_age'_`name_ind_var'_`var'_`m'_`sname': ///
                    reghdfe `var' ///
                    `events' /// 
                    `vars_controls' ///
                    if `subsample' ///
                    & `age_range' & `sample_flavor' ///
                    [aw=sample_weight1], ///
                    vce(cluster fips) absorb(fips year_true quarter)
                }
                }
                }	
                graph drop _all	
            }

            // "delta smoothing" method
            {    
                foreach sname in id_ht id_nh1 {
                foreach var in vape dvape smoke dsmoke {
                forval m = 1/3 {
                    estimates restore es`name_age'_`name_ind_var'_`var'_`m'_`sname'
                    scalar converge_pre = e(converge)

                    xlincom ///
                    ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -3+ lead
                    (          (_b[`2'] + _b[`3']) / 2) /// -2 lead
                    (                    (_b[`3']) / 1) /// -1 lead
                    ((_b[`4'])                     / 1) ///  0 lag   
                    ((_b[`4'] + _b[`5'])           / 2) ///  1 lag
                    ((_b[`4'] + _b[`5'] + _b[`6']) / 3) ///  2+ lag
                    , post level(95)
                    eststo esd`name_age'_`name_ind_var'_`var'_`m'_`sname'
                    matrix B = J(1,6,.)
                    forval b = 1/6 {
                        matrix B[1,`b'] = converge_pre
                    }
                    estadd matrix B
                }
                }
                }
            }   

            estwrite _all using "log/estimates/brfss_eventstudy_v5_`ind_var'_`name_age'.sters", replace
            }
        }
        cap log close
    }
}

// heterogeneity figures
if 1 {
    // intersectionality:
    // regressions: flavor ban intersectionality
    if 1 {
        eststo clear
        estimates clear

        // state yrbs; all, hetero, lgbq; fvape, fsmoke
        foreach yr in 5 1 {
        foreach q of numlist 6 9 10 11 12 13 14 25 26 27 28 29 30 31 32 33 34 {
            local subsample = word("$samples",`q') // MUST RUN "03_reg_main.do" for "$samples"
            di "`q' `subsample'"
            // subsample-specifics
            {	
                if `q' == 6 {
                local name_sample "all" // all youth, not missing sex id info
                global dem_control i.sex i.grade i.age i.race4
                global dem_control_name *.sex *.grade *.age *.race4
                }

                if `q' == 9 {
                local name_sample "id_ht" // sexual id - heterosexual
                global dem_control i.sex i.grade i.age i.race4
                global dem_control_name *.sex *.grade *.age *.race4
                }
                if `q' == 10 {
                local name_sample "id_nh1" // sexual id - non-heterosexual(spec 1)
                global dem_control i.sex i.grade i.age i.race4
                global dem_control_name *.sex *.grade *.age *.race4
                }
                if `q' == 11 {
                local name_sample "id_nh2" // sexual id - non-heterosexual(spec 2)
                global dem_control i.sex i.grade i.age i.race4
                global dem_control_name *.sex *.grade *.age *.race4
                }	
                if `q' == 12 { 
                local name_sample "id_gl" // sexual id - gay or lesbian
                global dem_control i.sex i.grade i.age i.race4
                global dem_control_name *.sex *.grade *.age *.race4
                }
                if `q' == 13 {
                local name_sample "id_bi" // sexual id - bisexual
                global dem_control i.sex i.grade i.age i.race4
                global dem_control_name *.sex *.grade *.age *.race4
                }
                if `q' == 14 {
                local name_sample "id_ns" // sexual id - not sure
                global dem_control i.sex i.grade i.age i.race4
                global dem_control_name *.sex *.grade *.age *.race4
                }

                if `q' == 25 {
                local name_sample "mh" // male, heterosexual
                global dem_control i.grade i.age i.race4
                global dem_control_name *.grade *.age *.race4
                }	
                if `q' == 26 {
                local name_sample "ml" // male, LGBQ
                global dem_control i.grade i.age i.race4
                global dem_control_name *.grade *.age *.race4
                }
                if `q' == 27 {
                local name_sample "fh" // female, heterosexual
                global dem_control i.grade i.age i.race4
                global dem_control_name *.grade *.age *.race4
                }
                if `q' == 28 {
                local name_sample "fl" // female, lgbq
                global dem_control i.grade i.age i.race4
                global dem_control_name *.grade *.age *.race4
                }
                if `q' == 29 {
                local name_sample "wh" // white, heterosexual
                global dem_control i.sex i.grade i.age
                global dem_control_name *.sex *.grade *.age 
                }
                if `q' == 30 {
                local name_sample "wl" // white, LGBQ
                global dem_control i.sex i.grade i.age
                global dem_control_name *.sex *.grade *.age 
                }
                if `q' == 31 {
                local name_sample "nwh" // non-white, heterosexual
                global dem_control i.sex i.grade i.age
                global dem_control_name *.sex *.grade *.age 
                }
                if `q' == 32 {
                local name_sample "nwl" // non-white, LGBQ
                global dem_control i.sex i.grade i.age
                global dem_control_name *.sex *.grade *.age 
                }		


                if `q' == 33 {
                local name_sample "gl_m" // gay/lesbian, male
                global dem_control i.grade i.age i.race4
                global dem_control_name *.grade *.age *.race4
                }
                if `q' == 34 {
                local name_sample "gl_f" // gay/lesbian, female
                global dem_control i.grade i.age i.race4
                global dem_control_name *.grade *.age *.race4
                }			
            }
        foreach var of varlist fvape fsmoke {
            // skip pattern
            {
                if `yr'==1 & "`var'"=="fvape" continue
            }
        forval model = 1/3 {
            // denote controls
            {
                if inlist("`var'","fvape") local vars_lasso_sel ${vars_lasso_sel_`var'}
                else                       local vars_lasso_sel ${vars_lasso_sel_`var'y`yr'}

                if `model'==1 local vars_controls ${vars_essential_coef1} ${vars_essential_coef0} ${dem_control}
                if `model'==2 local vars_controls ${vars_essential_coef1} ${vars_essential_coef0} ${dem_control} `vars_lasso_sel' 
                if `model'==3 local vars_controls ${vars_essential_coef1} ${vars_essential_coef0} ${dem_control} `vars_lasso_sel' c.tally_sexualorientation
            }

            // logit 
            logit `var' ///
            `vars_controls' ///
            i.fips i.year_true i.semester ///
            if `subsample' & !inlist(fips,6,11,25,41) [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)	

            _eststo `var'_`model'l3l_`name_sample'y`yr'3_st: ///
            margins, dydx(flavor_ban) post
            estadd scalar converge = converge_pre

            // OLS
            _eststo `var'_`model'3l_`name_sample'y`yr'3_st: ///
            reghdfe `var' ///
            `vars_controls' ///
            if `subsample' & !inlist(fips,6,11,25,41) [aw=aweight], ///
            vce(cluster fips) absorb(fips year_true semester)
        }
        }
            estwrite _all using "log/estimates/other_pol_v20_inter.sters", append
            eststo clear
            estimates clear
        } 
        }
    }
    
    // v1: heterosexual vs lgbq; all, male, female, NH white, hispanic or non-white (w/ OLS for non convergence)
    if 1 { 
        *local f_converge mlabel(@aux1) aux(B[1,]) mlabgap(*2)

        eststo clear 
        estimates clear
        
        foreach ind_var in etax mlsa cigtax flav {
            // ind_var-specific
            {
                if "`ind_var'"=="etax" {
                    local f_title "ENDS Taxes"
                    local f_ind_var ends_tax_nom35_scale
                }
                if "`ind_var'"=="flav"   {
                    local f_title "ENDS Flavor Bans"
                    local f_ind_var flavor_ban
                }
                if "`ind_var'"=="mlsa"   {
                    local f_title "ENDS MLSA"
                    local f_ind_var any_mlsa_vape
                }
                if "`ind_var'"=="cigtax" {
                    local f_title "Cigarette Taxes"
                    local f_ind_var cigarette_tax_scale
                }
            }
        foreach yr in y5 y1 {
        foreach survey in st {   
        foreach var in fvape fsmoke {
            // skip pattern
            {
                // ignore vape pre-2015
                if inlist("`var'","vape","fvape","dvape") & ("`yr'" == "y1") continue
                // ignore cigarette post-2011
                if "`var'"=="fsmoke" & "`yr'"=="y5" continue
            }

            if "`ind_var'"!="flav" estread *`var'_3l* using "log/estimates/main_`yr'3st3l"
            if "`ind_var'"=="flav" estread *`var'_3* using "log/estimates/other_pol_v20_inter"

        forval model = 3/3 {        
            // OLS replacements for logit non-convergence
            {
                // turn these off for substitutions
                local logit_wh l
                local logit_wl l

                if inlist("`ind_var'","etax","mlsa","cigtax") {
                    // frequent cigarette smoking
                    if "`var'"=="fsmoke" & `model'==3 {
                        // heterosexual, NH white (2011,2015)
                        estread `var'_`model'*_wh* using "log/estimates/main_`yr'3st`model'"
                        local logit_wh 
                    }

                    /*
                    // everyday cigarette smoking
                    if "`var'"=="dsmoke" & `model'==3 {
                        // heterosexual, NH white (2011,2015)
                        estread `var'_`model'*_wh* using "log/estimates/main_`yr'3st`model'"
                        local logit_wh
                    }

                    // frequent cigarette or cigar smoking 
                    if "`var'"=="fcombust" & `model'==3 & "`yr'"=="y5" {
                        // lgbq, nh white (2015)
                        estread `var'_`model'*_wl* using "log/estimates/main_`yr'3st`model'"
                        local logit_wl
                    }
                    // everyday cigarette or cigar smoking
                    if "`var'"=="dcombust" & `model'==3 & "`yr'"=="y1" {
                        // heterosexual, NH white (2011,2015)
                        estread `var'_`model'*_wh* using "log/estimates/main_`yr'3st`model'"
                        local logit_wh
                    }
                    */
                }
                if "`ind_var'"=="flav"   & "`var'"=="fsmoke" local logit_wh
            }
            
            // parameters
            {
                // y-axis
                if "`var'" == "fvape"  local ysca "-0.06(0.03)0.06"
                if "`var'" == "fsmoke" local ysca "-0.04(0.02)0.04"

                if "`ind_var'"=="flav" & "`var'"=="fvape"  local ysca "-0.100(0.050)0.100"
                if "`ind_var'"=="mlsa" & "`var'"=="fsmoke" local ysca "-0.060(0.030).060"

                
                if "`ind_var'"=="flav" { // convergence label
                foreach group in id_ht id_nh1 mh ml fh fl wh wl nwh nwl {
                    estimates restore `var'_`model'l3l_`group'`yr'3_`survey'
                    matrix B = e(converge)
                    estadd matrix B
                }
                }
            }
            // Coefficient Plot
            /* 'aux' and 'mlabel' let us see convergence */
            
            // list estimates
            {
                if "`ind_var'"!="flav" {
                    local f_estlist ///
                    (`var'_`model'l_id_ht`yr'3_`survey'      , msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.66) `f_converge') ///
                    (`var'_`model'l_id_nh1`yr'3_`survey'     , msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.61) `f_converge') ///
                    (`var'_`model'l_mh`yr'3_`survey'         , msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.41) `f_converge') /// 
                    (`var'_`model'l_ml`yr'3_`survey'         , msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.36) `f_converge') ///
                    (`var'_`model'l_fh`yr'3_`survey'         , msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.16) `f_converge') ///
                    (`var'_`model'l_fl`yr'3_`survey'         , msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.11) `f_converge') ///
                    (`var'_`model'`logit_wh'_wh`yr'3_`survey', msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(0.11)  `f_converge') ///
                    (`var'_`model'`logit_wl'_wl`yr'3_`survey', msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(0.16)  `f_converge') ///
                    (`var'_`model'l_nwh`yr'3_`survey'        , msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(0.36)  `f_converge') ///
                    (`var'_`model'l_nwl`yr'3_`survey'        , msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(0.41)  `f_converge')
                }
                if "`ind_var'"=="flav" {
                    local f_estlist ///
                    (`var'_`model'l3l_id_ht`yr'3_`survey'      , msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.66) `f_converge') ///
                    (`var'_`model'l3l_id_nh1`yr'3_`survey'     , msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.61) `f_converge') ///
                    (`var'_`model'l3l_mh`yr'3_`survey'         , msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.41) `f_converge') /// 
                    (`var'_`model'l3l_ml`yr'3_`survey'         , msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.36) `f_converge') ///
                    (`var'_`model'l3l_fh`yr'3_`survey'         , msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.16) `f_converge') ///
                    (`var'_`model'l3l_fl`yr'3_`survey'         , msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(-0.11) `f_converge') ///
                    (`var'_`model'`logit_wh'3l_wh`yr'3_`survey', msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(0.11)  `f_converge') ///
                    (`var'_`model'`logit_wl'3l_wl`yr'3_`survey', msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(0.16)  `f_converge') ///
                    (`var'_`model'l3l_nwh`yr'3_`survey'        , msymbol(O) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(0.36)  `f_converge') ///
                    (`var'_`model'l3l_nwl`yr'3_`survey'        , msymbol(T) mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) offset(0.41)  `f_converge')
                }
            }

            coefplot ///
            `f_estlist' ///
            , vertical keep(`f_ind_var') level(95) ///
            graphregion(color(white)) plotregion(margin(medium)) scheme(s2mono) /// 
            legend(order(6 8) row(1) lab(6 "Heterosexual") lab(8 "LGBQ")) ///
            yline(0,lp(dash)) ylabel(`ysize', nogrid angle(0) labsize(medium) format(%7.2fc)) ///
            xsize(15) ysize(8) ///
            ytitle("Estimated Effect of `f_title'", xoffset(-2) size(medium)) ///
            xlabel(0.3675 "All" 0.6175 "Male" 0.8675 "Female" 1.1325 "NH White" 1.3825 "Hispanic or Non-White" , labsize(medium)) ///
            ylabel(`ysca') ///
            mlabposition(3) mlabangle(vertical) ///
            msize(large) 

            graph export "output/etax/graphs/final/het_intersection_v1_`ind_var'_m`model'_`yr'_`var'.png", replace
            graph close
        }
            estimates clear
        }
        }
        }
        }
    }
}

// aggregated estimates event study 
if 1 {
    // endstax, state yrbs, 2015-2023, vaping/smoking outcomes (v42 OLS/logit/cnsreg with TWFE and stacked DD)
    if 1 {
        eststo clear
        estimates clear

        *local f_converge mlabel(@aux1) aux(B[1,]) mlabgap(*2) mlabposition(12)

        foreach survey in st {
        foreach yr in 5 1 {
        foreach subsample in id_ht id_nh1 {
            // subsample-specific
            {
                // name length
                local sname `subsample'
                if "`survey'"=="st"  & "`subsample'"=="id_nh1" local sname id_nh1
                if "`survey'"=="com" & "`subsample'"=="id_nh1" local sname nh1  
            }
        foreach var in vape fvape dvape smoke fsmoke dsmoke {
            // skip pattern
            {
                if inlist("`var'","vape","fvape","dvape") & ("`survey'"=="com" | `yr'==1) continue

                if inlist("`var'","smoke","fsmoke","dsmoke") & `yr'==5 continue
                // only need fvape and fsmoke figures
                if !inlist("`var'","fvape","fsmoke") continue
            }
            // estread
            if 1 {
                estread *sty`yr'_*`var'_?_`subsample'    using "log/estimates/eventstudy_v42.sters"
                estread es*y`yr's_m?_*`var'_`subsample'1 using "log/estimates/stacked_did_cont_es"   
            }
        foreach config of numlist 8 { // aggregate configurations
            // skip pattern
            {
                if inlist("`var'","vape","fvape","dvape")    & inlist(`config',7)   continue
                *if inlist("`var'","smoke","fsmoke","dsmoke") & inlist(`config',5,6) continue
            }

            // add convergence label
            {
                forval model = 1/3 {
                    estimates restore es_sty`yr'_`var'_`model'_`subsample'
                    scalar converge_pre = e(converge)

                    estimates restore esd_sty`yr'_`var'_`model'_`subsample'
                    
                    matrix B = J(1,5,.)
                    forval b = 1/5 {
                        matrix B[1,`b'] = converge_pre
                    }
                    estadd matrix B
                }
            }

            // config-specific: name estimates
            {
                // ENDS use configurations:
                /*
                if `config'==1 { // 6 estimators
                    scalar spacing = 0.10

                    local f_estlist ///
                    (esc_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) ///
                    (esc_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) ///
                    (escy`yr's_m1_`var'_`subsample'1 , msymbol(D)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) ///
                    (esod_sty`yr'_`var'_1_`subsample', msymbol(Th) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esody`yr's_m3_`var'_`subsample'1, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))
                
                    local f_legend ///
                    legend( ///
                    lab(2  "Constrained OLS TWFE baseline") ///
                    lab(4  "Constrained OLS TWFE full") ///
                    lab(6  "Constrained OLS stacked baseline") ///
                    lab(8  "Delta OLS TWFE baseline") ///
                    lab(10 "Delta OLS TWFE full") ///
                    lab(12 "Delta OLS stacked full") ///
                    size(medium) colfirst row(3))
                }
                if `config'==2 { // include all 12 possible estimates, add 4 additional logit estimates (delta logit TWFE m1/3, delta logit stacked m1/3) and previously missing (cnsreg stacked full)
                    scalar spacing = 0.060

                    local f_estlist ///
                    (esod_sty`yr'_`var'_1_`subsample', msymbol(t) offset(`=( spacing / 2) - (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) /// TWFE, BC
                    (esod_sty`yr'_`var'_3_`subsample', msymbol(T) offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) /// TWFE, LASSO
                    (esd_sty`yr'_`var'_1_`subsample' , msymbol(o) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) /// Logit, BC
                    (esd_sty`yr'_`var'_3_`subsample' , msymbol(O) offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) /// Logit, LASSO
                    (esc_sty`yr'_`var'_1_`subsample' , msymbol(v) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) /// Constrained, BC
                    (esc_sty`yr'_`var'_3_`subsample' , msymbol(V) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) /// Constrained, LASSO
                    (esody`yr's_m1_`var'_`subsample'1, msymbol(s) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) /// TWFE Stacked, BC
                    (esody`yr's_m3_`var'_`subsample'1, msymbol(S) offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) /// TWFE Stacked, LASSO
                    (esdy`yr's_m1_`var'_`subsample'1 , msymbol(d) offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) /// Logit Stacked, BC
                    (esdy`yr's_m3_`var'_`subsample'1 , msymbol(D) offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) /// Logit Stacked, LASSO
                    (escy`yr's_m1_`var'_`subsample'1 , msymbol(a) offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) /// Constrained Stacked, BC
                    (escy`yr's_m3_`var'_`subsample'1 , msymbol(A) offset(`=(-spacing / 2) + (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) //  Constrained Stacked, LASSO

                    local f_legend ///
                    legend( ///
                    lab(2  "TWFE, BC") ///
                    lab(4  "TWFE, LASSO") ///
                    lab(6  "Logit, BC") ///
                    lab(8  "Logit, LASSO") ///
                    lab(10 "Constrained, BC") ///
                    lab(12 "Constrained, LASSO") ///
                    lab(14 "TWFE Stacked, BC") ///
                    lab(16 "TWFE Stacked, LASSO") ///
                    lab(18 "Logit Stacked, BC") ///
                    lab(20 "Logit Stacked, LASSO") ///
                    lab(22 "Constrained Stacked, BC") ///
                    lab(24 "Constrained Stacked, LASSO") ///
                    size(medium) ///
                    order(2 4 14 16 6 8 18 20 10 12 22 24) ///
                    row(3))
                }
                if `config'==3 { // only include baseline logit
                    scalar spacing = 0.07

                    local f_estlist ///
                    (esc_sty`yr'_`var'_1_`subsample' , msymbol(o)  offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) ///
                    (esc_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) ///
                    (escy`yr's_m1_`var'_`subsample'1 , msymbol(D)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) ///
                    (esod_sty`yr'_`var'_1_`subsample', msymbol(t)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esody`yr's_m3_`var'_`subsample'1, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esd_sty`yr'_`var'_1_`subsample' , msymbol(th) offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esdy`yr's_m1_`var'_`subsample'1 , msymbol(sh) offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///

                    local f_legend ///
                    legend( ///
                    lab(2  "Constrained OLS TWFE baseline") ///
                    lab(4  "Constrained OLS TWFE full") ///
                    lab(6  "Constrained OLS stacked baseline") ///
                    lab(8  "Delta OLS TWFE baseline") ///
                    lab(10 "Delta OLS TWFE full") ///
                    lab(12 "Delta OLS stacked full") ///
                    lab(14 "Delta logit TWFE baseline") ///
                    lab(16 "Delta logit stacked baseline") ///
                    size(medium) colfirst row(4))
                }
                if `config'==4 { // only include full logit
                    scalar spacing = 0.07

                    local f_estlist ///
                    (esc_sty`yr'_`var'_1_`subsample' , msymbol(o)  offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) ///
                    (esc_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) ///
                    (escy`yr's_m1_`var'_`subsample'1 , msymbol(D)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) ///
                    (esod_sty`yr'_`var'_1_`subsample', msymbol(t)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esody`yr's_m3_`var'_`subsample'1, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esd_sty`yr'_`var'_3_`subsample' , msymbol(th) offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esdy`yr's_m3_`var'_`subsample'1 , msymbol(sh) offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///

                    local f_legend ///
                    legend( ///
                    lab(2  "Constrained OLS TWFE baseline") ///
                    lab(4  "Constrained OLS TWFE full") ///
                    lab(6  "Constrained OLS stacked baseline") ///
                    lab(8  "Delta OLS TWFE baseline") ///
                    lab(10 "Delta OLS TWFE full") ///
                    lab(12 "Delta OLS stacked full") ///
                    lab(14 "Delta logit TWFE full") ///
                    lab(16 "Delta logit stacked full") ///
                    size(medium) colfirst row(4))
                }
                */
                if `config'==5 { // all 12 estimates, different ordering and legend at bottom
                    scalar spacing = 0.060

                    local f_estlist ///
                    (esod_sty`yr'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                     /// TWFE, BC
                    (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                     /// TWFE, LASSO
                    (esc_sty`yr'_`var'_1_`subsample' , msymbol(A)  offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends))    /// Constrained, BC
                    (esc_sty`yr'_`var'_3_`subsample' , msymbol(V)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends))    /// Constrained, LASSO
                    (esd_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge')                        /// Logit, BC
                    (esd_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge')                        /// Logit, LASSO
                    (esody`yr's_m1_`var'_`subsample'1, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                     /// TWFE Stacked, BC
                    (esody`yr's_m3_`var'_`subsample'1, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                     /// TWFE Stacked, LASSO
                    (escy`yr's_m1_`var'_`subsample'1 , msymbol(X)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) /// Constrained Stacked, BC
                    (escy`yr's_m3_`var'_`subsample'1 , msymbol(+)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) /// Constrained Stacked, LASSO
                    (esdy`yr's_m1_`var'_`subsample'1 , msymbol(Dh) offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge')                        /// Logit Stacked, BC
                    (esdy`yr's_m3_`var'_`subsample'1 , msymbol(D)  offset(`=(-spacing / 2) + (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge')                         // Logit Stacked, LASSO
                    
                    local f_legend ///
                    legend( ///
                    lab(2  "TWFE, BC") ///
                    lab(4  "TWFE, LASSO") ///
                    lab(6  "Constrained, BC") ///
                    lab(8  "Constrained, LASSO") ///
                    lab(10 "Logit, BC") ///
                    lab(12 "Logit, LASSO") ///
                    lab(14 "TWFE Stacked, BC") ///
                    lab(16 "TWFE Stacked, LASSO") ///
                    lab(18 "Constrained Stacked, BC") ///
                    lab(20 "Constrained Stacked, LASSO") ///
                    lab(22 "Logit Stacked, BC") ///
                    lab(24 "Logit Stacked, LASSO") ///
                    size(medium) ///
                    order(2 4 14 16 6 8 18 20 10 12 22 24) ///
                    row(3))

                    if "`subsample'"=="id_ht" & "`var'"=="fsmoke" { // remove logit stacked BC and logit stacked LASSO due to non-convergence
                    local f_estlist ///
                    (esod_sty`yr'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                     /// TWFE, BC
                    (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                     /// TWFE, LASSO
                    (esc_sty`yr'_`var'_1_`subsample' , msymbol(A)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends))    /// Constrained, BC
                    (esc_sty`yr'_`var'_3_`subsample' , msymbol(V)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends))    /// Constrained, LASSO
                    (esd_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge')                        /// Logit, BC
                    (esd_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge')                        /// Logit, LASSO
                    (esody`yr's_m1_`var'_`subsample'1, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                     /// TWFE Stacked, BC
                    (esody`yr's_m3_`var'_`subsample'1, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                     /// TWFE Stacked, LASSO
                    (escy`yr's_m1_`var'_`subsample'1 , msymbol(X)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) /// Constrained Stacked, BC
                    (escy`yr's_m3_`var'_`subsample'1 , msymbol(+)  offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends))  // Constrained Stacked, LASSO
                    
                    local f_legend ///
                    legend( ///
                    lab(2  "TWFE, BC") ///
                    lab(4  "TWFE, LASSO") ///
                    lab(6  "Constrained, BC") ///
                    lab(8  "Constrained, LASSO") ///
                    lab(10 "Logit, BC") ///
                    lab(12 "Logit, LASSO") ///
                    lab(14 "TWFE Stacked, BC") ///
                    lab(16 "TWFE Stacked, LASSO") ///
                    lab(18 "Constrained Stacked, BC") ///
                    lab(20 "Constrained Stacked, LASSO") ///
                    size(medium) ///
                    order(2 4 14 16 6 8 18 20 10 12) ///
                    row(3))
                    }
                    
                }
                /*
                if `config'==6 { // all 12 estimates, again different ordering
                    scalar spacing = 0.060

                    local f_estlist ///
                    (esod_sty`yr'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))              /// TWFE, BC
                    (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))              /// TWFE, LASSO
                    (esody`yr's_m1_`var'_`subsample'1, msymbol(Sh) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))              /// TWFE Stacked, BC
                    (esody`yr's_m3_`var'_`subsample'1, msymbol(S)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))              /// TWFE Stacked, LASSO
                    (esd_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') /// Logit, BC
                    (esd_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') /// Logit, LASSO
                    (esdy`yr's_m1_`var'_`subsample'1 , msymbol(Dh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') /// Logit Stacked, BC
                    (esdy`yr's_m3_`var'_`subsample'1 , msymbol(D)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') /// Logit Stacked, LASSO
                    (esc_sty`yr'_`var'_1_`subsample' , msymbol(A)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) /// Constrained, BC
                    (esc_sty`yr'_`var'_3_`subsample' , msymbol(V)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) /// Constrained, LASSO
                    (escy`yr's_m1_`var'_`subsample'1 , msymbol(X)  offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) /// Constrained Stacked, BC
                    (escy`yr's_m3_`var'_`subsample'1 , msymbol(+)  offset(`=(-spacing / 2) + (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_ends semleadyr_2_ends semleadyr_1_og_ends semlagyr_0_ends semlagyr_1_ends)) //  Constrained Stacked, LASSO
                    
                    local f_legend ///
                    legend( ///
                    lab(2 "TWFE, BC") ///
                    lab(4 "TWFE, LASSO") ///
                    lab(6 "TWFE Stacked, BC") ///
                    lab(8 "TWFE Stacked, LASSO") ///
                    lab(10 "Logit, BC") ///
                    lab(12 "Logit, LASSO") ///
                    lab(14 "Logit Stacked, BC") ///
                    lab(16 "Logit Stacked, LASSO") ///
                    lab(18 "Constrained, BC") ///
                    lab(20 "Constrained, LASSO") ///                 
                    lab(22 "Constrained Stacked, BC") ///
                    lab(24 "Constrained Stacked, LASSO") ///
                    size(medium) row(3))
                }
                // cigarette smoking configurations:
                if `config'==7 { // OLS TWFE, logit TWFE, cnsreg TWFE 
                    scalar spacing = 0.10

                    local f_estlist ///
                    (esod_`survey'y`yr'_`var'_1_`sname', msymbol(Dh) offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esod_`survey'y`yr'_`var'_3_`sname', msymbol(D)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esd_`survey'y`yr'_`var'_1_`sname' , msymbol(Th) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esd_`survey'y`yr'_`var'_3_`sname' , msymbol(T)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                    (esc_`survey'y`yr'_`var'_1_`sname' , msymbol(Oh) offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) ///
                    (esc_`survey'y`yr'_`var'_3_`sname' , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) 
                    
                    local f_legend ///
                    legend( ///
                    lab(2  "TWFE, BC") ///
                    lab(4  "TWFE, LASSO") ///
                    lab(6  "Logit, BC") ///
                    lab(8  "Logit, LASSO") ///
                    lab(10 "Constrained, BC") ///
                    lab(12 "Constrained, LASSO") ///
                    size(medium) colfirst row(2))
                }
                */
                if `config'==8 { // 8 estimates; only OLS stacked (no logit stacked or constrained stacked)
                    scalar spacing = 0.07

                    local f_estlist ///
                    (esod_sty`yr'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                  /// TWFE, BC
                    (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                  /// TWFE, LASSO
                    (esc_sty`yr'_`var'_1_`subsample' , msymbol(A)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) /// Constrained, BC
                    (esc_sty`yr'_`var'_3_`subsample' , msymbol(V)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(s2wF3_ends s2wF2_ends s2wF1_ends_og s2wL0_ends s2wL1_ends)) /// Constrained, LASSO
                    (esd_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge')                     /// Logit, BC
                    (esd_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge')                     /// Logit, LASSO
                    (esody`yr's_m1_`var'_`subsample'1, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                  /// TWFE Stacked, BC
                    (esody`yr's_m3_`var'_`subsample'1, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))                                   // TWFE Stacked, LASSO
                    
                    local f_legend ///
                    legend( ///
                    lab(2  "TWFE, BC") ///
                    lab(4  "TWFE, LASSO") ///
                    lab(6  "Constrained, BC") ///
                    lab(8  "Constrained, LASSO") ///
                    lab(10 "Logit, BC") ///
                    lab(12 "Logit, LASSO") ///
                    lab(14 "TWFE Stacked, BC") ///
                    lab(16 "TWFE Stacked, LASSO") ///
                    size(medium) colfirst row(2))
                }
            }

            // post-estimation delta method
            {
                forval model = 1(2)3 {
                    if inlist(`config',1,2,3,4,5,6,8) { // vaping configurations
                        // delta, OLS twfe, model 1/3
                        estimates restore eso_sty`yr'_`var'_`model'_`subsample'

                        xlincom ///
                        ((_b[s2wF3_ends] + _b[s2wF2_ends] + _b[s2wF1_ends]) / 3) /// -5+   lead
                        (                 (_b[s2wF2_ends] + _b[s2wF1_ends]) / 2) /// -4,-3 lead
                        (                                  (_b[s2wF1_ends]) / 1) /// -2,-1 lead
                        ((_b[s2wL0_ends])                                   / 1) ///  0,1  lag   
                        ((_b[s2wL0_ends] + _b[s2wL1_ends])                  / 2) ///  2+  lag
                        , post level(95)
                        _eststo esod_sty`yr'_`var'_`model'_`subsample'

                        // delta, OLS stacked DD, model 1/3
                        estimates restore esoy`yr's_m`model'_`var'_`subsample'1

                        xlincom ///
                        ((_b[semleadyr_3_ends] + _b[semleadyr_2_ends] + _b[semleadyr_1_ends]) / 3) /// -6,-5 lead
                        (                       (_b[semleadyr_2_ends] + _b[semleadyr_1_ends]) / 2) /// -4,-3 lead
                        (                                              (_b[semleadyr_1_ends]) / 1) /// -2,-1 lead
                        ((_b[semlagyr_0_ends])                                                / 1) ///  0,1  lag   
                        ((_b[semlagyr_0_ends]  + _b[semlagyr_1_ends])                         / 2) ///  2,3  lag
                        , post level(95)
                        _eststo esody`yr's_m`model'_`var'_`subsample'1
                        
                        // delta, logit stacked DD, model 1/3
                        estimates restore esy`yr's_m`model'_`var'_`subsample'1

                        scalar converge_pre = e(converge)

                        xlincom ///
                        ((_b[semleadyr_3_ends] + _b[semleadyr_2_ends] + _b[semleadyr_1_ends]) / 3) /// -6,-5 lead
                        (                       (_b[semleadyr_2_ends] + _b[semleadyr_1_ends]) / 2) /// -4,-3 lead
                        (                                              (_b[semleadyr_1_ends]) / 1) /// -2,-1 lead
                        ((_b[semlagyr_0_ends])                                                / 1) ///  0,1  lag   
                        ((_b[semlagyr_0_ends]  + _b[semlagyr_1_ends])                         / 2) ///  2,3  lag
                        , post level(95)
                        _eststo esdy`yr's_m`model'_`var'_`subsample'1
                        matrix B = J(1,5,.)
                        forval b = 1/5 {
                            matrix B[1,`b'] = converge_pre
                        }
                        estadd matrix B
                    }
                    /*
                    if inlist(`config',7) { // cigarette smoking configurations
                        // delta, OLS twfe, model 1/3
                        estimates restore eso_`survey'y`yr'_`var'_`model'_`sname'

                        xlincom ///
                        ((_b[s2wF3_ends] + _b[s2wF2_ends] + _b[s2wF1_ends]) / 3) /// -5+   lead
                        (                 (_b[s2wF2_ends] + _b[s2wF1_ends]) / 2) /// -4,-3 lead
                        (                                  (_b[s2wF1_ends]) / 1) /// -2,-1 lead
                        ((_b[s2wL0_ends])                                   / 1) ///  0,1  lag   
                        ((_b[s2wL0_ends] + _b[s2wL1_ends])                  / 2) ///  2+  lag
                        , post level(95)
                        _eststo esod_`survey'y`yr'_`var'_`model'_`sname'
                    }
                    */
                }
            }

            // parameters
            {
                // y-axis
                if "`var'"=="vape"   local f_ysca yla(-0.120(0.040)0.120, nogrid)
                if "`var'"=="fvape"  local f_ysca yla(-0.075(0.025)0.075, nogrid)
                if "`subsample'"=="id_ht"  & "`var'"=="fsmoke" local f_ysca yla(-0.030(0.010)0.030, nogrid)
                if "`subsample'"=="id_nh1" & "`var'"=="fsmoke" local f_ysca yla(-0.075(0.025)0.075, nogrid)
            }

            forval legend_iter = 0/1 {
                
                // legend_iter-specific
                {
                    if `legend_iter'==0 {
                        local name_leg
                        local f_legend_di `f_legend'
                        local f_dimen ysize(2.18) xsize(7)
                    }
                    if `legend_iter'==1 {
                        local name_leg _1
                        local f_legend_di legend(off)
                        local f_dimen ysize(2.18) xsize(4.6)
                    }

                    // WANT LEGEND TO HAVE ASPECT RATIO (0.46 x 6.38)
                }

                // plotting 
                coefplot ///
                `f_estlist' ///
                , ///
                rename( ///
                s2wF3_ends = lead_3 s2wF2_ends = lead_2 s2wF1_ends_og = lead_1 s2wL0_ends = lag_0 s2wL1_ends = lag_1 ///
                semleadyr_3_ends = lead_3 semleadyr_2_ends = lead_2 semleadyr_1_og_ends = lead_1 semlagyr_0_ends = lag_0 semlagyr_1_ends = lag_1 ///
                lc_1 = lead_3 lc_2 = lead_2 lc_3 = lead_1 lc_4 = lag_0 lc_5 = lag_1 ///
                ) ///
                omitted ///
                vertical ///
                graphregion(color(white)) ///
                ytitle("Estimated Effect of ENDS Tax", size(medium) xoffset(-1)) ///
                yline(0, lcolor(black)) `f_ysca' ylabel(, labsize(medium)) ///
                xtitle("Years Before/After ENDS Tax Increase", size(medium) yoffset(-1)) ///
                xline(3.5, lpattern(dash) lcolor(black)) ///
                xlabel(1 "{&le} -5" 2 "-4,-3" 3 "-2,1" 4 "0,1" 5 "{&ge} 2", labsize(medium)) ///
                msize(medium) ///
                `f_dimen' ///
                `f_legend_di' ///
                ciopts(recast(rcap))

                graph export "output/etax/graphs/final/es_agg_v`config'`name_leg'_`var'_`subsample'_`survey'_y`yr'.png", replace
                graph close
            }
        }
            if inlist("`var'","dvape","dsmoke") estimates clear
        }
        }
        }
        }

        // non-convergent estimates
        {
            /*
            st, 5, id_ht, fsmoke, logit stacked BC
            st, 5, id_ht, fsmoke, logit stacked LASSO
            */
        }
    }

    // flavor ban/mlsa/cigtax, state yrbs
    if 1 {
        *local f_converge mlabel(@aux1) aux(B[1,]) mlabgap(*2) mlabposition(12)
        
        eststo clear
        estimates clear

        foreach ind_var in flav mlsa cigtax { // flavor bans, MLSA, cigtax
            // ind_var-specific
            {
                if "`ind_var'"=="flav"   local num_stack 3
                if "`ind_var'"=="mlsa"   local num_stack 2
                if "`ind_var'"=="cigtax" local num_stack
            }
        foreach yr in 5 1 {
        foreach var in fvape fsmoke {
            // skip pattern
            {
                if `yr'==1 & "`var'"=="fvape" continue
                if `yr'==5 & "`var'"=="fsmoke" continue
            }

            // estread
            if 1 {
                // flavor ban
                if "`ind_var'"=="flav" {
                    forval model = 1/3 {
                    estread *`var'*_?l4l_* using "log/estimates/other_pol_v20_y`yr'3st`model'l" // logit
                    estread *`var'*_?4l_*  using "log/estimates/other_pol_v20_y`yr'3st`model'"  // ols
                    estread *`var'*_?c4l_* using "log/estimates/other_pol_v20_y`yr'3st`model'c" // cnsreg
                    }

                    estread es*_*3 using "log/estimates/stacked_did_cont_es"	
                }
                // mlsa
                if "`ind_var'"=="mlsa" {
                    estread *sty`yr'*`var'* using "log/estimates/eventstudy_mlsa_v42.sters"
                    estread es*`var'*_*2 using "log/estimates/stacked_did_cont_es"
                }
                // cig taxes
                if "`ind_var'"=="cigtax" {
                    estread *sty`yr'*`var'* using "log/estimates/eventstudy_cigtax_v42.sters"
                    estread es*`var'*    using "log/estimates/stacked_did_prom_es_cigs_0_50" // $0.50 nominal as prominent cig tax increase
                }
            }
        foreach subsample in id_ht id_nh1 {
            // post-estimation delta method
            {
                forval model = 1(2)3 {
                    if "`ind_var'"=="flav" { // flavor ban:
                        // delta, OLS twfe, model 1/3
                        estimates restore `var'_`model'4l_`subsample'y`yr'3_st

                        xlincom ///
                        ((_b[flav_lead5_plus] + _b[flav_lead4_3] + _b[flav_lead2_1]) / 3) /// -5+   lead
                        (                      (_b[flav_lead4_3] + _b[flav_lead2_1]) / 2) /// -4,-3 lead
                        (                                         (_b[flav_lead2_1]) / 1) /// -2,-1 lead
                        ((_b[flav_lag0_1])                                           / 1) ///  0,1  lag   
                        ((_b[flav_lag0_1] + _b[flav_lag2_plus])                      / 2) ///  2+  lag
                        , post level(95)
                        _eststo `var'_`model'od4l_`subsample'y`yr'3_st

                        // delta, logit twfe, model 1/3
                        estimates restore `var'_`model'l4l_`subsample'y`yr'3_st

                        scalar converge_pre = e(converge)

                        xlincom ///
                        ((_b[flav_lead5_plus] + _b[flav_lead4_3] + _b[flav_lead2_1]) / 3) /// -5+   lead
                        (                      (_b[flav_lead4_3] + _b[flav_lead2_1]) / 2) /// -4,-3 lead
                        (                                         (_b[flav_lead2_1]) / 1) /// -2,-1 lead
                        ((_b[flav_lag0_1])                                           / 1) ///  0,1  lag   
                        ((_b[flav_lag0_1] + _b[flav_lag2_plus])                      / 2) ///  2+  lag
                        , post level(95)
                        _eststo `var'_`model'd4l_`subsample'y`yr'3_st
                        matrix B = J(1,5,.)
                        forval b = 1/5 {
                            matrix B[1,`b'] = converge_pre
                        }
                        estadd matrix B

                        // delta, OLS stacked, model 1/3
                        estimates restore esoy`yr's_m`model'_`var'_`subsample'3

                        xlincom ///
                        ((_b[semleadyr_3_flav] + _b[semleadyr_2_flav] + _b[semleadyr_1_flav]) / 3) /// -5+   lead
                        (                       (_b[semleadyr_2_flav] + _b[semleadyr_1_flav]) / 2) /// -4,-3 lead
                        (                                              (_b[semleadyr_1_flav]) / 1) /// -2,-1 lead
                        ((_b[semlagyr_0_flav])                                                / 1) ///  0,1  lag   
                        ((_b[semlagyr_0_flav] + _b[semlagyr_1_flav])                          / 2) ///  2+  lag
                        , post level(95)
                        _eststo esody`yr's_m`model'_`var'_`subsample'3
                    }
                    if inlist("`ind_var'","mlsa","cigtax") { // ENDS MLSA, cigarette taxes
                        // delta, OLS twfe, model 1/3
                        estimates restore eso_sty`yr'_`var'_`model'_`subsample'

                        if "`ind_var'"=="mlsa"   local name_ind_var any_mlsa_vape
                        if "`ind_var'"=="cigtax" local name_ind_var cigarette_tax_scale

                        xlincom ///
                        ((_b[`name_ind_var'_s2w_F3] + _b[`name_ind_var'_s2w_F2] + _b[`name_ind_var'_s2w_F1]) / 3) /// -5+   lead
                        (                            (_b[`name_ind_var'_s2w_F2] + _b[`name_ind_var'_s2w_F1]) / 2) /// -4,-3 lead
                        (                                                        (_b[`name_ind_var'_s2w_F1]) / 1) /// -2,-1 lead
                        ((_b[`name_ind_var'_s2w_L0])                                                         / 1) ///  0,1  lag   
                        ((_b[`name_ind_var'_s2w_L0] + _b[`name_ind_var'_s2w_L1])                             / 2) ///  2+  lag
                        , post level(95)
                        _eststo esod_sty`yr'_`var'_`model'_`subsample'

                        if "`ind_var'"=="mlsa" { // delta, OLS stacked, model 1/3
                            estimates restore esoy`yr's_m`model'_`var'_`subsample'2

                            xlincom ///
                            ((_b[semleadyr_3_mlsa] + _b[semleadyr_2_mlsa] + _b[semleadyr_1_mlsa]) / 3) /// -5+   lead
                            (                       (_b[semleadyr_2_mlsa] + _b[semleadyr_1_mlsa]) / 2) /// -4,-3 lead
                            (                                              (_b[semleadyr_1_mlsa]) / 1) /// -2,-1 lead
                            ((_b[semlagyr_0_mlsa])                                                / 1) ///  0,1  lag   
                            ((_b[semlagyr_0_mlsa] + _b[semlagyr_1_mlsa])                          / 2) ///  2+  lag
                            , post level(95)
                            _eststo esody`yr's_m`model'_`var'_`subsample'2
                        }
                    }
                }
            }

            // add convergence label
            {
                forval model = 1(2)3 {
                    // 
                    if inlist("`ind_var'","mlsa","cigtax") { // MLSA regular logit; cigtax regular logit
                        estimates restore es_sty`yr'_`var'_`model'_`subsample'
                        scalar converge_pre = e(converge)

                        estimates restore esd_sty`yr'_`var'_`model'_`subsample'

                        matrix B = J(1,5,.)
                        forval b = 1/5 {
                            matrix B[1,`b'] = converge_pre
                        }
                        estadd matrix B
                    }
                    if inlist("`ind_var'","flav","mlsa") { // flavor ban stacked logit; MLSA stacked logit;
                        estimates restore esy`yr's_m`model'_`var'_`subsample'`num_stack'
                        scalar converge_pre = e(converge)

                        estimates restore esdy`yr's_m`model'_`var'_`subsample'`num_stack'

                        matrix B = J(1,5,.)
                        forval b = 1/5 {
                            matrix B[1,`b'] = converge_pre
                        }
                        estadd matrix B
                    }
                }
            }
        foreach config of numlist 4 {
            // config-specific: name estimates
            {
                /*
                if `config'==1 { // 6 estimates: OLS TWFE, logit TWFE, constrained OLS TWFE (baseline/full controls)
                    if "`ind_var'"=="flav" { // flavor ban
                        scalar spacing = 0.10

                        local f_estlist ///
                        (`var'_1od4l_`subsample'y`yr'3_st, msymbol(Dh) offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_3od4l_`subsample'y`yr'3_st, msymbol(D)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_1d4l_`subsample'y`yr'3_st , msymbol(Th) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_3d4l_`subsample'y`yr'3_st , msymbol(T)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_1c4l_`subsample'y`yr'3_st , msymbol(Oh) offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) ///
                        (`var'_3c4l_`subsample'y`yr'3_st , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) 
                    
                        local f_legend ///
                        legend( ///
                        lab(2  "TWFE, BC") ///
                        lab(4  "TWFE, LASSO") ///
                        lab(6  "Logit, BC") ///
                        lab(8  "Logit, LASSO") ///
                        lab(10 "Constrained, BC") ///
                        lab(12 "Constrained, LASSO") ///
                        size(medium) colfirst row(2))
                    }
                    if inlist("`ind_var'","mlsa","cigtax") { // ENDS MLSA, cigarette taxes ($2023)

                        if "`ind_var'"=="mlsa"   local name_ind_var any_mlsa_vape
                        if "`ind_var'"=="cigtax" local name_ind_var cigarette_tax_scale

                        scalar spacing = 0.10

                        local f_estlist ///
                        (esod_sty`yr'_`var'_1_`subsample', msymbol(Dh) offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esod_sty`yr'_`var'_3_`subsample', msymbol(D)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esd_sty`yr'_`var'_1_`subsample' , msymbol(Th) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esd_sty`yr'_`var'_3_`subsample' , msymbol(T)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esc_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(`name_ind_var'_s2w_F3 `name_ind_var'_s2w_F2 `name_ind_var'_s2w_F1_og `name_ind_var'_s2w_L0 `name_ind_var'_s2w_L1)) ///
                        (esc_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(`name_ind_var'_s2w_F3 `name_ind_var'_s2w_F2 `name_ind_var'_s2w_F1_og `name_ind_var'_s2w_L0 `name_ind_var'_s2w_L1)) 
                        
                        local f_legend ///
                        legend( ///
                        lab(2  "TWFE, BC") ///
                        lab(4  "TWFE, LASSO") ///
                        lab(6  "Logit, BC") ///
                        lab(8  "Logit, LASSO") ///
                        lab(10 "Constrained, BC") ///
                        lab(12 "Constrained, LASSO") ///
                        size(medium) colfirst row(2))
                    }
                }
                if `config'==2 { // 12 estimates: OLS TWFE, logit TWFE, constrained OLS TWFE, OLS stacked, logit stacked, constrained OLS stacked (baseline/full controls)
                    if "`ind_var'"=="flav" { // flavor ban
                        scalar spacing = 0.06

                        local f_estlist ///
                        (`var'_1od4l_`subsample'y`yr'3_st, msymbol(Th) offset(`=( spacing / 2) - (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_3od4l_`subsample'y`yr'3_st, msymbol(T)  offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m1_`var'_`subsample'3, msymbol(Sh) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m3_`var'_`subsample'3, msymbol(S)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_1d4l_`subsample'y`yr'3_st , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (`var'_3d4l_`subsample'y`yr'3_st , msymbol(O)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esdy`yr's_m1_`var'_`subsample'3 , msymbol(Dh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esdy`yr's_m3_`var'_`subsample'3 , msymbol(D)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (`var'_1c4l_`subsample'y`yr'3_st , msymbol(A)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) ///
                        (`var'_3c4l_`subsample'y`yr'3_st , msymbol(V)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) ///
                        (escy`yr's_m1_`var'_`subsample'3 , msymbol(X)  offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_flav semleadyr_2_flav semleadyr_1_og_flav semlagyr_0_flav semlagyr_1_flav)) ///
                        (escy`yr's_m3_`var'_`subsample'3 , msymbol(+)  offset(`=(-spacing / 2) + (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_flav semleadyr_2_flav semleadyr_1_og_flav semlagyr_0_flav semlagyr_1_flav)) 
                    
                        local f_legend ///
                        legend( ///
                        lab(2 "OLS, BC") ///
                        lab(4 "OLS, LASSO") ///
                        lab(6 "OLS Stacked, BC") ///
                        lab(8 "OLS Stacked, LASSO") ///
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "Logit Stacked, BC") ///
                        lab(16 "Logit Stacked, LASSO") ///
                        lab(18 "Constrained, BC") ///
                        lab(20 "Constrained, LASSO") ///                 
                        lab(22 "Constrained Stacked, BC") ///
                        lab(24 "Constrained Stacked, LASSO") ///
                        size(medium) row(3))
                    }
                    if inlist("`ind_var'","mlsa") { // ENDS MLSA
                        scalar spacing = 0.06

                        local f_estlist ///
                        (esod_sty`yr'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m1_`var'_`subsample'2, msymbol(Sh) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m3_`var'_`subsample'2, msymbol(S)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esd_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esd_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esdy`yr's_m1_`var'_`subsample'2 , msymbol(Dh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esdy`yr's_m3_`var'_`subsample'2 , msymbol(D)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esc_sty`yr'_`var'_1_`subsample' , msymbol(A)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1)) ///
                        (esc_sty`yr'_`var'_3_`subsample' , msymbol(V)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1)) ///
                        (escy`yr's_m1_`var'_`subsample'2 , msymbol(X)  offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_mlsa semleadyr_2_mlsa semleadyr_1_og_mlsa semlagyr_0_mlsa semlagyr_1_mlsa)) ///
                        (escy`yr's_m3_`var'_`subsample'2 , msymbol(+)  offset(`=(-spacing / 2) + (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_mlsa semleadyr_2_mlsa semleadyr_1_og_mlsa semlagyr_0_mlsa semlagyr_1_mlsa))

                        local f_legend ///
                        legend( ///
                        lab(2 "OLS, BC") ///
                        lab(4 "OLS, LASSO") ///
                        lab(6 "OLS Stacked, BC") ///
                        lab(8 "OLS Stacked, LASSO") ///
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "Logit Stacked, BC") ///
                        lab(16 "Logit Stacked, LASSO") ///
                        lab(18 "Constrained, BC") ///
                        lab(20 "Constrained, LASSO") ///                 
                        lab(22 "Constrained Stacked, BC") ///
                        lab(24 "Constrained Stacked, LASSO") ///
                        size(medium) row(3))
                    }
                    if inlist("`ind_var'","cigtax") { // cigarette taxes ($2023) - (no logit stacked DD nor constrained stacked DD event studies)
                        // using $0.50 nominal increases for prominent stacked DD
                        scalar spacing = 0.07

                        local f_estlist ///
                        (esod_sty`yr'_`var'_1_`subsample'  , msymbol(Th) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esod_sty`yr'_`var'_3_`subsample'  , msymbol(T)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esdl3_50_y`yr'`subsample'_`var'_m1, msymbol(Sh) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esdl3_50_y`yr'`subsample'_`var'_m3, msymbol(S)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esd_sty`yr'_`var'_1_`subsample'   , msymbol(Oh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esd_sty`yr'_`var'_3_`subsample'   , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esc_sty`yr'_`var'_1_`subsample'   , msymbol(Dh) offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(cigarette_tax_scale_s2w_F3 cigarette_tax_scale_s2w_F2 cigarette_tax_scale_s2w_F1_og cigarette_tax_scale_s2w_L0 cigarette_tax_scale_s2w_L1)) ///
                        (esc_sty`yr'_`var'_3_`subsample'   , msymbol(D)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(cigarette_tax_scale_s2w_F3 cigarette_tax_scale_s2w_F2 cigarette_tax_scale_s2w_F1_og cigarette_tax_scale_s2w_L0 cigarette_tax_scale_s2w_L1)) 
                    
                        local f_legend ///
                        legend( ///
                        lab(2 "OLS, BC") ///
                        lab(4 "OLS, LASSO") ///
                        lab(6 "OLS Stacked, BC") ///
                        lab(8 "OLS Stacked, LASSO") ///
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "Constrained, BC") ///
                        lab(16 "Constrained, LASSO") ///                 
                        size(medium) row(3))
                    }
                }
                */
                if `config'==3 { // 12 estimates (different presentation order)
                    if "`ind_var'"=="flav" { // flavor ban
                        scalar spacing = 0.06
                        /*
                        local f_estlist ///
                        (`var'_1od4l_`subsample'y`yr'3_st, msymbol(Th) offset(`=( spacing / 2) - (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_3od4l_`subsample'y`yr'3_st, msymbol(T)  offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_1c4l_`subsample'y`yr'3_st , msymbol(A)  offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) ///
                        (`var'_3c4l_`subsample'y`yr'3_st , msymbol(V)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) ///
                        (`var'_1d4l_`subsample'y`yr'3_st , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (`var'_3d4l_`subsample'y`yr'3_st , msymbol(O)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esody`yr's_m1_`var'_`subsample'3, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m3_`var'_`subsample'3, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (escy`yr's_m1_`var'_`subsample'3 , msymbol(X)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_flav semleadyr_2_flav semleadyr_1_og_flav semlagyr_0_flav semlagyr_1_flav)) ///
                        (escy`yr's_m3_`var'_`subsample'3 , msymbol(+)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_flav semleadyr_2_flav semleadyr_1_og_flav semlagyr_0_flav semlagyr_1_flav)) ///
                        (esdy`yr's_m1_`var'_`subsample'3 , msymbol(Dh) offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esdy`yr's_m3_`var'_`subsample'3 , msymbol(D)  offset(`=(-spacing / 2) + (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') 
                    
                        local f_legend ///
                        legend( ///
                        lab(2  "TWFE, BC") ///
                        lab(4  "TWFE, LASSO") ///
                        lab(6  "Constrained, BC") ///
                        lab(8  "Constrained, LASSO") ///
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "TWFE Stacked, BC") ///
                        lab(16 "TWFE Stacked, LASSO") ///
                        lab(18 "Constrained Stacked, BC") ///
                        lab(20 "Constrained Stacked, LASSO") ///
                        lab(22 "Logit Stacked, BC") ///
                        lab(24 "Logit Stacked, LASSO") ///
                        size(medium) row(3))
                        */

                        // remove stacked constrained OLS
                        local f_estlist ///
                        (`var'_1od4l_`subsample'y`yr'3_st, msymbol(Th) offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_3od4l_`subsample'y`yr'3_st, msymbol(T)  offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_1c4l_`subsample'y`yr'3_st , msymbol(A)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) ///
                        (`var'_3c4l_`subsample'y`yr'3_st , msymbol(V)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) ///
                        (`var'_1d4l_`subsample'y`yr'3_st , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (`var'_3d4l_`subsample'y`yr'3_st , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esody`yr's_m1_`var'_`subsample'3, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m3_`var'_`subsample'3, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esdy`yr's_m1_`var'_`subsample'3 , msymbol(Dh) offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esdy`yr's_m3_`var'_`subsample'3 , msymbol(D)  offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') 
                    
                        local f_legend ///
                        legend( ///
                        lab(2  "TWFE, BC") ///
                        lab(4  "TWFE, LASSO") ///
                        lab(6  "Constrained, BC") ///
                        lab(8  "Constrained, LASSO") ///
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "TWFE Stacked, BC") ///
                        lab(16 "TWFE Stacked, LASSO") ///
                        lab(18 "Logit Stacked, BC") ///
                        lab(20 "Logit Stacked, LASSO") ///
                        size(medium) row(3) order(2 4 14 16 6 8 10 12 18 20))
                    }
                    if inlist("`ind_var'","mlsa") { // ENDS MLSA
                        scalar spacing = 0.06

                        /*
                        local f_estlist ///
                        (esod_sty`yr'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esc_sty`yr'_`var'_1_`subsample' , msymbol(A)  offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1)) ///
                        (esc_sty`yr'_`var'_3_`subsample' , msymbol(V)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1)) ///
                        (esd_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esd_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esody`yr's_m1_`var'_`subsample'2, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m3_`var'_`subsample'2, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (escy`yr's_m1_`var'_`subsample'2 , msymbol(X)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_mlsa semleadyr_2_mlsa semleadyr_1_og_mlsa semlagyr_0_mlsa semlagyr_1_mlsa)) ///
                        (escy`yr's_m3_`var'_`subsample'2 , msymbol(+)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_mlsa semleadyr_2_mlsa semleadyr_1_og_mlsa semlagyr_0_mlsa semlagyr_1_mlsa)) ///
                        (esdy`yr's_m1_`var'_`subsample'2 , msymbol(Dh) offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esdy`yr's_m3_`var'_`subsample'2 , msymbol(D)  offset(`=(-spacing / 2) + (spacing * 6)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') 

                        local f_legend ///
                        legend( ///
                        lab(2  "TWFE, BC") ///
                        lab(4  "TWFE, LASSO") ///
                        lab(6  "Constrained, BC") ///
                        lab(8  "Constrained, LASSO") ///
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "TWFE Stacked, BC") ///
                        lab(16 "TWFE Stacked, LASSO") ///
                        lab(18 "Constrained Stacked, BC") ///
                        lab(20 "Constrained Stacked, LASSO") ///
                        lab(22 "Logit Stacked, BC") ///
                        lab(24 "Logit Stacked, LASSO") ///
                        size(medium) row(3))
                        */

                        // remove logit stacked
                        local f_estlist ///
                        (esod_sty`yr'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esc_sty`yr'_`var'_1_`subsample' , msymbol(A)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1)) ///
                        (esc_sty`yr'_`var'_3_`subsample' , msymbol(V)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1)) ///
                        (esd_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esd_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esody`yr's_m1_`var'_`subsample'2, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m3_`var'_`subsample'2, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (escy`yr's_m1_`var'_`subsample'2 , msymbol(X)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_mlsa semleadyr_2_mlsa semleadyr_1_og_mlsa semlagyr_0_mlsa semlagyr_1_mlsa)) ///
                        (escy`yr's_m3_`var'_`subsample'2 , msymbol(+)  offset(`=(-spacing / 2) + (spacing * 5)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(semleadyr_3_mlsa semleadyr_2_mlsa semleadyr_1_og_mlsa semlagyr_0_mlsa semlagyr_1_mlsa))

                        local f_legend ///
                        legend( ///
                        lab(2  "TWFE, BC") ///
                        lab(4  "TWFE, LASSO") ///
                        lab(6  "Constrained, BC") ///
                        lab(8  "Constrained, LASSO") ///
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "TWFE Stacked, BC") ///
                        lab(16 "TWFE Stacked, LASSO") ///
                        lab(18 "Constrained Stacked, BC") ///
                        lab(20 "Constrained Stacked, LASSO") ///
                        size(medium) row(3) order(2 4 14 16 6 8 18 20 10 12))
                    }
                    if inlist("`ind_var'","cigtax") { // cigarette taxes ($2023) - (no logit stacked DD nor constrained stacked DD event studies)
                        // using $0.50 nominal increases for prominent stacked DD
                        scalar spacing = 0.07

                        local f_estlist ///
                        (esod_sty`yr'_`var'_1_`subsample'  , msymbol(Th) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esod_sty`yr'_`var'_3_`subsample'  , msymbol(T)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esc_sty`yr'_`var'_1_`subsample'   , msymbol(A)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(cigarette_tax_scale_s2w_F3 cigarette_tax_scale_s2w_F2 cigarette_tax_scale_s2w_F1_og cigarette_tax_scale_s2w_L0 cigarette_tax_scale_s2w_L1)) ///
                        (esc_sty`yr'_`var'_3_`subsample'   , msymbol(V)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(cigarette_tax_scale_s2w_F3 cigarette_tax_scale_s2w_F2 cigarette_tax_scale_s2w_F1_og cigarette_tax_scale_s2w_L0 cigarette_tax_scale_s2w_L1)) ///
                        (esd_sty`yr'_`var'_1_`subsample'   , msymbol(Oh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esd_sty`yr'_`var'_3_`subsample'   , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esdl3_50_y`yr'`subsample'_`var'_m1, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esdl3_50_y`yr'`subsample'_`var'_m3, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) 
                        
                        local f_legend ///
                        legend( ///
                        lab(2 "TWFE, BC") ///
                        lab(4 "TWFE, LASSO") ///
                        lab(6 "Constrained, BC") ///
                        lab(8 "Constrained, LASSO") ///    
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "TWFE Stacked, BC") ///
                        lab(16 "TWFE Stacked, LASSO") ///             
                        size(medium) cols(4) order(2 4 14 16 6 8 10 12))
                    }
                }
                if `config'==4 { // 8 estimates
                    scalar spacing = 0.07

                    if "`ind_var'"=="flav" {
                        local f_estlist ///
                        (`var'_1od4l_`subsample'y`yr'3_st, msymbol(Th) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_3od4l_`subsample'y`yr'3_st, msymbol(T)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (`var'_1c4l_`subsample'y`yr'3_st , msymbol(A)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) ///
                        (`var'_3c4l_`subsample'y`yr'3_st , msymbol(V)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(flav_lead5_plus flav_lead4_3 flav_lead2_1_og flav_lag0_1 flav_lag2_plus)) ///
                        (`var'_1d4l_`subsample'y`yr'3_st , msymbol(Oh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (`var'_3d4l_`subsample'y`yr'3_st , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esody`yr's_m1_`var'_`subsample'3, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m3_`var'_`subsample'3, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))  //
                    
                        local f_legend ///
                        legend( ///
                        lab(2  "TWFE, BC") ///
                        lab(4  "TWFE, LASSO") ///
                        lab(6  "Constrained, BC") ///
                        lab(8  "Constrained, LASSO") ///
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "TWFE Stacked, BC") ///
                        lab(16 "TWFE Stacked, LASSO") ///
                        size(medium) row(2) colfirst)
                    }
                    if "`ind_var'"=="mlsa" {
                        local f_estlist ///
                        (esod_sty`yr'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esod_sty`yr'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esc_sty`yr'_`var'_1_`subsample' , msymbol(A)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1)) ///
                        (esc_sty`yr'_`var'_3_`subsample' , msymbol(V)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(any_mlsa_vape_s2w_F3 any_mlsa_vape_s2w_F2 any_mlsa_vape_s2w_F1_og any_mlsa_vape_s2w_L0 any_mlsa_vape_s2w_L1)) ///
                        (esd_sty`yr'_`var'_1_`subsample' , msymbol(Oh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esd_sty`yr'_`var'_3_`subsample' , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esody`yr's_m1_`var'_`subsample'2, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esody`yr's_m3_`var'_`subsample'2, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5))  //
                        
                        local f_legend ///
                        legend( ///
                        lab(2  "TWFE, BC") ///
                        lab(4  "TWFE, LASSO") ///
                        lab(6  "Constrained, BC") ///
                        lab(8  "Constrained, LASSO") ///
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "TWFE Stacked, BC") ///
                        lab(16 "TWFE Stacked, LASSO") ///
                        size(medium) row(2) colfirst)
                    }
                    if "`ind_var'"=="cigtax" {
                        // using $0.50 nominal increases for prominent stacked DD
                        local f_estlist ///
                        (esod_sty`yr'_`var'_1_`subsample'  , msymbol(Th) offset(`=( spacing / 2) - (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esod_sty`yr'_`var'_3_`subsample'  , msymbol(T)  offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esc_sty`yr'_`var'_1_`subsample'   , msymbol(A)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(cigarette_tax_scale_s2w_F3 cigarette_tax_scale_s2w_F2 cigarette_tax_scale_s2w_F1_og cigarette_tax_scale_s2w_L0 cigarette_tax_scale_s2w_L1)) ///
                        (esc_sty`yr'_`var'_3_`subsample'   , msymbol(V)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(cigarette_tax_scale_s2w_F3 cigarette_tax_scale_s2w_F2 cigarette_tax_scale_s2w_F1_og cigarette_tax_scale_s2w_L0 cigarette_tax_scale_s2w_L1)) ///
                        (esd_sty`yr'_`var'_1_`subsample'   , msymbol(Oh) offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esd_sty`yr'_`var'_3_`subsample'   , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5) `f_converge') ///
                        (esdl3_50_y`yr'`subsample'_`var'_m1, msymbol(Sh) offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) ///
                        (esdl3_50_y`yr'`subsample'_`var'_m3, msymbol(S)  offset(`=(-spacing / 2) + (spacing * 4)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5)) 
                        
                        local f_legend ///
                        legend( ///
                        lab(2 "TWFE, BC") ///
                        lab(4 "TWFE, LASSO") ///
                        lab(6 "Constrained, BC") ///
                        lab(8 "Constrained, LASSO") ///    
                        lab(10 "Logit, BC") ///
                        lab(12 "Logit, LASSO") ///
                        lab(14 "TWFE Stacked, BC") ///
                        lab(16 "TWFE Stacked, LASSO") ///             
                        size(medium) cols(4) order(2 4 14 16 6 8 10 12))
                    }
                }
            }

            // parameters
            {
                // y-axis
                /*
                if inlist(`config',1) {
                if "`var'"=="vape" local f_ysca yla(-0.120(0.040)0.120, nogrid)
                if "`var'"!="vape" local f_ysca yla(-0.075(0.025)0.075, nogrid)
                }
                */

                if inlist(`config',2,3,4) {
                    if "`ind_var'"=="cigtax" {
                        if "`var'"=="fvape"  local f_ysca yla(-0.050(0.025)0.050, nogrid)
                        if "`subsample'"=="id_ht"  & "`var'"=="fsmoke" local f_ysca yla(-0.020(0.010)0.020, nogrid)
                        if "`subsample'"=="id_nh1" & "`var'"=="fsmoke" local f_ysca yla(-0.030(0.010)0.030, nogrid)
                    }
                    if "`ind_var'"=="flav" {
                        if "`var'"=="fvape"  local f_ysca yla(-0.150(0.025)0.075, nogrid)

                        if "`var'"=="fsmoke" & "`subsample'"=="id_ht"  local f_ysca yla(-0.040(0.010)0.040, nogrid)
                        if "`var'"=="fsmoke" & "`subsample'"=="id_nh1" local f_ysca yla(-0.075(0.025)0.075, nogrid)
                    }
                    if "`ind_var'"=="mlsa" {
                        if "`var'"=="fvape"  local f_ysca yla(-0.100(0.025)0.100, nogrid)
                        if "`var'"=="fsmoke" & "`subsample'"=="id_ht" local f_ysca yla(-0.030(0.010)0.030, nogrid)
                        if "`var'"=="fsmoke" & "`subsample'"=="id_nh1" local f_ysca yla(-0.050(0.010)0.050, nogrid)
                    }
                }

                if "`ind_var'"=="flav"   local f_varname "ENDS Flavor Bans"
                if "`ind_var'"=="mlsa"   local f_varname "ENDS MLSA"
                if "`ind_var'"=="cigtax" local f_varname "Cigarette Taxes"
            }

            forval legend_iter = 0/1 {
                
                // legend_iter-specific
                {
                    if `legend_iter'==0 {
                        local name_leg
                        local f_legend_di `f_legend'
                        local f_dimen ysize(2.18) xsize(7)
                    }
                    if `legend_iter'==1 {
                        local name_leg _1
                        local f_legend_di legend(off)
                        local f_dimen ysize(2.18) xsize(4.6)
                    }
                }

                // plotting 
                coefplot ///
                `f_estlist' ///
                , ///
                rename( ///
                flav_lead5_plus            = lead_3 flav_lead4_3               = lead_2 flav_lead2_1_og                = lead_1 flav_lag0_1                = lag_0 flav_lag2_plus             = lag_1 ///
                semleadyr_3_flav           = lead_3 semleadyr_2_flav           = lead_2 semleadyr_1_og_flav            = lead_1 semlagyr_0_flav            = lag_0 semlagyr_1_flav            = lag_1 ///
                any_mlsa_vape_s2w_F3       = lead_3 any_mlsa_vape_s2w_F2       = lead_2 any_mlsa_vape_s2w_F1_og        = lead_1 any_mlsa_vape_s2w_L0       = lag_0 any_mlsa_vape_s2w_L1       = lag_1 ///
                semleadyr_3_mlsa           = lead_3 semleadyr_2_mlsa           = lead_2 semleadyr_1_og_mlsa            = lead_1 semlagyr_0_mlsa            = lag_0 semlagyr_1_mlsa            = lag_1 ///
                cigarette_tax_scale_s2w_F3 = lead_3 cigarette_tax_scale_s2w_F2 = lead_2 cigarette_tax_scale_s2w_F1_og = lead_1 cigarette_tax_scale_s2w_L0 = lag_0 cigarette_tax_scale_s2w_L1 = lag_1 ///
                lc_1                       = lead_3 lc_2                       = lead_2 lc_3                           = lead_1 lc_4                       = lag_0 lc_5                       = lag_1 ///
                ) ///
                omitted ///
                vertical ///
                graphregion(color(white)) ///
                ytitle("Estimated Effect of `f_varname'", size(medium) xoffset(-1)) ///
                yline(0, lcolor(black)) `f_ysca' ylabel(, labsize(medium)) ///
                xtitle("Years Before/After `f_varname'", size(medium) yoffset(-1)) ///
                xline(3.5, lpattern(dash) lcolor(black)) ///
                xlabel(1 "{&le} -5" 2 "-4,-3" 3 "-2,1" 4 "0,1" 5 "{&ge} 2", labsize(medium)) ///
                `f_dimen' ///
                msize(medium) ///
                `f_legend_di' ///
                ciopts(recast(rcap))

                graph export "output/etax/graphs/final/es_agg_`ind_var'_v`config'`name_leg'_`var'_`subsample'.png", replace
                graph close
            }
        }
        }
            estimates clear
        }
        }
        }

        macro drop _name_ind_var

        // non-convergence
        {
            /*
                mlsa, 1, fsmoke, id_nh1, logit stacked BC
                mlsa, 1, fsmoke, id_nh1, logit stacked LASSO
            */
        }
    }

    // brfss, endstax/flavor ban/mlsa/cigtax, vape/dvape/smoke/dsmoke
    if 1 {
        *local f_converge mlabel(@aux1) aux(B[1,]) mlabgap(*2) mlabposition(12)

        eststo clear
        estimates clear

        foreach age_sep in /*all*/ sep {
        foreach ind_var in /*etax mlsa*/ flav /*cigtax*/ {
            eststo clear
            estimates clear
            
            if "`ind_var'"=="etax" {
                local ind_var_f etax

                if "`age_sep'"=="all" local ind_var_num _1
                if "`age_sep'"=="sep" local ind_var_num

                if "`age_sep'"=="all" local name_est ends_tax_nom35_scale
                if "`age_sep'"=="sep" local name_est etax
                local f_title ENDS Taxes
            }
            if "`ind_var'"=="mlsa" {
                local ind_var_f any_mlsa_vape
                local ind_var_num _2
                local f_title ENDS MLSA
            }
            if "`ind_var'"=="flav" {
                local ind_var_f flavor_ban
                local ind_var_num _3
                local f_title ENDS Flavor Bans
            }
            if "`ind_var'"=="cigtax" {
                local ind_var_f cigarette_tax_scale
                local ind_var_num _4
                local f_title Cigarette Taxes
            }
            if "`ind_var'"!="etax" local name_est `ind_var_f'

            if "`age_sep'"=="sep" {
                if "`ind_var'"=="etax" {
                    estread _all using "log/estimates/brfss_eventstudy_v1.sters"
                    estread _all using "log/estimates/brfss_eventstudy_v1_1.sters"
                }
                if "`ind_var'"!="etax" {
                    estread _all using "log/estimates/brfss_eventstudy_v1_2_`name_est'_.sters"
                    estread _all using "log/estimates/brfss_eventstudy_v1_2_`name_est'_1.sters"
                }
            }
            if "`age_sep'"=="all" {
                estread _all using "log/estimates/brfss_eventstudy_v4_`name_est'"
            }

        foreach subsample in id_ht id_nh1 {
        foreach var in dvape dsmoke {
        forval age = 0/1 { // {18-30, 31+}
            // skip pattern
            {
                if "`age_sep'"=="all" & `age'==1 continue
            }
            // age-specific
            {
                if `age'==0 local name_age   // 18-30
                if `age'==1 local name_age 1 // 31+
            }
            // name estimates
            {
                scalar spacing = 0.10

                if "`age_sep'"=="sep" {
                    if "`ind_var'"!="etax" {
                    local f_estlist ///
                    (esod`name_age'`ind_var_num'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                    (esod`name_age'`ind_var_num'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                    (esd`name_age'`ind_var_num'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6) `f_converge') ///
                    (esd`name_age'`ind_var_num'_`var'_3_`subsample' , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6) `f_converge') ///
                    (esc`name_age'`ind_var_num'_`var'_1_`subsample' , msymbol(A)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f')) ///
                    (esc`name_age'`ind_var_num'_`var'_3_`subsample' , msymbol(V)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f')) 
                    
                    local f_legend ///
                    legend( ///
                    lab(2  "TWFE, BC") ///
                    lab(4  "TWFE, LASSO") ///
                    lab(6  "Logit, BC") ///
                    lab(8  "Logit, LASSO") ///
                    lab(10 "Constrained, BC") ///
                    lab(12 "Constrained, LASSO") ///
                    size(medium) colfirst row(2))
                    }

                    if "`ind_var'"=="mlsa" & "`subsample'"=="id_nh1" & "`var'"=="dvape" { // remove logit, doesn't converge
                    local f_estlist ///
                    (esod`name_age'`ind_var_num'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                    (esod`name_age'`ind_var_num'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                    (esc`name_age'`ind_var_num'_`var'_1_`subsample' , msymbol(A)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f')) ///
                    (esc`name_age'`ind_var_num'_`var'_3_`subsample' , msymbol(V)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f')) 
                    
                    local f_legend ///
                    legend( ///
                    lab(2  "TWFE, BC") ///
                    lab(4  "TWFE, LASSO") ///
                    lab(10 "Constrained, BC") ///
                    lab(12 "Constrained, LASSO") ///
                    size(medium) colfirst row(2))
                    }

                    
                    if "`ind_var'"=="etax" {
                    local f_estlist ///
                    (esod`name_age'`ind_var_num'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                    (esod`name_age'`ind_var_num'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                    (es`name_age'd`ind_var_num'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6) `f_converge') ///
                    (es`name_age'd`ind_var_num'_`var'_3_`subsample' , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6) `f_converge') ///
                    (esc`name_age'`ind_var_num'_`var'_1_`subsample' , msymbol(A)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f')) ///
                    (esc`name_age'`ind_var_num'_`var'_3_`subsample' , msymbol(V)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f'))
                    
                    local f_legend ///
                    legend( ///
                    lab(2  "TWFE, BC") ///
                    lab(4  "TWFE, LASSO") ///
                    lab(6  "Logit, BC") ///
                    lab(8  "Logit, LASSO") ///
                    lab(10 "Constrained, BC") ///
                    lab(12 "Constrained, LASSO") ///
                    size(medium) colfirst row(2))
                    }
                }

                if "`age_sep'"=="all" {
                    local f_estlist ///
                    (esod`name_age'`ind_var_num'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                    (esod`name_age'`ind_var_num'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                    (esd`name_age'`ind_var_num'_`var'_1_`subsample' , msymbol(Oh) offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6) `f_converge') ///
                    (esd`name_age'`ind_var_num'_`var'_3_`subsample' , msymbol(O)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6) `f_converge') ///
                    (esc`name_age'`ind_var_num'_`var'_1_`subsample' , msymbol(A)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f')) ///
                    (esc`name_age'`ind_var_num'_`var'_3_`subsample' , msymbol(V)  offset(`=(-spacing / 2) + (spacing * 3)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f')) 
                    
                    local f_legend ///
                    legend( ///
                    lab(2  "TWFE, BC") ///
                    lab(4  "TWFE, LASSO") ///
                    lab(6  "Logit, BC") ///
                    lab(8  "Logit, LASSO") ///
                    lab(10 "Constrained, BC") ///
                    lab(12 "Constrained, LASSO") ///
                    size(medium) colfirst row(2))

                    if "`ind_var'"=="mlsa" & "`subsample'"=="id_nh1" & "`var'"=="dvape" { // remove logit -- doesn't converge
                        local f_estlist ///
                        (esod`name_age'`ind_var_num'_`var'_1_`subsample', msymbol(Th) offset(`=( spacing / 2) - (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                        (esod`name_age'`ind_var_num'_`var'_3_`subsample', msymbol(T)  offset(`=( spacing / 2) - (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(lc_1 lc_2 lc_3 lc_4 lc_5 lc_6)) ///
                        (esc`name_age'`ind_var_num'_`var'_1_`subsample' , msymbol(A)  offset(`=(-spacing / 2) + (spacing * 1)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f')) ///
                        (esc`name_age'`ind_var_num'_`var'_3_`subsample' , msymbol(V)  offset(`=(-spacing / 2) + (spacing * 2)') mcolor(gs5) ciopts(lcolor(gs5) lwidth(medthick)) keep(y_v2a_F3_`ind_var_f' y_v2a_F2_`ind_var_f' y_v2a_F1_`ind_var_f'_og y_v2a_L0_`ind_var_f' y_v2a_L1_`ind_var_f' y_v2a_L2_`ind_var_f')) 
                        
                        local f_legend ///
                        legend( ///
                        lab(2  "TWFE, BC") ///
                        lab(4  "TWFE, LASSO") ///
                        lab(6 "Constrained, BC") ///
                        lab(8 "Constrained, LASSO") ///
                        size(medium) colfirst row(2))
                    }
                }
            }

            // add convergence label
            if "`age_sep'"=="sep" & "`ind_var'"=="etax" {
                forval model = 1(2)3 {
                    estimates restore es`name_age'_`var'_`model'_`subsample'
                    scalar converge_pre = e(converge)

                    estimates restore es`name_age'd_`var'_`model'_`subsample'

                    matrix B = J(1,6,.)
                    forval b = 1/6 {
                        matrix B[1,`b'] = converge_pre
                    }
                    estadd matrix B
                }
            }

            // post-estimation delta method
            {
                forval model = 1(2)3 {
                    // delta, OLS twfe, model 1/3
                    estimates restore eso`name_age'`ind_var_num'_`var'_`model'_`subsample'

                    xlincom ///
                    ((_b[y_v2a_F3_`ind_var_f'] + _b[y_v2a_F2_`ind_var_f'] + _b[y_v2a_F1_`ind_var_f']) / 3) /// -3+ lead
                    (                           (_b[y_v2a_F2_`ind_var_f'] + _b[y_v2a_F1_`ind_var_f']) / 2) /// -2 lead
                    (                                                      (_b[y_v2a_F1_`ind_var_f']) / 1) /// -1 lead
                    ((_b[y_v2a_L0_`ind_var_f'])                                                       / 1) ///  0 lag   
                    ((_b[y_v2a_L0_`ind_var_f'] + _b[y_v2a_L1_`ind_var_f'])                            / 2) ///  1 lag
                    ((_b[y_v2a_L0_`ind_var_f'] + _b[y_v2a_L1_`ind_var_f'] + _b[y_v2a_L2_`ind_var_f']) / 3) ///  2+ lag
                    , post level(95)
                    _eststo esod`name_age'`ind_var_num'_`var'_`model'_`subsample'
                }
            }

            // parameters
            {
                // y-axis
                if `age'==0 {
                    if "`var'"=="dvape"  local f_ysca yla(-0.050(0.010)0.050, nogrid)
                    if "`var'"=="dsmoke" local f_ysca yla(-0.050(0.010)0.050, nogrid)
                    if "`age_sep'"=="all" & "`var'"=="dvape" local f_ysca yla(-0.020(0.010)0.020, nogrid)
                    if "`age_sep'"=="all" & "`var'"=="dsmoke" local f_ysca yla(-0.020(0.010)0.020, nogrid)

                    if "`ind_var'"=="etax"   & "`subsample'"=="id_nh1" & "`var'"=="dvape"  local f_ysca yla(-0.075(0.025)0.075, nogrid)
                    if "`ind_var'"=="etax"   & "`subsample'"=="id_nh1" & "`var'"=="dsmoke" local f_ysca yla(-0.050(0.010)0.050, nogrid)
                    
                    if "`ind_var'"=="cigtax" & "`subsample'"=="id_nh1" & "`var'"=="dvape"  local f_ysca yla(-0.075(0.025)0.075, nogrid)
                    if "`ind_var'"=="cigtax" & "`subsample'"=="id_nh1" & "`var'"=="dsmoke" local f_ysca yla(-0.075(0.025)0.075, nogrid)

                    if "`ind_var'"=="flav"   & "`subsample'"=="id_ht"  & "`var'"=="dvape"  local f_ysca yla(-0.150(0.050)0.050, nogrid)
                    if "`ind_var'"=="flav"   & "`subsample'"=="id_nh1" & "`var'"=="dvape"  local f_ysca yla(-0.400(0.100)0.200, nogrid)
                    if "`ind_var'"=="flav"   & "`subsample'"=="id_nh1" & "`var'"=="dsmoke" local f_ysca yla(-0.100(0.050)0.100, nogrid)

                    if "`ind_var'"=="mlsa"   & "`subsample'"=="id_ht"  & "`var'"=="dvape"  local f_ysca yla(-0.050(0.050)0.150, nogrid)
                    if "`ind_var'"=="mlsa"   & "`subsample'"=="id_nh1" & "`var'"=="dvape"  local f_ysca yla(-0.075(0.025)0.150, nogrid)
                    if "`ind_var'"=="mlsa"   & "`subsample'"=="id_nh1" & "`var'"=="dsmoke" local f_ysca yla(-0.100(0.050)0.100, nogrid)   

                    if "`age_sep'"=="all" & "`ind_var'"=="flav"   & "`subsample'"=="id_ht"  & "`var'"=="dvape"  local f_ysca yla(-0.050(0.010)0.050, nogrid)
                    if "`age_sep'"=="all" & "`ind_var'"=="flav"   & "`subsample'"=="id_nh1" & "`var'"=="dvape"  local f_ysca yla(-0.300(0.100)0.300, nogrid)
                    if "`age_sep'"=="all" & "`ind_var'"=="flav"   & "`subsample'"=="id_ht"  & "`var'"=="dsmoke" local f_ysca yla(-0.050(0.010)0.050, nogrid)
                    if "`age_sep'"=="all" & "`ind_var'"=="flav"   & "`subsample'"=="id_nh1" & "`var'"=="dsmoke" local f_ysca yla(-0.100(0.050)0.100, nogrid)

                    if "`age_sep'"=="all" & "`ind_var'"=="mlsa"   & "`subsample'"=="id_ht"  & "`var'"=="dvape"  local f_ysca yla(-0.050(0.010)0.050, nogrid)
                    if "`age_sep'"=="all" & "`ind_var'"=="mlsa"   & "`subsample'"=="id_nh1" & "`var'"=="dvape"  local f_ysca yla(-0.100(0.025)0.100, nogrid)
                    if "`age_sep'"=="all" & "`ind_var'"=="mlsa"   & "`subsample'"=="id_ht" & "`var'"=="dsmoke"  local f_ysca yla(-0.050(0.010)0.050, nogrid)
                    if "`age_sep'"=="all" & "`ind_var'"=="mlsa"   & "`subsample'"=="id_nh1" & "`var'"=="dsmoke" local f_ysca yla(-0.100(0.050)0.100, nogrid)
                }

                if `age'==1 {
                    if "`var'"=="dvape"  local f_ysca yla(-0.030(0.010)0.030, nogrid)
                    if "`var'"=="dsmoke" local f_ysca yla(-0.030(0.010)0.030, nogrid)

                    if "`ind_var'"=="flav"   & "`subsample'"=="id_nh1" & "`var'"=="dvape"  local f_ysca yla(-0.100(0.050)0.100, nogrid)
                    if "`ind_var'"=="flav"   & "`subsample'"=="id_nh1" & "`var'"=="dsmoke" local f_ysca yla(-0.075(0.025)0.075, nogrid)

                    if "`ind_var'"=="mlsa"   & "`subsample'"=="id_nh1" & "`var'"=="dvape"  local f_ysca yla(-0.050(0.050)0.100, nogrid)
                    if "`ind_var'"=="mlsa"   & "`subsample'"=="id_nh1" & "`var'"=="dsmoke" local f_ysca yla(-0.100(0.050)0.100, nogrid)
                }

                // dimensions
                
            }

            forval legend_iter = 0/1 {
                    
                // legend_iter-specific
                {
                    if `legend_iter'==0 {
                        local name_leg
                        local f_legend_di `f_legend'
                        local f_dimen ysize(2.18) xsize(6)
                    }
                    if `legend_iter'==1 {
                        local name_leg _1
                        local f_legend_di legend(off)
                        local f_dimen ysize(2.18) xsize(4.6)
                    }
                }

                // plotting 
                coefplot ///
                `f_estlist' ///
                , ///
                rename( ///
                y_v2a_F3_`ind_var_f' = lead_3 y_v2a_F2_`ind_var_f' = lead_2 y_v2a_F1_`ind_var_f'_og = lead_1 y_v2a_L0_`ind_var_f' = lag_0 y_v2a_L1_`ind_var_f' = lag_1 y_v2a_L2_`ind_var_f' = lag_2 ///
                lc_1 = lead_3 lc_2 = lead_2 lc_3 = lead_1 lc_4 = lag_0 lc_5 = lag_1 lc_6 = lag_2 ///
                ) ///
                omitted ///
                vertical ///
                graphregion(color(white)) ///
                ytitle("Estimated Effect of `f_title'", size(medium) xoffset(-1)) ///
                yline(0, lcolor(black)) `f_ysca' ylabel(, labsize(medium) glpattern(blank)) ///
                xtitle("Years Before/After `f_title'", size(medium) yoffset(-1)) ///
                xline(3.5, lpattern(dash) lcolor(black)) ///
                xlabel(1 "{&le} -3" 2 "-2" 3 "-1" 4 "0" 5 "1" 6 "{&ge} 2", labsize(medium)) ///
                msize(medium) ///
                `f_dimen' ///
                `f_legend_di' ///
                ciopts(recast(rcap))

                graph export "output/etax/graphs/final/es_agg_brfss_`age_sep'_`ind_var'`name_age'`name_leg'_`var'_`subsample'.png", replace
                graph close

                exit
            }
            eststo clear
        }
        }
        }
        estimates clear
        }
        }

        // non-convergence
        {
            /*
            
            */
        }
    }
}

// space for VSCode