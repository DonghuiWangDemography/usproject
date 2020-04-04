*setting up initial values by simple ordered probit 
*created on 03/11/2020 

 cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"   //desktop 
//cd "C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data"  // pc
//cd "C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data"
//cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"  // mac

//global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 


use scaling.dta, clear
   
	g response=round(nresp)
	expand response
	keep syear resp scale varname questionid enddate sid qid  nsurvey

 
 g k = resp 
 g s = syear 

 encode varname,gen(oldvar)


 *adjust variable order
 #delimit;
 recode oldvar (6=1 "ABC")
				(1=2 "GSS")
				(2=3 "PEW")
				(3=4 "TRA_4")
				(4=5 "TRA_5")
				(7=6 "CBS")
				(8=7 "GALLUP10")
				(9=8 "GALLUP4")
				(10=9 "USKN5")
				(11=10 "ORC4")
				(12=11 "PSRA4")
				(13=12 "ZOBY4")
				(5=13  "ABCWP4")
 
 ,gen(q)
 
 
 ;
 #delimit cr
 
  keep  k s q varname scale 

  qui: oprobit k i.s
  mat rs=r(table)
  mat s=rs[1, " k:"]


  
  levelsof q, local(survey)
  foreach x of local survey { 
  qui: oprobit k i.s if q==`x' 
  qui: mat c=r(table)
  qui: mat tau`x'=c[1, " /:"]
  	
  }
 
  	//rename tau
	forval i= 1/13{
	
    mat colname tau`i'=_cons
	local n= `= colsof(tau`i')'
	local ctau`i' ""
	forval j=1/`n'{	
	local ctau`i' "`ctau`i'' tau`i'_`j'"  
	
	}
	mat coleq tau`i'= `ctau`i''
	}
	
  *put together intial values 
  mat e0=s,tau1, tau2, tau3, tau4, tau5,tau6, tau7,tau8,tau9,tau10,tau11, tau12, tau13
