*simulation 

clear all 

set obs 10000
set seed 12202019

* 5yrs, 3 survyes 
g yr=  int(5*runiform() + 1)  
g survey = int(3*runiform()+ 1)

sort yr survey 
g id = _n

*mu, sigma, a function of time 

g x=.
g mu =.
g sigma =.
forval i =1/5 {
replace mu = `i'+5 if yr ==`i'
replace sigma=(`i'+10)*3 if yr ==`i' 

replace x=rnormal(mu,sigma)

}
// forval i= 1/5 {
// replace x=rnormal(`i'+6,`i'*`i')
// }

histogram x,by(yr)
*assign a, b, s, c, : questionaire characheristic

* survey 1 : s 4    c 0
* survey 2 : s 10   c -5
* survey 3 : s 5  c 1

* a,b, function of time : a = t+1 , b = t+2 

g       s=4 if  survey  ==1
replace s=10 if  survey ==2 
replace s=5 if survey  == 3

g       c =0 if survey  ==1
replace c =-5 if survey ==2
replace c = 1 if survey ==3 



g a= 0.1 if survey ==1
replace a = 0.2 if survey ==2
replace a = 0.3 if survey ==3

g b = 5 if survey ==1
replace b=10 if survey ==2
replace b =15 if survey ==3 


// forval i=1/5 {
//  replace a = `i'/5 if yr==`i'
//  replace b = `i'+10 if yr==`i'
 
// }

g deno= 1+exp(-a*x - b)  
misschk deno 
sum deno 

g t= (s/deno) + c
bysort survey: sum t

drop deno

*mapping t to r 
*survey 1 : 1- 5

g       r = 1 if t>=0 & t <=1 & survey ==1 
replace r = 2 if t>1 & t <=2 & survey ==1
replace r = 3 if t>2 & t <=3 & survey ==1
replace r = 4 if t>3 & t<=4 & survey ==1




forval i=-4/5 {
local j = `i'-1
replace r =`i' if t>`j' & t<=`i' & survey  ==2
}
replace r = -4 if t==-5 & survey ==2

forval i=2/6 {
local j = `i'-1
replace r =`i' if  t>`j' & t<=`i' & survey  ==3
}

replace r =2 if t ==1 & survey ==3

bysort survey: tab r
*number of respondents in each
bysort yr survey  r : g nres = _N 
export delimited using "/Users/donghui/Dropbox/Website/US_project/cleaned_data/sim.csv", replace

// collapse x, by(yr)
// sort yr
// twoway line x yr

*calculate cdf 
	collapse (count)id (mean) x  ,  by(yr survey r)
	rename survey survey_name
	rename yr year 
	rename id nresp
	rename r response 
	drop x
export delimited using "/Users/donghui/Dropbox/Website/US_project/cleaned_data/table2.csv", replace
