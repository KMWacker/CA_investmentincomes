
*****************************
***** I. QUARTERLY DATA *****
*****************************

**************************************************
* 1. Insheet current account data (Eurostat) *****
**************************************************

insheet using $path\Eurostat_bop_c6_q_1_Data.csv, names
drop sect*

gen qdate = quarterly(time, "YQ")
format qdate %tq
drop time
rename qdate time

tab geo if flagandfoot=="c" & partner=="Rest of the world"
tab geo if flagandfoot=="c" & partner=="Rest of the world" & bop_item=="Primary income: Investment income" 
tab geo if flagandfoot=="c" & partner=="Rest of the world" & bop_item=="Primary income: Investment income" & stk_flow=="Balance"

/* Dutch CA has outlier around 2015! */

encode bop_item, gen(bop_category)
drop flagandfoot bop_item

reshape wide value, i(time geo stk_flow partner) j(bop_category)
rename value1 ca
rename value2 inv_inc
rename value3 fdi_inc
label variable ca "current account, mio Euro"
label variable inv_inc "Primary income: Investment income, mio Euro"
label variable fdi_inc "Primary income: Investment income; Direct investment, mio Euro"

/* limit sample */
*preserve
keep if partner=="Rest of the world" & stk_flow=="Balance"
drop partner stk_flow 

save "$path\ca_invinc.dta", replace
clear

************************************
* 2. Merge GDP data (Eurostat) *****
************************************

insheet using $path\Eurostat_naidq_10_gdp_1_Data.csv, names

keep if na_item == "Gross domestic product at market prices" & s_adj=="Seasonally and calendar adjusted data"

gen qdate = quarterly(time, "YQ")
format qdate %tq
drop time unit 
rename qdate time

tab flag
* note BREAKS IN SERIES for Bulgaria and Greece (flag "b")

drop s_adj na_item
rename value gdp
label variable gdp "GDP at mkt prices, mio Euro, seasonally and calendar adj"

merge m:m geo time using $path\ca_invinc.dta

drop if geo=="Albania" | geo=="Argentina" | geo=="Armenia" | geo=="Azerbaijan" | geo=="Bahrain" | geo=="Belarus" ///
 | geo=="Bolivia" | geo=="Botswana" | geo=="Brunei Darussalam" | geo=="Cabo Verde" | geo=="Cambodia" ///
 | geo=="Colombia" | geo=="Costa Rica" | geo=="Dominican Republic" | geo=="Ecuador" | geo=="Egypt" ///
 | geo=="El Salvador" | geo=="Georgia" | geo=="Guatemala" | geo=="Honduras" | geo=="Indonesia" | geo=="Iran" ///
 | geo=="Iraq" | geo=="Israel" | geo=="Jamaica" | geo=="Kazakhstan" | geo=="Kyrgyzstan" | geo=="Macao" ///
 | geo=="Malaysia" | geo=="Mauritius" | geo=="Moldova" | geo=="Mongolia" | geo=="Morocco" | geo=="Namibia" ///
 | geo=="Nicaragua" | geo=="Nigeria" | geo=="Palestine" | geo=="Paraguay" | geo=="Peru" | geo=="Philippines" ///
 | geo=="Qatar" | geo=="Rwanda" | geo=="Samoa" | geo=="Seychelles" | geo=="Sri Lanka" | geo=="Thailand" ///
 | geo=="Ukraine" | geo=="Uruguay"
 
*no GDP data: BiH, Chile, China incl. HK, Iceland, Montenegro, North Macedonia, Saudi Arabia, Singapore, 
tab geo if _merge==1
drop if _merge==1
drop _merge


gen ca_gdp = ca/gdp
gen invinc_gdp = inv_inc/gdp
gen invinc_ca = inv_inc/ca
gen fdiinc_invinc = fdi_inc/inv_inc
gen fdiinc_gdp = fdi_inc/gdp

save "$path\ca_invinc.dta", replace

************************************
* 3. Add US data *****
************************************

insheet using $path\FRED_datacollection.csv, names clear
gen qdate = quarterly(time, "YQ")
format qdate %tq
drop time 
rename qdate time

gen ca_gdp = ieabcn/((gdp/4)*1000)
gen invinc_gdp = (ieaxiin-ieamiin)/((gdp/4)*1000)
gen invinc_ca = (ieaxiin-ieamiin)/ieabcn
gen fdiinc_invinc = (ieaxidn-ieamidn)/(ieaxiin-ieamiin)
gen fdiinc_gdp = (ieaxidn-ieamidn)/((gdp/4)*1000)
drop ieamin ieamidn ieaxidn ieaxin ieaxiin ieamiin ieabcn gdp 

append using "$path\ca_invinc.dta"
save "$path\ca_invinc.dta", replace

*************************
* 4. Add Japan data *****
*************************

insheet using $path\Japan_datacollection.csv, names clear
gen qdate = quarterly(time, "YQ")
format qdate %tq
drop time 
rename qdate time

gen ca_gdp = currentaccountabc/gdpexpenditureapproach
gen invinc_gdp = investmentincome/gdpexpenditureapproach
gen invinc_ca = investmentincome/currentaccountabc
gen fdiinc_invinc = directinvestmentincome/investmentincome
gen fdiinc_gdp = directinvestmentincome/gdpexpenditureapproach
drop primaryincome investmentincome directinvestmentincome currentaccountabc gdpexpenditureapproach

append using "$path\ca_invinc.dta"

************************************
* xx. Final data prep *****
************************************

replace geo = "Germany" if geo=="Germany (until 1990 former territory of the FRG)"
replace geo = "Kosovo" if geo=="Kosovo (under United Nations Security Council Resolution 1244/99)"
replace geo = "Czech Republic" if geo=="Czechia"
replace geo = "Slovak Republic" if geo=="Slovakia"

encode geo, gen(country)
tsset country time
generate quarter=quarter(dofq(time))
order time quarter country

gen dum_euro = 0
replace dum_euro = 1 if time>=tq(1999q1) & (geo=="Austria" | geo=="Belgium" | geo=="Finland" | geo=="France"| geo=="Germany" ///
| geo=="Ireland" | geo=="Italy" | geo=="Luxembourg" | geo=="Netherlands" | geo=="Portugal" | geo=="Spain")
replace dum_euro = 1 if time>=tq(2001q1) & geo=="Greece"
replace dum_euro = 1 if time>=tq(2007q1) & geo=="Slovenia"
replace dum_euro = 1 if time>=tq(2008q1) & (geo=="Cyprus" | geo=="Malta")
replace dum_euro = 1 if time>=tq(2009q1) & geo=="Slovak Republic"
replace dum_euro = 1 if time>=tq(2011q1) & geo=="Estonia"
replace dum_euro = 1 if time>=tq(2014q1) & geo=="Latvia"
replace dum_euro = 1 if time>=tq(2015q1) & geo=="Lithuania"

gen dum_invinc_deficit = 0
replace dum_invinc_deficit = 1 if invinc_gdp<0 & invinc_gdp!=.
gen dum_ca_deficit = 0
replace dum_ca_deficit = 1 if ca_gdp<0 & invinc_gdp!=.

bys country: egen dum_ever_euro = max(dum_euro)
bys country: egen mn_invinc_gdp = mean(invinc_gdp) if time>=tq(2012q1)
bys country: egen mn_ca_gdp = mean(ca_gdp) if time>=tq(2012q1)
bys country: egen mn_fdiinc_invinc = mean(fdiinc_invinc) if time>=tq(2012q1)
bys country: egen mn_fdiinc_gdp = mean(fdiinc_gdp) if time>=tq(2012q1)
bys country: egen avg2011_invinc_gdp = mean(invinc_gdp) if time>=tq(2011q1) & time<=tq(2011q4)
	
compress
save "$path\ca_invinc.dta", replace

***************************
***** II. ANNUAL DATA *****
***************************

snapshot erase _all
snapshot save, label("quarterly")

generate year=year(dofq(time))
collapse (mean) ca_gdp invinc_gdp invinc_ca fdiinc_invinc fdiinc_gdp dum_euro inv_inc ca, by(year geo)
rename geo country
rename year time

drop invinc_ca
gen invinc_ca = inv_inc/ca

merge 1:1 country time using "$path\Variables\Stata files\dataset.dta"
keep if _merge==3
drop _merge

merge 1:1 country time using "$path\Variables TiVA\Stata files\datasetTiVa.dta"
rename time year
rename _merge _mergeTiVa

merge 1:1 country year using "$path\Variables\Stata files\broadmoney_GFDD.dta"

gen ocab_gdp = ca_gdp-invinc_gdp
encode country, gen(geo)
xtset geo year
compress
save "$path\ca_invinc_annual.dta", replace
clear