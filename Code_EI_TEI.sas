/* Generierter Code (IMPORT) */
/* Quelldatei: 2024_04_02_SAS_PFI-X.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PFI-X */
/* Code generiert am: 02.04.24 13:42 */

%web_drop_table(energy_intake);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PFI-X/2024_04_02_SAS_PFI-X.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=energy_intake;
	GETNAMES=YES;
	SHEET="Energy_intake";
RUN;

PROC CONTENTS DATA=energy_intake; RUN;


%web_open_table(energy_intake);

/*-----------------------------------*/
/* CHECK DISTRIBUTION TEST MEAL ONLY */
/*-----------------------------------*/
proc univariate data=energy_intake;
var energy_testmeal_wo_preload_kcal;
histogram energy_testmeal_wo_preload_kcal / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est); 
run;
/*Kolmogorov p-value<0.05--> not normally distributed*/

/* box-cox transformation */
data energy_intake;
set energy_intake;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=energy_intake maxiter=0 nozeroconstant;
   	model BoxCox(energy_testmeal_wo_preload_kcal/parameter=0) = identity(z);
run;
/* check lambda in output, in this case 0, no negative parameters
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data energy_intake;
set energy_intake;
bc_ei_wo_preload_kcal = log(energy_testmeal_wo_preload_kcal);
run;
/* boxcox formula when lambda is 0*/

/* check normality of box-cox transformed variable */
proc univariate data=energy_intake;
var bc_ei_wo_preload_kcal;
histogram bc_ei_wo_preload_kcal / normal (mu=est sigma=est);
run;

/*----------------------------------------------------------------*/
/* CHECK DISTRIBUTION TOTAL ENERGY INTAKE (TEST MEAL AND PRELOAD) */
/*----------------------------------------------------------------*/
proc univariate data=energy_intake;
var total_energy_intake_kcal;
histogram total_energy_intake_kcal / normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;
/*Kolmogorov p-value<0.05--> not normally distributed*/

/* box-cox transformation */
data energy_intake;
set energy_intake;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=energy_intake maxiter=0 nozeroconstant;
   	model BoxCox(total_energy_intake_kcal/parameter=0) = identity(z);
run;
/* check lambda in output, in this case 0
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data energy_intake;
set energy_intake;
bc_total_ei_kcal = log(total_energy_intake_kcal);
run;
/* boxcox formula, 0 is lambda --> use log(variable)*/

/* check normality of box-cox transformed variable */
proc univariate data=energy_intake;
var bc_total_ei_kcal;
histogram bc_total_ei_kcal / normal (mu=est sigma=est);
run;


/*---------------------------------------*/
/* model for energy intake testmeal only */
/*---------------------------------------*/

/*adjusted for normality*/ 
proc mixed data=energy_intake;
class subject condition;
model bc_ei_wo_preload_kcal = condition / solution;
repeated condition / subject = subject type=un r rcorr;
lsmeans condition / diff = all adjust=tukey;
run;
/* "wo" means without */

/*---------------------------------------------------*/
/* model for total energy intake (pre-load+testmeal) */
/*---------------------------------------------------*/

/*adjusted for normality*/
proc mixed data=energy_intake;
class subject condition;
model bc_total_ei_kcal = condition / solution;
repeated condition / subject = subject type=un r rcorr;
lsmeans condition / diff = all adjust=tukey;
run;
