*pew for US.

use "C:\Users\donghuiw\Dropbox\Website\data_nocollapse\pew_dw_2.dta", clear 

keep if country== 840
clonevar wt = weight
clonevar opc_4p = fav_china
keep syear wt opc_4p survey
save "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data\pew_us.dta", replace 
