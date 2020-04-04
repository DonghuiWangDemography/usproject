*code revised for publication 
*Data cleaning 
*created on 03242020
*adapted from agg.do and part of scaling do

*created on 04022020, change codings of ABC and CBS


*================Roper DATA===================== 
// cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"
// global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 
// global ga "C:\Users\donghuiw\Dropbox\Website\ThirdPartySurveys\GALLUP\data" 

//mac 
cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"
global image "/Users/donghui/Dropbox/Website/US_project/image"
global ga "/Users/donghui/Dropbox/Website/ThirdPartySurveys/GALLUP/data"


//global cleaned "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"

//import delimited C:\Users\donghuiw\Dropbox\Website\US_project\agg_data\Roper_117q_12102019.csv,clear 

import delimited /Users/donghui/Dropbox/Website/US_project/agg_data/Roper_117q_12102019.csv,clear 


* drop inapp questionaries 
drop if questionid == "Number of items downloaded: " | questionid =="USGALLUP.11CHINA1.R02"  // china daily only interviewed once
drop if surveysponsor == "Pew Global Attitudes Project"  //pew cleaned in somwhere
drop if questionid=="USTNS.03TRANS.R08I2"                // pct missing 
drop if questionid== "USGALLUP.90CFRP.R18O"             // pct missing 
drop if questionid== "USHARRIS.09COMM100.R0835"       // ppl of china 
* drop two strange years
drop if questionid == "USGALLUP.062898.R5"   // 
drop if questionid == "USGALLUP.03FEB3.R25C"


drop if  resppct  == "*"  // less than 5 %
drop questionnote

order questionid orgname surveyorg  resptxt   sourcedoc questiontxt resppct

// USABCWP.011911.R31
// USABCWP.021412.R01

// 	keep if surveyorg == "ABC News" |surveyorg ==  "ABC News/Washington Post"
	
//     sort questionid
// 	keep questionid orgname surveyorg resptxt questiontxt resppct syear enddate
// 	export delimited using "/Users/donghui/Dropbox/Website/US_project/cleaned_data/ABCWP_04042020.csv", replace

*--------------------------
* 20 unique orgname 
*recode reponses 
	sort surveyorg  questionid resptxt questionid

* 2 scale : 1 2 :ABC (don't know and no opinion excluded)
	g 		resp = 2 if resptxt == "Favorable"        &       ( surveyorg == "ABC News" |  surveyorg ==  "ABC News/Washington Post")
	replace	resp = 1 if resptxt == "Unfavorable"      &       ( surveyorg == "ABC News" |  surveyorg ==  "ABC News/Washington Post")
	

	
*4 scale ABCWP 1234
	replace	resp = 1 if (resptxt == "Very unfavorable"   | resptxt == "Strongly unfavorable" )  &      surveyorg ==  "ABC News/Washington Post"
	replace	resp = 2 if resptxt == "Somewhat unfavorable"  &   surveyorg ==  "ABC News/Washington Post"

	replace	resp = 3 if resptxt == "Somewhat favorable"  &  surveyorg ==  "ABC News/Washington Post"
	replace	resp = 4 if (resptxt == "Very favorable"  | resptxt == "Strongly favorable" )   &      surveyorg ==  "ABC News/Washington Post"

* CBS : 3 scale :1 2 3 
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

*translantic trends 
	replace varname = "USTNS_5" if  questionid=="USMISC.2004GMF.Q08H"

*USHARRIS_5, USKN_5 

// *USKN10 -> USKN5: bx they were both asked in a 0 -100 scale 
	recode resp (1/2=1)(3/4=2)(5/6=3)(7/8=4)(9/10=5) if questionid =="USKN.201304CCGA.Q01A"
	replace varname ="USKN_5" if  questionid =="USKN.201304CCGA.Q01A"
	replace scale=5 if questionid =="USKN.201304CCGA.Q01A"

	
	bysort resp : egen respct_new=total(pct) if questionid=="USKN.201304CCGA.Q01A"
	list resp pct respct_new if questionid=="USKN.201304CCGA.Q01A"
	replace pct = respct_new if  questionid=="USKN.201304CCGA.Q01A"
	drop respct_new
	list resp pct if  questionid=="USKN.201304CCGA.Q01A"
	
	
	*duplicates drop 
	
* transatlantic trends
	g tra = regexm(sourcedoc, "Transatlantic Trends")

	replace varname = "TRA_5" if tra==1 & scale == 5
	replace varname = "TRA_4" if tra==1 & scale == 4


* adjust 1977 gallup_4 
	replace resp =1 if resp==4 & pct ==23 & varname == "USGALLUP_4" & syear == 1977

* 	2015 two gallup with diff question id but same marginal  distribution, drop one 
	drop if questionid=="USGALLUP.022615.R18C"

	
*sample mean (excluding 999 )
	g nresp = n*pct/100   					//number of respondents 
	g adj= n - nresp if resp == 999         // adj sample size 
	bysort questionid :  egen adjsize = sum(adj) 
	replace adjsize =n if adjsize==0
	
	g tval=nresp * resp if resp  != 999
	bysort questionid : egen tq= sum(tval)
	g meanval= tq/adjsize 
	g dif= scale -meanval
	

keep questionid resp pct enddate scale varname syear n nresp adjsize meanval questiontxt intmethod

 duplicates drop // adjusted USKN10
 
save agg_raw.dta, replace 


	*question wording sample 
	keep varname questiontxt 
	duplicates drop 
	putexcel set "/Users/donghui/Dropbox/Website/US_project/cleaned_data/qwording.xlsx"


*=============GSS and PEW=====================

*---------ignore 9999 (dk)--------------
use agg_raw.dta,clear 
	drop if resp == 999

	drop adjsize
	bysort questionid: egen adjsize = total(nresp)

	g edate =date(enddate,"MDY")
	drop enddate
	rename edate enddate 

	replace pct = nresp/adjsize 
	
	
	*cpt
	sort questionid resp 
	by questionid : g rid=_n
	bysort questionid (rid) : gen cpt = sum(pct)
	by questionid: g total=cpt[_N]
	drop n 
	rename adjsize n
	duplicates drop

	
keep resp questionid resp pct enddate scale varname syear n cpt nresp meanval
tempfile agg
save `agg.dta', replace 
	
use pew_us.dta,clear
	*questionid resp pct enddate scale varname syear n nresp
	drop if syear == 2014
	drop if opc_4p ==999
	
	g id=_n
	tab opc_4p, g(r)
	collapse (count)id (mean)r1 r2 r3 r4 opc_4p [pweight=wt] ,  by(syear)
	rename id n 
	rename opc_4p meanval 

	*comulative distribution 
	g cr1 = r1
	g cr2 = r1 + r2
	g cr3 = cr2 +r3
	g cr4 = cr3 +r4

	expand 4

	sort syear 
	by  syear : g resp=_n

	g 		pct = r1 if resp==1
	replace pct = r2 if resp==2
	replace pct = r3 if resp==3
	replace pct = r4 if resp==4

	g 		cpt = cr1 if resp==1
	replace cpt = cr2 if resp==2
	replace cpt = cr3 if resp==3
	replace cpt = cr4 if resp==4

	
	g scale = 4
	g nresp = pct*n
	g varname = "PEW"
	egen questionid= concat(varname syear)
	
	*create a month and year 
	g month = 1 
	g date= 1

	g enddate = mdy(month,date,syear)
	
keep questionid varname syear n resp nresp pct cpt scale meanval enddate
tempfile pew 
save `pew.dta', replace 


*gss 
use GSS_China.dta,clear
	drop if china ==.d 
		
	drop id 
	keep if inlist(year, 1974,1975,1977,1982,1983,1985,1986,1988,1989,1990,1991,1993)  //1994 is very strange
	clonevar syear =year 
	g id=_n
	clonevar wt = wtssall

	recode china (0=10) (1=9)(2=8)(3=7)(4=6)(5=5)(6=4)(7=3)(8=2)(9=1) (.d= 999),gen(opc_10p)
	tab opc_10p , g(r)

     *end month and date
	bysort syear: egen emonth=max(month)
	bysort syear: egen edate=max(date)
	
	
	collapse (count)id (mean)r1-r10 china opc_10p emonth edate[pweight=wt] ,  by(syear)
	rename id n 

	rename opc_10p meanval 
	
	
	*cumulative distribution 
	g cr1= r1
	forval i=2/10 {
	 local j= `i'-1
	g cr`i'= cr`j'+ r`i'
	}
	expand 10
	sort syear 
	by syear : g resp = _n

	g pct =. 
	g cpt =.
	forval i=1/10 {
	replace pct=r`i' if resp==`i'
	replace cpt =cr`i' if resp ==`i'
	}

	g scale = 10
	g nresp = pct*n

	g varname = "GSS"
	egen questionid= concat(varname syear)
	
	*enddate
	replace edate = 30 if emonth ==4  & edate==31 
	
	g enddate = mdy(emonth,edate, syear)

keep questionid varname syear n resp nresp pct cpt scale meanval enddate


append using `pew.dta'
append using `agg.dta' 

sort syear questionid resp

	g sid=_n

	format  enddate  %td
	drop if syear ==1955
	
	encode questionid, g(qid)

* number of running years 
	unique(syear), by(varname) gen(nyr)
	bysort  varname : egen nyear=max(nyr)

* number of unique surveys 
	unique (questionid), by(syear) gen(ns)
	bysort syear: egen nsurvey=max(ns)


	drop if nyear==1
	drop  ns  nyr

save scaling.dta, replace 
