*LAM used in happiness study 
*created on 06/17 2020
*task : happiness data input

*global data  "/Users/donghui/Dropbox/Website/US_project/cleaned_data/rdm_sim"     // mac
global data "C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data\rdm_sim" //lap
global image "C:\Users\wdhec\Dropbox\Website\US_project\image"


*import excel "/Users/donghui/Dropbox/Website/US_project/cleaned_data/rdm_sim/hapiness_raw.xlsx", sheet("WVS 1981_2012") firstrow
clear 
import excel "$data/hapiness_raw.xlsx", sheet("WVS 1981_2012") firstrow

rename A year 
rename Dissatisfied r1 
rename C r2
rename D r3
rename E r4
rename F r5
rename G r6
rename H r7
rename I r8
rename J r9
rename Satisfied r10

g nsize=int(EffectiveN)


keep year r*  nsize
drop if year == .
reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)

expand nresp
g varname = "WVS"

tempfile wvs
save `wvs.dta', replace


import excel "$data/hapiness_raw.xlsx", sheet("EB 1973_2015") firstrow clear 

rename A year 
rename B r1
rename C r2 
rename D r3
rename E r4

g nsize=int(G)

keep year r* nsize 
drop if year == .

reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)

expand nresp
g varname = "EB"

tempfile eb
save `eb.dta', replace


import excel "$data/hapiness_raw.xlsx", sheet("CBS 1997_2009") firstrow clear 

rename A year 
rename B r1
rename C r2 
rename D r3
rename E r4
rename F r5 
g nsize=int(H)


keep year r*  nsize
drop if year==.

reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)

expand nresp
g varname = "CBS(1997-2009)"

tempfile cbs_9709
save `cbs_9709.dta', replace


import excel "$data/hapiness_raw.xlsx", sheet("SCP 2004_2008") firstrow clear 

rename A year 
rename Completelydissatisfied r1 
rename C r2
rename D r3
rename E r4
rename F r5
rename G r6
rename H r7
rename I r8
rename J r9
rename Completelysatisfied r10

g nsize=int(EffectiveN)


keep year r*  nsize
drop if year==.

reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)

expand nresp
g varname = "SCP(2004-2008)"

tempfile scp_0408
save `scp_0408.dta', replace

import excel "$data/hapiness_raw.xlsx", sheet("ESS 2002_2014") firstrow clear 

rename A year 
rename Extremelydissatisfied r1 
rename C r2
rename D r3
rename E r4
rename F r5
rename G r6
rename H r7
rename I r8
rename J r9
rename Extremelysatisfied r10

g nsize=int(EffectiveN)


keep year r*  nsize
drop if year==.


reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)

expand nresp
g varname = "ESS"

tempfile ess
save `ess.dta', replace

import excel "$data/hapiness_raw.xlsx", sheet("SCP 1997_2002") firstrow clear 
rename A year 

rename B r1
rename C r2 
rename D r3
rename E r4
rename F r5 
g nsize=int(H)

keep year r*  nsize
drop if year==.

reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)
expand nresp

g varname = "SCP(1997-2002)"

tempfile scp_9702
save `scp_9702.dta', replace


import excel "$data/hapiness_raw.xlsx", sheet("CBS 1994_1997") firstrow clear 
rename A year 

rename B r1
rename C r2 
rename D r3
rename E r4
rename F r5 
g nsize=int(H)

keep year r*  nsize
drop if year==.

reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)
expand nresp

g varname = "CBS(1994-1997)"

tempfile cbs9497
save `cbs9497.dta', replace



import excel "$data/hapiness_raw.xlsx", sheet("CBS 1989_1993") firstrow clear 
rename A year 

rename B r1
rename C r2 
rename D r3
rename E r4
rename F r5 
g nsize=int(H)

keep year r*  nsize
drop if year==.

reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)
expand nresp

g varname = "CBS(1989-1993)"

tempfile cbs_8993
save `cbs_8993.dta', replace




import excel "$data/hapiness_raw.xlsx", sheet("SCP 1989_1993") firstrow clear 
rename A year 

rename B r1
rename C r2 
rename D r3
rename E r4
rename F r5 
g nsize=int(H)

keep year r*  nsize
drop if year==.

reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)
expand nresp

g varname = "SCP(1989-1993)"

tempfile scp_8993
save `scp_8993.dta', replace

import excel "$data/hapiness_raw.xlsx", sheet("CBS 1980_1986") firstrow clear 
drop A B
rename C year 

rename D r1
rename E r2 
rename F r3
rename G r4
rename H r5 
g nsize=int(K)

keep year r*  nsize
drop if year==.
reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)
expand nresp
g varname = "CBS(1980-1986)"
tempfile cbs_8086
save `cbs_8086.dta', replace 


import excel "$data/hapiness_raw.xlsx", sheet("SCP 1974_1977") firstrow clear 
drop A B
rename C year 

rename D r1
rename E r2 
rename F r3
rename G r4
rename H r5 
g nsize=int(K)

keep year r*  nsize
drop if year==.
reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)
expand nresp
g varname = "SCP(1974-1977)"
tempfile scp_7477
save `scp_7477.dta', replace 



import excel "$data/hapiness_raw.xlsx", sheet("CBS 1974_1977") firstrow clear 
drop A B
rename C year 
rename D r1
rename E r2 
rename F r3
rename G r4
rename H r5 
g nsize=int(K)

keep year r*  nsize
drop if year==.
reshape long  r , i(year) j(scale)
g nresp = int((r*nsize/100)+0.5)
expand nresp
g varname = "CBS(1974-1977)"
tempfile cbs_7477
save `cbs_7477.dta', replace 


append using `wvs.dta'
append using `eb.dta'
append using `cbs_9709.dta'
append using  `scp_0408.dta'
append using  `ess.dta'
append using  `scp_9702.dta'
append using  `cbs9497.dta'
append using  `cbs_8993.dta'
append using  `cbs_8086.dta'
append using  `scp_7477.dta'
append using  `cbs_7477.dta'

save "$data/happiness.dta", replace 


*graphing 

*Fig 1 cross tab the avaiability 

use "$data\happiness.dta", clear  
	keep year varname 
	duplicates drop 
		
 	tabplot varname year, subtitle("") height(0.3) xtitle(Year) ytitle(Variable name) xlabel(, labsize(small) angle(45))note("")
graph export  "$image\happiness_year.png" , replace 


* mean by panel 
use "$data\happiness.dta", clear  


collapse (mean)scale, by (varname year)

sort year
twoway connected scale year, by(varname, note("")) ylab(1(2)10) ytitle(Mean)
graph export "$image\happiness_panel.png", replace 

