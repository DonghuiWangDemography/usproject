*setting up initial values by simple ordered probit 
*created on 03/11/2020 

// cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"   //desktop 
cd "C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data"
//cd "C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data"
//cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"  // mac

//global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 


use scaling.dta, clear
   
	g response=round(nresp)
	expand response
	keep syear resp scale varname questionid enddate sid qid  nsurvey

 
 g k = resp 
 g s = syear 
 encode varname,gen(q)
 
 
keep  k s q varname scale 
//   oprobit k  i.s  // oprobit looks fine 
*keep if inlist( q, 1, 3, 4, 8)
	
  qui: oprobit k i.s
  mat s=r(table)[1, "k:"]

  levelsof q, local(survey)
  foreach x of local survey {
  
  qui: oprobit k i.s if q==`x' 
  qui: mat c=r(table)
  qui: mat tau`x'=c[1, " /:"]
  
  *rename tau
  mat colname tau`x'=_cons
  }

  

  mat coleq tau1 = tau1_1
  mat coleq tau2 = tau2_1 tau2_2 tau2_3 tau2_4 tau2_5 tau2_6 tau2_7 tau2_8 tau2_9
  mat coleq tau3 = tau3_1 tau3_2 tau3_3
  mat coleq tau4 = tau4_1 tau4_2 tau4_3 
  mat coleq tau5 = tau5_1 tau5_2 tau5_3 tau5_4
  mat coleq tau6 = tau6_1 tau6_2 
  mat coleq tau7 = tau7_1 tau7_2 tau7_3 tau7_4 tau7_5 tau7_6 tau7_7 tau7_8 tau7_9
  mat coleq tau8 = tau8_1 tau8_2 tau8_3
  mat coleq tau9 = tau9_1 tau9_2 tau9_3 tau9_4
  mat coleq tau10 = tau10_1 tau10_2 tau10_3
  mat coleq tau11 = tau11_1 tau11_2 tau11_3 
  mat coleq tau12 = tau12_1 tau12_2 tau12_3
  


  *put together 
  mat e0=s,tau1, tau2, tau3, tau4, tau5,tau6, tau7,tau8,tau9,tau10,tau11, tau12
