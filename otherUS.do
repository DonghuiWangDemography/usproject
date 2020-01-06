*other surveys 
*created on 12/04/2019

cd "C:\Users\donghuiw\Dropbox\Website\ThirdPartySurveys\otherUS\data"
global cleaned "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"

*1955 norc (no weight,not going to use)

*1989
infix wt_1 63-67 q10 27 q16 33 q17 34 using 1989_Lat187.dat,clear
	g wt=wt_1/1000 
	g opc_4p= 5- q10 if inrange(q10, 1,4)
	replace opc_4p= 999 if inrange(q10, 5,6)  // not sure or refused 
	g syear = 1989
	g survey = "la times"
	
keep wt syear opc_4p survey 
tempfile g1989
save `g1989.dta', replace 

*1990 times mirror 
/*roper 
22% Very unfavorable (minus 4-5)
39% Unfavorable (minus 1-3)
27% Favorable (plus 1-3)
4% Very favorable (plus 4-5)
8% Don't know
*/

infix 10 lines 10: wt_1 12- 13 1: q200e 64-65  using 1990_90TM2A.DAT, clear
	*recode q200e (1/3 =1)(4/5=2)(11/13=3)(14/15=4) (0=0), g(test)
	recode q200e (1=-1)(2=-2)(3=-3)(4=-4)(5=-5)(11= 1)(12= 2)(13= 3)(14= 4)(15= 5)(0=999), gen(opc_10pn)
	g wt=wt_1 /10
	g syear = 1990
	g survey = "times mirror"
	
keep wt syear opc_10pn survey 
tempfile g1990
save `g1990.dta', replace 

*1999 
use 1999_052899.DTA ,clear
	clonevar wt= weight 
	g opc_4p= 5- Q23 if inrange(Q23, 1,4)
	replace opc_4p = 999 if Q23==0 // not sure 
	g syear= 1999
	g survey = "cnn"
	
keep wt syear opc_4p survey 
tempfile g1999
save `g1999.dta', replace 

*2009
use 2009_040709A.DTA,clear
	clonevar wt= weight 
	g opc_4p= 5- Q20D if inrange(Q20D, 1,4)
	replace opc_4p = 999 if Q20D==9 // dk 
	g syear= 2009
	g survey = "cnn"
	
keep wt syear opc_4p survey 
tempfile g2009
save `g2009.dta', replace 

*2011
use 2011_053111.DTA,clear
	clonevar wt= weight 
	drop if Q11K ==.
	g opc_4p= 5- Q11K if inrange(Q11K, 1,4)
	replace opc_4p = 999 if Q11K==9 // dk 
	g syear= 2011
	g survey = "cnn"
	
keep wt syear opc_4p survey 
tempfile g2011
save `g2011.dta', replace 

*2011
use 2011_08.DTA,clear 
	clonevar wt= WEIGHT1 
	g opc_4p= 5- Q2I if inrange(Q2I, 1,4)
	replace opc_4p = 999 if Q2I==-1 // dk 
	g syear = 2011
	g survey = "PIPA"
keep wt syear opc_4p survey 
tempfile g2011p
save `g2011p.dta', replace 
	
*2014
use 2014_020514A.DTA,clear
	clonevar wt= weight 
	drop if Q30H ==.
	g opc_4p= 5- Q30H if inrange(Q30H, 1,4)
	replace opc_4p = 999 if Q30H==9 // dk 
	g syear= 2014
	g survey = "cnn"
	
keep wt syear opc_4p survey 
// tempfile g2014
// save `g2014.dta', replace 



*------trans atlantic : 03, 04, 05 ,06, 08, 10, 11------
use "C:\Users\donghuiw\Dropbox\Website\data_nocollapse\tra.dta" ,replace 
	keep if country == 840
	clonevar syear = year
	clonevar wt = weight  
	replace  wt = whgt_us if inlist(syear,2003,2005, 2012, 2013)
	
keep wt syear survey opc_100p opc_4p 
tempfile tara
save `tara.dta', replace 


*----------
append using `g1989.dta'
append using `g1990.dta'
append using `g1999.dta'
append using `g2009.dta'
append using `g2011.dta'
append using `g2011p.dta'
append using `tara.dta'


save "$cleaned\otherus.dta", replace 

*---test-------
use "$cleaned\otherus.dta", clear 
log using wt.txt
tab wt
log close 

replace opc_4p=. if opc_4p==999
collapse opc_4p [pweight=wt] , by(syear)
twoway connected opc_4p syear



