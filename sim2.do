* simulation 
*created on 03/03/2020



* set trace off 
   
*=======================simulation========================
global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 
*global image   "/Users/donghui/Dropbox/Website/US_project" // mac

clear 

*latent attitude :10 years,  
set obs 100000
set seed 12202019

g s=  int(10*runiform() + 1)  

*more observations at overlapping years 
expand 2 if inrange(s, 5,6)

g mu =.
forval i =1/10 {
	replace mu = sin(`i') if s ==`i'
} 
    tab mu if s==1 
	g mu0= mu - .841471
    g  y=rnormal(0,1) + mu0

	sort s
	twoway (line mu s) (scatter y s) , xtitle(year)
    graph export  "$image\attitude.png" , replace  
	

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
  
    replace `lnf' =ln(normal(`mu' - `tau1'))                           if $ML_y1 ==1 
    replace `lnf' =ln(normal(`mu' - `tau2')  - normal(`mu' - `tau1'))  if $ML_y1 ==2 
    replace `lnf' =ln(normal(`mu' - `tau3')  - normal(`mu' - `tau2'))  if $ML_y1 ==3 
    replace `lnf' =ln(1 - normal(`mu' - `tau3'))                       if $ML_y1 ==4 

  }
 end 
   
   keep if q==1  // keep only one survey 
   
  
   ml model lf obit (k = i.s, noconstant) () () ()  // mu as a function of time, other only constant
   ml check 
   ml search 
   ml maximize 
   
   return list
   mat a=r(table)
   
   mat def=a[1, 2..6]
   
   *stata's buit in function 
   oprobit k  i.s  // oprobit looks fine 
   mat b=r(table)
   mat mub=b[1, 2..6]   
   
   
   mat emu=def', mub'  
   
   svmat emu 
   g t=_n if !missing(emu1)
   
   sort t 
   twoway (line emu1 t) (line emu2 t) (scatter mu s)
 
*============================================
   

*===multiple years , two survyes========

  program drop obit 
  
  program define obit 

  args 	 lnf mu tau1_1 tau1_2 tau1_3  tau2_1 tau2_2  tau2_3 tau2_4   // cut off point 

  quietly {
  
	// survey 1 
    replace `lnf' =ln(normal(`mu' - `tau1_1'))                             if $ML_y1 ==1 & q==1
	replace `lnf' =ln(normal(`mu' -`tau1_2')  - normal(`mu'  - `tau1_1'))  if $ML_y1 ==2 & q==1
    replace `lnf' =ln(normal(`mu' - `tau1_3')  - normal(`mu' - `tau1_2'))  if $ML_y1 ==3 & q==1
    replace `lnf' =ln(1 - normal(`mu' - `tau1_3'))                         if $ML_y1 ==4 & q==1
	
	// survey 2
	replace `lnf' =ln(normal(`mu' - `tau2_1'))                             if $ML_y1 ==1 & q==2
	replace `lnf' =ln(normal(`mu' - `tau2_2')  - normal(`mu' - `tau2_1'))  if $ML_y1 ==2 & q==2
    replace `lnf' =ln(normal(`mu' - `tau2_3')  - normal(`mu' - `tau2_2'))  if $ML_y1 ==3 & q==2
	replace `lnf' =ln(normal(`mu' - `tau2_4')  - normal(`mu' - `tau2_3'))  if $ML_y1 ==4 & q==2
    replace `lnf' =ln(1 - normal(`mu' - `tau2_4'))                         if $ML_y1 ==5 & q==2
	
  }
 end 

    
    ml model lf obit (k= i.s, noconstant)  ///
					 ()  ()  ()            ///
	                 ()  ()  ()  ()       
   ml check 
   ml search    
   ml maximize , difficult 
   mat c=r(table)
   
 //  ml graph

//   *try gsem
//   g k_1 = k if q==1
//   g k_2 = k if q==2 
//  
//   gsem (k_1 <- i.s L@a, oprobit) (k_2 <- i.s L@a, oprobit)

  

   matrix e_mu = c[1,2..10]
   mat e_ci=c[5..6,2..10]
   mat emu=e_mu'
   
   svmat emu
   
   gen t= _n if !missing(emu1)
   
   replace emu= -1*emu1
   
   sort s t
   twoway (line emu t) (line mu s) , legend( lab(1 "Estimated")  lab(2 "Actural")) 
   
   
 *==========gllamm==============
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
