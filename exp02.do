*expoloratory 
*stimonson dyatic ratio model 
*created in 12112019

global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 
cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"

// global image "/Users/donghui/Dropbox/Website/US_project/image"
// cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"

*prepare input to wcalc6  software 

use  "pooled.dta", clear 

	*positive attitude 
	g d_opc_10pn=(inrange(opc_10pn,1,5)) if !missing(opc_10pn)
	g d_opc_3p = (opc_3p==3)			 if !missing(opc_3p)
	g d_opc_4p =(inrange(opc_4p,3,4))    if !missing(opc_4p)
	g d_opc_100p =(inrange(opc_100p, 51,100)) if !missing(opc_100p)


collapse (count)opc_10pn opc_4p opc_100p opc_3p  (mean) d_opc_10pn d_opc_3p d_opc_4p d_opc_100p [pweight=wt], by(syear survey)
	
	* work on gallup survey 
	egen nvar=rownonmiss(d_opc_10pn d_opc_3p d_opc_4p d_opc_100p)
	replace survey = "gallup10" if survey=="gallup" & !missing(d_opc_10pn) & nvar==1
	replace survey = "gallup4" if survey=="gallup" & !missing(d_opc_4p)   & nvar==1

	g var = survey if   nvar==1
	expand 2 if nvar==2

	sort syear survey 
	g id =_n

	replace var = "gallup10" if id == 7
	replace var = "gallup4" if id == 8

	replace var = "gallup10" if id == 26
	replace var = "gallup4" if id == 27

	egen 	size = rowtotal(opc_10pn opc_4p opc_100p opc_3p) if nvar==1
	replace size = opc_10pn if size ==. & var == "gallup10"
	replace size = opc_4p   if size ==. & var == "gallup4"
	g n=int(size)

	egen    value = rowtotal(d_opc_10pn d_opc_3p d_opc_4p d_opc_100p) if nvar==1
	replace value = d_opc_10pn if value ==. & var == "gallup10"
	replace value = d_opc_4p   if value ==. & var == "gallup4"

	g date =mdy(1,1,syear)  // 1974 - 2017

// keep int at least 2yrs 
sort var syear 
by var : g nyr=_N
drop if nyr == 1  // 4 dropped 

keep var value n date  syear
save "dra.dta", replace 



* compare drm with raw data 
import delimited C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra.Csv, clear 
g syear = v1
g mood = v2*100
*merge 1:1 syear using raw_combined.dta
merge 1:m syear using dra.dta 
g raw= value * 100

sort syear
twoway (line mood syear)  ///
       (scatter raw syear , mcolor(%50)), ///
	   title(Favorable opinion toward China ) ytitle("%") legend(col(1) ring(0) order(1 "Dyad Ratio Estimates" 2 "Survey margins"))

graph export "$image\dra.png",replace 

*----with scatter plot of orginal data------------
import delimited C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra.Csv, clear 
g syear = v1
g mood = v2

merge 1:m syear using dra.dta

sort syear
twoway (line mood syear) (scatter value syear)

*---------------merge with agg results (agg.do)--------------------
import delimited C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra.Csv, clear 
g smood = v2*100
drop v2
tempfile small
save `small.dta', replace 

import delimited  using  C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra_agg.Csv, clear 
merge 1:1 v1 using `small.dta'
drop if smood==.
g syear = v1
rename v2 aggmood

twoway (line smood syear) (line aggmood syear), ///
        xlabel(1970(2)2020, angle(90)) ylab(0(20)100) ///
		legend(row(1) ring(0) order(1 "small sample" 2 "larger sample")) title (Favorable opinion toward China)
graph export "$image\comp_dra.png",replace 

*something went wrong inbetween 1994 and 2008 

*------------------- unfav attitude-------------

use  "pooled.dta", clear 

	*negative attitude 
	g dn_opc_10pn=(inrange(opc_10pn,-5,-1))     if !missing(opc_10pn)
	g dn_opc_3p = (opc_3p==1)					if !missing(opc_3p)
	g dn_opc_4p =(inrange(opc_4p,1,2)) 			if !missing(opc_4p)
	g dn_opc_100p =(inrange(opc_100p, 0,49))    if !missing(opc_100p)


collapse (count)opc_10pn opc_4p opc_100p opc_3p  (mean) dn_opc_10pn dn_opc_3p dn_opc_4p dn_opc_100p [pweight=wt], by(syear survey)
	
	* work on gallup survey 
	egen nvar=rownonmiss(dn_opc_10pn dn_opc_3p dn_opc_4p dn_opc_100p)
	replace survey = "gallup10" if survey=="gallup" & !missing(dn_opc_10pn) & nvar==1
	replace survey = "gallup4" if survey=="gallup" & !missing(dn_opc_4p)   & nvar==1

	g var = survey if   nvar==1
	expand 2 if nvar==2

	sort syear survey 
	g id =_n

	replace var = "gallup10" if id == 7
	replace var = "gallup4" if id == 8

	replace var = "gallup10" if id == 26
	replace var = "gallup4" if id == 27

	egen 	size = rowtotal(opc_10pn opc_4p opc_100p opc_3p) if nvar==1
	replace size = opc_10pn if size ==. & var == "gallup10"
	replace size = opc_4p   if size ==. & var == "gallup4"
	g n=int(size)

	egen    value = rowtotal(dn_opc_10pn dn_opc_3p dn_opc_4p dn_opc_100p) if nvar==1
	replace value = dn_opc_10pn if value ==. & var == "gallup10"
	replace value = dn_opc_4p   if value ==. & var == "gallup4"

	g date =mdy(1,1,syear)  // 1974 - 2017

keep var value n date syear
save "dra_n.dta", replace 


* compare drm with raw data 
import delimited C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra_n.Csv, clear //desktop
*import delimited /Users/donghui/Dropbox/Website/US_project/cleaned_data/dra_n.Csv, clear	
	g syear = v1
	g mood = v2*100

*merge 1:1 syear using raw_combined.dta
merge 1:m syear using dra_n.dta
g raw = value*100


sort syear 
twoway (line mood syear)  ///
       (scatter raw syear, mcolor(%50)), ///
	   title("Unfavorable opionon toward China") ytitle("%") legend(col(1) ring(0) order(1 "Dyad Ratio Estimates" 2 "Survey margins"))  ///
	   ylab(0(20)80)

graph export "$image\dra_n.png",replace 


*-------merge with agg results -----------------
import delimited C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra.Csv, clear 
g smood = v2*100
drop v2
tempfile small
save `small.dta', replace 

import delimited  using  C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra_agg.Csv, clear 
merge 1:1 v1 using `small.dta'
drop if smood==.
g syear = v1
rename v2 aggmood

set scheme cleanplots
twoway (line smood syear) (line aggmood syear), xlabel(1970(2)2020, angle(90) )



*unfav
import delimited C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra_n.Csv, clear 
g smood = v2*100
drop v2
tempfile small
save `small.dta', replace 

import delimited  using  C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\dra_agg_n.Csv, clear 
merge 1:1 v1 using `small.dta'
drop if smood==.
g syear = v1
rename v2 aggmood

twoway (line smood syear) (line aggmood syear), xlabel(1970(2)2020, angle(90))  ylab (0(20)100)   ///
		legend(row(1) ring(0) order(1 "small sample" 2 "larger sample")) title (Unfavorable opinion toward China)

graph export "$image\comp_dra_n.png",replace 

*------DRA fav and unfav-------------------
