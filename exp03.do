*individual IRT 
* created in 12/12/2019
* 
global image "C:\Users\donghuiw\Dropbox\Website\US_project\image"
cd "C:\Users\donghuiw\Dropbox\Website\US_project\cleaned_data"

use  "pooled.dta", clear 
	foreach x of varlist opc_10pn opc_4p opc_100p opc_3p {
	replace `x' =. if `x' ==999
	drop if `x'== 999
	}


// 	* reorganize vars 
// 	g gss      = opc_10pn if survey == "gss"
// 	g gallup10 = opc_10pn if survey == "gallup"
// 	g gallup4  = opc_4p   if survey == "gallup"
// 	g chicago = opc_100p  if survey == "chicago"
// 	g tra	  = opc_100p  if survey == "tra"
// 	g pew     = opc_4p    if survey == "pew"
// 	g cnn	  = opc_4p    if survey == "cnn"
// 	g abc	  = opc_3p    if survey == "abc"
// 	g cbs	  = opc_3p    if survey == "cbs"
// 	*three other one wave survey
// 	g pipa    = opc_4p if survey == "PIPA"
// 	g la      = opc_4p if survey == "la times"




