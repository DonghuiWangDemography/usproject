*cbs
cd "C:\Users\donghuiw\Dropbox\Website\ThirdPartySurveys\CBS\data"
global cleaned "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"

*1979
/*
26% Favorable
44% Neutral
24% Unfavorable
6% No opinion
*/

infix 3 lines 3:wt_1 49-54 1: q16c 50 using 1979_020179.DAT,clear
	g wt=wt_1/1000
	g       opc_3p= 3 if q16c==1  // fav
	replace opc_3p= 2 if q16c==3 // neutral
	replace opc_3p= 1 if q16c==2 // unfav
	replace opc_3p= 999  if q16c==9
	g syear = 1979
keep wt syear opc_3p 
	
tempfile g1979
save `g1979.dta', replace 	

*1998
use 1998_98MY23.DTA, clear
	clonevar wt=weight
	g       opc_3p= 3 if Q16==1  // fav
	replace opc_3p= 2 if Q16==3 // neutral
	replace opc_3p= 1 if Q16==2 // unfav
	replace opc_3p= 999  if Q16==9
	g syear = 1998
keep wt syear opc_3p 

tempfile g1998_1
save `g1998_1.dta', replace 	

use 1998_061098.DTA,clear 	
	clonevar wt=weight
	g       opc_3p= 3 if Q5==1  // fav
	replace opc_3p= 2 if Q5==3 // neutral
	replace opc_3p= 1 if Q5==2 // unfav
	replace opc_3p= 999  if Q5==9
	g syear = 1998
	
keep wt syear opc_3p 	
tempfile g1998_2
save `g1998_2.dta', replace 	

*1999
use 1999_051299.DTA, clear
	clonevar wt=weight
	g       opc_3p= 3 if Q9==1  // fav
	replace opc_3p= 2 if Q9==3 // neutral
	replace opc_3p= 1 if Q9==2 // unfav
	replace opc_3p= 999  if Q9==9
	g syear = 1999
	
keep wt syear opc_3p 	
tempfile g1999
save `g1999.dta', replace 	

*2001
use 2001_040601.DTA,clear
	clonevar wt=weight
	g       opc_3p= 3 if Q26==1  // fav
	replace opc_3p= 2 if Q26==3 // neutral
	replace opc_3p= 1 if Q26==2 // unfav
	replace opc_3p= 999  if Q26==9
	g syear = 2001
	
keep wt syear opc_3p 	
// tempfile g2001
// save `g2001.dta', replace 	


*-------
append using `g1979.dta'
append using `g1998_1.dta'
append using `g1999.dta'

g survey = "cbs"

save "$cleaned\cbs.dta", replace 

use "$cleaned\cbs.dta" , clear 
