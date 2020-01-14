*dyad ratio approach 
*created in Jan 13th 2020
*calculate stimonson's dyad ratio by hand 


cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"
global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 

cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"  //mac 


*prepare to export 
use dra_agg.dta, clear
	keep if var =="PEW_4"  |   var =="USGALLUP_4" 
	keep if inrange(syear, 2005,2017)
	drop date 
	g date =mdy(1,1,syear)
	format date %td
	keep  fav date varname n
save tws_dyd, replace 


*hand written 
use dra_agg.dta, clear
	keep if var =="PEW_4" 
	keep if inrange(syear, 2005,2017)
	keep syear fav date 
	rename fav pew 
	tempfile pew
	save `pew.dta', replace 
	
use dra_agg.dta, clear
	keep if var =="USGALLUP_4" 
	keep if inrange(syear, 2005,2017)
	keep syear fav  
	rename fav gallup
	duplicates drop
	merge 1:1 syear using `pew.dta', nogen 
save tws.dta, replace 

* import results from stimoson's software (no smoothing )

import delimited /Users/donghui/Dropbox/Website/US_project/cleaned_data/tws_dyd.Csv, clear
	rename v1 syear 
	rename v2 stm
tempfile stm
save `stm.dta', replace 
	
*last year as reference 
use tws.dta, replace 
	merge 1:1 syear using `stm' , nogen 
	
	sort syear
	rename gallup g 
	rename pew p
	gen id=_n
	
	drop date
	
	replace p=100*p/p[13]
	replace g=100*g/g[13]
	
	* t=12 	
	g pr12=p[12]/p[13]
	g gr12=g[12]/g[13]
	egen r12=rowmean(pr12 gr12)
	
	g p12=p[13]*r12
	g g12=g[13]*r12
	
	egen c12=rowmean(p12 g12) 


	forval i=11(-1)1 {
	local  j = `i'+1
	display " `i' ,`j'"
	
	g pr`i'=p[`i']/p[`j']
	g gr`i'=g[`i']/g[`j']
	egen r`i'=rowmean(pr`i' gr`i')
	
	g c`i'=c`j'*r`i' 
	}

keep syear g p id stm c*

	g b=.
	forval i=1/12{
	replace b=c`i' if id==`i'
	}
	drop c*
	
tempfile b
save `b.dta', replace 
* forward recursion 	

use tws.dta, replace 
*last year as reference 
	sort syear
	rename gallup g 
	rename pew p
	gen id=_n
	
	drop date
	
	replace p=100*p/p[1]
	replace g=100*g/g[1]
	
	* t=2	
	g pr2=p[2]/p[1]
	g gr2=g[2]/g[1]
	egen r2=rowmean(pr2 gr2)
	
	g p2=p[1]*r2
	g g2=g[1]*r2
	
	egen c2=rowmean(p2 g2) 	
	
	forval i=3/13 {
	local j=`i' -1 
	
	g pr`i' =p[`i']/p[`j']
	g gr`i' =g[`i']/g[`j']
	egen r`i'=rowmean(pr`i' gr`i')
	
	g c`i' =c`j'*r`i'

	}
	
keep syear g p id  c*

	g f=.
	forval i=2/13{
	replace f=c`i' if id==`i'
	}
	drop c*	
	
	sort id  
	merge 1:1 id using `b.dta', nogen 
	
	egen dyd=rowmean(f b)
	
	sort syear 
	twoway connected stm syear || connected dyd syear || connected f syear || connected b syear || connected g syear || connected p syear 
	
	

	
	*smoothing 
	*simple exponential forecasts are optimal for an ARIMA (0,1,1) model
	tsset id 
	arima forward, arima(0,1,1)
	scalar sf= 1+ (-.99999525)
	
	arima back, arima(0,1,1)
	scalar sb= 1+ (-.9999911)

	
	g f=sf*forward + (1-sf)*forward[_n-1]
	g b=sb*back + (1-sb)*back[_n-1]
	egen dyd=rowmean(f  b)
	
	sort syear 
	twoway connected f syear || connected forward syear 

	sort syear 
	twoway connected b syear || connected back syear 
	
	sort syear 
	twoway connected dyd syear 

* prepare to export 
erase pew.dta
erase stimo.dta 
erase tws.dta
erase tws_dyd.dta
