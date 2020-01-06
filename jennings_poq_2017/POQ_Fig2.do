
use GallupYouGov.dta, clear

* 
graph /*
*/ bar themselves theirparty theircountry dontknow /*
*/ , over(year, gap(150) label(angle(horizontal) labsize(medsmall))) bar(1, color(gs0)) bar(2, color(gs4)) bar(3, color(gs8)) bar(4, color(gs12)) /*
*/ intensity(30) /*
*/ scheme(s2mono) /*
*/ graphregion(color(white)) /*
*/ ylabel(0(10)50, gmax angle(horizontal) labsize(medsmall)) /*
*/ blabel(bar, size(small) orient(horizontal)) /*
*/ ytitle("%") /*
*/ yscale(titlegap(2)) /*
*/ title("") /*
*/ legend( /*
*/ symysize(6) /*
*/ symxsize(6) /*
*/ label(1 "Themselves") /*
*/ label(2 "Their party") /*
*/ label(3 "Their country") /*
*/ label(4 "Don't know") /*
*/ rows(1) size(small)) 

graph export POQ_Fig2.tif, width(2000)
