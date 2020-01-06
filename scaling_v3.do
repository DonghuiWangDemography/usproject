*scaling 3rd version
*last do file scaling_v2.do 
*Task : anchoring year scaling 
*created on 01032020

*update to test github 

// cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"
// global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 

// cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"   // mac
// global image /Users/donghui/Dropbox/Website/US_project/image


*******three programs : midpoint, pct_mapping and base*********

*------midpoint within year rescale--------
program drop _all 

program midpoint 
args year name 

 use scaling.dta , clear 
 keep if syear ==`year' 

	*mid-point 
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 
	 
	sort questionid resp 
	
	levelsof resp if varname == "`name'", local(scale)
	display `scale'
	
	foreach i of local scale {
	g cut`i'=.
	replace cut`i' =midpoint if resp==`i' & varname == "`name'" 
	egen cut`i'_rf= max(cut`i')
	g dif`i'= abs(cut`i'_rf -midpoint)
	drop cut`i'
	drop cut`i'_rf
	}
	
	egen mindif=rowmin(dif*)

	g newscale =.
	foreach i of local scale {
	replace newscale = `i' if dif`i' == mindif  
	} 
	
	keep  resp varname newscale 
end 

	

*------linear pct mapping---------- 

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


*-------within-survey rescaling------- 

program base 

 args year name 


use scaling.dta, clear 
	keep if varname == "`name'"

	*mid-point 
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 
	
	levelsof resp if syear ==`year', local(level)
			
foreach i of local level {
	g cut`i'=.
	replace cut`i' =midpoint if resp==`i' & syear ==`year' 
	
	egen cut`i'_rf= max(cut`i')
	g dif`i'= abs(cut`i'_rf -midpoint)
	drop cut`i'
	drop cut`i'_rf
	}
	egen mindif=rowmin(dif*)
		
	g r_`name'_`year' =.
	
	levelsof resp if syear ==`year', local(level)
	
	foreach i of local level  {
	replace r_`name'_`year' = `i' if dif`i' == mindif 
}

	keep sid resp syear r_`name'_`year' 
	
	
end 

********end of the programs ****************	




* ==========Anchor gallup onto gss =========

*one to one mapping for 1994 gallup to 0 - 100 scale 
pct_mapping 1993 GSS
	mkmat resp b_GSS_1993, mat(s_gss)
	mat list s_gss	


midpoint 1993 GSS
	sort varname resp 
	keep if varname =="USGALLUP_4"
	
	g b_gss =.
	
	forval i=1/10 {
	replace b_gss = s_gss[`i', 2] if newscale == `i' 
	
	}
	mkmat resp b_gss, mat(bs_gss)
	mat list bs_gss

	
base 1993 USGALLUP_4
	g b_gss=.
	forval i=1/4 {
	replace b_gss = bs_gss[`i', 2] if r_USGALLUP_4_1993 == `i' 
	}
	
	tempfile gallup 
	save `gallup.dta', replace 
	
	
base 1993 GSS 
	g s_gss =.
	forval i=1/10 {
	replace s_gss = s_gss[`i', 2] if r_GSS_1993 == `i'
	}
	merge 1:1 sid using scaling, nogen
	merge 1:1 sid using  `gallup.dta', nogen 
	
	keep if varname == "GSS" | varname == "USGALLUP_4"
	
	keep syear resp nresp n sid varname s_gss b_gss enddate questionid	qid
	save gss_gallup_93,replace 
	
*calculate mean 
	 foreach x of varlist b_gss s_gss {
	 
	 g val_`x' = `x'  * nresp 
	 bysort questionid : egen tval_`x'=total(val_`x')
	 g mean_`x' = tval_`x' /n 
	 replace mean_`x' =. if mean_`x' ==0
	 
}
	 keep syear enddate mean*  varname	questionid qid
	 duplicates drop 
	
	 
	 
sort syear 
#delimit; 
twoway (connected mean_s_gss syear if varname == "GSS") 
	   (connected mean_b_gss syear if varname == "USGALLUP_4" & syear>1992) 
	    ,
	   xtitle(year)
	   ylab(45(5)60)
	   title(1993 GSS  as reference)
	   legend (
			ring(0)
			 order(1 "GSS"
				   2 "Gallup_4"
				   ))
	   ;
# delimit cr		

graph save Graph gss_r.gph, replace 

*prepare to export 
	 g        mean_gss_b = mean_s_gss if varname == "GSS"
	 replace  mean_gss_b = mean_b_gss if varname == "USGALLUP_4" & syear > 1992

	 keep syear varname questionid enddate mean_gss_b qid
	 
save scaling1, replace 

	
* -------Anchor GSS onto gallup -------- 
pct_mapping 1993 USGALLUP_4
	mkmat resp b_USGALLUP_4_1993, mat(s_gallup)
	mat list s_gallup	

*gss 
midpoint 1993  USGALLUP_4

	sort varname resp 
	keep if varname =="GSS"

	sort varname resp 
	g b_gallup =.
	
	forval i=1/4 {
	replace b_gallup = s_gallup[`i', 2] if newscale == `i' 
	
	}
	mkmat resp b_gallup, mat(bs_gallup)
	mat list bs_gallup
	

base 1993 GSS
	g b_gallup=.
	forval i=1/10 {
	replace b_gallup = bs_gallup[`i', 2] if r_GSS_1993 == `i' 
	
	}
	tempfile gss
	save `gss.dta', replace 


	
base 1993 USGALLUP_4 
	g s_gallup =.
	forval i=1/4 {
	replace s_gallup = s_gallup[`i', 2] if r_USGALLUP_4_1993 == `i'
	}
	merge 1:1 sid using scaling, nogen
	merge 1:1 sid using  `gss.dta', nogen 
	
	keep if varname == "GSS" | varname == "USGALLUP_4"
	
	*calculate mean 
	 foreach x of varlist b_gallup s_gallup {
	 
	 g val_`x' = `x'  * nresp 
	 bysort questionid : egen tval_`x'=total(val_`x')
	 g mean_`x' = tval_`x' /n 
	 replace mean_`x' =. if mean_`x' ==0
	 
}
	 keep syear enddate mean*  varname questionid qid
	 duplicates drop 
	 sort syear 
	 
sort syear 	 
#delimit; 
twoway (connected mean_b_gallup syear if varname == "GSS") 
	   (connected mean_s_gallup syear if varname == "USGALLUP_4" & syear >1992) 
	    ,
	   xtitle(year)
	   ylab(0(10)100)
	   title(1993 Gallup as reference)
	   legend (
			ring(0)
			 order(1 "GSS"
				   2 "Gallup_4"
				   ))
	   ;
# delimit cr	
	
graph save Graph gallup_r.gph, replace 
	 
graph combine  gss_r.gph  gallup_r.gph
graph export "$image\b_1993.png",replace 


*prepare to export 
	 g        mean_gallup_b = mean_b_gallup if varname == "GSS"
	 replace  mean_gallup_b = mean_s_gallup if varname == "USGALLUP_4" & syear>1992
	 
	 keep syear varname questionid enddate mean_gallup_b qid
	 
save scaling2, replace 


*----------2 anchoring years for three surveys-------

* Anchor gallup and pew using 2005, gallup and GSS with 1993 
* pew newscale (scaled with GSS 1993) , re-calculate midpoint 

use gss_gallup_93, clear
keep if syear ==2005 
	
mkmat resp b_gss, mat(s2_gss)
	mat list s2_gss



base 2005 PEW  // covert to 2005 pew 
	g s2_gss =.
	forval i= 1/4 {
	replace s2_gss = s2_gss[`i', 2] if r_PEW_2005 == `i' 
	}
		merge 1:1 sid using  scaling , nogen 
		merge 1:1 sid using  gss_gallup_93 , nogen 
		
	keep if inlist(varname, "GSS", "USGALLUP_4", "PEW")
	
	*calculate mean 
	 foreach x of varlist b_gss s_gss s2_gss {
	 
	 g val_`x' = `x'  * nresp 
	 bysort questionid : egen tval_`x'=total(val_`x')
	 g mean_`x' = tval_`x' /n 
	 replace mean_`x' =. if mean_`x' ==0
	 
}
	 keep syear enddate mean*  varname questionid qid 
	 duplicates drop 
	 sort syear 	

	 
sort syear 
#delimit; 
twoway (connected mean_s_gss syear if varname == "GSS") 
	   (connected mean_b_gss syear if varname == "USGALLUP_4" & inrange(syear, 1992, 2005)) 
	   (connected mean_s2_gss syear if varname == "PEW"  )
	    ,
	   xtitle(year)
	   title("1993 GSS, 2005 Gallup as references")
	   legend (
			ring(0)
			 order(1 "GSS"
				   2 "Gallup_4"
				   3 "PEW"
				   ))
	   ;
# delimit cr		

graph save Graph gss_pew.gph, replace 


*prepare to export 
	g 		mean_gss_b2 = mean_s_gss  if varname == "GSS" 
	replace mean_gss_b2 = mean_b_gss  if varname == "USGALLUP_4" & inrange(syear, 1992, 2005)
	replace mean_gss_b2 = mean_s2_gss if varname == "PEW"
		
	keep syear varname questionid enddate  qid mean_gss_b2
	 
save scaling3, replace 


* -----2005 pew, 1993 gallup ------

pct_mapping 2005 PEW
	mkmat resp b_PEW_2005 , mat(b_pew)
	mat list b_pew	

*gallup  
midpoint 2005  USGALLUP_4
	keep if varname == "USGALLUP_4"
	
	sort varname resp 
	g s_pew =.
	
	forval i=1/4 {
	replace s_pew = b_pew[`i', 2] if newscale == `i' 
	
	}
	mkmat resp s_pew , mat(bs_pew)
	mat list bs_pew
	

base 2005 USGALLUP_4

	g b_pew=.
	forval i=1/4 {
	replace b_pew = bs_pew[`i', 2] if r_USGALLUP_4_2005 == `i' 
	
	}
	tempfile gallup 
	save `gallup.dta', replace 

	
base 2005 PEW 
	g s_pew =.
	forval i=1/4 {
	replace s_pew = b_pew[`i', 2] if r_PEW_2005 == `i'
	}
	merge 1:1 sid using scaling, nogen
	merge 1:1 sid using  `gallup.dta', nogen 
	
	keep if varname == "PEW" | varname == "USGALLUP_4"
    save pew_gallup, replace 

	

use pew_gallup, clear
keep if syear ==1993 

mkmat resp b_pew, mat(s2_pew)
	mat list s2_pew
	

midpoint 1993 USGALLUP_4
	keep if varname == "GSS"
	g s2_pew =.
	forval i= 1/4 {
	replace s2_pew = s2_pew[`i', 2] if newscale == `i' 
	}
	
	mkmat resp s2_pew , mat(bs2_pew)
	mat list bs2_pew
	
	
base 1993 GSS
	g s2_pew =.
	forval i=1/10 {
	replace s2_pew =bs2_pew[`i', 2] if r_GSS_1993 == `i'
	}
	merge 1:1 sid using scaling, nogen
	merge 1:1 sid using pew_gallup, nogen 
	
 
	keep if inlist(varname, "GSS", "USGALLUP_4", "PEW")
	
	*calculate mean 
	 foreach x of varlist b_pew s_pew s2_pew {
	 
	 g val_`x' = `x'  * nresp 
	 bysort questionid : egen tval_`x'=total(val_`x')
	 g mean_`x' = tval_`x' /n 
	 replace mean_`x' =. if mean_`x' ==0
	 
}
	 keep syear enddate mean*  varname questionid qid
	 duplicates drop 
	 sort syear 	

	 
sort syear 
#delimit; 
twoway (connected mean_s2_pew syear if varname == "GSS") 
	   (connected mean_b_pew syear if varname == "USGALLUP_4" & inrange(syear, 1992, 2005)) 
	   (connected mean_s_pew syear if varname == "PEW"  )
	    ,
	   xtitle(year)
	   ylab(45(5)60)
	   title("2005 PEW, 1993 Gallup as references")
	   legend (
			ring(0)
			 order(1 "GSS"
				   2 "Gallup_4"
				   3 "PEW"
				   ))
	   ;
# delimit cr		
graph save Graph pew_gss.gph, replace 

graph combine  gss_r.gph  gallup_r.gph gss_pew.gph pew_gss.gph

graph export "$image/scaling4_03012019.png",replace 


* prepare to export 
	g        mean_pew_b = mean_s2_pew if varname == "GSS"
	replace  mean_pew_b = mean_b_pew  if varname == "USGALLUP_4" & inrange(syear, 1992, 2005)
	replace  mean_pew_b = mean_s_pew  if varname == "PEW"
    
	keep syear enddate varname questionid qid mean_pew_b
	
	merge 1:1 qid using scaling1, nogen
	merge 1:1 qid using scaling2, nogen 
	merge 1:1 qid using scaling3, nogen 

order syear enddate varname questionid mean_gss_b mean_gallup_b mean_gss_b2 mean_pew_b

export delimited using "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\scaling_4base_01052019.csv", replace


sort syear 
#delimit; 
twoway (connected mean_gss_b syear ) 
	   (connected mean_gallup_b syear ) 
	   (connected mean_gss_b2 syear )
	   (connected mean_pew_b syear )
  ,
	   xtitle(year)
	   ylab(0(5)100)
	   title("compare")
	   legend (
			ring(0)
			 order(1 "1993 GSS "
				   2 "1993 Gallup"
				   3 "1993 GSS, 2005 Gallup"
				   4 "2005 PEW, 1993 Gallup"
				   ))
	   ;
# delimit cr	

graph export "$image/compare.png",replace 

// graph export "$image\gss_ref_panel.png",replace 	
// sort anchored 
// #delimit;
// twoway (connected nresp anchored if syear == 1974)
//        (connected nresp anchored if syear == 1975)
//        (connected nresp anchored if syear == 1977)
// 	   (connected nresp anchored if syear == 1982)
// 	   (connected nresp anchored if syear == 1983)
// 	   (connected nresp anchored if syear == 1985)
// 	   (connected nresp anchored if syear == 1989)
// 	   (connected nresp anchored if syear == 1990)
// 	   (connected nresp anchored if syear == 1993)
// 		, 
// 	   legend(col(1) 
// 			ring(0)
// 			 order(1 "1974"
// 				   2 "1975"
// 				   3 "1977"
// 				   4 "1982"
// 				   5 "1983"
// 				   6 "1985"
// 				   7 "1989"
// 				   8 "1990"
// 				   9 "1993"
// 				   ))
// 		;
// #delimit cr


*--1991--

*one to one mapping for 1994 gallup to 0 - 100 scale 
pct_mapping 1991 GSS
	mkmat resp b_GSS_1991, mat(s_gss)
	mat list s_gss	


midpoint 1991 GSS
	sort varname resp 
	keep if varname =="USGALLUP_4"
	
	g b_gss =.
	
	forval i=1/10 {
	replace b_gss = s_gss[`i', 2] if newscale == `i' 
	
	}
	mkmat resp b_gss, mat(bs_gss)
	mat list bs_gss

	
base 1991 USGALLUP_4
	g b_gss=.
	forval i=1/4 {
	replace b_gss = bs_gss[`i', 2] if r_USGALLUP_4_1991 == `i' 
	}
	
	tempfile gallup 
	save `gallup.dta', replace 
	
	
base 1991 GSS 
	g s_gss =.
	forval i=1/10 {
	replace s_gss = s_gss[`i', 2] if r_GSS_1991 == `i'
	}
	merge 1:1 sid using scaling, nogen
	merge 1:1 sid using  `gallup.dta', nogen 
	
	keep if varname == "GSS" | varname == "USGALLUP_4"
	
	keep syear resp nresp n sid varname s_gss b_gss enddate questionid	
	save gss_gallup_91,replace 
	
	*calculate mean 
	 foreach x of varlist b_gss s_gss {
	 
	 g val_`x' = `x'  * nresp 
	 bysort questionid : egen tval_`x'=total(val_`x')
	 g mean_`x' = tval_`x' /n 
	 replace mean_`x' =. if mean_`x' ==0
	 
}
	 keep syear enddate mean*  varname 	 questionid	 
	 duplicates drop 
	 
	 
sort syear 
#delimit; 
twoway (connected mean_s_gss syear if varname == "GSS") 
	   (connected mean_b_gss syear if varname == "USGALLUP_4" & syear >1990 ) 
	    ,
	   ylabel(0(10)100)
	   xtitle(year)
	   title(1991 GSS  as reference)
	   legend (
			ring(0)
			 order(1 "GSS"
				   2 "Gallup_4"
				   ))
	   ;
# delimit cr		
	
