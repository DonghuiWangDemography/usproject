*simulation with JM's data
* created on 05/31/2020
cd "C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data"     // laptop
global image "C:\Users\wdhec\Dropbox\Website\US_project\image"  // laptop 


import delimited C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data\2020-05-28-simulation-random.csv, clear 

g t= year +1

mat tau1=(-1.577 , 0.02 , 1.604)
mat tau2=(-2.206,-0.824, 0.867, 1.414)
*survey1 
/*
-1.577
0.02
1.604
*/

*survey2
/*
-2.206
-0.824
0.867
1.414
*/

	

drop bininsurvey1 bininsurvey2 binninginsurvey1 binninginsurvey2

*random sample survey 1 : each year sample 10 % ? 
rename k1observedresponseinsurvey1 k1
rename k2observedresponseinsurvey2 k2
rename yindividualattitude y 
rename muyearattitude mu

// 	sort t 
// 	twoway (line mu  t, lcolor(red)) (scatter  y t , mlcolor(black) msymbol(Oh)), xlab(0(2)10) xtitle(T) ///
// 	legend(order (1 "mu{sub:t}"  2 "y*{sub:it} "))
//
//  graph export "$image\sim_latent.png",replace 





*overlapping two years 5 and 6 
forval i=1/6 {
preserve 
sample 20 if t==`i'
drop if t != `i'
tempfile s`i'
save `s`i'.dta', replace 
restore 
}

use `s6.dta', clear 
append using `s1.dta'
append using `s2.dta'
append using `s3.dta'
append using `s4.dta'
append using `s5.dta '

drop k2 
rename k1 k 

// *overlapping only one year: 5 
// forval i=1/5 {
// preserve 
// sample 20 if t==`i'
// drop if t != `i'
// tempfile s`i'
// save `s`i'.dta', replace 
// restore 
// }
//
// use `s5.dta', clear 
// append using `s1.dta'
// append using `s2.dta'
// append using `s3.dta'
// append using `s4.dta'
//
// drop k2 
// rename k1 k 


g survey=1 
save survey1.dta, replace 


*survey2 
import delimited C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data\2020-05-28-simulation-random.csv, clear 

g t= year +1
drop bininsurvey1 bininsurvey2 binninginsurvey1 binninginsurvey2

*random sample survey 1 : each year sample 10 % ? 
rename k1observedresponseinsurvey1 k1
rename k2observedresponseinsurvey2 k2

forval i=5/10 {
preserve 
sample 10 if t==`i'

drop if t != `i'

tempfile s`i'
save `s`i'.dta', replace 
restore 
}

use `s5.dta', clear 
append using `s6.dta'
append using `s7.dta'
append using `s8.dta'
append using `s9.dta'
append using `s10.dta'

drop k1 
rename k2 k 

g survey=2 

append using survey1.dta 

erase survey1.dta
save sim_jm, replace 

*----------Graphing-------------
 use sim_jm, clear 
 
  *calculate cdf

  tab k, gen(k_)
  collapse k_*, by(t survey)
  
  //gen t=k_1+k_2+k_3+k_4+k_5
  g k1=k_1
  g k2=k_1 + k_2
  g k3=k2+k_3
  g k4=k3+k_4
  g k5=k4+k_5


  local s1 "black"
  local s2 "black"
  local s1p "solid"
  local s2p "longdash_dot"
  
  tab k1 if survey==2 & t==10
  
  #delimit;
  twoway (line k1 t if survey==1 , lp(`s1p') lcolor(`s1'*.5) text(0.06 0.5 "y{sub:1}=1" , color(`s1'*.5) ))
		 (line k2 t if survey==1 , lp(`s1p') lcolor(`s1'*.75)text(0.51 0.5 "y{sub:1}=2" , color(`s1'*.75) ))
		 (line k3 t if survey==1 , lp(`s1p') lcolor(`s1'*1)  text(0.94 0.5 "y{sub:1}=3" , color(`s1'*1) ))
		 (line k4 t if survey==1 , lp(`s1p') lcolor(`s1'*1.25)text(1 0.5 "y{sub:1}=4"    , color(`s1'*1.25) ))
		 (line k1 t if survey==2 , lp(`s2p') lcolor(`s2'*.5) text(.024 10.5 "y{sub:2}=1" , color(`s2'*.5) ))
		 (line k2 t if survey==2 , lp(`s2p') lcolor(`s2'*.75) text(0.28 10.5 "y{sub:2}=2" , color(`s2'*.75) ))
		 (line k3 t if survey==2 , lp(`s2p') lcolor(`s2'*1)   text(0.87 10.5 "y{sub:2}=3" , color(`s2'*1) ))
		 (line k4 t if survey==2 , lp(`s2p') lcolor(`s2'*1.25)text(0.95 10.5 "y{sub:2}=4" , color(`s2'*1.25) ))
		 (line k5 t if survey==2,  lp(`s2p') lcolor(`s2'*2) lp(solid)text(1 10.5 "y{sub:2}=5" , color(`s2'*2) ))
		 ,  xlab(0(2)11) legend(off) xtitle(T)
  ;
  #delimit cr 


  graph export "$image\sim_surveyc.png",replace 

*----------
*anchort first year to zero
 import delimited C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data\2020-05-28-simulation-random.csv, clear 
keep year muyearattitude

duplicates drop 
sort year
g mu0=mu-mu[1]
mkmat  mu0



*estimation 
use sim_jm.dta, clear
drop mu
rename t s 
rename muyearattitude mu


 *initial values 
  qui: oprobit k i.s
  mat c=r(table)
  mat s=c[1, "k:"]

  levelsof survey, local(survey)
  foreach x of local survey { 
  qui: oprobit k i.s if survey==`x' 
  qui: mat c=r(table)
  qui: mat tau`x'=c[1, " /:"]
  	
  }
  	//rename tau
	forval i= 1/2{
	
    mat colname tau`i'=_cons
	local n= `= colsof(tau`i')'
	local ctau`i' ""
	forval j=1/`n'{	
	local ctau`i' "`ctau`i'' tau`i'_`j'"  
	
	}
	mat coleq tau`i'= `ctau`i''
	}
	
  *put together intial values 
  mat e0=s,tau1, tau2
   
   

*===multiple years , two survyes========

  program drop obit 
  
  program define obit 

  args 	 lnf mu tau1_1 tau1_2 tau1_3  tau2_1 tau2_2  tau2_3 tau2_4   // cut off point 

  quietly {
  
	// survey 1 
    replace `lnf' =ln(normal(`tau1_1' -`mu'))                             if $ML_y1 ==1 & survey==1
	replace `lnf' =ln(normal(`tau1_2'  -`mu')  - normal(`tau1_1' -`mu' )) if $ML_y1 ==2 & survey==1
    replace `lnf' =ln(normal(`tau1_3'  -`mu')  - normal(`tau1_2' -`mu'))  if $ML_y1 ==3 & survey==1
    replace `lnf' =ln(1 - normal(`tau1_3'  -`mu' ))                       if $ML_y1 ==4 & survey==1
	
	// survey 2
	replace `lnf' =ln(normal( `tau2_1' -`mu'))                            if $ML_y1 ==1 & survey==2
	replace `lnf' =ln(normal(`tau2_2' -`mu')  - normal( `tau2_1' -`mu'))  if $ML_y1 ==2 & survey==2
    replace `lnf' =ln(normal(`tau2_3' -`mu')  - normal( `tau2_2' -`mu'))  if $ML_y1 ==3 & survey==2
	replace `lnf' =ln(normal(`tau2_4' -`mu')  - normal( `tau2_3' -`mu'))  if $ML_y1 ==4 & survey==2
    replace `lnf' =ln(1 - normal(`tau2_4'  -`mu'))                        if $ML_y1 ==5 & survey==2
	
  }
 end 

   
    capture program drop obit_e
    program def obit_e, eclass 
	
    
    ml model lf obit (k: k= i.s, noconstant)  ///
					 (tau1_1: )  (tau1_2: )  (tau1_3: )            ///
	                 (tau2_1: )  (tau2_2: ) (tau2_3: )  (tau2_4 : )  	
   ml init e0  // intial values obtained from ordered probit rountine 
   ml maximize , difficult
   end 
   
   // bootstrap confidence interval 
   obit_e
   ml display 
   
   bootstrap _b, reps(50) seed(1234): obit_e
   
   
   mat c=r(table)
   
   mat e_mu = c[1, "k:"]'
   mat e_ci=c[5..6,"k:"]'
   
   
   mat e_tau1=c[1, "tau1_1:" .. "tau1_3:"]'
   mat e_tau2=c[1, "tau2_1:" .. "tau2_4:"]'
   
   mat com_mu=mu0, e_mu
   
   *compare actural Vs estimated cut-off
   mat com_tau1=tau1',e_tau1
   mat com_tau2=tau2',e_tau2
   
   mat list com_tau1 , format (%9.3f) 
   mat list com_tau2 , format (%9.3f) 

/*
           r1       b
c1  -1.577  -1.554
c2   0.020   0.063
c3   1.604   1.670

  com_tau2[4,2]
        r1       b
c1  -2.206  -2.229
c2  -0.824  -0.808
c3   0.867   0.892
c4   1.414   1.445
*/ 
   
   
   *graph estimated results   
   svmat com_mu
   rename com_mu1 Actural
   rename com_mu2 Estimate
	  
   gen t= _n if !missing(Actural)
   
   svmat e_ci
   rename e_ci1 ll
   rename e_ci2 ul
   
  
  
   sort  t
   twoway (line Actural t if !missing(Actural),lcolor(red)) ///
          (line Estimate t if !missing(Estimate),lcolor(black))  ///
		  (rscatter  ul ll t, recast(rarea) color(%30)) ///
		   , legend( ring(0)) xlab (1(1)10) ylab(-1(0.2)1) xtitle(T) ///
		   legend(ring(0)  order ( 1 "Actrual" 2 "Estimates" 3 "95% Confidence Interval"))
  
 graph export "$image\sim_estimate_1yr.png",replace 
