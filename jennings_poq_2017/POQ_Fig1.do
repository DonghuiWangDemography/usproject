
use POQ_Fig1.dta, clear

sort year

egen std_bsa_dis=std(bsa_distrust)
egen std_mori_dis=std(mori_distrust)

* 
twoway /*
*/ (line bsa_distrust year if year>1982 & year <2016) /*
*/ (line mori_distrust year if year>1982 & year <2016) /*
*/ (scatter bsa_distrust year if year>1982 & year <2016, mcolor(gs0) msize(medsmall) msymbol(O)) /*
*/ (scatter mori_distrust year if year>1982 & year <2016, mcolor(gs0) msize(medsmall) msymbol(T)) /*
*/ , scheme(s2mono) /*
*/ graphregion(color(white)) /*
*/ title("") /*
*/ xtitle("") /*
*/ ytitle("Distrust (%)") /*
*/ ytick(0(10)90) /*
*/ ylabel(0(10)90) /*
*/ ylabel(,angle(horizontal)) /*
*/ xtick(1980(5)2016) /*
*/ xlabel(1980(5)2015) /*
*/ xscale(titlegap(2)) /*
*/ legend(order(1 "Almost never trust government (BSA)" 2 "Distrust politicians generally (Ipsos-MORI)") /*
*/ rows(2) /*
*/ symxsize(5) /*
*/ size(medsmall)) 

graph export POQ_Fig1.tif, width(2000)
