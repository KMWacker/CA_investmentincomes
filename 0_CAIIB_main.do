***********************************************
*** MERGING IAB and ISO COUNTRY CLASSIFIERS ***
******* FDI AND ASSIMILATION PROJECT **********
******************* KMW ***********************
***********************************************

clear
set more off
version 18.5
set matsize 5000

global path C:\Users\KMWacker\ownCloud\Documents\Projects\FactorpaymentsIIP\Data_Analysis

cd $path


****************************************************
*************** STRUCTURE OVERVIEW: ****************
* 1. Insheet current account data (Eurostat)  ******
* 2. Merge GDP data (Eurostat) *********************
* 3. Merging to parent_country_data_v01 ************
* 4. Merging w/ individual labor data **************
* 5. Regressions ***********************************
****************************************************

do 1_CAIIB_datacr.do

