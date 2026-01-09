* Paramètres
capture macro drop YEAR
local YEAR = 2014
local ROOT "/Users/veroniquegille/Documents/ICRISAT_femalelabor/ICRESAT_India_agriculture"
local RAW   "`ROOT'/raw_data"
local OUT   "`ROOT'/Base de données générées/Cultivation_wide"

cap mkdir "`ROOT'/Base de données générées"
cap mkdir "`OUT'"

* ---- DEFINIR LES TEMPFILES QUE TU VAS UTILISER ----
tempfile SAT_CultInput SAT_Household

* ---- IMPORTER ET SAUVER DANS CES TEMPFILES ----
foreach T in CultInput Household_spl {
    local file "`RAW'/SAT_`T'_`YEAR'.xlsx"
    import excel using "`file'", firstrow clear

	drop if VDS_ID == ""
	
    if "`T'"=="CultInput"  save `SAT_CultInput', replace
    if "`T'"=="Household_spl"  save `SAT_Household', replace
}



* ---- UTILISER ET MERGER ----
use `SAT_Household', clear
*tab VDS_ID
*replace VDS_ID = substr(VDS_ID, 1, 3) + "14" + substr(VDS_ID, 6, .)
* 101 individus non-matchés ! 
* >>> Remplace VDS_ID par la/les vraie(s) clé(s) de jointure <<<
merge 1:m VDS_ID using `SAT_CultInput'

tab _merge

cd "/Users/veroniquegille/Documents/ICRISAT_femalelabor/ICRESAT_India_agriculture/Base de données générées/"

use "Cultivation_oper/Cultivation_oper_all.dta", clear

keep if OPERATION == "WEEDING"
collapse (sum) HACRE_T , by(VDS_ID YEAR SEASON)
g hours_WEEDING = HACRE_T


merge 1:1 VDS_ID YEAR SEASON using  "Cultivation_hh/Cultivation_hh_all.dta"

g FC = (CASTE_GROUP == "FC")
label variable FC "Forward Caste"
label variable AREA_HH "Total Area (Acres)"
label variable AREA_HH_SQ "Total Area sq. (Acres)"
g use_weedicide = ( WEEDICIDE_KG > 0 |  WEEDICIDE_LT > 0)
g tot_weedicide = WEEDICIDE_KG + WEEDICIDE_LT
g use_chemicals = ( WEEDICIDE_KG > 0 |  WEEDICIDE_LT > 0 | FERTILIZER_KG > 0 | (FERTILIZER_LT  > 0  & FERTILIZER_LT < .)| PESTICIDE_KG  > 0 | PESTICIDE_LT  > 0 )
g tot_weedicide = WEEDICIDE_KG + WEEDICIDE_LT
egen tot_chemicals = rowtotal(WEEDICIDE_KG  WEEDICIDE_LT  FERTILIZER_KG FERTILIZER_LT  PESTICIDE_KG PESTICIDE_LT)
g share_weedicide = tot_weedicide/AREA_HH
g share_chemicals = tot_chemicals/AREA_HH 
g share_female_f = WORK_HR_FF/WORK_HR_T
g share_f_wfemale = WORK_HR_FF/(WORK_HR_FF + WORK_HR_HF)
* labor time 
eststo clear
eststo: xi: reg HACRE_FF i.YEAR FC i.VILLAGE  AREA_HH AREA_HH_SQ if SEASON == "KHARIF" & VILLAGE_CROP == "PADDY", cluster(VDS_ID)
eststo: xi: reg share_female_f i.YEAR FC i.VILLAGE  AREA_HH AREA_HH_SQ if SEASON == "KHARIF" & VILLAGE_CROP == "PADDY", cluster(VDS_ID)
eststo:xi: reg share_f_wfemale i.YEAR FC i.VILLAGE  AREA_HH AREA_HH_SQ if SEASON == "KHARIF" & VILLAGE_CROP == "PADDY", cluster(VDS_ID)

esttab ///
using "~/IRD Dropbox/Véronique Gille/Applications/Overleaf/Female_labor_India/reg/LaborTime.tex", ///
label tex replace se star(* 0.10 ** 0.05 *** 0.01) collabels(none) nogaps f  ///
prehead("&\multicolumn{3}{c}{Family Female Labor time} \\ & Per Acre & Share of total time & Share of female time \\") nomtitle nogaps indicate("Year dummies = *YEAR*"  "Village dummies = *VILLAGE*") s(N, label("N Observations") fmt(0)) 


* Weeding
xi: reg hours_WEEDING i.YEAR i.FC i.VILLAGE  AREA_HH AREA_HH_SQ if SEASON == "KHARIF" & VILLAGE_CROP == "PADDY", cluster(VDS_ID)
xi: reg use_weedicide i.YEAR i.FC i.VILLAGE  AREA_HH AREA_HH_SQ if SEASON == "KHARIF" & VILLAGE_CROP == "PADDY", cluster(VDS_ID)
xi: reg use_chemicals i.YEAR i.FC i.VILLAGE  AREA_HH AREA_HH_SQ if SEASON == "KHARIF" & VILLAGE_CROP == "PADDY", cluster(VDS_ID)
xi: reg use_chemicals i.YEAR i.FC i.VILLAGE  AREA_HH AREA_HH_SQ if SEASON == "KHARIF" & VILLAGE_CROP == "PADDY", cluster(VDS_ID)
xi: reg share_chemicals i.YEAR i.FC i.VILLAGE if SEASON == "KHARIF" & VILLAGE_CROP == "PADDY", cluster(VDS_ID)
* proba weeding
* nb_hours weeding
* proba chemical 
* quantity chemical 
* 
