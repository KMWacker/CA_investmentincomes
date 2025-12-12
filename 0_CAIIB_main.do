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
****************************************************

do 1_CAIIB_datacr.do
