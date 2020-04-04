  
* the simpliest: write out all the relationship 

*created on Apirl,3, 2020, copy from sim3.do

*task:  mle for survey scaling, after adjusting the orginal data 


//cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"   //desktop 
//cd "C:\Users\wdhec\Dropbox\Website\US_project\cleaned_data"
cd "/Users/donghui/Dropbox/Website/US_project/cleaned_data"  // mac
//global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"  // pc 


use scaling.dta, clear
   
   * expand aggregate data into individual level data 
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



*------program----------------

 capture program drop obit 
 
 
  program define obit 
   
    #delimit ; 
	args  lnf mu tau1_1   
	             tau2_1  tau2_2 tau2_3 tau2_4 tau2_5 tau2_6 tau2_7 tau2_8 tau2_9  
				 tau3_1  tau3_2 tau3_3  
				 tau4_1  tau4_2 tau4_3 
				 tau5_1  tau5_2 tau5_3 tau5_4
				 tau6_1  tau6_2
				 tau7_1  tau7_2 tau7_3 tau7_4 tau7_5 tau7_6 tau7_7 tau7_8 tau7_9
				 tau8_1  tau8_2 tau8_3
				 tau9_1  tau9_2 tau9_3 tau9_4	
                 tau10_1  tau10_2 tau10_3  
				 tau11_1  tau11_2 tau11_3 
                 tau12_1  tau12_2 tau12_3 
				 tau13_1  tau13_2 tau13_3 			 

	;
	#delimit cr
	

	quietly {
  
	  // 1. ABC : 2 level 
    replace `lnf' =ln(normal(`tau1_1' -`mu'))                             if $ML_y1 ==1 & q==1
    replace `lnf' =ln(1 - normal(`tau1_1'  -`mu' ))                       if $ML_y1 ==2 & q==1
	
	
 	// 2. GSS
	replace `lnf' =ln(normal( `tau2_1' -`mu'))                            if $ML_y1 ==1 & q==2
	replace `lnf' =ln(normal(`tau2_2' -`mu')  - normal( `tau2_1' -`mu'))  if $ML_y1 ==2 & q==2
    replace `lnf' =ln(normal(`tau2_3' -`mu')  - normal( `tau2_2' -`mu'))  if $ML_y1 ==3 & q==2
	replace `lnf' =ln(normal(`tau2_4' -`mu')  - normal( `tau2_3' -`mu'))  if $ML_y1 ==4 & q==2
	replace `lnf' =ln(normal(`tau2_5' -`mu')  - normal( `tau2_4' -`mu'))  if $ML_y1 ==5 & q==2
    replace `lnf' =ln(normal(`tau2_6' -`mu')  - normal( `tau2_5' -`mu'))  if $ML_y1 ==6 & q==2
	replace `lnf' =ln(normal(`tau2_7' -`mu')  - normal( `tau2_6' -`mu'))  if $ML_y1 ==7 & q==2
	replace `lnf' =ln(normal(`tau2_8' -`mu')  - normal( `tau2_7' -`mu'))  if $ML_y1 ==8 & q==2
    replace `lnf' =ln(normal(`tau2_9' -`mu')  - normal( `tau2_8' -`mu'))  if $ML_y1 ==9 & q==2
    replace `lnf' =ln(1 - normal(`tau2_9'  -`mu'))                        if $ML_y1 ==10 & q==2
			
	
	// 3. PEW 
	replace `lnf' =ln(normal(`tau3_1' -`mu'))                             if $ML_y1 ==1 & q==3
	replace `lnf' =ln(normal(`tau3_2' -`mu')  - normal( `tau3_1' -`mu'))  if $ML_y1 ==2 & q==3
    replace `lnf' =ln(normal(`tau3_3' -`mu')  - normal( `tau3_2' -`mu'))  if $ML_y1 ==3 & q==3
    replace `lnf' =ln(1 - normal(`tau3_3'  -`mu'))                        if $ML_y1 ==4 & q==3
	
	
 	//4. TRA_4 
	
	replace `lnf' =ln(normal(`tau4_1' -`mu'))                             if $ML_y1 ==1 & q==4
	replace `lnf' =ln(normal(`tau4_2' -`mu')  - normal( `tau4_1' -`mu'))  if $ML_y1 ==2 & q==4
    replace `lnf' =ln(normal(`tau4_3' -`mu')  - normal( `tau4_2' -`mu'))  if $ML_y1 ==3 & q==4
    replace `lnf' =ln(1 - normal(`tau4_3'  -`mu'))                        if $ML_y1 ==4 & q==4

	
	//5.  TRA 5 
	replace `lnf' =ln(normal(`tau5_1' -`mu'))                             if $ML_y1 ==1 & q==5
	replace `lnf' =ln(normal(`tau5_2' -`mu')  - normal( `tau5_1' -`mu'))  if $ML_y1 ==2 & q==5
    replace `lnf' =ln(normal(`tau5_3' -`mu')  - normal( `tau5_2' -`mu'))  if $ML_y1 ==3 & q==5
	replace `lnf' =ln(normal(`tau5_4' -`mu')  - normal( `tau5_3' -`mu'))  if $ML_y1 ==4 & q==5
    replace `lnf' =ln(1 - normal(`tau5_4'  -`mu')) 					      if $ML_y1 ==5 & q==5	
	
	
	//6. USCBS_3 		
	replace `lnf' =ln(normal(`tau6_1' -`mu'))                             if $ML_y1 ==1 & q==6
	replace `lnf' =ln(normal(`tau6_2' -`mu')  - normal( `tau6_1' -`mu'))  if $ML_y1 ==2 & q==6
    replace `lnf' =ln(1 - normal(`tau6_2'  -`mu'))                        if $ML_y1 ==3 & q==6
		
	
	// 7. USGALLUP_10
	replace `lnf' =ln(normal( `tau7_1' -`mu'))                            if $ML_y1 ==1 & q==7
	replace `lnf' =ln(normal(`tau7_2' -`mu')  - normal( `tau7_1' -`mu'))  if $ML_y1 ==2 & q==7
    replace `lnf' =ln(normal(`tau7_3' -`mu')  - normal( `tau7_2' -`mu'))  if $ML_y1 ==3 & q==7
	replace `lnf' =ln(normal(`tau7_4' -`mu')  - normal( `tau7_3' -`mu'))  if $ML_y1 ==4 & q==7
	replace `lnf' =ln(normal(`tau7_5' -`mu')  - normal( `tau7_4' -`mu'))  if $ML_y1 ==5 & q==7
    replace `lnf' =ln(normal(`tau7_6' -`mu')  - normal( `tau7_5' -`mu'))  if $ML_y1 ==6 & q==7
	replace `lnf' =ln(normal(`tau7_7' -`mu')  - normal( `tau7_6' -`mu'))  if $ML_y1 ==7 & q==7
	replace `lnf' =ln(normal(`tau7_8' -`mu')  - normal( `tau7_7' -`mu'))  if $ML_y1 ==8 & q==7
    replace `lnf' =ln(normal(`tau7_9' -`mu')  - normal( `tau7_8' -`mu'))  if $ML_y1 ==9 & q==7
    replace `lnf' =ln(1 - normal(`tau7_9'  -`mu'))                        if $ML_y1 ==10 & q==7
				
	
	// 8. gallup_4
	replace `lnf' =ln(normal(`tau8_1' -`mu'))                             if $ML_y1 ==1 & q==8
	replace `lnf' =ln(normal(`tau8_2' -`mu')  - normal( `tau8_1' -`mu'))  if $ML_y1 ==2 & q==8
    replace `lnf' =ln(normal(`tau8_3' -`mu')  - normal( `tau8_2' -`mu'))  if $ML_y1 ==3 & q==8
    replace `lnf' =ln(1 - normal(`tau8_3'  -`mu')) 	                      if $ML_y1 ==4 & q==8	
	
	
	// 9. USKN_5
	replace `lnf' =ln(normal(`tau9_1' -`mu'))                             if $ML_y1 ==1 & q==9
	replace `lnf' =ln(normal(`tau9_2' -`mu')  - normal( `tau9_1' -`mu'))  if $ML_y1 ==2 & q==9
    replace `lnf' =ln(normal(`tau9_3' -`mu')  - normal( `tau9_2' -`mu'))  if $ML_y1 ==3 & q==9
	replace `lnf' =ln(normal(`tau9_4' -`mu')  - normal( `tau9_3' -`mu'))  if $ML_y1 ==4 & q==9
    replace `lnf' =ln(1 - normal(`tau9_4'  -`mu')) 						  if $ML_y1 ==5 & q==9	
	
	// 10. USORC_4
	replace `lnf' =ln(normal(`tau10_1' -`mu'))                              if $ML_y1 ==1 & q==10
	replace `lnf' =ln(normal(`tau10_2' -`mu')  - normal( `tau10_1' -`mu'))  if $ML_y1 ==2 & q==10
    replace `lnf' =ln(normal(`tau10_3' -`mu')  - normal( `tau10_2' -`mu'))  if $ML_y1 ==3 & q==10
    replace `lnf' =ln(1 - normal(`tau10_3'  -`mu')) 	                    if $ML_y1 ==4 & q==10	
	
	//11. USPSRA_4 
	replace `lnf' =ln(normal(`tau11_1' -`mu'))                              if $ML_y1 ==1 & q==11
	replace `lnf' =ln(normal(`tau11_2' -`mu')  - normal( `tau11_1' -`mu'))  if $ML_y1 ==2 & q==11
    replace `lnf' =ln(normal(`tau11_3' -`mu')  - normal( `tau11_2' -`mu'))  if $ML_y1 ==3 & q==11
    replace `lnf' =ln(1 - normal(`tau11_3'  -`mu')) 	                    if $ML_y1 ==4 & q==11	
	
	
	//12 zoby4
	replace `lnf' =ln(normal(`tau12_1' -`mu'))                              if $ML_y1 ==1 & q==12
	replace `lnf' =ln(normal(`tau12_2' -`mu')  - normal( `tau12_1' -`mu'))  if $ML_y1 ==2 & q==12
    replace `lnf' =ln(normal(`tau12_3' -`mu')  - normal( `tau12_2' -`mu'))  if $ML_y1 ==3 & q==12
    replace `lnf' =ln(1 - normal(`tau12_3'  -`mu')) 	                    if $ML_y1 ==4 & q==12	
	
	// abcwp4
	replace `lnf' =ln(normal(`tau13_1' -`mu'))                              if $ML_y1 ==1 & q==13
	replace `lnf' =ln(normal(`tau13_2' -`mu')  - normal( `tau13_1' -`mu'))  if $ML_y1 ==2 & q==13
    replace `lnf' =ln(normal(`tau13_3' -`mu')  - normal( `tau13_2' -`mu'))  if $ML_y1 ==3 & q==13
    replace `lnf' =ln(1 - normal(`tau13_3'  -`mu')) 	                    if $ML_y1 ==4 & q==13	
		
  }
 end 

    #delimit ; 
    ml model lf obit (k: k= i.s, noconstant) 
	                 (tau1_1:)
					 (tau2_1:) (tau2_2:) (tau2_3:) (tau2_4:) (tau2_5:) (tau2_6:) (tau2_7:) (tau2_8:) (tau2_9:) 
					 (tau3_1:) (tau3_2:) (tau3_3:) 
					 (tau4_1:) (tau4_2:) (tau4_3:)
					 (tau5_1:) (tau5_2:) (tau5_3:) (tau5_4:)
					 (tau6_1:) (tau6_2:)
					 (tau7_1:) (tau7_2:) (tau7_3:) (tau7_4:) (tau7_5:) (tau7_6:) (tau7_7:) (tau7_8:) (tau7_9:) 
					 (tau8_1:) (tau8_2:) (tau8_3:)
					 (tau9_1:) (tau9_2:) (tau9_3:) (tau9_4:)
					 (tau10_1:) (tau10_2:) (tau10_3:)
					 (tau11_1:) (tau11_2:) (tau11_3:)
					 (tau12_1:) (tau12_2:) (tau12_3:) 
					 (tau13_1:) (tau13_2:) (tau13_3:) 

	;
    #delimit cr
	
	
	ml init e0  // intial values obtained from ordered probit rountine 
	
//    ml check 
   ml maximize , difficult  
//    ml graph 
//    graph export "$image\iteration.png" ,replace 

   
   mat c=r(table)
   
   mat e_mu = c[1, "k:"]'
   mat e_ci=c[5..6,"k:"]'
  

   
   mat e_tau1 = c[1, "tau1_1:"]
   mat e_tau2 = c[1, "tau2_1:" .. "tau2_9:"]'
   mat e_tau3 = c[1, "tau3_1:" .. "tau3_3:"]'
   mat e_tau4 = c[1, "tau4_1:" .. "tau4_3:"]'
   mat e_tau5 = c[1, "tau5_1:" .. "tau5_4:"]'
   mat e_tau5 = c[1, "tau5_1:" .. "tau5_4:"]'
   mat e_tau6 = c[1, "tau6_1:" .. "tau6_2:"]'
   mat e_tau7 = c[1, "tau7_1:" .. "tau7_9:"]'
   mat e_tau8 = c[1, "tau8_1:" .. "tau8_3:"]'
   mat e_tau9 = c[1, "tau9_1:" .. "tau9_4:"]'
   mat e_tau10 = c[1, "tau10_1:".. "tau10_3:"]'
   mat e_tau11 = c[1, "tau11_1:" .. "tau11_3:"]'
   mat e_tau12 =  c[1, "tau12_1:" ..  "tau12_3:"]'
   mat e_tau13 =  c[1, "tau13_1:" ..  "tau13_3:"]'

set trace on 
   forval i=1/13 {
   svmat e_tau`i', names(matcol)
   }     
   



  
   levelsof s, matrow(s)
   mat mu= s, e_mu
   
   
   *graph estimated results   
   svmat  mu

   rename mu1 year   
   rename mu2 Esimates 
   

   svmat e_ci
   rename e_ci1 ul
   rename e_ci2 ll 
   
*   twoway (line Esimates year) (rarea ul ll year , color(grey%25) ) , xlab(1977(5)2020) ylab(-2/2) note("survey:ABC, GSS, PEW, TRA_4, USGALLUP_4")
     
   twoway (line Esimates year) (rcap  ul ll year) , xlab(1974(5)2020) ylab(-2/2) legend(ring(0)  order (1 "Estimates" 2 "Confidence Interval"))
   graph export "$image/Emp_estimate_04032020.png" ,replace 
   
   *keep estimated output 
   keep year Esimates ul ll e_tau*
   export delimited using Results_fullmodel_04032020.csv, replace

   *revise Figure 
   import delimited /Users/donghui/Dropbox/Website/US_project/tables/Results_fullmodel_04032020.csv, clear 
     
   sort year
   twoway (line esimates year) (rcap  ul ll year) , xlab(1974(5)2020) ylab(-2/2) legend(ring(0)  order (1 "Estimates" 2 "Confidence Interval"))
   graph export "$image/Emp_estimate.png" ,replace 
   
    
