*work on aggregate data 
* updated in 12/11/2019

//     net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
//     set scheme cleanplots

cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"
global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 
global ga "C:\Users\donghuiw\Dropbox\Website\ThirdPartySurveys\GALLUP\data" 


//global cleaned "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"

import delimited C:\Users\donghuiw\Dropbox\Website\US_project\agg_data\Roper_117q_12102019.csv,clear 

* drop inapp questionaries 
drop if questionid == "Number of items downloaded: " | questionid =="USGALLUP.11CHINA1.R02"  // china daily only interviewed once
drop if surveysponsor == "Pew Global Attitudes Project"  //pew cleaned in somwhere
drop if questionid=="USTNS.03TRANS.R08I2"                // pct missing 
drop if questionid== "USGALLUP.90CFRP.R18O"             // pct missing 
drop if questionid== "USHARRIS.09COMM100.R0835"  // ppl of china 
* drop two strange years
drop if questionid == "USGALLUP.062898.R5"   // 1998 
drop if questionid == "USGALLUP.03FEB3.R25C"


drop if  resppct  == "*"  // less than 5 %
drop questionnote

order questionid orgname surveyorg  resptxt   sourcedoc questiontxt resppct


*--------------------------
* 20 unique orgname 
*recode reponses 
sort surveyorg  questionid resptxt questionid

* 2 scale : 1 2 
g 		resp = 2 if resptxt == "Favorable"        &       ( surveyorg == "ABC News" | surveyorg ==  "ABC News/Washington Post")
replace	resp = 1 if resptxt == "Unfavorable"      &        ( surveyorg == "ABC News" | surveyorg ==  "ABC News/Washington Post")


*4 scale abc 1234

replace	resp = 1 if (resptxt == "Very unfavorable"   | resptxt == "Strongly unfavorable" )  &      surveyorg ==  "ABC News/Washington Post"
replace	resp = 2 if resptxt == "Somewhat unfavorable"  &   surveyorg ==  "ABC News/Washington Post"

replace	resp = 3 if resptxt == "Somewhat favorable"  &  surveyorg ==  "ABC News/Washington Post"
replace	resp = 4 if (resptxt == "Very favorable"  | resptxt == "Strongly favorable" )   &      surveyorg ==  "ABC News/Washington Post"



* 3 scale :1 2 3 
replace	resp = 1 if resptxt== "Generally unfavorable" &  surveyorg == "CBS News"
replace	resp = 2 if resptxt== "Neutral"               &  surveyorg == "CBS News"
replace	resp = 3 if resptxt== "Generally favorable"   &  surveyorg == "CBS News"


replace	resp = 1 if resptxt== "Unfavorable"      &  surveyorg == "CBS News/New York Times"
replace	resp = 2 if resptxt== "Neutral"          &  surveyorg == "CBS News/New York Times"
replace	resp = 3 if resptxt== "Favorable"        &  surveyorg == "CBS News/New York Times"

replace	resp = 1 if resptxt== "Generally unfavorable" &  surveyorg == "CBS News/New York Times"
replace	resp = 3 if resptxt== "Generally favorable" &  surveyorg == "CBS News/New York Times"


*9 scale  1- 9 1- very ufav, 9 very fav 
replace	resp = 1 if resptxt== "1--Very unfavorable" &  surveyorg == "Cambridge Reports/Research International"
replace	resp = 2 if resptxt== "2" &  surveyorg == "Cambridge Reports/Research International"
replace	resp = 3 if resptxt== "3" &  surveyorg == "Cambridge Reports/Research International"
replace	resp = 4 if resptxt== "4" &  surveyorg == "Cambridge Reports/Research International"
replace	resp = 5 if resptxt== "5" &  surveyorg == "Cambridge Reports/Research International"
replace	resp = 6 if resptxt== "6" &  surveyorg == "Cambridge Reports/Research International"
replace	resp = 7 if resptxt== "7" &  surveyorg == "Cambridge Reports/Research International"
replace	resp = 8 if resptxt== "8" &  surveyorg == "Cambridge Reports/Research International"
replace	resp = 9 if resptxt== "9--Very favorable" &  surveyorg == "Cambridge Reports/Research International"


*5 scale [infact 100] EOS Gallup Europe
encode  resptxt if surveyorg == "EOS Gallup Europe", g(ecd)
fre ecd 
replace resp = ecd if inrange(ecd, 1,5)
replace resp = 999 if inrange(ecd, 6,8)
drop ecd

*----------gallup---------- 

*10 scale 
replace resptxt = "5" if questionid=="USGALLUP.01FYR1.R28D" & resptxt== ""

replace	resp = 1 if (resptxt== "-5" | resptxt== "Minus 5") &  surveyorg == "Gallup Organization"
replace	resp = 2 if (resptxt== "-4" | resptxt== "Minus 4") &  surveyorg == "Gallup Organization"
replace	resp = 3 if (resptxt== "-3" | resptxt== "Minus 3") &  surveyorg == "Gallup Organization"
replace	resp = 4 if (resptxt== "-2" | resptxt== "Minus 2") &  surveyorg == "Gallup Organization"
replace	resp = 5 if (resptxt== "-1" | resptxt== "Minus 1") &  surveyorg == "Gallup Organization"
replace	resp = 6 if (resptxt== "1" | resptxt== "Plus 1") &  surveyorg == "Gallup Organization"
replace	resp = 7 if (resptxt== "2" | resptxt== "Plus 2") &  surveyorg == "Gallup Organization"
replace	resp = 8 if (resptxt== "3" | resptxt== "Plus 3") &  surveyorg == "Gallup Organization"
replace	resp = 9 if (resptxt== "4" | resptxt== "Plus 4") &  surveyorg == "Gallup Organization"
replace	resp = 10 if (resptxt== "5" | resptxt== "Plus 5") &  surveyorg == "Gallup Organization"

replace	resp = 10 if resptxt== "Favorable--Plus 5" &  surveyorg == "Gallup Organization"
replace	resp = 1 if resptxt== "Unfavorable--Minus five" &  surveyorg == "Gallup Organization"


* 4 scale 
*mostly, very 
replace	resp = 1 if resptxt== "Very unfavorable"   &  surveyorg == "Gallup Organization"
replace resp = 2 if (resptxt== "Mostly unfavorable" | resptxt== "Mostly unfavorable or" ) &  surveyorg == "Gallup Organization"
replace resp = 3 if resptxt== "Mostly favorable"   &  surveyorg == "Gallup Organization"
replace resp = 4 if resptxt== "Very favorable"     &  surveyorg == "Gallup Organization"


*somewhat,very 
replace resp = 2 if resptxt== "Somewhat unfavorable"   &  surveyorg == "Gallup Organization"
replace resp = 3 if resptxt== "Somewhat favorable"  &  surveyorg == "Gallup Organization"


replace	resp = 1 if resptxt== "Very unfavorable (-5, -4)"   &  surveyorg == "Gallup Organization"
replace resp = 2 if resptxt== "Unfavorable (-3, -2, -1)"  &  surveyorg == "Gallup Organization"
replace resp = 3 if resptxt== "Favorable (+1, +2, +3)"   &  surveyorg == "Gallup Organization"
replace resp = 4 if resptxt== "Very favorable (+4, +5)"     &  surveyorg == "Gallup Organization"


*-----USKN /USharris ----------
*123
replace	resp = 1 if resptxt == "Unfavorable"   & orgname =="USHARRIS"
replace	resp = 2 if resptxt == "No opinion at all" & orgname =="USHARRIS"
replace resp = 3 if resptxt == "Favorable"     & orgname =="USHARRIS"


*somewhat,very 
replace resp = 1 if resptxt== "Very unfavorable"   & orgname =="USHARRIS"
replace resp = 2 if resptxt== "Somewhat unfavorable" & orgname =="USHARRIS"
replace resp = 3 if resptxt== "Somewhat favorable"  & orgname =="USHARRIS"
replace resp = 4 if resptxt== "Very favorable"   & orgname =="USHARRIS"


replace resp = 999 if resptxt== "Not familiar/No opinion"
replace resp = 999 if resptxt== "Not sure/Decline"
replace resp = 999 if resptxt== "Not sure/Refused"
replace resp = 999 if resptxt== "Not familiar/Decline"
replace resp = 999 if resptxt== "Not sure"


*1-10
encode  resptxt if questionid == "USKN.201304CCGA.Q01A", g(ecd)
fre ecd 
replace resp = ecd- 7 if questionid == "USKN.201304CCGA.Q01A"
drop ecd

*100 
drop if  orgname =="USKN" & resptxt== "Mean = 40"

replace resp = 1 if resptxt== "0-30 Cold" |  resptxt== "30-0 degrees" | resptxt== "Cool 30-0 degrees" | resptxt=="30-0-Unfavorable"
replace resp = 2 if resptxt== "31-49"     |  resptxt== "49-31 degrees" | resptxt=="49-31"
replace resp = 3 if resptxt== "50 Not particularly warm or cold"   |resptxt== "50 degrees" | resptxt=="Not particularly warm or cold 50 degrees" 
replace resp = 3 if resptxt== "50-Not particularly warm or cold" 

replace resp = 4 if resptxt== "51-75" | resptxt=="75-51 degrees" |  resptxt== "75-51"
replace resp = 5 if resptxt== "76-100 Warm" | resptxt=="100-76 degrees" |  resptxt== "Warm 100-76 degrees" | resptxt=="100-76-Favorable"


*-----the rest-------
replace	resp = 1 if resptxt== "Favorable" & resp==.
replace	resp = 2 if resptxt== "Unfavorable" & resp==.

*mostly, very 
replace	resp = 1 if resptxt== "Very unfavorable"  & resp==.
replace resp = 2 if resptxt== "Mostly unfavorable" & resp==.
replace resp = 3 if resptxt== "Mostly favorable"  & resp==.
replace resp = 4 if resptxt== "Very favorable"   & resp==.
  
replace resp = 2 if resptxt== "Fairly unfavorable" & resp==.
replace resp = 3 if resptxt== "Fairly favorable"  & resp==.

replace resp = 2 if resptxt== "Somewhat unfavorable" & resp==.
replace resp = 3 if resptxt== "Somewhat favorable"  & resp==.

replace	resp = 1 if resptxt== "Very unfavorable (minus 4-5)"  & & resp==.
replace resp = 2 if resptxt== "Unfavorable (minus 1-3" & resp==.
replace resp = 3 if resptxt== "Favorable (plus 1-3)"  & resp==.
replace resp = 4 if resptxt== "Very favorable (plus 4-5)"   & resp==.

*-----------------
replace resp = 999  if resptxt == "Don't know/No opinion"  | resptxt == "Don't know/no opinion" 
replace resp = 999  if resptxt == "No opinion"          
replace resp = 999  if resptxt == "Don't know/No answer" 

replace resp = 999  if resptxt == "Can't rate"  
replace resp = 999 if resptxt== "Don't know/Refused"
replace resp = 999 if resptxt== "Don't know" | resptxt== "Don't Know"

replace resp = 999 if resptxt== "Neutral"  & resp==.
replace resp = 999 if resptxt== "Never heard of"  & resp==.
replace resp = 999 if resptxt== "Never heard"  & resp==.
replace resp = 999 if resptxt== "Never heard of (Vol.)"  & resp==.
replace resp = 999 if resptxt== "Refused"  & resp==.

*--------------------------------------------------------------

order questionid orgname surveyorg resp 

*calcualte scale 
g nomiss= (resp<999)
bysort questionid : egen scale = sum(nomiss)


*define variable 
replace orgname = "USGALLUP" if orgname =="31116081"
replace orgname = "USCBS" if orgname =="USCBSNYT"


sort orgname   // 18 
tostring scale, generate(scale1)
g varname  = orgname +"_"+ scale1


*year 
drop syear
g byear = substr(begdate,-4,.)
g eyear = substr(enddate,-4,.)

g bdate =date(begdate,"MDY")
g edate =date(enddate,"MDY")

 format bdate edate  %td
 destring byear,g(syear)
 

 *half sample size 
g csample = !(subpopulation == "")
g half = regexm(subpopulation, "half")

g       n = samplesize if csample ==0
replace n= samplesize if subpopulation == "See note" 
replace n = int(samplesize*0.5) if half ==1
replace n = int(samplesize *0.66666667)  if subpopulation =="Asked of 2/3 sample"

drop if n==.

destring resppct, g(pct)
bysort questionid : egen tpct=sum(pct) // some 99, 101, 102


*---------- adj var name ------------
*abc USABCWP_2 USABCWP_4  USABC_2
sort varname
replace varname = "ABC" if varname =="USABCWP_2"
replace varname = "ABC" if varname =="USABC_2"

replace resp = 1 if resp ==2 & varname =="USABCWP_4"
replace resp = 2 if resp ==3 & varname =="USABCWP_4"
replace resp = 2 if resp ==4 & varname =="USABCWP_4"

replace varname = "ABC" if varname =="USABCWP_4"

*translantic trends 
replace varname = "USTNS_5" if  questionid=="USMISC.2004GMF.Q08H"

*USHARRIS_5, USKN_5 
replace varname = "USKN_5" if  questionid=="USHARRIS.02CCFRB.R0510N"

* transatlantic trends
g tra = regexm(sourcedoc, "Transatlantic Trends")

replace varname = "TRA_5" if tra==1 & scale == 5
replace varname = "TRA_4" if tra==1 & scale == 4


* adjust 1977 gallup_4 
	replace resp =1 if resp==4 & pct ==23 & varname == "USGALLUP_4" & syear == 1977


*sample mean (excluding 999 )
	g nresp = n*pct/100   					//number of respondents 
	g adj= n - nresp if resp == 999         // adj sample size 
	bysort questionid :  egen adjsize = sum(adj) 
	replace adjsize =n if adjsize==0
	
	g tval=nresp * resp if resp  != 999
	bysort questionid : egen tq= sum(tval)
	g meanval= tq/adjsize 
	g dif= scale -meanval
	

keep questionid resp pct enddate scale varname syear n nresp adjsize meanval
save agg_raw.dta, replace 


*------------------------------------------------
use agg_raw.dta, clear 
*favorable 
	drop if  scale==2 &   resp ==1 
	drop if  scale==3 &  inrange(resp,1,2)
	drop if  scale==4 &  inrange(resp,1,2)
	drop if  scale==5 &  inrange(resp,1,3)
	drop if  scale==9 &  inrange(resp,1,5)
	drop if  scale==10 & inrange(resp,1,5)
	drop if  resp== 999

	bysort questionid : egen fav=sum(pct) 

keep questionid enddate syear fav varname n
duplicates drop 

tempfile fav
save `fav.dta', replace 


*unfav
use `agg.dta',clear 
	drop if  scale==2 &  resp ==2 
	drop if  scale==3 &  inrange(resp,2,3)
	drop if  scale==4 &  inrange(resp,3,4)
	drop if  scale==5 &  inrange(resp,3,5)
	drop if  scale==9 &  inrange(resp,5,9)
	drop if  scale==10 & inrange(resp,5,10)
	drop if  resp== 999

	bysort questionid : egen unfav=sum(pct) 
keep questionid  enddate syear unfav varname meanval scale
duplicates drop 


merge 1:1 questionid using `fav.dta'
drop _merge

save agg_cleaned.dta, replace 


*inspect 
// use  agg_cleaned.dta, clear 
// keep if varname == "TRA_5" & syear ==2011 |  varname == "USORC_4" & syear ==1987 |  varname == "USPSRA_4" & syear ==1998

*----append pew and GSS-------
use pew_us.dta,clear
replace opc_4p =. if opc_4p ==999

g fav  = (inrange(opc_4p, 3,4))
	g unfav = (inrange(opc_4p, 1,2))
	g id = _n

	collapse (count) id (mean)fav unfav opc_4p  [pweight=wt] , by (syear)
	g edate =mdy(1,1,syear)  
	g n= int(id)
	g varname ="PEW_4"
	replace fav =fav*100
	replace unfav =unfav*100

	rename opc_4p meanval 
	drop id 
	drop if fav ==0
	
tempfile pew
save `pew.dta', replace



use GSS_China.dta, clear
	 keep if inlist(year, 1974,1975,1977,1982,1983,1985,1986,1988,1989,1990,1991,1993)
	 clonevar syear =year 
	 recode china (0=5) (1=4)(2=3)(3=2)(4=1)(5=-1)(6=-2)(7=-3)(8=-4)(9=-5) (.d= 999),gen(opc_10pn)
	 *10
	 recode china (0=10) (1=9)(2=8)(3=7)(4=6)(5=5)(6=4)(7=3)(8=2)(9=1) (.d= 999),gen(opc_10p)
	 
	 clonevar wt = wtssall
	 keep syear opc_10pn opc_10p wt

	g fav = (inrange(opc_10pn, 0,5))
	g unfav = (inrange(opc_10pn, -5,-1))
	g id =_n
	
	replace opc_10p =. if opc_10p ==999

	
	collapse (count) id (mean)fav unfav opc_10p [pweight=wt] , by (syear)
	g edate =mdy(1,1,syear)  
	g n= int(id)
	g varname ="GSS_10"
	replace fav =fav*100
	replace unfav= unfav*100

	rename opc_10p meanval 
	
append using `pew.dta'
append using agg_cleaned.dta

	g date= edate
	drop if fav ==0

drop if syear ==1955 
sort syear


drop if n==.
keep varname fav unfav date n syear meanval

// keep int at least 2yrs 
sort varname syear 
by varname : g nyr=_N
drop if nyr == 1            // 6 dropped 


*---weighted average---------
// bysort syear : g nq = _N
//
// 	sort syear
// 	g wfav=fav*n 
// 	by syear: egen  y_n= sum(n)
// 	g fav_w = wfav / y_n
//
// drop wfav




// sort syear
// twoway line  nq syear,  ///
// color(black) title(Distribution of survey data over time) ytitle("number of surveys") xtitle(Year) ///
// 	   xlabel(1970(2)2020, angle(90))
//
// graph export "$image\survey.png",replace 


*-------small sample with large sample-----

use "dra_agg", clear 
* new gss and gallup : demean 
 // mean of gallup 4 : 2. 39 

g       newmean = meanval - 2.39 if varname =="GSS_10"
replace newmean = meanval - 2.39 if varname =="USGALLUP_10"
replace newmean = meanval  if newmean ==.


// 	g fav = value*100 
// 	sort syear var 
// 	g id =_n
//	
// tempfile dra
// save `dra.dta', replace 
//
// use "dra_n.dta", clear 
// 	g unfav = value*100 
// 	sort syear var 
// 	g id =_n
//	
// merge 1:1 id using `dra.dta'
// 	drop _merge
// 	g version = "indi"
// 	rename var varname 
//	
// append using "dra_agg.dta"
// 	replace version = "agg" if version == ""

*use dra_agg, clear 	
	
#delimit ;
twoway	(connected meanval syear if varname =="GSS_10" )  
	   (connected meanval syear if varname =="USGALLUP_10")
	   (connected meanval syear if varname =="PEW_4"      )
	    (connected meanval syear if varname =="USGALLUP_4" )
        (scatter meanval syear if varname =="TRA_4")
		(scatter meanval syear if varname =="USORC_4")
		(scatter meanval syear if varname =="USPSRA_4")
		(scatter meanval syear if varname =="USZOGBY_4")		
		(connected meanval syear if varname =="TRA_5")
		(connected meanval syear if varname =="USKN_5")
		(connected meanval syear if varname =="USCBS_3")
		(connected meanval syear if varname =="ABC")
	   	   , 
	   title(" 10 scale and 4 scale")
	   ytitle("mean") 
	   xtitle("year") 
	   xlabel(1970(2)2018, angle(90))
	   legend(col(1) 
			 order(1 "GSS"
				   2 "Gallup (10 scale)"
				   3 "PEW" 
				   4 "Gallup (4 scale)" 
				   5 "Trans Atlantic Trends (4 scale)"
				   6 "NORC"
				   7 "USPSRA"
				   8 "USZOGBY_4"
				   9 "Trans Atlantic Trends (5 scale)"
				   10 "USKN_5"
				   11 "USCBS_3"
				   12 "ABC"
				   ))
				  ;
#delimit cr	   

*-------10 scale and 4 scale-----

#delimit ;
twoway	(connected meanval syear if varname =="GSS_10" )  
	   (connected meanval syear if varname =="USGALLUP_10")
	   (connected meanval syear if varname =="PEW_4"      )
	    (connected meanval syear if varname =="USGALLUP_4" )
        (connected meanval syear if varname =="TRA_4")
		(connected meanval syear if varname =="USORC_4")
		(connected meanval syear if varname =="USPSRA_4")
		(connected meanval syear if varname =="USZOGBY_4")		

	   	   , 
	   title("10 scale and 4 scale")
	   ytitle("mean") 
	   xtitle("year") 
	   xlabel(1970(2)2018, angle(90)) ylab(0(2)8)
	   legend(col(1) 
			 order(1 "GSS"
				   2 "Gallup (10 scale)"
				   3 "PEW" 
				   4 "Gallup (4 scale)" 
				   5 "Trans Atlantic Trends (4 scale)"
				   6 "NORC"
				   7 "USPSRA"
				   8 "USZOGBY_4"
				   ))
				  ;
#delimit cr	   

graph export "$image\mean_10_4.png",replace 




#delimit ;
twoway	(connected newmean syear if varname =="GSS_10" )  
	   (connected newmean syear if varname =="USGALLUP_10")
	   (connected newmean syear if varname =="PEW_4"      )
	    (connected newmean syear if varname =="USGALLUP_4" )
        (connected newmean syear if varname =="TRA_4")
		(connected newmean syear if varname =="USORC_4")
		(connected newmean syear if varname =="USPSRA_4")
		(connected newmean syear if varname =="USZOGBY_4")		

	   	   , 
	   title("10 scale and 4 scale")
	   ytitle("mean") 
	   xtitle("year") 
	   xlabel(1970(2)2018, angle(90)) ylab(0(2)8)
	   legend(col(1) 
			 order(1 "GSS"
				   2 "Gallup (10 scale)"
				   3 "PEW" 
				   4 "Gallup (4 scale)" 
				   5 "Trans Atlantic Trends (4 scale)"
				   6 "NORC"
				   7 "USPSRA"
				   8 "USZOGBY_4"
				   ))
				  ;
#delimit cr	   

graph export "$image\mean_10_4_demean.png",replace 

*the most consistent 4---

#delimit ;
twoway	(connected meanval syear if varname =="USGALLUP_4" )
        (connected meanval syear if varname =="PEW_4")
		(connected meanval syear if varname =="USZOGBY_4")		

	   	   , 
	   title("Attitude toward China (mean)")
	   ytitle("mean") 
	   xtitle("year") 
	   xlabel(1970(2)2018, angle(90)) ylab(2(1)4)
	   legend(col(1) 
			 order(1 "USGALLUP_4"
				   2 "PEW_4"
				   3 "USZOGBY_4" 
				   ))
				  ;
#delimit cr	   

graph export "$image\mean_10_4.png",replace 


drop if varname =="TRA_5" & syear ==2008

sort syear 	
#delimit ;
twoway	(connected meanval syear if varname =="TRA_5")
		(connected meanval syear if varname =="USKN_5")
		(connected meanval syear if varname =="USCBS_3")
		(connected meanval syear if varname =="ABC")
	   	   , 
	   title("Attitude toward China (mean)")
	   ytitle("mean") 
	   xtitle("year") 
	   xlabel(1970(2)2018, angle(90))
	   legend(col(1) 
			 order(1 "Trans Atlantic Trends (5 scale)"
				   2 "USKN_5"
				   3 "USCBS_3"
				   4 "ABC"
				   ))
				  ;
#delimit cr	   

// #delimit ;
// twoway (connected fav syear if varname =="tra")  
// 	   (connected fav syear if varname =="TRA_5")  
// 	   (connected fav syear if varname =="TRA_4")  
// 	   	   , 
// 	   title("% Favorable attitudes toward China")
// 	   ytitle("%") 
// 	   xtitle("year") 
// 	   xlabel(1970(2)2018, angle(90))
// 	   ylabel(0(20)80)
// 	   legend(col(1) 
// 			 order(1 "individual" 
// 				   2 "aggregate 5" 
// 				   3 "agg 4"
// 				   ))
// 				  ;
// #delimit cr	   

* gallup : gallup 10 agg missing 1987 
* chicago : chicago agg missing 2013
* individual trans atlantic trends has more observations 


*------compare with raw data-------------------
import delimited C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra_agg.Csv, clear 
rename v1 syear
rename v2 mood 
drop if syear <1975

merge 1:m syear using  dra_agg.dta
drop if syear <1975


sort syear 
twoway (line mood syear)  ///
       (scatter fav syear, mcolor(%50)), ///
	   title("Favorable opionon toward China") ytitle("%") legend(col(1) ring(0) order(1 "Dyad Ratio Estimates" 2 "Survey margins")) 

graph export "$image\dra_agg.png",replace 

	   
* unfav
import delimited C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra_agg_n.Csv, clear 
rename v1 syear
rename v2 mood 
drop if syear <1975

sort syear 
twoway line mood syear

merge 1:m syear using  dra_agg.dta
drop if syear <1975


sort syear 
twoway (line mood syear)  ///
       (scatter unfav syear, mcolor(%50)), ///
	   title("Unfavorable opionon toward China") ytitle("%") ylab(0(20)80) legend(col(1) ring(0) order(1 "Dyad Ratio Estimates" 2 "Survey margins")) 	   
graph export "$image\dra_agg_n.png",replace 
	   
