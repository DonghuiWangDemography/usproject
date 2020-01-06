*append all csv file 


cd "C:\Users\donghuiw\Dropbox\Website\US_project\agg_data\China_keywords"

local satafiles:  dir . files "*.csv"

foreach file of local satafiles {
import delimited `file',clear
save `file',replace
}

use          `roper_china_1950_1.csv', clear 
append using `roper_china_1950_2.csv'
append using `roper_china_1950_3.csv'
append using `roper_china_1960.csv'
append using `roper_china_1970_1.csv'
append using `roper_china_1970_2.csv'
append using `roper_china_1970_3.csv'
append using `roper_china_1970_4.csv'
append using `roper_china_1970_5.csv'
append using `roper_china_1980_1.csv'
append using `roper_china_1980_2.csv'

append using `roper_china_1990_1.csv'
append using `roper_china_1990_2.csv'
append using `roper_china_1990_3.csv'
append using `roper_china_1990_4.csv'
append using `roper_china_1990_5.csv'

append using `roper_china_1950_3.csv'
