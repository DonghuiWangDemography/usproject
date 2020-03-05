* simulation 
*created on 03/03/2020

   
*=======================simulation========================
global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 
*global image   "/Users/donghui/Dropbox/Website/US_project" // mac

clear 

*latent attitude mean 

numlist "1/10"
local n :word count `r(numlist)'
mat mu=J(`n', 1, -99)
mat mu0=J(`n', 1, -99)

	forval i =1/10 {
	  mat mu[`i', 1] = sin(`i')
	  
	  mat mu0[`i', 1]=mu[`i'-.84147098, 1]  // anchor 1st yr to be zero
	} 
	
	mat mu0[1, 1] = 0
	
	svmat mu0, names(mu)
	rename mu1 mu
	gen s=_n if !missing(mu)
 
	expand  10000
	
	*more observations at overlapping years 
	expand 2 if inrange(s, 5,6)

	g  y=rnormal(0,1) + mu

	

* simulate survey 
* survey 1: yr 1 - 6 ,  4 scale : 1, 2, 3, 4 ;       
* survey 2: yr 4 - 10 , 5 scale : 1, 2, 3, ,4, 5 ;  


g       q= 1 if inrange(s, 1,4) 
replace q= 2 if inrange(s, 7,10)

*overlapping years : random assign 1, 2 
replace q =int(2*runiform()+1) if inrange(s, 5,6)

*cut-off points: based on percentile
sum y, detail
mat tau1 = (`r(p10)' \ `r(p50)' \ `r(p90)')
mat tau2 = (`r(p10)' \ `r(p25)' \ `r(p75)' \ `r(p90)')



g k=.
  replace k= 1 if y< tau1[1,1]                    & q==1 
  replace k= 2 if inrange(y,tau1[1,1], tau1[2,1]) & q==1 
  replace k =3 if inrange(y,tau1[2,1], tau1[3,1]) & q==1 
  replace k =4 if y>tau1[3,1] & q==1 

  replace k= 1 if y< tau2[1,1]                    & q==2 
  replace k= 2 if inrange(y,tau2[1,1], tau1[2,1]) & q==2
  replace k =3 if inrange(y,tau2[2,1], tau1[3,1]) & q==2 
  replace k =4 if inrange(y,tau2[3,1], tau1[4,1]) & q==2 
  replace k =5 if y>tau2[4,1]                     & q==2

  
  

 *============================================================ 
  * starting from an ordered probit 
 
  program drop obit 
  
  program define obit 

  args	 lnf mu tau1 tau2 tau3   // cut off point 
  
  quietly {
  
    replace `lnf' =ln(normal(`tau1' - `mu' ))                           if $ML_y1 ==1 
    replace `lnf' =ln(normal(`tau2' - `mu')  -  normal(`tau1' - `mu'  ))  if $ML_y1 ==2 
    replace `lnf' =ln(normal(`tau3' - `mu' )  - normal(`tau2' - `mu'  ))  if $ML_y1 ==3 
    replace `lnf' =ln(1 - normal(`tau3' - `mu' ))                       if $ML_y1 ==4 

  }
 end 
   
   
   // keep only one survey
   
   preserve 
   keep if q==1   
   
   ml model lf obit (k = i.s, noconstant) () () ()  // mu as a function of time, other only constant
   ml check 
   ml search 
   ml maximize 
   
   return list
   mat a=r(table)
   
   mat def=a[1, 1..6]
   
   
   *stata's buit in function 
   oprobit k  i.s  // oprobit looks fine 
   mat b=r(table)
   mat mub=b[1, 1..6]   
   
   mat mu0_one= mu0[1..6,1]
   
   *compare user-written function and actual trend 
   
   mat emu=mu0_one , def'   
   
   svmat emu 
   rename emu1 Estimates
   rename emu2 Actural 
   
   g t=_n if !missing(Estimates)
   
   sort t 
   twoway (line Actural t)  (line Estimates t) 
   graph export  "$image\first.png" , replace  
  
   restore 
   
*============================================
   

*===multiple years , two survyes========

  program drop obit 
  
  program define obit 

  args 	 lnf mu tau1_1 tau1_2 tau1_3  tau2_1 tau2_2  tau2_3 tau2_4   // cut off point 

  quietly {
  
	// survey 1 
    replace `lnf' =ln(normal(`tau1_1' -`mu'))                             if $ML_y1 ==1 & q==1
	replace `lnf' =ln(normal(`tau1_2'  -`mu')  - normal(`tau1_1' -`mu' )) if $ML_y1 ==2 & q==1
    replace `lnf' =ln(normal(`tau1_3'  -`mu')  - normal(`tau1_2' -`mu'))  if $ML_y1 ==3 & q==1
    replace `lnf' =ln(1 - normal(`tau1_3'  -`mu' ))                       if $ML_y1 ==4 & q==1
	
	// survey 2
	replace `lnf' =ln(normal( `tau2_1' -`mu'))                            if $ML_y1 ==1 & q==2
	replace `lnf' =ln(normal(`tau2_2' -`mu')  - normal( `tau2_1' -`mu'))  if $ML_y1 ==2 & q==2
    replace `lnf' =ln(normal(`tau2_3' -`mu')  - normal( `tau2_2' -`mu'))  if $ML_y1 ==3 & q==2
	replace `lnf' =ln(normal(`tau2_4' -`mu')  - normal( `tau2_3' -`mu'))  if $ML_y1 ==4 & q==2
    replace `lnf' =ln(1 - normal(`tau2_4'  -`mu'))                        if $ML_y1 ==5 & q==2
	
  }
 end 

    ml model lf obit (k= i.s, noconstant)  ///
					 ()  ()  ()            ///
	                 ()  ()  ()  ()       

   ml check 
   ml search    
   ml maximize , difficult
   mat c=r(table)
   

   mat e_mu = c[1,1..10]'
   mat e_ci=c[5..6,2..10]'
   
   mat e_tau1=c[1,11..13]'
   mat e_tau2=c[1,14..17]'
   
   mat com_mu=mu0, e_mu
   
   *compare actural Vs estimated cut-off
   mat com_tau1=tau1,e_tau1
   mat com_tau2=tau2,e_tau2
   
   mat list com_tau1 , format (%9.3f) 
   mat list com_tau2 , format (%9.3f) 

   
   *graph estimated results   
   svmat com_mu
   rename com_mu1 Actural
   rename com_mu2 Estimate
   
   
   gen t= _n if !missing(Actural)
   
   
   sort  t
   twoway (line Actural t) (line Estimate t) , xlab (1/10) 
   
   graph export  "$image\twosurvey_simulation.png" , replace  

   
 *========== Extend to multiple surveys ==============
 *simulate the third  survey : runs from 3 - 7 
  
  local newobs = _N + 5 
  set obs `newobs' 
  
  replace q =3 if q ==.
  
  bysort q: replace s=_n+2 if mu ==. & q ==3 
  
  expand 1000 if mu ==.
 
  
  forvalues i = 3/7 {
  replace mu= mu0[`i', 1] if mu ==. 
  replace y = mu0[`i', 1] + rnormal(0,1) if k ==.
  
  }
  
  *three levels , two cut - off points 
  sum y if q== 3, detail
  mat tau3 = (`r(p25)' \ `r(p75)')
  
  
  replace k= 1 if y< tau3[1,1]                    & q==3 
  replace k= 2 if inrange(y,tau3[1,1], tau3[2,1]) & q==3
  replace k =3 if y>tau3[2,1]                     & q==3

  
  
  program drop obit 
  
  program define obit 

  args 	 lnf mu tau1_1 tau1_2 tau1_3 tau2_1 tau2_2  tau2_3 tau2_4  tau3_1 tau3_2  // cut off point 

  quietly {
  
	// survey 1 
    replace `lnf' =ln(normal(`tau1_1' -`mu'))                             if $ML_y1 ==1 & q==1
	replace `lnf' =ln(normal(`tau1_2'  -`mu')  - normal(`tau1_1' -`mu' )) if $ML_y1 ==2 & q==1
    replace `lnf' =ln(normal(`tau1_3'  -`mu')  - normal(`tau1_2' -`mu'))  if $ML_y1 ==3 & q==1
    replace `lnf' =ln(1 - normal(`tau1_3'  -`mu' ))                       if $ML_y1 ==4 & q==1
	
	// survey 2
	replace `lnf' =ln(normal( `tau2_1' -`mu'))                            if $ML_y1 ==1 & q==2
	replace `lnf' =ln(normal(`tau2_2' -`mu')  - normal( `tau2_1' -`mu'))  if $ML_y1 ==2 & q==2
    replace `lnf' =ln(normal(`tau2_3' -`mu')  - normal( `tau2_2' -`mu'))  if $ML_y1 ==3 & q==2
	replace `lnf' =ln(normal(`tau2_4' -`mu')  - normal( `tau2_3' -`mu'))  if $ML_y1 ==4 & q==2
    replace `lnf' =ln(1 - normal(`tau2_4'  -`mu'))                        if $ML_y1 ==5 & q==2
	
	// survey 3 
	replace `lnf' =ln(normal( `tau3_1' -`mu'))                            if $ML_y1 ==1 & q==3
	replace `lnf' =ln(normal(`tau3_2' -`mu')  - normal( `tau3_1' -`mu'))  if $ML_y1 ==2 & q==3
    replace `lnf' =ln(1 - normal(`tau3_2'  -`mu'))                        if $ML_y1 ==3 & q==3
	
	
  }
 end 

   ml model lf obit (k= i.s, noconstant)  ///
					 ()  ()  ()            ///
	                 ()  ()  ()  ()       ///
					 ()  ()

   ml check 
   ml search    
   ml maximize , difficult
   mat c=r(table)
 
   mat e_mu= c[1,1..10]'
   mat e_ci=c[5..6,1..10]'
   
   mat e_tau1=c[1,11..13]'
   mat e_tau2=c[1,14..17]'
   mat e_tau3=c[1,18..19]'
   
   mat com_mu=mu0, e_mu
   
   mat com_tau3=tau3, e_tau3
   
   *graph estimated results   
   svmat com_mu
   rename com_mu1 Actural
   rename com_mu2 Estimate
   
   
   gen t= _n if !missing(Actural)
   
   
   sort  t
   twoway (line Actural t) (line Estimate t) , xlab (1/10) 
   

 
// program drop _all 
// program define par_shift
//
// version 1.0
//
// 	levelsof s, local(s)    //time 
//     levelsof q, local(q)    //questionaire 
// 	levelsof k, local(k)   // response level 
//	
// 	foreach t of local s {
// 	foreach q of local q {
// 	foreach k of local k {
// 	local k_1 = `k'-1
//	
// 	args  lnf  mu_`t'  tau_`q'_`k'
//
//     quietly replace `lnf' = ln(normal(tau_`q'_`k' - mu_`t'))  if `k' == 1
// 	quietly replace `lnf' = ln(normal(tau_`q'_`k' - mu_`t')  - normal(tau_`q'_`k_1' - mu_`t')) if inrange(`k', 2, scale_1)
// 	quietly replace `lnf' = ln(1 - normal(tau_`q'_`k' - mu_`t')) if `k'== scale 
//	
// 	}
// 	}
// 	}
//
//    end 

// * set trace on 
//    ml model lf par_shift  k
//    ml check 
//    ml search repeat(100)
//    ml maximize
