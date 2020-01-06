*abc

cd "C:\Users\donghuiw\Dropbox\Website\ThirdPartySurveys\ABC\data"
global cleaned "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"

*1989
infix 4 lines 4:wt_1 25-32 2:q41g 59 using 1989_89APR.dat,clear
	g wt=wt_1/10 
	g 		opc_3p = 1 if q41g==2     // unfav
	replace opc_3p = 2 if q41g==8     // dk or no opinion 
	replace opc_3p = 3 if q41g==1     //fav 	
	replace opc_3p = 999 if q41g==9   // NA/refused 
	g syear = 1989
keep wt syear opc_3p
tempfile g1989_1
save `g1989_1.dta', replace 

*jap
infix 4 lines  4:wt_1 25-32 2:q335 52 using 1989_89JAPN.dat, clear
	g wt=wt_1/10 
	drop if wt>10
	g 		opc_3p = 1 if q335==2 // unfav
	replace opc_3p = 2 if q335==8 // dk or no opinion 
	replace opc_3p = 3 if q335==1 //fav 	
	replace opc_3p = 999 if q335==9 
	g syear = 1989
keep wt syear opc_3p
tempfile g1989_2
save `g1989_2.dta', replace 

*1990
infix 3 lines 3:wt_1 25-33 2:q3b 9 using 1990_379.DAT,clear
	g wt=wt_1/100
	g 		opc_3p = 1 if q3b==2 // unfav
	replace opc_3p = 2 if q3b==8 // dk or no opinion 
	replace opc_3p = 3 if q3b==1 //fav 	
	replace opc_3p = 999 if q3b==9 //fav 
	g syear = 1990
	
keep wt syear opc_3p
tempfile g1990
save `g1990.dta', replace 

*2011
use 2011_011911.DTA,clear
	clonevar wt = weight
	g 		opc_3p = 1 if Q31NET==2 // unfav
	replace opc_3p = 2 if Q31NET==8 // dk or no opinion 
	replace opc_3p = 3 if Q31NET==1 //fav 	
	replace opc_3p = 999 if Q31NET==. 
	g syear = 2011
keep wt syear opc_3p
// tempfile g2011
// save `g2011.dta', replace 

append using `g1989_1.dta'
append using `g1989_2.dta'
append using `g1990.dta'

g survey = "abc"
save "$cleaned\abc.dta" , replace 


use "$cleaned\abc.dta" , clear 
* code into binary
g 		opc_2p = 1 if opc_3p == 1 
replace opc_2p = 2 if opc_3p == 3
replace opc_2p = 999 if opc_3p == 2 |  opc_3p == 999

drop opc_3p
save "$cleaned\abc_v2.dta" , replace  
