// use "C:\Users\khanalsa.GRIN\OneDrive - Grinnell College\Econ History research data\Data_v3_2.dta" 
use "C:\Users\khanalsa\OneDrive - Grinnell College\Econ History research data\Data_v3_2.dta"

/**
										DESCRIPTIVE STATS AND TABLES
*/

// Figure 2
graph bar (mean) deaths_per_pop, over(level_of_plantation, relabel(1 "0: Plantation economy of no importance" 2 "1: Plantation Economy of some importance" 3 "2: Plantation Economy of significant importance")) ytitle("Mean Combat Deaths per Population")

/*
                                         MAIN MODEL
*/

/*
FIRST STAGES
-- I use asdoc command to neatly output tables in stata. They donot show the first stage regressions in the output, so I run them seperately so that I can include firststage regressions in the table.
-- if !missing(deaths_per_pop) is used since my entire dataset contains many countries (non-African and Asian countries), of which only 70 I use. ALl of the countries included in the analysis have deaths_per_pop variable, hence I check if theyre missing. If they are missing, those countries are one of the few ones from Asia and Africa not under consideration, or not in either continent at all.  
*/
// COLUMN 1: Main Model
asdoc regress plantation_dummy rainfall political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam !="IRQ" & !missing(deaths_per_pop)),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded) replace

// COLUMN 2: W/O % Catholic
asdoc regress plantation_dummy rainfall political_violence asia years_of_colonization euro1900 i.colonyof_encoded if (shortnam !="IRQ" & !missing(deaths_per_pop)),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded)

// COLUMN 3:  LPM
asdoc regress plantation_dummy rainfall political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam !="IRQ" & !missing(deaths_per_pop)),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded) 

//Column 4
asdoc regress deaths_per_pop plantation_dummy political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if shortnam !="IRQ",first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded)

// COLUMN 5: No Fixed Effects
asdoc regress plantation_dummy rainfall  political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam !="IRQ" & !missing(deaths_per_pop)),first r nest cnames(CR) drop(i.colonyof_encoded)


/*
2SLS MODELS
*/
// COLUMN 1: Main Model
asdoc ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =rainfall) if shortnam !="IRQ",first replace vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded)
estat firststage

// COLUMN 2: W/O % Catholic
asdoc ivregress 2sls deaths_per_pop political_violence asia years_of_colonization euro1900 i.colonyof_encoded  (plantation_dummy =rainfall) if shortnam !="IRQ",first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded)
estat firststage

// COLUMN 3:  LPM
asdoc ivregress 2sls independence_wars  political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =rainfall) if (!missing(deaths_per_pop) & shortnam!="IRQ"),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded)
estat firststage

// COLUMN 4: Without IV
asdoc regress deaths_per_pop plantation_dummy political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if shortnam !="IRQ",first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded)

// COLUMN 5: No Fixed effects
asdoc ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 (plantation_dummy =rainfall) if shortnam !="IRQ",first r nest cnames(CR) drop(i.colonyof_encoded)
estat firststage




//------------------------------------------------------------------------------
/*
									    ROBUSTNESS CHECKS
*/

/*
FIRST STAGES
-- I use asdoc command to neatly output tables in stata. They donot show the first stage regressions in the output, so I run them seperately so that I can include firststage regressions in the table.
-- if !missing(deaths_per_pop) is used since my entire dataset contains many countries (non-African and Asian countries), of which only 70 I use. ALl of the countries included in the analysis have deaths_per_pop variable, hence I check if theyre missing. If they are missing, those countries are one of the few ones from Asia and Africa not under consideration, or not in either continent at all.  
*/



//COLUMN 1:  Remove observations with Census Discrepancies
asdoc regress plantation_dummy rainfall political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam !="IRQ" & !missing(deaths_per_pop) & census_discrepancy<10),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded) replace

//COLUMN 2: Alternative Instrument --Tempreture
asdoc regress plantation_dummy temp1 temp2 temp3 temp4 temp5 independence_wars political_violence asia percent_catholic euro1900 i.colonyof_encoded if (shortnam!="IRQ" & !missing(deaths_per_pop)), nest cnames(CR) drop(i.colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded) 

// COLUMN 4: Using actual encoded variable, isntead of the dummy we created out of it
asdoc regress level_of_plantation rainfall political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam!="IRQ" & !missing(deaths_per_pop)),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded) 

// COLUMN 4: Dep var is total violence
asdoc regress plantation_dummy rainfall political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam!="IRQ" & !missing(deaths_per_pop)),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded)


/*
2SLS Models
*/
//------------------------------------------------------------------------------
// COLUMN 1: Remove observations with Census Discrepancies
asdoc ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =rainfall) if (shortnam!="IRQ" & !missing(deaths_per_pop) & census_discrepancy<10),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded) replace
estat firststage

// COLUMN 2: Alternative Instrument -- Tempreture
asdoc ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =temp1 temp2 temp3 temp4 temp5) if (shortnam!="IRQ" & !missing(deaths_per_pop)),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded)
estat firststage

//------------------------------------------------------------------------------
// COLUMN 3: Using actual encoded variable, isntead of the dummy we created out of it
asdoc ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (level_of_plantation=rainfall) if (shortnam!="IRQ" & !missing(deaths_per_pop)),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded) 
estat firststage

//------------------------------------------------------------------------------
// COLUMN 4: Dep var is total violence
asdoc ivregress 2sls total_colonial_violence independence_wars political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =rainfall) if (shortnam!="IRQ" & !missing(deaths_per_pop)),first vce(cluster colonyof_encoded) nest cnames(CR) drop(i.colonyof_encoded)
estat firststage