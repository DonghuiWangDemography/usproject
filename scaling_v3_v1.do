*scaling on the basis of percentile 

// cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"
// global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 


cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"
global image  "/Users/donghui/Dropbox/Website/US_project/image"

set scheme Cleanplots, perm


* illustration 
use scaling, clear 
	g pt = cpt *100 

	keep if syear ==1993
	keep if inlist(varname, "USGALLUP_4", "GSS")
	
	replace resp = -1 * resp if varname == "GSS"
	*mid-point 
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 	
	g mid = round(midpoint*100 , 0.01) 
	
	g zero =0 
    #delimit ;
	twoway (bar resp  pt  if varname == "GSS" , hor xline(0) ) 
		   (bar resp pt if varname =="USGALLUP_4", hor )
		   (scatter mid zero, mlabel(mid))
		   ;
	delimit cr 
	
	
	levelsof (midpoint) if varname == "GSS",local(gs)
	twoway connected  cpt resp  if varname == "GSS" , yline(`gs') 
	*graph save Graph gss.gph, replace  
	
// 	twoway (connected cpt resp if varname == "GSS") ///
// 	       (spike  resp mid if varname == "GSS" ,hor yaxis(2))
	
// 	levelsof (midpoint) if varname == "USGALLUP_4",local(ga)
// 	twoway connected  cpt resp  if varname == "USGALLUP_4" , yline(`ga')  
// 	graph save Graph gallup.gph, replace  
//	
// 	graph combine  gss.gph gallup.gph



graph export Graph "$image\illustration.png"


	
//  sort resp
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
	
*==================================
program drop _all 

program pct_mapping
  args year name 

use adj.dta, clear
    keep if syear == `year' 
	keep if varname == "`name'"
		   		   
	*mid-point 
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 
	
	g b_`name'_`year'= round(midpoint*100 , 0.01) 


keep syear sid resp b_`name'_`year'  

end



set trace on 
program anchor

	args year first second 

pct_mapping `year' `first'  
	mkmat resp b_`first'_`year', mat(b_`first'_`year')
	mat list b_`first'_`year'
	
use adj.dta, clear 

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
	
use adj.dta, clear 
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
	 
	 *Graph results
#delimit; 
twoway (connected mean_b_`first'_`year'  syear if varname == "`first'"  &  syear <= `year') 
	   (connected mean_b_`second'_`year' syear if varname == "`second'" &  syear >=`year')
	   ,
	   title(Anchoring year : `year')
	   xtitle(year)
	   ylab(0(20)100)
	   legend (rows(2)
			ring(0)
			 order(1 "`first'"
				   2 "`second'"
				   ))

	   ;
# delimit cr	

graph save Graph `first'_`second'_`year'.gph, replace 
end 	
set trace off 



*------------single-year anchoring-------------
* GSS GALLUP
* identify common years shared by GSS and GAllup  
use scaling, clear 
	tab syear varname if inlist(varname, "GSS", "USGALLUP_4")
	sort enddate 
	list enddate if syear == 1989 & varname == "USGALLUP_4"
*	drop if enddate==td(13aug1989)
	drop if enddate==td(02mar1989)
	save adj, replace   // data that deleted survey that has multiples  dates 
	
	
	*------include 1977------------
local yr "1977 1991 1989 1993"
	foreach x of local yr {
	anchor `x' GSS USGALLUP_4
	
	g       anchor_`x' = mean_b_GSS_`x'         if varname =="GSS"          & syear <= `x'
	replace anchor_`x' = mean_b_USGALLUP_4_`x'  if varname  == "USGALLUP_4" & syear > `x'
	
	keep syear qid varname enddate anchor_`x'
	drop if anchor_`x' ==.	
	
	tempfile y`x'
    save `y`x'', replace 	
	}

	merge 1:1 qid using `y1977', nogen 
	merge 1:1 qid using `y1989', nogen 
	merge 1:1 qid using `y1991', nogen
	drop qid varname 
	
	egen anchor = rowmean(anchor_*)
	la var anchor "Average"	
	
	
	local yr "1977 1991 1989 1993"
	foreach x of local yr {
	la var  anchor_`x' "Anchoring year: `x' "
	}
	
	
	sort syear 
	#delimit; 
	twoway (line anchor syear ,lwidth(medthick))
		   (line anchor_1977 syear ,lp(solid) lcolor(gs7%30))
		   (line anchor_1989 syear ,lp(solid) lcolor(gs6%30))
		   (line anchor_1991 syear ,lp(solid) lcolor(gs5%30))
		   (line anchor_1993 syear ,lp(solid) lcolor(gs4%30)) 
		   ,
		   xlab(1970(10)2020)
		   ylab(0(10)100)
		   xtitle(year)
		   title(GSS and Gallup)
		   	   legend(ring(0) 
		        order  (1 "Average" 
				        ))
		   ;
	# delimit cr
	graph save Graph "$image\gss_gallup.gph", replace 
	
export delimited using "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\gss_gallup.csv", replace



grc1leg    GSS_USGALLUP_4_1977.gph  GSS_USGALLUP_4_1991.gph  GSS_USGALLUP_4_1989.gph GSS_USGALLUP_4_1993.gph , ///
legendfrom(GSS_USGALLUP_4_1977.gph)ring(0) pos(4) span

graph export "$image/gss_gallup.png",replace 



*---taking out 1977---
local yr "1991 1989 1993"
	foreach x of local yr {
	anchor `x' GSS USGALLUP_4
	
	g       anchor_`x' = mean_b_GSS_`x'         if varname =="GSS"          & syear <= `x'
	replace anchor_`x' = mean_b_USGALLUP_4_`x'  if varname  == "USGALLUP_4" & syear > `x'
	
	keep syear qid varname enddate anchor_`x'
	drop if anchor_`x' ==.	
	
	tempfile y`x'
    save `y`x'', replace 	
	}

	merge 1:1 qid using `y1989', nogen 
	merge 1:1 qid using `y1991', nogen
	drop qid varname 
	
	egen anchor = rowmean(anchor_*)
	la var anchor "Average"	
	
	
	local yr " 1991 1989 1993"
	foreach x of local yr {
	la var  anchor_`x' "Anchoring year: `x' "
	}

	
	sort syear 
	#delimit; 
	twoway (line anchor syear ,lwidth(medthick))
		   (line anchor_1989 syear ,lp(solid) lcolor(gs10%30))
		   (line anchor_1991 syear ,lp(solid) lcolor(gs8%30))
		   (line anchor_1993 syear ,lp(solid) lcolor(gs3%30)) 
		   ,
		   xlab(1970(10)2020)
		   ylab(0(10)100)
		   xtitle(year)
		   title(GSS and Gallup)
		   ;
	# delimit cr
	
	graph export "$image/takingout1977.png",replace 


* PEW GALLUP 
* how many overlapping years ? 
use scaling, clear 
	tab syear varname if inlist(varname, "PEW", "USGALLUP_4")
	*looks fine 
	save adj, replace   // data that deleted survey that has multiples  dates 
	


* "2005 2006 2007 2008 2010 2009 2011 2012 2013  2017"
local yr "2005 2006 2007 2008 2010 2009 2011 2012 2013 2015 2017"
	foreach x of local yr {
	anchor `x' USGALLUP_4 PEW
	
	g       anchor_`x' = mean_b_USGALLUP_4_`x'   if varname =="USGALLUP_4"    & syear <= `x'
	replace anchor_`x' = mean_b_PEW_`x'          if varname == "PEW"          & syear > `x'
	
	keep syear qid varname enddate anchor_`x'
	drop if anchor_`x' ==.
	
	tempfile y`x'
    save `y`x'', replace 
	}
	merge 1:1 qid using `y2005.dta', nogen 
	merge 1:1 qid using `y2006.dta', nogen
	merge 1:1 qid using `y2007.dta', nogen
	merge 1:1 qid using `y2008.dta', nogen
	merge 1:1 qid using `y2009.dta', nogen
	merge 1:1 qid using `y2010.dta', nogen
	merge 1:1 qid using `y2011.dta', nogen
	merge 1:1 qid using `y2012.dta', nogen
	merge 1:1 qid using `y2013.dta', nogen
	merge 1:1 qid using `y2015.dta', nogen


	sort syear
	drop qid varname 
	egen anchor = rowmean(anchor_*)
	
	la var anchor "Average"
	
	local yr "2005 2006 2007 2008 2010 2009 2011 2012 2013 2015 2017"
	foreach x of local yr {
	la var  anchor_`x' "Anchoring year: `x' "
	}
	
	sort enddate 
	#delimit; 
	twoway (line anchor syear, lwidth(medthick))
	       (line anchor_2005 syear, lp(solid) lcolor(gs13%30)) 
		   (line anchor_2006 syear, lp(solid) lcolor(gs12%30))
		   (line anchor_2007 syear, lp(solid) lcolor(gs11%30))
		   (line anchor_2008 syear, lp(solid) lcolor(gs10%30))
		   (line anchor_2009 syear, lp(solid) lcolor(gs9%30))
		   (line anchor_2010 syear, lp(solid) lcolor(gs8%30))
		   (line anchor_2011 syear, lp(solid) lcolor(gs7%30))
		   (line anchor_2012 syear, lp(solid) lcolor(gs6%30))
		   (line anchor_2013 syear, lp(solid) lcolor(gs5%30))
		   (line anchor_2015 syear, lp(solid) lcolor(gs4%30))
		   (line anchor_2017 syear, lp(solid) lcolor(gs3%30))
		   ,
		   xlab(1970(10)2020)
		   ylab(0(10)100)
		   xtitle(year)
		   title(Gallup and PEW)
		   legend(ring(0) 
		        order  (1 "Average" 
				        ))
		   
		   ;
	# delimit cr
	graph save Graph "$image\gallup_pew.gph", replace 

	graph combine "$image\gss_gallup.gph" "$image\gallup_pew.gph" , note(Note: Grey lines are the scaling results with different anchoring years)
	graph export "$image\total.png",replace 

	order syear qid varname enddate anchor_2005-anchor_2013
	
	
	
	export delimited using gallup_pew.csv , replace 
	
	grc1leg  USGALLUP_4_PEW_2005.gph  USGALLUP_4_PEW_2006.gph USGALLUP_4_PEW_2007.gph USGALLUP_4_PEW_2008.gph   ///
	USGALLUP_4_PEW_2009.gph USGALLUP_4_PEW_2010.gph  USGALLUP_4_PEW_2011.gph  USGALLUP_4_PEW_2013.gph  USGALLUP_4_PEW_2015.gph USGALLUP_4_PEW_2017.gph , ///
	legendfrom(USGALLUP_4_PEW_2005.gph)ring(0) pos(4) span

graph export "$image/gallup_pew.png",replace 

*merge two time series 
  import delimited using gallup_pew.csv, clear 
	drop varname qid 
	rename anchor* galluppew*

	
*======Gallup and every other survey ==========
	use scaling.dta, clear 
    keep syear varname qid nsurvey
	duplicates drop 
	*identify surveys that overlap with gallup 
	g lap_1= (varname =="USGALLUP_4" & nsurvey >1) 
	bysort syear: egen lap=max(lap_1)
	
	keep qid lap 
	
	merge 1:m qid using scaling, nogen 
	
	*for each pairs, calculate the mean 
	
	
	
	
	
