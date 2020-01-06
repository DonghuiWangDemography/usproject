*created on 12/3/2019 
*gallup data on attitude toward China
*recode: the larger the value, the more favorable the attitude 
*naming convention : 4p = 4 scale all positive, 10np : 10 scale, positive and negative values ; 100p : 100 scale, positive values  

*cd "C:\Users\wdhec\Dropbox\Website\ThirdPartySurveys\GALLUP\data"  laptop
global ga "C:\Users\donghuiw\Dropbox\Website\ThirdPartySurveys\GALLUP\data" 
global cleaned "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"

cd "$ga"
*---------------------
*1976
infix wt 1 q04b 10-11 using 1976_954.DAT, clear  // wt 1-4
	*notice the inconsistencies between data and codebook : the results are consistent with codebook 
	recode q04b (5=5) (4=4) (3=3) (2=2) (1=1) (6= -1) (7=-2) (8=-3)(9=-4) (10=-5) (11=999), gen(opc_10pn) 
	g syear= 1976
	drop q04b
	
tempfile g1976
save `g1976.dta', replace 

*1977: China-cuba study 
use 1977_7757GO.DTA,clear
	rename weight wt // 1-4
	drop if Q03_A==0
	g syear = 1977
	g opc_4p= 5- Q03_A if Q03_A<5
	replace opc_4p= 999 if Q03_A==5
	keep wt syear opc_4p 
	
tempfile g1977
save `g1977.dta', replace 

*1979  :koea 
use 1979_79138G.DTA,clear
	rename weight wt  // 1-4
	g syear = 1979
	g 		opc_4p=1 if Q2D == "4"
	replace opc_4p=2 if Q2D == "3"
	replace opc_4p=3 if Q2D == "2"
	replace opc_4p=4 if Q2D == "1"
	replace opc_4p=999 if Q2D == "&"

	keep wt syear opc_4p
	
tempfile g1979_1
save `g1979_1.dta', replace 

 
*1979 
infix wt 1 q05b 78-79 using 1979_1123.dat, clear
	recode q05b (5=1) (4=2) (3=3) (2=4) (1=5) (6= -1) (7=-2) (8=-3)(9=-4) (10=-5) (11=999), gen(opc_10pn)
	g syear = 1979
	keep wt syear opc_10pn
tempfile g1979_2
save `g1979_2.dta', replace 	


* 1980
infix wt 1 q05b  66-67 using 1980_1147.dat, clear   // wt 1-4
	recode q05b (5=1) (4=2) (3=3) (2=4) (1=5) (6= -1) (7=-2) (8=-3)(9=-4) (10=-5) (11=999), gen(opc_10pn)
	g syear = 1980
	keep wt syear opc_10pn
tempfile g1980
save `g1980.dta', replace 	


*1983
infix wt_1 1 Q09c 37-38 using 1983_1224.dat, clear 
	g wt=wt_1/100
	recode Q09c (5=1) (4=2) (3=3) (2=4) (1=5) (6= -1) (7=-2) (8=-3)(9=-4) (10=-5) (11=999), gen(opc_10pn)
	g syear = 1983
	keep wt syear opc_10pn
	
tempfile g1983
save `g1983.dta', replace 	


*1987
*weighted to be inverst of each r's prob of being at home 
infix 9 lines 1: wt_1 1-3 2: q202g 39-40 using 1987_TM09PR.DAT,clear 
	g wt=wt_1/100
	drop if  q202g ==.
	recode q202g (6= -5)(7=-4)(8=-3)(9=-2)(10=-1) (11=999)(12=1)(13=2)(14=3)(15=4)(16=5),gen(opc_10pn) 
	g syear = 1987
	recode opc_10pn (-5/-4=1)(-3/-1=2)(1/3=3)(4/5=4),g(test)
	keep wt syear opc_10pn
	
tempfile g1987
save `g1987.dta', replace 


*1989 
infix 3 lines 1: wt_1 13-15  1: q8b 52  using 1989_040689.dat,clear 
	g wt=wt_1/100
	g syear = 1989
	g opc_4p = 5- q8b if inrange(q8b, 1,4)
	replace opc_4p = 999 if q8b ==5 | q8b==0  // cannot rate or  never heard of
	keep wt syear opc_4p
	
tempfile g1989_1
save `g1989_1.dta', replace 	


*1989
infix 2 lines 1: wt_1 12-15 2:q2a 13  using 1989_081689.dat,clear
	g wt=wt_1/100
	g syear=1989
	g       opc_4p = 5- q2a if inrange(q2a, 1,4)
	replace opc_4p = 999 if q2a ==5 | q2a==0  // cannot rate or  never heard of
	keep wt syear opc_4p
		
tempfile g1989_2
save `g1989_2.dta', replace 	
	


*1990
infix 6 lines 1: wt_1 13-15 4: q18o 29-31 using 1990_90CFRP.dat,clear
	g wt=wt_1/100
	drop if q18o==.
	g opc_100p =q18o 
	g syear=1990
	keep  wt syear opc_100p
tempfile g1990
save `g1990.dta', replace 	


*1991
*infix wt 13-15 sex 44 q2k 35 using 1991_122021.DAT, clear

*1993
*form A
infix 6 lines 1: wt_1 13-15 5:q20 56 using 1993_422021.DAT,clear
	g wt=wt_1/100
	drop if q20 ==.
	g       opc_4p = 5- q20 if inrange(q20, 1,4)
	replace opc_4p = 999 if q20 ==5   // dk or refused 
	g syear = 1993
	keep wt syear opc_4p
		
tempfile g1993_a
save `g1993_a.dta', replace 	

*form B
infix 6 lines 1: wt_1 13-15 5:q20 57-58 using 1993_422021.DAT,clear
	g wt=wt_1/100
	drop if q20 ==.
	recode q20 (1= -5)(2=-4)(3=-3)(4=-2)(5=-1) (6=1)(7=2)(8=3)(9=4)(10=5)(11/12=999),gen(opc_10pn) 
	g syear = 1993
	keep wt syear opc_10pn
	
tempfile g1993_b
save `g1993_b.dta', replace 	


*1994
infix 6 lines 1: wt_1 13-15 5:q15 52 using  1994_422035.DAT,clear
	g wt=wt_1/100
	g       opc_4p = 5- q15 if inrange(q15, 1,4)
	replace opc_4p = 999 if q15 ==5   // dk or refused 
	g syear = 1994
	keep wt syear opc_4p
	
tempfile g1994
save `g1994.dta', replace 	


*1996
infix 8 lines 1: wt_1 13-15 6:q38 63-64 using 1996_96JAN.DAT,clear
	g wt=wt_1/100
	drop if wt ==.
	recode q38 (1= -5)(2=-4)(3=-3)(4=-2)(5=-1)(6=1)(7=2)(8=3)(9=4)(10=5)(11/12=999),gen(opc_10pn) 
	g syear = 1996
	keep wt syear opc_10pn
	
tempfile g1996_1
save `g1996_1.dta', replace

*960307 : march 
infix 8 lines 1: wt_1 13-15 6:q22i 28-29 using 1996_960307.DAT,clear
	g wt=wt_1/100
	drop if wt ==.
	recode q22i (1= -5)(2=-4)(3=-3)(4=-2)(5=-1)(6=1)(7=2)(8=3)(9=4)(10=5)(0=999),gen(opc_10pn) 
	g syear = 1996
	keep wt syear opc_10pn
tempfile g1996_2
save `g1996_2.dta', replace



*1997 
infix 7 lines 1:wt_1 13-15 6:q21  51 using 1997_97JE26.DAT,clear
	g wt=wt_1/100
	g       opc_4p = 5- q21 if inrange(q21, 1,4)
	replace opc_4p = 999 if q21 ==5   // dk or refused 
	g syear = 1994
	keep wt syear opc_4p

tempfile g1997
save `g1997.dta', replace


*1998
infix 7 lines 1:wt_1 13-15 6:q5 26 using 1998_062898.DAT, clear 
	drop if q5==.  // split sample
	g wt=wt_1/100
	g       opc_4p = 5- q5 if inrange(q5, 1,4)
	replace opc_4p = 999 if q5 ==5   // dk or refused 
	g syear = 1998
	keep wt syear opc_4p
	
tempfile g1998_1
save `g1998_1.dta', replace

*june
infix 7 lines 1:wt_1 13-15 6:q12 33 using 1998_98JUL7.DAT, clear 
	g wt=wt_1/100
	g       opc_4p = 5- q12 if inrange(q12, 1,4)
	replace opc_4p = 999 if q12 ==5   // dk or refused 
	g syear = 1998
	keep wt syear opc_4p
	
tempfile g1998_2
save `g1998_2.dta', replace	

*1999 
*feb 
use  1999_99FEB8.DTA,clear
	clonevar wt= weight
	g       opc_4p = 5- Q2G if inrange(Q2G, 1,4)
	replace opc_4p = 999 if Q2G ==5   // dk or refused 
	g syear = 1999
	keep wt syear opc_4p
tempfile g1999_1
save `g1999_1.dta', replace	


*mar
infix 7 lines 1:wt_1 13-15 7:q34 33 using 1999_99MAR12.DAT, clear 
	g wt=wt_1/100
	g       opc_4p = 5- q34 if inrange(q34, 1,4)
	replace opc_4p = 999 if q34 ==5   // dk or refused 
	g syear = 1999
	keep wt syear opc_4p
	
tempfile g1999_2
save `g1999_2.dta', replace	

*99MM07
infix 7 lines 1:wt_1 13-15 6:q23a 61 using 1999_99MM07.dat,clear 
	g wt=wt_1/100
	g       opc_4p = 5- q23a if inrange(q23a, 1,4)
	replace opc_4p = 999 if q23a ==5   // dk or refused 
	g syear = 1999
	keep wt syear opc_4p
	
tempfile g1999_3
save `g1999_3.dta', replace	


*2000
use 2000_00MC17.DTA,clear
	clonevar wt = wtfctr
	drop if Q17B==.
	g       opc_4p = 5- Q17B if inrange(Q17B, 1,4)
	replace opc_4p = 999 if Q17B ==5   // dk or refused 
	g syear = 2000
	keep wt syear opc_4p
	
tempfile g2000_1
save `g2000_1.dta', replace	

use 2000_00NMB13.DTA,clear
	clonevar wt = wtfctr
	g       opc_4p = 5- Q13C if inrange(Q13C, 1,4)
	replace opc_4p = 999 if Q13C ==5   // dk or refused 
	g syear = 2000
	keep wt syear opc_4p
	
// tempfile g2000_2
// save `g2000_2.dta', replace	

*------------
append using  `g1976.dta'
append using `g1977.dta'
append using `g1979_1.dta'
append using `g1979_2.dta'
append using `g1980.dta'
append using `g1983.dta'
append using `g1987.dta'
append using `g1989_1.dta'
append using `g1989_2.dta'
append using `g1990.dta'
append using `g1993_a.dta'
append using `g1993_b.dta'
append using `g1994.dta'
append using `g1996_1.dta'
append using `g1996_2.dta'
append using `g1997.dta'
append using `g1998_1.dta'
append using `g1998_2.dta'
append using `g1999_1.dta'
append using `g1999_2.dta'
append using `g1999_3.dta'
append using `g2000_1.dta'

g survey = "gallup"

// *1 in person 2 televephone 
// g       type = 1 if inrange(syear,1976,1987)
// replace type = 1 if syear == 1990
// replace type = 2 if type == . 

save "$cleaned\gallup.dta" , replace 


*--------------
// use "$cleaned\gallup.dta", clear 

// *compare with GSS
// use "$cleaned\GSS_China.dta" , clear
//  drop if year > 1994
//  clonevar syear =year 
//  recode china (0=5) (1=4) (2=3)(3=2)(4=1)(5=-1)(6=-2)(7=-3)(8=-4)(9=-5) (.=.),gen(opc_10pn)
//  clonevar wt = wtssall
//  keep syear opc_10pn wt
//  g survey=  "gss"
// 
// append using "$cleaned\gallup.dta"
// replace opc_10pn =. if opc_10pn==999
//
//
// *collapse opc_10pn  [pweight=cweight] , by(syear survey)
//
// collapse opc_10pn [pweight=wt] , by(syear survey)
// twoway (connected opc_10pn syear if survey =="gallup" ) ///
//        (connected opc_10pn syear if survey =="gss" ), ///
// 	   ytitle("mean(-5 to +5)") ///
// 	   xtitle("year")  ///
// 	   xlabel(1972(2)2000) ///
// 	   legend(rows(2) order(1 "gallup" 2 "gss"))
//
//	   
// *compare with pew
// use "$cleaned\pew_us.dta" , clear
// append using "$cleaned\gallup.dta"
// replace opc_4p =. if opc_4p==999
//
//
//
// twoway (scatter opc_4p syear if survey =="gallup" ) ///
//        (scatter opc_4p syear if survey =="pew" ), ///
// 	   xtitle("year")  ///
// 	   legend(rows(2) order(1 "gallup" 2 "pew"))


	   