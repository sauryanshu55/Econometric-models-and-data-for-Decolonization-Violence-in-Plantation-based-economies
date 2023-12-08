/*
DECOLONIZATION VIOLENCE IN PLANTATION-BASED COLONIAL ECONOMIES IN ASIA AND AFRICA
A: Sauryanshu Khanal
D: December 7th, 2023
ECN-395: Seminar in Economic History

----------Econometric Models, Data And Descriptive Statistics------------------- 
*/

//------------------------------------------------------------------------------
/*
									MERGING AND CLEANING DATASETS
*/
global data_dir "C:\Users\khanalsa.GRIN\OneDrive - Grinnell College\Econ History research data\Data"
// Replace with your data directory here

// Use Acemoglu,Johnson,Robinson(2001) as the starting data file, and keep on adding to it
use "$data_dir\AJR.dta" 

// Add Decolonization deaths and Population data
// Sources for Decolonization deaths: Correlates of War(2017)
// Sources for population data: Variety of sources, including National censuses, UN, Worldbank, CIA world Factbook.
// Note: 1) Decolonization detahs per population= Decolonization deaths/population. This equals 0 for countries where decolonization deaths is 0. 
// 		Hence, population is 0 for those countries since population is not needed at all
//       2) This data already contains deaths per population variable included (calcualted earlier during data construction) 
merge 1:1 shortnam using "$data_dir\Deaths & Pop.dta"
drop _merge //drop merge info

// Add Rainfall data (Worldbank,2020)
// The worldbank data already has been averaged for each year for each country since records begin for that country. Hence, we donot need to average it ourselves
merge 1:1 shortnam using "$data_dir\Rainfall.dta"
drop _merge

// Add data from Ziltener, Kunzler, Andre (2017)
merge 1:1 shortnam using "$data_dir\ZKA.dta"
drop _merge

// Generate plantation dummy variable as has been described in the paper
generate plantation_dummy=0
replace plantation_dummy=1 if (level_of_plantation==1 | level_of_plantation==2)


// Generate independence wars dummy, as has been described in the paper
generate independence_wars=0
replace independence_wars=1 if decol_deaths>0

// Drop unused/extraneous variables that arent needed, and that came with merging datasets
drop f_french CountryName Maincolonialmotherlandsour onsetofcolonialismsourceZi endofcolonialismsourceZilt COLYEARS ViolentColonizationWarsofDe ViolentResistenceRevoltsetc ViolentIndependenceSourceow colonialviolencetotalSource FormofColonialDomination0 Colonialadministrationhistoric ethnicfunctiongroupsusedbyc powertransferduringdecoloniza colonialforeigntradepolicy0 colonialtradeconcentrationso colonialinvestmentconcentratio colonialinvestmentininfrastru plantationsduringcolonialperi goldsilverminingduringcoloni miningduringcolonialperiod0 foreignpresencecolonialcount immigrationofforeignworkersd missionaryactivitiesduringcol colonialborderssplitethnicgr levelofpoliticaltransformatio levelofeconomictransformation levelofsocialtransformation levelofcolonialtransformation tempmean

// At this point, we have 272 countries/territories from all over the world. We have only added relevant variables for a country which we are looking at. That includes decolonization deaths. We remove extraneous observations of countries outside of Africa and Asia that we have no use for, to clean up the dataset
drop if missing(decol_deaths)


//------------------------------------------------------------------------------
/*
									DESCRIPTIVE STATISTICS
*/

// Figure 2
graph bar (mean) deaths_per_pop, over(level_of_plantation, relabel(1 "0: Plantation economy of no importance" 2 "1: Plantation Economy of some importance" 3 "2: Plantation Economy of significant importance")) ytitle("Mean Combat Deaths per Population")

//Figure 3
twoway (scatter rainfall plantation_dummy, xlabel(0 "No importance" 1 "Some/significant imp") mlabel(shortnam)) (lfit rainfall plantation_dummy)

//Table 2
summarize decol_deaths euro1900 rainfall years_of_colonization percent_catholic census_discrepancy

//------------------------------------------------------------------------------
/*
                                         MAIN MODELS
*/

/*
	FIRST STAGES-----
-- I used asdoc command to neatly output tables in stata. They donot show the first stage regressions in the output, so I run them seperately so that I can include firststage regressions in the table.
*/
// COLUMN 1: Main Model
regress plantation_dummy rainfall political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam !="IRQ"), vce(cluster colonyof_encoded)

// COLUMN 2: W/O % Catholic
regress plantation_dummy rainfall political_violence asia years_of_colonization euro1900 i.colonyof_encoded if (shortnam !="IRQ"), vce(cluster colonyof_encoded)

//Column 4
regress deaths_per_pop plantation_dummy political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if shortnam !="IRQ", vce(cluster colonyof_encoded) 

// COLUMN 5: No Fixed Effects
regress plantation_dummy rainfall  political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam !="IRQ")


/*
	2SLS MODELS-----
*/
// COLUMN 1: Main Model
ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =rainfall) if shortnam !="IRQ",first vce(cluster colonyof_encoded)
estat firststage

// COLUMN 2: W/O % Catholic
ivregress 2sls deaths_per_pop political_violence asia years_of_colonization euro1900 i.colonyof_encoded  (plantation_dummy =rainfall) if shortnam !="IRQ",first vce(cluster colonyof_encoded) 
estat firststage

// COLUMN 3:  LPM
ivregress 2sls independence_wars  political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =rainfall) if (!missing(deaths_per_pop) & shortnam!="IRQ"),first vce(cluster colonyof_encoded)
estat firststage

// COLUMN 4: Without IV
regress deaths_per_pop plantation_dummy political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if shortnam !="IRQ",first vce(cluster colonyof_encoded)

// COLUMN 5: No Fixed effects
ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 (plantation_dummy =rainfall) if shortnam !="IRQ",first r 
estat firststage


//------------------------------------------------------------------------------
/*
									    ROBUSTNESS CHECK MODELS
*/

/*
	FIRST STAGES-----
-- I used asdoc command to neatly output tables in stata. They donot show the first stage regressions in the output, so I run them seperately so that I can include firststage regressions in the table.  
*/

//COLUMN 1:  Remove observations with Census Discrepancies
regress plantation_dummy rainfall political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam !="IRQ" & census_discrepancy<10),vce(cluster colonyof_encoded)

//COLUMN 2: Alternative Instrument --Tempreture
regress plantation_dummy temp1 temp2 temp3 temp4 temp5 independence_wars political_violence asia percent_catholic euro1900 i.colonyof_encoded if (shortnam!="IRQ"), vce(cluster colonyof_encoded)

// COLUMN 4: Using actual encoded variable, isntead of the dummy we created out of it
regress level_of_plantation rainfall political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam!="IRQ"),vce(cluster colonyof_encoded) 

// COLUMN 4: Dep var is total violence
regress plantation_dummy rainfall political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded if (shortnam!="IRQ"),vce(cluster colonyof_encoded)


/*
	2SLS MODELS-----
*/
//------------------------------------------------------------------------------
// COLUMN 1: Remove observations with Census Discrepancies
ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =rainfall) if (shortnam!="IRQ" & census_discrepancy<10),first vce(cluster colonyof_encoded) 
estat firststage

// COLUMN 2: Alternative Instrument -- Tempreture
ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =temp1 temp2 temp3 temp4 temp5) if (shortnam!="IRQ" & !missing(deaths_per_pop)),first vce(cluster colonyof_encoded)
estat firststage

//------------------------------------------------------------------------------
// COLUMN 3: Using actual encoded variable, isntead of the dummy we created out of it
ivregress 2sls deaths_per_pop political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (level_of_plantation=rainfall) if (shortnam!="IRQ"),first vce(cluster colonyof_encoded)
estat firststage

//------------------------------------------------------------------------------
// COLUMN 4: Dep var is total violence
ivregress 2sls total_colonial_violence independence_wars political_violence asia years_of_colonization percent_catholic euro1900 i.colonyof_encoded (plantation_dummy =rainfall) if (shortnam!="IRQ"),first vce(cluster colonyof_encoded) 
estat firststage


