*new analysis in 2017 
*update : replace 2010 ACS with 2000 census 
*add population increase rate and total population size as IV;
*first update: Feb24th, 2017 ;
*update Feb27th: imported spatial lage variable move analysis to the new folder : reanalysis2017;

libname eva "G:\RA\RAship Dr Chi\population projection evaluation\county_level_data\Independent variable 2010 ";
run;
libname new2017 "G:\RA\RAship Dr Chi\population projection evaluation\county_level_data\IV2000 ";
run;

*step 1 : exract old data from the previous analysis 
*keep fips total popualtion projection error crime data and land developmentality ;
proc contents data=eva.Completedata; run; 
data old;
set eva.Completedata;  
keep FIPS_1 fips  newfips_city  error  
TotalPopulation_1970 TotalPopulation_1980 TotalPopulation_1990 TotalPopulation_2000 TotalPopulation_2010_actual 
 Ave_MEAN NEAR_DIST ;
run;
proc contents data=old ; run;

*step 2: merge old datat with the 2000 new Ivs;
*proc contents data=new2017.Census2000; run;
data new;
set new2017.Censusrefined;
*set new2017.Complete2017;
run;
proc contents data=new; run;  
proc means data=new;
var PCT_T217A004; run; 
data data1;
set new2017.crime2000; 
*if length(FIPS_CTY ) = 3 then newfips_city=FIPS_CTY;
*else newfips_city=repeat('0',3-length(FIPS_CTY)-1)||FIPS_CTY;
newfips_city=put(input(FIPS_CTY,best32.),z3.);  *this finally works;
newFIPS_ST=put (input (FIPS_ST,best32.), z2.);
*covert to numerical variables;

*FIPs=newFIPS_ST*1000+newFIPS_ST;
FIPS= cat(newFIPS_ST,newfips_city);
run;
proc sort data=data1;
by fips;
run;
 proc sort data=new;
 by fips;run;
 proc sort data=old;
 by fips;run;
 data complete2017 ;
 merge old new data1;
 by fips;run;

data new2017.complete2017;
set complete2017;
*if  State= 72 or  State =47 then delete ; *delete Alaska and purto rico; 
run;
proc contents data=new2017.complete2017;run;

proc means data=new2017.complete2017 mean median max min nmiss;
var T009_002 PCT_T009_005 PCT_T015_002 PCT_T217A004; 
*var PCT_T009_002;
run; 
proc corr data=new2017.complete2017 ;
var TotalPopulation_2000 T001_001 ;
run; 


**analysis;
data data1;
set new2017.complete2017;
rpop=100*(TotalPopulation_2010_actual-TotalPopulation_2000)/TotalPopulation_2000 ;
lrpop=log(rpop);
lpop=log(TotalPopulation_2010_actual);
abserror=abs(error) ;
popdensity=T003_001;
*young=100*(T008_005+T008_006)/T008_001;
*old=100*(T008_011+T008_012+T008_013)/T008_001;
young=PCT_T009_002;
old=PCT_T009_005;
black=PCT_T014_003;
hispanic=PCT_T015_010;
*black=100*T054_003/T054_001;
*hispanic=100*(1-T055_002/T055_001);

college=PCT_T040_004;
highschool=PCT_T040_003; 
Bachelor=PCT_T040_005;

employed=PCT_T069_005;
ag=PCT_T085_002;
retail=PCT_T085_008;

income=T093_001; * median household income;
pubtrans=PCT_T195_003;
lesscommute=PCT_T217A004;

cirme_total=(P1TOT/TotalPopulation_2000)*100000;
crime_violent=(P1VLNT/TotalPopulation_2000)*100000;

landdevelop=Ave_MEAN;
airportdis=NEAR_DIST;
*if  State= 72 or  State =47 then delete ; *delete Alaska and purto rico; 

run;

data new2017.completeiv2017;
set  data1;
keep fips error abserror 
rpop LPOP TotalPopulation_2010_actual popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute cirme_total crime_violent landdevelop airportdis ;
run;


ods select MissPattern;
proc mi data=data1 nimpute=0;
var error abserror 
rpop LPOP TotalPopulation_2010_actual popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute cirme_total crime_violent landdevelop airportdis ;
run;


proc contents data=data1; run; 
proc corr data=data1;
var hispanic employed hisp_2 PCT_T015_002; run; 

*independent variable: error, absolute error;
proc means data=data1 mean std min max ;
*var error abserror popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute cirme_total crime_violent landdevelop airportdis;
*var error abserror popdensity rpop young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute airportdis cirme_total  crime_violent landdevelop  ;
*var PCT_T015_010 PCT_T217A004;
*var  rpop  TotalPopulation_2000  popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute  cirme_total  crime_violent landdevelop airportdis;
*var lrpop lpop; 
var error abserror rpop LPOP TotalPopulation_2010_actual popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute cirme_total crime_violent landdevelop airportdis ;
run;

proc univariate data=data1;
*var error abserror popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommut cirme_tota  landdevelo airportdis ;
var TotalPopulation_2000 rpop ;
ppplot;
run;

 

libname spatial  "G:\RA\RAship Dr Chi\population projection evaluation\reanalysis2017spring";
run;
data data1;
set spatial.Aprilolsbefore;
run;
proc contents data=data1;run;
proc means data=data1 mean std min max ;
*var error abserror popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute cirme_total crime_violent landdevelop airportdis;
*var error abserror popdensity rpop young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute airportdis cirme_total  crime_violent landdevelop  ;
*var PCT_T015_010 PCT_T217A004;
*var  rpop  TotalPopulation_2000  popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute  cirme_total  crime_violent landdevelop airportdis;
*var lrpop lpop; 
var error abserror rpop LPOP  popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis ;
run;


****error full model ******************;

proc reg data=data1;
model error=rpop lpop  popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute cirme_total crime_violent landdevelop airportdis ;  
run;
proc reg data=data1;
model abserror=rpop  TotalPopulation_2000 popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute cirme_total crime_violent landdevelop airportdis ; 
run;

/*prepare to calculate weights ;
proc contents data=data1; run;
data new2017.olsafter2017;
set data1;
keep FIPS FIPS_1
error abserror rpop lrpop lpop TotalPopulation_2000 popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans lesscommute cirme_total crime_violent landdevelop airportdis 
;
run; 
*/


data b1;
set spatial.Olsafterweights;
run;
proc contents data=b1 ORDER=CASECOLLATE; run; 
data dis;
set b1;
if young=0 then delete; run; 

proc means data=work.Dis mean std  min max  ;
var rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis ;
run;  

proc univariate data=work.Dis  ;
*var rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis ;
var black Bachelor retail pubtrans  CIRME_TOTA CRIME_VIOL LANDDEVELO;
run;  
*fullmodel;
ods output ParameterEstimates (persist) =modelols_full; 

proc reg data=b1;
model error=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
 ;  
model abserror=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
;  
run;
ods output close;



proc reg data=b1;
model error=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
/ selection=backward stb vif ;  
model abserror=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
/ selection=backward stb vif ;  
run;



***reduced model ols;
ods output ParameterEstimates (persist) =modelols_reduced; 
*ols reduced ;
proc autoreg data=b1;
model error=rpop LPOP  old black  college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT LANDDEVELO airportdis;
model abserror=rpop LPOP black hispanic college highschool Bachelor employed ag  LESSCOMMUT LANDDEVELO airportdis  ;
run;
ods output close;

proc format ;
picture StandardizedEst (round)
low-high='9.999';
picture stderrf (round)
low-high='(9.999)' (prefix='(')  
.='';
value pf 0-0.001="***" 0.001-0.01="**" 0.01-0.05="*" other=" "; run;

proc tabulate data=errorlag_reduced noseps order=data;      
  class model variable ;                      
  var StandardizedEst  probt stderr ;     
  table variable=''*(StandardizedEst =' '*sum=' '                          
                      probt=''*sum=''*F=pf.
                      stderr=' '*sum=' '*F=stderrf.),                
         model=' '                                                  
          / box=[label="Parameter"] rts=15 row=float misstext=' '; 
run;

proc tabulate data=errorlag_reduced noseps order=data;      
  class model variable ;                      
  var VarianceInflation ;     
  table variable=''*(VarianceInflation =' '*sum=' '                          
                      ),                
         model=' '                                                  
          / box=[label="Parameter"] rts=15 row=float misstext=' '; 
run;

*error ;
*full model;

ods output ParameterEstimates (persist) =spatial_full; 
proc autoreg data=b1;
model error=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
     wrpop WLPOP WPOPDENS wyoung wold wblack whispanic WCOLLEGE WHIGHSCHOO WBACHOLOR WEMPLOYED WAG WRETAIL WINCOME WPUBTRANS WLESSCOMMU WCRIMETOTA WCRIMEVIOL WLANDDEVEL WAIRPORT
 ; 
model abserror=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
     wrpop WLPOP WPOPDENS wyoung wold wblack whispanic WCOLLEGE WHIGHSCHOO WBACHOLOR WEMPLOYED WAG WRETAIL WINCOME WPUBTRANS WLESSCOMMU WCRIMETOTA WCRIMEVIOL WLANDDEVEL WAIRPORT
 ;   
run;
ods output close;



ods output ParameterEstimates (persist) =error_reduced; 

proc reg data=b1;
model error=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
     wrpop WLPOP WPOPDENS wyoung wold wblack whispanic WCOLLEGE WHIGHSCHOO WBACHOLOR WEMPLOYED WAG WRETAIL WINCOME WPUBTRANS WLESSCOMMU WCRIMETOTA WCRIMEVIOL WLANDDEVEL WAIRPORT
/ selection=backward stb vif aic ; 
model abserror=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
     wrpop WLPOP WPOPDENS wyoung wold wblack whispanic WCOLLEGE WHIGHSCHOO WBACHOLOR WEMPLOYED WAG WRETAIL WINCOME WPUBTRANS WLESSCOMMU WCRIMETOTA WCRIMEVIOL WLANDDEVEL WAIRPORT
/ selection=backward stb vif aic;  
 
run;
ods output close;
* too many VIFs greater than 5---redo model;
proc reg data=b1;
model error=rpop LPOP  young old   college  Bachelor  ag retail income pubtrans LESSCOMMUT    
     wrpop   wyoung wold  WBACHOLOR WEMPLOYED WAG   WLESSCOMMU   WAIRPORT weeror
/ stb vif aic ; 
run; 

proc autoreg data=b1;
model error=rpop LPOP  young old   college  Bachelor  ag retail income pubtrans LESSCOMMUT    
     wrpop   wyoung wold  WBACHOLOR WEMPLOYED WAG   WLESSCOMMU   WAIRPORT weeror
; 
run; 


ods output ParameterEstimates (persist) =error_reduced2; 
proc reg data=b1;
model error=rpop LPOP  old black hispanic college ag  income pubtrans LESSCOMMUT  LANDDEVELO airportdis  
     wrpop WLPOP wblack whispanic  WHIGHSCHOO WBACHOLOR WEMPLOYED WAG WRETAIL WINCOME  WLESSCOMMU WCRIMETOTA WCRIMEVIOL WLANDDEVEL WAIRPORT
/vif; 
model abserror=rpop LPOP  black  college highschool Bachelor employed ag retail  LESSCOMMUT  LANDDEVELO airportdis  
     wrpop WLPOP   whispanic  WHIGHSCHOO WINCOME WCRIMETOTA WCRIMEVIOL WLANDDEVEL WAIRPORT
/vif;  
 
run;
ods output close;
*error+lage reducde ;

ods output ParameterEstimates (persist) =errorlag_reduced;
proc reg data=b1 (stats=(default aic ));
model error=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
     wrpop WLPOP WPOPDENS wyoung wold wblack whispanic WCOLLEGE WHIGHSCHOO WBACHOLOR WEMPLOYED WAG WRETAIL WINCOME WPUBTRANS WLESSCOMMU WCRIMETOTA WCRIMEVIOL WLANDDEVEL WAIRPORT
     weeror / selection=backward stb vif aic ;  
model abserror=rpop LPOP popdensity young old black hispanic college highschool Bachelor employed ag retail income pubtrans LESSCOMMUT CIRME_TOTA CRIME_VIOL LANDDEVELO airportdis  
     wrpop WLPOP WPOPDENS wyoung wold wblack whispanic WCOLLEGE WHIGHSCHOO WBACHOLOR WEMPLOYED WAG WRETAIL WINCOME WPUBTRANS WLESSCOMMU WCRIMETOTA WCRIMEVIOL WLANDDEVEL WAIRPORT
WABSERROR / selection=backward stb vif  aic ;  
run;

ods output close;



proc autoreg data=b1 ;
model error=rpop LPOP  young old black hispanic college  Bachelor  ag retail income pubtrans LESSCOMMUT 
     wrpop  WPOPDENS wyoung wold wblack whispanic  WHIGHSCHOO WBACHOLOR WEMPLOYED WAG  WINCOME WPUBTRANS WLESSCOMMU 
     weeror ;  
model abserror=rpop LPOP popdensity black  college highschool Bachelor employed ag LESSCOMMUT LANDDEVELO airportdis  
     wrpop  whispanic  WHIGHSCHOO  WAG  WINCOME 
WABSERROR;  
run;
