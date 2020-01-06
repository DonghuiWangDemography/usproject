*chicago conuncil

cd "C:\Users\donghuiw\Dropbox\Website\ThirdPartySurveys\Chicago_Council\data"

*2002
use 2002_02CCFRB.DTA,clear
	drop if Q510A14 <0  // negative as non- response or not asked ?
	clonevar opc_100p= Q510A14 if Q510A14<100
	replace opc_100p=999 if !inrange(Q510A14, 0, 100)
*	recode opc_100p (0/30=1)(31/49=2)(50=3)(51/75=4)(76/100=5),g(test) 
	g syear =2002

keep wt syear opc_100p
tempfile g2002
save `g2002.dta', replace 

*2006
use 2006_06GLOBEV.DTA,clear
	g opc_100p= Q333_6 if Q333_6>0
	replace  opc_100p=999 if  !inrange(Q333_6, 0, 100)
	g syear = 2006
	clonevar wt = weight
keep wt syear opc_100p
tempfile g2006
save `g2006.dta', replace 	

*2008 
*soft
use 2008_08SOFT.DTA, clear
	g opc_100p =Q70B_CH
	replace opc_100p=999 if !inrange(Q70B_CH, 0, 100)
	g syear = 2008
	clonevar wt = weight
keep wt syear opc_100p
tempfile g2008_1
save `g2008_1.dta', replace 	

use 2008_08GLOBAL.DTA,clear 
	g opc_100p =Q150_6
	replace opc_100p=999 if !inrange(Q150_6, 0, 100)
	g syear = 2008
	clonevar wt = weight	
keep wt syear opc_100p

tempfile g2008_2
save `g2008_2.dta', replace 

*2010
use 2010_10GLOBALV.DTA,clear
	g opc_100p =Q45_CN
	replace opc_100p=999 if !inrange(Q45_CN, 0, 100)
	g syear = 2010
	clonevar wt = weight
keep wt syear opc_100p
tempfile g2010
save `g2010.dta', replace 	

*2013
use 2013_201304CCGA.DTA,clear
	g opc_100p =Q1_1
	replace opc_100p=999 if !inrange(Q1_1, 0, 100)
	g syear = 2013
	clonevar wt = WEIGHT_1
keep wt syear opc_100p
tempfile g2013
save `g2013.dta', replace 	


*2014
use 2014_2014ccga.dta,clear
	g opc_100p = Q45_06
	replace opc_100p=999 if !inrange(Q45_06, 0, 100)
	g syear = 2014
	clonevar wt = WEIGHT1
keep wt syear opc_100p

*-------------
append using `g2002.dta'
append using `g2006.dta'
append using `g2008_1.dta'
append using `g2008_2.dta'
append using `g2010.dta'
append using `g2013.dta'

g survey = "chicago" 

save "$cleaned\chicago.dta" , replace 
