*scaling 2nd version
*last do file scaling.do 
*Task : mapp other surveys into gallup_4

// cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"
// global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 

cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"
 

*midpoint
program drop _all

program midpointlong 
	args name 
	
use scaling.dta, clear
	drop if syear ==1955
	encode questionid, g(numsurvey)
	egen nsurvey=nvals(numsurvey), by(syear)

*rescale based on refrences 
levelsof syear if varname =="`name'" & nsurvey > 1, local(year)
foreach x of local year {
 use scaling.dta , clear 
 drop if syear ==1955

	*mid-point 
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 
	 
	keep if syear == `x' 
	
	sort questionid resp

	forval i=1/10 {
	g cut`i'=.
	replace cut`i' =midpoint if resp==`i' & varname == "`name'" 
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

save year_`x', replace 
display "==> year_`x'"

}

*append 
use scaling.dta, clear 
	drop if syear ==1955
	encode questionid, g(numsurvey)
	egen nsurvey=nvals(numsurvey), by(syear)
	drop numsurvey 
	
	sort  questionid resp  
	bysort questionid : g midpoint = pct/2 +cpt[_n-1]
	replace  midpoint = pct/2 if midpoint ==. 
	g   ref_`name'=1   

	levelsof syear if varname =="`name'" & nsurvey > 1, local(year)
	foreach x of local year{
		merge 1:1 sid using year_`x', nogen update 
	}

	!del *year_*.dta  // only works at windows platform 
	
sort varname syear


	la var syear "survey year"

save ref_`name'_midpoint, replace 

end 


* do midpoint for the rest 
	midpointlong GSS


	
	
*graph 
use  ref_USGALLUP_4_midpoint.dta, clear
sort syear 
#delimit ;	
twoway (connected newmean syear if varname == "PEW")
       (connected newmean syear if varname == "GSS")  
	   (connected newmean syear if varname == "USCBS_3")
	   (connected newmean syear if varname == "USKN_5"),
	   ylab(0(1)4)
	   ;
#delimit cr

*GSS
use ref_GSS_midpoint.dta, clear 

tab varname 
sort syear 
#delimit ;	
twoway (connected newmean syear if varname == "USGALLUP_4")
       (connected newmean syear if varname == "ABC")  ,
	   
	   ylab(1(1)10)
	   ;
#delimit cr	


use scaling.dta, clear 
	drop if syear ==1955
	encode questionid, g(numsurvey)
	egen nsurvey=nvals(numsurvey), by(syear)
	
*1989 and 2011 
	
	
// *gss export to R
// use GSS_China.dta,clear
// 	drop if china ==.d 
//		
// 	drop id 
// 	keep if inlist(year, 1974,1975,1977,1982,1983,1985,1986,1988,1989,1990,1991,1993)  //1994 is very strange
// 	clonevar syear =year 
// 	g id=_n
// 	clonevar wt = wtssall
//
// 	recode china (0=10) (1=9)(2=8)(3=7)(4=6)(5=5)(6=4)(7=3)(8=2)(9=1) (.d= 999), gen(resp)
// 	drop if resp == 999 
//	
// keep year resp
// save gss_r, replace 
*-----continous reference --------------
