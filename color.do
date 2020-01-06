
*https://scatter.wordpress.com/2017/06/01/stata-roll-your-own-palettes/#more-14249

local colorlist "orange orange_red red ebblue eltblue purple"
local intenlist ".5 .75 1 1.25 1.5 1.75 2"
local ncolor=wordcount("`colorlist'")
local ninten=wordcount("`intenlist'")
local ncases=`ncolor'*`ninten'
disp "ncolor `ncolor' ninten `ninten' ncases `ncases'"
set more off
clear
set obs `ncases'
gen case=_n
gen ncases=_N
gen color=""
gen intenS=""
gen colorname=""
** fill in the strings with colors and intensities
local ii=1
forval color= 1/`ncolor' {
forval inten= 1/`ninten' {
     replace color=word("`colorlist'",`color') if case==`ii'
     replace intenS=word("`intenlist'",`inten') if case==`ii'
     replace colorname=color+"*"+intenS
     local ii=`ii'+1
     }
     }
*** the num variables are sequential
encode color, gen(colornum)
encode intenS, gen(intennum)
encode colorname, gen(col_int_num)
gen inten=real(intenS) // this is the actual numeric value of intensity


local plot ""
summ col_int_num
local nplots=r(max)
forval point=1/`nplots' {
    qui summ col_int_num if col_int_num==`point'
    local labelnum=r(mean)
    local colorname: label col_int_num `labelnum'
    qui summ colornum if col_int_num==`point'
    local colnum=r(mean)
    local color: label colornum `colnum'
    qui summ intennum if col_int_num==`point'
    local intnum=r(mean)
    local inten: label intennum `intnum'
    local plot "`plot' (scatter inten colornum if col_int_num==`point', mcolor(`colorname') msize(huge) mlab(colorname) mlabc(`colorname') mlabsize(tiny) mlabpos(6))"
    }
*disp "`plot'" 
local xmax=`ncolor'+1 
twoway `plot' , legend(off) ylab(.25 (.25) 2) xlab(0 (1) `xmax', val) xtitle(color) ytitle(intensity)
graph export sample_color_swatch.png, replace
