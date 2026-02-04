//
// (03): estimate (almost) all project-related regressions (this file will take a long time to complete)
//

version 15.1

clear all
cap log close
set more off

eststo    clear
estimates clear


use "data/final/master_set_2023", clear


// LASSO procedure to select controls
if 0 {
    // v1: 'pdslasso'
    {
        // YRBS (non-missing sexual id info sample)
        {
            // ENDS use
            {
                // vape
                {
                    pdslasso vape ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,beer_tax_scale,RML,MML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke
                    tobacco_lis_law_any uer coviddeaths
                    populationvaccinated 2014b.year_true 2015.year_true
                    2016.year_true 2017.year_true 2018.year_true
                    2019.year_true 2021.year_true 2022.year_true
                    2023.year_true 1b.semester 2.semester
                    */
                }

                // fvape
                {
                    pdslasso fvape ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke MML uer
                    coviddeaths populationvaccinated 2014b.year_true
                    2015.year_true 2016.year_true 2017.year_true
                    2018.year_true 2019.year_true 2021.year_true
                    2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }

                // dvape
                {
                    pdslasso dvape ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke MML uer
                    coviddeaths populationvaccinated 2014b.year_true
                    2015.year_true 2016.year_true 2017.year_true
                    2018.year_true 2019.year_true 2021.year_true
                    2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }
            } // vape: drop {ecigs_lis_law_any,beer_tax_scale,RML,MML}
            // fvape:  drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
            // dvape:  drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}

            // combustible tobacco (2015-2023)
            {
                // smoke
                {
                    pdslasso smoke ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  5: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML,MML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke uer
                    coviddeaths populationvaccinated 2014b.year_true
                    2015.year_true 2016.year_true 2017.year_true
                    2018.year_true 2019.year_true 2021.year_true
                    2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }

                // fsmoke
                {
                    pdslasso fsmoke ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  6: {ecigs_lis_law_any,indoor_ban_vape,tobacco_lis_law_any,beer_tax_scale,RML,MML}
                    /*
                    ecigban indoor_ban_smoke uer coviddeaths
                    populationvaccinated 2014b.year_true 2015.year_true
                    2016.year_true 2017.year_true 2018.year_true
                    2019.year_true 2021.year_true 2022.year_true
                    2023.year_true 1b.semester 2.semester
                    */
                }

                // dsmoke
                {
                    pdslasso dsmoke ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  6: {ecigs_lis_law_any,indoor_ban_vape,tobacco_lis_law_any,beer_tax_scale,RML,MML}
                    /*
                    ecigban indoor_ban_smoke uer coviddeaths
                    populationvaccinated 2014b.year_true 2015.year_true
                    2016.year_true 2017.year_true 2018.year_true
                    2019.year_true 2021.year_true 2022.year_true
                    2023.year_true 1b.semester 2.semester
                    */
                }

                // combust
                {
                    pdslasso combust ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  4: {ecigs_lis_law_any,beer_tax_scale,RML,MML}
                    /*  
                    indoor_ban_vape ecigban indoor_ban_smoke
                    tobacco_lis_law_any uer coviddeaths
                    populationvaccinated 2014b.year_true 2015.year_true
                    2016.year_true 2017.year_true 2018.year_true
                    2019.year_true 2021.year_true 2022.year_true
                    2023.year_true 1b.semester 2.semester

                    */
                }

                // fcombust (need year_true in partial)
                {
                    pdslasso fcombust ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips i.year_true) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  6: {ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke,beer_tax_scale,RML,MML}
                    /*
                    ecigban tobacco_lis_law_any uer coviddeaths
                    populationvaccinated 1b.semester 2.semester

                    */
                }

                // dcombust (need year_true in partial)
                {
                    pdslasso dcombust ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips i.year_true) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  6: {ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke,beer_tax_scale,RML,MML}
                    /*
                    ecigban tobacco_lis_law_any uer coviddeaths
                    populationvaccinated 1b.semester 2.semester
                    */
                }
            } // smoke:  drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML,MML}
            // fsmoke:   drop {ecigs_lis_law_any,indoor_ban_vape,tobacco_lis_law_any,beer_tax_scale,RML,MML}
            // dsmoke:   drop {ecigs_lis_law_any,indoor_ban_vape,tobacco_lis_law_any,beer_tax_scale,RML,MML}
            // combust:  drop {ecigs_lis_law_any,beer_tax_scale,RML,MML}
            // fcombust: drop {ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke,beer_tax_scale,RML,MML}
            // dcombust: drop {ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke,beer_tax_scale,RML,MML}

            // combustible tobacco (2011-2023)
            {
                // smoke
                {
                    pdslasso smoke ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2011,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,beer_tax_scale,RML,MML} 
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke
                    tobacco_lis_law_any uer coviddeaths
                    populationvaccinated 2011b.year_true 2013.year_true
                    2014.year_true 2015.year_true 2016.year_true
                    2017.year_true 2018.year_true 2019.year_true
                    2021.year_true 2022.year_true 2023.year_true
                    1b.semester 2.semester
                    */
                }

                // fsmoke
                {
                    pdslasso fsmoke ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2011,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 5: {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML,MML}
                    /*
                    ecigban indoor_ban_smoke tobacco_lis_law_any uer
                    coviddeaths populationvaccinated 2011b.year_true
                    2013.year_true 2014.year_true 2015.year_true
                    2016.year_true 2017.year_true 2018.year_true
                    2019.year_true 2021.year_true 2022.year_true
                    2023.year_true 1b.semester 2.semester
                    */
                }

                // dsmoke
                {
                    pdslasso dsmoke ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2011,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  5: {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML,MML}
                    /*
                    ecigban indoor_ban_smoke tobacco_lis_law_any uer
                    coviddeaths populationvaccinated 2011b.year_true
                    2013.year_true 2014.year_true 2015.year_true
                    2016.year_true 2017.year_true 2018.year_true
                    2019.year_true 2021.year_true 2022.year_true
                    2023.year_true 1b.semester 2.semester

                    */
                }

                // combust
                {
                    pdslasso combust ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2011,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  3: {ecigs_lis_law_any,beer_tax_scale,RML}
                    /*  
                    indoor_ban_vape ecigban indoor_ban_smoke
                    tobacco_lis_law_any MML uer coviddeaths
                    populationvaccinated 2011b.year_true 2013.year_true
                    2014.year_true 2015.year_true 2016.year_true
                    2017.year_true 2018.year_true 2019.year_true
                    2021.year_true 2022.year_true 2023.year_true
                    1b.semester 2.semester
                    */
                }

                // fcombust (need year_true in partial)
                {
                    pdslasso fcombust ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2011,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips i.year_true) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  4: {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML} 
                    /*
                    ecigban indoor_ban_smoke tobacco_lis_law_any MML uer
                    coviddeaths populationvaccinated 1b.semester
                    2.semester
                    */
                }

                // dcombust (need year_true in partial)
                {
                    pdslasso dcombust ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2011,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips i.year_true) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped  4: {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML} 
                    /*
                    ecigban indoor_ban_smoke tobacco_lis_law_any MML uer
                    coviddeaths populationvaccinated 1b.semester
                    2.semester
                    */
                }
            } // smoke:  drop {ecigs_lis_law_any,beer_tax_scale,RML,MML}
            // fsmoke:   drop {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML,MML}
            // dsmoke:   drop {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML,MML}
            // combust:  drop {ecigs_lis_law_any,beer_tax_scale,RML}
            // fcombust: drop {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML} 
            // dcombust: drop {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML}

            // sexual orientation (2015-2023)
            {
                // lgbq_1
                {
                    pdslasso lgbq_1 ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 3: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke RML MML uer
                    coviddeaths populationvaccinated 2014b.year_true
                    2015.year_true 2016.year_true 2017.year_true
                    2018.year_true 2019.year_true 2021.year_true
                    2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }

                // id_gay_lesbian
                {
                    pdslasso id_gay_lesbian ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke MML uer
                    coviddeaths populationvaccinated 2014b.year_true
                    2015.year_true 2016.year_true 2017.year_true
                    2018.year_true 2019.year_true 2021.year_true
                    2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }

                // id_bisexual
                {
                    pdslasso id_bisexual ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke MML uer
                    coviddeaths populationvaccinated 2014b.year_true
                    2015.year_true 2016.year_true 2017.year_true
                    2018.year_true 2019.year_true 2021.year_true
                    2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }

                // id_questioning
                {
                    pdslasso id_questioning ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 3: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke RML MML uer
                    coviddeaths populationvaccinated 2014b.year_true
                    2015.year_true 2016.year_true 2017.year_true
                    2018.year_true 2019.year_true 2021.year_true
                    2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }
            } // lgbq_1:       drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale}
            // id_gay_lesbian: drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
            // id_bisexual:    drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML} 
            // id_questioning: drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale}
        
            // mental health (2015-2023)
            {
                // gen vars
                cap drop either_bully
                gen 	 either_bully = .
                replace  either_bully = 1 if (bullied==1)|(e_bullied==1)
                replace  either_bully = 0 if (bullied==0)&(e_bullied==0)

                // af4: physical bullying, sad, or suicide ideation
                gen     aff_mh4 = .
                replace aff_mh4 = 1 if (bullied==1)|(sad==1)|(s_ideation==1)
                replace aff_mh4 = 0 if (bullied==0)&(sad==0)&(s_ideation==0)

                // either_bully
                {
                    pdslasso either_bully ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke MML uer coviddeaths
                    populationvaccinated 2014b.year_true 2015.year_true 2016.year_true
                    2017.year_true 2018.year_true 2019.year_true 2021.year_true 2022.year_true
                    2023.year_true 1b.semester 2.semester
                    */
                }

                // sad
                {
                    pdslasso sad ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips i.year_true) /// partial (include year_true)
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke MML uer coviddeaths
                    populationvaccinated 1b.semester 2.semester
                    */
                }

                // either_bully or sad (aff_mh8)
                {
                    // af8: either bullying or sad
                    gen     aff_mh8 = .
                    replace aff_mh8 = 1 if (either_bully==1)|(sad==1)
                    replace aff_mh8 = 0 if (either_bully==0)&(sad==0)

                    pdslasso aff_mh8 ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke MML uer coviddeaths
                    populationvaccinated 2014b.year_true 2015.year_true 2016.year_true
                    2017.year_true 2018.year_true 2019.year_true 2021.year_true 2022.year_true
                    2023.year_true 1b.semester 2.semester

                    */
                }

                // s_ideation
                {
                    pdslasso s_ideation ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke MML uer coviddeaths
                    populationvaccinated 2014b.year_true 2015.year_true 2016.year_true
                    2017.year_true 2018.year_true 2019.year_true 2021.year_true 2022.year_true
                    2023.year_true 1b.semester 2.semester
                    */
                }

                // aff_mh4
                {
                    pdslasso aff_mh4 ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2015,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
                    /*
                    indoor_ban_vape ecigban indoor_ban_smoke MML uer
                    coviddeaths populationvaccinated 2014b.year_true
                    2015.year_true 2016.year_true 2017.year_true
                    2018.year_true 2019.year_true 2021.year_true
                    2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }
            } // either_bully: drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
            // sad:            drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
            // aff_mh8:        drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
            // s_ideation:     drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}
            // aff_mh4:        drop {ecigs_lis_law_any,tobacco_lis_law_any,beer_tax_scale,RML}

            // sexual orientation (2011-2023)
            {
                // lgbq_1
                {
                    pdslasso lgbq_1 ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester) ///
                    if !mi(lgbq_1) & !national & inrange(year,2011,2023) [aw=aweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 5: {ecigs_lis_law_any, indoor_ban_vape, beer_tax_scale, RML, MML}
                    /*
                    ecigban indoor_ban_smoke tobacco_lis_law_any uer coviddeaths
                    populationvaccinated 2011b.year_true 2013.year_true 2014.year_true
                    2015.year_true 2016.year_true 2017.year_true 2018.year_true 2019.year_true
                    2021.year_true 2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }
            } // lgbq_1: drop {ecigs_lis_law_any, indoor_ban_vape, beer_tax_scale, RML, MML}
        } 
        
        // combined YRBS 
        {
            // ENDS use
            {
                // vape
                {
                    pdslasso vape ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester i.national) ///
                    if !mi(lgbq_1) & 1 [aw=cweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips i.national) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML}
                    /*
                    ecigban indoor_ban_smoke tobacco_lis_law_any MML uer coviddeaths populationvaccinated
                    2014b.year_true 2015.year_true 2016.year_true 2017.year_true 2018.year_true
                    2019.year_true 2021.year_true 2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }

                // fvape
                {
                    pdslasso fvape ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester i.national) ///
                    if !mi(lgbq_1) & 1 [aw=cweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips i.national) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law,indoor_ban_vape,beer_tax_scale,RML}
                    /*
                    ecigban indoor_ban_smoke tobacco_lis_law_any MML uer coviddeaths populationvaccinated
                    2014b.year_true 2015.year_true 2016.year_true 2017.year_true 2018.year_true
                    2019.year_true 2021.year_true 2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }

                // dvape
                {
                    pdslasso dvape ///
                    ends_tax_nom35_scale ///
                    flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                    (i.sex i.grade i.age i.race4 ///
                    uer coviddeaths populationvaccinated ///
                    ecigs_lis_law_any indoor_ban_vape ecigban ///
                    indoor_ban_smoke tobacco_lis_law_any ///
                    beer_tax_scale RML MML ///
                    i.fips i.year_true i.semester i.national) ///
                    if !mi(lgbq_1) & 1 [aw=cweight], ///
                    pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                    i.year_true i.semester) /// ...
                    partial(i.sex i.grade i.age i.race4 i.fips i.national) /// partial
                    robust                                      /// heteroskedasticity
                    cluster(fips)                               // cluster SE
                    // dropped 4: {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML}
                    /*
                    ecigban indoor_ban_smoke tobacco_lis_law_any MML uer coviddeaths populationvaccinated
                    2014b.year_true 2015.year_true 2016.year_true 2017.year_true 2018.year_true
                    2019.year_true 2021.year_true 2022.year_true 2023.year_true 1b.semester 2.semester
                    */
                }
            } // vape: dropped {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML}
            //  fvape: dropped {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML}
            //  dvape: dropped {ecigs_lis_law_any,indoor_ban_vape,beer_tax_scale,RML}
        } 

        // BRFSS (not missing sex-id info sample)
        {
            use "data/final/brfss_master_set_2023", clear

            // 18-30 year olds
            // vape (year_true in partial)
            {
                pdslasso vape ///
                ends_tax_nom35_scale ///
                flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                (i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race ///
                uer coviddeaths populationvaccinated ///
                ecigs_lis_law_any indoor_ban_vape ecigban ///
                indoor_ban_smoke tobacco_lis_law_any ///
                beer_tax_scale RML MML ///
                i.fips i.year_true i.quarter) ///
                if !mi(heterosexual)&!mi(lgbq) & inrange(year_survey,2016,2023) ///
                & inrange(age,18,30) [aw=sample_weight1], ///
                pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                i.quarter) /// ...
                partial(i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race i.year_true i.fips) /// partial
                robust                                      /// heteroskedasticity
                cluster(fips)                               // cluster SE
                // dropped 6: {ecigs_lis_law_any,indoor_ban_vape,tobacco_lis_law_any,beer_tax_scale,RML,MML}
                /*
                ecigban indoor_ban_smoke uer coviddeaths
                populationvaccinated 1b.quarter 2.quarter 3.quarter
                4.quarter
                */
            }
            // dvape
            {
                pdslasso dvape ///
                ends_tax_nom35_scale ///
                flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                (i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race ///
                uer coviddeaths populationvaccinated ///
                ecigs_lis_law_any indoor_ban_vape ecigban ///
                indoor_ban_smoke tobacco_lis_law_any ///
                beer_tax_scale RML MML ///
                i.fips i.year_true i.quarter) ///
                if !mi(heterosexual)&!mi(lgbq) & inrange(year_survey,2016,2023) ///
                & inrange(age,18,30) [aw=sample_weight1], ///
                pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                i.quarter) /// ...
                partial(i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race i.year_true i.fips) /// partial
                robust                                      /// heteroskedasticity
                cluster(fips)                               // cluster SE
                // dropped 7: {ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke,tobacco_lis_law_any,beer_tax_scale,RML,MML}
                /*
                ecigban uer coviddeaths populationvaccinated
                1b.quarter 2.quarter 3.quarter 4.quarter
                */
            }
            // smoke
            {
                pdslasso smoke ///
                ends_tax_nom35_scale ///
                flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                (i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race ///
                uer coviddeaths populationvaccinated ///
                ecigs_lis_law_any indoor_ban_vape ecigban ///
                indoor_ban_smoke tobacco_lis_law_any ///
                beer_tax_scale RML MML ///
                i.fips i.year_true i.quarter) ///
                if !mi(heterosexual)&!mi(lgbq) & inrange(year_survey,2014,2023) ///
                & inrange(age,18,30) [aw=sample_weight1], ///
                pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                i.quarter) /// ...
                partial(i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race i.year_true i.fips) /// partial
                robust                                      /// heteroskedasticity
                cluster(fips)                               // cluster SE
                // dropped 7:
                /*
                ecigban uer coviddeaths populationvaccinated 1b.quarter 2.quarter 3.quarter 4.quarter
                */
            }
            // dsmoke 
            {
                pdslasso dsmoke ///
                ends_tax_nom35_scale ///
                flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                (i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race ///
                uer coviddeaths populationvaccinated ///
                ecigs_lis_law_any indoor_ban_vape ecigban ///
                indoor_ban_smoke tobacco_lis_law_any ///
                beer_tax_scale RML MML ///
                i.fips i.year_true i.quarter) ///
                if !mi(heterosexual)&!mi(lgbq) & inrange(year_survey,2014,2023) ///
                & inrange(age,18,30) [aw=sample_weight1], ///
                pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                i.quarter) /// ...
                partial(i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race i.year_true i.fips) /// partial
                robust                                      /// heteroskedasticity
                cluster(fips)                               // cluster SE
                // dropped 7
                /*
                ecigban uer coviddeaths populationvaccinated 1b.quarter 2.quarter 3.quarter 4.quarter
                */
            }

            // 18-80 year olds
            // vape (year_true in partial)
            {
                pdslasso vape ///
                ends_tax_nom35_scale ///
                flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                (i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race ///
                uer coviddeaths populationvaccinated ///
                ecigs_lis_law_any indoor_ban_vape ecigban ///
                indoor_ban_smoke tobacco_lis_law_any ///
                beer_tax_scale RML MML ///
                i.fips i.year_true i.quarter) ///
                if !mi(heterosexual)&!mi(lgbq) & inrange(year_survey,2016,2023) ///
                & inrange(age,18,80) [aw=sample_weight1], ///
                pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                i.quarter) /// ...
                partial(i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race i.year_true i.fips) /// partial
                robust                                      /// heteroskedasticity
                cluster(fips)                               // cluster SE
                // dropped 7: {ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke,tobacco_lis_law_any,beer_tax_scale,RML,MML}
                /*
                ecigban uer coviddeaths populationvaccinated
                1b.quarter 2.quarter 3.quarter 4.quarter
                */
            }
            // dvape (year_true in partial)
            {
                pdslasso dvape ///
                ends_tax_nom35_scale ///
                flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                (i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race ///
                uer coviddeaths populationvaccinated ///
                ecigs_lis_law_any indoor_ban_vape ecigban ///
                indoor_ban_smoke tobacco_lis_law_any ///
                beer_tax_scale RML MML ///
                i.fips i.year_true i.quarter) ///
                if !mi(heterosexual)&!mi(lgbq) & inrange(year_survey,2016,2023) ///
                & inrange(age,18,80) [aw=sample_weight1], ///
                pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                i.quarter) /// ...
                partial(i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race i.year_true i.fips) /// partial
                robust                                      /// heteroskedasticity
                cluster(fips)                               // cluster SE
                // dropped 7: {ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke,tobacco_lis_law_any,beer_tax_scale,RML,MML}
                /*
                ecigban uer coviddeaths populationvaccinated
                1b.quarter 2.quarter 3.quarter 4.quarter
                */
            }
            // smoke
            {
                pdslasso smoke ///
                ends_tax_nom35_scale ///
                flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                (i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race ///
                uer coviddeaths populationvaccinated ///
                ecigs_lis_law_any indoor_ban_vape ecigban ///
                indoor_ban_smoke tobacco_lis_law_any ///
                beer_tax_scale RML MML ///
                i.fips i.year_true i.quarter) ///
                if !mi(heterosexual)&!mi(lgbq) & inrange(year_survey,2014,2023) ///
                & inrange(age,18,80) [aw=sample_weight1], ///
                pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                i.quarter) /// ...
                partial(i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race i.year_true i.fips) /// partial
                robust                                      /// heteroskedasticity
                cluster(fips)                               // cluster SE
                // dropped 7: {ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke,tobacco_lis_law_any,beer_tax_scale,RML,MML}
                /*
                ecigban uer coviddeaths populationvaccinated 1b.quarter 2.quarter 3.quarter 4.quarter
                */
            }
            // dsmoke
            {
                pdslasso dsmoke ///
                ends_tax_nom35_scale ///
                flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
                (i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race ///
                uer coviddeaths populationvaccinated ///
                ecigs_lis_law_any indoor_ban_vape ecigban ///
                indoor_ban_smoke tobacco_lis_law_any ///
                beer_tax_scale RML MML ///
                i.fips i.year_true i.quarter) ///
                if !mi(heterosexual)&!mi(lgbq) & inrange(year_survey,2014,2023) ///
                & inrange(age,18,80) [aw=sample_weight1], ///
                pnotpen(uer coviddeaths populationvaccinated /// unpenalized
                i.quarter) /// ...
                partial(i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college ///
                /*c.white*/ c.black c.hispanic c.other_race i.year_true i.fips) /// partial
                robust                                      /// heteroskedasticity
                cluster(fips)                               // cluster SE
                // dropped 7: {ecigs_lis_law_any,indoor_ban_vape,indoor_ban_smoke,tobacco_lis_law_any,beer_tax_scale,RML,MML}
                /*
                ecigban uer coviddeaths populationvaccinated 1b.quarter 2.quarter 3.quarter 4.quarter
                */
            }
        }
    }  
}

// define variables
{
    // outcome variables
    {
        // vaping, cigarette smoking, cigar smoking, cigarette or cigar smoking
        global total_outcomes ///
        vape fvape dvape smoke fsmoke dsmoke cigar fcigar dcigar combust fcombust dcombust 
    }

    // control variables
    {
        // essential vars
        global vars_essential_coef1   c.ends_tax_nom35_scale c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale
        global vars_essential_coef0   c.uer c.coviddeaths c.populationvaccinated
        // BRFSS
        global vars_essential_coef1_b c.ends_tax_nom35_scale c.flavor_ban c.any_mlsa_vape c.t21 c.cigarette_tax_scale
        global vars_essential_coef0_b c.uer c.coviddeaths c.populationvaccinated

        // LASSO vars (dependent variable specific)
        {
            // ENDS
            {
                global vars_lasso_sel_vape  /// current vaping
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke i.tobacco_lis_law_any

                global vars_lasso_sel_fvape /// frequent vaping
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke c.MML
            
                global vars_lasso_sel_dvape /// daily vaping
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke c.MML
            }

            // cigarette smoking 
            {
                // 2011-2023
                global vars_lasso_sel_smokey1 /// current cig smoking
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke i.tobacco_lis_law_any

                global vars_lasso_sel_fsmokey1 /// frequent cig smoking
                i.ecigban c.indoor_ban_smoke i.tobacco_lis_law_any

                global vars_lasso_sel_dsmokey1 /// daily cig smoking
                i.ecigban c.indoor_ban_smoke i.tobacco_lis_law_any

                // 2015-2023
                global vars_lasso_sel_smokey5 /// current cig smoking
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke

                global vars_lasso_sel_fsmokey5 /// frequent cig smoking
                i.ecigban c.indoor_ban_smoke

                global vars_lasso_sel_dsmokey5 /// daily cig smoking
                i.ecigban c.indoor_ban_smoke
            }

            // cigarette or cigar smoking
            {
                // 2011-2023
                global vars_lasso_sel_combusty1 /// current cig or cigar smoking
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke i.tobacco_lis_law_any c.MML

                global vars_lasso_sel_fcombusty1 /// frequent cig or cigar smoking
                i.ecigban c.indoor_ban_smoke i.tobacco_lis_law_any c.MML

                global vars_lasso_sel_dcombusty1 /// daily cig or cigar smoking
                i.ecigban c.indoor_ban_smoke i.tobacco_lis_law_any c.MML

                // 2015-2023
                global vars_lasso_sel_combusty5 /// current cig or cigar smoking
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke i.tobacco_lis_law_any

                global vars_lasso_sel_fcombusty5 /// frequent cig or cigar smoking
                i.ecigban i.tobacco_lis_law_any

                global vars_lasso_sel_dcombusty5 /// daily cig or cigar smoking
                i.ecigban i.tobacco_lis_law_any
            }

            // sexual orientation
            {
                // 2015-2023
                global vars_lasso_sel_lgbq_1 /// lgbq identification
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke c.RML c.MML

                global vars_lasso_sel_id_gay_lesbian /// gay/lesbian identification
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke c.MML

                global vars_lasso_sel_id_bisexual /// bisexual identification
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke c.MML

                global vars_lasso_sel_id_questioning /// questioning identification
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke c.RML c.MML


                // 2011-2023
                global vars_lasso_sel_lgbq_1y1 /// lgbq identification
                i.ecigban c.indoor_ban_smoke i.tobacco_lis_law_any
            }

            // mental health
            {
                global vars_lasso_sel_either_bully /// either_bully (physical or electronic)
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke c.MML

                // either_bully or sad (aff_mh8)
                global vars_lasso_sel_aff_mh8 /// either_bully or sad
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke c.MML

                // in-person bully, sad, suicidal ideation (aff_mh4)
                global vars_lasso_sel_aff_mh4 ///
                c.indoor_ban_vape i.ecigban c.indoor_ban_smoke c.MML
            }

            global vars_lasso_sel_other /// other vars (take union of ENDS dropped controls)
            c.indoor_ban_vape i.ecigban c.indoor_ban_smoke

            // BRFSS 
            {
                // LASSO vars (dependent variable specific) -- using 18-30 nonmissing sex-id sample
                global vars_lasso_sel_vape_b  /// current vaping
                c.ecigban c.indoor_ban_smoke
                global vars_lasso_sel_dvape_b /// daily vaping
                c.ecigban

                global vars_lasso_sel_smoke_b /// current smoking (2014-2023 sample)
                c.ecigban
                global vars_lasso_sel_dsmoke_b /// daily smoking (2014-2023 sample)
                c.ecigban
            }
        }
    }

    // subsample definitions
    {
        local racial "race4==1 race4==2 race4==3 race4==4 1 !mi(lgbq_1)"
        // 6 groups: #(1-6)
        // white,NH; black; hispanic; other; all; all, including sex-id info

        local sex "sex==1 sex==2"
        // 2 groups: #(7-8)
        // female; male

        local sexual_id "sex_orientation==1 lgbq_1==1 lgbq_2==1 sex_orientation==2 sex_orientation==3 inlist(sex_orientation,4,5,6)"
        // 6 groups: #(9-14)
        // heterosexual; lgbq(def. 1); lgbq(def. 2); gay or lesbian; bisexual; questioning

        local age "inrange(age,1,6) inrange(age,7,7)" // <18, 18 or older	
        // 2 groups: #(15-16)
        // less than 18; 18 or older

        local intersection_slim "(race4==1)&(sex==2)&(lgbq_1==0) (race4==1)&(sex==2)&(lgbq_1==1) (inrange(race4,2,4))&(sex==2)&(lgbq_1==0) (inrange(race4,2,4))&(sex==2)&(lgbq_1==1) (race4==1)&(sex==1)&(lgbq_1==0) (race4==1)&(sex==1)&(lgbq_1==1) (inrange(race4,2,4))&(sex==1)&(lgbq_1==0) (inrange(race4,2,4))&(sex==1)&(lgbq_1==1)"	
        // 8 groups: #(17-24)	
        // white,male,het; white,male,lgbq; non-white,male,het; non-white,male,lgbq; white,female,het; white,female,lgbq; non-white,female,het; non-white,female,lgbq

        local intersection_broad "(sex==2)&(lgbq_1==0) (sex==2)&(lgbq_1==1) (sex==1)&(lgbq_1==0) (sex==1)&(lgbq_1==1) (race4==1)&(lgbq_1==0) (race4==1)&(lgbq_1==1) (inrange(race4,2,4))&(lgbq_1==0) (inrange(race4,2,4))&(lgbq_1==1)"
        // 8 groups: #(25-32)
        // male,het; male,lgbq; female,het; female,lgbq -- white,het; white,lgbq; non-white,het; non-white,lgbq

        local gay_lesbian "(sex==2)&(id_gay_lesbian==1) (sex==1)&(id_gay_lesbian==1)"
        // 2 groups: #(33-34)
        // male, gay or lesbian; female, gay or lesbian

        global samples `racial' `sex' `sexual_id' `age' `intersection_slim' `intersection_broad' `gay_lesbian'
	    local sample_num = wordcount("$samples") // (***)
    }
}

// main regression loop
if 1 { 
    cap log close 
    log using "log/regressions/reg_main.smcl", replace
    
    eststo    clear
    estimates clear

    foreach i in !national /*national*/ 1 {
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
    foreach yr in 2011 2015 /*2017*/ {
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
    
    keep if `i'	
    keep if inrange(year,`yr',`yr_end')		

    foreach q in 5 6 9 10 11 12 13 14 25 26 27 28 29 30 31 32 33 34 { 

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

        foreach var of global total_outcomes {
        forval model = 1/2 {
            // LASSO assignment (***)
            {
                // vaping vars get specific LASSO controls, other vars get other LASSO controls
                if inlist("`var'","vape","fvape","dvape") ///
                local vars_lasso_sel ${vars_lasso_sel_`var'}

                else ///
                local vars_lasso_sel ${vars_lasso_sel_`var'`yr_name'}
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
            [aw=`weight'], meanonly
            scalar pre_treat_mean = r(mean)

            // OLS
            if `model'==1 {
                // model 1: state, year, semester FE, demographics, macro/covid, 
                // ENDS taxes, flavor bans, MLSA laws, Tobacco-21 Laws, cigarette taxes
                _eststo `var'_1_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${dem_control} `technical' ///
                if `subsample' [aw=`weight'], ///
                abs(fips year_true semester) vce(cluster fips) nosample	
                estadd scalar pre_treat_mean = pre_treat_mean	


                // model 2: model 1 + LASSO selected vars
                _eststo `var'_2_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                ${dem_control} `technical' ///
                if `subsample' [aw=`weight'], ///
                abs(fips year_true semester) vce(cluster fips) nosample	
                estadd scalar pre_treat_mean = pre_treat_mean


                // model 3: model 2 + LGBQ policy control
                _eststo `var'_3_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${dem_control} `technical' ///
                if `subsample' [aw=`weight'], ///
                abs(fips year_true semester) vce(cluster fips) nosample	
                estadd scalar pre_treat_mean = pre_treat_mean


                if `q'==6 { // fully-differenced
                    // model 1
                    _eststo `var'_1d_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    ${dem_control} `technical') /// 
                    if `subsample' [aw=`weight'], ///
                    absorb(fips year_true semester ///
                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester) ///
                    vce(cluster fips) nosample


                    // model 2
                    _eststo `var'_2d_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    ${dem_control} `technical') /// 
                    if `subsample' [aw=`weight'], ///
                    absorb(fips year_true semester ///
                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester) ///
                    vce(cluster fips) nosample


                    // model 3
                    _eststo `var'_3d_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    c.tally_sexualorientation ///
                    ${dem_control} `technical') /// 
                    if `subsample' [aw=`weight'], ///
                    absorb(fips year_true semester ///
                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester) ///
                    vce(cluster fips) nosample
                }
            }

            // logit
            if `model'==2 {
                // model 1: state, year, semester FE, demographics, macro/covid, 
                // ENDS taxes, flavor bans, MLSA laws, Tobacco-21 Laws, cigarette taxes
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if `subsample' [pw=`weight'], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	
                matrix A            = e(converged)

                _eststo `var'_1l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                margins, dydx(${vars_essential_coef1}) post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre
                
                local mat_size = wordcount(e(xvars)) 
                matrix B = J(1,`mat_size',.)
                forval b = 1/`mat_size' {
                matrix B[1,`b'] = A[1,1]
                }
                estadd matrix B


                // model 2: model 1 + LASSO selected vars
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if `subsample' [pw=`weight'], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	
                matrix A = e(converged)

                _eststo `var'_2l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                margins, dydx(${vars_essential_coef1}) post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre
                
                local mat_size = wordcount(e(xvars)) 
                matrix B = J(1,`mat_size',.)
                forval b = 1/`mat_size' {
                matrix B[1,`b'] = A[1,1]
                }
                estadd matrix B


                // model 3: model 2 + LGBQ policy control
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if `subsample' [pw=`weight'], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	
                matrix A            = e(converged)

                _eststo `var'_3l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                margins, dydx(${vars_essential_coef1}) post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre
                
                local mat_size = wordcount(e(xvars)) 
                matrix B = J(1,`mat_size',.)
                forval b = 1/`mat_size' {
                matrix B[1,`b'] = A[1,1]
                }
                estadd matrix B

                if `q'==6 {
                    // model 1
                    _eststo `var'_1ldo_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester) /// 
                    if `subsample' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)

                    // model 2
                    _eststo `var'_2ldo_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester) /// 
                    if `subsample' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)

                    // model 3
                    _eststo `var'_3ldo_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    c.tally_sexualorientation ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester) /// 
                    if `subsample' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)
                }
            }
        }
        }	

        // write estimates
        {
            // OLS
            cap estwrite *_1_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'1", append 
            cap estwrite *_2_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'2", append
            cap estwrite *_3_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'3", append

            // logit
            cap estwrite *_1l_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'1l", append 
            cap estwrite *_2l_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'2l", append
            cap estwrite *_3l_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'3l", append

            if `q'==6 {
                // OLS
                cap estwrite *_1d_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'1", append 
                cap estwrite *_2d_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'2", append
                cap estwrite *_3d_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'3", append

                // logit
                cap estwrite *_1ldo_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'1l", append 
                cap estwrite *_2ldo_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'2l", append
                cap estwrite *_3ldo_*`name' using "log/estimates/main_`yr_name'`yr_end_name'`name'3l", append
            }
        }
        eststo clear
    }
    eststo clear
    }
    }
    eststo clear
    }

    log close
}

// stacked DD (focus on state YRBS)
if 1 {
    // continuous stacked DD (ENDS tax, [cigarette tax,] flavor ban), "regular" stacked for MLSA
    if 1 {
        // treatment stacks created conditional on lgbq information
        use "data/final/master_set_2023", clear

        // leads and lags (subject to change depending on TWFE construction)
        {
            // semester-based events
            {
                preserve
                use "data/inter/master_control2023_semester", clear
                keep fips year_true semester ends_tax_nom35_scale cigarette_tax_scale flavor_ban
                save "data/inter/mctemp", replace
                
                use "${path_cheps_google}/datasets/yrbs/data/clean/stateyrbs_timing_output", clear
                sort fips year
                drop if year_true == .
                
                merge 1:1 fips year_true semester using "data/inter/mctemp"
                erase                                   "data/inter/mctemp.dta"
                drop _merge
                sort fips year_true semester
                
                replace year = 0 if year == .
            
                foreach var of varlist ends_tax_nom35_scale cigarette_tax_scale flavor_ban {
                    // var name
                    {
                        if "`var'"=="ends_tax_nom35_scale" local name_var ends
                        if "`var'"=="cigarette_tax_scale"  local name_var cig
                        if "`var'"=="flavor_ban"           local name_var flav
                    }

                    bys fips: gen L0 = `var'[_n] - `var'[_n - 1]
                    replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010
                
                    // lags
                    forval i = 0/7 {
                        bys fips: gen semlag`i'_`name_var' = L0[_n - `i']
                        replace semlag`i'_`name_var' = 0 ///
                        if semlag`i'_`name_var' == .
                    }
                    
                    // leads
                    forval i = 1/12 {
                        bys fips: gen semlead`i'_`name_var' = L0[_n + `i']
                        replace semlead`i'_`name_var' = 0 ///
                        if semlead`i'_`name_var' == .      // assume future tax holds constant
                        sort fips year_true semester
                    }

                    order ///
                    semlead12_`name_var' semlead11_`name_var' semlead10_`name_var' semlead9_`name_var' ///
                    semlead8_`name_var'  semlead7_`name_var'  semlead6_`name_var'  semlead5_`name_var' ///
                    semlead4_`name_var'  semlead3_`name_var'  semlead2_`name_var'  semlead1_`name_var', after(L0)
                
                    gen semleadyr_3_`name_var' = semlead12_`name_var' + semlead11_`name_var' + semlead10_`name_var' + semlead9_`name_var' // [-6,-5]
                    gen semleadyr_2_`name_var' = semlead8_`name_var'  + semlead7_`name_var'  + semlead6_`name_var'  + semlead5_`name_var' // [-4,-3]
                    gen semleadyr_1_`name_var' = semlead4_`name_var'  + semlead3_`name_var'  + semlead2_`name_var'  + semlead1_`name_var' // [-2,-1]
                    gen semlagyr_0_`name_var'  = semlag0_`name_var'   + semlag1_`name_var'   + semlag2_`name_var'   + semlag3_`name_var'  // [0,1]
                    gen semlagyr_1_`name_var'  = semlag4_`name_var'   + semlag5_`name_var'   + semlag6_`name_var'   + semlag7_`name_var'  // [2,3]

                    gen semleadyr_1_og_`name_var' = semleadyr_1_`name_var'

                    label var semleadyr_3_`name_var' "5-6 Years Prior"
                    label var semleadyr_2_`name_var' "3-4 Years Prior"
                    label var semleadyr_1_`name_var' "1-2 Years Prior"
                    label var semlagyr_0_`name_var'  "0-1 Years After"
                    label var semlagyr_1_`name_var'  "2-3 Years After"

                    drop L0
                }

                drop if year == 0
                
                gen national = 0
            
                tempfile leadlag_sem
                save `leadlag_sem', replace
                restore

                macro drop _name_var
            }

            // relative timing events (MLSA)
            {
                preserve

                use "data/inter/master_control2023_semester", clear
                gen semester_date = yh(year_true, semester)
                format semester_date %th
                keep fips year_true semester semester_date any_mlsa_vape
                sort fips semester_date

                // semester-based, relative time --> biennial (don't assume -1 as reference)
                foreach var of varlist any_mlsa_vape {
                    local name_var mlsa
                    // find introduction date
                    {
                        // first differences
                        bys fips: gen `var'_intro_ = `var'[_n] - `var'[_n-1]
                        replace       `var'_intro_ = 0 if missing(`var'_intro_)

                        // grab dates w/ variation
                        replace `var'_intro_ = semester_date if `var'_intro_ != 0
                        replace `var'_intro_ = .             if `var'_intro_ == 0
                        format  `var'_intro_ %th

                        // take earliest date w/ variation
                        bys fips: egen `var'_intro = min(`var'_intro_)
                        drop           `var'_intro_

                        // pre-treatment
                        gen pre_`name_var'_intro = 1 ///
                        if (semester_date < `var'_intro) & !mi(`var'_intro)
                    }
                    gen diff = semester_date - `var'_intro

                    recode diff                          ///
                    (. = 99)                                  /// code missing as 99
                    (-1000/-9 = -3) (-8/-5 = -2) (-4/-1 = -1) ///
                    (0/3 = 0)       (4/1000 = 1)

                    xi i.diff, noomit

                    rename (_I*) (`name_var'_*)
                    rename `name_var'_diff_1 semleadyr_3_`name_var'
                    rename `name_var'_diff_2 semleadyr_2_`name_var'
                    rename `name_var'_diff_3 semleadyr_1_`name_var'
                    rename `name_var'_diff_4 semlagyr_0_`name_var'
                    rename `name_var'_diff_5 semlagyr_1_`name_var'
                    // missing as `name_var'_diff_6

                    gen semleadyr_1_og_`name_var' = semleadyr_1_`name_var'

                    label var semleadyr_3_`name_var' "5-6 Years Prior"
                    label var semleadyr_2_`name_var' "3-4 Years Prior"
                    label var semleadyr_1_`name_var' "1-2 Years Prior"
                    label var semlagyr_0_`name_var'  "0-1 Years After"
                    label var semlagyr_1_`name_var'  "2-3 Years After"

                    drop diff `var'_intro
                    macro drop _name_var
                }

                gen national = 0

                tempfile leadlag_sem_rel
                save `leadlag_sem_rel', replace
                restore
            }

            local num_leads 3
            local num_lags  1 
        }

        // when do we observe treatment?
        {
            // using survey wave timing to define treatment time
            if 0 {
                foreach var of varlist ends_tax_nom35_scale /*cigarette_tax_scale flavor_ban*/ any_mlsa_vape {
                    preserve

                    //if "`var'"=="flavor_ban" keep if !inlist(fips,6,11,25,41)

                    // state-year split, according to state yrbs availability and info on sex-id
                    gcollapse `var' if national==0 & !mi(lgbq_1) [aw=aweight], by(fips state_abbrev year)

                    // state-year cells where we observe "turning on"
                    bys fips: gen introduction = 1 ///
                    if (`var'[_n] - `var'[_n-1] != 0) & (`var' > 0) & (`var'[_n-1] == 0)

                    // identify if there are "always on" states
                    bys fips: egen always_on = min(`var')

                    forval i = 11(2)23 {
                    di "`var' intro in 20`i'"
                    tab state_abbrev if year==20`i' & introduction == 1
                    }

                    di "`var' always on: "
                    tab state_abbrev always_on if always_on!=0

                    restore
                }
            }

            // cigarette tax: no introduction over time

            // flavor ban  
            // using year of treatment to define treatment time
            foreach var of varlist flavor_ban {
                preserve
                
                use "data/inter/master_control2023_semester.dta", clear
                gen `var'_indicator = (`var' > 0) & !mi(`var')
	            egen `var'_year = csgvar(`var'_indicator), ivar(fips) tvar(year_true)

                keep fips year_true semester `var'_year

                tempfile `var'_year
                save    ``var'_year'

                restore

                merge m:1 fips year_true semester using ``var'_year'
                drop if _merge==2
                drop    _merge

                // verify whether states have enough variation
                levelsof `var'_year if `var'_year>0, local(`var'_year_list)
                foreach year of local `var'_year_list {
                    di "`year' `var' introduction"
                    tab year state_abbrev if `var'_year==`year' & !national & !mi(lgbq_1)
                }

                // set PA to zero -- temporary ban
                replace `var'_year=0 if state_abbrev=="PA"
            }
            /*
                // with survey wave timing
                {
                    2011 (0)

                    2013 (0)

                    2015 (0)

                    2017 (0)
                    
                    2019 (0)

                    2021 (6)
                    IL, MD, NJ, NY, RI, UT

                    2023 (0)

                    always on (1)
                    MA
                }

                // with introduction year timing
                {
                    2016 intro: 
                    MA -- no (always on)

                    2018 intro:
                    CA -- no (remove CA from sample)

                    2019 intro:
                    NY -- yes
                    PA -- no (temporary ban)
                    RI -- yes

                    2020 intro:
                    IL -- yes
                    MD -- yes
                    NJ -- yes
                    UT -- yes

                    // 2019: NY, RI
                    // 2020: IL,MD,NJ,UT
                }
            */     
        }

        // merge events, set reference
        {
            merge m:1 fips year national using `leadlag_sem'
            drop _merge

            merge m:1 fips year_true semester national using `leadlag_sem_rel'
            drop _merge

            foreach name_var in ends cig flav mlsa {
                replace semleadyr_1_`name_var' = 0
            }
        }

        compress

        // reduce data size 
        {
            keep ///
            fips state_abbrev year year_true semester national pre_etax_intro pre_mlsa_intro flavor_ban_year ///
            aweight ///
            sex grade age race4 lgbq_1 sex_orientation ///
            vape fvape dvape smoke fsmoke dsmoke cigar fcigar dcigar combust fcombust dcombust ///
            uer povertyrate coviddeaths* covid_cases_cu_rate* ///
            populationvaccinated* governmentresponseindex* stringencyindex* containmenthealthindex* ///
            ends_tax_nom35_scale flavor_ban any_mlsa_vape t21 cigarette_tax_scale ///
            ecigs_lis_law_any indoor_ban_vape ecigban ///
            indoor_ban_smoke tobacco_lis_law_any ///
            naloxone samaritan_alc beer_tax_scale RML MML ///
            tally_sexualorientation* ///
            lgbq_1* ///
            semleadyr_3_* semleadyr_2_* semleadyr_1_* semlagyr_0_* semlagyr_1_* semleadyr_1_og_*

            keep if inrange(year,2011,2023) & !national
        }

        save "data/inter/stacked_main_2023", replace


        // regressions:
        cap log close
        log using "log/regressions/stacked_did_cont.smcl", /*replace*/ append

        local iter = 0

        foreach policy in ends mlsa flav {
            local iter = `iter'+1
            // policy-specific
            {
                if "`policy'"=="ends" {
                    local policy_var ends_tax_nom35_scale
                    local policy_num 1
                    local policy_name "ENDS Tax Increase"
                    local fe_stack cohort
                    local sample_flavor 1

                    local vars_essential_coef1 /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale
                }
                if "`policy'"=="mlsa" {
                    local policy_var any_mlsa_vape
                    local policy_num 2
                    local policy_name "MLSA Law"
                    local fe_stack treat_year
                    local sample_flavor 1

                    local vars_essential_coef1 c.ends_tax_nom35_scale c.flavor_ban /*c.any_mlsa_vape*/ i.t21 c.cigarette_tax_scale
                }
                if "`policy'"=="flav" {
                    local policy_var flavor_ban
                    local policy_num 3
                    local policy_name "ENDS Flavor Ban"
                    local fe_stack cohort
                    local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR

                    local vars_essential_coef1 c.ends_tax_nom35_scale /*c.flavor_ban*/ c.any_mlsa_vape i.t21 c.cigarette_tax_scale
                }

                global dem_control i.sex i.grade i.age i.race4
                local vars_essential_coef0 c.uer c.coviddeaths c.populationvaccinated $dem_control
            }

            // create and append stacks (need ~ 15 GBs free to create ENDS tax stack)
            {
                if "`policy'"=="ends" { // ENDS tax

                    use "data/inter/stacked_main_2023", clear

                    // cohort 1: 2015 (NC)
                    {
                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2015 - (2 * `num_leads')) & (year <= 2017)

                        // drop states that adopted in 2017
                        drop if inlist(state_abbrev,"CA","IL","KS","LA","MD","PA","WV")

                        // drop states that already adopted by 2015
                        // --> no states in State YRBS pre-2015

                        // edit leads/lags (all states that don't turn on policy by 2015 will be 'untreated', so no leads and lags)
                        foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                        replace `var' = 0 if state_abbrev != "NC"
                        }

                        // generate important vars
                        gen cohort       = 27
                        gen stack_weight = 1    // only 1 treated state
                        gen treat_year   = 2015

                        // save file for appending
                        save "data/inter/NC", replace
                    }

                    use "data/inter/stacked_main_2023", clear

                    // cohort 2: 2017 (CA, IL, MD, PA, WV)
                    {
                        // remove KS and LA b/c no sex-id info

                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2017 - (2 * `num_leads')) & (year <= 2019)

                        // drop states already adopted by 2017
                        drop if state_abbrev == "NC"

                        // drop states that adopted in 2019
                        drop if inlist(state_abbrev,"NJ")

                        // create stack and save
                        levelsof state_abbrev if inlist(state_abbrev,"CA","IL","MD","PA","WV"), local(states2017)
                        foreach st of local states2017 {
                            preserve

                            // keep single 2017 treated state at a time 
                            drop if inlist(state_abbrev,"CA","IL","MD","PA","WV") & state_abbrev != "`st'"

                            // all states 'untreated' so all leads/lags are 0
                            foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                                replace `var' = 0 if state_abbrev != "`st'"
                            }

                            // generate other vars
                            qui sum fips if state_abbrev == "`st'", meanonly
                            local fips = r(mean)
                            
                            gen cohort       = `fips'
                            gen stack_weight = 1 // stack_weight is 1 b/c each treatment state has different magnitude of treatment
                            gen treat_year   = 2017

                            // save
                            save "data/inter/`st'", replace

                            restore
                        }
                    }

                    use "data/inter/stacked_main_2023", clear

                    // cohort 3: 2019 (NM)
                    {
                        // remove NJ because we don't have sufficient pre-treatment info

                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2019 - (2 * `num_leads')) & (year <= 2021)

                        // drop states already adopted by 2019
                        drop if state_abbrev == "NC"
                        drop if inlist(state_abbrev,"CA","IL","MD","PA","WV")

                        // drop states that adopt in 2021
                        drop if inlist(state_abbrev,"CO","CT","DE","KY","ME","NH","NV") ///
                        | inlist(state_abbrev,"NY","UT","VA","VT","WI")
                        // max arguments for 'inlist' = 10

                        // create stack and save
                        levelsof state_abbrev if inlist(state_abbrev,"NJ"), local(states2019)
                        foreach st of local states2019 {
                            preserve

                            // keep one 2019 treated state at a time 
                            drop if inlist(state_abbrev,"NJ") & state_abbrev != "`st'"

                            // all states 'untreated' so all leads/lags are 0
                            foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                                replace `var' = 0 if state_abbrev != "`st'"
                            }

                            // generate other vars
                            qui sum fips if state_abbrev == "`st'", meanonly
                            local fips = r(mean)
                            
                            gen cohort       = `fips'
                            gen stack_weight = 1 // stack_weight is 1 b/c each treatment state has different magnitude of treatment
                            gen treat_year   = 2019

                            // save
                            save "data/inter/`st'", replace

                            restore

                        } 
                    }

                    use "data/inter/stacked_main_2023", clear

                    // cohort 4: 2021 (CO, CT, DE, KY, ME, NH, NV, NY, UT, VA, VT, WI)
                    {
                        // remove GA b/c no LGBQ info 

                        // trim sample
                        keep if (year >= 2021 - (2 * `num_leads')) & (year <= 2023)

                        // drop states already adopted by 2021
                        drop if state_abbrev == "NC"
                        drop if inlist(state_abbrev,"CA","IL","MD","PA","WV")
                        drop if inlist(state_abbrev,"NJ")

                        // drop states that adopt in 2023
                        drop if state_abbrev=="IN"

                        // create stack and save
                        levelsof state_abbrev if ///
                        inlist(state_abbrev,"CO","CT","DE","KY","ME","NH","NV") | ///
                        inlist(state_abbrev,"NY","UT","VA","VT","WI"), local(states2021)
                        foreach st of local states2021 {
                            preserve

                            // keep one 2021 treated state at a time
                            drop if ///
                            ( inlist(state_abbrev,"CO","CT","DE","KY","ME","NH","NV") ///
                            | inlist(state_abbrev,"NY","UT","VA","VT","WI")) & (state_abbrev != "`st'")

                            // all states 'untreated' so all lead/lags are 0
                            foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                                replace `var' = 0 if state_abbrev != "`st'"
                            }

                            // generate other vars
                            qui sum fips if state_abbrev == "`st'", meanonly
                            local fips = r(mean)
                            
                            gen cohort       = `fips'
                            gen stack_weight = 1 // stack_weight is 1 b/c each treatment state has different magnitude of treatment
                            gen treat_year   = 2021

                            // save
                            save "data/inter/`st'", replace

                            restore
                        }
                    }

                    // cohort 5: 2023 ()
                    // too close to end of sample period

                    // append stacks, drop always on states
                    {
                        // 2021
                        foreach st of local states2021 {
                        if "`st'"=="CO" use          "data/inter/`st'", clear
                        else            append using "data/inter/`st'"
                        }

                        // 2019
                        foreach st of local states2019 {
                        append using "data/inter/`st'"
                        }

                        // 2017
                        foreach st of local states2017 {
                        append using "data/inter/`st'"
                        }

                        // 2015
                        append using "data/inter/NC"

                        // erase tempfiles
                        forval year = 17(2)21 {
                        foreach st of local states20`year' {
                        erase "data/inter/`st'.dta"
                        }
                        }
                        erase "data/inter/NC.dta"

                        // always on states
                        drop if inlist(state_abbrev, "KS", "MA", "NJ")
                    }
                }

                if "`policy'"=="flav" { // flavor bans 
                    // using true year of flavor ban introduction

                    use "data/inter/stacked_main_2023", clear

                    // IL is only treatment state with non 0/1 values during survey years
                    // go with continuous approach 
                
                    // cohort 1: 2019 (NY, RI)
                    {
                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2019 - (2 * `num_leads')) & (year <= 2021)

                        // drop states in 2020 cohort
                        drop if flavor_ban_year==2020

                        // drop states already adopted by 2019
                        // nobody else

                        // edit leads/lags
                        foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                        replace `var' = 0 if flavor_ban_year!=2019
                        }

                        // create stack and save
                        local flavor_2019_st NY RI
                        foreach st of local flavor_2019_st {
                            preserve

                            // keep single treated state at a time 
                            drop if flavor_ban_year==2019 & state_abbrev != "`st'"

                            // all states 'untreated' so all leads/lags are 0
                            foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                                replace `var' = 0 if state_abbrev != "`st'"
                            }

                            // generate other vars
                            qui sum fips if state_abbrev == "`st'", meanonly
                            local fips = r(mean)
                            
                            gen cohort       = `fips'
                            gen stack_weight = 1 // stack_weight is 1 b/c each treatment state has different magnitude of treatment
                            gen treat_year   = 2019

                            // save
                            save "data/inter/`st'", replace

                            restore
                        }
                    }
                    // where are IL and MD in the reg?

                    // cohort 2: 2020 (IL,MD,NJ,UT)
                    {
                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2020 - (2 * `num_leads')) & (year <= 2023) 
                        // this is slightly different here because 2020 is in between survey years 
                        // technically 3 years post instead of 2, but still 2 periods of post-intro data

                        // drop states in future cohort
                        // no future cohort

                        // drop states already adopted by 2020
                        drop if flavor_ban_year==2019

                        // edit leads/lags
                        foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                        replace `var' = 0 if flavor_ban_year!=2020
                        }

                        // create stack and save
                        local flavor_2020_st IL MD NJ UT
                        foreach st of local flavor_2020_st  {
                            preserve

                            // keep single treated state at a time 
                            drop if flavor_ban_year==2020 & state_abbrev != "`st'"

                            // all states 'untreated' so all leads/lags are 0
                            foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                                replace `var' = 0 if state_abbrev != "`st'"
                            }

                            // generate other vars
                            qui sum fips if state_abbrev == "`st'", meanonly
                            local fips = r(mean)
                            
                            gen cohort       = `fips'
                            gen stack_weight = 1 // stack_weight is 1 b/c each treatment state has different magnitude of treatment
                            gen treat_year   = 2020

                            // save
                            save "data/inter/`st'", replace

                            restore
                        }
                    }

                    // append stacks
                    {
                        // 2020
                        foreach st of local flavor_2020_st {
                            if "`st'"=="IL" use "data/inter/`st'", clear
                            else   append using "data/inter/`st'"
                        }

                        // 2019
                        foreach st of local flavor_2019_st {
                            append using "data/inter/`st'"
                        }

                        // erase tempfiles
                        forval year=2019/2020 {
                        foreach st of local flavor_`year'_st {
                        erase "data/inter/`st'.dta"
                        }
                        }
                    }
                }

                if "`policy'"=="cig" { // cigarette taxes ?
                // no introducers over time period 
                }

                if "`policy'"=="mlsa" { // ENDS MLSA
                    // MLSA
                    /*
                        // without conditional on lgbq info
                        {
                            2011 (0)

                            2013 (11)
                            AK, HI, ID, KS, MD, MS, NY, SC, TN, WI, WY

                            2015 (19)
                            AL, AR, AZ, CT, DE, FL, IL, IN, KY, MO, NC, NE, NM, OK, RI, SD, VA, VT, WV

                            2017 (6)
                            IA, LA, MT, ND, NV, TX

                            2019 (2)
                            GA, ME

                            2021 (2)
                            MI, PA

                            2023 (0)

                            always on (6)
                            CA, CO, MA, NH, NJ, UT
                        }
                        // conditional on lgbq info
                        {
                            2011 (0)

                            2013 (2)
                            HI, WI

                            2015 (9)
                            AZ, CT, DE, FL, IL, NC, NM, RI, VT

                            2017 (2)
                            ND, NV

                            2019 (1)
                            ME

                            2021 (2)
                            MI, PA

                            2023 (0)

                            always on (23)
                            AL, AR, CA, CO, IA, IN, KS, KY, MA, MD, MO, MS, NE, NH, NJ, NY, OK, SC, TX, UT, VA, WV, WY
                        }
                    */

                    use "data/inter/stacked_main_2023", clear

                    // cohort 0: 2013 (HI, WI) [2]
                    {
                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2013 - (2 * `num_leads')) & (year <= 2015)

                        // drop states who adopt pre-2013
                        // nobody

                        // drop states who adopt in 2015
                        drop if inlist(state_abbrev, "AZ", "CT", "DE", "FL", "IL", "NC", "NM", "RI", "VT")

                        // all other states 'untreated' so lead/lags are zero
                        foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                            replace `var' = 0 ///
                            if !inlist(state_abbrev, "HI", "WI")
                        }

                        gen stack_weight = 1
                        gen treat_year = 2013

                        save "data/inter/cohort0.dta", replace
                    }

                    use "data/inter/stacked_main_2023", clear

                    // cohort 1: 2015 (AZ, CT, DE, FL, IL, NC, NM, RI, VT) [9]
                    {
                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2015 - (2 * `num_leads')) & (year <= 2017)

                        // drop states who adopt pre-2015
                        drop if ///
                        inlist(state_abbrev, "HI", "WI")

                        // drop states who adopt in 2017
                        drop if inlist(state_abbrev, "ND", "NV")

                        // all other states 'untreated' so lead/lags are zero
                        foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                            replace `var' = 0 ///
                            if !inlist(state_abbrev, "AZ", "CT", "DE", "FL", "IL", "NC", "NM", "RI", "VT")
                        }

                        gen stack_weight = 1
                        gen treat_year = 2015

                        save "data/inter/cohort1.dta", replace
                    }

                    use "data/inter/stacked_main_2023", clear

                    // cohort 2: 2017 (ND, NV) [2]
                    {
                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2017 - (2 * `num_leads')) & (year <= 2019)

                        // drop states who adopt pre-2017
                        drop if ///
                        inlist(state_abbrev, "HI", "WI") | ///
                        inlist(state_abbrev, "AZ", "CT", "DE", "FL", "IL", "NC", "NM", "RI", "VT")

                        // drop states who adopt in 2019
                        drop if inlist(state_abbrev, "ME")

                        // all other states 'untreated' so lead/lags are zero
                        foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                            replace `var' = 0 ///
                            if !inlist(state_abbrev, "ND", "NV")
                        }

                        gen stack_weight = 1
                        gen treat_year = 2017

                        save "data/inter/cohort2.dta", replace
                    }

                    use "data/inter/stacked_main_2023", clear

                    // cohort 3: 2019 (ME) [1]
                    {
                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2019 - (2 * `num_leads')) & (year <= 2021)

                        // drop states who adopt pre-2019
                        drop if ///
                        inlist(state_abbrev, "HI", "WI") | ///
                        inlist(state_abbrev, "AZ", "CT", "DE", "FL", "IL", "NC", "NM", "RI", "VT") | ///
                        inlist(state_abbrev, "ND", "NV")

                        // drop states who adopt in 2021
                        drop if inlist(state_abbrev, "MI", "PA")

                        // all other states 'untreated' so lead/lags are zero
                        foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                            replace `var' = 0 ///
                            if !inlist(state_abbrev, "ME")
                        }

                        gen stack_weight = 1
                        gen treat_year = 2019

                        save "data/inter/cohort3.dta", replace
                    }

                    use "data/inter/stacked_main_2023", clear

                    // cohort 4: 2021 (MI, PA) [2]
                    {
                        // trim sample s.t. same number of leads and lags
                        keep if (year >= 2021 - (2 * `num_leads')) & (year <= 2023)

                        // drop states who adopt pre-2021
                        drop if ///
                        inlist(state_abbrev, "HI", "WI") | ///
                        inlist(state_abbrev, "AZ", "CT", "DE", "FL", "IL", "NC", "NM", "RI", "VT") | ///
                        inlist(state_abbrev, "ND", "NV") | ///
                        inlist(state_abbrev, "ME")

                        // drop states who adopt in 2023
                        // nobody

                        // all other states 'untreated' so lead/lags are zero
                        foreach var of varlist semleadyr_?_`policy' semlagyr_?_`policy' {
                            replace `var' = 0 ///
                            if !inlist(state_abbrev, "MI", "PA")
                        }

                        gen stack_weight = 1
                        gen treat_year = 2021

                        save "data/inter/cohort4.dta", replace
                    }

                    // append stacks, drop always on states
                    {
                        use          "data/inter/cohort0", clear
                        append using "data/inter/cohort1"
                        append using "data/inter/cohort2"
                        append using "data/inter/cohort3"
                        append using "data/inter/cohort4"

                        forval i=0/4{
                            erase "data/inter/cohort`i'.dta"
                        }

                        // always on states
                        drop if inlist(state_abbrev, "AL", "AR", "CA", "CO", "IA", "IN", "KS", "KY", "MA") | ///
                        inlist(state_abbrev, "MD", "MO", "MS", "NE", "NH", "NJ", "NY", "OK", "SC") | ///
                        inlist(state_abbrev, "TX", "UT", "VA", "WV", "WY")
                    }
                }

                if `iter'==3 erase "data/inter/stacked_main_2023.dta"
            }
        
            // weighting
            gen int_weight = aweight * stack_weight

            compress

            if 0 { // tester regs for: ENDS tax, het, fsmoke; MLSA, lgbq, fsmoke; 
                if `iter'==1 log using "log/regressions/stacked_did_cont_extra.smcl", append
                local var fsmoke
                
                if "`policy'"=="ends" {
                    { // use 'difficult' 
                        // point estimate: heterosexuals, fsmoke, m3 
                        logit `var' ///
                        `policy_var' /// 
                        `vars_essential_coef1' `vars_essential_coef0' ///
                        ${vars_lasso_sel_`var'y1} ///
                        c.tally_sexualorientation ///
                        i.fips i.year_true i.semester ///
                        i.`fe_stack'#i.fips i.`fe_stack'#i.year_true ///
                        if lgbq_1==0 & inrange(year,2011,2023) & `sample_flavor' ///
                        [pw=int_weight], vce(cluster fips) iterate(20) difficult

                        scalar converge_pre = e(converged)

                        _eststo y1s_m3_`var'_id_ht`policy_num'_a: ///
                        margins, dydx(`policy_var') post
                        estadd scalar converge = converge_pre
                        // Does not help

                        /*
                        // fully-diff: fsmoke, m3
                        _eststo y1s_m3do_`var'_all`policy_num'_a: ///
                        logit `var' ///
                        lgbq_1##( ///
                        c.`policy_var' /// 
                        `vars_essential_coef1' `vars_essential_coef0' ///
                        ${vars_lasso_sel_`var'y1} ///
                        c.tally_sexualorientation ///
                        i.fips i.year_true i.semester ///
                        i.`fe_stack'#i.fips i.`fe_stack'#i.year_true) ///
                        if !mi(lgbq_1) & inrange(year,2011,2023) & `sample_flavor' ///
                        [pw=int_weight], vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)
                        */
                        // OLS
                    }
                    { // use OLS
                        // fully-diff: fsmoke, m3
                        _eststo y1s_m3d_`var'_all`policy_num'_a: ///
                        reghdfe `var' ///
                        lgbq_1##( ///
                        c.`policy_var' /// 
                        `vars_essential_coef1' `vars_essential_coef0' ///
                        ${vars_lasso_sel_`var'y1} ///
                        c.tally_sexualorientation ///
                        if !mi(lgbq_1) & inrange(year,2011,2023) & `sample_flavor' ///
                        [aw=int_weight], 
                        absorb(fips year_true semester ///
                        lgbq_1#fips lgbq_1#year_true lgbq_1#semester ///
                        lgbq_1#`fe_stack'#fips lgbq_1#`fe_stack'#year_true)
                        vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)
                    }
                }
                if "`policy'"=="mlsa" { 
                    { // use difficult
                        // point estimate: lgbq, fsmoke, m3 
                        logit `var' ///
                        `policy_var' /// 
                        `vars_essential_coef1' `vars_essential_coef0' ///
                        ${vars_lasso_sel_`var'y1} ///
                        c.tally_sexualorientation ///
                        i.fips i.year_true i.semester ///
                        i.`fe_stack'#i.fips i.`fe_stack'#i.year_true ///
                        if lgbq_1==1 & inrange(year,2011,2023) & `sample_flavor' ///
                        [pw=int_weight], vce(cluster fips) iterate(15) difficult

                        scalar converge_pre = e(converged)

                        _eststo y1s_m3_`var'_id_nh1`policy_num'_a: ///
                        margins, dydx(`policy_var') post
                        estadd scalar converge = converge_pre


                        // fully diff: fsmoke, m3 
                        _eststo y1s_m3do_`var'_all`policy_num'_a: ///
                        logit `var' ///
                        lgbq_1##( ///
                        c.`policy_var' /// 
                        `vars_essential_coef1' `vars_essential_coef0' ///
                        ${vars_lasso_sel_`var'y1} ///
                        c.tally_sexualorientation ///
                        i.fips i.year_true i.semester ///
                        i.`fe_stack'#i.fips i.`fe_stack'#i.year_true) ///
                        if !mi(lgbq_1) & inrange(year,2011,2023) & `sample_flavor' ///
                        [pw=int_weight], vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)
                    }
                }
                if "`policy'"=="flav" { 
                    { // use difficult 
                        // fully diff: fsmoke, m3 
                        _eststo y1s_m3do_`var'_all`policy_num'_a: ///
                        logit `var' ///
                        lgbq_1##( ///
                        c.`policy_var' /// 
                        `vars_essential_coef1' `vars_essential_coef0' ///
                        ${vars_lasso_sel_`var'y1} ///
                        c.tally_sexualorientation ///
                        i.fips i.year_true i.semester ///
                        i.`fe_stack'#i.fips i.`fe_stack'#i.year_true) ///
                        if !mi(lgbq_1) & inrange(year,2011,2023) & `sample_flavor' ///
                        [pw=int_weight], vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)
                    }
                }
                if `iter'==3 cap log close
            }

            // estimation 
            local events     semleadyr_3_`policy' semleadyr_2_`policy' semleadyr_1_`policy'    semlagyr_0_`policy' semlagyr_1_`policy'
            local events_adj semleadyr_3_`policy' semleadyr_2_`policy' semleadyr_1_og_`policy' semlagyr_0_`policy' semlagyr_1_`policy'
            tokenize "`events'"
            {
                set matsize 5000
                eststo clear 
                estimates clear

                foreach yr in 1 5 {
                foreach subsample in lgbq_1==0 lgbq_1==1 !mi(lgbq_1) {
                    // subsample-specifics
                    {
                        if "`subsample'" == "lgbq_1==0"   local s_name "id_ht"
                        if "`subsample'" == "lgbq_1==1"   local s_name "id_nh1"
                        if "`subsample'" == "!mi(lgbq_1)" local s_name 
                        // this wasn't supposed to be blank, but b/c of a previous error now is blank (+ I don't want to re-run)
                    }
                foreach var in vape fvape dvape smoke fsmoke dsmoke {

                    // denote lasso vars
                    {
                        if inlist("`var'","vape","fvape","dvape") ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'}

                        else ///
                        local vars_lasso_sel ${vars_lasso_sel_`var'y`yr'}
                    }

                    // skip patterns
                    {
                        if inlist("`var'","vape","fvape","dvape") & (`yr'==1) continue
                        if inlist("`var'","smoke","fsmoke","dsmoke") & (`yr'==5) continue
                    }

                    // pre-treatment mean
                    {
                        if "`policy'"=="ends" ///
                        summarize `var' if pre_etax_intro == 1 & !mi(pre_etax_intro) & `subsample' ///
                        & inrange(year,201`yr',2023) & `sample_flavor' [aw=aweight], meanonly	

                        if "`policy'"=="mlsa" ///
                        summarize `var' if pre_mlsa_intro == 1 & !mi(pre_mlsa_intro) & `subsample' ///
                        & inrange(year,201`yr',2023) & `sample_flavor' [aw=aweight], meanonly	

                        if "`policy'"=="flav" ///
                        summarize `var' if (year < flavor_ban_year) & flavor_ban_year!=0 & `subsample' ///
                        & inrange(year,201`yr',2023) & `sample_flavor' [aw=aweight], meanonly	

                        scalar pre_treat_mean = r(mean)
                    }

                    forval m = 1/3 {
                        // model-specifics (***)
                        {
                            if `m'==1 /// essential vars
                            local vars_controls `vars_essential_coef1' `vars_essential_coef0'

                            if `m'==2 /// essential vars + LASSO
                            local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel'

                            if `m'==3 /// essential vars + LASSO + LGBQ policy
                            local vars_controls `vars_essential_coef1' `vars_essential_coef0' `vars_lasso_sel' c.tally_sexualorientation 
                        }


                        if 1 { // point estimate (shouldn't really have the "s" in estimate name -- artifact from semester-based event study)
                            // logit 
                            if 1 {
                                // `fe_stack' X state FE and `fe_stack' X year_true FE
                                logit `var' ///
                                `policy_var' /// 
                                `vars_controls' ///
                                i.fips i.year_true i.semester ///
                                i.`fe_stack'#i.fips i.`fe_stack'#i.year_true ///
                                if `subsample' & inrange(year,201`yr',2023) & `sample_flavor' ///
                                [pw=int_weight], vce(cluster fips) iterate(15)

                                scalar converge_pre = e(converged)

                                _eststo y`yr's_m`m'_`var'_`s_name'`policy_num': ///
                                margins, dydx(`policy_var') post
                                estadd scalar pre_treat_mean = pre_treat_mean
                                estadd scalar converge = converge_pre


                                // treat_year FE on its own (look for similarity as justification for event study approach in ENDS taxes)
                                {
                                    logit `var' ///
                                    `policy_var' /// 
                                    `vars_controls' ///
                                    i.fips i.year_true i.semester ///
                                    i.treat_year ///
                                    if `subsample' & inrange(year,201`yr',2023) & `sample_flavor' ///
                                    [pw=int_weight], vce(cluster fips) iterate(15)

                                    scalar converge_pre = e(converged)

                                    _eststo y`yr's_m`m'_`var'_`s_name'_t`policy_num': ///
                                    margins, dydx(`policy_var') post
                                    estadd scalar pre_treat_mean = pre_treat_mean
                                    estadd scalar converge = converge_pre
                                }

                                if "`subsample'"=="!mi(lgbq_1)" & !("`policy'"=="ends" & inlist("`var'","smoke","fsmoke","dsmoke")) {
                                    _eststo y`yr's_m`m'do_`var'_`s_name'`policy_num': ///
                                    logit `var' ///
                                    lgbq_1##( ///
                                    c.`policy_var' /// 
                                    `vars_controls' ///
                                    i.fips i.year_true i.semester ///
                                    i.`fe_stack'#i.fips i.`fe_stack'#i.year_true) ///
                                    if `subsample' & inrange(year,201`yr',2023) & `sample_flavor' ///
                                    [pw=int_weight], vce(cluster fips) iterate(15)
                                    estadd scalar converge = e(converged)
                                }
                            }

                            // ols
                            if 1 {
                                _eststo oy`yr's_m`m'_`var'_`s_name'`policy_num': ///
                                reghdfe `var' ///
                                `policy_var' /// 
                                `vars_controls' ///
                                if `subsample' & inrange(year,201`yr',2023) & `sample_flavor' ///
                                [aw=int_weight], ///
                                absorb(fips year_true semester i.`fe_stack'#i.fips i.`fe_stack'#i.year_true) ///
                                vce(cluster fips) nosample

                                if "`subsample'"=="!mi(lgbq_1)" {
                                    _eststo oy`yr's_m`m'do_`var'_`s_name'`policy_num': ///
                                    reghdfe `var' ///
                                    lgbq_1##( ///
                                    c.`policy_var' /// 
                                    `vars_controls') ///
                                    if `subsample' & inrange(year,201`yr',2023) & `sample_flavor' ///
                                    [aw=int_weight], ///
                                    absorb(fips year_true semester ///
                                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester ///
                                    lgbq_1#`fe_stack'#fips lgbq_1#`fe_stack'#year_true) ///
                                    vce(cluster fips) nosample
                                }
                            }
                        }

                        if 1 { // event study (semester based events)
                        if "`subsample'"!="!mi(lgbq_1)" {
                            logit `var' ///
                            `events' /// 
                            `vars_controls' ///
                            i.fips i.year_true i.semester ///
                            i.`fe_stack'#i.fips i.`fe_stack'#i.year_true ///
                            if `subsample' & inrange(year,201`yr',2023) & `sample_flavor' ///
                            [pw=int_weight], vce(cluster fips) iterate(15)

                            scalar converge_pre = e(converged)
                            matrix A = e(converged)

                            _eststo esy`yr's_m`m'_`var'_`s_name'`policy_num': ///
                            margins, dydx(`events') post
                            estadd scalar pre_treat_mean = pre_treat_mean
                            estadd scalar converge = converge_pre

                            local mat_size = wordcount(e(xvars)) 
                            matrix B = J(1,`mat_size',.)
                            forval b = 1/`mat_size' {
                            matrix B[1,`b'] = A[1,1]
                            }
                            estadd matrix B

                            // delta method
                            {
                                xlincom ///
                                ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -6,-5 lead
                                (          (_b[`2'] + _b[`3']) / 2) /// -4,-3 lead
                                (                    (_b[`3']) / 1) /// -2,-1 lead
                                ((_b[`4'])                     / 1) ///  0,1  lag   
                                ((_b[`4'] + _b[`5'])           / 2) ///  2,3  lag
                                , post level(95)
                                _eststo esdy`yr's_m`m'_`var'_`s_name'`policy_num'
                            }

                            // OLS
                            _eststo esoy`yr's_m`m'_`var'_`s_name'`policy_num': ///
                            reghdfe `var' ///
                            `events' /// 
                            `vars_controls' ///
                            if `subsample' & inrange(year,201`yr',2023) & `sample_flavor' ///
                            [aw=int_weight], ///
                            absorb(fips year_true semester i.`fe_stack'#i.fips i.`fe_stack'#i.year_true) ///
                            vce(cluster fips) nosample

                            // constrained linear regression (with treat_year FE instead of `fe_stack' x state, `fe_stack' x year) 
                            {
                                constraint 1 (semleadyr_3_`policy' + semleadyr_2_`policy' + semleadyr_1_og_`policy') / 3 = 0

                                _eststo escy`yr's_m`m'_`var'_`s_name'`policy_num': ///
                                cnsreg `var' ///
                                `events_adj' ///
                                `vars_controls' ///
                                i.fips i.year_true i.semester ///
                                i.treat_year ///
                                if `subsample' & inrange(year,201`yr',2023) & `sample_flavor' ///
                                [pw=int_weight], constraints(1) vce(cluster fips)
                            }
                        }
                        }
                    }
                }
                
                if "`subsample'" != "!mi(lgbq_1)" estwrite es* using "log/estimates/stacked_did_cont_es", append
                estwrite y*_`s_name'`policy_num'               using "log/estimates/stacked_did_cont_`policy_num'"   , append
                estwrite y*_t`policy_num'                      using "log/estimates/stacked_did_cont_t" , append

                estwrite oy*_`s_name'`policy_num'              using "log/estimates/stacked_did_cont_o_`policy_num'"   , append

                eststo clear
                estimates clear
                }
                }
                
                eststo clear 
                estimates clear
            }

            // event study figures
            if 0 {
                foreach yr in y5 {

                forval m = 1/3 { // model

                eststo clear 
                estimates clear 

                estread es*`yr's_m`m'_*`vari'*`policy_num' using "log/estimates/stacked_did_cont_es"

                foreach s_name in id_ht id_nh1 { // subsample
                foreach var in vape fvape dvape { // dep var
                    // skip pattern
                    if inlist("`var'","vape","fvape","dvape") & "`yr'"=="y1" continue
                    
                    forval adj = 0/8 {
                        // adj-specifics
                        {
                            if `adj'==0 {
                                local name_adj
                                local list_events semleadyr_3_`policy' semleadyr_2_`policy' semleadyr_1_`policy' semlagyr_0_`policy' semlagyr_1_`policy'
                            }
                            if `adj'==1 {
                                local name_adj d
                                local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                            }
                            if `adj'==2 { // generate estimates
                                estimates restore es`yr's_m`m'_`var'_`s_name'`policy_num'

                                // a0: exclude -2-1 from average
                                local preavg = ((_b[semleadyr_3_`policy'] + _b[semleadyr_2_`policy']) / 2)

                                xlincom ///
                                (_b[semleadyr_3_`policy'] - `preavg') /// -6-5 lead
                                (_b[semleadyr_2_`policy'] - `preavg') /// -4-3 lead
                                (_b[semleadyr_1_`policy'])            /// -2-1 lead
                                (_b[semlagyr_0_`policy'] - `preavg')  /// 01   lag
                                (_b[semlagyr_1_`policy'] - `preavg')  /// 23   lag
                                , post level(95)
                                _eststo esa0`yr's_m`m'_`var'_`s_name'`policy_num'

                                local name_adj a0
                                local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                            }
                            if `adj'==3 { // generate estimates
                                estimates restore es`yr's_m`m'_`var'_`s_name'`policy_num'

                                // a1: include -2-1 in average
                                local preavg  = ((_b[semleadyr_3_`policy'] + _b[semleadyr_2_`policy'] + _b[semleadyr_1_`policy']) / 3)

                                xlincom ///
                                (_b[semleadyr_3_`policy'] - `preavg') /// -6-5 lead
                                (_b[semleadyr_2_`policy'] - `preavg') /// -4-3 lead
                                (_b[semleadyr_1_`policy'])            /// -2-1 lead
                                (_b[semlagyr_0_`policy']  - `preavg') /// 01   lag
                                (_b[semlagyr_1_`policy']  - `preavg') /// 23   lag
                                , post level(95)
                                _eststo esa1`yr's_m`m'_`var'_`s_name'`policy_num'

                                local name_adj a1
                                local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                            }
                            if `adj'==4 {
                                local name_adj c
                                local list_events semleadyr_3_`policy' semleadyr_2_`policy' semleadyr_1_og_`policy' semlagyr_0 semlagyr_1_`policy'
                            }
                            if `adj'==5 {
                                local name_adj o
                                local list_events semleadyr_3_`policy' semleadyr_2_`policy' semleadyr_1_`policy' semlagyr_0 semlagyr_1_`policy'
                            }
                            if `adj'==6 { // ols, pretreatment avg as reference, exclusive
                                estimates restore eso`yr's_m`m'_`var'_`s_name'`policy_num'

                                // o0: exclude -2-1 from average
                                local preavg = ((_b[semleadyr_3_`policy'] + _b[semleadyr_2_`policy']) / 2)

                                xlincom ///
                                (_b[semleadyr_3_`policy'] - `preavg') /// -6-5 lead
                                (_b[semleadyr_2_`policy'] - `preavg') /// -4-3 lead
                                (_b[semleadyr_1_`policy'])            /// -2-1 lead
                                (_b[semlagyr_0_`policy'] - `preavg')  /// 01   lag
                                (_b[semlagyr_1_`policy'] - `preavg')  /// 23   lag
                                , post level(95)
                                _eststo eso0`yr's_m`m'_`var'_`s_name'`policy_num'

                                local name_adj o0
                                local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                            }
                            if `adj'==7 { // ols, pretreatment avg as reference, inclusive
                                estimates restore eso`yr's_m`m'_`var'_`s_name'`policy_num'

                                // o0: exclude -2-1 from average
                                local preavg = ((_b[semleadyr_3_`policy'] + _b[semleadyr_2_`policy'] + _b[semleadyr_1_`policy']) / 3)

                                xlincom ///
                                (_b[semleadyr_3_`policy'] - `preavg') /// -6-5 lead
                                (_b[semleadyr_2_`policy'] - `preavg') /// -4-3 lead
                                (_b[semleadyr_1_`policy'])            /// -2-1 lead
                                (_b[semlagyr_0_`policy'] - `preavg')  /// 01   lag
                                (_b[semlagyr_1_`policy'] - `preavg')  /// 23   lag
                                , post level(95)
                                _eststo eso1`yr's_m`m'_`var'_`s_name'`policy_num'

                                local name_adj o1
                                local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                            }
                            if `adj'==8 { // ols, "delta smoothing"
                                estimates restore eso`yr's_m`m'_`var'_`s_name'`policy_num'
                                
                                local      list_events semleadyr_3_`policy' semleadyr_2_`policy' semleadyr_1_`policy' semlagyr_0_`policy' semlagyr_1_`policy'
                                tokenize "`list_events'" 

                                xlincom ///
                                ((_b[`1'] + _b[`2'] + _b[`3']) / 3) /// -6,-5 lead
                                (          (_b[`2'] + _b[`3']) / 2) /// -4,-3 lead
                                (                    (_b[`3']) / 1) /// -2,-1 lead
                                ((_b[`4'])                     / 1) ///  0,1  lag   
                                ((_b[`4'] + _b[`5'])           / 2) ///  2,3  lag
                                , post level(95)
                                _eststo esod`yr's_m`m'_`var'_`s_name'`policy_num'

                                local name_adj od
                                local list_events lc_1 lc_2 lc_3 lc_4 lc_5
                            }

                            macro drop _preavg
                        } 
                    foreach medium in draft /*presentation*/ {
                        if "`medium'" == "draft"        local name_med "dr"
                        if "`medium'" == "presentation" local name_med "pr"		 
                        // y-axis
                        {
                            if "`medium'" == "draft" {
                                if "`s_name'" == "id_ht" {
                                if "`var'" == "vape" local ysca yla(-0.2(0.05)0.2, nogrid)
                                if "`var'" != "vape" local ysca yla(-0.1(0.025)0.1 , nogrid)
                                }
                                if "`s_name'" == "id_nh1" {
                                if "`var'" != "dvape" local ysca yla(-0.25(0.05)0.25, nogrid)
                                if "`var'" == "dvape" local ysca yla(-0.4(0.1)0.4   , nogrid)
                                }

                                if "`var'"=="vape" local ysca yla(-0.150(0.050)0.150, nogrid)
                                if "`var'"!="vape" local ysca yla(-0.075(0.025)0.075, nogrid)
                            }

                            if "`medium'" == "presentation" {
                                if "`s_name'" == "id_ht" {
                                if "`var'" == "vape" local ysca yla(-0.2(0.05)0.2, nogrid)
                                if "`var'" != "vape" local ysca yla(-0.1(0.025)0.1 , nogrid)
                                }
                                if "`s_name'" == "id_nh1" {
                                if "`var'" == "vape" local ysca yla(-0.25(0.05)0.25, nogrid)
                                if "`var'" != "vape" local ysca yla(-0.15(0.05)0.15, nogrid)
                                }
                            }
                        }

                        coefplot(es`name_adj'`yr's_m`m'_`var'_`s_name'`policy_num', ///
                        omitted keep(`list_events') ///
                        recast(connected) lwidth(thin) lcolor(black) color(black)), ///
                        vertical ///
                        title("`converge_local'",) ///
                        graphregion(color(white)) ///
                        ytitle("Estimated Effect of `policy_name'", size(medium)) ///
                        yline(0, lcolor(black)) `ysca' ylabel(, labsize(medium)) ///
                        xtitle("Years Before/After `policy_name'", size(medium)) ///
                        xline(3.5, lpattern(dash) lcolor(black)) ///
                        xlabel(1 "-6,-5" 2 "-4,-3" 3 "-2,1" 4 "0,1" 5 "2,3", labsize(medium)) ///
                        legend(off) ///
                        ciopts(recast(rcap) lwidth(thin)) 

                        graph export "output/etax/graphs/final/stacked_did_cont_`policy'_`name_med'`name_adj'_`var'_`yr'_m`m'_`s_name'.png", replace

                        graph close			
                    }
                    }
                }

                }
                }	
                graph drop _all	
                }
            }

            macro drop _iter
        }
        cap log close
    }

    // prominent stacked DD
    if 1 {
        // create stack
        {
            use "data/inter/master_control2023_semester", clear
            drop if year_true==2024

            // merge MAP policy controls
            {
                preserve
	
                use "${path_cheps_google}/datasets/map_lgbtq/data/clean/policy_tally", clear
                rename year year_true
                rename state_fips fips

                // create quantiles
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

                restore

                merge m:1 fips year_true using `map_policy'
                drop if _merge==2
                drop _merge
            }

            // annual panel
            gcollapse (mean) ///
            ends_tax_nom35 ends_tax_nom35_scale flavor_ban any_mlsa_vape t21 cigarette_tax cigarette_tax_scale ///
            uer coviddeaths populationvaccinated ///
            indoor_ban_vape ecigban indoor_ban_smoke tobacco_lis_law_any MML tally_sexualorientation, ///
            by(fips year_true) labelformat(#sourcelabel#)

            tempfile stack_controls_annual
            save    `stack_controls_annual'

            foreach policy in /*ecigs*/ cigs {
                if "`policy'"=="ecigs" local tax_var_stem ends_tax_nom35
                if "`policy'"=="cigs"  local tax_var_stem cigarette_tax
            forval real = 0/1 {
                // nominal vs real ($2023) tax for stacks
                if `real'==0 local tax_var `tax_var_stem'
                if `real'==1 local tax_var `tax_var_stem'_scale 
            foreach prominent of numlist 10 25 50 75 100 {
            foreach lag_num of numlist 3 {

                local lead 6 // might be too long for this short panel
                local lag `lag_num'

                use `stack_controls_annual', clear

                sort  fips year_true
                xtset fips year_true

                // gen indicator for any ENDS tax
                /* {
                    cap drop ecig_ind
                    assert              (`tax_var' != .)
                    gen      ecig_ind = (`tax_var' >  0)
                    
                    *** distinct fips if (ecig_ind > 0) & (year_true <= 2019) 
                    *** distinct fips if (ecig_ind > 0) 
                } */

                // first difference of annual taxes 
                cap drop `policy'_change
                gen      `policy'_change = d1.`tax_var'
                replace  `policy'_change = 0                 if (`policy'_change == .)

                // generate indicator for having a prominent tax increase
                gen      prom_inc_`policy' = 0
                replace  prom_inc_`policy' = 1 if (`policy'_change >= `prominent'/100)

                // don't create stack if no prominent increases
                qui count if prom_inc_`policy' ==1
                if r(N) == 0 {
                    local incomplete_run "`policy', `real', `prominent', `lag_num'; `incomplete_run'"
                    continue
                }

                cap drop gvar // requires 'csdid' package 
                egen     gvar = csgvar(prom_inc_`policy'), tvar(year_true) ivar(fips)
                tab      gvar   
                // {initial treatment years, 0} -- obs = 0 never enact prominent tax increases

                cap drop never_adopt
                gen      never_adopt = (gvar == 0)

                // first year of treatment (defined by prominent tax increase) 
                cap drop treat_year_ini	
                gen      treat_year_ini = .
                replace  treat_year_ini = gvar if (gvar != 0) 
                drop                      gvar

                // denote cells that experience prominent increases  
                gen  treat_year_inc = year_true if (prom_inc_`policy' == 1)
                sort treat_year_inc fips 

                // create unique id for prominent-increase year cohorts
                gen     eventid = _n if (treat_year_inc != .) 
                qui sum eventid 
                local max = r(max)

                di "prom tax level: `prominent'"

                // process each cohort 
                local eventno = ""
                forval i = 1/`max' {
                    
                    preserve
                    
                    // id treatment state + year
                    sum treat_year_inc if eventid==`i'
                    local stack_year = r(mean)
                    
                    sum fips if eventid==`i'
                    local stack_fip = r(mean)
                    
                    // cut sample: keep donor states, not yet, and never adopters within the window
                    // temporal restriction
                    keep if inrange(year_true, `stack_year' - `lead', `stack_year' + `lag') 
                    
                    // treatment state should be balanced -- keep this?
                    bys fips: gen count = _N

                    qui sum count if (fips == `stack_fip')
                    local    numobs = r(mean)
                    assert (`numobs' == count) // check balancedness
                    drop count

                    // not-yet adopters: prominent indicator with temporal restrictions
                    cap drop gvar
                    egen     gvar = csgvar(prom_inc_`policy'), tvar(year_true) ivar(fips)
                    tab      gvar 
                    
                    cap drop notyet_adopt
                    gen      notyet_adopt = (gvar == 0) & (never_adopt == 0)
                    

                    keep if /// treated stack, never adopters, not yet adopters
                    (fips == `stack_fip') | (never_adopt == 1) | (notyet_adopt == 1) 
                    
                    
                    // generate relative time events
                    sort fips year_true
                    gen     `policy'_change_og = `policy'_change // preserve nominal change for later
                    replace `policy'_change = 0
                    replace `policy'_change = 1 if ///
                    (fips == `stack_fip') & (treat_year_inc == `stack_year')
                    
                    // leads
                    forval f = `lead'(-1)1 {
                    gen       F`f'_rel_pre = F`f'.`policy'_change
                    replace   F`f'_rel_pre = 0                 if F`f'_rel_pre == .
                    label var F`f'_rel_pre "-`f'"
                    }
                    
                    // lags
                    forval l = 0/`lag' {
                    gen       L`l'_rel_pre = L`l'.`policy'_change
                    replace   L`l'_rel_pre = 0                 if L`l'_rel_pre == .
                    label var L`l'_rel_pre "`l'"
                    }
                    
                    cap drop cohort
                    gen      cohort = `i'
                    
                    tempfile event`i'
                    save    `event`i'' 
                    
                    local eventno = "`eventno'" + "`i'"
                    
                    restore
                }

                // append cohorts into single stack
                {
                    clear
                    use `event1'

                    forval i = 2 / `max' {
                    append using `event`i''
                    }
                }

                sort cohort fips year_true

                // create post-prominent increase indicator with 'eventid' and 'cohort'
                {
                    // match cohort, state with eventid
                    gen     eventid_cohort_match = 0
                    replace eventid_cohort_match = 1 if (eventid==cohort)
                    
                    bys cohort fips: ///
                    egen match = max(eventid_cohort_match)
                    drop             eventid_cohort_match
                    
                    // id cohort-specific treat year when there are multiple prominent increases within a state
                    gen     relevant_year_pre = 0
                    replace relevant_year_pre = treat_year_inc if (eventid==cohort)
                    
                    bys cohort fips: ///
                    egen relevant_year = max(relevant_year_pre)
                    drop                     relevant_year_pre
                    
                    // treated if current year >= relevant treatment year and "in your stack"
                    gen     treated_post = 0
                    replace treated_post = 1 if (year_true>=relevant_year) & (match==1)
                    drop                                    relevant_year
                }

                // create control for having ever experienced a tax change 50-99% of `prominent' during stack period
                {
                    // only "non-stack states" (match==0) turn on -- check if this is what we want
                    
                    // grab year of "small" tax increase
                    gen     small_tax_control_year_ = .
                    replace small_tax_control_year_ = year_true if ///
                    inrange(`policy'_change_og, `= (`prominent' / 100) * 0.5', `= (`prominent' / 100) * 0.99') ///
                    & (match == 0)
                    
                    bys cohort fips: ///
                    egen small_tax_control_year = min(small_tax_control_year_)
                    drop                              small_tax_control_year_
                    
                    // turn on if experienced/experiencing year of small increase
                    gen     small_tax_control = 0
                    replace small_tax_control = 1 if (year_true >= small_tax_control_year)
                    drop                                           small_tax_control_year
                }

                save "data/inter/stack_`policy'_`prominent'_l`lag_num'_`real'.dta", replace
            }
            }
            }
            }
        }

        di "incomplete stacks: `incomplete_run'"
        macro drop             _incomplete_run

        // create annual YRBS
        {
            use "data/final/master_set_2023", clear
            keep if !national
                
            gcollapse (mean) vape fvape dvape smoke fsmoke dsmoke combust fcombust dcombust ///
            (rawsum) aweight, ///
            by(fips year year_true semester lgbq_1 sex race4 age grade) labelformat(#sourcelabel#)

            save "data/final/annual_panel_yrbs_2023", replace
        }

        // check size of tax increases
        if 0 {
            preserve

            use "data/inter/master_control2023_semester", clear
            drop if year_true==2024

            statastates, fips(fips) nogenerate

            // annual panel
            gcollapse (mean) cigarette_tax cigarette_tax_scale, ///
            by(fips state_abbrev year_true) labelformat(#sourcelabel#)    

            // change in tax
            xtset fips year_true
            gen cig_tax_nom_d = d.cigarette_tax
            summ cig_tax_nom_d if !inlist(cig_tax_nom_d,0,.), det
            // mean 0.339
            // 50th pct: 0.25, 75th pct: 0.5, 90 pct: 0.75

            // 13 states with $0.50 nominal cig tax increases,
            // CA, CO, DC, IL, MA, MD, MN, NV, NY, OK, OR, PA, UT   

            // 8 states with $0.75 nominal cig tax increases
            // CA, CO, DC, IL, MD, MN, NY, OR

            restore
        }

        // regressions:
        cap log close
        log using "log/regressions/stacked_did_prom.smcl", replace 

        global dem_control i.sex i.grade i.age i.race4
        // denote essential controls (***)
        {
            // remove "i." for t21
            local vars_essential_coef1_ecigs /*c.ends_tax_nom35_scale*/ c.flavor_ban c.any_mlsa_vape c.t21 c.cigarette_tax_scale
            local vars_essential_coef1_cigs c.ends_tax_nom35_scale c.flavor_ban c.any_mlsa_vape c.t21 /*c.cigarette_tax_scale*/
            local vars_essential_coef0 c.uer c.coviddeaths c.populationvaccinated $dem_control

            // remove "i." for tobacco, "i." for ecigban
            local vars_lasso_sel_vape  /// current vaping
            c.indoor_ban_vape c.ecigban c.indoor_ban_smoke c.tobacco_lis_law_any
            local vars_lasso_sel_fvape /// frequent vaping
            c.indoor_ban_vape c.ecigban c.indoor_ban_smoke c.MML        
            local vars_lasso_sel_dvape /// daily vaping
            c.indoor_ban_vape c.ecigban c.indoor_ban_smoke c.MML

            // cigarette smoking 
            {
                // 2011-2023
                local vars_lasso_sel_smokey1 /// current cig smoking
                c.indoor_ban_vape c.ecigban c.indoor_ban_smoke c.tobacco_lis_law_any

                local vars_lasso_sel_fsmokey1 /// frequent cig smoking
                c.ecigban c.indoor_ban_smoke c.tobacco_lis_law_any

                local vars_lasso_sel_dsmokey1 /// daily cig smoking
                c.ecigban c.indoor_ban_smoke c.tobacco_lis_law_any

                // 2015-2023
                local vars_lasso_sel_smokey5 /// current cig smoking
                c.indoor_ban_vape c.ecigban c.indoor_ban_smoke

                local vars_lasso_sel_fsmokey5 /// frequent cig smoking
                c.ecigban c.indoor_ban_smoke

                local vars_lasso_sel_dsmokey5 /// daily cig smoking
                c.ecigban c.indoor_ban_smoke
            }

            // cigarette or cigar smoking
            {
                // 2011-2023
                local vars_lasso_sel_combusty1 /// current cig or cigar smoking
                c.indoor_ban_vape c.ecigban c.indoor_ban_smoke c.tobacco_lis_law_any c.MML

                local vars_lasso_sel_fcombusty1 /// frequent cig or cigar smoking
                c.ecigban c.indoor_ban_smoke c.tobacco_lis_law_any c.MML

                local vars_lasso_sel_dcombusty1 /// daily cig or cigar smoking
                c.ecigban c.indoor_ban_smoke c.tobacco_lis_law_any c.MML

                // 2015-2023
                local vars_lasso_sel_combusty5 /// current cig or cigar smoking
                c.indoor_ban_vape c.ecigban c.indoor_ban_smoke c.tobacco_lis_law_any

                local vars_lasso_sel_fcombusty5 /// frequent cig or cigar smoking
                c.ecigban c.tobacco_lis_law_any

                local vars_lasso_sel_dcombusty5 /// daily cig or cigar smoking
                c.ecigban c.tobacco_lis_law_any
            }
        }

        eststo clear
        estimates clear

        set matsize 5000

        // analysis
        {
            // eststo names at max length
            foreach policy in /*ecigs*/ cigs {
                if "`policy'"=="ecigs" local p_num 1
                if "`policy'"=="cigs"  local p_num 2
            forval real = /*0/1*/ 0/0 {
            foreach prominent of numlist /*10 25*/ 50 75 100 {
                if `prominent'==100 local prom_name 1h
                else                local prom_name `prominent'
            local lag_num 3
                use "data/inter/stack_`policy'_`prominent'_l`lag_num'_`real'", clear

                joinby using "data/final/annual_panel_yrbs_2023.dta"

                // combine annual relative time events into biennial groups
                {
                    gen F3_rel = F6_rel_pre + F5_rel_pre 
                    gen F2_rel = F4_rel_pre + F3_rel_pre  
                    gen F1_rel = F2_rel_pre + F1_rel_pre 
                    gen L0_rel = L0_rel_pre + L1_rel_pre
                    
                    if `lag_num'==2 gen L1_rel = L2_rel_pre
                    else            gen L1_rel = L2_rel_pre + L3_rel_pre
                    
                    if `lag_num'==4 gen L2_rel = L4_rel_pre
                    if `lag_num'==5 gen L2_rel = L4_rel_pre + L5_rel_pre 
                    
                    if `lag_num' == 2 {
                        global events_rel      F3_rel F2_rel F1_rel    L0_rel L1_rel
                        global events_rel_adj  F3_rel F2_rel F1_rel_og L0_rel L1_rel
                    } 
                    if `lag_num' == 3 {
                        global events_rel      F3_rel F2_rel F1_rel    L0_rel L1_rel
                        global events_rel_adj  F3_rel F2_rel F1_rel_og L0_rel L1_rel
                    }  
                    if `lag_num' == 4 {
                        global events_rel      F3_rel F2_rel F1_rel    L0_rel L1_rel L2_rel
                        global events_rel_adj  F3_rel F2_rel F1_rel_og L0_rel L1_rel L2_rel
                    } 
                    if `lag_num' == 5 {
                        global events_rel      F3_rel F2_rel F1_rel    L0_rel L1_rel L2_rel
                        global events_rel_adj  F3_rel F2_rel F1_rel_og L0_rel L1_rel L2_rel
                    }

                    gen     F1_rel_og = F1_rel // untouched event
                    replace F1_rel = 0
                }

                foreach yr in 5 1 {
                foreach subsample in 1 !mi(lgbq_1) lgbq_1==0 lgbq_1==1 {
                    // subsample-specific
                    {
                        // subsample names 
                        if "`subsample'" == "1"           local s_name "all_u"
                        if "`subsample'" == "!mi(lgbq_1)" local s_name "all"
                        if "`subsample'" == "lgbq_1==0"   local s_name "id_ht"
                        if "`subsample'" == "lgbq_1==1"   local s_name "id_nh1"
                    }
                foreach var of varlist vape fvape dvape /*smoke*/ fsmoke /*dsmoke*/ {
                    // skip patterns
                    {
                        if `yr'==5 & inlist("`var'","smoke","fsmoke","dsmoke") continue
                        if `yr'==1 & inlist("`var'","vape","fvape","dvape")    continue
                    }

                    // LASSO
                    {
                        if inlist("`var'","vape","fvape","dvape") ///
                        local vars_lasso_sel `vars_lasso_sel_`var''

                        else ///
                        local vars_lasso_sel `vars_lasso_sel_`var'y`yr''
                    }

                    summarize `var' if (treated_post==0) & (match==1) ///
                    & inrange(year,201`yr',2023) & `subsample' [aw=aweight], meanonly
		            scalar pre_treat_mean = r(mean)

                    if 1 { // point estimate
                        // ols:
                        // model 1
                        _eststo l`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m1: ///
                        reghdfe `var' ///
                        i.treated_post small_tax_control ///
                        `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                        ${dem_control} ///
                        if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                        absorb(i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true) ///
                        vce(cluster fips) nosample
                        estadd scalar pre_treat_mean = pre_treat_mean

                        // model 2
                        _eststo l`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m2: ///
                        reghdfe `var' ///
                        i.treated_post small_tax_control ///
                        `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                        `vars_lasso_sel' ///
                        ${dem_control} ///
                        if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                        absorb(i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true) ///
                        vce(cluster fips) nosample
                        estadd scalar pre_treat_mean = pre_treat_mean

                        // model 3
                        _eststo l`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m3: ///
                        reghdfe `var' ///
                        i.treated_post small_tax_control ///
                        `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                        `vars_lasso_sel' ///
                        tally_sexualorientation ///
                        ${dem_control} ///
                        if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                        absorb(i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true) ///
                        vce(cluster fips) nosample
                        estadd scalar pre_treat_mean = pre_treat_mean

                        if "`subsample'" == "!mi(lgbq_1)" {
                            // model 1
                            _eststo l`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m1d: ///
                            reghdfe `var' ///
                            lgbq_1##(i.treated_post i.small_tax_control ///
                            `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                            ${dem_control}) ///
                            if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                            absorb(i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true ///
                            lgbq_1#i.fips lgbq_1#i.year_true lgbq_1#i.semester lgbq_1#(i.cohort#i.fips) lgbq_1#(i.cohort#i.year_true)) ///
                            vce(cluster fips) nosample
                            estadd scalar pre_treat_mean = pre_treat_mean

                            // model 2
                            _eststo l`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m2d: ///
                            reghdfe `var' ///
                            lgbq_1##(i.treated_post i.small_tax_control ///
                            `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                            `vars_lasso_sel' ///
                            ${dem_control}) ///
                            if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                            absorb(i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true ///
                            lgbq_1#i.fips lgbq_1#i.year_true lgbq_1#i.semester lgbq_1#(i.cohort#i.fips) lgbq_1#(i.cohort#i.year_true)) ///
                            vce(cluster fips) nosample
                            estadd scalar pre_treat_mean = pre_treat_mean

                            // model 3
                            _eststo l`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m3d: ///
                            reghdfe `var' ///
                            lgbq_1##(i.treated_post i.small_tax_control ///
                            `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                            `vars_lasso_sel' ///
                            c.tally_sexualorientation ///
                            ${dem_control}) ///
                            if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                            absorb(i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true ///
                            lgbq_1#i.fips lgbq_1#i.year_true lgbq_1#i.semester lgbq_1#(i.cohort#i.fips) lgbq_1#(i.cohort#i.year_true)) ///
                            vce(cluster fips) nosample
                            estadd scalar pre_treat_mean = pre_treat_mean
                        }

                        estwrite _all using "log/estimates/stacked_did_prom_`policy'_`real'_`prominent'", append

                        eststo clear
                        estimates clear
                    }

                    if 1 { // event study
                    if inlist("`subsample'","lgbq_1==0","lgbq_1==1") {
                        // ols:
                        // model 1
                        _eststo esl`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m1: ///
                        reghdfe `var' ///
                        ${events_rel} small_tax_control ///
                        `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                        ${dem_control} ///
                        if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                        absorb(i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true) ///
                        vce(cluster fips) nosample
                        estadd scalar pre_treat_mean = pre_treat_mean

                        { // delta simple average
                            xlincom ///
                            ((_b[F3_rel]+ _b[F2_rel] + _b[F1_rel]) / 3) /// -6,-5   lead
                            (            (_b[F2_rel] + _b[F1_rel]) / 2) /// -4,-3 lead
                            (                         (_b[F1_rel]) / 1) /// -2,-1 lead
                            ((_b[L0_rel])                          / 1) ///  0,1  lag   
                            ((_b[L0_rel] + _b[L1_rel])             / 2) ///  2,3   lag
                            , post level(95)
                            _eststo esdl`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m1
                        }

                        if 0 { // 'cnsreg' 
                            constraint 1 (F3_rel + F2_rel + F1_rel_og) / 3 = 0

                            _eststo escl`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m1: ///
                            cnsreg `var' ///
                            ${events_rel_adj} small_tax_control ///
                            `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                            ${dem_control} ///
                            i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true ///
                            if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                            constraints(1) vce(cluster fips)
                        }


                        // model 2
                        _eststo esl`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m2: ///
                        reghdfe `var' ///
                        ${events_rel} small_tax_control ///
                        `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                        `vars_lasso_sel' ///
                        ${dem_control} ///
                        if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                        absorb(i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true) ///
                        vce(cluster fips) nosample
                        estadd scalar pre_treat_mean = pre_treat_mean

                        { // delta simple average
                            xlincom ///
                            ((_b[F3_rel]+ _b[F2_rel] + _b[F1_rel]) / 3) /// -6,-5   lead
                            (            (_b[F2_rel] + _b[F1_rel]) / 2) /// -4,-3 lead
                            (                         (_b[F1_rel]) / 1) /// -2,-1 lead
                            ((_b[L0_rel])                          / 1) ///  0,1  lag   
                            ((_b[L0_rel] + _b[L1_rel])             / 2) ///  2,3   lag
                            , post level(95)
                            _eststo esdl`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m2
                        }

                        if 0 { // 'cnsreg' 
                            constraint 1 (F3_rel + F2_rel + F1_rel_og) / 3 = 0

                            _eststo escl`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m2: ///
                            cnsreg `var' ///
                            ${events_rel_adj} small_tax_control ///
                            `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                            `vars_lasso_sel' ///
                            ${dem_control} ///
                            i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true ///
                            if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                            constraints(1) vce(cluster fips)
                        }

                        // model 3
                        _eststo esl`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m3: ///
                        reghdfe `var' ///
                        ${events_rel} small_tax_control ///
                        `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                        `vars_lasso_sel' ///
                        tally_sexualorientation ///
                        ${dem_control} ///
                        if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                        absorb(i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true) ///
                        vce(cluster fips) nosample
                        estadd scalar pre_treat_mean = pre_treat_mean

                        { // delta simple average
                            xlincom ///
                            ((_b[F3_rel]+ _b[F2_rel] + _b[F1_rel]) / 3) /// -6,-5   lead
                            (            (_b[F2_rel] + _b[F1_rel]) / 2) /// -4,-3 lead
                            (                         (_b[F1_rel]) / 1) /// -2,-1 lead
                            ((_b[L0_rel])                          / 1) ///  0,1  lag   
                            ((_b[L0_rel] + _b[L1_rel])             / 2) ///  2,3   lag
                            , post level(95)
                            _eststo esdl`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m3
                        }

                        if 0 { // 'cnsreg' 
                            constraint 1 (F3_rel + F2_rel + F1_rel_og) / 3 = 0

                            _eststo escl`lag_num'_`prom_name'_y`yr'`s_name'_`var'_m3: ///
                            cnsreg `var' ///
                            ${events_rel_adj} small_tax_control ///
                            `vars_essential_coef1_`policy'' `vars_essential_coef0' ///
                            `vars_lasso_sel' ///
                            tally_sexualorientation ///
                            ${dem_control} ///
                            i.fips i.year_true i.semester i.cohort#i.fips i.cohort#i.year_true ///
                            if `subsample' & inrange(year,201`yr',2023) [pw=aweight], ///
                            constraints(1) vce(cluster fips)
                        }

                        estwrite _all using "log/estimates/stacked_did_prom_es_`policy'_`real'_`prominent'", append

                        eststo clear
                        estimates clear
                    }
                    }
                }
                
                }
                }
            }
            }
            }
        }

        macro drop events_rel events_rel_adj

        log close
    }
}

// mental health mechanisms, splits by MH (state YRBS)
if 1 {
    // create flavor ban events
    {
        // (s1)- semester-based: -14 to 5
        use "data/inter/master_control2023_semester", clear
        keep fips year_true semester flavor_ban
        sort fips year_true semester

        bys fips: gen L0 = flavor_ban[_n] - flavor_ban[_n - 1]
        replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010

        // lags
        forval i = 0/5 {
        bys fips: gen s1L`i'_flav = L0[_n - `i']
        replace s1L`i'_flav = 0 if s1L`i'_flav == . // no issue b/c no ends tax pre 2010
        // endpoints:
        if `i' == 5 {
            bys fips: gen sum_s1L`i'_flav = sum(s1L`i'_flav)
            replace s1L`i'_flav = sum_s1L`i'_flav
            drop sum_s1L`i'_flav
        }
        }

        // leads
        forval i = 1/14 {
        bys fips: gen s1F`i'_flav = L0[_n + `i']
        replace s1F`i'_flav = 0 if s1F`i'_flav == . // assume future tax holds constant
        // endpoints:
        if `i' == 14 {
            gsort fips -year_true -semester
            bys fips: gen sum_s1F`i'_flav = sum(s1F`i'_flav)
            replace s1F`i'_flav = sum_s1F`i'_flav
            drop                  sum_s1F`i'_flav
        }
        sort fips year_true semester
        }
        order s1F14_flav s1F13_flav s1F12_flav s1F11_flav s1F10_flav s1F9_flav s1F8_flav s1F7_flav s1F6_flav s1F5_flav ///
        s1F4_flav s1F3_flav s1F2_flav s1F1_flav, after(L0)

        gen flav_lag0_1    = s1L0_flav + s1L1_flav + s1L2_flav + s1L3_flav
        gen flav_lag2_plus = s1L4_flav + s1L5_flav

        tempfile flavor_s1
        save    `flavor_s1'
    }

    use "data/final/master_set_2023", clear
    // create outcome vars
    {
        // broad measures of "affected":

        cap drop either_bully
        gen 	 either_bully = .
        replace  either_bully = 1 if (bullied==1)|(e_bullied==1)
        replace  either_bully = 0 if (bullied==0)&(e_bullied==0)

        // either bully, sad, or suicide ideation
        gen      aff_mh_b = .
        replace  aff_mh_b = 1 if (either_bully==1)|(sad==1)|(s_ideation==1)
        replace  aff_mh_b = 0 if (either_bully==0)&(sad==0)&(s_ideation==0)

        // af2: sad or suicide ideation
        gen     aff_mh = .
        replace aff_mh = 1 if (sad==1)|(s_ideation==1)
        replace aff_mh = 0 if (sad==0)&(s_ideation==0)

        // af3: sad or suicide ideation,plan,attempt, or injury
        gen     aff_mh3 = .
        replace aff_mh3 = 1 if (sad==1)|(s_ideation==1)|(s_plan==1)|(s_attempt==1)|(s_injury==1)
        replace aff_mh3 = 0 if (sad==0)&(s_ideation==0)&(s_plan==0)&(s_attempt==0)&(s_injury==0)

        // af4: physical bullying, sad, or suicide ideation
        gen     aff_mh4 = .
        replace aff_mh4 = 1 if (bullied==1)|(sad==1)|(s_ideation==1)
        replace aff_mh4 = 0 if (bullied==0)&(sad==0)&(s_ideation==0)

        // af5: physical bullying or suicide ideation
        gen     aff_mh5 = .
        replace aff_mh5 = 1 if (bullied==1)|(s_ideation==1)
        replace aff_mh5 = 0 if (bullied==0)&(s_ideation==0)

        // af6: suicide ideation,planning,attempt, or injury
        gen     aff_mh6 = .
        replace aff_mh6 = 1 if (s_ideation==1)|(s_plan==1)|(s_attempt==1)|(s_injury==1)
        replace aff_mh6 = 0 if (s_ideation==0)&(s_plan==0)&(s_attempt==0)&(s_injury==0)

        // af7: physical bullying or sad
        gen     aff_mh7 = .
        replace aff_mh7 = 1 if (bullied==1)|(sad==1)
        replace aff_mh7 = 0 if (bullied==0)&(sad==0)

        // af8: either bullying or sad
        gen     aff_mh8 = .
        replace aff_mh8 = 1 if (either_bully==1)|(sad==1)
        replace aff_mh8 = 0 if (either_bully==0)&(sad==0)

        // af9: having 2/3 of the following: either bully, sad, suicide ideation
        gen     aff_mh9 = .
        replace aff_mh9 = 1 if ///
        (either_bully==1 & sad==1)|(either_bully==1 & s_ideation==1)|(sad==1 & s_ideation==1)
        replace aff_mh9 = 0 if ///
        (either_bully==0 & sad==0)|(either_bully==0 & s_ideation==0)|(sad==0 & s_ideation==0)
    }

    // subsamples
    {
        local sub_sad "(lgbq_1==1)&(sad==1) (lgbq_1==1)&(sad==0) (lgbq_1==0)&(sad==1) (lgbq_1==0)&(sad==0)"
        // 4 groups: #(1-4)
        // lgbq,sad; lgbq,happy; het,sad; het,happy

        local sub_s_idea "(lgbq_1==1)&(s_ideation==1) (lgbq_1==1)&(s_ideation==0) (lgbq_1==0)&(s_ideation==1) (lgbq_1==0)&(s_ideation==0)"
        // 4 groups: #(5-8)
        // lgbq,suicide; lgbq,non-suicide; het,suicide; het,non-suicide

        local sub_bully "(lgbq_1==1)&(bullied==1) (lgbq_1==1)&(bullied==0) (lgbq_1==0)&(bullied==1) (lgbq_1==0)&(bullied==0)"
        // 4 groups: #(9-12)
        // lgbq,bully; lgbq,no-bully; het,bully; het,no-bully

        local sub_e_bully "(lgbq_1==1)&(e_bullied==1) (lgbq_1==1)&(e_bullied==0) (lgbq_1==0)&(e_bullied==1) (lgbq_1==0)&(e_bullied==0)"
        // 4 groups: #(13-16)
        // lgbq,e-bully; lgbq,no e-bully; het,e-bully; het,no e-bully

        local sub_either_bully "(lgbq_1==1)&(either_bully==1) (lgbq_1==1)&(either_bully==0) (lgbq_1==0)&(either_bully==1) (lgbq_1==0)&(either_bully==0)"
        // 4 groups: #(17-20)
        // lgbq,bully(either); lgbq,no bully(either); het,bully(either); het,no bully(either)

        local sub_affected "(lgbq_1==1)&(aff_mh_b==1) (lgbq_1==1)&(aff_mh_b==0) (lgbq_1==0)&(aff_mh_b==1) (lgbq_1==0)&(aff_mh_b==0)"
        // 4 groups: #(21-24)
        // lgbq,affected; lgbq,non-affected; het,affected; het,non-affected

        local sub_affected2 "(lgbq_1==1)&(aff_mh==1) (lgbq_1==1)&(aff_mh==0) (lgbq_1==0)&(aff_mh==1) (lgbq_1==0)&(aff_mh==0)"
        // 4 groups: #(25-28)
        // lgbq,affected2; lgbq,non-affected2; het,affected2; het,non-affected2

        local sub_affected3 "(lgbq_1==1)&(aff_mh3==1) (lgbq_1==1)&(aff_mh3==0) (lgbq_1==0)&(aff_mh3==1) (lgbq_1==0)&(aff_mh3==0)"
        // 4 groups: #(29-32)
        // lgbq,affected3; lgbq,non-affected3; het,affected3; het,non-affected3

        local sub_affected4 "(lgbq_1==1)&(aff_mh4==1) (lgbq_1==1)&(aff_mh4==0) (lgbq_1==0)&(aff_mh4==1) (lgbq_1==0)&(aff_mh4==0)"
        // 4 groups: #(33-36)
        // lgbq,affected4; lgbq,non-affected4; het,affected4; het,non-affected4

        local sub_affected5 "(lgbq_1==1)&(aff_mh5==1) (lgbq_1==1)&(aff_mh5==0) (lgbq_1==0)&(aff_mh5==1) (lgbq_1==0)&(aff_mh5==0)"
        // 4 groups: #(37-40)
        // lgbq,affected5; lgbq,non-affected5; het,affected5; het,non-affected5

        local sub_affected6 "(lgbq_1==1)&(aff_mh6==1) (lgbq_1==1)&(aff_mh6==0) (lgbq_1==0)&(aff_mh6==1) (lgbq_1==0)&(aff_mh6==0)"
        // 4 groups: #(41-44)
        // lgbq,affected6; lgbq,non-affected6; het,affected6; het,non-affected6

        local sub_affected7 "(lgbq_1==1)&(aff_mh7==1) (lgbq_1==1)&(aff_mh7==0) (lgbq_1==0)&(aff_mh7==1) (lgbq_1==0)&(aff_mh7==0)"
        // 4 groups: #(45-48)
        // lgbq,affected7; lgbq,non-affected7; het,affected7; het,non-affected7

        local sub_affected8 "(lgbq_1==1)&(aff_mh8==1) (lgbq_1==1)&(aff_mh8==0) (lgbq_1==0)&(aff_mh8==1) (lgbq_1==0)&(aff_mh8==0)"
        // 4 groups: #(49-52)
        // lgbq,affected8; lgbq,non-affected8; het,affected8; het,non-affected8

        local sub_affected9 "(lgbq_1==1)&(aff_mh9==1) (lgbq_1==1)&(aff_mh9==0) (lgbq_1==0)&(aff_mh9==1) (lgbq_1==0)&(aff_mh9==0)"
        // 4 groups: #(53-56)
        // lgbq,affected9; lgbq,non-affected9; het,affected9; het,non-affected9

        local sub_test "(lgbq_1==1) (lgbq_1==0)"
        // 2 groups: #(57-58)
        // lgbq; het

        local subsamples "`sub_sad' `sub_s_idea' `sub_bully' `sub_e_bully' `sub_either_bully' `sub_affected' `sub_affected2' `sub_affected3' `sub_affected4' `sub_affected5' `sub_affected6' `sub_affected7' `sub_affected8' `sub_affected9' `sub_test'"

        local subsamples_total = wordcount("`subsamples'")
    }

    // merge
    {
        // flavor events
        merge m:1 fips year_true semester using `flavor_s1'
        drop if _merge==2
        drop    _merge
    }

    // regressions
    cap log close
    log using "log/regressions/mental_health.smcl", replace 
    {
        global dem_control i.sex i.grade i.age i.race4

        estimates clear
        eststo    clear

        foreach yr in 5 1 {

        keep if !national

        forval q = 1/`subsamples_total' { // cycle through subsamples
            local subsample = word("`subsamples'",`q')
            di  "`subsample'"
        // sample names
        {
            // depression, suicidal ideation
            if `q' == 1  local name_sample "nh_sad"
	        if `q' == 2  local name_sample "nh_nsad"
	        if `q' == 3  local name_sample "ht_sad"
	        if `q' == 4  local name_sample "ht_nsad"
	        if `q' == 5  local name_sample "nh_sidea"
	        if `q' == 6  local name_sample "nh_nsidea"
	        if `q' == 7  local name_sample "ht_sidea"
	        if `q' == 8  local name_sample "ht_nsidea"

            // bullying
            if `q' == 9  local name_sample "nh_b"
            if `q' == 10 local name_sample "nh_nb"
            if `q' == 11 local name_sample "ht_b"
            if `q' == 12 local name_sample "ht_nb"
            if `q' == 13 local name_sample "nh_eb"
            if `q' == 14 local name_sample "nh_neb"
            if `q' == 15 local name_sample "ht_eb"
            if `q' == 16 local name_sample "ht_neb"
            if `q' == 17 local name_sample "nh_be"
            if `q' == 18 local name_sample "nh_nbe"
            if `q' == 19 local name_sample "ht_be"
            if `q' == 20 local name_sample "ht_nbe"

            // bad mental health (broadly)
            if `q' == 21 local name_sample "nh_aff"
            if `q' == 22 local name_sample "nh_naff"
            if `q' == 23 local name_sample "ht_aff"
            if `q' == 24 local name_sample "ht_naff"
            if `q' == 25 local name_sample "nh_af2"
            if `q' == 26 local name_sample "nh_naf2"
            if `q' == 27 local name_sample "ht_af2"
            if `q' == 28 local name_sample "ht_naf2"
            if `q' == 29 local name_sample "nh_af3"
            if `q' == 30 local name_sample "nh_naf3"
            if `q' == 31 local name_sample "ht_af3"
            if `q' == 32 local name_sample "ht_naf3"
            if `q' == 33 local name_sample "nh_af4"
            if `q' == 34 local name_sample "nh_naf4"
            if `q' == 35 local name_sample "ht_af4"
            if `q' == 36 local name_sample "ht_naf4"
            if `q' == 37 local name_sample "nh_af5"
            if `q' == 38 local name_sample "nh_naf5"
            if `q' == 39 local name_sample "ht_af5"
            if `q' == 40 local name_sample "ht_naf5"
            if `q' == 41 local name_sample "nh_af6"
            if `q' == 42 local name_sample "nh_naf6"
            if `q' == 43 local name_sample "ht_af6"
            if `q' == 44 local name_sample "ht_naf6"
            if `q' == 45 local name_sample "nh_af7"
            if `q' == 46 local name_sample "nh_naf7"
            if `q' == 47 local name_sample "ht_af7"
            if `q' == 48 local name_sample "ht_naf7"
            if `q' == 49 local name_sample "nh_af8"
            if `q' == 50 local name_sample "nh_naf8"
            if `q' == 51 local name_sample "ht_af8"
            if `q' == 52 local name_sample "ht_naf8"
            if `q' == 53 local name_sample "nh_af9"
            if `q' == 54 local name_sample "nh_naf9"
            if `q' == 55 local name_sample "ht_af9"
            if `q' == 56 local name_sample "ht_naf9"

            if `q' == 57 local name_sample "nh"
            if `q' == 58 local name_sample "ht"
        }

        forval flavor = 0/1 {
            // flavor-specific
            {
                if `flavor'==0 {
                    local vars_covars   ${vars_essential_coef1}
                    local vars_margins  ${vars_essential_coef1}
                    local sample_flavor 1

                    local name_flavor
                }
                if `flavor'==1 { // overall flavor ban
                    local vars_covars   c.ends_tax_nom35_scale c.any_mlsa_vape i.t21 c.cigarette_tax_scale c.flavor_ban
                    local vars_margins  c.flavor_ban
                    local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR

                    local name_flavor `flavor'
                }
                if `flavor'==2 { // flavor ban lags
                    local vars_covars   c.ends_tax_nom35_scale c.any_mlsa_vape i.t21 c.cigarette_tax_scale c.flav_lag0_1 c.flav_lag2_plus
                    local vars_margins  c.flav_lag0_1 c.flav_lag2_plus
                    local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR

                    local name_flavor `flavor'
                }
            }
        foreach var in vape fvape dvape smoke fsmoke dsmoke { 
            // skip pattern
            {
                if `yr'==1                        & inlist("`var'","vape","fvape","dvape")    continue
                if `yr'==5 & inlist(`flavor',1,2) & inlist("`var'","smoke","fsmoke","dsmoke") continue
            }

            // LASSO assignment (***)
            {
                if inlist("`var'","vape","fvape","dvape") ///
                local vars_lasso_sel ${vars_lasso_sel_`var'}

                else ///
                local vars_lasso_sel ${vars_lasso_sel_`var'y`yr'}
            }

            /*
                if /// 
                !(  inlist("`name_sample'","nh_sad",  "nh_nsad",  "ht_sad",  "ht_nsad")    /// depression
                /// |  inlist("`name_sample'","nh_b",    "nh_nb",    "ht_b",    "ht_nb")      /// physical bullying
                |  inlist("`name_sample'","nh_be",   "nh_nbe",   "ht_be",   "ht_nbe")     /// bullying either
                |  inlist("`name_sample'","nh_af8",  "nh_naf8",  "ht_af8",  "ht_naf8")    /// depression or bully either
                |  inlist("`name_sample'","nh_sidea","nh_nsidea","ht_sidea","ht_nsidea")) /// suicidal ideation
            */
            if !inlist("`name_sample'","nh","ht") {
                
                summarize `var' if pre_etax_intro == 1 & !mi(pre_etax_intro) ///
                & `subsample' & `sample_flavor' & inrange(year,201`yr',2023) [aw=aweight], meanonly	
                scalar pre_treat_mean = r(mean)

                if inlist("`var'","vape","fvape","dvape") { 
                // model 1: 
                logit `var' ///
                `vars_covars' ${vars_essential_coef0} ///
                ${dem_control} ///
                i.fips i.year_true i.semester ///
                if `subsample' & `sample_flavor' & inrange(year,201`yr',2023) [pw=aweight], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	

                _eststo `var'_`name_sample'y`yr'_m1`name_flavor': ///
                margins, dydx(`vars_margins') post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre


                // model 2:
                logit `var' ///
                `vars_covars' ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                ${dem_control} ///
                i.fips i.year_true i.semester ///
                if `subsample' & `sample_flavor' & inrange(year,201`yr',2023) [pw=aweight], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	

                _eststo `var'_`name_sample'y`yr'_m2`name_flavor': ///
                margins, dydx(`vars_margins') post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre
                }


                // model 3: 
                logit `var' ///
                `vars_covars' ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester ///
                if `subsample' & `sample_flavor' & inrange(year,201`yr',2023) [pw=aweight], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	

                _eststo `var'_`name_sample'y`yr'_m3`name_flavor': ///
                margins, dydx(`vars_margins') post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre
            }
            // fully-differenced model
            if  inlist("`name_sample'","nh","ht") {
            foreach split in sad s_ideation bullied e_bullied either_bully aff_mh_b aff_mh aff_mh3 aff_mh4 aff_mh5 aff_mh6 aff_mh7 aff_mh8 aff_mh9 {
                // split-specifics
                {
                    if "`split'"=="sad"          local name_split sad
                    if "`split'"=="s_ideation"   local name_split sidea
                    
                    if "`split'"=="bullied"      local name_split b
                    if "`split'"=="e_bullied"    local name_split eb
                    if "`split'"=="either_bully" local name_split be

                    if "`split'"=="aff_mh_b"     local name_split aff
                    if "`split'"=="aff_mh"       local name_split af2
                    if "`split'"=="aff_mh3"      local name_split af3
                    if "`split'"=="aff_mh4"      local name_split af4
                    if "`split'"=="aff_mh5"      local name_split af5
                    if "`split'"=="aff_mh6"      local name_split af6
                    if "`split'"=="aff_mh7"      local name_split af7
                    if "`split'"=="aff_mh8"      local name_split af8
                    if "`split'"=="aff_mh9"      local name_split af9
                }
                
                if inlist("`var'","vape","fvape","dvape") {
                // model 1
                _eststo `var'_`name_sample'y`yr'_m1`name_flavor'_`name_split': ///
                logit `var' ///
                `split'##( ///
                `vars_covars' ${vars_essential_coef0} ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' & `sample_flavor' & inrange(year,201`yr',2023) [pw=aweight], ///
                vce(cluster fips) iterate(15)
                estadd scalar converge = e(converged)

                // model 2
                _eststo `var'_`name_sample'y`yr'_m2`name_flavor'_`name_split': ///
                logit `var' ///
                `split'##( ///
                `vars_covars' ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' & `sample_flavor' & inrange(year,201`yr',2023) [pw=aweight], ///
                vce(cluster fips) iterate(15)
                estadd scalar converge = e(converged)
                }

                // model 3
                _eststo `var'_`name_sample'y`yr'_m3`name_flavor'_`name_split': ///
                logit `var' ///
                `split'##( ///
                `vars_covars' ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' & `sample_flavor' & inrange(year,201`yr',2023) [pw=aweight], ///
                vce(cluster fips) iterate(15)
                estadd scalar converge = e(converged)   
            }
            }
        }
        if `yr'==5     estwrite *vape_*  using "log/estimates/mental_health_l.sters", append
        estwrite *smoke_* using "log/estimates/mental_health_l_smoke.sters", append
        eststo clear
        estimates clear
        }
        }
        }
    }
    log close

    use "data/final/master_set_2023", clear
}

// spatial heterogeneity
if 1 {
    set matsize 1000

    eststo clear
    estimates clear

    cap log close 
    log using "log/regressions/spatial_het.smcl", replace

    foreach i in !national /*national*/ 1 {
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
    foreach yr in 2011 2015 /*2017*/ {
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

    // create spatial het vars (***) -- move to cleaning code
    {
        // create census region variable
        gen 	region=1 if inlist(fips, 9,23,25,33,44,50,34,36,42)
        replace region=2 if inlist(fips, 18,17,26,39,55,19,20,27,29,31,38,46)
        replace region=3 if inlist(fips, 10,11,12,13,24,37,45,51,54,1,21,28,47,5,22,40,48)
        replace region=4 if inlist(fips, 4,8,16,35,30,49,32,56,2,6,15,41,53)

        // create census division variable
        gen     division = .
        replace division = 1 if inlist(fips, 9,23,25,33,44,50)
        replace division = 2 if inlist(fips, 34,36,42)
        replace division = 3 if inlist(fips, 18,17,26,39,55)
        replace division = 4 if inlist(fips, 19,20,27,29,31,38,46)
        replace division = 5 if inlist(fips, 10,11,12,13,24,37,45,51,54)
        replace division = 6 if inlist(fips, 1,21,28,47)
        replace division = 7 if inlist(fips, 5,22,40,48)
        replace division = 8 if inlist(fips, 4,8,16,35,30,49,32,56)
        replace division = 9 if inlist(fips, 2,6,15,41,53)      
        
        // create time variable
        gen 	time = 1 if year == 2011
        replace time = 2 if year == 2013
        replace time = 3 if year == 2015
        replace time = 4 if year == 2017
        replace time = 5 if year == 2019
        replace time = 6 if year == 2021
        replace time = 7 if year == 2023


        // allow states to have different trends
        bys fips: egen fips_treat_diff = total(ends_tax_nom35_scale)
        replace        fips_treat_diff = 1 if (fips_treat_diff > 0) & !mi(fips_treat_diff)
        replace        fips_treat_diff = fips_treat_diff * fips

        // force common trend for all treated states
        bys fips: gen fips_treat_common = (fips_treat_diff > 0)  
    }
    
    keep if `i'	
    keep if inrange(year,`yr',`yr_end')		

    foreach q in 5 6 9 10 { 

        *** if "`i'"=="!national" & `q'==5 continue // TEMPORARY

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

        foreach var of varlist vape fvape dvape smoke fsmoke dsmoke {
        foreach model of numlist 5 6 { // spatial het model
            // spatial het model
            {
                if `model'==1 /// census region-year FE
                local vars_spatial i.region#i.year_true
                if `model'==2 /// census division-year FE
                local vars_spatial i.division#i.year_true
                if `model'==3 /// state-specific linear time trends
                local vars_spatial i.fips#c.time
                if `model'==4 /// tr state-specific linear time trends
                local vars_spatial i.fips_treat_diff#c.time
                if `model'==5 /// common tr state linear time trend
                local vars_spatial i.fips_treat_common#c.time
                if `model'==6 /// census-region specific linear time trends
                local vars_spatial i.region#c.time
                if `model'==7 /// census-division specific linear time trends
                local vars_spatial i.division#c.time
            }

            // LASSO assignment (***)
            {
                // vaping vars get specific LASSO controls, other vars get other LASSO controls
                if inlist("`var'","vape","fvape","dvape") ///
                local vars_lasso_sel ${vars_lasso_sel_`var'}

                else ///
                local vars_lasso_sel ${vars_lasso_sel_`var'`yr_name'}
            }
            
            // skip patterns
            {
                // only vaping/smoking outcomes for national and combined YRBS
                if !inlist("`var'","vape","fvape","dvape","smoke","fsmoke","dsmoke") & ("`i'" != "!national") continue

                // no vaping outcomes pre-2015
                if inlist("`var'","vape","fvape","dvape") & ("`yr'"=="2011") continue

                // no smoking outcomes 2015-2023
                if inlist("`var'","smoke","fsmoke","dsmoke") & ("`yr'"=="2015") continue
            }

            di "`name' `yr' `name_sample' `var'"

            summarize `var' ///
            if pre_etax_intro == 1 & !mi(pre_etax_intro) & `subsample' ///
            [aw=`weight'], meanonly
            scalar pre_treat_mean = r(mean)

            // logistic regression
            {
                // model 1: state, year, semester FE, demographics, macro/covid, 
                // ENDS taxes, flavor bans, MLSA laws, Tobacco-21 Laws, cigarette taxes
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_spatial' ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if `subsample' [pw=`weight'], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	

                _eststo `var'_1l`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                margins, dydx(${vars_essential_coef1}) post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre


                // model 2: model 1 + LASSO selected vars
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                `vars_spatial' ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if `subsample' [pw=`weight'], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	

                _eststo `var'_2l`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                margins, dydx(${vars_essential_coef1}) post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre


                // model 3: model 2 + LGBQ policy control
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                `vars_spatial' ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if `subsample' [pw=`weight'], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	

                _eststo `var'_3l`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                margins, dydx(${vars_essential_coef1}) post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre

                if `q'==6 {
                    // model 1
                    _eststo `var'_1ldo`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_spatial' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester) /// 
                    if `subsample' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)

                    // model 2
                    _eststo `var'_2ldo`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    `vars_spatial' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester) /// 
                    if `subsample' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)

                    // model 3
                    _eststo `var'_3ldo`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    c.tally_sexualorientation ///
                    `vars_spatial' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester) /// 
                    if `subsample' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)
                }
            }

            // ols regression
            {
                // model 1
                _eststo `var'_1`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${dem_control} `technical' ///
                if `subsample' [aw=`weight'], ///
                vce(cluster fips) absorb(fips year_true semester `vars_spatial')

                estadd scalar pre_treat_mean = pre_treat_mean


                // model 2:
                _eststo `var'_2`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                ${dem_control} `technical' ///
                if `subsample' [aw=`weight'], ///
                vce(cluster fips) absorb(fips year_true semester `vars_spatial')

                estadd scalar pre_treat_mean = pre_treat_mean


                // model 3:
                _eststo `var'_3`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${dem_control} `technical' ///
                if `subsample' [aw=`weight'], ///
                vce(cluster fips) absorb(fips year_true semester `vars_spatial')

                estadd scalar pre_treat_mean = pre_treat_mean

                if `q'==6 {
                    // model 1
                    _eststo `var'_1d`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    ${dem_control} `technical') /// 
                    if `subsample' [aw=`weight'], ///
                    vce(cluster fips) ///
                    absorb(fips year_true semester `vars_spatial' lgbq_1#fips lgbq_1#year_true lgbq_1#semester lgbq_1#(`vars_spatial'))
                    estadd scalar pre_treat_mean = pre_treat_mean

                    // model 2
                    _eststo `var'_2d`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    ${dem_control} `technical') /// 
                    if `subsample' [aw=`weight'], ///
                    vce(cluster fips) ///
                    absorb(fips year_true semester `vars_spatial' lgbq_1#fips lgbq_1#year_true lgbq_1#semester lgbq_1#(`vars_spatial'))
                    estadd scalar pre_treat_mean = pre_treat_mean

                    // model 3
                    _eststo `var'_3d`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    c.tally_sexualorientation ///
                    ${dem_control} `technical') /// 
                    if `subsample' [aw=`weight'], ///
                    vce(cluster fips) ///
                    absorb(fips year_true semester `vars_spatial' lgbq_1#fips lgbq_1#year_true lgbq_1#semester lgbq_1#(`vars_spatial'))
                    estadd scalar pre_treat_mean = pre_treat_mean
                }
            }
        }
        }	

        // write estimates
        {
            // logit
            estwrite *_1l?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'1l", append 
            estwrite *_2l?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'2l", append
            estwrite *_3l?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'3l", append

            // ols
            estwrite *_1?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'1", append 
            estwrite *_2?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'2", append
            estwrite *_3?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'3", append

            if `q'==6 {
                // logit
                estwrite *_1ldo?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'1l", append 
                estwrite *_2ldo?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'2l", append
                estwrite *_3ldo?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'3l", append

                // ols
                estwrite *_1d?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'1", append 
                estwrite *_2d?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'2", append
                estwrite *_3d?_*`name' using "log/estimates/spatial_het_`yr_name'`yr_end_name'`name'3", append
            }
        }
        eststo clear
    }
    eststo clear
    }
    }
    eststo clear
    }

    log close
}

// sample selection
if 1 {
    use "data/final/master_set_2023", clear

    global dem_control i.sex i.grade i.age i.race4

    eststo clear
    estimates clear

    foreach yr in 5 1 {
        if `yr'==5 local name_lasso
        if `yr'==1 local name_lasso y`yr'
    foreach var in lgbq_1 /*id_gay_lesbian id_bisexual id_questioning*/ {

        use "data/final/master_set_2023", clear

        keep if inrange(year,201`yr',2023)
        keep if !national

        drop if mi(sex_orientation) 

        // sample trimming
        {
            if "`var'" == "id_gay_lesbian" drop if (id_bisexual == 1 | id_questioning == 1)
            if "`var'" == "id_bisexual"    drop if (id_gay_lesbian == 1 | id_questioning == 1)
            if "`var'" == "id_questioning" drop if (id_gay_lesbian == 1 | id_bisexual == 1)
        }

        // subsample names
        {
            if "`var'" == "lgbq_1"         local n_var "lgbq_1"
            if "`var'" == "id_gay_lesbian" local n_var "id_gl"
            if "`var'" == "id_bisexual"    local n_var "id_bi"
            if "`var'" == "id_questioning" local n_var "id_ns"
        }

        summarize `var' if pre_etax_intro == 1 & !mi(pre_etax_intro) [aw=aweight], meanonly
        scalar pre_treat_mean = r(mean)

        forval flavor=0/1 {
            // flavor-specific
            {
                if `flavor'==0 {
                    local vars_margins ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                    local name_flavor
                    local sample_flavor 1
                }
                if `flavor'==1 {
                    local vars_margins flavor_ban
                    local name_flavor 3l
                    local sample_flavor "!inlist(fips,6,11,25,41)"
                }
            }

            // logit: (use ${vars_lasso_sel_other})
            // model 1
            logit `var' ///
            ${vars_essential_coef1} ${vars_essential_coef0} ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `sample_flavor' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `n_var'_1`name_flavor'_y`yr'_st: margins, ///
            dydx(`vars_margins') post
            estadd scalar pre_treat_mean = pre_treat_mean
            estadd scalar converge = converge_pre


            // model 2
            logit `var' ///
            ${vars_essential_coef1} ${vars_essential_coef0} ///
            ${vars_lasso_sel_`var'`name_lasso'} ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `sample_flavor' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `n_var'_2`name_flavor'_y`yr'_st: margins, ///
            dydx(`vars_margins') post
            estadd scalar pre_treat_mean = pre_treat_mean
            estadd scalar converge = converge_pre


            // model 3
            logit `var' ///
            ${vars_essential_coef1} ${vars_essential_coef0} ///
            ${vars_lasso_sel_`var'`name_lasso'} ///
            c.tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `sample_flavor' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `n_var'_3`name_flavor'_y`yr'_st: margins, ///
            dydx(`vars_margins') post
            estadd scalar pre_treat_mean = pre_treat_mean
            estadd scalar converge = converge_pre
        }

    }
    }

    macro drop _name_lasso _name_flavor

    estwrite _all using "log/estimates/sample_selection.sters", replace
}

// leave-one-out (w/ viz code)
if 1 {
  log using "log/regressions/leaveoneout.smcl", replace

  eststo clear 
  estimates clear
  
  // get state abbreviation
  statastates,fips(fips) nogen

  global dem_control i.sex i.grade i.age i.race4

  local figure_varlist fvape fsmoke
  
  foreach d in !national /*1*/ {
    if "`d'" == "!national" {
		local dname "st"
	 	local weight "aweight"
		local technical
		}	
	if "`d'" == "national" {
		local dname "nat"
	 	local weight "bweight"
		local technical
		}	
	if "`d'" == "1" {
		local dname "com"
	 	local weight "cweight"
		local technical i.national
		}	
  foreach yr in 1 5 {
  foreach end_year in 2023 {
	if `end_year'==2023 local endyr 3

    // get all contributing variation (not just 0-1)
    {
      use "data/final/master_set_2023", clear 
      keep if `d'
      keep if inrange(year,201`yr',`end_year') // same states for 2015 vs 2011 w/ these specifications for State YRBS
      
	  qui{

	  gcollapse (mean) ends_tax_nom35_scale, by(fips state_abbrev year semester)

	  sort fips year semester
      
      bys fips: gen ends_diff = ends_tax_nom35_scale[_n] - ends_tax_nom35_scale[_n-1]
	  replace       ends_diff = 0 if ends_diff==.
      
	  // max and min difference (if same value - doesn't contribute to ID var)
	  bys fips: egen min_ends_diff = min(ends_diff)
	  bys fips: egen max_ends_diff = max(ends_diff)

	  sort fips year semester
      
      gcollapse(mean) min_ends_diff max_ends_diff, by(fips state_abbrev)
      
      gen id_var = 1 if min_ends_diff != max_ends_diff
      
      levelsof fips if id_var == 1, local(ends_fips)
      
	  // get "dictionary" for fips codes
	  {
		// list of eststo names
		forval iter = 1/2 { // one time to define locals, second time to populate them
		foreach var of local figure_varlist { // outcome vars
		forval i = 0/1 { // het, lgbq
		forval m = 1/3 { // models
		foreach fip of local ends_fips { // treatment states
        
		  // define empty locals
		  if `iter'==1 local est_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m' est_`var'_all_`i'_y`yr'`endyr'_`dname'`m'
  
          // fill them
		  if `iter'==2 ///
		  local est_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m' est_`var'_`fip'_`i'_y`yr'`endyr'_`dname'`m' `est_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m''

		}
		}
		}
		}
		}

		
		// state abbreviation list
		forval iter = 1/2 { // one time to define locals, second time to populate them
		foreach var of local figure_varlist { // outcome vars
		forval i = 0/1 { // het, lgbq
		forval m = 1/3 { // models
		foreach fip of local ends_fips { // treatment states
          
		  // define empty locals
	      if `iter'==1 local fabr_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m' All

          // fill them
          if `iter'==2 {
		  levelsof state_abbrev if fips==`fip', clean
		  local state_abbrev = r(levels)
          local fabr_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m' `state_abbrev' `fabr_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m''
		  }
		}
		}
		}
		}
		}

		
        
		// length
		foreach var of local figure_varlist { // outcome vars
		forval i = 0/1 { // het, lgbq
		forval m = 1/3 { // models
          
		  // split estimate names into pieces
		  tokenize "`est_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m''"
		  //di "1=|`1'| 2=|`2'|"
          
		  // count number of pieces
		  forval j = 1/100 {
			if "``j''"!="" di "not done at `j'"
			if "``j''"=="" {
				di "done at `j'"
				local ct_est_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m' = `=`j'-1'
				continue, break
			}
		  }
          
		  // split state abbrevs into pieces
          tokenize "`fabr_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m''"
		  //di "1=|`1'| 2=|`2'|"
          
		  // count number of pieces
		  forval j = 1/100 {
			if "``j''"!="" di "not done at `j'"
			if "``j''"=="" {
				di "done at `j'"
				local ct_fabr_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m' = `=`j'-1'
				continue, break
			}
		  }
          
		  // make sure this makes sense -- hand check some
		  di "estimates: `ct_est_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m'', abbrev: `ct_fabr_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m''"

		}
		}
		}
		
	  }

	  }
	  di "dataset `d', y`yr'`endyr': `ends_fips'"
	}
    
    
	// regressions
	if 0 {
        use "data/final/master_set_2023", clear 
        keep if `d'
        keep if inrange(year,201`yr',`end_year')

        foreach var of local figure_varlist {

            // LASSO assignment (***)
            {
                if inlist("`var'","vape","fvape","dvape") ///
                local vars_lasso_sel ${vars_lasso_sel_`var'}

                else ///
                local vars_lasso_sel ${vars_lasso_sel_other}
            }
        
            // skip patterns
            {
                // skip vaping pre-2015
                if inlist("`var'","vape","fvape","dvape") & 201`yr'==2011 continue

                // skip vaping with national and combined yrbs
                if inlist("`var'","vape","fvape","dvape") & inlist("`dname'","nat","com") continue

                // skip smoking 2015-
                if inlist("`var'","smoke","fsmoke","dsmoke") & 201`yr'==2015 continue
            }

		foreach sex_id in 0 1 {
          
            di "`dname', y`yr'`endyr', `var', id:`sex_id'"

            // model 1: state, year, semester FE, demographics, macro/covid, 
            // ENDS taxes, flavor bans, MLSA laws, Tobacco-21 Laws, cigarette taxes
            logit `var' ///
            ${vars_essential_coef1} ${vars_essential_coef0} /// 
            ${dem_control} `technical' ///
            i.fips i.year_true i.semester ///
            if lgbq_1 == `sex_id' [pw=`weight'],  ///
            vce(cluster fips) iterate(15)
        
            matrix A = e(converged)
        
            eststo est_`var'_all_`sex_id'_y`yr'`endyr'_`dname'1: ///
            margins, dydx(ends_tax_nom35_scale) post
            estadd matrix A


            // model 2:  model 1 + LASSO selected vars
            logit `var' ///
            ${vars_essential_coef1} ${vars_essential_coef0} /// 
            `vars_lasso_sel' ///
            ${dem_control} `technical' ///
            i.fips i.year_true i.semester ///
            if lgbq_1 == `sex_id' [pw=`weight'],  ///
            vce(cluster fips) iterate(15)

            matrix A = e(converged)

            eststo est_`var'_all_`sex_id'_y`yr'`endyr'_`dname'2: ///
            margins, dydx(ends_tax_nom35_scale) post
            estadd matrix A
        

            // model 3: model 2 + LGBQ policy control
            logit `var' ///
            ${vars_essential_coef1} ${vars_essential_coef0} /// 
            `vars_lasso_sel' ///
            tally_sexualorientation ///
            ${dem_control} `technical' ///
            i.fips i.year_true i.semester ///
            if lgbq_1 == `sex_id' [pw=`weight'],  ///
            vce(cluster fips) iterate(15)

            matrix A = e(converged)

            eststo est_`var'_all_`sex_id'_y`yr'`endyr'_`dname'3: ///
            margins, dydx(ends_tax_nom35_scale) post
            estadd matrix A

            estwrite *_y`yr'`endyr'_* using "log/estimates/leaveone_y`yr'`endyr'_`dname'.sters", append
            eststo clear
            
            foreach fip of local ends_fips {

                di "`dname', y`yr'`endyr', `var', id:`sex_id', fip:`fip'"

                // model 1
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} /// 
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if (fips!=`fip') & (lgbq_1 == `sex_id') [pw=`weight'],  ///
                vce(cluster fips) iterate(15)
            
                matrix A = e(converged)
            
                eststo est_`var'_`fip'_`sex_id'_y`yr'`endyr'_`dname'1: ///
                margins, dydx(ends_tax_nom35_scale) post
                estadd matrix A


                // model 2
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} /// 
                `vars_lasso_sel' ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if (fips!=`fip') & (lgbq_1 == `sex_id') [pw=`weight'],  ///
                vce(cluster fips) iterate(15)

                matrix A = e(converged)

                eststo est_`var'_`fip'_`sex_id'_y`yr'`endyr'_`dname'2: ///
                margins, dydx(ends_tax_nom35_scale) post
                estadd matrix A
            

                // model 3
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} /// 
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if (fips!=`fip') & (lgbq_1 == `sex_id') [pw=`weight'],  ///
                vce(cluster fips) iterate(15)

                matrix A = e(converged)

                eststo est_`var'_`fip'_`sex_id'_y`yr'`endyr'_`dname'3: ///
                margins, dydx(ends_tax_nom35_scale) post
                estadd matrix A
            }

            estwrite *_y`yr'`endyr'_* using "log/estimates/leaveone_y`yr'`endyr'_`dname'.sters", append
            eststo clear
		}
        eststo clear
        }
        eststo clear 
	}
	

    // figures
	{
	  foreach var of local figure_varlist {

		// skip vaping pre-2015
		if inlist("`var'","vape","fvape","dvape") & 201`yr'==2011 continue

		// skip vaping with national and combined yrbs
		if inlist("`var'","vape","fvape","dvape") & inlist("`dname'","nat","com") continue

		// skip smoking 2015-2021
		if inlist("`var'","smoke","fsmoke","dsmoke") & 201`yr'==2015 continue

        estimates clear 
		eststo clear

		estread est_`var'_*_y`yr'`endyr'_`dname'? using "log/estimates/leaveone_y`yr'`endyr'_`dname'.sters"
        
        forval i = 0/1 { // het,lgbq
            // y-axis scale
            {
                if "`dname'" == "com" {
                    if "`var'"=="smoke"  local yscale "-0.02(0.02)0.06"
                    if "`var'"=="dsmoke" local yscale "-0.02(0.01)0.02"
                }

                if "`dname'" == "st" {
                    if "`var'"=="smoke"  local yscale "-0.02(0.02)0.04"
                    
                    if "`var'"=="dsmoke" local yscale "-0.02(0.01)0.02"

                    if "`var'"=="vape"  local yscale "-0.08(0.02)0.02"
                    if "`var'"=="fvape" local yscale "-0.04(0.02)0.04"
                    if "`var'"=="dvape" local yscale "-0.04(0.02)0.04"

                    
                    if `i'==0 & "`var'"=="fsmoke" local yscale "-0.008(0.002)0.004"
                    if `i'==1 & "`var'"=="fsmoke" local yscale "-0.020(0.005)0.010"
                }
            }
		forval m = 1/3 { // models
		
			// match together lists of estimate names and state abbreviations
			local coefplot_call 
            
			forval iter = 1/2 { // first to load up coefplot call, second time to run coefplot
			
			// "load up" coefplot command
			if `iter'==1 {
			  // loop through treatment states, collect estimates
			  forval est_num = 1/`ct_est_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m'' {
			
			  // counter
			  di "`var', `i', `m', `iter', `est_num'"

			  // split estimate names (one per treatment state)
              local est: word `est_num' of `est_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m''
              di "`est'"
			  
			  // split state abbrevs 
			  local fip_abbrev: word `est_num' of `fabr_list_`var'_f_`i'_y`yr'`endyr'_`dname'`m''
			  di "`fip_abbrev'"
  
			  local coefplot_call ///
			  (`est', msymbol(D) mcolor(black) aseq(`fip_abbrev') `converge_label') `coefplot_call'
			  }
			}
            
			// run coefplot command
            if `iter'==2 {
                coefplot ///
                `coefplot_call' ///
                , ///
                keep(ends_tax_nom35_scale) ///
                vertical yline(0,lp(dash)) ///
                graphregion(color(white)) scheme(s2mono) ///
                xlabel(, labsize(medium) angle(90)) xtitle("Treatment State Omitted From Sample", size(medium) yoffset(-2)) ///
                ytitle("Estimated Effect of ENDS Taxes", size(medium)) ///
                ylabel(`yscale', nogrid angle(0) labsize(medium) format(%7.3fc)) ///
                level(95) ///
                aseq swapnames ///
                legend(off) ///
                ciopts(recast(rcap) lcolor(black)) ///
                xsize(10) ysize(8)
                
                graph export "output/etax/graphs/final/leaveone_`dname'_y`yr'`endyr'_`var'_`i'_`m'.png", replace
                graph close 
			}
		    }
		}
		}
	  }
	}

	estimates clear 
	eststo clear
	
  }
  }
  } 

  cap log close
}

// BRFSS
if 1 {
    // construction now performed in '02_clean_master_2023.do'

    // regressions
    {
        // flavor ban events
        {
            // (q1)- quarter-based: -17 to 8
            use "data/inter/controls_quarterly_2023", clear
            keep fips year_true quarter flavor_ban
            sort fips year_true quarter

            bys fips: gen L0 = flavor_ban[_n] - flavor_ban[_n - 1]
            replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010

            // lags
            forval i = 0/8 {
            bys fips: gen q1L`i'_flav = L0[_n - `i']
            replace q1L`i'_flav = 0 if q1L`i'_flav == . // no issue b/c no ends tax pre 2010
            // endpoints:
            if `i' == 8 {
                bys fips: gen sum_q1L`i'_flav = sum(q1L`i'_flav)
                replace q1L`i'_flav = sum_q1L`i'_flav
                drop sum_q1L`i'_flav
            }
            }

            // leads
            forval i = 1/17 {
            bys fips: gen q1F`i'_flav = L0[_n + `i']
            replace q1F`i'_flav = 0 if q1F`i'_flav == . // assume future tax holds constant
            // endpoints:
            if `i' == 17 {
                gsort fips -year_true -quarter
                bys fips: gen sum_q1F`i'_flav = sum(q1F`i'_flav)
                replace q1F`i'_flav = sum_q1F`i'_flav
                drop                  sum_q1F`i'_flav
            }
            sort fips year_true quarter
            }
            order q1F17_flav q1F16_flav q1F15_flav q1F14_flav q1F13_flav q1F12_flav q1F11_flav q1F10_flav q1F9_flav q1F8_flav q1F7_flav q1F6_flav q1F5_flav ///
            q1F4_flav q1F3_flav q1F2_flav q1F1_flav, after(L0)

            gen flav_lag0_1    = q1L0_flav + q1L1_flav + q1L2_flav + q1L3_flav
            gen flav_lag2_plus = q1L4_flav + q1L5_flav + q1L6_flav + q1L7_flav + q1L8_flav

            tempfile flavor_q1
            save    `flavor_q1'
        }

        use "data/final/brfss_master_set_2023", clear

        // merge 
        {
            // flavor events
            merge m:1 fips year_true quarter using `flavor_q1'
            drop if _merge==2
            drop    _merge
        }

        // subsamples
        {
            local brfss_samples "1 !mi(heterosexual)&!mi(lgbq) heterosexual==1 lgbq==1"

            // Carpenter, Sansone splits - BMI, children, alcohol use:
            {
                local brfss_sample_alc "alcohol==0 alcohol==1"   						   // non-drinker, drinker 
                local brfss_sample_edu "hs==1 some_college==1 college==1"   			   // high school attainment, some college attainment, college graduate
                local brfss_sample_inc "hhincome_sub25==1 hhincome_2550==1 hhincome_50==1" // household income <25k, 25-50k, >50k
                local brfss_sample_hlt "hlth_cov==0 hlth_cov==1" 						   // don't have healthcare, have healthcare
                local brfss_sample_chl "has_child==0 has_child==1" 						   // don't have children, have children
                local brfss_sample_bmi "bmi_sub25==1 bmi_2530==1 bmi_30==1"				   // bmi <25, 25-30, >=30

                local brfss_sample_mh1 "mh==0 inrange(mh,1,30)" 										   // 0 days bad mh, >0 days bad mh
                local brfss_sample_mh2 "inrange(mh,0,1) inrange(mh,2,30) inrange(mh,0,2) inrange(mh,3,30)" // 0/1 bad mh days, >1 bad mh days, 0/1/2 bad mh days, >2 bad mh days
                local brfss_sample_mh3 "inrange(mh,0,0) inrange(mh,1,14) inrange(mh,15,30)" 		       // 0 bad mh days, 1-14 bad mh days, >14 bad mh days
                local brfss_sample_mh4 "inrange(mh,0,13) inrange(mh,14,30)"							       // 0-13 bad mh days, >13 bad mh days   
            
                global brfss_sample_carpenter_splits `brfss_sample_alc' `brfss_sample_edu' `brfss_sample_inc' `brfss_sample_hlt' `brfss_sample_chl' `brfss_sample_bmi' 1
            }
        }

        // gen Carpenter split and mental health vars
        {
            // gen mental health variable
            {
                gen       mh = menthlth
                replace   mh = 0 if menthlth==88 // zero days
                replace   mh = . if inlist(menthlth,77,99) // don't know/not sure and refused
                label var mh "Past 30 days, how many days with not good mental health?"
            }

            // gen household income variables
            {
                // <25k
                // 2014-2020
                gen 	hhincome_sub25 = .
                replace hhincome_sub25 = 1 if inrange(year_survey,2014,2020) & inlist(income2,1,2,3,4)
                replace hhincome_sub25 = 0 if inrange(year_survey,2014,2020) & inlist(income2,5,6,7,8)

                // 2021-2023
                replace   hhincome_sub25 = 1 if inrange(year_survey,2021,2023) & inlist(income3,1,2,3,4)
                replace   hhincome_sub25 = 0 if inrange(year_survey,2021,2023) & inlist(income3,5,6,7,8,9,10,11)
                label var hhincome_sub25 "Household income less than 25k"

                // 25-50k
                // 2014-2020
                gen 	hhincome_2550 = .
                replace hhincome_2550 = 1 if inrange(year_survey,2014,2020) & inlist(income2,5,6)
                replace hhincome_2550 = 0 if inrange(year_survey,2014,2020) & inlist(income2,1,2,3,4,7,8)

                // 2021-2023
                replace   hhincome_2550 = 1 if inrange(year_survey,2021,2023) & inlist(income3,5,6)
                replace   hhincome_2550 = 0 if inrange(year_survey,2021,2023) & inlist(income3,1,2,3,4,7,8,9,10,11)
                label var hhincome_2550 "Household income between 25k-50k"

                // >50k
                // 2014-2020
                gen 	hhincome_50 = .
                replace hhincome_50 = 1 if inrange(year_survey,2014,2020) & inlist(income2,7,8)
                replace hhincome_50 = 0 if inrange(year_survey,2014,2020) & inlist(income2,1,2,3,4,5,6)

                // 2021-2023
                replace   hhincome_50 = 1 if inrange(year_survey,2021,2023) & inlist(income3,7,8,9,10,11)
                replace   hhincome_50 = 0 if inrange(year_survey,2021,2023) & inlist(income3,1,2,3,4,5,6)
                label var hhincome_50 "Household income above 50k"
            }

            // gen healthcare coverage variable
            {
                // 2014-2020
                gen       hlth_cov = .
                replace   hlth_cov = 1 if inrange(year_survey,2014,2020) & inlist(hlthpln1,1)
                replace   hlth_cov = 0 if inrange(year_survey,2014,2020) & inlist(hlthpln1,2)

                // 2021-2022
                replace   hlth_cov = 1 if inrange(year_survey,2021,2022) & inlist(priminsr,1,2,3,4,5,6,7,8,9,10)
                replace   hlth_cov = 0 if inrange(year_survey,2021,2022) & inlist(priminsr,88)

                // 2023
                replace   hlth_cov = 1 if inrange(year_survey,2023,2023) & inlist(primins1,1,2,3,4,5,6,7,8,9,10)
                replace   hlth_cov = 0 if inrange(year_survey,2023,2023) & inlist(primins1,88)
                label var hlth_cov "Has health insurance"
            }

            // gen children variable
            {
                gen       has_child = .
                replace   has_child = 1 if inrange(children,1,87)
                replace   has_child = 0 if children==88
                label var has_child ">0 children in household"
            }

            // gen bmi variables
            {
                gen 	  bmi_sub25 = .
                replace   bmi_sub25 = 1 if inlist(_bmi5cat,1,2)
                replace   bmi_sub25 = 0 if inlist(_bmi5cat,3,4)
                label var bmi_sub25 "BMI < 25"

                gen 	  bmi_2530 = .
                replace   bmi_2530 = 1 if inlist(_bmi5cat,3)
                replace   bmi_2530 = 0 if inlist(_bmi5cat,1,2,4)
                label var bmi_2530 "BMI 25-30"

                gen 	  bmi_30 = .
                replace   bmi_30 = 1 if inlist(_bmi5cat,4)
                replace   bmi_30 = 0 if inlist(_bmi5cat,1,2,3)
                label var bmi_30 "BMI >= 30"
            }

            // gen test of difference variables
            {
                // high school/ some college


                // mental health
                // 0 days==0, >0 days==1
                gen       mh01 = .
                replace   mh01 = 0 if mh==0
                replace   mh01 = 1 if inrange(mh,1,30)
                label var mh01 "More than 0 bad mental health days"

                // 0,1 days==0, >1 days==1
                gen       mh02 = .
                replace   mh02 = 0 if inrange(mh,0,1)
                replace   mh02 = 1 if inrange(mh,2,30)
                label var mh02 "More than 1 bad mental health days"

                // 0,1,2 days==0, >2 days==1
                gen       mh03 = .
                replace   mh03 = 0 if inrange(mh,0,2)
                replace   mh03 = 1 if inrange(mh,3,30)
                label var mh03 "More than 2 bad mental health days"

                // 0-13 days==0, >13 days==1
                gen       mh13 = .
                replace   mh13 = 0 if inrange(mh,0,13)
                replace   mh13 = 1 if inrange(mh,14,30)
                label var mh13 "More than 13 bad mental health days"
            }
        }

        // demographics 
        {
            global brfss_dem_control i.age i.female c.married c.no_hs /*c.hs*/ c.some_college c.college /*c.white*/ c.black c.hispanic c.other_race
        }

        cap log close
	    log using "log/regressions/brfss", /*replace*/ append 

        // keep only 2014-2023 sample for data speed purposes
        keep if inrange(year_survey,2014,2023)

        eststo    clear 
        estimates clear

        foreach yr of numlist 4 {
            local yr_name y`yr'
        foreach yr_end of numlist 2023 {
            if `yr_end'==2023 local yr_end_name 3

        forval q = 1/4 { // subsamples
            local subsample = word("`brfss_samples'",`q')
            di "`q' `subsample'"
            // subsample names
            {
                // sex id
                if `q' == 1 local name_sample "all_u"  // all youth, unrestricted/ unconditional on sex id	
                if `q' == 2 local name_sample "all"    // all youth, conditional on sex id  	
                if `q' == 3 local name_sample "id_ht"  // heterosexual  	
                if `q' == 4 local name_sample "id_nh1" // lgbq  	
            }

        forval j = 2/2 { // weighted regs

            if `j'==2 {
                local w           w
                local weights_sum "[aw=sample_weight1]"
		        local weights     "[pw=sample_weight1]"		
            }

        forval model = 0/1 { // logit, ols
        forval flavor = 0/1 {
            // flavor-specific
            {
                if `flavor'==0 {
                    local vars_covars   ${vars_essential_coef1_b}
                    local vars_margins  c.ends_tax_nom35_scale c.any_mlsa_vape c.cigarette_tax_scale
                    local sample_flavor 1

                    local name_flavor
                }
                if `flavor'==1 { // overall flavor ban
                    local vars_covars  c.ends_tax_nom35_scale c.any_mlsa_vape c.t21 c.cigarette_tax_scale c.flavor_ban 
                    local vars_margins c.flavor_ban
                    local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR

                    local name_flavor `flavor'
                }
                if `flavor'==2 { // flavor ban lags
                    local vars_covars  c.ends_tax_nom35_scale c.any_mlsa_vape c.t21 c.cigarette_tax_scale c.flav_lag0_1 c.flav_lag2_plus
                    local vars_margins c.flav_lag0_1 c.flav_lag2_plus
                    local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR

                    local name_flavor `flavor'
                }
            }
        foreach split of global brfss_sample_carpenter_splits {
            // split names
            {
                if "`split'" == "alcohol==0"         local name_split "na" // non-drinker
                if "`split'" == "alcohol==1"         local name_split "a"  // drinker

                if "`split'" == "hs==1"              local name_split "hs" // high school
                if "`split'" == "some_college==1"    local name_split "sc" // some college
                if "`split'" == "college==1"         local name_split "c"  // college grad

                if "`split'" == "hhincome_sub25==1"  local name_split "hl" // hhincome, low (<25k)
                if "`split'" == "hhincome_2550==1"   local name_split "hm" // hhincome, medium (25-50k)
                if "`split'" == "hhincome_50==1"     local name_split "hh" // hhincome, high (>50k)
                
                if "`split'" == "hlth_cov==0"        local name_split "h0" // don't have healthcare coverage
                if "`split'" == "hlth_cov==1"        local name_split "h1" // have healthcare coverage

                if "`split'" == "has_child==0"       local name_split "c0" // don't have children
                if "`split'" == "has_child==1"       local name_split "c1" // has children

                if "`split'" == "bmi_sub25==1"       local name_split "bl" // bmi, low (<25)
                if "`split'" == "bmi_2530==1"        local name_split "bm" // bmi, medium (25-30)
                if "`split'" == "bmi_30==1"          local name_split "bh" // bmi, high (>30)

                if "`split'" == "mh==0"              local name_split "0m" // 0 bad mental health days
                if "`split'" == "inrange(mh,1,30)"   local name_split "1m" // 1 or more bad mental health days 
                if "`split'" == "inrange(mh,0,1)"    local name_split "2m" // 0 or 1 bad mental health days  
                if "`split'" == "inrange(mh,2,30)"   local name_split "3m" // 2 or more bad mental health days
                if "`split'" == "inrange(mh,0,2)"    local name_split "4m" // 0 or 1 or 2 bad mental health days
                if "`split'" == "inrange(mh,3,30)"   local name_split "5m" // 3 or more bad mental health days
                if "`split'" == "inrange(mh,0,0)"    local name_split "6m" // 0 bad mental health days   
                if "`split'" == "inrange(mh,1,14)"   local name_split "7m" // 1-14 bad mental health days 
                if "`split'" == "inrange(mh,15,30)"  local name_split "8m" // 15 or more bad mental health days
                if "`split'" == "inrange(mh,0,13)"   local name_split "9m" // 0-13 bad mental health days
                if "`split'" == "inrange(mh,14,30)"  local name_split "10m" // 14 or more bad mental health days   	  
                
                if "`split'" == "1" local name_split "di" // everyone
            }

            // skip pattern
            {
                // don't estimate Carpenter splits for entire sample
                if inlist(`q',1,2) & "`name_split'"!="di" continue

                // don't estimate Carpenter splits for flavor ban regs
                if inlist(`flavor',1,2) & "`name_split'"!="di" continue
            }
        foreach age_spec of numlist 14 35 {
            // set age range
            {
                if `age_spec' == 14 {  // (1.4) 18-30 year olds
                    local age_start 18
                    local age_end 30
                    }
                if `age_spec' == 35 {  // (3.5) 31+   year olds
                    local age_start 31
                    local age_end 80
                    }
            }
        foreach var of varlist vape dvape smoke dsmoke {

            // skip pattern
            {
                // skip smoking outcomes for carpenter splits
                if "`name_split'"!="di" & inlist("`var'","smoke","dsmoke") continue
            }
            
            di "`name_sample', `flavor', `split', `age_spec', `var'"

            summarize `var' if pre_etax_intro == 1 & !mi(pre_etax_intro) ///
            & `subsample' & inrange(age,`age_start',`age_end') ///
            & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights_sum'
            scalar pre_treat_mean`w' = r(mean)  

            // LASSO assignment (***)
            {
                local vars_lasso_sel ${vars_lasso_sel_`var'_b}
                // using 18-30 nonmissing sexual id sample for LASSO
                // cig smoking LASSO done on 2014-2023 sample
            }

            // logit
            if `model'==0 {
                // model 1: state, year, semester FE, demographics, macro/covid, 
                // ENDS taxes, flavor bans, MLSA laws, Tobacco-21 Laws, cigarette taxes
                logit `var' ///
                `vars_covars' ${vars_essential_coef0_b} ///
                ${brfss_dem_control} ///
                i.fips i.year_true i.quarter ///
                if `subsample' & inrange(age,`age_start',`age_end') ///
                & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights', ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	

                _eststo `var'1`name_flavor'_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                margins, dydx(`vars_margins') post
                estadd scalar pre_treat_mean = pre_treat_mean`w'
                estadd scalar converge       = converge_pre


                // model 2: model 1 + LASSO variables
                logit `var' ///
                `vars_covars' ${vars_essential_coef0_b} ///
                `vars_lasso_sel' ///
                ${brfss_dem_control} ///
                i.fips i.year_true i.quarter ///
                if `subsample' & inrange(age,`age_start',`age_end') ///
                & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights', ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	

                _eststo `var'2`name_flavor'_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                margins, dydx(`vars_margins') post
                estadd scalar pre_treat_mean = pre_treat_mean`w'
                estadd scalar converge       = converge_pre

                
                // model 3: model 2 + LGBQ policy control
                logit `var' ///
                `vars_covars' ${vars_essential_coef0_b} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${brfss_dem_control} ///
                i.fips i.year_true i.quarter ///
                if `subsample' & inrange(age,`age_start',`age_end') ///
                & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights', ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	

                _eststo `var'3`name_flavor'_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                margins, dydx(`vars_margins') post
                estadd scalar pre_treat_mean = pre_treat_mean`w'
                estadd scalar converge       = converge_pre


                if `q'==2 { // fully differenced
                    // model 1
                    _eststo `var'1do`name_flavor'_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                    logit `var' ///
                    lgbq##( ///
                    `vars_covars' ${vars_essential_coef0_b} ///
                    ${brfss_dem_control} ///
                    i.fips i.year_true i.quarter) /// 
                    if `subsample' & inrange(age,`age_start',`age_end') ///
                    & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights', ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)


                    // model 2
                    _eststo `var'2do`name_flavor'_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                    logit `var' ///
                    lgbq##( ///
                    `vars_covars' ${vars_essential_coef0_b} ///
                    `vars_lasso_sel' ///
                    ${brfss_dem_control} ///
                    i.fips i.year_true i.quarter) /// 
                    if `subsample' & inrange(age,`age_start',`age_end') ///
                    & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights', ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)


                    // model 3
                    _eststo `var'3do`name_flavor'_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                    logit `var' ///
                    lgbq##( ///
                    `vars_covars' ${vars_essential_coef0_b} ///
                    `vars_lasso_sel' ///
                    c.tally_sexualorientation ///
                    ${brfss_dem_control} ///
                    i.fips i.year_true i.quarter) /// 
                    if `subsample' & inrange(age,`age_start',`age_end') ///
                    & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights', ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)
                }
            }

            // ols
            if `model'==1 {
                // model 1
                _eststo `var'1`name_flavor'o_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                reghdfe `var' ///
                `vars_covars' ${vars_essential_coef0_b} ///
                ${brfss_dem_control} ///
                if `subsample' & inrange(age,`age_start',`age_end') ///
                & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights_sum', ///
                absorb(i.fips i.year_true i.quarter) vce(cluster fips) nosample

                estadd scalar pre_treat_mean = pre_treat_mean`w'

                // model 2
                _eststo `var'2`name_flavor'o_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                reghdfe `var' ///
                `vars_covars' ${vars_essential_coef0_b} ///
                `vars_lasso_sel' ///
                ${brfss_dem_control} ///
                if `subsample' & inrange(age,`age_start',`age_end') ///
                & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights_sum', ///
                absorb(i.fips i.year_true i.quarter) vce(cluster fips) nosample

                estadd scalar pre_treat_mean = pre_treat_mean`w'

                // model 3
                _eststo `var'3`name_flavor'o_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                reghdfe `var' ///
                `vars_covars' ${vars_essential_coef0_b} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${brfss_dem_control} ///
                if `subsample' & inrange(age,`age_start',`age_end') ///
                & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights_sum', ///
                absorb(i.fips i.year_true i.quarter) vce(cluster fips) nosample

                estadd scalar pre_treat_mean = pre_treat_mean`w'

                if `q'==2 { // fully differenced
                    // weird naming -- b/c logit has "1do"
                    // model 1
                    _eststo `var'1d`name_flavor'_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                    reghdfe `var' ///
                    lgbq##( ///
                    `vars_covars' ${vars_essential_coef0_b} ///
                    ${brfss_dem_control}) /// 
                    if `subsample' & inrange(age,`age_start',`age_end') ///
                    & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights_sum', ///
                    absorb(fips year_true quarter ///
                    lgbq#fips lgbq#year_true lgbq#quarter) vce(cluster fips) nosample
                    
                    // model 2
                    _eststo `var'2d`name_flavor'_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                    reghdfe `var' ///
                    lgbq##( ///
                    `vars_covars' ${vars_essential_coef0_b} ///
                    ${brfss_dem_control} ///
                    `vars_lasso_sel') /// 
                    if `subsample' & inrange(age,`age_start',`age_end') ///
                    & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights_sum', ///
                    absorb(fips year_true quarter ///
                    lgbq#fips lgbq#year_true lgbq#quarter) vce(cluster fips) nosample

                    // model 3
                    _eststo `var'3d`name_flavor'_`age_spec'_`name_sample'`yr_name'`yr_end_name'`name_split'`w': ///
                    reghdfe `var' ///
                    lgbq##( ///
                    `vars_covars' ${vars_essential_coef0_b} ///
                    ${brfss_dem_control} ///
                    `vars_lasso_sel' ///
                    c.tally_sexualorientation) /// 
                    if `subsample' & inrange(age,`age_start',`age_end') ///
                    & inrange(year_survey,201`yr',`yr_end') & `sample_flavor' & `split' `weights_sum', ///
                    absorb(fips year_true quarter ///
                    lgbq#fips lgbq#year_true lgbq#quarter) vce(cluster fips) nosample
                }
            }
        }
        }
            estwrite _all using "log/estimates/brfss_`model'.sters", append
            eststo clear
            estimates clear
        }
        }
        }
        }

        }
        
        }
        }

        log close
    }
}

// other policies (unique conditions for flavor bans)
if 1 {
    cap log close 
    log using "log/regressions/other_pol_v2.smcl", /*replace*/ append

    eststo clear 
    estimates clear
    
    // create flavor ban events
    {
        /* (s1)- semester-based: -14 to 5 */ { 
            use "data/inter/master_control2023_semester", clear
            keep fips year_true semester flavor_ban
            sort fips year_true semester

            bys fips: gen L0 = flavor_ban[_n] - flavor_ban[_n - 1]
            replace L0 = 0 if L0 == . // fips 26 first state, in sem 2 of 2010

            * Lags
            forval i = 0/5 {
            bys fips: gen s1L`i'_flav = L0[_n - `i']
            replace s1L`i'_flav = 0 if s1L`i'_flav == . // no issue b/c no ends tax pre 2010
            // endpoints:
            if `i' == 5 {
                bys fips: gen sum_s1L`i'_flav = sum(s1L`i'_flav)
                replace s1L`i'_flav = sum_s1L`i'_flav
                drop sum_s1L`i'_flav
            }
            }

            * Leads
            forval i = 1/14 {
            bys fips: gen s1F`i'_flav = L0[_n + `i']
            replace s1F`i'_flav = 0 if s1F`i'_flav == . // assume future tax holds constant
            // endpoints:
            if `i' == 14 {
                gsort fips -year_true -semester
                bys fips: gen sum_s1F`i'_flav = sum(s1F`i'_flav)
                replace s1F`i'_flav = sum_s1F`i'_flav
                drop                  sum_s1F`i'_flav
            }
            sort fips year_true semester
            }
            order s1F14_flav s1F13_flav s1F12_flav s1F11_flav s1F10_flav s1F9_flav s1F8_flav s1F7_flav s1F6_flav s1F5_flav ///
            s1F4_flav s1F3_flav s1F2_flav s1F1_flav, after(L0)

            gen flav_lead5_plus = s1F14_flav + s1F13_flav + s1F12_flav + s1F11_flav + s1F10_flav + s1F9_flav
            gen flav_lead4_3    = s1F8_flav  + s1F7_flav  + s1F6_flav  + s1F5_flav
            gen flav_lead2_1    = s1F4_flav  + s1F3_flav  + s1F2_flav  + s1F1_flav
            gen flav_lag0_1     = s1L0_flav  + s1L1_flav  + s1L2_flav  + s1L3_flav
            gen flav_lag2_plus  = s1L4_flav  + s1L5_flav

            tempfile flavor_s1
            save    `flavor_s1'
        }
    }

    // create annual controls
    {
        // grab control file
        use "data/inter/master_control2023_semester.dta", clear

        // scale taxes to $2019
        summ cpi if year_true ==2019, meanonly
        local cpi_2019 = r(mean)
        di   `cpi_2019'

        gen cpi_2019 = cpi/`cpi_2019' 

        foreach var of varlist ends_tax_nom35 cigarette_tax beer_tax {
            gen `var'_19 = `var' / cpi_2019
        }

        gcollapse ///
        ends_tax_nom35_scale ends_tax_nom35_19 flavor_ban any_mlsa_vape t21 cigarette_tax_scale cigarette_tax_19 ///
        indoor_ban_vape ecigban indoor_ban_smoke tobacco_lis_law_any MML ///
        uer coviddeaths populationvaccinated, ///
        by(fips year_true)

        rename (ends_tax_nom35_scale ends_tax_nom35_19 flavor_ban any_mlsa_vape t21 cigarette_tax_scale cigarette_tax_19 ///
        indoor_ban_vape ecigban indoor_ban_smoke tobacco_lis_law_any MML ///
        uer coviddeaths populationvaccinated) ///
        (ends_tax_nom35_scale_avg ends_tax_nom35_19_avg flavor_ban_avg any_mlsa_vape_avg t21_avg cigarette_tax_scale_avg cigarette_tax_19_avg ///
        indoor_ban_vape_avg ecigban_avg indoor_ban_smoke_avg tobacco_lis_law_any_avg MML_avg ///
        uer_avg coviddeaths_avg populationvaccinated_avg)

        rename year_true year // ignore "year_true" information

        tempfile avg
        save    `avg'

        // grab sexual orientation tally
        {
            use "${path_cheps_google}/datasets/map_lgbtq/data/clean/policy_tally", clear
            rename state_fips fips

            // create quantiles
            local num_quan 4
            foreach var in tally_sexualorientation tally_genderid tally_overall {
                xtile `var'_q`num_quan' = `var', nquantiles(`num_quan')
            }

            // backfill to 2011
            expand 5 if year==2015, gen(backfill)
            bys fips: egen subtract_yr = seq()    if backfill==1
            replace year = year - subtract_yr     if backfill==1
            sort fips year
            drop backfill subtract_yr

            rename ///
            (tally_sexualorientation     tally_genderid     tally_overall) ///
            (tally_sexualorientation_avg tally_genderid_avg tally_overall_avg)

            tempfile map_policy_avg
            save    `map_policy_avg'
        }
    }

    foreach i in !national /*national*/ 1 {
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
    foreach yr in 2011 2015 /*2017*/ {
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

    // merges 
    {
        // flavor events
        merge m:1 fips year_true semester using `flavor_s1'
        drop if _merge==2
        drop    _merge

        gen flav_lead2_1_og = flav_lead2_1
        replace flav_lead2_1 = 0 // set as reference

        // control file avg
        merge m:1 fips year using `avg'
        drop if _merge==2
        drop    _merge

        // sexual orientation avg
        merge m:1 fips year using `map_policy_avg'
        drop if _merge==2
        drop    _merge
    }

    // create spatial het vars (***) 
    {
        // create census region variable
        gen 	region=1 if inlist(fips, 9,23,25,33,44,50,34,36,42)
        replace region=2 if inlist(fips, 18,17,26,39,55,19,20,27,29,31,38,46)
        replace region=3 if inlist(fips, 10,11,12,13,24,37,45,51,54,1,21,28,47,5,22,40,48)
        replace region=4 if inlist(fips, 4,8,16,35,30,49,32,56,2,6,15,41,53)

        // create census division variable
        gen     division = .
        replace division = 1 if inlist(fips, 9,23,25,33,44,50)
        replace division = 2 if inlist(fips, 34,36,42)
        replace division = 3 if inlist(fips, 18,17,26,39,55)
        replace division = 4 if inlist(fips, 19,20,27,29,31,38,46)
        replace division = 5 if inlist(fips, 10,11,12,13,24,37,45,51,54)
        replace division = 6 if inlist(fips, 1,21,28,47)
        replace division = 7 if inlist(fips, 5,22,40,48)
        replace division = 8 if inlist(fips, 4,8,16,35,30,49,32,56)
        replace division = 9 if inlist(fips, 2,6,15,41,53)      
        
        // create time variable
        gen 	time = 1 if year == 2011
        replace time = 2 if year == 2013
        replace time = 3 if year == 2015
        replace time = 4 if year == 2017
        replace time = 5 if year == 2019
        replace time = 6 if year == 2021
        replace time = 7 if year == 2023


        // allow states to have different trends
        bys fips: egen fips_treat_diff = total(ends_tax_nom35_scale)
        replace        fips_treat_diff = 1 if (fips_treat_diff > 0) & !mi(fips_treat_diff)
        replace        fips_treat_diff = fips_treat_diff * fips

        // force common trend for all treated states
        bys fips: gen fips_treat_common = (fips_treat_diff > 0)  
    }
    
    keep if `i'	
    keep if inrange(year,`yr',`yr_end')		

    foreach q in 5 6 9 10 { // subsample
        forval exclude_2021 = 0/1 { // exclude 2021 survey
            if `exclude_2021'==0 local sample_2021 1
            if `exclude_2021'==1 local sample_2021 "year!=2021"
        forval ddd_explicit = 0/1 { // explicit DDD coefficient
            cap drop flavor_ban_x_lgbq 
            gen flavor_ban_x_lgbq = flavor_ban * lgbq_1
        foreach spatial of numlist 0 5 6 { // spatial heterogeneity

        // skip patterns
        {
            // only one restriction (2021, ddd explicit) at at time
            if `exclude_2021'+`ddd_explicit'==2 continue
            if (`exclude_2021'+`ddd_explicit'>0) & `spatial'!=0 continue
        }

        // spatial het model
        {
            if `spatial'==0 /// non-spatial heterogeneity
            local vars_spatial 
            if `spatial'==1 /// census region-year FE
            local vars_spatial i.region#i.year_true
            if `spatial'==2 /// census division-year FE
            local vars_spatial i.division#i.year_true
            if `spatial'==3 /// state-specific linear time trends
            local vars_spatial i.fips#c.time
            if `spatial'==4 /// tr state-specific linear time trends
            local vars_spatial i.fips_treat_diff#c.time
            if `spatial'==5 /// common tr state linear time trend
            local vars_spatial i.fips_treat_common#c.time
            if `spatial'==6 /// census-region specific linear time trends
            local vars_spatial i.region#c.time
            if `spatial'==7 /// census-division specific linear time trends
            local vars_spatial i.division#c.timek
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

        foreach var of varlist vape fvape dvape smoke fsmoke dsmoke combust fcombust dcombust {
        foreach model of numlist 3 4 /*1 2*/ { // independent var: {flavor ban lags, T21, flavor ban overall, flavor ban event study}

            // model-specific
            {
                if `model'==1 { // flavor ban lags
                    local sample_model "!inlist(fips,6,11,25,41)"
                    // CA,DC,MA,OR

                    local flavor_ban c.flav_lag0_1 c.flav_lag2_plus
                }
                if `model'==2 { // tobacco 21
                    local sample_model "(year<2021)"

                    local ind_var_avg  c.t21_avg
                }
                if `model'==3 { // flavor ban overall
                    local sample_model "!inlist(fips,6,11,25,41)"
                    // CA,DC,MA,OR

                    local flavor_ban c.flavor_ban
                }
                if `model'==4 { // flavor ban event study
                    local sample_model "!inlist(fips,6,11,25,41)"
                    // CA,DC,MA,OR

                    local flavor_ban     c.flav_lead5_plus c.flav_lead4_3 c.flav_lead2_1    c.flav_lag0_1 c.flav_lag2_plus
                    local flavor_ban_adj c.flav_lead5_plus c.flav_lead4_3 c.flav_lead2_1_og c.flav_lag0_1 c.flav_lag2_plus
                }
            }

            // LASSO assignment (***)
            {
                // control vars w/o flavor
                local vars_essential_coef1 ///
                c.ends_tax_nom35_scale /*c.flavor_ban*/ c.any_mlsa_vape i.t21 c.cigarette_tax_scale

                // control vars w/ averages
                local vars_essential_coef1_avg ///
                c.ends_tax_nom35_scale_avg c.flavor_ban_avg c.any_mlsa_vape_avg c.t21_avg c.cigarette_tax_scale_avg
                local vars_essential_coef0_avg ///
                c.uer_avg c.coviddeaths_avg c.populationvaccinated_avg
                local vars_lasso_sel_vape_avg ///
                c.indoor_ban_vape_avg c.ecigban_avg c.indoor_ban_smoke_avg c.tobacco_lis_law_any_avg
                local vars_lasso_sel_fvape_avg ///
                c.indoor_ban_vape_avg c.ecigban_avg c.indoor_ban_smoke_avg c.MML_avg
                local vars_lasso_sel_dvape_avg ///
                c.indoor_ban_vape_avg c.ecigban_avg c.indoor_ban_smoke_avg c.MML_avg

                if inlist("`var'","vape","fvape","dvape") {
                    local vars_lasso_sel     ${vars_lasso_sel_`var'}
                    local vars_lasso_sel_avg  `vars_lasso_sel_`var'_avg'
                }

                else ///
                local vars_lasso_sel ${vars_lasso_sel_`var'`yr_name'}
            }
            
            // skip patterns
            {
                // only vaping/smoking outcomes for national and combined YRBS
                if !inlist("`var'","vape","fvape","dvape","smoke","fsmoke","dsmoke") & ("`i'" != "!national") continue

                // vaping outcomes start in 2015, smoking outcomes start in 2011
                if  inlist("`var'","vape","fvape","dvape") & ("`yr'"=="2011") continue
                *if !inlist("`var'","vape","fvape","dvape") & ("`yr'"=="2015") continue
            
                // event studies only for hetero,lgbq
                if inlist(`q',5,6) & `model'==4 continue
            }

            di "`name' `yr' `name_sample' `exclude_2021' `ddd_explicit' `spatial' `var' `model'"

            summarize `var' ///
            if pre_etax_intro == 1 & !mi(pre_etax_intro) & `subsample' & `sample_model' & `sample_2021' ///
            [aw=`weight'], meanonly
            scalar pre_treat_mean = r(mean)

            // logistic regression
            {
                /*
                    // model 1: state, year, semester FE, demographics, macro/covid, 
                    // ENDS taxes, flavor bans, MLSA laws, Tobacco-21 Laws, cigarette taxes
                    logit `var' ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' & `sample_model' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)	

                    _eststo `var'_1l`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    margins, dydx(`ind_var') post
                    estadd scalar pre_treat_mean = pre_treat_mean
                    estadd scalar converge       = converge_pre


                    // model 2: model 1 + LASSO selected vars
                    logit `var' ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' & `sample_model' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)	

                    _eststo `var'_2l`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    margins, dydx(`ind_var') post
                    estadd scalar pre_treat_mean = pre_treat_mean
                    estadd scalar converge       = converge_pre


                    // model 3: model 2 + LGBQ policy control
                    logit `var' ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    tally_sexualorientation ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' & `sample_model' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)	

                    _eststo `var'_3l`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    margins, dydx(`ind_var') post
                    estadd scalar pre_treat_mean = pre_treat_mean
                    estadd scalar converge       = converge_pre

                    if `q'==6 {
                        // model 1
                        _eststo `var'_1ldo`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        logit `var' ///
                        lgbq_1##( ///
                        ${vars_essential_coef1} ${vars_essential_coef0} ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester) /// 
                        if `subsample' & `sample_model' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)

                        // model 2
                        _eststo `var'_2ldo`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        logit `var' ///
                        lgbq_1##( ///
                        ${vars_essential_coef1} ${vars_essential_coef0} ///
                        `vars_lasso_sel' ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester) /// 
                        if `subsample' & `sample_model' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)

                        // model 3
                        _eststo `var'_3ldo`model'_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        logit `var' ///
                        lgbq_1##( ///
                        ${vars_essential_coef1} ${vars_essential_coef0} ///
                        `vars_lasso_sel' ///
                        c.tally_sexualorientation ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester) /// 
                        if `subsample' & `sample_model' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)
                    }
                */

                if inlist(`model',1,3,4) { // flavor ban lags, overall, event study
                    if `ddd_explicit'==0 {
                    if "`i'"=="!national" & `exclude_2021'==0 & ///
                    !(inlist("`var'","smoke","fsmoke","dsmoke","combust","fcombust","dcombust") & `yr'==2015) {
                        // model 1
                        logit `var' ///
                        `flavor_ban' ///
                        `vars_essential_coef1' ${vars_essential_coef0} ///
                        `vars_spatial' ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester ///
                        if `subsample' & `sample_model' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)

                        scalar converge_pre = e(converged)	

                        _eststo `var'_1l`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        margins, dydx(`flavor_ban') post
                        estadd scalar pre_treat_mean = pre_treat_mean
                        estadd scalar converge       = converge_pre


                        // model 2
                        logit `var' ///
                        `flavor_ban' ///
                        `vars_essential_coef1' ${vars_essential_coef0} ///
                        `vars_lasso_sel' ///
                        `vars_spatial' ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester ///
                        if `subsample' & `sample_model' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)

                        scalar converge_pre = e(converged)	

                        _eststo `var'_2l`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        margins, dydx(`flavor_ban') post
                        estadd scalar pre_treat_mean = pre_treat_mean
                        estadd scalar converge       = converge_pre
                    }

                    // model 3
                    logit `var' ///
                    `flavor_ban' ///
                    `vars_essential_coef1' ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    tally_sexualorientation ///
                    `vars_spatial' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' & `sample_model' & `sample_2021' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)	

                    _eststo `var'_3l`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    margins, dydx(`flavor_ban') post
                    estadd scalar pre_treat_mean = pre_treat_mean
                    estadd scalar converge       = converge_pre
                    }

                    if `q'==6 {
                        if `ddd_explicit'==0 {
                        if "`i'"=="!national" & `exclude_2021'==0 & ///
                        !(inlist("`var'","smoke","fsmoke","dsmoke","combust","fcombust","dcombust") & `yr'==2015) {
                            // model 1
                            _eststo `var'_1ldo`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                            logit `var' ///
                            lgbq_1##( ///
                            `flavor_ban' ///
                            `vars_essential_coef1' ${vars_essential_coef0} ///
                            `vars_spatial' ///
                            ${dem_control} `technical' ///
                            i.fips i.year_true i.semester) /// 
                            if `subsample' & `sample_model' [pw=`weight'], ///
                            vce(cluster fips) iterate(15)
                            estadd scalar converge = e(converged)

                            // model 2
                            _eststo `var'_2ldo`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                            logit `var' ///
                            lgbq_1##( ///
                            `flavor_ban' ///
                            `vars_essential_coef1' ${vars_essential_coef0} ///
                            `vars_lasso_sel' ///
                            `vars_spatial' ///
                            ${dem_control} `technical' ///
                            i.fips i.year_true i.semester) /// 
                            if `subsample' & `sample_model' [pw=`weight'], ///
                            vce(cluster fips) iterate(15)
                            estadd scalar converge = e(converged)
                        }

                        // model 3
                        _eststo `var'_3ldo`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        logit `var' ///
                        lgbq_1##( ///
                        `flavor_ban' ///
                        `vars_essential_coef1' ${vars_essential_coef0} ///
                        `vars_lasso_sel' ///
                        c.tally_sexualorientation ///
                        `vars_spatial' ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester) /// 
                        if `subsample' & `sample_model' & `sample_2021' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)
                        }

                        if `ddd_explicit'==1 & `model'==3 {
                        // model 3
                        logit `var' ///
                        lgbq_1##( ///
                        `vars_essential_coef1' ${vars_essential_coef0} ///
                        `vars_lasso_sel' ///
                        c.tally_sexualorientation ///
                        `vars_spatial' ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester) /// 
                        flavor_ban flavor_ban_x_lgbq ///
                        if `subsample' & `sample_model' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)

                        _eststo `var'_3ldo`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        margins, dydx(flavor_ban flavor_ban_x_lgbq) post
                        }
                    }
                }

                /*
                if `model'==2 { // annual average for T21
                    summarize `var' ///
                    if pre_etax_intro == 1 & !mi(pre_etax_intro) & `subsample' ///
                    [aw=`weight'], meanonly
                    scalar pre_treat_mean = r(mean)

                    // model 1
                    logit `var' ///
                    `vars_essential_coef1_avg' `vars_essential_coef0_avg' ///
                    `vars_spatial' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)	

                    _eststo `var'_1l`model'a_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    margins, dydx(`ind_var_avg') post
                    estadd scalar pre_treat_mean = pre_treat_mean
                    estadd scalar converge       = converge_pre


                    // model 2
                    logit `var' ///
                    `vars_essential_coef1_avg' `vars_essential_coef0_avg' ///
                    `vars_lasso_sel_avg' ///
                    `vars_spatial' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)	

                    _eststo `var'_2l`model'a_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    margins, dydx(`ind_var_avg') post
                    estadd scalar pre_treat_mean = pre_treat_mean
                    estadd scalar converge       = converge_pre


                    // model 3
                    logit `var' ///
                    `vars_essential_coef1_avg' `vars_essential_coef0_avg' ///
                    `vars_lasso_sel_avg' ///
                    tally_sexualorientation_avg ///
                    `vars_spatial' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' [pw=`weight'], ///
                    vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)	

                    _eststo `var'_3l`model'a_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    margins, dydx(`ind_var_avg') post
                    estadd scalar pre_treat_mean = pre_treat_mean
                    estadd scalar converge       = converge_pre

                    if `q'==6 {
                        // model 1
                        _eststo `var'_1ldo`model'a_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        logit `var' ///
                        lgbq_1##( ///
                        `vars_essential_coef1_avg' `vars_essential_coef0_avg' ///
                        `vars_spatial' ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester) /// 
                        if `subsample' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)

                        // model 2
                        _eststo `var'_2ldo`model'a_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        logit `var' ///
                        lgbq_1##( ///
                        `vars_essential_coef1_avg' `vars_essential_coef0_avg' ///
                        `vars_lasso_sel_avg' ///
                        `vars_spatial' ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester) /// 
                        if `subsample' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)

                        // model 3
                        _eststo `var'_3ldo`model'a_`name_sample'`yr_name'`yr_end_name'_`name': ///
                        logit `var' ///
                        lgbq_1##( ///
                        `vars_essential_coef1_avg' `vars_essential_coef0_avg' ///
                        `vars_lasso_sel_avg' ///
                        c.tally_sexualorientation_avg ///
                        `vars_spatial' ///
                        ${dem_control} `technical' ///
                        i.fips i.year_true i.semester) /// 
                        if `subsample' [pw=`weight'], ///
                        vce(cluster fips) iterate(15)
                        estadd scalar converge = e(converged)
                    }
                }
                */
            }

            // ols, cnsreg event studies
            if "`i'"=="!national" & `exclude_2021'==0 & `ddd_explicit'==0 & /// 
            !(inlist("`var'","smoke","fsmoke","dsmoke","combust","fcombust","dcombust") & `yr'==2015) & ///
            inlist(`model',3,4) {
                // OLS:
                // model 1
                _eststo `var'_1`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                `flavor_ban' ///
                `vars_essential_coef1' ${vars_essential_coef0} ///
                ${dem_control} `technical' ///
                if `subsample' & `sample_model' [pw=`weight'], ///
                vce(cluster fips) absorb(i.fips i.year_true i.semester `vars_spatial') nosample
                estadd scalar pre_treat_mean = pre_treat_mean

                // model 2
                _eststo `var'_2`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                `flavor_ban' ///
                `vars_essential_coef1' ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                ${dem_control} `technical' ///
                if `subsample' & `sample_model' [pw=`weight'], ///
                vce(cluster fips) absorb(i.fips i.year_true i.semester `vars_spatial') nosample
                estadd scalar pre_treat_mean = pre_treat_mean

                // model 3
                _eststo `var'_3`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                `flavor_ban' ///
                `vars_essential_coef1' ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${dem_control} `technical' ///
                if `subsample' & `sample_model' [pw=`weight'], ///
                vce(cluster fips) absorb(i.fips i.year_true i.semester `vars_spatial') nosample
                estadd scalar pre_treat_mean = pre_treat_mean

                if `q'==6 {
                    if `spatial'==0 local spatial_interact 
                    else            local spatial_interact "lgbq_1#(`vars_spatial')"

                    // model 1
                    _eststo `var'_1do`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    `flavor_ban' ///
                    `vars_essential_coef1' ${vars_essential_coef0} ///
                    ${dem_control} `technical') ///
                    if `subsample' & `sample_model' [pw=`weight'], ///
                    vce(cluster fips) ///
                    absorb(i.fips i.year_true i.semester `vars_spatial' ///
                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester `spatial_interact') nosample
                    estadd scalar pre_treat_mean = pre_treat_mean

                    // model 2
                    _eststo `var'_2do`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    `flavor_ban' ///
                    `vars_essential_coef1' ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    ${dem_control} `technical') ///
                    if `subsample' & `sample_model' [pw=`weight'], ///
                    vce(cluster fips) ///
                    absorb(i.fips i.year_true i.semester `vars_spatial' ///
                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester `spatial_interact') nosample
                    estadd scalar pre_treat_mean = pre_treat_mean

                    // model 3
                    _eststo `var'_3do`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    `flavor_ban' ///
                    `vars_essential_coef1' ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    c.tally_sexualorientation ///
                    ${dem_control} `technical') ///
                    if `subsample' & `sample_model' [pw=`weight'], ///
                    vce(cluster fips) ///
                    absorb(i.fips i.year_true i.semester `vars_spatial' ///
                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester `spatial_interact') nosample
                    estadd scalar pre_treat_mean = pre_treat_mean
                }

                // cnsreg:
                if `spatial'==0 & `model'==4 {
                    constraint 1 (flav_lead5_plus + flav_lead4_3 + flav_lead2_1_og) / 3 = 0
                    // model 1
                    _eststo `var'_1c`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    cnsreg `var' ///
                    `flavor_ban_adj' ///
                    `vars_essential_coef1' ${vars_essential_coef0} ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' & `sample_model' [pw=`weight'], ///
                    vce(cluster fips) constraints(1)
                    estadd scalar pre_treat_mean = pre_treat_mean

                    // model 2
                    _eststo `var'_2c`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    cnsreg `var' ///
                    `flavor_ban_adj' ///
                    `vars_essential_coef1' ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' & `sample_model' [pw=`weight'], ///
                    vce(cluster fips) constraints(1)
                    estadd scalar pre_treat_mean = pre_treat_mean

                    // model 3
                    _eststo `var'_3c`model'l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    cnsreg `var' ///
                    `flavor_ban_adj' ///
                    `vars_essential_coef1' ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    tally_sexualorientation ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester ///
                    if `subsample' & `sample_model' [pw=`weight'], ///
                    vce(cluster fips) constraints(1)
                    estadd scalar pre_treat_mean = pre_treat_mean
                }
            }
        }
        }	

        // write estimates
        {
            /*
                // logit
                *** TEMPORARY estwrite *_1l?_*`name' *_1l?l_*`name' *_1l?a_*`name' using "log/estimates/other_pol_v2_`yr_name'`yr_end_name'`name'1l", append 
                *** TEMPORARY estwrite *_2l?_*`name' *_2l?l_*`name' *_2l?a_*`name' using "log/estimates/other_pol_v2_`yr_name'`yr_end_name'`name'2l", append
                *** TEMPORARY estwrite *_3l?_*`name' *_3l?l_*`name' *_3l?a_*`name' using "log/estimates/other_pol_v2_`yr_name'`yr_end_name'`name'3l", append
            */

            if `exclude_2021'==0 & `ddd_explicit'==0 { // "normal" estimates
                // logit
                if "`i'"=="!national" estwrite *_1l?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'1l.sters", append
                if "`i'"=="!national" estwrite *_2l?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'2l.sters", append
                estwrite *_3l?l_*`name'                       using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'3l.sters", append

                // OLS
                if "`i'"=="!national" {
                estwrite *_1?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'1.sters", append
                estwrite *_2?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'2.sters", append
                estwrite *_3?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'3.sters", append
                }
                if `q'==6 {
                    /*
                        // logit
                        *** TEMPORARY estwrite *_1ldo?_*`name' *_1ldo?l_*`name' *_1ldo?a_*`name' using "log/estimates/other_pol_v2_`yr_name'`yr_end_name'`name'1l", append 
                        *** TEMPORARY estwrite *_2ldo?_*`name' *_2ldo?l_*`name' *_2ldo?a_*`name' using "log/estimates/other_pol_v2_`yr_name'`yr_end_name'`name'2l", append
                        *** TEMPORARY estwrite *_3ldo?_*`name' *_3ldo?l_*`name' *_3ldo?a_*`name' using "log/estimates/other_pol_v2_`yr_name'`yr_end_name'`name'3l", append
                    */

                    // logit
                    if "`i'"=="!national" estwrite *_1ldo?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'1l.sters", append 
                    if "`i'"=="!national" estwrite *_2ldo?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'2l.sters", append
                    estwrite *_3ldo?l_*`name'                       using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'3l.sters", append

                    // ols
                    if "`i'"=="!national" {
                    estwrite *_1do?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'1.sters", append 
                    estwrite *_2do?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'2.sters", append
                    estwrite *_3do?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'3.sters", append
                    }
                }

                // cnsreg
                if inlist(`q',9,10) & `spatial'==0 & "`i'"=="!national" {
                    estwrite *_1c?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'1c.sters", append
                    estwrite *_2c?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'2c.sters", append
                    estwrite *_3c?l_*`name' using "log/estimates/other_pol_v2`spatial'_`yr_name'`yr_end_name'`name'3c.sters", append
                }
            }

            if !(`exclude_2021'==0 & `ddd_explicit'==0) { // excluding 2021/ explicit DDD coefficients
                if `exclude_2021'==1 { // exclude 2021 - logit
                estwrite           *_3l?l_*`name'   using "log/estimates/other_pol_v2`spatial'_2021_`yr_name'`yr_end_name'`name'3l.sters", append
                if `q'==6 estwrite *_3ldo?l_*`name' using "log/estimates/other_pol_v2`spatial'_2021_`yr_name'`yr_end_name'`name'3l.sters", append
                }

                if `ddd_explicit'==1 { // explicit DDD coef
                if `q'==6 estwrite *_3ldo?l_*`name' using "log/estimates/other_pol_v2`spatial'_ddd_`yr_name'`yr_end_name'`name'3l.sters", append
                }
            } 
        }
        eststo clear
        }
    }
    }
    }
    eststo clear
    }
    }
    eststo clear
    }

    log close

    macro drop _model_name _spatial_interact
}

// unweighted regs
if 1 {
    cap log close 
    log using "log/regressions/unweighted.smcl", replace
    
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
    
    keep if `i'	
    keep if inrange(year,`yr',`yr_end')		

    foreach q in 5 6 9 10 /*11 12 13 14 25 26 27 28 29 30 31 32 33 34*/ { 

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

            // OLS
            if `model'==1 {
                // model 1: state, year, semester FE, demographics, macro/covid, 
                // ENDS taxes, flavor bans, MLSA laws, Tobacco-21 Laws, cigarette taxes
                _eststo `var'_1_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${dem_control} `technical' ///
                if `subsample', ///
                abs(fips year_true semester) vce(cluster fips) nosample	
                estadd scalar pre_treat_mean = pre_treat_mean	


                // model 2: model 1 + LASSO selected vars
                _eststo `var'_2_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                ${dem_control} `technical' ///
                if `subsample', ///
                abs(fips year_true semester) vce(cluster fips) nosample	
                estadd scalar pre_treat_mean = pre_treat_mean


                // model 3: model 2 + LGBQ policy control
                _eststo `var'_3_`name_sample'`yr_name'`yr_end_name'_`name': ///
                reghdfe `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${dem_control} `technical' ///
                if `subsample', ///
                abs(fips year_true semester) vce(cluster fips) nosample	
                estadd scalar pre_treat_mean = pre_treat_mean


                if `q'==6 { // fully-differenced
                    // model 1
                    _eststo `var'_1d_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    ${dem_control} `technical') /// 
                    if `subsample', ///
                    absorb(fips year_true semester ///
                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester) ///
                    vce(cluster fips) nosample


                    // model 2
                    _eststo `var'_2d_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    ${dem_control} `technical') /// 
                    if `subsample', ///
                    absorb(fips year_true semester ///
                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester) ///
                    vce(cluster fips) nosample


                    // model 3
                    _eststo `var'_3d_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    reghdfe `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    c.tally_sexualorientation ///
                    ${dem_control} `technical') /// 
                    if `subsample', ///
                    absorb(fips year_true semester ///
                    lgbq_1#fips lgbq_1#year_true lgbq_1#semester) ///
                    vce(cluster fips) nosample
                }
            }

            // logit
            if `model'==2 {
                // model 1: state, year, semester FE, demographics, macro/covid, 
                // ENDS taxes, flavor bans, MLSA laws, Tobacco-21 Laws, cigarette taxes
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if `subsample', ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	
                matrix A            = e(converged)

                _eststo `var'_1l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                margins, dydx(${vars_essential_coef1}) post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre
                
                local mat_size = wordcount(e(xvars)) 
                matrix B = J(1,`mat_size',.)
                forval b = 1/`mat_size' {
                matrix B[1,`b'] = A[1,1]
                }
                estadd matrix B


                // model 2: model 1 + LASSO selected vars
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if `subsample', ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	
                matrix A = e(converged)

                _eststo `var'_2l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                margins, dydx(${vars_essential_coef1}) post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre
                
                local mat_size = wordcount(e(xvars)) 
                matrix B = J(1,`mat_size',.)
                forval b = 1/`mat_size' {
                matrix B[1,`b'] = A[1,1]
                }
                estadd matrix B


                // model 3: model 2 + LGBQ policy control
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                tally_sexualorientation ///
                ${dem_control} `technical' ///
                i.fips i.year_true i.semester ///
                if `subsample', ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)	
                matrix A            = e(converged)

                _eststo `var'_3l_`name_sample'`yr_name'`yr_end_name'_`name': ///
                margins, dydx(${vars_essential_coef1}) post
                estadd scalar pre_treat_mean = pre_treat_mean
                estadd scalar converge       = converge_pre
                
                local mat_size = wordcount(e(xvars)) 
                matrix B = J(1,`mat_size',.)
                forval b = 1/`mat_size' {
                matrix B[1,`b'] = A[1,1]
                }
                estadd matrix B

                if `q'==6 {
                    // model 1
                    _eststo `var'_1ldo_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester) /// 
                    if `subsample', ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)

                    // model 2
                    _eststo `var'_2ldo_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester) /// 
                    if `subsample', ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)

                    // model 3
                    _eststo `var'_3ldo_`name_sample'`yr_name'`yr_end_name'_`name': ///
                    logit `var' ///
                    lgbq_1##( ///
                    ${vars_essential_coef1} ${vars_essential_coef0} ///
                    `vars_lasso_sel' ///
                    c.tally_sexualorientation ///
                    ${dem_control} `technical' ///
                    i.fips i.year_true i.semester) /// 
                    if `subsample', ///
                    vce(cluster fips) iterate(15)
                    estadd scalar converge = e(converged)
                }
            }
        }
        }	

        // write estimates
        {
            /*
            // OLS
            cap estwrite *_1_*`name' using "log/estimates/unweighted_`yr_name'`yr_end_name'`name'1", append 
            cap estwrite *_2_*`name' using "log/estimates/unweighted_`yr_name'`yr_end_name'`name'2", append
            cap estwrite *_3_*`name' using "log/estimates/unweighted_`yr_name'`yr_end_name'`name'3", append
            */

            // logit
            cap estwrite *_?l_*`name' using "log/estimates/unweighted_`yr_name'`yr_end_name'`name'l", append 

            if `q'==6 {
                /*
                // OLS
                cap estwrite *_1d_*`name' using "log/estimates/unweighted_`yr_name'`yr_end_name'`name'1", append 
                cap estwrite *_2d_*`name' using "log/estimates/unweighted_`yr_name'`yr_end_name'`name'2", append
                cap estwrite *_3d_*`name' using "log/estimates/unweighted_`yr_name'`yr_end_name'`name'3", append
                */

                // logit
                cap estwrite *_?ldo_*`name' using "log/estimates/unweighted_`yr_name'`yr_end_name'`name'l", append 
            }
        }
        eststo clear
    }
    eststo clear
    }
    }
    eststo clear
    }

    log close
}

// ENDS tax as outcome, R2
if 1 {
    // initial submission full regression model; 2015-2021,2015-2023

    foreach sample in !mi(lgbq_1) lgbq_1==0 lgbq_1==1 {
        if "`sample'"=="!mi(lgbq_1)" local name_sample all
        if "`sample'"=="lgbq_1==0"   local name_sample id_ht
        if "`sample'"=="lgbq_1==1"   local name_sample id_nh1
    foreach year_end of numlist 2021 2023 {
        // year_end-specific
        {
            if `year_end'==1 local name_scale 1
            else             local name_scale
        }

        // full sample w/ sexual ID
        _eststo `name_sample'_`year_end': ///
        reg ends_tax_nom35_scale`name_scale' ///
        ///
        c.uer c.coviddeaths ///
        ///
        c.cigarette_tax_scale`name_scale' ///
        c.indoor_ban_smoke i.tobacco_lis_law_any ///
        ///
        c.any_mlsa_vape i.t21 /*c.ends_tax_nom35_scale*/ ///
        c.ecigs_lis_law_any c.indoor_ban_vape c.flavor_ban i.ecigban ///
        ///
        c.naloxone c.samaritan_alc c.beer_tax_scale`name_scale' c.RML c.MML ///
        ///
        i.year_true i.semester i.fips ///
        ///
        i.sex i.grade i.age i.race4 ///
        if !national & `sample' & inrange(year,2015,`year_end') ///
        [aw=aweight], ///
        vce(cluster fips) 
    }
    }

    esttab full_2021 full_2023 id_ht_2021 id_ht_2023 id_nh1_2021 id_nh1_2023 ///
    using "output/etax/figures/final/r2_initialmodel.rtf", ///
    replace ///
    mtitles("2015-2021" "2015-2023" "2015-2021" "2015-2023" "2015-2021" "2015-2023") ///
    mgroups("Full Sample with Sexual ID" "Hetero" "LGBQ", pattern(1 0 1 0 1 0)) ///
    drop(*) r2 nonotes modelwidth(6)

    macro drop _name_scale
} 

// ad valorem vs excise tax
if 1 {
    eststo clear
    estimates clear

    use "data/final/master_set_2023", clear

    global dem_control i.sex i.grade i.age i.race4

    // create vars
    {
        // ends tax var
        gen ends_tax_excise = 0
        gen ends_tax_adval  = 0
        gen ends_tax_hybrid = 0

        gen ends_tax_adval_hybrid  = 0
        gen ends_tax_excise_hybrid = 0

        // dummy var
        gen excise       = 0
        gen adval        = 0  
        gen hybrid       = 0 
        
        gen excise_hybrid = 0
        gen adval_hybrid  = 0 

        // excise tax (12)
        local fips_codes 9 10 20 22 31 34 37 39 51 53 54 55
        foreach fip of local fips_codes {
            replace ends_tax_excise_hybrid = ends_tax_nom35_scale if fips==`fip'
            replace ends_tax_excise        = ends_tax_nom35_scale if fips==`fip'

            replace excise_hybrid          = 1                    if fips==`fip' & ends_tax_nom35_scale!=0
            replace excise                 = 1                    if fips==`fip' & ends_tax_nom35_scale!=0
        }

        // ad valorem (16 + D.C)
        local fips_codes 6 8 15 17 18 23 24 25 27 32 36 41 42 49 50 56 11
        foreach fip of local fips_codes {
            replace ends_tax_adval_hybrid = ends_tax_nom35_scale if fips==`fip'
            replace ends_tax_adval        = ends_tax_nom35_scale if fips==`fip'
            
            replace adval_hybrid          = 1                    if fips==`fip' & ends_tax_nom35_scale!=0
            replace adval                 = 1                    if fips==`fip' & ends_tax_nom35_scale!=0
        }

        // both (5)
        local fips_codes 13 21 33 35 44
        foreach fip of local fips_codes {
            replace ends_tax_excise_hybrid = ends_tax_nom35_scale if fips==`fip'
            replace ends_tax_adval_hybrid  = ends_tax_nom35_scale if fips==`fip'
            replace ends_tax_hybrid        = ends_tax_nom35_scale if fips==`fip'
            
            replace excise_hybrid          = 1                    if fips==`fip' & ends_tax_nom35_scale!=0
            replace adval_hybrid           = 1                    if fips==`fip' & ends_tax_nom35_scale!=0
            replace hybrid                 = 1                    if fips==`fip' & ends_tax_nom35_scale!=0
        }

        { // state list
            // excise tax (12)
            /*
                Connecticut 9     (decent pre/post 2019-2021)
                Delaware 10       (2019 missing, tax b/w 2017 and 2021.)
                Kansas 20         (x - 1 year of lgbq info)
                Louisiana 22      (x - no years of lgbq info)
                Nebraska 31       (x - no ENDS tax in data)
                New Jersey 34     ("always adopter", real tax value strictly decreasing in sample)
                North Carolina 37 ("always adopter", nominal increase b/w 2015 and 2017)
                Ohio 39           (x - no state YRBS)
                Virginia 51       (decent pre/post)
                Washington 53     (x - no state YRBS)
                West Virginia 54  (decent pre/post)
                Wisconsin 55      (decent pre/post)

                only 6/7 states in estimation (6 if remove NJ as "always adopter")
            */
            // ad valorem (16 + D.C)
            /*
                California 6      (decent pre/post)
                Colorado 8        (decent pre/post)
                Hawaii 15         (x - no ENDS tax in data)
                Illinois 17       (decent pre/post)
                Indiana 18        (decent pre/post)
                Maine 23          (decent pre/post)
                Maryland 24       (decent pre/post)
                Massachusetts 25  (x - 1 year of survey)
                Minnesota 27      (x - no state YRBS)
                Nevada 32         (decent pre/post)
                New York 36       (decent pre/post)
                Oregon 41         (x - no state YRBS)
                Pennsylvania 42   (decent pre/post)
                Utah 49           (decent pre/post)
                Vermont 50        (decent pre/post)
                Wyoming 56        (x - no state YRBS)
                Washington D.C. 11 (x - no state YRBS)

                11 states in estimation
            */
            // both (5)
            /*
                Georgia 13       (x - no lgbq data)
                Kentucky 21      (decent pre/post)
                New Hampshire 33 (decent pre/post)
                New Mexico 35    (decent pre/post)
                Rhode Island 44  (x - no ENDS tax in data)

                3 states in estimation
            */
        }

        /*
            // dummmy
            reghdfe vape excise adval_hybrid c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
            ${vars_lasso_sel_vape} tally_sexualorientation  ${dem_control} if lgbq_1==0 [pw=aweight], vce(cluster fips) absorb( i.fips i.year_true i.semester)
            // excise: 0.002[p=0.943], adval_hybrid: 0.012 [p=0.0387]

            // continuous
            reghdfe vape ends_tax_excise ends_tax_adval_hybrid c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
            ${vars_lasso_sel_vape} tally_sexualorientation  ${dem_control} if lgbq_1==0 [pw=aweight], vce(cluster fips) absorb( i.fips i.year_true i.semester)
            // ends_tax_excise: -0.223**[p=0.014], ends_tax_adval_hybrid: -0.020*[p=0.060]

            { // sanity check
                reghdfe vape ends_tax_nom35_scale c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
                ${vars_lasso_sel_vape} tally_sexualorientation  ${dem_control} if lgbq_1==0 [pw=aweight], vce(cluster fips) absorb( i.fips i.year_true i.semester)
            } // -0.026**

            // gen regular ends tax introduction var
            gen ends_tax = 0
            replace ends_tax = 1 if ends_tax_nom35_scale != 0
            reghdfe vape ends_tax c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
            ${vars_lasso_sel_vape} tally_sexualorientation  ${dem_control} if lgbq_1==0 [pw=aweight], vce(cluster fips) absorb( i.fips i.year_true i.semester)
            // ends_tax: 0.009 [p=0.494]
            // NO EFFECT OF TAXES IF USING A BINARY ON/OFF


            // continuous, with excise_hybrid
            reghdfe vape ends_tax_excise_hybrid ends_tax_adval c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
            ${vars_lasso_sel_vape} tally_sexualorientation  ${dem_control} if lgbq_1==0 [pw=aweight], vce(cluster fips) absorb( i.fips i.year_true i.semester)
            // 
        */
        /*
            gcollapse vape lgbq_1 ends_tax_nom35_scale excise adval_hybrid ends_tax_excise ends_tax_adval_hybrid ends_tax_adval ends_tax_hybrid  [aw=aweight] ///
            if !national & inrange(year,2015,2023), by(state year)
            // Delaware
            {
                no 2019 survey. 2017: no endstax, vape=
            }
        */
    }

    gen endstax_x_adval_hybrid = ends_tax_nom35_scale * adval_hybrid
    gen endstax_x_adval        = ends_tax_nom35_scale * adval
    gen endstax_x_hybrid       = ends_tax_nom35_scale * hybrid

    // regs
    foreach subsample in !mi(lgbq_1) lgbq_1==0 lgbq_1==1 {
        // subsample-specific
        {
            if "`subsample'"=="!mi(lgbq_1)" local name_sample all
            if "`subsample'"=="lgbq_1==0"   local name_sample id_ht
            if "`subsample'"=="lgbq_1==1"   local name_sample id_nh1
        }
    foreach var of varlist fvape fsmoke {
        if "`var'"=="fvape" local vars_lasso_sel ${vars_lasso_sel_`var'}
        else                local vars_lasso_sel ${vars_lasso_sel_`var'y1}
        // test of difference
        if "`subsample'"=="!mi(lgbq_1)" {
            /*
            // model 3
            // 1: dummy
            _eststo `var'_3ldo_`name_sample'1: ///
            logit `var' ///
            lgbq_1##( ///
            i.excise_hybrid i.adval ///
            c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
            `vars_lasso_sel' ///
            c.tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester) ///
            if `subsample' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            estadd scalar converge = e(converged)

            // 2: cont
            _eststo `var'_3ldo_`name_sample'2: ///
            logit `var' ///
            lgbq_1##( ///
            c.ends_tax_excise_hybrid c.ends_tax_adval ///
            c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
            `vars_lasso_sel' ///
            c.tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester) ///
            if `subsample' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            estadd scalar converge = e(converged)
            */

            if "`var'"=="fsmoke" {
                // 2: cont

                // use 'difficult'
                _eststo `var'_3ldo_`name_sample'2_a: ///
                logit `var' ///
                lgbq_1##( ///
                c.ends_tax_excise_hybrid c.ends_tax_adval ///
                c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' [pw=aweight], difficult ///
                vce(cluster fips) iterate(15)

                estadd scalar converge = e(converged)
                // works!

                // use OLS
                _eststo `var'_3ld_`name_sample'2: ///
                reghdfe `var' ///
                lgbq_1##( ///
                c.ends_tax_excise_hybrid c.ends_tax_adval ///
                c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control}) ///
                if `subsample' [aw=aweight], ///
                absorb(fips year_true semester ///
                lgbq_1#fips lgbq_1#year_true lgbq_1#semester) ///
                vce(cluster fips) nosample

                estadd scalar converge = e(converged)
            }
        }

        /*
        // average marginal effect
        else {
            // model 3: model 2 + LGBQ policy control
            // 1: dummy
            logit `var' ///
            i.excise_hybrid i.adval ///
            c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
            `vars_lasso_sel' ///
            tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `subsample' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `var'_3l_`name_sample'1: ///
            margins, dydx(excise_hybrid adval) post
            estadd scalar converge = converge_pre

            // 2: cont
            logit `var' ///
            ends_tax_excise_hybrid ends_tax_adval ///
            c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
            `vars_lasso_sel' ///
            tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `subsample' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `var'_3l_`name_sample'2: ///
            margins, dydx(ends_tax_excise_hybrid ends_tax_adval) post
            estadd scalar converge = converge_pre

            // test excise = adval
            test ends_tax_excise_hybrid = ends_tax_adval
            estadd scalar excise_equal_adval = `r(p)'
        }
        */
    }
    }

    // table
    {
        set matsize 5000

        esttab fvape_3l_id_ht1 fsmoke_3l_id_ht1 ///
        using "output/etax/figures/final/excise_adval.rtf", ///
        replace keep(1.excise_hybrid 1.adval) b(3) se(3) ${stars} ///
        mtitles("Frequent ENDS Use" "Frequent Cigarette Smoking") ///
        refcat(1.excise_hybrid "Panel I: Heterosexual", nolabel) nonotes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(15) varwidth(20) nogaps onecell

        esttab fvape_3l_id_nh11 fsmoke_3l_id_nh11 ///
        using "output/etax/figures/final/excise_adval.rtf", ///
        append keep(1.excise_hybrid 1.adval) b(3) se(3) ${stars} ///
        nomtitle ///
        refcat(1.excise_hybrid "Panel I: LGBQ", nolabel) nonum nonotes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(15) varwidth(20) nogaps onecell

        esttab fvape_3ldo_all1 fsmoke_3ldo_all1 ///
        using "output/etax/figures/final/excise_adval.rtf", ///
        append keep(1.lgbq_1#1.excise_hybrid 1.lgbq_1#1.adval) main(p) b(3) not ${stars} ///
        stats(N converge, fmt(0 0)) ///
        nomtitle ///
        nonum notes ///
        modelwidth(15) varwidth(20) nogaps onecell

        esttab fvape_3l_id_ht2 fsmoke_3l_id_ht2 ///
        using "output/etax/figures/final/excise_adval.rtf", ///
        append keep(ends_tax_excise_hybrid ends_tax_adval) b(3) se(3) ${stars} ///
        nomtitle ///
        refcat(ends_tax_excise_hybrid "Panel II: Heterosexual", nolabel) nonotes ///
        stats(excise_equal_adval N converge, fmt(3 0 0)) ///
        modelwidth(15) varwidth(20) nogaps onecell

        esttab fvape_3l_id_nh12 fsmoke_3l_id_nh12 ///
        using "output/etax/figures/final/excise_adval.rtf", ///
        append keep(ends_tax_excise_hybrid ends_tax_adval) b(3) se(3) ${stars} ///
        nomtitle ///
        refcat(ends_tax_excise_hybrid "Panel II: LGBQ", nolabel) nonum nonotes ///
        stats(excise_equal_adval N converge, fmt(3 0 0)) ///
        modelwidth(15) varwidth(20) nogaps onecell

        esttab fvape_3ldo_all2 fsmoke_3ldo_all2 ///
        using "output/etax/figures/final/excise_adval.rtf", ///
        append keep(1.lgbq_1#c.ends_tax_excise_hybrid 1.lgbq_1#c.ends_tax_adval) main(p) b(3) not ${stars} ///
        stats(N converge, fmt(0 0)) ///
        nomtitle ///
        nonum notes ///
        modelwidth(15) varwidth(20) nogaps onecell
    }
    // table v2 (with fsmoke adjusted for 'difficult')
    {
        esttab fsmoke_3ldo_all2_a ///
        using "output/etax/figures/final/excise_adval_v2.rtf", ///
        replace keep(1.lgbq_1#c.ends_tax_excise_hybrid 1.lgbq_1#c.ends_tax_adval) main(p) b(3) not ${stars} ///
        mtitles("Frequent Cigarette Smoking") ///
        refcat(1.excise_hybrid "Panel I: Heterosexual", nolabel) nonotes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(15) varwidth(20) nogaps onecell
    }
}

// remove 2021 survey
if 1 {
    eststo clear
    estimates clear

    use "data/final/master_set_2023", clear

    global dem_control i.sex i.grade i.age i.race4

    // regs
    foreach subsample in !mi(lgbq_1) lgbq_1==0 lgbq_1==1 {
        // subsample-specific
        {
            if "`subsample'"=="!mi(lgbq_1)" local name_sample all
            if "`subsample'"=="lgbq_1==0"   local name_sample id_ht
            if "`subsample'"=="lgbq_1==1"   local name_sample id_nh1
        }
    foreach var of varlist fvape fsmoke {
        if "`var'"=="fvape" local vars_lasso_sel ${vars_lasso_sel_`var'}
        else                local vars_lasso_sel ${vars_lasso_sel_`var'y1}

        summarize `var' ///
        if pre_etax_intro == 1 & !mi(pre_etax_intro) & `subsample' & year!=2021 ///
        [aw=aweight], meanonly
        scalar pre_treat_mean = r(mean)

        // test of difference
        if "`subsample'"=="!mi(lgbq_1)" {
            /*
                // model 1
                _eststo `var'_1ldo_`name_sample': ///
                logit `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' & year != 2021 [pw=aweight], ///
                vce(cluster fips) iterate(15)

                estadd scalar converge = e(converged)

                // model 2
                _eststo `var'_2ldo_`name_sample': ///
                logit `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${vars_lasso_sel_`var'} ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' & year != 2021 [pw=aweight], ///
                vce(cluster fips) iterate(15)

                estadd scalar converge = e(converged)
            */

            // model 3
            if "`var'"=="fvape" { // use logit
                _eststo `var'_3ldo_`name_sample': ///
                logit `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' & year != 2021 [pw=aweight], ///
                vce(cluster fips) iterate(15)
                estadd scalar converge = e(converged)
            }
            if "`var'"=="fsmoke" { // use OLS
                // ends tax, cig tax, MLSA
                _eststo `var'_3do_`name_sample': ///
                reghdfe `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control}) ///
                if `subsample' & year != 2021 [aw=aweight], ///
                vce(cluster fips) absorb(fips year_true semester ///
                lgbq_1#fips lgbq_1#year_true lgbq_1#semester) nosample

                // flavor ban
                _eststo `var'_3do3l_`name_sample': ///
                reghdfe `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control}) ///
                if `subsample' & year != 2021 & !inlist(fips,6,11,25,41) [aw=aweight], ///
                vce(cluster fips) absorb(fips year_true semester ///
                lgbq_1#fips lgbq_1#year_true lgbq_1#semester) nosample
            }
        }

        // average marginal effect
        else {
            /*
                // model 1
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${dem_control} ///
                i.fips i.year_true i.semester ///
                if `subsample' & year != 2021 [pw=aweight], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)

                _eststo `var'_1l_`name_sample': ///
                margins, dydx(ends_tax_nom35_scale) post
                estadd scalar converge = converge_pre

                // model 2
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${vars_lasso_sel_`var'} ///
                ${dem_control} ///
                i.fips i.year_true i.semester ///
                if `subsample' & year != 2021 [pw=aweight], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)

                _eststo `var'_2l_`name_sample': ///
                margins, dydx(ends_tax_nom35_scale) post
                estadd scalar converge = converge_pre
            */

            // model 3: model 2 + LGBQ policy control
            logit `var' ///
            ${vars_essential_coef1} ${vars_essential_coef0} ///
            `vars_lasso_sel' ///
            tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `subsample' & year != 2021 [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `var'_3l_`name_sample': ///
            margins, dydx(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) post
            estadd scalar converge = converge_pre
            estadd scalar pre_treat_mean = pre_treat_mean
        }
    }
    }

    // table
    {
        esttab fvape_3l_id_ht fsmoke_3l_id_ht ///
        using "output/etax/figures/final/remove2021.rtf", ///
        replace keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) order(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) ///
        b(3) se(3) ${stars} ///
        mtitles("Frequent ENDS Use" "Frequent Cigarette Smoking") ///
        refcat(ends_tax_nom35_scale "Heterosexual", nolabel) nonotes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab fvape_3l_id_nh1 fsmoke_3l_id_nh1 ///
        using "output/etax/figures/final/remove2021.rtf", ///
        append keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) order(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) ///
        b(3) se(3) ${stars} ///
        nomtitle ///
        refcat(ends_tax_nom35_scale "LGBQ", nolabel) nonum nonotes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab fvape_3ldo_all fsmoke_3do_all /// use OLS for fsmoke fully dif
        using "output/etax/figures/final/remove2021.rtf", ///
        append keep(1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape) ///
        order(1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape) main(p) b(3) not ${stars} ///
        stats(N converge, fmt(0 0)) ///
        nomtitle ///
        nonum notes ///
        modelwidth(6) varwidth(20) nogaps onecell
    }

    // table flavor ban
    {
        estread *vape* using "log\estimates\other_pol_v20_2021_y53st3l.sters"
        estread *smoke* using "log\estimates\other_pol_v20_2021_y13st3l.sters"
        set matsize 5000

        esttab ///
        vape_3l3l_id_hty53_st fvape_3l3l_id_hty53_st dvape_3l3l_id_hty53_st ///
        smoke_3l3l_id_hty13_st fsmoke_3l3l_id_hty13_st dsmoke_3l3l_id_hty13_st ///
        using "output/etax/figures/final/remove2021_flavor.rtf", ///
        replace keep(flavor_ban) b(3) se(3) ${stars} ///
        mtitles("Current ENDS Use" "Frequent ENDS Use" "Everyday ENDS Use" "Current Cigarette Smoking" "Frequent Cigarette Smoking" "Everyday Cigarette Smoking") ///
        refcat(flavor_ban "Heterosexual", nolabel) nonotes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab ///
        vape_3l3l_id_nh1y53_st fvape_3l3l_id_nh1y53_st dvape_3l3l_id_nh1y53_st ///
        smoke_3l3l_id_nh1y13_st fsmoke_3l3l_id_nh1y13_st dsmoke_3l3l_id_nh1y13_st ///
        using "output/etax/figures/final/remove2021_flavor.rtf", ///
        append keep(flavor_ban) b(3) se(3) ${stars} ///
        nomtitle ///
        refcat(flavor_ban "LGBQ", nolabel) nonum nonotes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab ///
        vape_3ldo3l_ally53_st fvape_3ldo3l_ally53_st dvape_3ldo3l_ally53_st ///
        smoke_3ldo3l_ally13_st fsmoke_3ldo3l_ally13_st dsmoke_3ldo3l_ally13_st ///
        using "output/etax/figures/final/remove2021_flavor.rtf", ///
        append keep(1.lgbq_1#c.flavor_ban) main(p) b(3) not ${stars} ///
        stats(N converge, fmt(0 0)) ///
        nomtitle ///
        nonum notes ///
        modelwidth(6) varwidth(20) nogaps onecell
    }

    // table flavor ban v2 (with only OLS fsmoke)
    {
        esttab ///
        fsmoke_3do3l_all ///
        using "output/etax/figures/final/remove2021_flavor_v2.rtf", ///
        append keep(1.lgbq_1#c.flavor_ban) main(p) b(3) not ${stars} ///
        stats(N, fmt(0 0)) ///
        mtitle("Frequent Cigarette Smoking") ///
        nonum notes ///
        modelwidth(6) varwidth(20) nogaps onecell
    }
}

// union of selected LASSO controls
if 1 {
    eststo clear
    estimates clear

    use "data/final/master_set_2023", clear

    global dem_control i.sex i.grade i.age i.race4

    // combine selected vars (use union of LASSO selections)
    local vars_lasso_sel

    foreach var in $vars_lasso_sel_fvape $vars_lasso_sel_fsmokey1 {
        if strpos("`vars_lasso_sel'", "`var'")==0 {
            local vars_lasso_sel `vars_lasso_sel' `var'
        }
    }
    di "`vars_lasso_sel'"

    // regs
    foreach subsample in !mi(lgbq_1) lgbq_1==0 lgbq_1==1 {
        // subsample-specific
        {
            if "`subsample'"=="!mi(lgbq_1)" local name_sample all
            if "`subsample'"=="lgbq_1==0"   local name_sample id_ht
            if "`subsample'"=="lgbq_1==1"   local name_sample id_nh1
        }
    foreach var of varlist fvape fsmoke {

        summarize `var' ///
        if pre_etax_intro == 1 & !mi(pre_etax_intro) & `subsample' ///
        [aw=aweight], meanonly
        scalar pre_treat_mean = r(mean)

        // test of difference
        if "`subsample'"=="!mi(lgbq_1)" {

            // model 3
            if "`var'"=="fvape" {   
                // use logit
                // ends tax, cig tax, MLSA
                _eststo `var'_3ld_`name_sample': ///
                logit `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' [pw=aweight], ///
                vce(cluster fips) iterate(15)
                estadd scalar converge = e(converged)

                // flavor ban
                _eststo `var'_3ld3l_`name_sample': ///
                logit `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' & !inlist(fips,6,11,25,41) [pw=aweight], ///
                vce(cluster fips) iterate(15)
                estadd scalar converge = e(converged)
            }

            if "`var'"=="fsmoke" { // use OLS
                // ends tax, cig tax, MLSA
                _eststo `var'_3do_`name_sample': ///
                reghdfe `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control}) ///
                if `subsample' [aw=aweight], ///
                vce(cluster fips) absorb(fips year_true semester ///
                lgbq_1#fips lgbq_1#year_true lgbq_1#semester) nosample

                // flavor ban
                _eststo `var'_3do3l_`name_sample': ///
                reghdfe `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control}) ///
                if `subsample' & !inlist(fips,6,11,25,41) [aw=aweight], ///
                vce(cluster fips) absorb(fips year_true semester ///
                lgbq_1#fips lgbq_1#year_true lgbq_1#semester) nosample
            }
        }

        // average marginal effect
        else {
            // model 3: model 2 + LGBQ policy control
            logit `var' ///
            ${vars_essential_coef1} ${vars_essential_coef0} ///
            `vars_lasso_sel' ///
            tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `subsample' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `var'_3l_`name_sample': ///
            margins, dydx(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) post
            estadd scalar converge = converge_pre
            estadd scalar pre_treat_mean = pre_treat_mean

            // flavor ban
            logit `var' ///
            ${vars_essential_coef1} ${vars_essential_coef0} ///
            `vars_lasso_sel' ///
            tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `subsample' & !inlist(fips,6,11,25,41) [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `var'_3l3l_`name_sample': ///
            margins, dydx(flavor_ban) post
            estadd scalar converge = converge_pre
            estadd scalar pre_treat_mean = pre_treat_mean
        }
    }
    }

    // table
    {
        esttab fvape_3l_id_ht fsmoke_3l_id_ht ///
        using "output/etax/figures/final/lasso_union.rtf", ///
        replace keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) order(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) ///
        b(3) se(3) ${stars} ///
        mtitles("Frequent ENDS Use" "Frequent Cigarette Smoking") ///
        refcat(ends_tax_nom35_scale "Heterosexual", nolabel) nonotes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab fvape_3l_id_nh1 fsmoke_3l_id_nh1 ///
        using "output/etax/figures/final/lasso_union.rtf", ///
        append keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) order(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) ///
        b(3) se(3) ${stars} ///
        nomtitle ///
        refcat(ends_tax_nom35_scale "LGBQ", nolabel) nonum nonotes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab fvape_3ld_all fsmoke_3do_all /// use OLS for fsmoke fully dif
        using "output/etax/figures/final/lasso_union.rtf", ///
        append keep(1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape) ///
        order(1.lgbq_1#c.ends_tax_nom35_scale 1.lgbq_1#c.cigarette_tax_scale 1.lgbq_1#c.any_mlsa_vape) main(p) b(3) not ${stars} ///
        stats(N converge, fmt(0 0)) ///
        nomtitle ///
        nonum notes ///
        modelwidth(6) varwidth(20) nogaps onecell
    }

    // table flavor ban
    {
        esttab fvape_3l3l_id_ht fsmoke_3l3l_id_ht ///
        using "output/etax/figures/final/lasso_union_1.rtf", ///
        replace keep(flavor_ban) ///
        b(3) se(3) ${stars} ///
        mtitles("Frequent ENDS Use" "Frequent Cigarette Smoking") ///
        refcat(ends_tax_nom35_scale "Heterosexual", nolabel) nonotes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab fvape_3l3l_id_nh1 fsmoke_3l3l_id_nh1 ///
        using "output/etax/figures/final/lasso_union_1.rtf", ///
        append keep(flavor_ban) ///
        b(3) se(3) ${stars} ///
        nomtitle ///
        refcat(ends_tax_nom35_scale "LGBQ", nolabel) nonum nonotes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab fvape_3ld3l_all fsmoke_3do3l_all /// use OLS for fsmoke fully dif
        using "output/etax/figures/final/lasso_union_1.rtf", ///
        append keep(1.lgbq_1#c.flavor_ban) ///
        main(p) b(3) not ${stars} ///
        stats(N converge, fmt(0 0)) ///
        nomtitle ///
        nonum notes ///
        modelwidth(6) varwidth(20) nogaps onecell
    }
}

// use $0.01 tax increase instead of $1 increase
if 1 {
    eststo clear
    estimates clear

    use "data/final/master_set_2023", clear

    global dem_control i.sex i.grade i.age i.race4

    gen ends_tax_nom35_scale_cents = ends_tax_nom35_scale * 100
    gen cigarette_tax_scale_cents  = cigarette_tax_scale * 100

    // regs
    foreach subsample in !mi(lgbq_1) lgbq_1==0 lgbq_1==1 {
        // subsample-specific
        {
            if "`subsample'"=="!mi(lgbq_1)" local name_sample all
            if "`subsample'"=="lgbq_1==0"   local name_sample id_ht
            if "`subsample'"=="lgbq_1==1"   local name_sample id_nh1
        }
    foreach var of varlist /*vape*/ fvape /*dvape smoke*/ fsmoke /*dsmoke*/ {
        if "`var'"=="fvape"  local vars_lasso_sel ${vars_lasso_sel_`var'}
        if "`var'"=="fsmoke" local vars_lasso_sel ${vars_lasso_sel_`var'y1}

        // test of difference
        if "`subsample'"=="!mi(lgbq_1)" {
            // model 3
            if "`var'"=="fvape" {
                _eststo `var'_3ldo_`name_sample': ///
                logit `var' ///
                lgbq_1##( ///
                c.ends_tax_nom35_scale_cents c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale_cents ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' [pw=aweight], ///
                vce(cluster fips) iterate(15)

                estadd scalar converge = e(converged)
            }

            if "`var'"=="fsmoke" { // OLS for non-convergence (kind of odd but keeping consistent presentation)
                _eststo `var'_3ld_`name_sample': ///
                reghdfe `var' ///
                lgbq_1##( ///
                c.ends_tax_nom35_scale_cents c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale_cents ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control}) ///
                if `subsample' [aw=aweight] , ///
                vce(cluster fips) ///
                absorb(fips year_true semester ///
                lgbq_1#fips lgbq_1#year_true lgbq_1#semester) nosample
            }
        }

        // average marginal effect
        else {
            // model 3: model 2 + LGBQ policy control
            logit `var' ///
            c.ends_tax_nom35_scale_cents c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale_cents ${vars_essential_coef0} ///
            `vars_lasso_sel' ///
            tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `subsample' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `var'_3l_`name_sample': ///
            margins, dydx(ends_tax_nom35_scale_cents cigarette_tax_scale_cents) post

            estadd scalar converge = converge_pre

            xlincom (_b[ends_tax_nom35_scale_cents] * 100) ///
            (_b[cigarette_tax_scale_cents] * 100), ///
            level(95) post
            _eststo `var'_3l_`name_sample'_100
        }
    }
    }

    set matsize 5000

    // table 1 -- unscaled
    if 0 {
        esttab vape_3l_id_ht fvape_3l_id_ht dvape_3l_id_ht smoke_3l_id_ht fsmoke_3l_id_ht dsmoke_3l_id_ht ///
        using "output/etax/figures/final/response_cents.rtf", ///
        replace keep(ends_tax_nom35_scale_cents) b(6) se(6) ${stars} ///
        mtitles("Current ENDS Use" "Frequent ENDS Use" "Everyday ENDS Use") ///
        refcat(ends_tax_nom35_scale_cents "Heterosexual", nolabel) nonotes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab vape_3l_id_nh1 fvape_3l_id_nh1 dvape_3l_id_nh1 smoke_3l_id_nh1 fsmoke_3l_id_nh1 dsmoke_3l_id_nh1 ///
        using "output/etax/figures/final/response_cents.rtf", ///
        append keep(ends_tax_nom35_scale_cents) b(6) se(6) ${stars} ///
        nomtitle ///
        refcat(ends_tax_nom35_scale_cents "LGBQ", nolabel) nonum nonotes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab vape_3ldo_all fvape_3ldo_all dvape_3ldo_all smoke_3ldo_all fsmoke_3ldo_all dsmoke_3ldo_all ///
        using "output/etax/figures/final/response_cents.rtf", ///
        append keep(1.lgbq_1#c.ends_tax_nom35_scale_cents) main(p) b(3) not ${stars} ///
        stats(N converge, fmt(0 0)) ///
        nomtitle ///
        nonum notes ///
        modelwidth(6) varwidth(20) nogaps onecell
    }
    // table 2 -- scaled x 100 (OLS for fsmoke test of difference)
    {
        esttab fvape_3l_id_ht_100 fsmoke_3l_id_ht_100 ///
        using "output/etax/figures/final/cents_x_100.rtf", ///
        replace keep(lc_1 lc_2) b(4) se(4) ${stars} ///
        mtitles("Frequent ENDS Use" "Frequent Cigarette Smoking") ///
        refcat(lc_1 "Heterosexual", nolabel) nonotes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(8) varwidth(20) nogaps onecell

        esttab fvape_3l_id_nh1_100 fsmoke_3l_id_nh1_100 ///
        using "output/etax/figures/final/cents_x_100.rtf", ///
        append keep(lc_1 lc_2) b(4) se(4) ${stars} ///
        nomtitle ///
        refcat(lc_1 "LGBQ", nolabel) nonum nonotes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(8) varwidth(20) nogaps onecell

        esttab fvape_3ldo_all fsmoke_3ld_all ///
        using "output/etax/figures/final/cents_x_100.rtf", ///
        append keep(1.lgbq_1#c.ends_tax_nom35_scale_cents 1.lgbq_1#c.cigarette_tax_scale_cents) ///
        main(p) b(3) not ${stars} ///
        stats(N converge, fmt(0 0)) ///
        nomtitle ///
        nonum notes ///
        modelwidth(8) varwidth(20) nogaps onecell
    }
    // table 3 (ols for fsmoke test of difference)
    if 0 {
        esttab fsmoke_3ld_all ///
        using "output/etax/figures/final/response_cents_3.rtf", ///
        replace keep(1.lgbq_1#c.ends_tax_nom35_scale_cents 1.lgbq_1#c.cigarette_tax_scale_cents) ///
        main(p) b(3) not ${stars} ///
        stats(N converge, fmt(0 0)) ///
        nomtitle ///
        nonum notes ///
        modelwidth(6) varwidth(20) nogaps onecell
    }
}

// triple DDD; same full interaction as main estimate, now present coefficients (must manually multiply LGBQ w/ ENDS tax)
if 1 { 
    eststo clear
    estimates clear

    use "data/final/master_set_2023", clear

    // v2
    cap drop endstax_x_lgbq 
    cap drop cigtax_x_lgbq
    cap drop mlsa_x_lgbq
    cap drop flavor_x_lgbq

    gen endstax_x_lgbq = ends_tax_nom35_scale * lgbq_1
    gen cigtax_x_lgbq  = cigarette_tax_scale  * lgbq_1
    gen mlsa_x_lgbq    = any_mlsa_vape        * lgbq_1
    gen flavor_x_lgbq  = flavor_ban           * lgbq_1

    // regs
    foreach subsample in !mi(lgbq_1) {
        // subsample-specific
        {
            if "`subsample'"=="!mi(lgbq_1)" local name_sample all
            if "`subsample'"=="lgbq_1==0"   local name_sample id_ht
            if "`subsample'"=="lgbq_1==1"   local name_sample id_nh1
        }
    foreach var of varlist fvape  /*vape dvape smoke*/ fsmoke /*dsmoke*/ {
        if "`var'"=="fvape"  local vars_lasso_sel ${vars_lasso_sel_`var'}
        if "`var'"=="fsmoke" local vars_lasso_sel ${vars_lasso_sel_`var'y1}
        // test of difference
        if "`subsample'"=="!mi(lgbq_1)" {
            // model 3
            // ends tax, cig tax, mlsa
            logit `var' ///
            lgbq_1##( ///
            i.t21 ${vars_essential_coef0} ///
            `vars_lasso_sel' ///
            c.tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester) ///
            c.ends_tax_nom35_scale c.endstax_x_lgbq ///
            c.cigarette_tax_scale c.cigtax_x_lgbq ///
            c.any_mlsa_vape c.mlsa_x_lgbq ///
            c.flavor_ban c.flavor_x_lgbq ///
            if `subsample' [pw=aweight], difficult ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `var'_3ldo_`name_sample': ///
            margins, dydx(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape ///
            endstax_x_lgbq cigtax_x_lgbq mlsa_x_lgbq) post
            estadd scalar converge = converge_pre

            if "`var'"=="fsmoke" { // OLS (kind of odd but keeping presentation consistent)
                // ends tax, cig tax, mlsa
                _eststo `var'_3ld_`name_sample': ///
                reghdfe `var' ///
                lgbq_1##( ///
                i.t21 ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control}) ///
                c.ends_tax_nom35_scale c.endstax_x_lgbq ///
                c.cigarette_tax_scale c.cigtax_x_lgbq ///
                c.any_mlsa_vape c.mlsa_x_lgbq ///
                c.flavor_ban c.flavor_x_lgbq ///
                if `subsample' [aw=aweight], ///
                vce(cluster fips) nosample ///
                absorb(fips year_true semester ///
                lgbq_1#fips lgbq_1#year_true lgbq_1#semester)

                // flavor ban
                _eststo `var'_3ld3l_`name_sample': ///
                reghdfe `var' ///
                lgbq_1##( ///
                i.t21 ${vars_essential_coef0} ///
                `vars_lasso_sel' ///
                c.tally_sexualorientation ///
                ${dem_control}) ///
                c.ends_tax_nom35_scale c.endstax_x_lgbq ///
                c.cigarette_tax_scale c.cigtax_x_lgbq ///
                c.any_mlsa_vape c.mlsa_x_lgbq ///
                c.flavor_ban c.flavor_x_lgbq ///
                if `subsample' & !inlist(fips,6,11,25,41) [aw=aweight], ///
                vce(cluster fips) nosample ///
                absorb(fips year_true semester ///
                lgbq_1#fips lgbq_1#year_true lgbq_1#semester)
            }
        }
    }
    }

    // table v1
    {
        esttab fvape_3ldo_all fsmoke_3ldo_all ///
        using "output/etax/figures/final/ddd_v1.rtf", ///
        replace keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape ///
        endstax_x_lgbq cigtax_x_lgbq mlsa_x_lgbq) ///
        cells(b(fmt(3) star)&se(par fmt(3))&p(par({ }) fmt(3)))  ///
        ${stars} ///
        mtitles("Frequent ENDS Use" "Frequent Cigarette Smoking")  ///
        notes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(8) varwidth(20) nogaps onecell
    }
    // table v2 (flavor ban)
    {
        estread _all using "log/estimates/other_pol_v20_ddd_y53st3l.sters"
        estread _all using "log/estimates/other_pol_v20_ddd_y13st3l.sters"

        esttab fvape_3ldo3l_ally53_st fsmoke_3ldo3l_ally13_st ///
        using "output/etax/figures/final/ddd_v2.rtf", ///
        replace keep(flavor_ban flavor_ban_x_lgbq) ///
        b(3) se(3) ///
        ${stars} ///
        mtitles("Frequent ENDS Use" "Frequent Cigarette Smoking") ///
        notes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(8) varwidth(20) nogaps onecell
    }
    // table v3 (fsmoke OLS)
    {
        esttab fsmoke_3ld_all ///
        using "output/etax/figures/final/ddd_v3.rtf", ///
        replace keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape ///
        endstax_x_lgbq cigtax_x_lgbq mlsa_x_lgbq) ///
        cells(b(fmt(3) star)&se(par fmt(3))&p(par({ }) fmt(3)))  ///
        ${stars} ///
        mtitles("Frequent Cigarette Smoking")  ///
        notes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab fsmoke_3ld3l_all ///
        using "output/etax/figures/final/ddd_v3.rtf", ///
        append keep(flavor_ban flavor_x_lgbq) ///
        cells(b(fmt(3) star)&se(par fmt(3))&p(par({ }) fmt(3)))  ///
        ${stars} ///
        mtitles("Frequent Cigarette Smoking")  ///
        notes ///
        stats(N converge, fmt(0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell
    }
}

// effect of 4 policies on probability of being either depressed, in-person bullying victim, or suicidal
if 1 {
    eststo clear
    estimates clear

    use "data/final/master_set_2023", clear

    // af4: physical bullying, sad, or suicide ideation
    cap drop aff_mh4
    gen      aff_mh4 = .
    replace  aff_mh4 = 1 if (bullied==1)|(sad==1)|(s_ideation==1)
    replace  aff_mh4 = 0 if (bullied==0)&(sad==0)&(s_ideation==0)

    // regs
    forval flavor = 0/1 {
        // flavor-specific
        {
            if `flavor'==0 {
                local vars_covars  ${vars_essential_coef1}
                local vars_margins ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape
                local sample_flavor 1

                local name_flavor
            }
            if `flavor'==1 {
                local vars_covars   c.ends_tax_nom35_scale c.any_mlsa_vape i.t21 c.cigarette_tax_scale c.flavor_ban
                local vars_margins  c.flavor_ban
                local sample_flavor "!inlist(fips,6,11,25,41)" // CA,DC,MA,OR

                local name_flavor `flavor'   
            }
        }
    foreach subsample in lgbq_1==0 lgbq_1==1 {
        // subsample-specific
        {
            if "`subsample'"=="!mi(lgbq_1)" local name_sample all
            if "`subsample'"=="lgbq_1==0"   local name_sample id_ht
            if "`subsample'"=="lgbq_1==1"   local name_sample id_nh1
        }
    foreach var of varlist aff_mh4 {

        summarize `var' ///
        if pre_etax_intro == 1 & !mi(pre_etax_intro) & `subsample' ///
        [aw=aweight], meanonly
        scalar pre_treat_mean = r(mean)

        // test of difference
        /*
        if "`subsample'"=="!mi(lgbq_1)" {
            // model 3
            _eststo `var'_3ldo_`name_sample': ///
            logit `var' ///
            lgbq_1##( ///
            ${vars_essential_coef1} ${vars_essential_coef0} ///
            ${vars_lasso_sel_`var'} ///
            c.tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester) ///
            if `subsample' & year != 2021 [pw=aweight], ///
            vce(cluster fips) iterate(15)

            estadd scalar converge = e(converged)
        }
        */

        // average marginal effect
        {
            // model 3: model 2 + LGBQ policy control
            logit `var' ///
            `vars_covars' ${vars_essential_coef0} ///
            ${vars_lasso_sel_`var'} ///
            tally_sexualorientation ///
            ${dem_control} ///
            i.fips i.year_true i.semester ///
            if `subsample' & inrange(year,2015,2023) & `sample_flavor' [pw=aweight], ///
            vce(cluster fips) iterate(15)

            scalar converge_pre = e(converged)

            _eststo `var'_3l`name_flavor'_`name_sample': ///
            margins, dydx(`vars_margins') post
            estadd scalar converge = converge_pre
            estadd scalar pre_treat_mean = pre_treat_mean
        }
    }
    }
    }

    // table 1
    {
        esttab aff_mh4_3l_id_ht ///
        using "output/etax/figures/inter/response_prob_mh_v1.rtf", ///
        replace keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) b(3) se(3) ${stars} ///
        mtitles("Sad, In-Person Bullied, or Suicidal") ///
        refcat(ends_tax_nom35_scale "Heterosexual", nolabel) nonotes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab aff_mh4_3l_id_nh1 ///
        using "output/etax/figures/inter/response_prob_mh_v1.rtf", ///
        append keep(ends_tax_nom35_scale cigarette_tax_scale any_mlsa_vape) b(3) se(3) ${stars} ///
        nomtitle ///
        refcat(ends_tax_nom35_scale "LGBQ", nolabel) nonum notes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell
    }
    // table 1.1: flavor ban
    {
        esttab aff_mh4_3l1_id_ht ///
        using "output/etax/figures/inter/response_prob_mh_v1_1.rtf", ///
        replace keep(flavor_ban) b(3) se(3) ${stars} ///
        mtitles("Sad, In-Person Bullied, or Suicidal") ///
        refcat(flavor_ban "Heterosexual", nolabel) nonotes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell

        esttab aff_mh4_3l1_id_nh1 ///
        using "output/etax/figures/inter/response_prob_mh_v1_1.rtf", ///
        append keep(flavor_ban) b(3) se(3) ${stars} ///
        nomtitle ///
        refcat(flavor_ban "LGBQ", nolabel) nonum notes ///
        stats(pre_treat_mean N converge, fmt(3 0 0)) ///
        modelwidth(6) varwidth(20) nogaps onecell
    }
}


// R1 response document additions
if 1 {
    eststo clear
    estimates clear
    set matsize 10000

    use "data/final/master_set_2023", clear

    global dem_control i.sex i.grade i.age i.race4

    // 2015-2019 regs
    {
        // regs
        foreach subsample in !mi(lgbq_1) lgbq_1==0 lgbq_1==1 {
            // subsample-specific
            {
                if "`subsample'"=="!mi(lgbq_1)" local name_sample all
                if "`subsample'"=="lgbq_1==0"   local name_sample id_ht
                if "`subsample'"=="lgbq_1==1"   local name_sample id_nh1
            }
        foreach var of varlist vape fvape dvape {
            // test of difference
            if "`subsample'"=="!mi(lgbq_1)" {
                // model 3
                _eststo `var'_3ldo_`name_sample': ///
                logit `var' ///
                lgbq_1##( ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${vars_lasso_sel_`var'} ///
                c.tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester) ///
                if `subsample' & inrange(year,2015,2019) [pw=aweight], ///
                vce(cluster fips) iterate(15)

                estadd scalar converge = e(converged)
            }

            // average marginal effect
            else {
                // model 3: model 2 + LGBQ policy control
                logit `var' ///
                ${vars_essential_coef1} ${vars_essential_coef0} ///
                ${vars_lasso_sel_`var'} ///
                tally_sexualorientation ///
                ${dem_control} ///
                i.fips i.year_true i.semester ///
                if `subsample' & inrange(year,2015,2019) [pw=aweight], ///
                vce(cluster fips) iterate(15)

                scalar converge_pre = e(converged)

                _eststo `var'_3l_`name_sample': ///
                margins, dydx(ends_tax_nom35_scale) post
                estadd scalar converge = converge_pre
            }
        }
        }

        // table
        {
            esttab vape_3l_id_ht fvape_3l_id_ht dvape_3l_id_ht ///
            using "output/etax/figures/inter/response_20152019.rtf", ///
            replace keep(ends_tax_nom35_scale) b(3) se(3) ${stars} ///
            mtitles("Current ENDS Use" "Frequent ENDS Use" "Everyday ENDS Use") ///
            refcat(ends_tax_nom35_scale "Heterosexual", nolabel) nonotes ///
            stats(N converge, fmt(0 0)) ///
            modelwidth(15) varwidth(20) nogaps onecell

            esttab vape_3l_id_nh1 fvape_3l_id_nh1 dvape_3l_id_nh1 ///
            using "output/etax/figures/inter/response_20152019.rtf", ///
            append keep(ends_tax_nom35_scale) b(3) se(3) ${stars} ///
            nomtitle ///
            refcat(ends_tax_nom35_scale "LGBQ", nolabel) nonum nonotes ///
            stats(N converge, fmt(0 0)) ///
            modelwidth(15) varwidth(20) nogaps onecell

            esttab vape_3ldo_all fvape_3ldo_all dvape_3ldo_all ///
            using "output/etax/figures/inter/response_20152019.rtf", ///
            append keep(1.lgbq_1#c.ends_tax_nom35_scale) main(p) b(3) not ${stars} ///
            stats(N converge, fmt(0 0)) ///
            nomtitle ///
            nonum notes ///
            modelwidth(15) varwidth(20) nogaps onecell
        }
    }

    // triple DDD 
    {
        // without fully interacting RH-side controls with LGBQ status
        {
            cap drop endstax_x_lgbq 
            gen endstax_x_lgbq = ends_tax_nom35_scale * lgbq_1

            // regs
            foreach subsample in !mi(lgbq_1) {
                // subsample-specific
                {
                    if "`subsample'"=="!mi(lgbq_1)" local name_sample all
                    if "`subsample'"=="lgbq_1==0"   local name_sample id_ht
                    if "`subsample'"=="lgbq_1==1"   local name_sample id_nh1
                }
            foreach var of varlist vape fvape dvape {
                // test of difference
                if "`subsample'"=="!mi(lgbq_1)" {
                    // model 3
                    logit `var' ///
                    i.lgbq_1 ///
                    c.ends_tax_nom35_scale c.endstax_x_lgbq ///
                    c.flavor_ban c.any_mlsa_vape i.t21 c.cigarette_tax_scale ${vars_essential_coef0} ///
                    ${vars_lasso_sel_`var'} ///
                    c.tally_sexualorientation ///
                    ${dem_control} ///
                    i.fips i.year_true i.semester ///
                    if `subsample' [pw=aweight], ///
                    vce(cluster fips) iterate(15)

                    scalar converge_pre = e(converged)

                    _eststo `var'_3ldo_`name_sample': ///
                    margins, dydx(ends_tax_nom35_scale endstax_x_lgbq) post
                    estadd scalar converge = converge_pre 
                }
            }
            }

            // table
            {
                esttab vape_3ldo_all fvape_3ldo_all dvape_3ldo_all ///
                using "output/etax/figures/inter/response_ddd.rtf", ///
                replace keep(ends_tax_nom35_scale endstax_x_lgbq) ///
                cells(b(fmt(3) star)&se(par fmt(3))&p(par fmt(3)))  ///
                ${stars} ///
                mtitles("Current ENDS Use" "Frequent ENDS Use" "Everyday ENDS Use")  ///
                notes ///
                stats(N converge, fmt(0 0)) ///
                modelwidth(15) varwidth(20) nogaps onecell
            }
        }
    }

    // states without sexual orientation information
    {
        preserve

        gcollapse lgbq_1 [aw=aweight] ///
        if !national & inrange(year,2015,2023), by(state)

        tab state if mi(lgbq_1)
        // Alaska, Georgia, Idaho, Louisiana, Montana, South Dakota, Tennessee

        restore
    }
}

// manuscript calculations
if 1 {
    // introduction
    {
        use "data/final/master_set_2023", clear
        // National YRBS summary stats of ENDS/tobacco use:
        {
            // LGBQ, 2023
            summ vape smoke if (inrange(year,2023,2023) & national & (lgbq_1 == 1)) [aw=bweight]

            // Heterosexual, 2023
            summ vape smoke if (inrange(year,2023,2023) & national & (lgbq_1 == 0)) [aw=bweight]

            // vape: lgbq / het
            di 0.2299 / 0.1476
            // 1.558, 56 percent higher among lgbq

            // smoke: lgbq / het 
            di 0.0541 / 0.0259
            // 2.089, 109 percent higher among lgbq
        }

        // state YRBS
        {
            // LGBQ, 2023
            summ vape fvape smoke if (inrange(year,2023,2023) & !national & (lgbq_1 == 1)) [aw=aweight]

            // Heterosexual, 2023
            summ vape fvape smoke if (inrange(year,2023,2023) & !national & (lgbq_1 == 0)) [aw=aweight]

            // vape: lgbq / het
            di 0.2061 / 0.1415
            // 1.4565, 46 percent higher among lgbq

            // fvape: lgbq / het
            di 0.0787 / 0.0548
            // 1.4631, 46 percent higher among lgbq

            // smoke: lgbq / het 
            di 0.0474 / 0.0262
            // 1.8092, 81 percent higher among lgbq


            // LGBQ, 2015-2023
            summ vape smoke if (inrange(year,2015,2023) & !national & (lgbq_1 == 1)) [aw=aweight]

            // Heterosexual, 2015-2023
            summ vape smoke if (inrange(year,2015,2023) & !national & (lgbq_1 == 0)) [aw=aweight]

            // vape:
            di 0.2255 / 0.1786
            // 1.2626, 26 percent higher among lgbq

            // smoke:
            di 0.0860 / 0.0508
            // 1.6929, 69 percent higher among lgbq
        }

    }

    // background
    {
        // adult ENDS prevalence
        {
            preserve
            use "data/final/brfss_master_set_2023", clear

            gcollapse vape dvape [aw=sample_weight1], by(year_survey)
            restore
            // 2022: vape: 0.0754, dvape: 0.0348; 2023: vape: 0.0744, dvape: 0.0371
        }

        // middle/highschool ENDS prevalence
        {
            summ vape if year==2023 & national==1 [aw=bweight]
            // 16.75 percent
        }
    }

    // data
    {
        // percent of sample with sex-id information
        {
            // 2015-2023, state YRBS
            preserve

            keep if !national 
            keep if inrange(year,2015,2023)

            tab sex_orientation,mi gen(sex_orientation_)

            count if sex_orientation_7 // sex_orientation missing

            // (full sample - sample missing sex id) / full sample
            di (_N - r(N)) / _N 
            // ()
            
            // 85.74% of sample reports sexual id info
            di 100 - 85.74
            // 14.26 percent


            // how many of these due to states not including the question in survey (exclude non-responses)
            
            // state-years w/o lgbq question has sum==0
            bys fips year: egen lgbq_sum = sum(lgbq_1)

            count if lgbq_1 == . & lgbq_sum != 0
            // N = 19,057. These are non-response missings

            keep if lgbq_sum==0
            // N = 96,873. These are missings due to states not asking question

            di 96873 + 19057 // = 115930

            di _N / 115930
            // 83.56 percent 
            // 84 percent of missing observations are from states which do not ask the LGBQ question

            restore
        }

        // median LGBQ observations in each state in national/state YRBS
        {
            use "data/final/master_set_2023",clear

            // only treatment states then all states
            forval j = 1/2 {

                // National YRBS
                preserve
                keep if national

                if `j' == 1 keep if etax_intro != .

                gcollapse (rawsum) lgbq_1, by(fips year)

                //rename age lgbq_count

                egen median_state = median(lgbq_1)
                summ median_state
                // 39.5 is median lgbq-identifying observations per state-year in the national yrbs, among treatment states
                // 34   is median lgbq-identifying observations per state-year in the national yrbs

                egen mean_state = mean(lgbq_1)
                summ mean_state
                // 88.81 is mean lgbq observations per state-year in national yrbs, among treatment states
                // 72.54 is mean lgbq observations per state-year in national yrbs
                
                restore

                // State YRBS
                preserve
                keep if !national
                
                if `j' == 1 keep if etax_intro != .

                gcollapse (rawsum) lgbq_1, by(fips year)

                egen median_state = median(lgbq_1)
                summ median_state
                // 266   is median lgbq-identifying observations per state-year in the state yrbs, among treatment states
                // 217.5 is median lgbq-identifying observations per state-year in the state yrbs
                

                egen mean_state = mean(lgbq_1)
                summ mean_state
                // 855.15 is mean lgbq observations per state-year in state yrbs, among treatment states
                // 551.74 is mean lgbq observations per state-year in state yrbs
                
                restore
            }
        }      

        // percent of sample LGBQ, within LGBQ groups
        {
            preserve
            gcollapse lgbq_1 id_bisexual id_gay_lesbian id_questioning if !national & inrange(year,2015,2023) & !mi(lgbq_1) [aw=aweight]
            // 18.7% LGBQ, 9.1% bisexual, 6.6% questioning, 3.0% gay or lesbian
            restore
        }  

        // highest/smallest tax in 2023
        {
            preserve
            use "data/inter/master_control2023_semester.dta",clear
            gcollapse ends_tax_nom35_scale, by(fips year_true)
            statastates, fips(fips) nogen

            bys year_true: egen max_tax_year = max(ends_tax_nom35_scale)
            bys year_true: egen min_tax_year = min(ends_tax_nom35_scale) if ends_tax_nom35_scale>0 

            sort fips year_true

            br if ///
            (max_tax_year==ends_tax_nom35_scale | min_tax_year==ends_tax_nom35_scale) ///
            & year_true==2023
            // 
            restore
            // highest: Minnesota = $2.89 (2023$)
            // lowest: Delaware, Georgia, Kansas, North Carolina, Wisconsin = $0.05 (2023$)
        }        

        // cigarette tax stats
        {
            preserve
            use "data/inter/master_control2023_semester", clear

            gcollapse cigarette_tax_scale, by(fips year_true)

            summ cigarette_tax_scale

            // min: $0.14 (fips 29 in 2023)

            // max: $5.89 (fips 36 in 2011)

            // mean: $2.04

            restore
        }

        // flavor ban stats
        {
            preserve
            use "data/inter/master_control2023_semester", clear

            gcollapse flavor_ban, by(fips year_true)
            statastates, fips(fips) nogen
            drop state_name
            order state_abbrev, after(fips)

            count if flavor_ban>0 & year_true==2023

            restore
        }
    }

    // empirical strategy
    {
        // # non inflation driven tax changes
        {
            preserve
            use "${path_cheps_google}/datasets/cheps_controls/data/final/cheps_master_controls_2000to2023_11-11-24", clear
            drop if year==2024

            keep state_fips state_name year quarter quarterly_date ends_tax_nom35_closed

            xtset state_fips quarterly_date

            bys state_fips: gen tax_diff = d.ends_tax_nom35_closed
            replace tax_diff = 0 if tax_diff == .

            keep if inrange(year,2015,2023)
            count if tax_diff!=0
            // 76 changes
            restore
        }
    }
}

// space for VSCode