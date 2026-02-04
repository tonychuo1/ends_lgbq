//
// (04): tabulate summary statistics and regression results (for regression tables, in place of the listed "pre-treatment means", use the "dependent var means (overall, not pre-treatment)" code chunk at the bottom of this file)
//

// descriptive statistics
if 1 {
    use "data/final/master_set_2023", clear
    
    preserve

    local vars_descriptive ///
    vape fvape dvape ///
    smoke fsmoke dsmoke ///
    combust fcombust dcombust ///
    ///
    ends_tax_nom35_scale flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
    uer coviddeaths populationvaccinated ///
    ///
    ecigs_lis_law_any indoor_ban_vape ecigban ///
    indoor_ban_smoke tobacco_lis_law_any beer_tax_scale RML MML ///
    tally_sexualorientation 

    // label dep vars for table display
    {
        label var vape "Current ENDS Use"
        label var fvape "Frequent ENDS Use"
        label var dvape "Everyday ENDS Use"

        label var smoke "Current Cigarette Smoking"
        label var fsmoke "Frequent Cigarette Smoking"
        label var dsmoke "Everyday Cigarette Smoking"

        label var combust "Current Cigarette or Cigar Smoking"
        label var fcombust "Frequent Cigarette or Cigar Smoking"
        label var dcombust "Everyday Cigarette or Cigar Smoking"

        label var cigar "Current Cigar Smoking"
        label var fcigar "Frequent Cigar Smoking"
        label var dcigar "Everyday Cigar Smoking"

        label var ends_tax_nom35_scale "ENDS Tax ($2023)"
        label var any_mlsa_vape "Vaping MLSA Law"
        label var t21 "Tobacco 21 Law"
        label var ecigs_lis_law_any "E-Cig Licensure Law"
        label var indoor_ban_vape "Indoor Vaping Restriction"
        label var ecigban "Online E-Cig Sales Ban"
        label var flavor_ban "Flavored E-Cig Restriction"

        label var cigarette_tax_scale "Cigarette Tax ($2023)"
        label var tobacco_lis_law_any "Tobacco Licensure Law"
        label var indoor_ban_smoke "Indoor Smoking Restriction"
        label var tobacban "Online Tobacco Sales Ban"
        label var menthol_ban "Menthol Flavor Ban"

        label var beer_tax_scale "Beer Tax ($2023)"
        //label var samaritan_alc "Good Samaritan Alcohol Law"
        label var RML "Recreational Marijuana Law"
        label var MML "Medical Marijuana Law"
        //label var DML "Marijuana Decriminalization"

        //label var pdmp_must "Must-Access Prescription Drug Monitoring Program Law"
        //label var samaritan_drug "Good Samaritan Drug Law"

        label var samaritan_alc "Good Samaritan Alcohol Law"
        label var naloxone "Naloxone Law"

        label var uer "Unemployment Rate"
        label var log_povrate "Logged Poverty Rate"
        //label var pcinc_scale "Per-Capita Income (2021 $)"
        //label var minimum_wage_scale "Minimum Wage (2021 $)"		
    }

    // multiply covid deaths by 100 to get reasonable looking table
    replace coviddeaths = coviddeaths * 100


    eststo clear
    // All, 2015-2023
    qui eststo: estpost summ `vars_descriptive' if (inrange(year,2015,2023) & !national) [aw=aweight]

    // All, non-missing sex orientation info, 2015-2023
    qui eststo: estpost summ `vars_descriptive' if (inrange(year,2015,2023) & !national & !mi(lgbq_1)) [aw=aweight] 

    // LGBQ, 2015-2023
    qui eststo: estpost summ `vars_descriptive' if (inrange(year,2015,2023) & !national & (lgbq_1 == 1)) [aw=aweight]

    // Heterosexual, 2015-2023
    qui eststo: estpost summ `vars_descriptive' if (inrange(year,2015,2023) & !national & (lgbq_1 == 0)) [aw=aweight]

    // LGBQ, 2011-2023
    qui eststo: estpost summ `vars_descriptive' if (inrange(year,2011,2023) & !national & (lgbq_1 == 1)) [aw=aweight]

    // Heterosexual, 2011-2023
    qui eststo: estpost summ `vars_descriptive' if (inrange(year,2011,2023) & !national & (lgbq_1 == 0)) [aw=aweight]


    * Table vars
    esttab using "output/etax/figures/final/summary_stats.rtf", ///
    cells("mean(fmt(3)) & sd(par)") mtitle("All (2015-2023)" "All* (2015-2023)" ///
    "LGBQ (2015-2023)" "Hetero (2015-2023)" "LGBQ (2011-2023)" "Hetero (2011-2023)" ) ///
    replace gaps onecell modelwidth(11) varwidth(12) label collabels(none) ///
    refcat(vape "{\li200 \i Dependent Variables}" ends_tax_nom35_scale "{\pard \vspace-500 \i Independent Variables}", nolabel) ///
    nonum note("All* denotes all observations with sexual identity information ") 


    eststo clear 
    estimates clear

    restore
}

// main effect of ENDS and cigarette policies (on vaping) across models
if 1 {
    // v1: sex-id, hetero, lgbq panels; models 1,2,3 columns; current, frequent, daily use column groups
    {
        set matsize 1000

        eststo clear
        estimates clear

        // regressions 'difficult'
        if 0 {
            // try to use 'difficult' on non-converging fsmoke fully-diff regs
            global dem_control i.sex i.grade i.age i.race4

            forval flavor = 0/1 {
                // flavor-specific
                {
                    if `flavor'==0 {
                        local sample_flavor 1
                        local vars_margins ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    }
                    if `flavor'==1 {
                        local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR
                        local vars_margins flavor_ban
                    }
                }
            forval model = 1/3 {
                // model-specific
                {
                    if `model'==1 local vars_controls
                    if `model'==2 local vars_controls ${vars_lasso_sel_fsmokey1}
                    if `model'==3 local vars_controls ${vars_lasso_sel_fsmokey1} c.tally_sexualorientation
                }
                local yr 1
            foreach var of varlist smoke fsmoke {
                if `model'==1 & `flavor'==0 { // tester
                    logit `var' ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    ${dem_control} ///
                    `vars_controls' ///
                    i.fips i.year_true i.semester ///
                    if lgbq_1==0 & `sample_flavor' & inrange(year,201`yr',2023) [pw=aweight], difficult ///
                    vce(cluster fips) iterate(15)
                    scalar converge_pre = e(converged)	

                    _eststo `var'_`model'`flavor'l_id_hty`yr'3_st_test: ///
                    margins, dydx(`vars_margins') post
                    estadd scalar converge = converge_pre
                }

                // fully-diff
                {
                    _eststo `var'_`model'`flavor'ldo_ally`yr'3_st_a: ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    ${dem_control} ///
                    `vars_controls' ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & `sample_flavor' & inrange(year,201`yr',2023) [pw=aweight], difficult ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)	
                }
            }
            }
                *estwrite _all using "log/estimates/logit_difficult_combustibles.sters", append
            }
        }

        forval flavor=0/1 {
            // flavor-specific
            {
                if `flavor'==1 local name_fl 3l // denotes overall flavorban estimates in "other_pol.sters"
                else           local name_fl
            }
        foreach survey in st {
        foreach var in vape {
            if "`var'"=="vape"  local t_title "ENDS"
            if "`var'"=="smoke" local t_title "Cigarette"
            if "`var'"=="cigar" local t_title "Cigar"

            if "`survey'"=="com" & "`var'"!="vape" continue
            

            forval model = 1/3 {
                if `flavor'==0 estread `var'_*l* f`var'_*l* d`var'_*l* using "log/estimates/main_y53`survey'`model'l"
                if `flavor'==1 estread `var'_*l* f`var'_*l* d`var'_*l* using "log/estimates/other_pol_v20_y53st`model'l"
            }

        forval other_pol = 1/1 { // ends taxes, other policies 
            if `flavor'==1 & `other_pol'!=1 continue
        foreach panel in all id_ht id_nh1 {

            // parameters
            {
                if `flavor'==0 {
                    local t_keep_main0 ends_tax_nom35_scale 
                    local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                    local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                    local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                    local t_keep_main1 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape

                    local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                    local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""
                }
                if `flavor'==1 {
                    local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban

                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""
                }

                if "`panel'"=="all" {
                    local t_nonum
                    local t_mgroup  "mgroup("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use", pattern(1 0 0 1 0 0 1 0 0))"
                    local t_mtitles "mtitles("Model 1" "Model 2" "Model 3" "Model 1" "Model 2" "Model 3" "Model 1" "Model 2" "Model 3")"
                    
                    local t_repapp  replace

                    local t_refcat "All Conditional on Sex-ID"
                }
                else {
                    local t_nonum   nonum
                    local t_mgroup 
                    local t_mtitles nomtitle

                    local t_repapp  append
                }
                if "`panel'"=="id_ht" {
                    local t_refcat "Heterosexual"
                }
                if "`panel'"=="id_nh1" {
                    local t_refcat "LGBQ"
                }

                if `flavor'==0 local t_refcat_var ends_tax_nom35_scale
                if `flavor'==1 local t_refcat_var flavor_ban 
            }

            esttab ///
            `var'_1l`name_fl'_`panel'y53_`survey' `var'_2l`name_fl'_`panel'y53_`survey' `var'_3l`name_fl'_`panel'y53_`survey' ///
            f`var'_1l`name_fl'_`panel'y53_`survey' f`var'_2l`name_fl'_`panel'y53_`survey' f`var'_3l`name_fl'_`panel'y53_`survey' ///
            d`var'_1l`name_fl'_`panel'y53_`survey' d`var'_2l`name_fl'_`panel'y53_`survey' d`var'_3l`name_fl'_`panel'y53_`survey' ///
            using "output/etax/figures/final/main_logit_v1_`survey'_`var'_`flavor'.rtf", ///
            `t_repapp' keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
            `t_nonum' ///
            `t_mgroup'  ///
            `t_mtitles' ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(5) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
        }

        // test of difference

        esttab ///
        `var'_1ldo`name_fl'_ally53_`survey' `var'_2ldo`name_fl'_ally53_`survey' `var'_3ldo`name_fl'_ally53_`survey' ///
        f`var'_1ldo`name_fl'_ally53_`survey' f`var'_2ldo`name_fl'_ally53_`survey' f`var'_3ldo`name_fl'_ally53_`survey' ///
        d`var'_1ldo`name_fl'_ally53_`survey' d`var'_2ldo`name_fl'_ally53_`survey' d`var'_3ldo`name_fl'_ally53_`survey' ///
        using "output/etax/figures/final/main_logit_v1_`survey'_`var'_`flavor'.rtf", ///
        append keep(`t_keep_dif`other_pol'') order(`t_keep_dif`other_pol'') ///
        nonum ///
        nomtitle ///
        main(p) b(3) not $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(5) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps

        
        }
        estimates clear
        }
        }
        }
        macro drop _name_fl
    }

    // v1.1: lgbq_2 subsample
    {
        set matsize 1000

        eststo clear
        estimates clear

        // test of differences regs for lgbq_2
        {
            global dem_control i.sex i.grade i.age i.race4

            foreach var of varlist fvape fsmoke {
                // var-specific
                {
                    if "`var'"=="fvape" {
                        local vars_lasso_sel ${vars_lasso_sel_`var'}
                        local year y5
                    }
                    else {
                        local vars_lasso_sel ${vars_lasso_sel_`var'y1}
                        local year y1
                    }
                }
                
                // model 3
                _eststo `var'_3ldo_st`year'3_id_nh2: ///
                logit `var' ///
                lgbq_2##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester) /// 
                if !mi(lgbq_2) [pw=aweight], ///
                vce(cluster fips) iterate(15)
                estadd scalar converge = e(converged)

                // model 3 - flavor ban
                // lgbq_2
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester /// 
                if lgbq_2==1 & !inlist(fips,6,11,25,41) [pw=aweight], ///
                vce(cluster fips) iterate(15)
                estadd scalar converge = e(converged)

                _eststo `var'_3l3l_st`year'3_id_nh2: ///
                margins, dydx(flavor_ban) post

                _eststo `var'_3ldo3l_st`year'3_id_nh2: ///
                logit `var' ///
                lgbq_2##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester) /// 
                if !mi(lgbq_2)& !inlist(fips,6,11,25,41) [pw=aweight], ///
                vce(cluster fips) iterate(15)
                estadd scalar converge = e(converged)
            }
        }

        foreach survey in st { 
            
            if 1 {
            estread fvape_*l* using "log/estimates/main_y53`survey'3l"
            estread fsmoke_*l* using "log/estimates/main_y13`survey'3l"
            }

        forval other_pol = 0/0 { // ends taxes, other policies 
        foreach panel in id_nh2 {

            // parameters
            {
               
                local t_keep_main0 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                local t_keep_dif0  1.lgbq_2#c.ends_tax_nom35_scale  1.lgbq_2#c.cigarette_tax_scale 1.lgbq_2#c.any_mlsa_vape

                local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" flavor_ban "ENDS Flavor Ban" any_mlsa_vape "ENDS MLSA""
                local t_coef_dif0  "1.lgbq_2#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_2#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_2#c.flavor_ban "ENDS Flavor Ban Diff" 1.lgbq_2#c.any_mlsa_vape "ENDS MLSA Diff""

                if "`panel'"=="id_nh2" {
                    local t_nonum
                    local t_mtitles "mtitles("Frequent Vaping" "Frequent Smoking")"
                    
                    local t_repapp  replace
                }
                else {
                    local t_nonum   nonum
                    local t_mgroup 
                    local t_mtitles nomtitle

                    local t_repapp  append
                }
                if "`panel'"=="id_nh2" {
                    local t_refcat "LGBQ (def 2)"
                }

                if `other_pol'==0 local t_refcat_var ends_tax_nom35_scale`scale_name'
                if `other_pol'==1 local t_refcat_var cigarette_tax_scale
            }

            esttab ///
            fvape_3l_`panel'y53_`survey' fsmoke_3l_`panel'y13_`survey' ///
            using "output/etax/figures/final/main_logit_v1_1_`survey'.rtf", ///
            replace keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
            `t_nonum' ///
            `t_mgroup'  ///
            `t_mtitles' ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(5) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps

            esttab ///
            fvape_3l3l_sty53_id_nh2 fsmoke_3l3l_sty13_id_nh2 ///
            using "output/etax/figures/final/main_logit_v1_1_`survey'.rtf", ///
            append keep(flavor_ban) ///
            nonum ///
            nomtitle ///
            b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(5) varwidth(15) compress onecell nogaps
        }

        // test of difference
        esttab ///
        fvape_3ldo_sty53_id_nh2 fsmoke_3ldo_sty13_id_nh2 ///
        using "output/etax/figures/final/main_logit_v1_1_`survey'.rtf", ///
        append keep(`t_keep_dif`other_pol'') order(`t_keep_dif`other_pol'') ///
        nonum ///
        nomtitle ///
        main(p) b(3) not $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(5) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps

        esttab ///
        fvape_3ldo3l_sty53_id_nh2 fsmoke_3ldo3l_sty13_id_nh2 ///
        using "output/etax/figures/final/main_logit_v1_1_`survey'.rtf", ///
        append keep(1.lgbq_2#c.flavor_ban) ///
        nonum ///
        nomtitle ///
        main(p) b(3) not $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(5) varwidth(15)compress onecell nogaps

        }
        
        }

        estimates clear
    }
}

// OLS main effect of ENDS and cigarette policies
if 1 {
    // v1: sex-id, hetero, lgbq panels; current, frequent, daily use columns
    {
        set matsize 1000

        eststo clear
        estimates clear
        
        forval flavor=0/1 {
            // flavor-specific
            {
                if `flavor'==1 {
                    local name_fl 3l // denotes overall flavorban estimates in "other_pol.sters"
                    local t_o o
                }
                else {
                    local name_fl
                    local t_o
                }
            }
        forval model = 1/3 {
        foreach var in vape smoke {
            if "`var'"=="vape" local name_y y5
            else               local name_y y1

            if `flavor'==0 { 
                estread `var'_`model'_*  f`var'_`model'_*  d`var'_`model'_* using "log/estimates/main_`name_y'3st`model'"
                estread `var'_`model'd_* f`var'_`model'd_* d`var'_`model'd_* using "log/estimates/main_`name_y'3st`model'"
            }
            if `flavor'==1 {
                estread `var'_`model'`name_fl'_*  f`var'_`model'`name_fl'_*  d`var'_`model'`name_fl'_* using "log/estimates/other_pol_v20_`name_y'3st`model'"
                estread `var'_`model'd`t_o'`name_fl'_* f`var'_`model'd`t_o'`name_fl'_* d`var'_`model'd`t_o'`name_fl'_* using "log/estimates/other_pol_v20_`name_y'3st`model'"
            }

            if "`var'"=="vape"  local t_title "ENDS"
            if "`var'"=="smoke" local t_title "Cigarette"
            if "`var'"=="cigar" local t_title "Cigar"
        forval other_pol = 1/1 { // deprecated level of iteration 
        foreach panel in all id_ht id_nh1 {

            // parameters
            {
                if `flavor'==0 {
                    local t_keep_main0 ends_tax_nom35_scale 
                    local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                    local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                    local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                    local t_keep_main1 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape

                    local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                    local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""
                
                    local t_refcat_var ends_tax_nom35_scale
                }
                if `flavor'==1 {
                    local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban

                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""

                    local t_refcat_var flavor_ban
                }

                if "`panel'"=="all" {
                    local t_nonum
                    local t_mtitles "mtitles("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use")"
                    
                    local t_repapp  replace

                    local t_refcat "All Conditional on Sex-ID"
                }
                else {
                    local t_nonum   nonum
                    local t_mtitles nomtitle

                    local t_repapp  append
                }
                if "`panel'"=="id_ht" {
                    local t_refcat "Heterosexual"
                }
                if "`panel'"=="id_nh1" {
                    local t_refcat "LGBQ"
                }
            }

            esttab ///
            `var'_`model'`name_fl'_`panel'`name_y'3_st f`var'_`model'`name_fl'_`panel'`name_y'3_st d`var'_`model'`name_fl'_`panel'`name_y'3_st ///
            using "output/etax/figures/final/main_ols_v1_m`model'_`var'_`flavor'.rtf", ///
            `t_repapp' keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
            `t_nonum' ///
            `t_mtitles' ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(10) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
        }

        // test of differences
        esttab ///
        `var'_`model'd`t_o'`name_fl'_all`name_y'3_st f`var'_`model'd`t_o'`name_fl'_all`name_y'3_st d`var'_`model'd`t_o'`name_fl'_all`name_y'3_st ///
        using "output/etax/figures/final/main_ols_v1_m`model'_`var'_`flavor'.rtf", ///
        append keep(`t_keep_dif`other_pol'') order(`t_keep_dif`other_pol'') ///
        nonum ///
        nomtitle ///
        main(p) b(3) not $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(10) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps
        }
        estimates clear
        }
        }
        }
    }
}

// combustible tobacco
if 1 {
    // v1: current, frequent, everyday cigarette smoking, c/f/d cigarette or cigar smoking; state, combined yrbs
    // 2011-2023; 2015-2023
    if 1 {
        set matsize 5000

        eststo clear

        forval flavor=0/1 {
            // flavor-specific
            {
                if `flavor'==1 local name_fl 3l // denotes overall flavorban estimates in "other_pol.sters"
                else           local name_fl
            }
        foreach yr in /*1*/ 5 {
        estimates clear

        forval model = 3/3 {
        forval other_pol = 1/1 { // deprecated
        foreach panel_sep1 in st com com_ols { // state, combined yrbs
            if `yr'==5 & "`panel_sep1'"!="st" continue

            // panel sep1-specifics
            {
                if "`panel_sep1'"=="st"      local t_name_ps1 "State YRBS"
                if "`panel_sep1'"=="com"     local t_name_ps1 "Combined YRBS"
                if "`panel_sep1'"=="com_ols" local t_name_ps1 "Combined YRBS, OLS"
            }

            if "`panel_sep1'"=="com_ols" {
                local panel_sep1 com
                local t_l
                local t_o
                local t_notes notes // last panel

                estread *smoke_`model'_*   *combust_`model'_*  using "log/estimates/main_y`yr'3`panel_sep1'`model'"
                estread *smoke_`model'd_*  *combust_`model'd_* using "log/estimates/main_y`yr'3`panel_sep1'`model'"
            }
            else {
                local t_l l
                local t_o o
                local t_notes nonotes // not last panel

                if `flavor'==0 {
                    estread *smoke_`model'l_*   *combust_`model'l_*    using "log/estimates/main_y`yr'3`panel_sep1'`model'l"
                    estread *smoke_`model'ldo_* *combust_`model'ldo_* using "log/estimates/main_y`yr'3`panel_sep1'`model'l"
                }
                if `flavor'==1 {
                    estread *smoke_`model'l`name_fl'_*   *combust_`model'l`name_fl'_*   using "log/estimates/other_pol_v20_y`yr'3`panel_sep1'`model'l"
                    estread *smoke_`model'ldo`name_fl'_* *combust_`model'ldo`name_fl'_* using "log/estimates/other_pol_v20_y`yr'3`panel_sep1'`model'l"
                }
            }
        foreach panel_sep2 in all id_ht id_nh1 { // sexual orientation

            // parameters
            {
                if `flavor'==0 {
                    local t_keep_main0 ends_tax_nom35_scale 
                    local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                    local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                    local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                    local t_keep_main1 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape

                    local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                    local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""
                }
                if `flavor'==1 {
                    local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban

                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""
                }

                if `flavor'==0 local t_refcat_var ends_tax_nom35_scale
                if `flavor'==1 local t_refcat_var flavor_ban

                // first panel
                if "`panel_sep1'"=="st" & "`panel_sep2'"=="all" {
                    local t_nonum
                    local t_mtitles "mtitles("Current Cigarette Smoking" "Frequent Cigarette Smoking" "Everyday Cigarette Smoking" "Current Cig/Cigar Smoking" "Frequent Cig/Cigar Smoking" "Everyday Cig/Cigar Smoking")"
                    
                    local t_repapp  replace
                }
                // not first panel
                else {
                    local t_nonum   nonum
                    local t_mtitles nomtitle

                    local t_repapp append
                }

                if "`panel_sep2'"=="all" {
                    local t_refcat "`t_name_ps1', All Conditional on Sex-ID"
                }
                if "`panel_sep2'"=="id_ht" {
                    local t_refcat "`t_name_ps1', Heterosexual"
                }
                if "`panel_sep2'"=="id_nh1" {
                    local t_refcat "`t_name_ps1', LGBQ"
                }
            }

            esttab ///
            smoke_`model'`t_l'_`panel_sep2'y`yr'3_`panel_sep1'   fsmoke_`model'`t_l'_`panel_sep2'y`yr'3_`panel_sep1'   dsmoke_`model'`t_l'_`panel_sep2'y`yr'3_`panel_sep1' ///
            combust_`model'`t_l'_`panel_sep2'y`yr'3_`panel_sep1' fcombust_`model'`t_l'_`panel_sep2'y`yr'3_`panel_sep1' dcombust_`model'`t_l'_`panel_sep2'y`yr'3_`panel_sep1' ///
            using "output/etax/figures/final/combustible_v1_y`yr'_m`model'_`flavor'.rtf", ///
            `t_repapp' keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
            `t_nonum' ///
            `t_mtitles' ///
            nonotes ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(4) se(4) $stars stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(6) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
        }

        // test of differences
        esttab ///
        smoke_`model'`t_l'd`t_o'_ally`yr'3_`panel_sep1'   fsmoke_`model'`t_l'd`t_o'_ally`yr'3_`panel_sep1'   dsmoke_`model'`t_l'd`t_o'_ally`yr'3_`panel_sep1' ///
        combust_`model'`t_l'd`t_o'_ally`yr'3_`panel_sep1' fcombust_`model'`t_l'd`t_o'_ally`yr'3_`panel_sep1' dcombust_`model'`t_l'd`t_o'_ally`yr'3_`panel_sep1' ///
        using "output/etax/figures/final/combustible_v1_y`yr'_m`model'_`flavor'.rtf", ///
        append keep(`t_keep_dif`other_pol'') order(`t_keep_dif`other_pol'') ///
        nonum ///
        nomtitle ///
        `t_notes' ///
        eqlabel(,none) ///
        main(p) b(4) not $stars stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps

        estimates clear
        }
        }
        }
        }
        }
    }

    // regressions: 2015-2023 fully differenced OLS flavor ban regressions
    if 1 {
        global dem_control i.sex i.grade i.age i.race4
        // state yrbs, model 3
        foreach var of varlist smoke fsmoke dsmoke combust fcombust dcombust {
            // model 3
            _eststo `var'_3d_ally53_st: ///
            reghdfe `var' ///
            lgbq_1##( ///
            ${vars_essential_coef1} ${vars_essential_coef0} ///
            ${vars_lasso_sel_`var'y5} ///
            c.tally_sexualorientation ///
            ${dem_control}) /// 
            if !mi(lgbq_1) & !inlist(fips,6,11,25,41) [aw=aweight], ///
            absorb(fips year_true semester ///
            lgbq_1#fips lgbq_1#year_true lgbq_1#semester) ///
            vce(cluster fips) nosample
        }

        esttab ///
        smoke_3d_ally53_st fsmoke_3d_ally53_st dsmoke_3d_ally53_st ///
        combust_3d_ally53_st fcombust_3d_ally53_st dcombust_3d_ally53_st ///
        using "output/etax/figures/final/combustible_v2_v3_y5_1_ols.rtf", replace keep(1.lgbq_1#c.flavor_ban) ///
        mtitle("Current Cig Smoking" "Frequent Cig Smoking" "Everyday Cig Smoking" "Current Cig/Cigar Smoking" "Frequent Cig/Cigar Smoking" "Everyday Cig/Cigar Smoking") ///
        main(p) b(4) not $stars modelwidth(6) varwidth(15) compress onecell nogaps
    }

    // v2: (v1), main cigarette table with fewer estimates
    if 1 {
        set matsize 5000

        eststo clear

        forval flavor=0/1 {
            // flavor-specific
            {
                if `flavor'==1 local name_fl 3l // denotes overall flavorban estimates in "other_pol.sters"
                else           local name_fl
            }
        foreach yr in 1 5 {
        estimates clear

        foreach model_lin in ols logit {
            if `flavor'==1 & `yr'==5 & "`model_lin'"=="ols" continue // need to estimate these
        forval other_pol = 1/1 { // ends taxes, other policies 
            if `flavor'==1 & `other_pol'!=1 continue
        foreach panel_sep1 in st /*com com_ols*/ { // state, combined yrbs
            // panel sep1-specifics
            {
                if "`panel_sep1'"=="st"      local t_name_ps1 "State YRBS"
                if "`panel_sep1'"=="com"     local t_name_ps1 "Combined YRBS"
                if "`panel_sep1'"=="com_ols" local t_name_ps1 "Combined YRBS, OLS"
            }

            local t_notes notes

            if "`model_lin'"=="ols" {
                local t_l
                local t_o
                if `flavor'==1 local t_o o
            }
            if "`model_lin'"=="logit" {
                local t_l l
                local t_o o
            }
            forval model = 1/3 { // pull estimates
                if `flavor'==0 {
                    estread smoke_`model'`t_l'`name_fl'_*  fsmoke_`model'`t_l'`name_fl'_* dsmoke_`model'`t_l'`name_fl'_*  using "log/estimates/main_y`yr'3`panel_sep1'`model'`t_l'"
                    estread smoke_`model'`t_l'd`t_o'`name_fl'_* fsmoke_`model'`t_l'd`t_o'`name_fl'_* dsmoke_`model'`t_l'd`t_o'`name_fl'_* using "log/estimates/main_y`yr'3`panel_sep1'`model'`t_l'"
                }
                if `flavor'==1 {
                    estread smoke_`model'`t_l'`name_fl'_*  fsmoke_`model'`t_l'`name_fl'_* dsmoke_`model'`t_l'`name_fl'_*  using "log/estimates/other_pol_v20_y`yr'3`panel_sep1'`model'`t_l'"
                    estread smoke_`model'`t_l'd`t_o'`name_fl'_* fsmoke_`model'`t_l'd`t_o'`name_fl'_* dsmoke_`model'`t_l'd`t_o'`name_fl'_* using "log/estimates/other_pol_v20_y`yr'3`panel_sep1'`model'`t_l'"
                }
            }

            if "`panel_sep1'"=="com_ols" {
                local panel_sep1 com
                local t_notes notes // last panel
            }
            else {
                *local t_notes nonotes // not last panel
            }
        foreach panel_sep2 in all id_ht id_nh1 { // sexual orientation

            // parameters
            {
                if `flavor'==0 {
                    local t_keep_main0 ends_tax_nom35_scale 
                    local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                    local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                    local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                    local t_keep_main1 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape

                    local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                    local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""
                
                    local t_refcat_var ends_tax_nom35_scale
                }
                if `flavor'==1 {
                    local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban

                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""

                    local t_refcat_var flavor_ban
                }

                // first panel
                if "`panel_sep1'"=="st" & "`panel_sep2'"=="all" {
                    local t_nonum
                    local t_mtitles "mtitles("Current Cigarette Smoking" "Current Cigarette Smoking" "Current Cigarette Smoking" "Frequent Cigarette Smoking" "Frequent Cigarette Smoking" "Frequent Cigarette Smoking" "Everyday Cigarette Smoking" "Everyday Cigarette Smoking" "Everyday Cigarette Smoking")"
                    if `flavor'==1 & `yr'==5 local t_mtitles "mtitles("Current Cigarette Smoking" "Frequent Cigarette Smoking" "Everyday Cigarette Smoking")"

                    local t_repapp  replace
                }
                // not first panel
                else {
                    local t_nonum   nonum
                    local t_mtitles nomtitle

                    local t_repapp append
                }

                if "`panel_sep2'"=="all" {
                    local t_refcat "`t_name_ps1', All Conditional on Sex-ID"
                }
                if "`panel_sep2'"=="id_ht" {
                    local t_refcat "`t_name_ps1', Heterosexual"
                }
                if "`panel_sep2'"=="id_nh1" {
                    local t_refcat "`t_name_ps1', LGBQ"
                }

                local t_estlist ///
                smoke_1`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1'  smoke_2`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1'  smoke_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' ///
                fsmoke_1`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' fsmoke_2`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' fsmoke_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' ///
                dsmoke_1`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' dsmoke_2`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' dsmoke_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1'
            
                local t_estlist_dif ///
                smoke_1`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'  smoke_2`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'  smoke_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'    ///
                fsmoke_1`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' fsmoke_2`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' fsmoke_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' ///
                dsmoke_1`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' dsmoke_2`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' dsmoke_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'
                
                if `flavor'==1 & `yr'==5 {
                    local t_estlist ///
                    smoke_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' ///
                    fsmoke_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' ///
                    dsmoke_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1'
                
                    local t_estlist_dif ///
                    smoke_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'    ///
                    fsmoke_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' ///
                    dsmoke_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'
                }
            }

            esttab ///
            `t_estlist' ///
            using "output/etax/figures/final/combustible_v2_y`yr'_`flavor'_`model_lin'.rtf", ///
            `t_repapp' keep(`t_keep_main`other_pol'') ///
            `t_nonum' ///
            `t_mtitles' ///
            nonotes ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(4) se(4) $stars stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(6) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
        }

        // test of differences
        esttab ///
        `t_estlist_dif' ///
        using "output/etax/figures/final/combustible_v2_y`yr'_`flavor'_`model_lin'.rtf", ///
        append keep(`t_keep_dif`other_pol'') ///
        nonum ///
        nomtitle ///
        `t_notes' ///
        eqlabel(,none) ///
        main(p) b(4) not $stars stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps

        estimates clear
        }
        }
        }
        }
        }
    }

    // v3: (v2), cigarette or cigar smoking
    if 1 {
        set matsize 5000

        eststo clear

        forval flavor=0/1 {
            // flavor-specific
            {
                if `flavor'==1 local name_fl 3l // denotes overall flavorban estimates in "other_pol.sters"
                else           local name_fl
            }
        foreach yr in 1 5 {
        estimates clear

        foreach model_lin in ols logit {
            if `flavor'==1 & `yr'==5 & "`model_lin'"=="ols" continue
        forval other_pol = 1/1 { // ends taxes, other policies 
        foreach panel_sep1 in st /*com com_ols*/ { // state, combined yrbs
            // panel sep1-specifics
            {
                if "`panel_sep1'"=="st"      local t_name_ps1 "State YRBS"
                if "`panel_sep1'"=="com"     local t_name_ps1 "Combined YRBS"
                if "`panel_sep1'"=="com_ols" local t_name_ps1 "Combined YRBS, OLS"
            }

            local t_notes notes

            if "`model_lin'"=="ols" {
                local t_l
                local t_o
                if `flavor'==1 local t_o o
            }
            if "`model_lin'"=="logit" {
                local t_l l
                local t_o o
            }
            forval model = 1/3 { // pull estimates
                if `flavor'==0 {
                    estread combust_`model'`t_l'`name_fl'_*  fcombust_`model'`t_l'`name_fl'_* dcombust_`model'`t_l'`name_fl'_*  using "log/estimates/main_y`yr'3`panel_sep1'`model'`t_l'"
                    estread combust_`model'`t_l'd`t_o'`name_fl'_* fcombust_`model'`t_l'd`t_o'`name_fl'_* dcombust_`model'`t_l'd`t_o'`name_fl'_* using "log/estimates/main_y`yr'3`panel_sep1'`model'`t_l'"
                }
                if `flavor'==1 {
                    estread combust_`model'`t_l'`name_fl'_*  fcombust_`model'`t_l'`name_fl'_* dcombust_`model'`t_l'`name_fl'_*  using "log/estimates/other_pol_v20_y`yr'3`panel_sep1'`model'`t_l'"
                    estread combust_`model'`t_l'd`t_o'`name_fl'_* fcombust_`model'`t_l'd`t_o'`name_fl'_* dcombust_`model'`t_l'd`t_o'`name_fl'_* using "log/estimates/other_pol_v20_y`yr'3`panel_sep1'`model'`t_l'"
                }
            }

            if "`panel_sep1'"=="com_ols" {
                local panel_sep1 com
                local t_notes notes // last panel
            }
            else {
                *local t_notes nonotes // not last panel
            }
        foreach panel_sep2 in all id_ht id_nh1 { // sexual orientation

            // parameters
            {
                if `flavor'==0 {
                    local t_keep_main0 ends_tax_nom35_scale 
                    local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                    local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                    local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                    local t_keep_main1 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape

                    local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                    local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""
                
                    local t_refcat_var ends_tax_nom35_scale
                }
                if `flavor'==1 {
                    local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban

                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""

                    local t_refcat_var flavor_ban
                }

                // first panel
                if "`panel_sep1'"=="st" & "`panel_sep2'"=="all" {
                    local t_nonum
                    local t_mtitles "mtitles("Current Cig/Cigar Smoking" "Current Cig/Cigar Smoking" "Current Cig/Cigar Smoking" "Frequent Cig/Cigar Smoking" "Frequent Cig/Cigar Smoking" "Frequent Cig/Cigar Smoking" "Everyday Cig/Cigar Smoking" "Everyday Cig/Cigar Smoking" "Everyday Cig/Cigar Smoking")"
                    if `flavor'==1 & `yr'==5 local t_mtitles "mtitles("Current Cig/Cigar Smoking" "Frequent Cig/Cigar Smoking" "Everyday Cig/Cigar Smoking")"

                    local t_repapp  replace
                }
                // not first panel
                else {
                    local t_nonum   nonum
                    local t_mtitles nomtitle

                    local t_repapp append
                }

                if "`panel_sep2'"=="all" {
                    local t_refcat "`t_name_ps1', All Conditional on Sex-ID"
                }
                if "`panel_sep2'"=="id_ht" {
                    local t_refcat "`t_name_ps1', Heterosexual"
                }
                if "`panel_sep2'"=="id_nh1" {
                    local t_refcat "`t_name_ps1', LGBQ"
                }

                local t_estlist ///
                combust_1`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1'  combust_2`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1'  combust_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' ///
                fcombust_1`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' fcombust_2`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' fcombust_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' ///
                dcombust_1`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' dcombust_2`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' dcombust_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1'

                local t_estlist_dif ///
                combust_1`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'  combust_2`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'  combust_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'    ///
                fcombust_1`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' fcombust_2`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' fcombust_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' ///
                dcombust_1`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' dcombust_2`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' dcombust_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' 

                if `flavor'==1 & `yr'==5 {
                    local t_estlist ///
                    combust_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' ///
                    fcombust_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1' ///
                    dcombust_3`t_l'`name_fl'_`panel_sep2'y`yr'3_`panel_sep1'
                    
                    local t_estlist_dif ///
                    combust_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'  ///
                    fcombust_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1' ///
                    dcombust_3`t_l'd`t_o'`name_fl'_ally`yr'3_`panel_sep1'
                }
            }

            esttab ///
            `t_estlist' ///
            using "output/etax/figures/final/combustible_v3_y`yr'_`flavor'_`model_lin'.rtf", ///
            `t_repapp' keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
            `t_nonum' ///
            `t_mtitles' ///
            nonotes ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(4) se(4) $stars stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(6) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
        }

        // test of differences
        esttab ///
        `t_estlist_dif' ///
        using "output/etax/figures/final/combustible_v3_y`yr'_`flavor'_`model_lin'.rtf", ///
        append keep(`t_keep_dif`other_pol'') order(`t_keep_dif`other_pol'') ///
        nonum ///
        nomtitle ///
        `t_notes' ///
        eqlabel(,none) ///
        main(p) b(4) not $stars stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps

        estimates clear
        }
        }
        }
        }
        }
    }
}

// mental health mechanisms
if 1 {
    // v4: sadness, bullying, suicidal ideation for current ENDS use and current cigarette smoking
    if 1 {
        // extra regressions to replace (smoke,nh_naf4) regs
        if 1 {
            // use 'difficult' option
            {
                // regressions
                {
                    // try 'difficult' for current cig smoking regs with lgbq not sad, not bullied, and not suicidal sample; fully differenced sample
                    gen     aff_mh4 = .
                    replace aff_mh4 = 1 if (bullied==1)|(sad==1)|(s_ideation==1)
                    replace aff_mh4 = 0 if (bullied==0)&(sad==0)&(s_ideation==0)

                    eststo clear
                    estimates clear

                    global dem_control i.sex i.grade i.age i.race4

                    forval flavor=0/1 {
                        // flavor-specifics
                        {
                            if `flavor'==0 {
                                local name_flavor
                                local sample_flavor 1
                                local vars_margins ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                            }
                            if `flavor'==1 {
                                local name_flavor 1
                                local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR
                                local vars_margins flavor_ban
                            }
                        }
                        // tester on vape, lgbq, model 3
                        if `flavor'==0 {
                        logit vape ///
                        ${vars_essential_coef1} ${vars_essential_coef0} ///
                        ${vars_lasso_sel_vape} ///
                        tally_sexualorientation ///
                        ${dem_control} ///
                        i.fips i.year_true i.semester ///
                        if (lgbq_1==1)&(aff_mh4==0) & `sample_flavor' & inrange(year,2015,2023) [pw=aweight], ///
                        vce(cluster fips) iterate(15)
                        scalar converge_pre = e(converged)	

                        _eststo vape_nh_naf4y5_m3`name_flavor'_test: ///
                        margins, dydx(`vars_margins') post
                        estadd scalar converge = converge_pre
                        }

                        // smoke, lgbq, model 3
                        logit smoke ///
                        ${vars_essential_coef1} ${vars_essential_coef0} ///
                        ${vars_lasso_sel_smokey1} ///
                        tally_sexualorientation ///
                        ${dem_control} ///
                        i.fips i.year_true i.semester ///
                        if (lgbq_1==1)&(aff_mh4==0) & `sample_flavor' & inrange(year,2011,2023) [pw=aweight], ///
                        vce(cluster fips) iterate(15) difficult
                        scalar converge_pre = e(converged)	

                        _eststo smoke_nh_naf4y1_m3`name_flavor': ///
                        margins, dydx(`vars_margins') post
                        estadd scalar converge = converge_pre

                        if `flavor'==1 { // fully diff for flavor lgbq
                            _eststo smoke_id_nh1y1_m3`name_flavor'_af4: ///
                            logit smoke ///
                            aff_mh4##( ///
                            ${vars_essential_coef1} ${vars_essential_coef0} ///
                            ${vars_lasso_sel_smokey1} ///
                            c.tally_sexualorientation ///
                            ${dem_control} ///
                            i.fips i.year_true i.semester) ///
                            if lgbq_1==1 & `sample_flavor' & inrange(year,2011,2023) [pw=aweight], ///
                            vce(cluster fips) iterate(15) difficult
                            estadd scalar converge = e(converged)
                        }
                    }
                    // partially worked, only not on fully diff flavor ban

                    estwrite _all using "log/estimates/logit_difficult_mh", append
                }

                // table
                {
                    estimates clear
                    eststo clear

                    estread _all using "log/estimates/logit_difficult_mh"

                    esttab vape_nh_naf4y5_m3_test smoke_nh_naf4y1_m3 smoke_nh_naf4y1_m31 ///
                    using "output/etax/figures/final/mental_health_l_v4_difficult.rtf", replace ///
                    b(3) se(3) $stars stats(N converge) mtitle("vape test" "current smoke" "current smoke") ///
                    onecell nogaps compress
                    esttab smoke_id_nh1y1_m31_af4 ///
                    using "output/etax/figures/final/mental_health_l_v4_difficult.rtf", append ///
                    b(3) se(3) $stars stats(N converge) keep(1.aff_mh4#c.flavor_ban) mtitle("current smoke") ///
                    onecell nogaps compress
                }
            }

            // use OLS for flavor ban lgbq current smoking
            {
                // regression
                {
                    cap drop aff_mh4
                    gen      aff_mh4 = .
                    replace  aff_mh4 = 1 if (bullied==1)|(sad==1)|(s_ideation==1)
                    replace  aff_mh4 = 0 if (bullied==0)&(sad==0)&(s_ideation==0)

                    eststo clear
                    estimates clear

                    global dem_control i.sex i.grade i.age i.race4

                    forval flavor=1/1 {
                        // flavor-specifics
                        {
                            if `flavor'==1 {
                                local name_flavor 1
                                local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR
                                local vars_margins flavor_ban
                            }
                        }
                        // tester on vape, lgbq, model 3
                        logit vape ///
                        ${vars_essential_coef1} ${vars_essential_coef0} ///
                        ${vars_lasso_sel_vape} ///
                        tally_sexualorientation ///
                        ${dem_control} ///
                        i.fips i.year_true i.semester ///
                        if (lgbq_1==1)&(aff_mh4==0) & `sample_flavor' & inrange(year,2015,2023) [pw=aweight], ///
                        vce(cluster fips) iterate(15)
                        scalar converge_pre = e(converged)	

                        _eststo vape_nh_naf4y5_m3`name_flavor'_test: ///
                        margins, dydx(`vars_margins') post
                        estadd scalar converge = converge_pre
                        

                        if `flavor'==1 { 
                            // flavor ban fully dif lgbq
                            _eststo smoke_id_nh1y1_m3`name_flavor'_af4_o: ///
                            reghdfe smoke ///
                            aff_mh4##( ///
                            ${vars_essential_coef1} ${vars_essential_coef0} ///
                            ${vars_lasso_sel_smokey1} ///
                            c.tally_sexualorientation ///
                            ${dem_control}) ///
                            if lgbq_1==1 & `sample_flavor' & inrange(year,2011,2023) [aw=aweight], ///
                            absorb(fips year_true semester ///
                            aff_mh4#fips aff_mh4#year_true aff_mh4#semester) ///
                            vce(cluster fips)

                            // lgbq sad
                            _eststo smoke_nh_af4y1_m3`name_flavor'_test: ///
                            reghdfe smoke ///
                            ${vars_essential_coef1} ${vars_essential_coef0} ///
                            ${vars_lasso_sel_smokey1} ///
                            c.tally_sexualorientation ///
                            ${dem_control} ///
                            if (lgbq_1==1)&(aff_mh4==1) & `sample_flavor' & inrange(year,2011,2023) [aw=aweight], ///
                            absorb(fips year_true semester) ///
                            vce(cluster fips)

                            // lgbq not sad
                            _eststo smoke_nh_naf4y1_m3`name_flavor'_test: ///
                            reghdfe smoke ///
                            ${vars_essential_coef1} ${vars_essential_coef0} ///
                            ${vars_lasso_sel_smokey1} ///
                            c.tally_sexualorientation ///
                            ${dem_control} ///
                            if (lgbq_1==1)&(aff_mh4==0) & `sample_flavor' & inrange(year,2011,2023) [aw=aweight], ///
                            absorb(fips year_true semester) ///
                            vce(cluster fips)
                        }
                    }

                    estwrite _all using "log/estimates/mental_health_ols.sters", append
                }
            }
        }

        eststo    clear
        estimates clear

        estread vape_*af4*_m*  vape_*_m*_af4  using "log/estimates/mental_health_l.sters"
        estread smoke_*af4*_m* smoke_*_m*_af4 using "log/estimates/mental_health_l_smoke.sters"

        forval flavor=0/1 {
            if `flavor'==0 local name_f
            if `flavor'==1 local name_f `flavor'
        foreach var in vape smoke {
            if "`var'"=="vape" local name_y y5
            if "`var'"=="smoke" local name_y y1
        forval model = 3/3 {
        foreach panel in aff_mh4 {

            // parameters
            {
                if "`panel'"=="aff_mh4" {
                    local t_nonum 
                    local t_mgroups "mgroups("LGBQ" "Hetero", pattern(1 0 1 0))"
                    local t_repapp replace
                }
                else {
                    local t_nonum nonum
                    local t_mgroups
                    local t_repapp append
                }

                local t_vwidth varwidth(15)
                local t_mwidth modelwidth(5)
                local t_format compress onecell nogaps ${stars} `t_vwidth' `t_mwidth'

                if `flavor'==0 {
                    local t_coef "coef(ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA")"
                    local t_keep "keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape)"
                }
                if `flavor'==1 {
                    local t_keep  "keep(flavor_ban)"
                    local t_coef "coef(flavor_ban "ENDS Flavor Ban")"
                }
                local t_stats "se(3) b(3) stats(pre_treat_mean N converge, fmt(3 0 0) labels("Pre-treatment Mean" "{\i N}" "Converge"))"
                
                local t_stats_test "main(p) b(4) not stats(N converge, fmt(0 0) labels("{\i N}" "Converge"))"
                
                // panel-specifics
                {
                    if `flavor'==0 {
                        local t_coef_test "coef(1.`panel'#c.ends_tax_nom35_scale "ENDS Tax Test" 1.`panel'#c.cigarette_tax_scale "Cig Tax Test" 1.`panel'#c.any_mlsa_vape "ENDS MLSA Test")"
                        local t_keep_test "keep(1.`panel'#c.ends_tax_nom35_scale 1.`panel'#c.cigarette_tax_scale 1.`panel'#c.any_mlsa_vape)"
                    }
                    if `flavor'==1 {
                        local t_keep_test "keep(1.`panel'#c.flavor_ban)"
                        local t_coef_test "coef(1.`panel'#c.flavor_ban "ENDS Flavor Ban Diff")"
                    }

                    if "`panel'"=="bullied" {
                        local t_name_p b
                        local t_name_ref "Physically Bullied"

                        local t_notes nonotes
                    }
                    if "`panel'"=="e_bullied" {
                        local t_name_p eb
                        local t_name_ref "E-Bullied"
                        
                        local t_notes nonotes
                    }
                    if "`panel'"=="aff_mh_b" {
                        local t_name_p aff
                        local t_name_ref "Bullied (Either) or Sad or Suicide Ideation"

                        local t_notes nonotes
                    }
                    if "`panel'"=="aff_mh" {
                        local t_name_p af2
                        local t_name_ref "Sad or Suicide Ideation"

                        local t_notes nonotes
                    }
                    if "`panel'"=="aff_mh3" {
                        local t_name_p af3
                        local t_name_ref "Sad, Suicide Ideation, Plan, Attempt, or Injury"

                        local t_notes nonotes
                    }
                    if "`panel'"=="aff_mh4" {
                        local t_name_p af4
                        local t_name_ref "Physical Bullying, Sad, or Suicide Ideation"

                        local t_notes notes
                    }
                    if "`panel'"=="aff_mh5" {
                        local t_name_p af5
                        local t_name_ref "Physical Bullying or Suicide Ideation"

                        local t_notes nonotes
                    }
                    if "`panel'"=="aff_mh6" {
                        local t_name_p af6
                        local t_name_ref "Suicide Ideation, Plan, Attempt, Injury"

                        local t_notes nonotes
                    }
                    if "`panel'"=="aff_mh7" {
                        local t_name_p af7
                        local t_name_ref "Physical Bullying or Sad"

                        local t_notes nonotes
                    }
                    if "`panel'"=="aff_mh9" {
                        local t_name_p af9
                        local t_name_ref "2/3: Either Bully, Sad, Suicide Ideation"

                        local t_notes notes
                    }
                }
            }
        
            esttab /// 
            `var'_nh_`t_name_p'`name_y'_m`model'`name_f' `var'_nh_n`t_name_p'`name_y'_m`model'`name_f' `var'_ht_`t_name_p'`name_y'_m`model'`name_f' `var'_ht_n`t_name_p'`name_y'_m`model'`name_f' ///
            using "output/etax/figures/final/mental_health_l_v4_`flavor'_m`model'_`var'.rtf", `t_repapp' ///
            mtitle("`t_name_ref'" "Not `t_name_ref'" "`t_name_ref'" "Not `t_name_ref'") ///
            `t_mgroups' ///
            nonotes ///
            `t_format' `t_nonum' ///
            `t_keep' `t_coef' `t_stats'

            esttab /// test of difference
            `var'_nh`name_y'_m`model'`name_f'_`t_name_p' `var'_nh`name_y'_m`model'`name_f'_`t_name_p' `var'_ht`name_y'_m`model'`name_f'_`t_name_p' `var'_ht`name_y'_m`model'`name_f'_`t_name_p' ///
            using "output/etax/figures/final/mental_health_l_v4_`flavor'_m`model'_`var'.rtf", append ///
            nomtitle ///
            ///
            `t_notes' /// 
            `t_format' nonum ///
            `t_keep_test' `t_coef_test' `t_stats_test' ///
            eqlabels(,none)
        }
        }
        }
        }

        estimates clear
        macro drop _name_y
    }
}

// spatial heterogeneity
if 1 {
    // v1: census region-specific linear time trend; common treated state linear time trend (logit / OLS) 
    {
        set matsize 5000

        eststo clear
        estimates clear

        forval flavor=1/1 {
            // flavor-specific
            {
                if `flavor'==1 {
                    local name_fl 3l // denotes overall flavorban estimates in "other_pol.sters"
                    local t_o o
                }
                else {
                    local name_fl
                    local t_o
                }
            }
        forval spatial=5/6 {
            if `flavor'==0 & `spatial'==6 continue
        foreach reg in logit ols {
            if "`reg'"=="logit" {
                local t_logit l
                local t_logit_o o
            }
            if "`reg'"=="ols"   {
                local t_logit
                local t_logit_o
            }
        forval model = 3/3 {
        foreach var in vape smoke /*cigar*/ {
            if "`var'"=="vape"  {
                local t_title "ENDS"
                local name_y y5
            }
            if "`var'"=="smoke" {
                local t_title "Cigarette"
                local name_y y1
            }
            if "`var'"=="cigar" {
                local t_title "Cigar"
                local name_y y1
            }

            if `flavor'==0 {
                estread `var'_`model'`t_logit'?_*             f`var'_`model'`t_logit'?_*             d`var'_`model'`t_logit'?_*             using "log/estimates/spatial_het_`name_y'3st`model'`t_logit'"
                estread `var'_`model'`t_logit'd`t_logit_o'?_* f`var'_`model'`t_logit'd`t_logit_o'?_* d`var'_`model'`t_logit'd`t_logit_o'?_* using "log/estimates/spatial_het_`name_y'3st`model'`t_logit'"
            }
            if `flavor'==1 {
                estread `var'_`model'`t_logit'`name_fl'_*             f`var'_`model'`t_logit'`name_fl'_*             d`var'_`model'`t_logit'`name_fl'_*             using "log/estimates/other_pol_v25_`name_y'3st`model'`t_logit'"
                estread `var'_`model'`t_logit'd`t_logit_o'`name_fl'_* f`var'_`model'`t_logit'd`t_logit_o'`name_fl'_* d`var'_`model'`t_logit'd`t_logit_o'`name_fl'_* using "log/estimates/other_pol_v25_`name_y'3st`model'`t_logit'"

                if `flavor'==1 & "`reg'"=="ols" local t_logit_o o

                estread `var'_`model'`t_logit'`name_fl'_*             f`var'_`model'`t_logit'`name_fl'_*             d`var'_`model'`t_logit'`name_fl'_*             using "log/estimates/other_pol_v26_`name_y'3st`model'`t_logit'"
                estread `var'_`model'`t_logit'd`t_logit_o'`name_fl'_* f`var'_`model'`t_logit'd`t_logit_o'`name_fl'_* d`var'_`model'`t_logit'd`t_logit_o'`name_fl'_* using "log/estimates/other_pol_v26_`name_y'3st`model'`t_logit'"
            }
        forval other_pol = 1/1 { // deprecated 
        foreach panel in all id_ht id_nh1 {

            di "`flavor', `spatial', `reg', `var', `panel'"

            // parameters
            {
                if `flavor'==0 {
                    local t_keep_main0 ends_tax_nom35_scale 
                    local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                    local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                    local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                    local t_keep_main1 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape

                    local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                    local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""

                    local t_refcat_var ends_tax_nom35_scale
                }
                if `flavor'==1 {
                    local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban

                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""

                    local t_refcat_var flavor_ban
                }

                if "`panel'"=="all" {
                    local t_nonum
                    local t_mtitles "mtitles("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use" "Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use")"
                    local t_mgroup  "mgroups("Census Region-Specific Linear Time Trend" "Common Treated State Linear Time Trend", pattern(1 0 0 1 0 0))"

                    if `spatial'==6 local t_mgroup_flav "mgroups("Census Region-Specific Linear Time Trend", pattern(1 0 0 1 0 0))"
                    if `spatial'==5 local t_mgroup_flav "mgroups("Common Treated State Linear Time Trend", pattern(1 0 0 1 0 0))"

                    local t_mtitles_flav "mtitles("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use")"

                    
                    local t_repapp  replace

                    local t_refcat "refcat(`t_refcat_var' "All Conditional on Sex-ID", nolabel)"
                }
                else {
                    local t_nonum   nonum
                    local t_mtitles nomtitle
                    local t_mgroup

                    local t_mtitles_flav nomtitle

                    local t_repapp  append
                }
                if "`panel'"=="id_ht" {
                    local t_refcat "refcat(`t_refcat_var' "Heterosexual", nolabel)"
                }
                if "`panel'"=="id_nh1" {
                    local t_refcat "refcat(`t_refcat_var' "LGBQ", nolabel)"
                }
            }

            if `flavor'==0 {
                esttab ///
                `var'_`model'`t_logit'6_`panel'`name_y'3_st f`var'_`model'`t_logit'6_`panel'`name_y'3_st d`var'_`model'`t_logit'6_`panel'`name_y'3_st ///
                `var'_`model'`t_logit'5_`panel'`name_y'3_st f`var'_`model'`t_logit'5_`panel'`name_y'3_st d`var'_`model'`t_logit'5_`panel'`name_y'3_st ///
                using "output/etax/figures/final/spatial_het_v1_`flavor'_m`model'`t_logit'_`var'_`other_pol'.rtf", ///
                `t_repapp' keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
                `t_nonum' ///
                `t_mtitles' ///
                `t_mgroup' ///
                `t_refcat' ///
                b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
                modelwidth(6) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
            }
            if `flavor'==1 {
                esttab ///
                `var'_`model'`t_logit'`name_fl'_`panel'`name_y'3_st f`var'_`model'`t_logit'`name_fl'_`panel'`name_y'3_st d`var'_`model'`t_logit'`name_fl'_`panel'`name_y'3_st ///
                using "output/etax/figures/final/spatial_het_v1_`flavor'_`spatial'_m`model'`t_logit'_`var'_`other_pol'.rtf", ///
                `t_repapp' keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
                `t_nonum' ///
                `t_mtitles_flav' ///
                `t_mgroup_flav' ///
                `t_refcat' ///
                b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
                modelwidth(6) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
            }
        }

        // test of differences
        if `flavor'==0 {
            esttab ///
            `var'_`model'`t_logit'd`t_logit_o'6_all`name_y'3_st f`var'_`model'`t_logit'd`t_logit_o'6_all`name_y'3_st d`var'_`model'`t_logit'd`t_logit_o'6_all`name_y'3_st ///
            `var'_`model'`t_logit'd`t_logit_o'5_all`name_y'3_st f`var'_`model'`t_logit'd`t_logit_o'5_all`name_y'3_st d`var'_`model'`t_logit'd`t_logit_o'5_all`name_y'3_st ///
            using "output/etax/figures/final/spatial_het_v1_`flavor'_m`model'`t_logit'_`var'_`other_pol'.rtf", ///
            append keep(`t_keep_dif`other_pol'') order(`t_keep_dif`other_pol'') ///
            nonum ///
            nomtitle ///
            main(p) b(3) not $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(6) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps
        }
        if `flavor'==1 {
            esttab ///
            `var'_`model'`t_logit'd`t_logit_o'`name_fl'_all`name_y'3_st f`var'_`model'`t_logit'd`t_logit_o'`name_fl'_all`name_y'3_st d`var'_`model'`t_logit'd`t_logit_o'`name_fl'_all`name_y'3_st ///
            using "output/etax/figures/final/spatial_het_v1_`flavor'_`spatial'_m`model'`t_logit'_`var'_`other_pol'.rtf", ///
            append keep(`t_keep_dif`other_pol'') order(`t_keep_dif`other_pol'') ///
            nonum ///
            nomtitle ///
            main(p) b(3) not $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(6) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps    
        }
        }
        estimates clear
        }
        }
        }
        }
        }
    }
}

// other policies (baseline model)
if 1 {
    // v1: essential + {ecigban,ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke}
    {
        eststo clear
        estimates clear

        // estimation:
        if 0 {
            // essential controls (essential + {ecigban,ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke})
            {
                local vars_essential_coef1 ///
                c.ends_tax_nom35_scale c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ///
                i.ecigban c.ecigs_lis_law_any c.indoor_ban_vape c.indoor_ban_smoke
            }

            use "data/final/master_set_2023", clear

            keep if !national
            keep if inrange(year,2015,2023)

            foreach subsample in !mi(lgbq_1) lgbq_1==0 lgbq_1==1 {
                // subsample-specifics
                {
                    if "`subsample'"=="!mi(lgbq_1)" local name_sample all
                    if "`subsample'"=="lgbq_1==0"   local name_sample id_ht
                    if "`subsample'"=="lgbq_1==1"   local name_sample id_nh1
                }
            foreach var of varlist vape fvape dvape {
                summarize `var' ///
                if pre_etax_intro == 1 & !mi(pre_etax_intro) & `subsample' ///
                [aw=aweight], meanonly
                scalar pre_treat_mean = r(mean)

                // logit
                logit `var' ///
                `vars_essential_coef1' ${vars_essential_coef0} ///
                ${dem_control} ///
                i.fips i.year_true i.semester ///
                if `subsample' [pw=aweight], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	
                matrix A            = e(converged)

                _eststo `var'_1l_`name_sample': ///
                margins, dydx(`vars_essential_coef1') post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre
                estadd matrix A

                if "`subsample'"=="!mi(lgbq_1)" {
                    _eststo `var'_1ldo_`name_sample': ///
                    logit `var' ///
                    lgbq_1##( ///
                    `vars_essential_coef1' ${vars_essential_coef0} ///
                    ${dem_control} ///
                    i.fips i.year_true i.semester) ///
                    if `subsample' [pw=aweight], ///
                    vce(cluster fips) iterate(15)

                    estadd scalar converge = e(converged)	
                    estadd matrix A        = e(converged)
                }
            }
            }

            estwrite _all using "log/estimates/other_pol.sters", replace
            estimates clear
        }

        // table
        {
            estread _all using "log/estimates/other_pol.sters"

            // v1:
            {
                set matsize 5000

                foreach var in vape {
                foreach panel in all id_ht id_nh1 {
                    // parameters
                    {
                        local t_keep_main1 ends_tax_nom35_scale flavor_ban any_mlsa_vape 1.t21 cigarette_tax_scale ///
                        1.ecigban ecigs_lis_law_any indoor_ban_vape indoor_ban_smoke
                        local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.flavor_ban 1.lgbq_1#c.any_mlsa_vape 1.lgbq_1#1.t21 1.lgbq_1#c.cigarette_tax_scale ///
                        1.lgbq_1#1.ecigban 1.lgbq_1#c.ecigs_lis_law_any 1.lgbq_1#c.indoor_ban_vape 1.lgbq_1#c.indoor_ban_smoke

                        local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" flavor_ban "ENDS Flavor Ban" any_mlsa_vape "ENDS MLSA" 1.t21 "Tobacco-21 Law" cigarette_tax_scale "Cig Tax ($2023)" 1.ecigban "ENDS Online Sales Bans" ecigs_lis_law_any "ENDS Licensure Laws" indoor_ban_vape "Indoor Vaping Restrictions" indoor_ban_smoke "Indoor Smoking Restrictions""
                        local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "Test ENDS Tax" 1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff" 1.lgbq_1#1.t21 "Tobacco-21 Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#1.ecigban "ENDS Online Sales Ban Diff" 1.lgbq_1#c.ecigs_lis_law_any "ENDS Licensure Diff" 1.lgbq_1#c.indoor_ban_vape "Indoor Vaping Restriction Test" 1.lgbq_1#c.indoor_ban_smoke "Indoor Smoking Restriction Test""

                        if "`panel'"=="all" {
                            local t_nonum
                            local t_mtitles "mtitles("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use")"
                            
                            local t_repapp  replace

                            local t_refcat "All Conditional on Sex-ID"
                        }
                        else {
                            local t_nonum   nonum
                            local t_mtitles nomtitle

                            local t_repapp  append
                        }
                        if "`panel'"=="id_ht" {
                            local t_refcat "Heterosexual"
                        }
                        if "`panel'"=="id_nh1" {
                            local t_refcat "LGBQ"
                        }
                    }

                    esttab ///
                    `var'_1l_`panel' f`var'_1l_`panel' d`var'_1l_`panel' ///
                    using "output/etax/figures/final/other_pol_v1_m1l_`var'.rtf", ///
                    `t_repapp' keep(`t_keep_main1') ///
                    `t_nonum' ///
                    `t_mtitles' ///
                    refcat(ends_tax_nom35_scale "`t_refcat'", nolabel) ///
                    b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
                    modelwidth(10) varwidth(15) coef(`t_coef_main1') compress onecell nogaps
                }

                // test of diff
                esttab ///
                `var'_1ldo_all f`var'_1ldo_all d`var'_1ldo_all ///
                using "output/etax/figures/final/other_pol_v1_m1l_`var'.rtf", ///
                append keep(`t_keep_dif1') ///
                nonum ///
                nomtitle ///
                main(p) b(3) not $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
                modelwidth(10) varwidth(15) coef(`t_coef_dif1') compress onecell nogaps
                }
            }
        }

        macro drop _s_name
    }

    // v2: flavor ban, T21 sample restrictions
    {
        set matsize 5000

        forval model = 1/3 {
            estread ///
            vape_*l*_*all*   vape_*l*_*id_ht*  vape_*l*_*id_nh1* ///
            fvape_*l*_*all* fvape_*l*_*id_ht* fvape_*l*_*id_nh1* ///
            dvape_*l*_*all* dvape_*l*_*id_ht* dvape_*l*_*id_nh1* ///
            using "log/estimates/other_pol_v2_y53st`model'l"
        foreach var in vape {
        forval ind_var = 1/2 { // flavor ban, T21
        forval lags = 0/1 {
        forval avg  = 0/1 {
            // skip lags for T21
            if `ind_var'==2 & `lags'==1 continue
            // skip avg for flavor
            if `ind_var'==1 & `avg'==1 continue

            if `lags'==1 local t_lag l
            else         local t_lag

            if `avg'==1 local t_avg a
            else        local t_avg 
            
        foreach panel in all id_ht id_nh1 {
            // parameters
            {
                if `ind_var'==1 {
                    local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban
                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""
                }
                if `ind_var'==2 {
                    local t_keep_main1 1.t21
                    local t_keep_dif1  1.lgbq_1#1.t21
                    local t_coef_main1 "1.t21 "Tobacco-21 Law""
                    local t_coef_dif1  "1.lgbq_1#1.t21 "Tobacco-21 Diff""
                }
                if `lags'==1 {
                    local t_keep_main1 flav_lag0_1 flav_lag2_plus
                    local t_keep_dif1  1.lgbq_1#c.flav_lag0_1 1.lgbq_1#c.flav_lag2_plus
                    local t_coef_main1 "flav_lag0_1 "ENDS Flavor Ban 0-1 Years" flav_lag2_plus "ENDS Flavor Ban 2+ Years""
                    local t_coef_dif1  "1.lgbq_1#c.flav_lag0_1 "ENDS Flavor Ban 0-1 Year Diff" 1.lgbq_1#c.flav_lag2_plus "ENDS Flavor Ban 2+ Year Diff""
                }
                if `avg'==1 {
                    local t_keep_main1 t21_avg
                    local t_keep_dif1  1.lgbq_1#c.t21_avg
                    local t_coef_main1 "t21_avg "Tobacco-21 Law""
                    local t_coef_dif1  "1.lgbq_1#c.t21_avg "Tobacco-21 Diff""
                }

                local t_refcat_var: word 1 of `t_keep_main1'
                
                if `ind_var'==1 & "`panel'"=="all" {
                    local t_nonum
                    local t_mtitles "mtitles("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use")"
                    
                    local t_repapp  replace
                }
                else {
                    local t_nonum   nonum
                    local t_mtitles nomtitle

                    local t_repapp  append
                }

                if "`panel'"=="all" {
                    local t_refcat "All Conditional on Sex-ID"
                }
                if "`panel'"=="id_ht" {
                    local t_refcat "Heterosexual"
                }
                if "`panel'"=="id_nh1" {
                    local t_refcat "LGBQ"
                }
            }

            esttab ///
            `var'_`model'l`ind_var'`t_lag'`t_avg'_`panel'y53_st f`var'_`model'l`ind_var'`t_lag'`t_avg'_`panel'y53_st d`var'_`model'l`ind_var'`t_lag'`t_avg'_`panel'y53_st ///
            using "output/etax/figures/final/other_pol_v2_m`model'`t_lag'`t_avg'_`var'.rtf", ///
            `t_repapp' keep(`t_keep_main1') ///
            `t_nonum' ///
            `t_mtitles' ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(10) varwidth(15) coef(`t_coef_main1') compress onecell nogaps
        }

        // test of diff
        esttab ///
        `var'_`model'ldo`ind_var'`t_lag'`t_avg'_ally53_st f`var'_`model'ldo`ind_var'`t_lag'`t_avg'_ally53_st d`var'_`model'ldo`ind_var'`t_lag'`t_avg'_ally53_st ///
        using "output/etax/figures/final/other_pol_v2_m`model'`t_lag'`t_avg'_`var'.rtf", ///
        append keep(`t_keep_dif1') ///
        nonum ///
        nomtitle ///
        main(p) b(3) not $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(10) varwidth(15) coef(`t_coef_dif1') compress onecell nogaps eqlabel(,none)
        }
        }
        }
        }
        }
    }
}

// sample selection
if 1 {
    // v1: lgbq_1 identification; 2015-2023, 2011-2023
    {
        eststo clear
        estimates clear
        
        estread _all using "log/estimates/sample_selection.sters"

        // parameters
        {
            local coef1 "coef(ends_tax_nom35_scale "ENDS Tax ($ 2023)" cigarette_tax_scale "Cig Tax ($ 2023)" any_mlsa_vape "MLSA-18 Law")"	
            local coef2 "coef(flavor_ban "ENDS Flavor Ban")"
            local vwidth "varwidth(16)"
            local mwidth "modelwidth(10)"
            local stats "stats(pre_treat_mean N converge, fmt(3 0 0) labels("Pre-treatment Mean" "{\i N}" "Converged"))"
        }

        esttab lgbq_1_1_y5_st lgbq_1_2_y5_st lgbq_1_3_y5_st		///
        using "output/etax/figures/final/sample_selection_v1.rtf", replace 				///
        compress se(3) b(3)  		///
        onecell nogaps keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) ///
        order(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) $stars nonotes `coef1'		///
        `stats' `vwidth' `mwidth' refcat(ends_tax_nom35_scale "Panel I: 2015-2023", nolabel) ///
        mtitle("Model 1" "Model 2" "Model 3")

        esttab lgbq_1_13l_y5_st lgbq_1_23l_y5_st lgbq_1_33l_y5_st		///
        using "output/etax/figures/final/sample_selection_v1.rtf", append 				///
        compress se(3) b(3)  		///
        onecell nogaps keep(flavor_ban) $stars nonotes nonum `coef2'		///
        `stats' `vwidth' `mwidth' ///
        nomtitle

        esttab lgbq_1_1_y1_st lgbq_1_2_y1_st lgbq_1_3_y1_st		///
        using "output/etax/figures/final/sample_selection_v1.rtf", append 				///
        compress se(3) b(3)  		///
        onecell nogaps keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) ///
        order(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) $stars nonotes nonum `coef1'		///
        `stats' `vwidth' `mwidth' refcat(ends_tax_nom35_scale "Panel II: 2011-2023", nolabel) ///
        nomtitle

        esttab lgbq_1_13l_y1_st lgbq_1_23l_y1_st lgbq_1_33l_y1_st		///
        using "output/etax/figures/final/sample_selection_v1.rtf", append 				///
        compress se(3) b(3)  		///
        onecell nogaps keep(flavor_ban) $stars notes nonum `coef2'		///
        `stats' `vwidth' `mwidth' ///
        nomtitle

        estimates clear
    }
}

// unweighted point estimates
if 1 {
    // main ENDS effects
    {
        set matsize 1000

        eststo clear
        estimates clear

        foreach survey in st {
        foreach var in vape {
            if "`var'"=="vape"  local t_title "ENDS"
            if "`var'"=="smoke" local t_title "Cigarette"
            if "`var'"=="cigar" local t_title "Cigar"

            if "`survey'"=="com" & "`var'"!="vape" continue
            
            forval model = 1/3 {
            estread `var'_*l* f`var'_*l* d`var'_*l* using "log/estimates/unweighted_y53`survey'l"
            }

        forval other_pol = /*0/1*/ 0/0 { // ends taxes, other policies 
        foreach panel in all id_ht id_nh1 {

            // parameters
            {
                local t_keep_main0 ends_tax_nom35_scale 
                local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                local t_keep_main1 cigarette_tax_scale flavor_ban 1.t21 any_mlsa_vape
                local t_keep_dif1  1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.flavor_ban 1.lgbq_1#1.t21 1.lgbq_1#c.any_mlsa_vape

                local t_coef_main1 "cigarette_tax_scale "Cig Tax ($2023)" flavor_ban "ENDS Flavor Ban" 1.t21 "Tobacco-21 Law" any_mlsa_vape "ENDS MLSA""
                local t_coef_dif1  "1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff" 1.lgbq_1#1.t21 "Tobacco-21 Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""

                if "`panel'"=="all" {
                    local t_nonum
                    local t_mgroup  "mgroup("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use", pattern(1 0 0 1 0 0 1 0 0))"
                    local t_mtitles "mtitles("Model 1" "Model 2" "Model 3" "Model 1" "Model 2" "Model 3" "Model 1" "Model 2" "Model 3")"
                    
                    local t_repapp  replace

                    local t_refcat "All Conditional on Sex-ID"
                }
                else {
                    local t_nonum   nonum
                    local t_mgroup 
                    local t_mtitles nomtitle

                    local t_repapp  append
                }
                if "`panel'"=="id_ht" {
                    local t_refcat "Heterosexual"
                }
                if "`panel'"=="id_nh1" {
                    local t_refcat "LGBQ"
                }

                if `other_pol'==0 local t_refcat_var ends_tax_nom35_scale`scale_name'
                if `other_pol'==1 local t_refcat_var cigarette_tax_scale
            }

            esttab ///
            `var'_1l_`panel'y53_`survey' `var'_2l_`panel'y53_`survey' `var'_3l_`panel'y53_`survey' ///
            f`var'_1l_`panel'y53_`survey' f`var'_2l_`panel'y53_`survey' f`var'_3l_`panel'y53_`survey' ///
            d`var'_1l_`panel'y53_`survey' d`var'_2l_`panel'y53_`survey' d`var'_3l_`panel'y53_`survey' ///
            using "output/etax/figures/final/unweighted_`survey'_`var'.rtf", ///
            `t_repapp' keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
            `t_nonum' ///
            `t_mgroup'  ///
            `t_mtitles' ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(5) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
        }

        // test of difference

        esttab ///
        `var'_1ldo_ally53_`survey' `var'_2ldo_ally53_`survey' `var'_3ldo_ally53_`survey' ///
        f`var'_1ldo_ally53_`survey' f`var'_2ldo_ally53_`survey' f`var'_3ldo_ally53_`survey' ///
        d`var'_1ldo_ally53_`survey' d`var'_2ldo_ally53_`survey' d`var'_3ldo_ally53_`survey' ///
        using "output/etax/figures/final/unweighted_`survey'_`var'.rtf", ///
        append keep(`t_keep_dif`other_pol'') order(`t_keep_dif`other_pol'') ///
        nonum ///
        nomtitle ///
        main(p) b(3) not $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(5) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps        
        }
        estimates clear
        }
        }
    }

    // v2: present coefficient on Hetero*Tax (only model 3)
    {
        // regs
        {
            eststo    clear
            estimates clear

            foreach i in !national {
                // dataset-specifics
                {
                    if "`i'"=="!national" {
                        local name "st"
                        local weight "aweight"
                        local technical ""
                    }	
                    if "`i'"=="national" {
                        local name "nat"
                        local weight "bweight"
                        local technical ""
                    }	
                    if "`i'"=="1" {
                        local name "com"
                        local weight "cweight"
                        local technical "i.national"
                    }	
                }
            foreach yr in 2015 /*2017*/ {
                // starting year-specifics
                {
                    if "`yr'" == "2011" local yr_name "y1"
                    if "`yr'" == "2015" local yr_name "y5"
                    if "`yr'" == "2017" local yr_name "y7"
                }
            foreach yr_end in 2023 {
                // ending year-specifics
                {
                    if `yr_end' == 2021 {
                        local yr_end_name ""
                        local scale_name  "1"
                    }
                    if `yr_end' == 2023 {
                        local yr_end_name "3"
                        local scale_name  ""
                    }
                }

            use "data/final/master_set_2023", clear

            gen     hetero = .
            replace hetero = 0 if lgbq_1==1
            replace hetero = 1 if lgbq_1==0
            gen endstax_x_hetero = ends_tax_nom35_scale * hetero
            
            keep if `i'	
            keep if inrange(year,`yr',`yr_end')		

            foreach q in 6 { 

                // skip pattern
                {
                    // only all_u,all,id_ht,id_nh1 for combined and national yrbs
                    if inlist("`i'","national","1") & !inlist(`q',5,6,9,10) continue
                }

                local subsample = word("$samples",`q') 
                di "`q' `subsample'"
                // subsample-specifics
                {	
                    if `q' == 1 {
                    local name_sample "r_wh" // race - white, non-hispanic
                    global dem_control i.sex i.grade i.age
                    global dem_control_name *.sex *.grade *.age
                    }
                    if `q' == 2 {
                    local name_sample "r_bl" // race - black
                    global dem_control i.sex i.grade i.age
                    global dem_control_name *.sex *.grade *.age
                    }
                    if `q' == 3 {
                    local name_sample "r_h" // race - hispanic
                    global dem_control i.sex i.grade i.age
                    global dem_control_name *.sex *.grade *.age
                    }
                    if `q' == 4 {
                    local name_sample "r_o" // race - other
                    global dem_control i.sex i.grade i.age
                    global dem_control_name *.sex *.grade *.age
                    }


                    if `q' == 5 {
                    local name_sample "all_u" // all youth, unrestricted/ unconditional on sex id
                    global dem_control i.sex i.grade i.age i.race4
                    global dem_control_name *.sex *.grade *.age *.race4
                    }
                    if `q' == 6 {
                    local name_sample "all" // all youth, not missing sex id info
                    global dem_control i.sex i.grade i.age i.race4
                    global dem_control_name *.sex *.grade *.age *.race4
                    }



                    if `q' == 7 {
                    local name_sample "s_f" // sex-female
                    global dem_control i.grade i.age i.race4
                    global dem_control_name *.grade *.age *.race4
                    }
                    if `q' == 8 {
                    local name_sample "s_m" // sex-male
                    global dem_control i.grade i.age i.race4
                    global dem_control_name *.grade *.age *.race4
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



                    if `q' == 15 {
                    local name_sample "a_18l" // age - less than 18
                    global dem_control i.sex i.grade i.age i.race4
                    global dem_control_name *.sex *.grade *.age *.race4
                    }
                    if `q' == 16 {
                    local name_sample "a_18m" // age - 18 or more
                    global dem_control i.sex i.grade i.age i.race4
                    global dem_control_name *.sex *.grade *.age *.race4
                    }



                    if `q' == 17 {
                    local name_sample "wmh" // white, male, heterosexual
                    global dem_control i.grade i.age 
                    global dem_control_name *.grade *.age 
                    }
                    if `q' == 18 {
                    local name_sample "wml" // white, male, LGBQ
                    global dem_control i.grade i.age 
                    global dem_control_name *.grade *.age 
                    }
                    if `q' == 19 {
                    local name_sample "nwmh" // non-white, male, heterosexual
                    global dem_control i.grade i.age 
                    global dem_control_name *.grade *.age
                    }
                    if `q' == 20 {
                    local name_sample "nwml" // non-white, male, LGBQ
                    global dem_control i.grade i.age 
                    global dem_control_name *.grade *.age 
                    }			
                    if `q' == 21 {
                    local name_sample "wfh" // white, female, heterosexual
                    global dem_control i.grade i.age 
                    global dem_control_name *.grade *.age 
                    }
                    if `q' == 22 {
                    local name_sample "wfl" // white, female, LGBQ
                    global dem_control i.grade i.age 
                    global dem_control_name *.grade *.age 
                    }
                    if `q' == 23 {
                    local name_sample "nwfh" // non-white, female, heterosexual
                    global dem_control i.grade i.age 
                    global dem_control_name *.grade *.age
                    }
                    if `q' == 24 {
                    local name_sample "nwfl" // non-white, female, LGBQ
                    global dem_control i.grade i.age 
                    global dem_control_name *.grade *.age 
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

                foreach var in vape fvape dvape {
                forval model = 2/2 {
                    // LASSO assignment (***)
                    {
                        // vaping vars get specific LASSO controls, other vars get other LASSO controls
                        if inlist("`var'","vape","fvape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'}

                        else ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'`yr_name'}

                        local vars_essential_coef1 /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale
                    }
                    
                    // skip patterns
                    {
                        // only vaping/smoking/combust outcomes for national and combined YRBS
                        ** if !inlist("`var'","vape","fvape","dvape","smoke","fsmoke","dsmoke","combust","fcombust","dcombust") & ("`i'" != "!national") continue

                        // no vaping outcomes pre-2015
                        if inlist("`var'","vape","fvape","dvape") & ("`yr'"=="2011") continue
                    }

                    di "`name' `yr' `name_sample' `var'"

                    summarize `var' ///
                    if pre_etax_intro == 1 & !mi(pre_etax_intro) & `subsample' ///
                    , meanonly
                    scalar pre_treat_mean = r(mean)

                    // logit
                    if `model'==2 {
                        if `q'==6 {
                            // model 3
                            logit `var' ///
                            hetero##( ///
                            `vars_essential_coef1' ${vars_essential_coef0} ///
                            `vars_lasso_sel' ///
                            c.tally_sexualorientation ///
                            ${dem_control} `technical' ///
                            i.fips i.year_true i.semester) /// 
                            ends_tax_nom35_scale endstax_x_hetero ///
                            if `subsample', ///
                            vce(cluster fips) iterate(15)
                            scalar converge_pre = e(converged)

                            _eststo `var'_3ldo_`name_sample'`yr_name'`yr_end_name'_`name': ///
                            margins, dydx(ends_tax_nom35_scale endstax_x_hetero) post

                            estadd scalar converge = converge_pre
                            estadd scalar pre_treat_mean = pre_treat_mean

                            // weighted (for comparison)
                            logit `var' ///
                            hetero##( ///
                            `vars_essential_coef1' ${vars_essential_coef0} ///
                            `vars_lasso_sel' ///
                            c.tally_sexualorientation ///
                            ${dem_control} `technical' ///
                            i.fips i.year_true i.semester) /// 
                            ends_tax_nom35_scale endstax_x_hetero ///
                            if `subsample' [pw=`weight'], ///
                            vce(cluster fips) iterate(15)
                            scalar converge_pre = e(converged)

                            _eststo `var'_3ldow_`name_sample'`yr_name'`yr_end_name'_`name': ///
                            margins, dydx(ends_tax_nom35_scale endstax_x_hetero) post

                            estadd scalar converge = converge_pre
                        }
                    }
                }
                }	

            }
            }
            }
            }
        }

        // table
        {
            set matsize 1000

            foreach survey in st {
            foreach var in vape {
                if "`var'"=="vape"  local t_title "ENDS"
                if "`var'"=="smoke" local t_title "Cigarette"
                if "`var'"=="cigar" local t_title "Cigar"

                if "`survey'"=="com" & "`var'"!="vape" continue
            forval other_pol = /*0/1*/ 0/0 { // ends taxes, other policies 
            foreach panel in all {

                // parameters
                {
                    local t_keep_main0 ends_tax_nom35_scale endstax_x_hetero

                    local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)" endstax_x_hetero "ENDS Tax X Hetero""

                    if "`panel'"=="all" {
                        local t_nonum
                        local t_mgroup  "mgroup("Model 3", pattern(1 0 0))"
                        local t_mtitles "mtitles("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use")"
                        
                        local t_repapp  replace

                        local t_refcat "All Conditional on Sex-ID"
                    }
                    else {
                        local t_nonum   nonum
                        local t_mgroup 
                        local t_mtitles nomtitle

                        local t_repapp  append
                    }

                    if `other_pol'==0 local t_refcat_var ends_tax_nom35_scale
                    if `other_pol'==1 local t_refcat_var cigarette_tax_scale
                }
                
                // unweighted
                esttab ///
                `var'_3ldo_`panel'y53_`survey' ///
                f`var'_3ldo_`panel'y53_`survey' ///
                d`var'_3ldo_`panel'y53_`survey' ///
                using "output/etax/figures/final/unweighted_v2_`survey'_`var'.rtf", ///
                `t_repapp' keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
                `t_nonum' ///
                `t_mgroup'  ///
                `t_mtitles' ///
                refcat(ends_tax_nom35_scale "Unweighted", nolabel) ///
                b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
                modelwidth(5) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps

                // weighted
                esttab ///
                `var'_3ldow_`panel'y53_`survey' ///
                f`var'_3ldow_`panel'y53_`survey' ///
                d`var'_3ldow_`panel'y53_`survey' ///
                using "output/etax/figures/final/unweighted_v2_`survey'_`var'.rtf", ///
                append keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
                nonum ///
                ///
                nomtitle ///
                refcat(ends_tax_nom35_scale "Weighted", nolabel) ///
                b(3) se(3) $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
                modelwidth(5) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
            }
            }
            }
        }
    }
}

// full sample unconditional on sex-id info
if 1 {
    set matsize 1000

    eststo clear
    estimates clear

    if 1 { // regs for full sample frequent cigarette smoking -- use 'difficult' option on logit
        // state yrbs, 2011-2023
        global dem_control i.sex i.grade i.age i.race4
        forval flavor = 0/1 {
            // flavor-specific
            {
                if `flavor'==0 {
                    local sample_flavor 1
                    local vars_margins ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                }
                if `flavor'==1 {
                    local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR
                    local vars_margins flavor_ban
                }
            }

            forval model = 1/3 {
                // model-specific
                {
                    if `model'==1 local vars_controls
                    if `model'==2 local vars_controls ${vars_lasso_sel_fsmokey1}
                    if `model'==3 local vars_controls ${vars_lasso_sel_fsmokey1} tally_sexualorientation
                }
            foreach var of varlist fvape fsmoke {
                if (`flavor'==1|`model'>1) & "`var'"=="fvape" continue // tester on fvape to confirm using identical model

                // model 1
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${dem_control} ///
                `vars_controls' ///
                i.fips i.year_true i.semester ///
                if 1 & `sample_flavor' [pw=aweight], difficult ///
                vce(cluster fips) iterate(15)
                scalar converge_pre = e(converged)	

                _eststo `var'_`model'`flavor'l_all_uy13_st_a: ///
                margins, dydx(`vars_margins') post
                estadd scalar converge = converge_pre

                if "`var'"=="fsmoke" { // tester on 'difficult'
                    *_eststo `var'_`model'`flavor'ldo_ally13_st_a: ///
                }
            }
            }
            estwrite _all using "log/estimates/logit_difficult.sters", append
        }

        esttab ///
        fsmoke_10l_all_uy13_st_a fsmoke_20l_all_uy13_st_a fsmoke_30l_all_uy13_st_a ///
        fsmoke_11l_all_uy13_st_a fsmoke_21l_all_uy13_st_a fsmoke_31l_all_uy13_st_a ///
        using "output/etax/figures/final/pooled_sample_difficult.rtf", replace ///
        mgroups("Frequent Cig Smoking", pattern(1 0 0 0 0 0)) ///
        mtitle("Model 1" "Model 2" "Model 3" "Model 1" "Model 2" "Model 3") b(3) se(3) $stars ///
        varwidth(15) modelwidth(7) compress onecell nogaps 
    }

    // replace full sample frequent cigarette smoking with ", difficult" regressions
    forval flavor=0/1 {
        // flavor-specific
        {
            if `flavor'==0 local name_fl
            if `flavor'==1 local name_fl 3l
        }
    foreach survey in st {
    foreach var in vape smoke {
        // var specific
        {
            if "`var'"=="vape"  {
                local t_title "ENDS"
                local name_y y5
            }
            if "`var'"=="smoke" {
                local t_title "Cigarette"
                local name_y y1
            }
        }

        // skip pattern
        if "`survey'"=="com" & "`var'"!="vape" continue
        
        forval model = 1/3 { // pull estimates
            if `flavor'==0 estread `var'_*l* f`var'_*l* d`var'_*l* using "log/estimates/main_`name_y'3`survey'`model'l"
            if `flavor'==1 estread `var'_*l* f`var'_*l* d`var'_*l* using "log/estimates/other_pol_v20_`name_y'3`survey'`model'l"
        }

    forval other_pol = 1/1 { // ends taxes, other policies 
    foreach panel in all_u all { // replace "all_u" fsmoke regs with "..._a" regs

        // parameters
        {
            if `flavor'==0 {
                local t_keep_main0 ends_tax_nom35_scale 
                local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                local t_keep_main1 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape

                local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""
            }
            if `flavor'==1 {
                local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban

                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""
            }

            if "`panel'"=="all_u" {
                local t_nonum
                local t_mgroup  "mgroup("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use", pattern(1 0 0 1 0 0 1 0 0))"
                local t_mtitles "mtitles("Model 1" "Model 2" "Model 3" "Model 1" "Model 2" "Model 3" "Model 1" "Model 2" "Model 3")"
                
                local t_repapp  replace

                local t_refcat "All, Unconditional on Sex-ID"

                local t_notes nonotes
            }
            if "`panel'"=="all" {
                local t_notes notes

                local t_repapp append
                local t_mtitles nomtitles
                local t_refcat "All, Conditional on Sex-ID"
            }

            if `flavor'==0 local t_refcat_var ends_tax_nom35_scale
            if `flavor'==1 local t_refcat_var flavor_ban
        }

        esttab ///
        `var'_1l`name_fl'_`panel'`name_y'3_`survey' `var'_2l`name_fl'_`panel'`name_y'3_`survey' `var'_3l`name_fl'_`panel'`name_y'3_`survey' ///
        f`var'_1l`name_fl'_`panel'`name_y'3_`survey' f`var'_2l`name_fl'_`panel'`name_y'3_`survey' f`var'_3l`name_fl'_`panel'`name_y'3_`survey' ///
        d`var'_1l`name_fl'_`panel'`name_y'3_`survey' d`var'_2l`name_fl'_`panel'`name_y'3_`survey' d`var'_3l`name_fl'_`panel'`name_y'3_`survey' ///
        using "output/etax/figures/final/pooled_sample_`flavor'_`var'.rtf", ///
        `t_repapp' keep(`t_keep_main`other_pol'') order(`t_keep_main`other_pol'') ///
        `t_nonum' ///
        `t_mgroup'  ///
        `t_mtitles' ///
        refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
        b(3) se(3) $stars `t_notes' stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(5) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
    }
    }
    estimates clear
    }
    }
    }

    macro drop _t_extra
}

// BRFSS main
if 1 {
    // v1: model 1,2,3; vape/smoke; young hetero,young lgbq, older hetero, older lgbq
    if 1 {
        set matsize 5000
        estimates clear	

        forval flavor=0/1 {
            if `flavor'==0 local name_f
            if `flavor'==1 local name_f `flavor'
        forval model_lin = 0/1 {
            if `model_lin'==0 {
                local name_m 
                local name_m_dif o // weird naming structure from before
            }
            if `model_lin'==1 {
                local name_m o
                local name_m_dif
            }
        foreach yr in y4 {
            if "`yr'" == "y4" local y 4
        foreach var in vape smoke {
            // var-specific
            {
                if "`var'"=="vape"  local name_var "ENDS Use"
                if "`var'"=="smoke" local name_var "Cigarette Smoking"
            }
        estread *`var'?`name_f'`name_m'_14_*y4*diw *`var'?`name_f'`name_m'_35_*y4*diw *`var'?d`name_m_dif'`name_f'_14_*y4*diw *`var'?d`name_m_dif'`name_f'_35_*y4*diw ///
        using "log/estimates/brfss_`model_lin'.sters"

        * Set table parameters
        {
            local coef "coef(ends_tax_nom35_scale "ENDS Tax ($ 2023)" cigarette_tax_scale "Cig Tax ($ 2023)" any_mlsa_vape "ENDS MLSA")"	
            local vwidth "varwidth(15)"
            local mwidth "modelwidth(5)"
            local stats "stats(pre_treat_mean N converge, fmt(3 0 0) labels("Pre-treatment Mean" "{\i N}" "Converged"))"
            local stats_test "stats(N converge, fmt(0 0) labels("{\i N}" "Converged"))"

            if `flavor'==0 {
                local t_keep_main ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                local t_keep_dif  1.lgbq#c.ends_tax_nom35_scale 1.lgbq#c.cigarette_tax_scale 1.lgbq#c.any_mlsa_vape

                local t_coef_main "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                local t_coef_dif  "1.lgbq#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq#c.any_mlsa_vape "ENDS MLSA Diff""

                local t_refcat ends_tax_nom35_scale
            }
            if `flavor'==1 {
                local t_keep_main flavor_ban
                local t_keep_dif  1.lgbq#c.flavor_ban

                local t_coef_main "flavor_ban "ENDS Flavor Ban""
                local t_coef_dif  "1.lgbq#c.flavor_ban "ENDS Flavor Ban Diff""

                local t_refcat flavor_ban
            }
        }


        esttab `var'1`name_f'`name_m'_14_id_hty43diw `var'2`name_f'`name_m'_14_id_hty43diw `var'3`name_f'`name_m'_14_id_hty43diw d`var'1`name_f'`name_m'_14_id_hty43diw d`var'2`name_f'`name_m'_14_id_hty43diw d`var'3`name_f'`name_m'_14_id_hty43diw   	///
        using "output/etax/figures/final/brfss_l_v1_`var'_`flavor'_`model_lin'.rtf", replace  				///
        compress se(4) b(4) nonotes `coef'    ///
        onecell nogaps keep(`t_keep_main') order(`t_keep_main') $stars 		///
        `stats' `vwidth' `mwidth' refcat(`t_refcat' "Panel I: Heterosexuals, 18-30", nolabel) ///
        mtitle("Model 1" "Model 2" "Model 3" "Model 1" "Model 2" "Model 3") ///
        mgroups("Current `name_var'" "Daily `name_var'", pattern(1 0 0 1 0 0)) 

        esttab `var'1`name_f'`name_m'_14_id_nh1y43diw `var'2`name_f'`name_m'_14_id_nh1y43diw `var'3`name_f'`name_m'_14_id_nh1y43diw d`var'1`name_f'`name_m'_14_id_nh1y43diw d`var'2`name_f'`name_m'_14_id_nh1y43diw d`var'3`name_f'`name_m'_14_id_nh1y43diw  	///
        using "output/etax/figures/final/brfss_l_v1_`var'_`flavor'_`model_lin'.rtf", append  				///
        compress se(4) b(4) nonotes `coef' 		///
        onecell nogaps keep(`t_keep_main') order(`t_keep_main') $stars refcat(`t_refcat' "Panel II: LGBQ, 18-30", nolabel)	///
        `stats' `vwidth' `mwidth' ///
        nomtitle nonum 

        esttab `var'1d`name_m_dif'`name_f'_14_ally43diw `var'2d`name_m_dif'`name_f'_14_ally43diw `var'3d`name_m_dif'`name_f'_14_ally43diw d`var'1d`name_m_dif'`name_f'_14_ally43diw d`var'2d`name_m_dif'`name_f'_14_ally43diw d`var'3d`name_m_dif'`name_f'_14_ally43diw ///
        using "output/etax/figures/final/brfss_l_v1_`var'_`flavor'_`model_lin'.rtf", append			 ///
        compress main(p) b(4) not nonotes coef(`t_coef_dif')			///
        onecell nogaps keep(`t_keep_dif') order(`t_keep_dif') $stars `stats_test' `vwidth' `mwidth'						///
        nomtitle nonum 

        esttab `var'1`name_f'`name_m'_35_id_hty43diw `var'2`name_f'`name_m'_35_id_hty43diw `var'3`name_f'`name_m'_35_id_hty43diw d`var'1`name_f'`name_m'_35_id_hty43diw d`var'2`name_f'`name_m'_35_id_hty43diw d`var'3`name_f'`name_m'_35_id_hty43diw   	///
        using "output/etax/figures/final/brfss_l_v1_`var'_`flavor'_`model_lin'.rtf", append  				///
        compress se(4) b(4) nonotes `coef'    ///
        onecell nogaps keep(`t_keep_main') order(`t_keep_main') $stars 		///
        `stats' `vwidth' `mwidth' refcat(`t_refcat' "Panel III: Heterosexuals, 31+", nolabel) ///
        nonum nomtitle

        esttab `var'1`name_f'`name_m'_35_id_nh1y43diw `var'2`name_f'`name_m'_35_id_nh1y43diw `var'3`name_f'`name_m'_35_id_nh1y43diw d`var'1`name_f'`name_m'_35_id_nh1y43diw d`var'2`name_f'`name_m'_35_id_nh1y43diw d`var'3`name_f'`name_m'_35_id_nh1y43diw  	///
        using "output/etax/figures/final/brfss_l_v1_`var'_`flavor'_`model_lin'.rtf", append  				///
        compress se(4) b(4) nonotes `coef' 		///
        onecell nogaps keep(`t_keep_main') order(`t_keep_main') $stars refcat(`t_refcat' "Panel IV: LGBQ, 31+", nolabel)	///
        `stats' `vwidth' `mwidth' ///
        nomtitle nonum 

        esttab `var'1d`name_m_dif'`name_f'_35_ally43diw `var'2d`name_m_dif'`name_f'_35_ally43diw `var'3d`name_m_dif'`name_f'_35_ally43diw d`var'1d`name_m_dif'`name_f'_35_ally43diw d`var'2d`name_m_dif'`name_f'_35_ally43diw d`var'3d`name_m_dif'`name_f'_35_ally43diw ///
        using "output/etax/figures/final/brfss_l_v1_`var'_`flavor'_`model_lin'.rtf", append			 ///
        compress main(p) b(4) not coef(`t_coef_dif')			///
        onecell nogaps keep(`t_keep_dif') order(`t_keep_dif') $stars `stats_test' `vwidth' `mwidth'						///
        nomtitle nonum 


        estimates clear	
        }
        }
        }
        }
    } 
}

// combined yrbs
if 1 {
    // v1: sex-id, hetero, lgbq panels; current, frequent, daily use columns
    {
        set matsize 1000

        eststo clear
        estimates clear

        forval flavor=0/1 {
            // flavor-specific
            {
                if `flavor'==1 local name_fl 3l // denotes overall flavorban estimates in "other_pol.sters"
                else           local name_fl
            }
        forval model = 3/3 {
        foreach var in vape smoke {
            if "`var'"=="vape"  {
                local t_title "ENDS"
                local yr 5
            }
            if "`var'"=="smoke" {
                local t_title "Cigarette"
                local yr 1
            }
            if "`var'"=="cigar" {
                local t_title "Cigar"
                local yr 1
            }

            if `flavor'==0 {
                estread `var'_`model'l_*  f`var'_`model'l_*  d`var'_`model'l_* using "log/estimates/main_y`yr'3com`model'l"
                estread `var'_`model'ldo_* f`var'_`model'ldo_* d`var'_`model'ldo_* using "log/estimates/main_y`yr'3com`model'l"
            }
            if `flavor'==1 {
                estread `var'_`model'l`name_fl'_*  f`var'_`model'l`name_fl'_*  d`var'_`model'l`name_fl'_* using "log/estimates/other_pol_v20_y`yr'3com`model'l"
                estread `var'_`model'ldo`name_fl'_* f`var'_`model'ldo`name_fl'_* d`var'_`model'ldo`name_fl'_* using "log/estimates/other_pol_v20_y`yr'3com`model'l"
            }
        forval other_pol = 1/1 { // ends taxes, other policies 
        foreach panel in all id_ht id_nh1 {

            // parameters
            {
                if `flavor'==0 {
                    local t_keep_main0 ends_tax_nom35_scale 
                    local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                    local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                    local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                    local t_keep_main1 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape

                    local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                    local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""
                    
                    local t_refcat_var ends_tax_nom35_scale
                }
                if `flavor'==1 {
                    local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban

                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""
                    
                    local t_refcat_var flavor_ban 
                }

                if "`panel'"=="all" {
                    local t_nonum
                    local t_mtitles "mtitles("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use")"
                    
                    local t_repapp  replace

                    local t_refcat "All Conditional on Sex-ID"
                }
                else {
                    local t_nonum   nonum
                    local t_mtitles nomtitle

                    local t_repapp  append
                }
                if "`panel'"=="id_ht" {
                    local t_refcat "Heterosexual"
                }
                if "`panel'"=="id_nh1" {
                    local t_refcat "LGBQ"
                }
            }

            esttab ///
            `var'_`model'l`name_fl'_`panel'y`yr'3_com f`var'_`model'l`name_fl'_`panel'y`yr'3_com d`var'_`model'l`name_fl'_`panel'y`yr'3_com ///
            using "output/etax/figures/final/combined_v1_`flavor'_m`model'l_`var'.rtf", ///
            `t_repapp' keep(`t_keep_main`other_pol'') ///
            `t_nonum' ///
            `t_mtitles' ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(10) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
        }

        // test of differences
        esttab ///
        `var'_`model'ldo`name_fl'_ally`yr'3_com f`var'_`model'ldo`name_fl'_ally`yr'3_com d`var'_`model'ldo`name_fl'_ally`yr'3_com ///
        using "output/etax/figures/final/combined_v1_`flavor'_m`model'l_`var'.rtf", ///
        append keep(`t_keep_dif`other_pol'') ///
        nonum ///
        nomtitle ///
        main(p) b(3) not $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(10) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps
        }
        estimates clear
        }
        }
        }
    }

    // v2: (v1), ols
    {
        // regressions
        if 1 {
            // flavor ban OLS fully differenced
            global dem_control i.sex i.grade i.age i.race4
            // state yrbs, model 3
            foreach var of varlist fsmoke {
                // model 3
                _eststo `var'_3d_ally53_com: ///
                reghdfe `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${vars_lasso_sel_`var'y1} ///
                c.tally_sexualorientation ///
                i.national ///
                ${dem_control}) /// 
                if !mi(lgbq_1) & !inlist(fips,6,11,25,41) [aw=cweight], ///
                absorb(fips year_true semester ///
                lgbq_1#fips lgbq_1#year_true lgbq_1#semester) ///
                vce(cluster fips) nosample

                // tester: lgbq fsmoke point estimate
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${vars_lasso_sel_`var'y1} ///
                c.tally_sexualorientation ///
                ${dem_control} /// 
                if !mi(lgbq_1) & !inlist(fips,6,11,25,41) [aw=aweight], ///
                absorb(fips year_true semester) ///
                vce(cluster fips) nosample
            }

            // table
            {
                esttab fsmoke_3d_ally53_com ///
                using "output/etax/figures/final/combined_v2_1.rtf", replace ///
                keep(1.lgbq_1#c.flavor_ban) main(p) b(3) not mtitle("Frequent Cig Smoking") ///
                $stars compress onecell nogaps
            }
        }

        set matsize 1000

        eststo clear
        estimates clear

        forval flavor=0/0 {
            // flavor-specific
            {
                if `flavor'==1 local name_fl 3l // denotes overall flavorban estimates in "other_pol.sters"
                else           local name_fl
            }
        forval model = 3/3 {
        foreach var in vape smoke {
            if "`var'"=="vape"  {
                local t_title "ENDS"
                local yr 5
            }
            if "`var'"=="smoke" {
                local t_title "Cigarette"
                local yr 1
            }
            if "`var'"=="cigar" {
                local t_title "Cigar"
                local yr 1
            }

            if `flavor'==0 {
                estread `var'_`model'_*  f`var'_`model'_*  d`var'_`model'_* using "log/estimates/main_y`yr'3com`model'"
                estread `var'_`model'd_* f`var'_`model'd_* d`var'_`model'd_* using "log/estimates/main_y`yr'3com`model'"
            }
            if `flavor'==1 {
                estread `var'_`model'`name_fl'_*  f`var'_`model'`name_fl'_*   d`var'_`model'`name_fl'_* using "log/estimates/other_pol_v20_y`yr'3com`model'"
                estread `var'_`model'd`name_fl'_* f`var'_`model'd`name_fl'_* d`var'_`model'd`name_fl'_* using "log/estimates/other_pol_v20_y`yr'3com`model'"
            }
        forval other_pol = 1/1 { // ends taxes, other policies 
        foreach panel in all id_ht id_nh1 {

            // parameters
            {
                if `flavor'==0 {
                    local t_keep_main0 ends_tax_nom35_scale 
                    local t_keep_dif0  1.lgbq_1#c.ends_tax_nom35_scale 

                    local t_coef_main0 "ends_tax_nom35_scale "ENDS Tax ($2023)""
                    local t_coef_dif0  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff""

                    local t_keep_main1 ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    local t_keep_dif1  1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape

                    local t_coef_main1 "ends_tax_nom35_scale "ENDS Tax ($2023)" cigarette_tax_scale "Cig Tax ($2023)" any_mlsa_vape "ENDS MLSA""
                    local t_coef_dif1  "1.lgbq_1#c.ends_tax_nom35_scale "ENDS Tax Diff" 1.lgbq_1#c.cigarette_tax_scale "Cig Tax Diff" 1.lgbq_1#c.any_mlsa_vape "ENDS MLSA Diff""
                    
                    local t_refcat_var ends_tax_nom35_scale
                }
                if `flavor'==1 {
                    local t_keep_main1 flavor_ban
                    local t_keep_dif1  1.lgbq_1#c.flavor_ban

                    local t_coef_main1 "flavor_ban "ENDS Flavor Ban""
                    local t_coef_dif1  "1.lgbq_1#c.flavor_ban "ENDS Flavor Ban Diff""
                    
                    local t_refcat_var flavor_ban 
                }

                if "`panel'"=="all" {
                    local t_nonum
                    local t_mtitles "mtitles("Current `t_title' Use" "Frequent `t_title' Use" "Everyday `t_title' Use")"
                    
                    local t_repapp  replace

                    local t_refcat "All Conditional on Sex-ID"
                }
                else {
                    local t_nonum   nonum
                    local t_mtitles nomtitle

                    local t_repapp  append
                }
                if "`panel'"=="id_ht" {
                    local t_refcat "Heterosexual"
                }
                if "`panel'"=="id_nh1" {
                    local t_refcat "LGBQ"
                }
            }

            esttab ///
            `var'_`model'`name_fl'_`panel'y`yr'3_com f`var'_`model'`name_fl'_`panel'y`yr'3_com d`var'_`model'`name_fl'_`panel'y`yr'3_com ///
            using "output/etax/figures/final/combined_v2_`flavor'_`var'.rtf", ///
            `t_repapp' keep(`t_keep_main`other_pol'') ///
            `t_nonum' ///
            `t_mtitles' ///
            refcat(`t_refcat_var' "`t_refcat'", nolabel) ///
            b(3) se(3) $stars nonotes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
            modelwidth(10) varwidth(15) coef(`t_coef_main`other_pol'') compress onecell nogaps
        }

        // test of differences
        esttab ///
        `var'_`model'd`name_fl'_ally`yr'3_com f`var'_`model'd`name_fl'_ally`yr'3_com d`var'_`model'd`name_fl'_ally`yr'3_com ///
        using "output/etax/figures/final/combined_v2_`flavor'_`var'.rtf", ///
        append keep(`t_keep_dif`other_pol'') ///
        nonum ///
        nomtitle ///
        main(p) b(3) not $stars notes stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(10) varwidth(15) coef(`t_coef_dif`other_pol'') compress onecell nogaps
        }
        estimates clear
        }
        }
        }
    }
}

// dependent var means (overall, not pre-treatment)
if 1 {
    use "data/final/master_set_2023", clear 

    eststo clear 
    estimates clear

    // gen mh vars
    {
        // af4: physical bullying, sad, or suicide ideation
        gen     aff_mh4 = .
        replace aff_mh4 = 1 if (bullied==1)|(sad==1)|(s_ideation==1)
        replace aff_mh4 = 0 if (bullied==0)&(sad==0)&(s_ideation==0)
    }

    // macros for sample cuts 
    {
        local samp_state !national
        local samp_com   1

        local samp_year5 inrange(year,2015,2023)
        local samp_year1 inrange(year,2011,2023)
        
        local samp_het   lgbq_1==0
        local samp_lgbq  lgbq_1==1


        local samp_year6_b inrange(year_survey,2016,2023)
        local samp_year4_b inrange(year_survey,2014,2023)

        local samp_het_b  lgbq==0
        local samp_lgbq_b lgbq==1

        local samp_age0_b inrange(age,18,30)
        local samp_age1_b inrange(age,31,80)
    }
    
    local width "modelwidth(6) varwidth(10)"

    local weight [aw=aweight], meanonly
    local weight_b [aw=sample_weight1], meanonly

    local summ "eststo: estpost summ"

    // ENDS use
    {
        // current: 
        local var vape
        // (1) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'               `weight'

        // (2) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq'              `weight'

        // (3) hetero, aff_mh4=1
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'  & aff_mh4==1 `weight'

        // (4) hetero, aff_mh4=0
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'  & aff_mh4==0 `weight'

        // (5) lgbq, aff_mh4=1
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' & aff_mh4==1 `weight'

        // (6) lgbq, aff_mh4=0
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' & aff_mh4==0 `weight'


        // frequent:
        local var fvape
        // (7) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'               `weight'

        // (8) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq'              `weight'

        // (9) all youth
        `summ' `var' if `samp_state' & `samp_year5' & 1 `weight'

        // (10) non-missing sexual id youth
        `summ' `var' if `samp_state' & `samp_year5' & !mi(lgbq_1)              `weight'

        // (11) hetero (exclude 2021)
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'  & year!=2021 `weight'

        // (12) lgbq (exclude 2021)
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' & year!=2021 `weight'

        // (13) hetero (combined yrbs)
        `summ' `var' if 1            & `samp_year5' & `samp_het'               `weight'

        // (14) lgbq (combined yrbs)
        `summ' `var' if 1            & `samp_year5' & `samp_lgbq'              `weight'

        
        // daily:
        local var dvape
        // (15) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'               `weight'

        // (16) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq'              `weight'
    }

    esttab using "output/etax/figures/final/mean_depvar.rtf", ///
    cells(mean(fmt(3))) replace gaps onecell `width' ///
    collabels(none) refcat(vape "ENDS use", nolabel)
    eststo clear

    // cigarette smoking (2011-2023)
    {
        // current: 
        local var smoke
        // (1) hetero
        `summ' `var' if `samp_state' & `samp_year1' & `samp_het'               `weight'

        // (2) lgbq
        `summ' `var' if `samp_state' & `samp_year1' & `samp_lgbq'              `weight'

        // (3) hetero, aff_mh4=1
        `summ' `var' if `samp_state' & `samp_year1' & `samp_het'  & aff_mh4==1 `weight'

        // (4) hetero, aff_mh4=0
        `summ' `var' if `samp_state' & `samp_year1' & `samp_het'  & aff_mh4==0 `weight'

        // (5) lgbq, aff_mh4=1
        `summ' `var' if `samp_state' & `samp_year1' & `samp_lgbq' & aff_mh4==1 `weight'

        // (6) lgbq, aff_mh4=0
        `summ' `var' if `samp_state' & `samp_year1' & `samp_lgbq' & aff_mh4==0 `weight'


        // frequent:
        local var fsmoke
        // (7) hetero
        `summ' `var' if `samp_state' & `samp_year1' & `samp_het'               `weight'

        // (8) lgbq
        `summ' `var' if `samp_state' & `samp_year1' & `samp_lgbq'              `weight'

        // (9) all youth
        `summ' `var' if `samp_state' & `samp_year1' & 1                        `weight'

        // (10) non-missing sexual id youth
        `summ' `var' if `samp_state' & `samp_year1' & !mi(lgbq_1)              `weight'

        // (11) hetero (exclude 2021)
        `summ' `var' if `samp_state' & `samp_year1' & `samp_het'  & year!=2021 `weight'

        // (12) lgbq (exclude 2021)
        `summ' `var' if `samp_state' & `samp_year1' & `samp_lgbq' & year!=2021 `weight'

        // (13) hetero (combined yrbs)
        `summ' `var' if 1            & `samp_year1' & `samp_het'               `weight'

        // (14) lgbq (combined yrbs)
        `summ' `var' if 1            & `samp_year1' & `samp_lgbq'              `weight'

        
        // daily:
        local var dsmoke
        // (15) hetero
        `summ' `var' if `samp_state' & `samp_year1' & `samp_het'               `weight'

        // (16) lgbq
        `summ' `var' if `samp_state' & `samp_year1' & `samp_lgbq'              `weight'
    }

    esttab using "output/etax/figures/final/mean_depvar.rtf", ///
    cells(mean(fmt(3))) append gaps onecell `width' ///
    collabels(none) refcat(smoke "Cigarette smoking (2011-2023)", nolabel)
    eststo clear

    // cigarette smoking (2015-2023)
    {
        
        // current
        local var smoke
        // (1) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'  `weight'

        // (2) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' `weight'


        // frequent
        local var fsmoke
        // (3) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'  `weight'

        // (4) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' `weight'


        // daily
        local var dsmoke
        // (5) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'  `weight'

        // (6) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' `weight'
    }

    esttab using "output/etax/figures/final/mean_depvar.rtf", ///
    cells(mean(fmt(3))) append gaps onecell `width' ///
    collabels(none) refcat(smoke "Cigarette smoking (2015-2023)", nolabel) 
    eststo clear

    // mental health (aff_mh4) (2015-2023)
    {
        local var aff_mh4
        // (1) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het'  `weight'

        // (2) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' `weight'
    }

    esttab using "output/etax/figures/final/mean_depvar.rtf", ///
    cells(mean(fmt(3))) append gaps onecell `width' ///
    collabels(none) refcat(aff_mh4 "Mental health (2015-2023)", nolabel)
    eststo clear

    // lgbq identification
    {
        local var lgbq_1
        // (1) lgbq_1 (2015-2023)
        `summ' `var' if `samp_state' & `samp_year5'  `weight'

        // (2) lgbq_1 (2011-2023)
        `summ' `var' if `samp_state' & `samp_year1'  `weight'
    }

    esttab using "output/etax/figures/final/mean_depvar.rtf", ///
    cells(mean(fmt(3))) append gaps onecell `width' ///
    collabels(none) refcat(lgbq_1 "LGBQ identification", nolabel)
    eststo clear

    // cigarette or cigar smoking (2011-2023)
    {
        // current
        local var combust
        // hetero
        `summ' `var' if `samp_state' & `samp_year1' & `samp_het'  `weight'

        // lgbq
        `summ' `var' if `samp_state' & `samp_year1' & `samp_lgbq' `weight'


        // frequent
        local var fcombust
        // hetero
        `summ' `var' if `samp_state' & `samp_year1' & `samp_het'  `weight'

        // lgbq
        `summ' `var' if `samp_state' & `samp_year1' & `samp_lgbq' `weight'


        // daily
        local var dcombust
        // hetero
        `summ' `var' if `samp_state' & `samp_year1' & `samp_het'  `weight'

        // lgbq
        `summ' `var' if `samp_state' & `samp_year1' & `samp_lgbq' `weight'
    }

    esttab using "output/etax/figures/final/mean_depvar.rtf", ///
    cells(mean(fmt(3))) append gaps onecell `width' ///
    collabels(none) refcat(combust "Cigarette or cigar smoking (2011-2023)", nolabel)
    eststo clear

    // cigarette or cigar smoking (2015-2023)
    {
        // current
        local var combust
        // (1) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het' `weight'

        // (2) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' `weight'


        // frequent
        local var fcombust
        // (3) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het' `weight'

        // (4) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' `weight'


        // daily
        local var dcombust
        // (5) hetero
        `summ' `var' if `samp_state' & `samp_year5' & `samp_het' `weight'

        // (6) lgbq
        `summ' `var' if `samp_state' & `samp_year5' & `samp_lgbq' `weight'
    }

    esttab using "output/etax/figures/final/mean_depvar.rtf", ///
    cells(mean(fmt(3))) append gaps onecell `width' ///
    collabels(none) refcat(combust "Cigarette or cigar smoking (2015-2023)", nolabel)
    eststo clear

    use "data/final/brfss_master_set_2023", clear

    // BRFSS
    {
        // current ENDS use:
        local var vape
        // (1) 18-30, hetero
        `summ' `var' if `samp_year6_b' & `samp_het_b'  & `samp_age0_b' `weight_b'

        // (2) 31-80, hetero
        `summ' `var' if `samp_year6_b' & `samp_het_b'  & `samp_age1_b' `weight_b'

        // (3) 18-30, lgbq
        `summ' `var' if `samp_year6_b' & `samp_lgbq_b' & `samp_age0_b' `weight_b'

        // (4) 31-80, lgbq
        `summ' `var' if `samp_year6_b' & `samp_lgbq_b' & `samp_age1_b' `weight_b'


        // daily ENDS use:
        local var dvape
        // (5) 18-30, hetero
        `summ' `var' if `samp_year6_b' & `samp_het_b'  & `samp_age0_b' `weight_b'

        // (6) 31-80, hetero
        `summ' `var' if `samp_year6_b' & `samp_het_b'  & `samp_age1_b' `weight_b'

        // (7) 18-30, lgbq
        `summ' `var' if `samp_year6_b' & `samp_lgbq_b' & `samp_age0_b' `weight_b'

        // (8) 31-80, lgbq
        `summ' `var' if `samp_year6_b' & `samp_lgbq_b' & `samp_age1_b' `weight_b'


        // current cigarette smoking:
        local var smoke
        // (9) 18-30, hetero
        `summ' `var' if `samp_year4_b' & `samp_het_b'  & `samp_age0_b' `weight_b'

        // (10) 31-80, hetero
        `summ' `var' if `samp_year4_b' & `samp_het_b'  & `samp_age1_b' `weight_b'

        // (11) 18-30, lgbq
        `summ' `var' if `samp_year4_b' & `samp_lgbq_b' & `samp_age0_b' `weight_b'

        // (12) 31-80, lgbq
        `summ' `var' if `samp_year4_b' & `samp_lgbq_b' & `samp_age1_b' `weight_b'


        // daily cigarette smoking:
        local var dsmoke
        // (13) 18-30, hetero
        `summ' `var' if `samp_year4_b' & `samp_het_b'  & `samp_age0_b' `weight_b'

        // (14) 31-80, hetero
        `summ' `var' if `samp_year4_b' & `samp_het_b'  & `samp_age1_b' `weight_b'

        // (15) 18-30, lgbq
        `summ' `var' if `samp_year4_b' & `samp_lgbq_b' & `samp_age0_b' `weight_b'

        // (16) 31-80, lgbq
        `summ' `var' if `samp_year4_b' & `samp_lgbq_b' & `samp_age1_b' `weight_b'
    }

    esttab using "output/etax/figures/final/mean_depvar.rtf", ///
    cells(mean(fmt(3))) append gaps onecell `width' ///
    collabels(none)refcat(vape "BRFSS", nolabel)
    eststo clear
}


// space for VSCode