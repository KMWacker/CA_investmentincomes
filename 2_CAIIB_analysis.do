global path C:\Users\...
cd $path

**************
*** Graphs: **
**************

use "$path\ca_invinc.dta"


*Figure 1
graph bar mn_invinc_gdp mn_ca_gdp if time==tq(2020q1) & geo=="Germany" | geo=="Japan" | geo=="Ireland" | geo=="Luxemburg" | geo=="Poland" | geo=="Netherlands" | geo=="Luxembourg" | geo=="France" | geo=="Romania" | geo=="Switzerland" | geo=="United States" | geo=="United Kingdom", over(country, label(angle(45))) graphregion(color(white)) ytitle(Share of GDP) legend(label(1 "Investment income balance") label(2 "Current account balance") pos(6) col(2))

graph twoway (scatter mn_invinc mn_ca if time>=tq(2020q1), graphregion(color(white)) mlabel(geo) ytitle(investment income balance / GDP) xtitle(current account balance / GDP) legend(off)) ///
(function y=x, range(-0.06 0.1) lcolor(grey))

*Generating Table A.1: Summary statistics and trends
bys country: sum invinc_gdp
bys country: reg invinc_gdp time, robust

**************
*** FACT 1: **
**************
* Zero correlation between IIBs and OCABs outside of OFCs,
* with large country heterogeneity

gen ocab_gdp = ca_gdp-invinc_gdp
label var ocab_gdp "other CAB components than IIBs"

* Overall correlation
corr ocab_gdp invinc_gdp

* Table 1
xtreg ocab_gdp c.invinc_gdp, fe robust
		outreg2 using $path\Results\correltable, /// 
		replace word auto(3) addtext (Estimation, FE) ///
		title("Correlation between IIBs and OCABs")

xtreg ocab_gdp c.invinc_gdp if dum_euro==1, fe robust	
		outreg2 using $path\Results\correltable, ///
		word auto(3) addtext (Estimation, FE) ///
		title("Correlation between IIBs and OCABs")

reg ocab_gdp c.invinc_gdp if dum_euro==1, robust cluster(country)	
		
xtreg ocab_gdp c.invinc_gdp if dum_euro==0, fe robust	
		outreg2 using $path\Results\correltable, ///
		word auto(3) addtext (Estimation, FE) ///
		title("Correlation between IIBs and OCABs")

reg ocab_gdp c.invinc_gdp if dum_euro==0, robust cluster(country)		
xtreg ocab_gdp c.invinc_gdp if geo!="Luxembourg" & geo!="Ireland", fe robust
		outreg2 using $path\Results\correltable, ///
		word auto(3) addtext (Estimation, FE) ///
		title("Correlation between IIBs and OCABs")
		
xtreg ocab_gdp c.invinc_gdp, be		/* not reported in paper table */
		
xtreg ocab_gdp c.invinc_gdp if geo!="Luxembourg" & geo!="Ireland", be
		outreg2 using $path\Results\correltable, ///
		word auto(3) addtext (Estimation, BE) ///
		title("Correlation between IIBs and OCABs")		
		
reg ocab_gdp c.invinc_gdp if geo!="Luxembourg" & geo!="Ireland", robust cluster(country) 		/* not reported in paper table */
		
* Table 2: Country-by-country regressions
			
bys geo: reg ocab_gdp c.invinc_gdp, robust

gen r_squared = .
foreach n of num 1 2 4/14 16 17 18 20/23 25 27/39 {
reg ca_gdp invinc_gdp if time>=tq(2008q1) & country==`n', robust
replace r_squared = e(r2) if country==`n'
}
sum r_squar if time==tq(2010q1), det


**************
*** FACT 2: **
**************
* IIBs and OCABs show opposite correlations with 
* traditional CAB correlates

use "$path\ca_invinc_annual.dta", clear

*make sure we have a complete sample
gen smpl_complete = 0
qui xtreg invinc_gdp savings gfdddi05 ggbudget termsoftrade dum_euro domcredit ggbudget, fe robust
replace smpl_complete = 1 if e(sample)

*Table 3
xtreg ca_gdp savings gfdddi05 ggbudget termsoftrade dum_euro domcredit  ggbudget if smpl_complete==1, fe robust
		outreg2 using $path\Results\fe_econletters, ///
		replace word auto(3) addtext (Note, all countries) ///
		title("Regression results") ctitle("CA/GDP") 
		
xtreg invinc_gdp savings gfdddi05 ggbudget termsoftrade dum_euro domcredit ggbudget if smpl_complete==1, fe robust
		outreg2 using $path\Results\fe_econletters, ///
		word auto(3) addtext (Note, all countries) ///
		title("Regression results") ctitle("IIB/GDP") 		

xtreg ocab_gdp savings gfdddi05 ggbudget termsoftrade dum_euro domcredit  ggbudget if smpl_complete==1, fe robust
		outreg2 using $path\Results\fe_econletters, ///
		word auto(3) addtext (Note, all countries) ///
		title("Regression results") ctitle("OCAB/GDP") 
		
* Robustness w/o major OFCs		
		
xtreg ca_gdp savings gfdddi05 ggbudget termsoftrade dum_euro domcredit  ggbudget if smpl_complete==1 & country!="Luxembourg" & country!="Ireland", fe robust
		outreg2 using $path\Results\fe_econletters_robust, ///
		replace word auto(3) addtext (Note, all countries) ///
		title("Regression results") ctitle("CA/GDP") 
		
xtreg invinc_gdp savings gfdddi05 ggbudget termsoftrade dum_euro domcredit  ggbudget if smpl_complete==1 & country!="Luxembourg" & country!="Ireland", fe robust
		outreg2 using $path\Results\fe_econletters_robust, ///
		word auto(3) addtext (Note, all countries) ///
		title("Regression results") ctitle("IIB/GDP") 		

xtreg ocab_gdp savings gfdddi05 ggbudget termsoftrade dum_euro domcredit ggbudget if smpl_complete==1 & country!="Luxembourg" & country!="Ireland", fe robust
		outreg2 using $path\Results\fe_econletters_robust, ///
		word auto(3) addtext (Note, all countries) ///
		title("Regression results") ctitle("OCAB/GDP")		
		
* test for equality of parameters in col (2) and (3)
test _b[savings] == -0.0010731
		

**************
*** FACT 3: **
**************
