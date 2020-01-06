*exploratory 

global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"

cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"


use GSS_China.dta, clear 
 keep if inlist(year, 1974,1975,1977,1982,1983,1985,1986,1988,1989,1990,1991,1993,1994)
 clonevar syear =year 
 recode china (0=5) (1=4)(2=3)(3=2)(4=1)(5=-1)(6=-2)(7=-3)(8=-4)(9=-5) (.d= 999),gen(opc_10pn)
 clonevar wt = wtssall
 keep syear opc_10pn wt
 g survey=  "gss"

append using gallup.dta
append using abc.dta
*append using abc_v2.dta
append using cbs.dta
append using chicago.dta
append using pew_us.dta
append using otherus.dta


la var syear "survey year"
drop  if survey == "pew" & syear ==2014  // all 999 in 2014 pew
drop  if survey == "gss" & syear == 1994 

save "pooled.dta", replace 



use  "pooled.dta", clear 
foreach x of varlist opc_10pn opc_4p opc_100p opc_3p {
*replace `x' =. if `x' ==999
fre `x'
}

*positive attitude 
g d_opc_10pn=(inrange(opc_10pn,1,5)) if !missing(opc_10pn)
g d_opc_3p = (opc_3p==3)			 if !missing(opc_3p)
g d_opc_4p =(inrange(opc_4p,3,4))    if !missing(opc_4p)
g d_opc_100p =(inrange(opc_100p, 51,100)) if !missing(opc_100p)


g 		dich= d_opc_10pn 
replace dich= d_opc_3p   if dich ==.
replace dich= d_opc_4p   if dich ==.
replace dich= d_opc_100p if dich ==.


*negative attitude 
g dn_opc_10pn=(inrange(opc_10pn,-5,-1))     if !missing(opc_10pn)
g dn_opc_3p = (opc_3p==1)					if !missing(opc_3p)
g dn_opc_4p =(inrange(opc_4p,1,2)) 			if !missing(opc_4p)
g dn_opc_100p =(inrange(opc_100p, 0,49))    if !missing(opc_100p)


g 		dich_n= dn_opc_10pn  
replace dich_n= dn_opc_3p    if dich_n==.
replace dich_n= dn_opc_4p    if dich_n==.
replace dich_n= dn_opc_100p  if dich_n==.


*preserve 
collapse dich dich_n [pweight=wt] , by (syear)
drop if dich==.

replace dich=dich*100
replace dich_n = dich_n*100

save raw_combined, replace

//twoway scatter  dich syear || loewss dich syear

twoway (connected dich syear) (connected dich_n syear),  ///
		xtitle("year") ytitle("%")  xlabel(1970(5)2020) legend(col(1) order(1 "favorable " 2 "unfavorable")) /// 
		title("% of favorable and unfavorable attitudes toward China")  note(Note: 80 cross-sectional surveys)
		
graph save "$image\bin_combined", replace 
graph export  "$image\bin_combined.png" , replace 
*restore

*-----------
collapse dich dich_n [pweight=wt] , by (syear survey)

*putexcel set "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\collaps_nowt.xlsx"
*collapse dich dich_n  , by (syear survey)
replace dich=dich*100
replace dich_n = dich_n*100
g dk=100- (dich+dich_n)

#delimit ;
twoway (connected dich syear if survey =="gallup") 
       (connected dich syear if survey =="gss" )
	   (connected dich syear if survey =="pew" )
	   (connected dich syear if survey =="chicago")
	   (connected dich syear if survey =="tra")	   
	   (connected dich syear if survey =="cnn")
	   (connected dich syear if survey =="abc")
	   (connected dich syear if survey =="cbs")
	   (scatter dich syear if survey =="la times")
	   (scatter dich syear if survey =="times mirror")
	   (scatter dich syear if survey =="PIPA")	   
	   , 
	   title("% Favorable attitudes toward China")
	   ytitle("%") 
	   xtitle("year") 
	   xlabel(1970(5)2020)
	   ylabel(0(20)80)
	   legend(col(1) 
			 order(1 "Gallup" 
				   2 "GSS" 
				   3 "Pew" 
				   4 "Chicago Council" 
				   5 "Transatlantic Trends" 
				   6 "CNN"
				   7 "ABC"
				   8 "CBS"
				   9 "LA Times"
				  10 "Times Mirror"
				  11 "PIPA"))
				  ;
#delimit cr
graph save "$image\bin", replace 

graph use "$image\bin"
graph export "$image\bin.png", replace  


*unfav 
#delimit ;
twoway (connected dich_n syear if survey =="gallup") 
       (connected dich_n syear if survey =="gss" )
	   (connected dich_n syear if survey =="pew" )
	   (connected dich_n syear if survey =="chicago")
	   (connected dich_n syear if survey =="tra")	   
	   (connected dich_n syear if survey =="cnn")
	   (connected dich_n syear if survey =="abc")
	   (connected dich_n syear if survey =="cbs")
	   (scatter dich_n syear if survey =="la times")
	   (scatter dich_n syear if survey =="times mirror")
	   (scatter dich_n syear if survey =="PIPA")	   
	   , 
	  title("%Unfavorable attitudes toward China")
	   ytitle("%") 
	   xtitle("year") 
	   xlabel(1970(5)2020)
	   ylabel(0(20)80)
	   legend(col(1) 
			 order(1 "Gallup" 
				   2 "GSS" 
				   3 "Pew" 
				   4 "Chicago Council" 
				   5 "Transatlantic Trends" 
				   6 "CNN"
				   7 "ABC"
				   8 "CBS"
				   9 "LA Times"
				  10 "Times Mirror"
				  11 "PIPA"))
				  ;
#delimit cr
graph save "$image\bin_n", replace 

graph use "$image\bin_n"
graph export "$image\bin_n.png", replace  

*dk,refuse 

#delimit ;
twoway (connected dk syear if survey =="gallup") 
       (connected dk syear if survey =="gss" )
	   (connected dk syear if survey =="pew" )
	   (connected dk syear if survey =="chicago")
	   (connected dk syear if survey =="tra")	   
	   (connected dk syear if survey =="cnn")
	   (connected dk syear if survey =="abc")
	   (connected dk syear if survey =="cbs")
	   (scatter dk syear if survey =="la times")
	   (scatter dk syear if survey =="times mirror")
	   (scatter dk syear if survey =="PIPA")	   
	   , 
	  title(" % Don't know,neutral, or refuse to answer")
	   ytitle("%") 
	   xtitle("year") 
	   xlabel(1970(5)2020)
	   legend(col(1) 
			 order(1 "Gallup" 
				   2 "GSS" 
				   3 "Pew" 
				   4 "Chicago Council" 
				   5 "Transatlantic Trends" 
				   6 "CNN"
				   7 "ABC"
				   8 "CBS"
				   9 "LA Times"
				  10 "Times Mirror"
				  11 "PIPA"))
				  ;
#delimit cr

graph save "$image\dk", replace 
graph export "$image\dk.png", replace 



*-------------------
*an alternative way to calculate 
*---------------
use  "pooled.dta", clear 
foreach x of varlist opc_10pn opc_4p opc_100p opc_3p {
replace `x' =. if `x' ==999
}

collapse opc_10pn opc_4p opc_100p opc_3p [pweight=wt], by(syear survey)


#delimit ;
twoway (connected opc_10pn syear if survey =="gallup")
	   (connected opc_10pn syear if survey =="gss")
       ,
	   title("Scale -5  to +5 ")
	   ytitle("Mean") 
	   xtitle("year") 
	   xlabel(1970(5)2000)	
	   ytitle("Mean ") 
	   legend(col(2) order(1 "Gallup"  2 "GSS") ring(0) size(small))
	   saving(s10, replace) 
	   ;
#delimit cr



#delimit ;
twoway (connected opc_100p syear if survey =="chicago")
       (connected opc_100p syear if survey =="tra")
	   ,
	   title("Scale 0 to 100")
	   xtitle("year") 
	   xlabel(2000(5)2015)	
	   ytitle("Mean") 
	   legend(col(2) order(1 "Chicago Council"  2 "Transatlantic Trends") ring(0) size(small))
	   saving(s100, replace) 
	   ;
#delimit cr


#delimit ;
twoway (connected opc_4p syear if survey =="gallup")
       (connected opc_4p syear if survey =="pew")
	   (connected opc_4p syear if survey =="cnn")
	   ,
	   title("Scale 1 to 4")
	   xtitle("year") 
	   xlabel(1975(5)2020)	
	   ytitle("Mean") 
	   legend(col(3) order(1 "Gallup"  2 "Pew" 3 "CNN") ring(0) size(small))
	   saving(s4, replace) 
	   ;
#delimit cr



#delimit ;
twoway (connected opc_3p syear if survey =="abc")
       (connected opc_3p syear if survey =="cbs")
	   ,
	   title("Scale 1 to 3")
	   xtitle("year") 
	   xlabel(1975(5)2020)	
	   ytitle("Mean") 
	   legend(col(1) order(1 "ABC"  2 "CBS") ring(0) size(small) position(3))
	   saving(s3, replace) 	   
	   ;
#delimit cr

graph combine "s10" "s100" "s4" "s3" 

graph save "$image\panel", replace 

graph use "$image\panel"
graph export "$image\panel.png",replace 


*-------------------------------
*look up frequencies 
use  "pooled.dta", clear 
keep if syear == 1989 

cumul opc_10pn if opc_10pn != 999, gen(gss_1989)
cumul opc_4p   if opc_4p != 999 & survey == "gallup" , gen(gallup_1989)
cumul opc_4p   if opc_4p != 999 & survey == "la times" , gen(la_1989)
cumul opc_3p   if opc_3p != 999 & survey == "abc" , gen(abc_1989)


*stack gss_1989 gallup_1989  la_1989  abc_1989, into(opc_1989) wide clear

sort gss_1989 gallup_1989 la_1989 opc_3p
line gss_1989 opc_10pn if opc_10pn != 999   ||  line gallup_1989 opc_4p if opc_4p != 999  || line la_1989 opc_4p if opc_4p != 999 || line abc_1989 opc_3p if opc_3p != 999
	 



sort survey 
*1989 : abc, gallup gss, la times 
foreach x of varlist  opc_10pn opc_4p  opc_3p {
drop if `x' == 999 
*histogram `x' if syear == 1989 &  `x' != 999  // abc
*tab `x' survey if syear == 1989  // abc
bysort survey : tab `x'
}


twoway  (kdensity opc_10pn if syear == 1989 &  opc_10pn != 999)   ///
		(kdensity opc_4p   if syear == 1989 &  opc_4p != 999 & survey == "gallup")  ///
		(kdensity opc_4p   if syear == 1989 &  opc_4p != 999 & survey == "la times")  ///
		(kdensity opc_3p   if syear == 1989 &  opc_3p != 999 )  
		
twoway  (histogram opc_10pn if syear == 1989 &  opc_10pn != 999)   ///
		(histogram opc_4p   if syear == 1989 &  opc_4p != 999 & survey == "gallup")  ///
		(histogram opc_4p   if syear == 1989 &  opc_4p != 999 & survey == "la times")  ///
		(histogram opc_3p   if syear == 1989 &  opc_3p != 999 )  
		