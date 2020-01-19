*merge data , descriptive graphs 

// ssc install grstyle
// ssc install tabplot 

*created in 12/17/2019
* prior do file agg.do 

// cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"
// global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 


// cd "C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data"   laptop 
// global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"

cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"  // mac 
global image "/Users/donghui/Dropbox/Website/US_project/image"

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


*----------------------graph---------------

use scaling.dta, clear
	
	*Fig 1 cross tab the avaiability 
	tabplot syear varname,subtitle("") height(1) xtitle(survey) 
//	graph save Graph  "$image/survey.gph",replace 
// 	graph use   "$image/survey.gph"
// 	graph export "$image/survey.png",replace 
	encode varname,gen(var)
	*re-order
	
	
	*mid-point 
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 	
	g mid = round(midpoint*100 , 0.01) 
	
		
	 #delimit ;
	recode var (3 =1 "PEW") 
			   (8 =2 "USGALLUP_4")
			   (4 =3 "TRA_4")
			   (10=4 "USORC_4")
			   (11=5  "USPSRA_4")
			   (12=6 "USZOGBY_4")
			   (2 =7 "GSS")
			   (7= 8 "USGALLUP_10")
			   (1=9 "ABC")
			   (6=10 "USCBS_3")
			   (4=11 "TRA_5")
			   (9=12 "USKN_5")
			   ,
	gen(varid);
	#delimit cr	  

	
// 	grstyle init
// 	grstyle set lpattern	
	
	la var syear "year"
	la var meanval "Mean"
	sort syear
	twoway connected meanval syear, by(varid) col(3) ylab(0(2)10)
	graph export  "$image/mean.png" , replace 
	
	
	sort syear
	 #delimit ;
	twoway (connected meanval syear if varname =="PEW")
		   (connected meanval syear if varname=="USGALLUP_4")
		   ,
		 title("2 scales")
		 ytitle(Mean)
		 xtitle (Year)
		 ylab(1(1)4)
		  legend(col(1) 
			 order(1 "PEW"
				   2 "Gallup"				   
				   ))
				  ;
		#delimit cr	 
		
	*Fig 2 
	* 3
// 	grstyle init
// 	grstyle set lpattern

	
	 #delimit ;

	twoway (connected meanval syear if varname =="ABC")
		   (connected meanval syear if varname=="USCBS_3")
		   ,
		 title("2 scales")
		 ytitle(Mean)
		 xtitle (Year)
		 ylab(1(1)3)
		  legend(col(1) 
			 order(1 "ABC"
				   2 "USCBS_3"				   
				   ))
				  ;
		#delimit cr	  
		
		graph save Graph "$image\s3.gph", replace 


	#delimit ;
	twoway	(connected meanval syear if varname =="PEW"      )
			(connected meanval syear if varname =="USGALLUP_4" )
			(connected meanval syear if varname =="TRA_4")
			(connected meanval syear if varname =="USORC_4" & syear > 1990)
			(connected meanval syear if varname =="USPSRA_4")
			(connected meanval syear if varname =="USZOGBY_4")		
			   , 
		   title("4 scale")
		   ytitle("mean") 
		   xtitle("year") 
		   ylab(1(1)4)
		   legend(col(1) 				 
				 order( 1 "PEW" 
					   2 "Gallup" 
					   3 "Trans Atlantic Trends"
					   4 "NORC"
					   5 "USPSRA"
					   6 "USZOGBY"
					   ))
					  ;
	#delimit cr	   
	graph save Graph "$image\s4.gph", replace 

	
	
	#delimit ;
	twoway	(connected meanval syear if varname =="TRA_5")
			(connected meanval syear if varname =="USKN_5")
			   , 
		   title("5 scale")
		   ytitle("mean") 
		   xtitle("year") 
		   ylab(1(1)5)
		   legend(col(1) 
				 order(1 "TRA_5"
					   2 "USKN_5"
					   ))
					  ;
	#delimit cr	   
	graph save Graph "$image\s5.gph", replace 


   #delimit ;
	twoway	(connected meanval syear if varname =="GSS")
			(connected meanval syear if varname =="USGALLUP_10")
			   , 
		   title("10 scale")
		   ytitle("mean") 
		   xtitle("year") 
		   ylab(1(1)10)
		   legend(col(1) 
				 order(1 "GSS"
					   2 "USGALLUP_10"
					   ))
					  ;
	#delimit cr	   
	graph save Graph "$image\s10.gph", replace 

	graph combine  "$image\s3.gph" "$image\s4.gph" "$image\s5.gph"  "$image\s10.gph" 

	
	
	sort syear resp
	list syear questionid resp pct if varname=="USORC_4"
	
	
* experiment with midpoint 
	

	
	
	
	
	
	
	
	
	
	
	
	
	
*=========No longer useful==============
use scaling.dta, clear
*prepare for optimization 
	recode resp(1=-5)(2=-4)(3=-1)(4=-2)(5=-1)(6=1)(7=2)(8=3)(9=4)(10=5) if varname =="GSS"
	
g c= -6 if varname == "GSS"
replace c=0 if c==.

g s= scale 

keep syear resp nresp  varname enddate c s 

*export delimited using "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\optim_v2.csv", replace

export delimited using "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\raw_agg_12302019.csv", replace

use scaling.dta , clear  

keep if syear == 1989
sort resp
 
 #delimit ;
 twoway (connected cpt resp if varname == "GSS")  
		(connected cpt resp if varname == "USCAMREP_9" )  
		(connected cpt resp if questionid == "USGALLUP.040689.R1D")
		(connected cpt resp if questionid == "USGALLUP.081689.R02A") 
		(connected cpt resp if varname == "USLAT_4" ) 
		(connected cpt resp if varname == "USCBS_3" ) 
		(connected cpt resp if questionid == "USABCWP.89JAPN.R35E")
		(connected cpt resp if questionid == "USABCWP.89APR.R41G") 
          , 
	   title("8 surveys in 1989")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1) 
			 order(1 "GSS"
				   2 "Cambridge Reports"
				   3 "Gallup(March)" 
				   4 "Gallup(Aug)"
				   5 "Trans Atlantic Trends"
				   6 "CBS"
				   7 "ABC(Jan)"
				   8 "ABC(Apr)"
				   ))
				  ;
#delimit cr	   

graph export "$image\dis_1989.png",replace 


// replace resp = resp/10 
// sort resp
// #delimit ;
//  twoway (connected cpt resp if varname == "GSS")  
//         (function ibeta(2.42,  2.14, x), range(0.1 1)) 
// 		,
// 		 xtitle("scale") 
// 	     legend(col(1) 
// 			 order(1 "GSS" 2 "cdf of best fit beta(alfa = 2.42, beta= 2.14)")
// 			 ring(0))
//           ;
// #delimit cr	 
//
// graph save  "$image\beta_1989.gph", replace 
//
// graph use "$image\beta_1989.gph"
//
// graph export "$image\beta_1989.png", replace 




*-----test 1989-------------
use scaling.dta , clear  
keep if syear == 1989 
replace resp= resp*10
*GSS: 1974,1975,1977,1982,1983,1985,1986,1988,1989,1990,1991,1993
*define boundaries based on the cumulative distribution 
sort questionid resp

forval i=1/100 {
g cut`i'=.
replace cut`i' =cpt if resp==`i' & varname == "GSS" 
egen cut`i'_rf= max(cut`i')
g dif`i'= abs(cut`i'_rf -cpt)
drop cut`i'
drop cut`i'_rf
}

egen mindif=rowmin(dif*)

g newscale =.
forval i = 1/100 {
replace newscale = `i' if dif`i' == mindif 
}
drop dif1-dif100


#delimit ;
 twoway (connected cpt newscale if varname == "GSS")  
		(connected cpt newscale if varname == "USCAMREP_9" )  
		(connected cpt newscale if questionid == "USGALLUP.040689.R1D")
		(connected cpt newscale if questionid == "USGALLUP.081689.R02A") 
		(connected cpt newscale if varname == "USLAT_4" ) 
		(connected cpt newscale if varname == "USCBS_3" ) 
		(connected cpt newscale if questionid == "USABCWP.89JAPN.R35E")
		(connected cpt newscale if questionid == "USABCWP.89APR.R41G") 
          , 
	   title("8 surveys in 1989 (after scaling)")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1) 
			 order(1 "GSS"
				   2 "Cambridge Reports"
				   3 "Gallup(March)" 
				   4 "Gallup(Aug)"
				   5 "Trans Atlantic Trends"
				   6 "CBS"
				   7 "ABC(Jan)"
				   8 "ABC(Apr)"
				   ))
				  ;
#delimit cr	  
graph export "$image\dis_1989_after.png",replace 



*----------do the same thing for the rest of the GSS----------
* 1977, 1983, 1985 , 1987, 1989, 1990, 1991, 1993 

use scaling.dta , clear  

local gss "1977 1983 1985  1989  1990 1991 1993"
foreach x of local gss {
 use scaling.dta , clear  
	keep if syear == `x' 
	
	sort questionid resp

	forval i=1/10 {
	g cut`i'=.
	replace cut`i' =cpt if resp==`i' & varname == "GSS" 
	egen cut`i'_rf= max(cut`i')
	g dif`i'= abs(cut`i'_rf -cpt)
	drop cut`i'
	drop cut`i'_rf
	}

	egen mindif=rowmin(dif*)

	g newscale =.
	forval i = 1/10 {
	replace newscale = `i' if dif`i' == mindif 
	
	}
drop dif1-dif10
keep sid syear questionid newscale 
tempfile y`x'
save `y`x'', replace 
}


append using `y1977'
append using `y1983'
append using `y1985'
append using `y1989'
append using `y1990'
append using `y1991'

merge 1:1 sid using scaling.dta 

sort varname syear
save ref_gss, replace 



 
 
 
*-------graph the rest--------------
* 1977 
use ref_gss, clear
keep if syear == 1977
sort newscale
#delimit ;
 twoway (connected cpt newscale if varname == "GSS")  
		(connected cpt newscale if varname == "USGALLUP_4")  
         , 
	   title("1977")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1) 
			ring(0)
			 order(1 "GSS"
				   2 "Gallup_4"
			       ))
				  ;
#delimit cr	  
graph save Graph g1977.gph, replace 

*1983
use ref_gss, clear
keep if syear == 1983

sort newscale
#delimit ;
 twoway (connected cpt newscale if varname == "GSS")  
		(connected cpt newscale if varname == "USGALLUP_10")  
         , 
	   title("1983")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1) 
			ring(0)
			 order(1 "GSS"
				   2 "USGALLUP_10"
				   ))
				  ;
#delimit cr	 
graph save Graph g1983.gph, replace 


*1985
use ref_gss, clear
keep if syear == 1985

sort newscale
#delimit ;
 twoway (connected cpt newscale if varname == "GSS")  
		(connected cpt newscale if varname == "USGALLUP_4")  
         , 
	   title("1985")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1) 
			ring(0)
			 order(1 "GSS"
				   2 "USGALLUP_4"
				   ))
				  ;
#delimit cr	 
graph save Graph g1985.gph, replace 




*1990
use ref_gss, clear
keep if syear == 1990 

sort newscale
#delimit ;
 twoway (connected cpt newscale if varname == "GSS")  
		(connected cpt newscale if varname == "ABC")  
		(connected cpt newscale if varname == "USPSRA_4")  
         , 
	   title("1990")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1)
			ring(0)
			 order(1 "GSS"
				   2 "ABC"
				   3 "USPSRA_4"
				   ))
				  ;
#delimit cr	 

graph save Graph g1990.gph, replace 

*1991
use ref_gss, clear
keep if syear == 1991

sort newscale
#delimit ;
 twoway (connected cpt newscale if varname == "GSS")  
		(connected cpt newscale if varname == "USGALLUP_4")  
         , 
	   title("1991")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1) 
			  ring(0)
			 order(1 "GSS"
				   2 "USGALLUP_4"
				   ))
				  ;
#delimit cr	 

graph save Graph g1991.gph, replace 

*1993
use ref_gss, clear
keep if syear == 1993

sort newscale
#delimit ;
 twoway (connected cpt newscale if varname == "GSS")  
		(connected cpt newscale if varname == "USGALLUP_4")  
         , 
	   title("1993")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1) 
			ring(0)
			 order(1 "GSS"
				   2 "USGALLUP_4"
				   ))
				  ;
#delimit cr	 
graph save Graph g1993.gph, replace 


graph combine  g1977.gph g1983.gph g1985.gph g1990.gph g1991.gph g1993.gph
graph export "$image\gss_ref_panel.png",replace 



*------overlapping assumption  --------
use ref_gss, clear
keep if inlist(syear,1977, 1983, 1985, 1989, 1990, 1991, 1993)
keep if varname =="USGALLUP_4"

* graph by year 

sort questionid newscale 
#delimit ;
twoway (connected resp newscale  if syear == 1977)  
	   (connected resp newscale  if syear == 1985) 
	   (connected resp newscale  if questionid == "USGALLUP.040689.R1D")  
	   (connected resp newscale  if questionid == "USGALLUP.081689.R02A")  
	   (connected resp newscale  if syear == 1991)
	   (connected resp newscale  if syear == 1993)
	   ,
	   title("Gallup(4) to GSS")
	   legend(col(1) 
	   	order ( 1 "1977"
		      2 "1985"
			  3 "1989 march"
			  4 "1989 aug"
			  5 "1991"
			 6  "1993"
				   ))
				  ;

#delimit cr	

*-------calculate mean------------

	g tval=nresp * newscale 
	bysort questionid : egen tq= sum(tval)
	g newmean= tq/n
sort syear

#delimit ;
twoway	(connected meanval syear if varname =="GSS" ) 
	    (connected newmean syear if varname =="USGALLUP_4") 
	    (connected newmean syear if varname =="ABC") 
	   	   , 
	   title("mean")
	   ytitle("mean") 
	   xtitle("year") 
	   ylab(0/10)
	   legend(col(1) 
			 order(1 "GSS"
				   2 "USGALLUP_4"
				   3 "ABC"
				   ))
				  ;
#delimit cr	
graph export "$image\gss_ref_newmean.png",replace 

use ref_gss, clear


*alfa  1.827513 , beta 16.263349
*zscore 2.42 , 2.14  
*----------------------------------
*betafit pct if  varname =="GSS" |  varname =="USGALLUP_10"

*==============================
*mid point z score 
*1977- 1993 ref : GSS 

use scaling.dta, clear
drop if syear == 1955

*midpoint 
sort  questionid resp  
bysort questionid : g midpoint = pct/2 +cpt[_n-1]
replace  midpoint = pct/2 if midpoint ==. 


*use midpoint to strech data
local gss "1977 1983 1985  1989  1990 1991 1993"
foreach x of local gss {
 use scaling.dta , clear 
 
	*mid-point 
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 
	 
	keep if syear == `x' 
	
	sort questionid resp

	forval i=1/10 {
	g cut`i'=.
	replace cut`i' =midpoint if resp==`i' & varname == "GSS" 
	egen cut`i'_rf= max(cut`i')
	g dif`i'= abs(cut`i'_rf -midpoint)
	drop cut`i'
	drop cut`i'_rf
	}

	egen mindif=rowmin(dif*)

	g newscale =.
	forval i = 1/10 {
	replace newscale = `i' if dif`i' == mindif 
	
	}
drop dif1-dif10
keep sid syear questionid newscale 
tempfile y`x'
save `y`x'', replace 
}

append using `y1977'
append using `y1983'
append using `y1985'
append using `y1989'
append using `y1990'
append using `y1991'

merge 1:1 sid using scaling.dta 

sort  questionid resp  
bysort questionid : g midpoint = pct/2 +cpt[_n-1]
replace  midpoint = pct/2 if midpoint ==. 

g   ref_gss=1   


sort varname syear
save ref_gss_midpoint, replace 

* graph 
use ref_gss_midpoint , clear 
keep if syear == 1989
sort  newscale 
#delimit ;
 twoway (connected midpoint newscale if varname == "GSS")  
		(connected midpoint newscale if varname == "USCAMREP_9" )  
		(connected midpoint newscale if questionid == "USGALLUP.040689.R1D")
		(connected midpoint newscale if questionid == "USGALLUP.081689.R02A") 
		(connected midpoint newscale if varname == "USLAT_4" ) 
		(connected midpoint newscale if varname == "USCBS_3" ) 
		(connected midpoint newscale if questionid == "USABCWP.89JAPN.R35E")
		(connected midpoint newscale if questionid == "USABCWP.89APR.R41G") 
          , 
	   title("8 surveys in 1989 (after scaling)")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1) 
			 order(1 "GSS"
				   2 "Cambridge Reports"
				   3 "Gallup(March)" 
				   4 "Gallup(Aug)"
				   5 "Trans Atlantic Trends"
				   6 "CBS"
				   7 "ABC(Jan)"
				   8 "ABC(Apr)"
				   ))
				  ;
#delimit cr	  


use ref_gss_midpoint , clear


*------overlapping assumption  --------
use ref_gss_midpoint , clear

// keep if inlist(syear,1977, 1983, 1985, 1989, 1990, 1991, 1993)
// keep if varname =="USGALLUP_4"
//
// * graph by year 
//
// sort questionid resp newscale 
// #delimit ;
// twoway (connected resp newscale  if syear == 1977)  
// 	   (connected resp newscale  if syear == 1985) 
// 	   (connected resp newscale  if questionid == "USGALLUP.040689.R1D")  
// 	   (connected resp newscale  if questionid == "USGALLUP.081689.R02A")  
// 	   (connected resp newscale  if syear == 1991)
// 	   (connected resp newscale  if syear == 1993)
// 	   ,
// 	   title("Gallup(4) to GSS")
// 	   legend(col(1) 
// 	   	order ( 1 "1977"
// 		      2 "1985"
// 			  3 "1989 march"
// 			  4 "1989 aug"
// 			  5 "1991"
// 			  6 "1993"
// 				   ))
// 				  ;
//
// #delimit cr	

sort questionid resp newscale
#delimit ;
twoway (connected newscale  resp  if syear == 1983 & varname=="USGALLUP_10")  
	   (connected newscale  resp  if syear == 1993 & varname=="USGALLUP_10" ) 
	   ,
	   title("Gallup(10) to GSS")
	   xtitle(gallup(10))
	   ytitle(gss(ref))
	   
	   legend(col(1) 
	   	order ( 1 "1983"
		      2 "1993"

				   ))
				  ;

#delimit cr	

graph save Graph gallup10_gss.gph, replace 


sort questionid resp newscale
#delimit ;
twoway (connected newscale  resp  if syear == 1977 & varname=="USGALLUP_4")  
	   (connected newscale  resp  if syear == 1985 & varname=="USGALLUP_4" ) 
	   (connected newscale  resp  if syear == 1989 & varname=="USGALLUP_4" )
	   	(connected newscale  resp  if syear == 1991 & varname=="USGALLUP_4" )
	   	(connected newscale  resp  if syear == 1993 & varname=="USGALLUP_4" )
	   ,
	   title("Gallup(4) to GSS")
	   	   xtitle(gallup(4))
		   ytitle(gss(ref))

	   legend(col(1) 
	   	order ( 1 "1977"
		      2 "1985"
			  3 "1989"
			  4 "1991"
			  3 "1993"

				   ))
				  ;

#delimit cr	

graph save Graph gallup4_gss.gph, replace 

*============use other references =========== 
*pew 
use scaling.dta, clear
drop if syear == 1955


set trace on 

*use midpoint to strech data
*local numlist pew  "2005/2013"
local pew "2005 2006 2007 2008 2009 2010 2011 2012 2013"
foreach x of local pew {
 use scaling.dta , clear 
	*mid-point 
	
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 
	 
	keep if syear == `x' 
	
	sort questionid resp

	forval i=1/10 {
	g cut`i'=.
	replace cut`i' =midpoint if resp==`i' & varname == "PEW" 
	egen cut`i'_rf= max(cut`i')
	g dif`i'= abs(cut`i'_rf -midpoint)
	drop cut`i'
	drop cut`i'_rf
	}

	egen mindif=rowmin(dif*)

	g newscale =.
	forval i = 1/10 {
	replace newscale = `i' if dif`i' == mindif 
	
	}
drop dif1-dif10
keep sid syear questionid newscale 
tempfile y`x'
save `y`x'', replace 
}
set trace off 

append using `y2005'
append using `y2006'
append using `y2007'
append using `y2008'
append using `y2009'
append using `y2010'
append using `y2011'
append using `y2012'

merge 1:1 sid using scaling.dta 

sort  questionid resp  
bysort questionid : g midpoint = pct/2 +cpt[_n-1]
replace  midpoint = pct/2 if midpoint ==. 

g   ref_pew =1


sort varname syear
save ref_pew_midpoint, replace 

use ref_pew_midpoint , clear


sort newscale
#delimit ;
 twoway (connected midpoint newscale if varname == "PEW" & syear == 2005)  
		(connected midpoint newscale if varname == "USGALLUP_4"  & syear == 2005)  
         , 
	   title("2005")
	   ytitle("cumulative freq") 
	   xtitle("scale") 
	   legend(col(1) 
			ring(0)
			 order(1 "PEW"
				   2 "USGALLUP_4"
				   ))
				  ;
#delimit cr	 

//keep if inlist(syear,2005 2006 2007 2008 2009 2010 2011 2012 2013)

*---------overlapping between pew and gallup --------

sort questionid newscale  resp 
#delimit ;
twoway (connected newscale  resp  if syear == 2005 & varname == "USGALLUP_4")  
	   (connected newscale  resp  if syear == 2006 & varname == "USGALLUP_4") 
	   (connected newscale  resp  if syear == 2007 & varname == "USGALLUP_4")
	   (connected newscale  resp  if syear == 2008 & varname == "USGALLUP_4") 
	   (connected newscale  resp  if syear == 2009 & varname == "USGALLUP_4") 
	   (connected newscale  resp  if syear == 2010 & varname == "USGALLUP_4") 
	   (connected newscale  resp  if syear == 2011 & varname == "USGALLUP_4") 
	   (connected newscale  resp  if syear == 2012 & varname == "USGALLUP_4") 
	   (connected newscale  resp  if syear == 2013 & varname == "USGALLUP_4") 
	   (connected newscale  resp  if syear == 2014 & varname == "USGALLUP_4") 
	   (connected newscale  resp  if syear == 2015 & varname == "USGALLUP_4") 
	   (connected newscale  resp  if syear == 2017 & varname == "USGALLUP_4") 

	   ,
	   title("Gallup to PEW")
	   xtitle(gallup)
	   ytitle(pew(ref))
	   legend(col(1) 
	   	order ( 1 "2005"
		      2 "2006"
			  3 "2007"
			  4 "2008"
			  5 "2009"
			  6 "2010"
			  7 "2011"
			  8 "2012"
			  9 "2013"
			  10 "2014"
			  11 "2015"
			  12 "2017"

				   ))
				  ;

#delimit cr	

graph save Graph gallup_pew.gph, replace 


// *---look aat a single year -----
//
// use ref_pew_midpoint, clear
// keep if syear == 2005
//
// sort newscale
// #delimit ;
//  twoway (connected cpt newscale if varname == "PEW")  
// 		(connected cpt newscale if varname == "TRA_5")  
//          , 
// 	   title("2005")
// 	   ytitle("cumulative freq") 
// 	   xtitle("scale") 
// 	   legend(col(1) 
// 			ring(0)
// 			 order(1 "PEW"
// 				   2 "TRA_5"
// 				   ))
// 				  ;
// #delimit cr	 
// graph save Graph p2005.gph, replace 


*-----gallup as reference ----------
use scaling.dta , clear 
sort enddate resp 
list questionid resp cpt enddate if varname == "USGALLUP_4"  & inlist(syear, 1999,2000)

sort enddate resp 




// #delimit ;
// twoway (connected resp  cpt if questionid == "USGALLUP.200005.Q06A")
// 	   (connected resp  cpt if questionid == "USGALLUP.00NMB13.R13C")
// 	   (connected resp  cpt if questionid == "USGALLUP.00MC17.R17B")
//
// 	   ,
// 	   	title(" Gallup 2000")
// 	   ytitle("cumulative freq") 
// 	   xtitle("scale") 
// 	   legend(col(1) 
// 			ring(0)
// 			 order(1 "Jan"
// 				   2 "Nov"
// 				   3 "March"
// 				   ))
//
// ;
// #delimit cr	
//
//
// #delimit ;
// twoway (connected resp  cpt if questionid == "USGALLUP.99FEB8.R02G")
// 	   (connected resp  cpt if questionid == "USGALLUP.99MAR12.R34")
// 	   (connected resp  cpt if questionid == "USGALLUP.99MM07.R23A")
// 	   	   ,
// 	   	title(" Gallup 1999")
// 	   ytitle("cumulative freq") 
// 	   xtitle("scale") 
// 	   legend(col(1) 
// 			ring(0)
// 			 order(1 "Feb"
// 				   2 "Mar"
// 				   3 "May"
// 				   ))
// ;
// #delimit cr	

*keep mid year : 2000 : march;  1999: mrach 
drop if questionid == "USGALLUP.200005.Q06A"
drop if questionid == "USGALLUP.00NMB13.R13C"


drop if questionid == "USGALLUP.99FEB8.R02G"
drop if questionid == "USGALLUP.99MM07.R23A"

save gallup_temp, replace 


 
local gallup "1997 1998 1999 2000 2001 2002 2004"

foreach x of local gallup {
 use gallup_temp.dta , clear 
	*mid-point 
	
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 
	 
	keep if syear == `x' 
	
	sort questionid resp

	forval i=1/10 {
	g cut`i'=.
	replace cut`i' =midpoint if resp==`i' & varname == "USGALLUP_4" 
	egen cut`i'_rf= max(cut`i')
	g dif`i'= abs(cut`i'_rf -midpoint)
	drop cut`i'
	drop cut`i'_rf
	}

	egen mindif=rowmin(dif*)

	g newscale =.
	forval i = 1/10 {
	replace newscale = `i' if dif`i' == mindif 
	
	}
drop dif1-dif10
keep sid syear questionid newscale 
tempfile y`x'
save `y`x'', replace 
}
set trace off 


append using `y1997'
append using `y1998'
append using `y1999'
append using `y2000'
append using `y2001'

merge 1:1 sid using gallup_temp.dta 

sort  questionid resp  
bysort questionid : g midpoint = pct/2 +cpt[_n-1]
replace  midpoint = pct/2 if midpoint ==. 

g   ref_gallup=1

sort varname syear
save ref_gallup_midpoint, replace 

*uscbs  
use ref_gallup_midpoint, replace 

sort questionid resp newscale
#delimit ;
twoway (connected newscale  resp  if syear == 1998 & varname=="USCBS_3")  
	   (connected newscale  resp  if syear == 1999 & varname=="USCBS_3" ) 
	   (connected newscale  resp  if syear == 2001 & varname=="USCBS_3" )
	   ,
	   title("USCBS to GALLUP4")
	   xtitle(uscbs)
	   ytitle(gallup_4(ref))
	   legend(col(1) 
	   	order ( 1 "1998"
		      2 "1999"
			  3 "2001"
				   ))
				  ;

#delimit cr	

graph save Graph cbs_gallup.gph, replace 




sort questionid resp newscale 

// #delimit ;
// twoway (connected resp newscale  if syear == 1998 & questionid  == "USCBS.98MY23.R16") 
//        (connected resp newscale  if syear == 1998 & questionid  == "USCBSNYT.061098.R05")   
// 	   (connected resp newscale  if syear == 1998 & varname == "USPSRA_4") 
// 	   ,
// 	   title("Ref(gallup)")
// 	   legend(col(1) 
// 	   	order ( 1 "1998 May  CBS"
// 		      2 "1998 June  CBS"
// 			  3 "1998 PSRA"
// 				   ))
// 				  ;
//
// #delimit cr	


*-----------
graph combine  gallup10_gss.gph gallup4_gss.gph  cbs_gallup.gph gallup_pew.gph

graph export "$image\scaling_3refs.png",replace 




*-------------compile into one large file------------ 
use ref_gss_midpoint , clear
rename newscale scale_rgss

*keep syear questionid sid resp scale scale_rgss midpoint cpt nresp enddate
tempfile gss_r
save `gss_r.dta', replace 

use ref_pew_midpoint, clear 
rename newscale scale_rpew
*keep syear questionid sid resp scale_rpew scale  midpoint cpt nresp enddate

tempfile pew_r
save `pew_r.dta', replace 


use ref_gallup_midpoint
rename newscale scale_rgallup

*keep syear questionid sid resp scale_rgallup scale  midpoint cpt nresp enddate

merge 1:1 sid using  `gss_r.dta',nogen 
merge 1:1 sid using  `pew_r.dta', nogen 

keep varname syear questionid sid resp  scale  midpoint cpt nresp enddate  ///
      scale_rgallup scale_rgss scale_rpew

 	  
	  
g        newscale = scale_rgss 
replace  newscale = scale_rpew if newscale==.
replace  newscale = scale_rgallup if newscale==.
replace newscale = resp if varname == "GSS" & newscale==.
replace newscale = resp if varname == "USGALLUP_4"  & newscale==.
replace newscale = resp if varname == "PEW"  & newscale==.



// * calculate mean
// 	g tval=nresp * midpoint 
// 	bysort questionid : egen tq= sum(tval)
// 	g newmean= tq/n
//
// * graph mean value overtime 

use scaling.dta, clear

	drop if syear ==1955
	encode questionid, g(numsurvey)
	egen nsurvey=nvals(numsurvey), by(syear)
	
	*mid-point 
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 

*zscore 
g zscore= invnormal(midpoint)

*calculate mean of zscore 
	g tval=nresp * zscore 
	bysort questionid : egen tq= sum(tval)
	g z_mean= tq/n

sort syear
#delimit ;
twoway	(connected z_mean syear if varname =="GSS" )  
	   (connected z_mean syear if varname =="USGALLUP_10")
	   (connected z_mean syear if varname =="PEW_4"      )
	    (connected z_mean syear if varname =="USGALLUP_4" )
        (connected z_mean syear if varname =="TRA_4")
		(connected z_mean syear if varname =="USORC_4")
		(connected z_mean syear if varname =="USPSRA_4")
		(connected z_mean syear if varname =="USZOGBY_4")		
		(connected z_mean syear if varname =="TRA_5")
		(connected z_mean syear if varname =="USKN_5")
		(connected z_mean syear if varname =="USCBS_3")
		(connected z_mean syear if varname =="ABC")
	   	   , 
	   title(" 10 scale and 4 scale")
	   ytitle("mean (mid_point z score)") 
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


sort syear
#delimit ;
twoway	(connected z_mean syear if varname =="GSS" )  
	   (connected z_mean syear if varname =="USGALLUP_10")
	   (connected z_mean syear if varname =="PEW_4"      )
	    (connected z_mean syear if varname =="USGALLUP_4" )
        (connected z_mean syear if varname =="TRA_4")
		(connected z_mean syear if varname =="USORC_4")
		(connected z_mean syear if varname =="USPSRA_4")
		(connected z_mean syear if varname =="USZOGBY_4")
		(connected z_mean syear if varname =="USUMARY_4")
	   	   , 
	   title("10 scale and 4 scale")
	   ytitle("mean (mid_point z score)") 
	   xtitle("year") 
	   xlabel(1970(2)2018, angle(90)) 
	   ylab(-0.15(0.01)0.15)
	   legend(col(1) 
			 order(1 "GSS"
				   2 "Gallup (10 scale)"
				   3 "PEW" 
				   4 "Gallup (4 scale)" 
				   5 "Trans Atlantic Trends (4 scale)"
				   6 "NORC"
				   7 "USPSRA"
				   8 "USZOGBY_4"
				   9 "USUMARY_4"
				   ))
				  ;
#delimit cr	   
graph export "$image\scaling_zscore.png",replace 



sort syear
#delimit ;
twoway  (connected z_mean syear if varname =="USCBS_3")
		(connected z_mean syear if varname =="ABC")

,
	   title("3 scale ")
	   ytitle("mean (mid_point z score)") 
	   xtitle("year") 
	   xlabel(1970(2)2018, angle(90)) 
	   ylab(-0.15(0.01)0.15)
	   legend(col(1) 
			 order(1 "CBS"
				   2 "ABC"

				   ))
				  ;
#delimit cr	   
