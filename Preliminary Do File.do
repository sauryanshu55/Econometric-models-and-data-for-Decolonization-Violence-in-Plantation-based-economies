// use "C:\Users\khanalsa.GRIN\OneDrive - Grinnell College\Econ History research data\Data_v1.dta" 
use "C:\Users\Sauryanshu Khanal\OneDrive - Grinnell College\Econ History research data\Data_v1.dta"

/**
										DESCRIPTIVE 
*/
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
asdoc regress plantation_dummy rainfall independence_wars political_violence asia percent_catholic euro1900 i.colonyof_encoded if !missing(deaths_per_pop), nest cnames(CR) drop(i.colonyof_encoded) replace

// COLUMN 2: W/O Fixed Effects
asdoc regress plantation_dummy rainfall independence_wars political_violence asia percent_catholic euro1900 if !missing(deaths_per_pop), nest cnames(CR) drop(i.colonyof_encoded)

// COLUMN 3: W/O Percent_catholic
asdoc regress plantation_dummy rainfall independence_wars political_violence asia euro1900 i.colonyof_encoded if !missing(deaths_per_pop), nest cnames(CR) drop(i.colonyof_encoded)


/*
2SLS MODELS
*/

// COLUMN 1: Main Model 
asdoc ivregress 2sls deaths_per_pop independence_wars political_violence asia percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =rainfall ), first nest cnames(CR) drop(i.colonyof_encoded) replace
estat firststage

//------------------------------------------------------------------------------

// COLUMN 2: W/O Fixed Effects
asdoc ivregress 2sls deaths_per_pop independence_wars political_violence asia percent_catholic euro1900 (plantation_dummy =rainfall ), first nest cnames(CR) drop(i.colonyof_encoded)
estat firststage

//------------------------------------------------------------------------------
// COLUMN 3 - W/O Percent_catholic
asdoc ivregress 2sls deaths_per_pop independence_wars political_violence asia euro1900 i.colonyof_encoded (plantation_dummy =rainfall ), first nest cnames(CR) drop(i.colonyof_encoded)
estat firststage

// COLUMN 4 - W/O instrument &  With Fixed effects
asdoc reg deaths_per_pop plantation_dummy independence_wars political_violence asia percent_catholic euro1900 i.colonyof_encoded, nest cnames(CR) drop(i.colonyof_encoded)


//------------------------------------------------------------------------------
/*
									    ROBUSTNESS CHECKS
*/

/*
First Stage
*/
asdoc regress plantation_dummy temp1 temp2 temp3 temp4 temp5 independence_wars political_violence asia percent_catholic euro1900 i.colonyof_encoded, nest cnames(CR) drop(i.colonyof_encoded) replace
asdoc regress plantation_dummy rainfall independence_wars political_violence asia percent_catholic euro1900 i.colonyof_encoded if census_discrepancy<10, nest cnames(CR) drop(i.colonyof_encoded)
asdoc regress plantation rainfall independence_wars political_violence asia percent_catholic euro1900 i.colonyof_encoded, nest cnames(CR) drop(i.colonyof_encoded) 
asdoc regress total_colonial_violence rainfall independence_wars political_violence asia percent_catholic euro1900 i.colonyof_encoded, nest cnames(CR) drop(i.colonyof_encoded) 

// Alternative Instrument -- Tempreture
asdoc ivregress 2sls deaths_per_pop independence_wars political_violence asia percent_catholic  euro1900 i.colonyof_encoded (plantation_dummy=temp1 temp2 temp3 temp4 temp5) if census_discrepancy <10 , first nest cnames(CR) drop(i.colonyof_encoded) replace 
estat firststage

//------------------------------------------------------------------------------
// Remove observations with Census Discrepancies
asdoc ivregress 2sls deaths_per_pop independence_wars political_violence asia percent_catholic  euro1900 i.colonyof_encoded (plantation_dummy=rainfall) if census_discrepancy <10 , first nest cnames(CR) drop(i.colonyof_encoded) 
estat firststage

//------------------------------------------------------------------------------
// Using actual encoded variable
asdoc ivregress 2sls deaths_per_pop independence_wars political_violence asia percent_catholic  euro1900 i.colonyof_encoded (plantation=rainfall) if census_discrepancy <10 , first nest cnames(CR) drop(i.colonyof_encoded) 
estat firststage

//------------------------------------------------------------------------------
// Dep var is total violence
// Motivation: we could have confounded col violence with decol violence. Using 
//col violence absorbs that effect
asdoc ivregress 2sls total_colonial_violence independence_wars asia percent_catholic euro1900 i.colonyof_encoded (plantation_dummy=rainfall ), first nest cnames(CR) drop(i.colonyof_encoded) 
estat firststage

