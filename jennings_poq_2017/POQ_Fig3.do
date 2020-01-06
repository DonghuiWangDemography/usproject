
use POQ_Replication.dta, clear

* 
twoway /*
*/ (line discontent yr if yr>1965) /*
*/ (line govapp_dis yr if yr>1965) /*
*/ , scheme(s2mono) /*
*/ graphregion(color(white)) /*
*/ title("") /*
*/ xtitle("") /*
*/ ytitle("Political discontent / government dissatisfaction") /*
*/ ytick(30(10)80) /*
*/ ylabel(30(10)80) /*
*/ ylabel(,angle(horizontal)) /*
*/ xtick(1965(5)2015) /*
*/ xlabel(1965(5)2015) /*
*/ xscale(titlegap(2)) /*
*/ legend(order(1 "Political discontent" 2 "Government dissatisfaction") /*
*/ rows(1) /*
*/ symxsize(5) /*
*/ size(medsmall)) 

graph export POQ_Fig3.tif, width(2000)
