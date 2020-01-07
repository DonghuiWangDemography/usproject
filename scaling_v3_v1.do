cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"
global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 

program drop _all 

program pct_mapping
  args year name 


use scaling.dta, clear
    keep if syear == `year' 
	keep if varname == "`name'"
		   		   
	*mid-point 
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 
	
	g b_`name'_`year'= round(midpoint*100 , 0.01) 


keep syear sid resp b_`name'_`year'  

end


*map GSS 1993 and Gallup 1993 onto a linear function 

set trace on 
program anchor

	args year first second 


pct_mapping `year' `first'  
	mkmat resp b_`first'_`year', mat(b_`first'_`year')
	mat list b_`first'_`year'
	
use scaling.dta, clear 

	g b_`first'_`year'=.
	levelsof resp, local(levels)
	foreach i of local levels {
	replace b_`first'_`year' = b_`first'_`year'[`i', 2] if resp == `i'
	}

tempfile syear nresp sid qid b_`first'_`year'
tempfile `first'_`year'
save ``first'_`year'.dta' , replace 


pct_mapping `year' `second'  
	mkmat resp b_`second'_`year', mat(b_`second'_`year')
	mat list b_`second'_`year'
	
use scaling.dta, clear 
	g b_`second'_`year'=.
	levelsof resp, local(levels)
	foreach i of local levels {
	replace b_`second'_`year' = b_`second'_`year'[`i', 2] if resp == `i'
	}

keep syear nresp sid qid b_`second'_`year'
	merge 1:1 sid using ``first'_`year'.dta', nogen 
	keep if inlist(varname, "`first'" , "`second'" )
	
	
	*calculate mean 
	 foreach x of varlist b_`first'_`year' b_`second'_`year' {
	 
	 g val_`x' = `x'  * nresp 
	 bysort questionid : egen tval_`x'=total(val_`x')
	 g mean_`x' = tval_`x' /n 
	 replace mean_`x' =. if mean_`x' ==0
	 
}
	 keep syear enddate mean*  varname questionid qid
	 duplicates drop 
	 sort syear
	 
	 
*graph results 
	 
set scheme Cleanplots 
sort syear 

#delimit; 
twoway (connected mean_b_`first'_`year'  syear if varname == "`first'" ) 
	   (connected mean_b_`second'_`year' syear if varname == "`second'" )
	   ,
	   title(Anchoring year : `year')
	   xtitle(year)
	   ylab(0(10)100)
	   legend (
			ring(0)
			 order(1 "`first'"
				   2 "`second'"
				   ))

	   ;
# delimit cr


// #delimit; 
// twoway (connected mean_b_`first'_`year'  syear if varname == "`first'"  &  syear <= `year') 
// 	   (connected mean_b_`second'_`year' syear if varname == "`second'" &  syear >=`year')
// 	   ,
// 	   title(Anchoring year : `year')
// 	   xtitle(year)
// 	   ylab(0(10)100)
// 	   legend (
// 			ring(0)
// 			 order(1 "`first'"
// 				   2 "`second'"
// 				   ))
//
// 	   ;
// # delimit cr	
graph save Graph `first'_`second'_`year'.gph, replace 
	 
end 	
set trace off 


* overlapping years 
* how many overlapping years ? 
// use scaling, clear 
// tab syear varname if inlist(varname, "GSS", "USGALLUP_4")

anchor 1977 GSS USGALLUP_4 
	g       anchor_1977 = mean_b_GSS_1977         if varname =="GSS"          & syear <= 1977
	replace anchor_1977 = mean_b_USGALLUP_4_1977  if varname  == "USGALLUP_4" & syear > 1977
	keep syear qid varname enddate anchor_1977
	drop if anchor_1977 ==.	
save y_1977, replace 
	

anchor 1991 GSS USGALLUP_4
	g       anchor_1991 = mean_b_GSS_1991         if varname =="GSS"          & syear <= 1991
	replace anchor_1991 = mean_b_USGALLUP_4_1991  if varname  == "USGALLUP_4" & syear > 1991
	keep syear qid varname enddate anchor_1991
	drop if anchor_1991 ==.
save y_1991, replace 

anchor 1993 GSS USGALLUP_4

	g       anchor_1993 = mean_b_GSS_1993         if varname =="GSS"          & syear <= 1993
	replace anchor_1993 = mean_b_USGALLUP_4_1993  if varname  == "USGALLUP_4" & syear > 1993
	keep syear qid varname enddate anchor_1993
	drop if anchor_1993 ==.
	keep syear qid varname enddate anchor_1993

merge 1:1 qid using y_1977, nogen 
merge 1:1 qid using y_1991, nogen
export delimited using "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\gss_gallup.csv", replace

erase y_1977.dta
erase y_1991.dta

grc1leg    GSS_USGALLUP_4_1977.gph  GSS_USGALLUP_4_1991.gph GSS_USGALLUP_4_1993.gph , ///
legendfrom(GSS_USGALLUP_4_1977.gph)ring(0) pos(4) span

graph export "$image/gss_gallup.png",replace 



* how many overlapping years ? 
use scaling, clear 
tab syear varname if inlist(varname, "PEW", "USGALLUP_4")
* "2005 2006 2007 2008 2010 2009 2011 2012 2013  2017"

anchor 2005 USGALLUP_4 PEW
	g       anchor_2005 = mean_b_USGALLUP_4_2005 if varname =="USGALLUP_4"   & syear <= 2005
	replace anchor_2005 = mean_b_PEW_2005        if varname  == "PEW"        & syear > 2005
	keep syear qid varname enddate anchor_2005
	drop if anchor_2005 ==.	
	tempfile y2005
	save `y2005.dta', replace 
	

anchor 2006 USGALLUP_4 PEW
	g       anchor_2006 = mean_b_USGALLUP_4_2006 if varname =="USGALLUP_4"   & syear <= 2006
	replace anchor_2006 = mean_b_PEW_2006        if varname  == "PEW"        & syear > 2006
	keep syear qid varname enddate anchor_2006
	drop if anchor_2006 ==.	
	tempfile y2006
	save `y2006.dta', replace 


anchor 2007 USGALLUP_4 PEW
	g       anchor_2007 = mean_b_USGALLUP_4_2007 if varname =="USGALLUP_4"   & syear <= 2007
	replace anchor_2007 = mean_b_PEW_2007        if varname  == "PEW"        & syear > 2007
	keep syear qid varname enddate anchor_2007
	drop if anchor_2007 ==.	
	tempfile y2007
	save `y2007.dta', replace 


anchor 2008 USGALLUP_4 PEW
	g       anchor_2008 = mean_b_USGALLUP_4_2008 if varname =="USGALLUP_4"   & syear <= 2008
	replace anchor_2008 = mean_b_PEW_2008        if varname  == "PEW"        & syear > 2008
	keep syear qid varname enddate anchor_2008
	drop if anchor_2008 ==.	
	tempfile y2008
	save `y2008.dta', replace 

anchor 2009 USGALLUP_4 PEW
	g       anchor_2009 = mean_b_USGALLUP_4_2009 if varname =="USGALLUP_4"   & syear <= 2009
	replace anchor_2009 = mean_b_PEW_2009        if varname  == "PEW"        & syear > 2009
	keep syear qid varname enddate anchor_2009
	drop if anchor_2009 ==.	
	tempfile y2009
	save `y2009.dta', replace 

anchor 2010 USGALLUP_4 PEW
	g       anchor_2010 = mean_b_USGALLUP_4_2010 if varname =="USGALLUP_4"   & syear <= 2010
	replace anchor_2010 = mean_b_PEW_2010        if varname  == "PEW"        & syear > 2010
	keep syear qid varname enddate anchor_2010
	drop if anchor_2010 ==.	
	tempfile y2010
	save `y2010.dta', replace
	
	
anchor 2011 USGALLUP_4 PEW
	g       anchor_2011 = mean_b_USGALLUP_4_2011 if varname =="USGALLUP_4"   & syear <= 2011
	replace anchor_2011 = mean_b_PEW_2011        if varname  == "PEW"        & syear > 2011
	keep syear qid varname enddate anchor_2011
	drop if anchor_2011 ==.	
	tempfile y2011
	save `y2011.dta', replace
		
	
anchor 2012 USGALLUP_4 PEW
	g       anchor_2012 = mean_b_USGALLUP_4_2012 if varname =="USGALLUP_4"   & syear <= 2012
	replace anchor_2012 = mean_b_PEW_2012        if varname  == "PEW"        & syear > 2012
	keep syear qid varname enddate anchor_2012
	drop if anchor_2012 ==.	
	tempfile y2012
	save `y2012.dta', replace
	
	
anchor 2013 USGALLUP_4 PEW
	g       anchor_2013 = mean_b_USGALLUP_4_2013 if varname =="USGALLUP_4"   & syear <= 2013
	replace anchor_2013 = mean_b_PEW_2013        if varname  == "PEW"        & syear > 2013
	keep syear qid varname enddate anchor_2013
	drop if anchor_2013 ==.	
	tempfile y2013
	save `y2013.dta', replace
	
anchor 2017 USGALLUP_4 PEW
	g       anchor_2017 = mean_b_USGALLUP_4_2017 if varname =="USGALLUP_4"   & syear <= 2017
	replace anchor_2017 = mean_b_PEW_2017        if varname  == "PEW"        & syear > 2017
	keep syear qid varname enddate anchor_2017
	drop if anchor_2017 ==.	
// 	tempfile y2017
// 	save `y2017.dta', replace		


merge 1:1 qid using `y2005.dta', nogen 
merge 1:1 qid using `y2006.dta', nogen
merge 1:1 qid using `y2007.dta', nogen
merge 1:1 qid using `y2008.dta', nogen
merge 1:1 qid using `y2009.dta', nogen
merge 1:1 qid using `y2010.dta', nogen
merge 1:1 qid using `y2011.dta', nogen
merge 1:1 qid using `y2012.dta', nogen
merge 1:1 qid using `y2013.dta', nogen

sort syear
order syear qid varname enddate anchor_2005-anchor_2013
export delimited using "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\gallup_pew.csv", replace


	
grc1leg  USGALLUP_4_PEW_2005.gph  USGALLUP_4_PEW_2006.gph USGALLUP_4_PEW_2007.gph USGALLUP_4_PEW_2008.gph   ///
USGALLUP_4_PEW_2009.gph USGALLUP_4_PEW_2010.gph  USGALLUP_4_PEW_2011.gph  USGALLUP_4_PEW_2013.gph USGALLUP_4_PEW_2017.gph , ///
legendfrom(USGALLUP_4_PEW_2005.gph) span

graph export "$image/gallup_pew.png",replace 




// sort syear 
// #delimit; 
// twoway (connected mean_b_GSS_1977        syear if varname == "GSS"        &  syear <= 1977) 
// 	   (connected mean_b_USGALLUP_4_1977 syear if varname == "USGALLUP_4" &  syear >=1977 )
// 	   (connected mean_b_GSS_1991        syear if varname == "GSS"        &  syear <= 1991) 
// 	   (connected mean_b_USGALLUP_4_1991 syear if varname == "USGALLUP_4" &  syear >=1991 )
// 	   (connected mean_b_GSS_1993        syear if varname == "GSS"        &  syear <= 1993) 
// 	   (connected mean_b_USGALLUP_4_1993 syear if varname == "USGALLUP_4" &  syear >=1993 )	   
// 	    ,
// 	   xtitle(year)
// 	   ylab(0(5)100)
// 	   legend (
// 			ring(0)
// 			 order(1 "GSS"
// 				   2 "Gallup_4"
// 				   ))
// 	   ;
// # delimit cr	
