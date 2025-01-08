/* Generierter Code (IMPORT) */
/* Quelldatei: 2024_04_02_SAS_PFI-X.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PFI-X */
/* Code generiert am: 02.04.24 13:39 */

%web_drop_table(VAS);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PFI-X/2024_04_02_SAS_PFI-X.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=VAS;
	GETNAMES=YES;
	SHEET="Hormones";
RUN;

PROC CONTENTS DATA=VAS; RUN;


%web_open_table(VAS);

/*--------------------------*/
/*CHECK DISTRIBUTIONS HUNGER*/
/*--------------------------*/
proc univariate data=VAS;
var delta_hunger;
where time > -15;
histogram delta_hunger/ normal(mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data VAS;
set VAS;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=VAS maxiter=0 nozeroconstant;
   	model BoxCox(delta_hunger/parameter=8) = identity(z);
run;
/* check lambda in output, in this case 0.75
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data VAS;
set VAS;
bc_delta_hunger = ((delta_hunger+8)**0.75 -1)/0.75;
run;
/* boxcox formula, 0.75 is lambda*/

/* check normality of box-cox transformed variable */
proc univariate data=VAS;
var bc_delta_hunger;
histogram bc_delta_hunger / normal (mu=est sigma=est);
run;

/*------------------------------------------*/
/*MIXED MODEL HUNGER NOT ADJUSTED - NOT USED*/
/*------------------------------------------*/
proc mixed data=VAS;
where time > -15;
class subject condition time;
model delta_hunger = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0,
    'hypothesis 1: no change from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
    'hypothesis 1: decrease from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
	'hypothesis 1: no change from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: similar (=no) change from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: decrease from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 
lsmestimate condition*time
	'hypothesis 2: change from baseline in ace-K at time 15 i.e. after preload and test meal' 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: change from baseline in xylitol at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0/ adjdfe=row divisor = 7; 
	/*hypothesis 2: change from baseline (-16=0) after preload until time 15 during the test meal*/
lsmestimate condition*time
	'hypothesis 2: slight increase from baseline in xylitol compared to ace-K at time 15 i.e. after preload and test meal' 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: lower increase from baseline in xylitol compared to sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: slight increase from baseline in xylitol compared to tap water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 / adjdfe=row divisor=7 adjust=bon stepdown joint (label='hypotheses 2');
	/*hypothesis 2: difference between test solutions after preload AND test meal*/

/*------------------------------------*/
/* MIXED MODEL ADJUSTED FOR NORMALITY */
/*------------------------------------*/
proc mixed data=VAS;
where time > -15;
class subject condition time;
model bc_delta_hunger = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0,
    'hypothesis 1: no change from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
    'hypothesis 1: decrease from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
	'hypothesis 1: no change from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: similar (=no) change from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: decrease from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 
lsmestimate condition*time
	'hypothesis 2: change from baseline in ace-K at time 15 i.e. after preload and test meal' 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: change from baseline in xylitol at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0/ adjdfe=row divisor = 7; 
	/*hypothesis 2: change from baseline (-16=0) after preload until time 15 during the test meal*/
lsmestimate condition*time
	'hypothesis 2: slight increase from baseline in xylitol compared to ace-K at time 15 i.e. after preload and test meal' 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: lower increase from baseline in xylitol compared to sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: slight increase from baseline in xylitol compared to tap water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 / adjdfe=row divisor=7 adjust=bon stepdown joint (label='hypotheses 2');
	/*hypothesis 2: difference between test solutions after preload AND test meal*/

/*---------------------------------------------------------------------------------------*/

/*-----------------------*/
/*CHECK DISTRIBUTIONS PFC*/
/*-----------------------*/
proc univariate data=VAS;
var delta_pfc;
where time > -15;
histogram delta_pfc/ normal(mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data VAS;
set VAS;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=VAS maxiter=0 nozeroconstant;
   	model BoxCox(delta_pfc/parameter=9) = identity(z);
run;
/* check lambda in output, in this case 0.5
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data VAS;
set VAS;
bc_delta_pfc = ((delta_pfc+9)**0.5 -1)/0.5;
run;
/* boxcox formula, 0.5 is lambda*/

/* check normality of box-cox transformed variable */
proc univariate data=VAS;
var bc_delta_pfc;
histogram bc_delta_pfc / normal (mu=est sigma=est);
run;

/*---------------------------------------*/
/*MIXED MODEL PFC NOT ADJUSTED - NOT USED*/
/*---------------------------------------*/
proc mixed data=VAS;
where time > -15;
class subject condition time;
model delta_pfc = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0,
    'hypothesis 1: no change from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
    'hypothesis 1: decrease from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
	'hypothesis 1: no change from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: similar (=no) change from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: decrease from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 
lsmestimate condition*time
	'hypothesis 2: change from baseline in ace-K at time 15 i.e. after preload and test meal' 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: change from baseline in xylitol at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0/ adjdfe=row divisor = 7; 
	/*hypothesis 2: change from baseline (-16=0) after preload until time 15 during the test meal*/
lsmestimate condition*time
	'hypothesis 2: slight increase from baseline in xylitol compared to ace-K at time 15 i.e. after preload and test meal' 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: lower increase from baseline in xylitol compared to sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: slight increase from baseline in xylitol compared to tap water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 / adjdfe=row divisor=7 adjust=bon stepdown joint (label='hypotheses 2');
	/*hypothesis 2: difference between test solutions after preload AND test meal*/

/*------------------------------------*/
/* MIXED MODEL ADJUSTED FOR NORMALITY */
/*------------------------------------*/
proc mixed data=VAS;
where time > -15;
class subject condition time;
model bc_delta_pfc = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0,
    'hypothesis 1: no change from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
    'hypothesis 1: decrease from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
	'hypothesis 1: no change from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: similar (=no) change from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: decrease from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 
lsmestimate condition*time
	'hypothesis 2: change from baseline in ace-K at time 15 i.e. after preload and test meal' 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: change from baseline in xylitol at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0/ adjdfe=row divisor = 7; 
	/*hypothesis 2: change from baseline (-16=0) after preload until time 15 during the test meal*/
lsmestimate condition*time
	'hypothesis 2: slight increase from baseline in xylitol compared to ace-K at time 15 i.e. after preload and test meal' 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: lower increase from baseline in xylitol compared to sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: slight increase from baseline in xylitol compared to tap water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 / adjdfe=row divisor=7 adjust=bon stepdown joint (label='hypotheses 2');
	/*hypothesis 2: difference between test solutions after preload AND test meal*/

/*------------------------------------------------------------------------------------*/

/*----------------------------*/
/* CHECK DISTRIBUTION SATIETY */
/*----------------------------*/
proc univariate data=VAS;
var delta_satiety;
where time > -15;
histogram delta_satiety/ normal(mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data VAS;
set VAS;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=VAS maxiter=0 nozeroconstant;
   	model BoxCox(delta_satiety/parameter=4) = identity(z);
run;
/* check lambda in output, in this case 0.75
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data VAS;
set VAS;
bc_delta_satiety = ((delta_satiety+4)**0.75 -1)/0.75;
run;
/* boxcox formula, 0.5 is lambda*/

/* check normality of box-cox transformed variable */
proc univariate data=VAS;
var bc_delta_satiety;
histogram bc_delta_satiety / normal (mu=est sigma=est);
run;


/*-------------------------------------------*/
/*MIXED MODEL SATIETY NOT ADJUSTED - NOT USED*/
/*-------------------------------------------*/
proc mixed data=VAS;
where time > -15;
class subject condition time;
model delta_satiety = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0,
    'hypothesis 1: no change from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
    'hypothesis 1: decrease from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
	'hypothesis 1: no change from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: similar (=no) change from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: decrease from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 
lsmestimate condition*time
	'hypothesis 2: change from baseline in ace-K at time 15 i.e. after preload and test meal' 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: change from baseline in xylitol at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0/ adjdfe=row divisor = 7; 
	/*hypothesis 2: change from baseline (-16=0) after preload until time 15 during the test meal*/
lsmestimate condition*time
	'hypothesis 2: slight increase from baseline in xylitol compared to ace-K at time 15 i.e. after preload and test meal' 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: lower increase from baseline in xylitol compared to sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: slight increase from baseline in xylitol compared to tap water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 / adjdfe=row divisor=7 adjust=bon stepdown joint (label='hypotheses 2');
	/*hypothesis 2: difference between test solutions after preload AND test meal*/

/*------------------------------------*/
/* MIXED MODEL ADJUSTED FOR NORMALITY */
/*------------------------------------*/
proc mixed data=VAS;
where time > -15;
class subject condition time;
model bc_delta_satiety = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0,
    'hypothesis 1: no change from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
    'hypothesis 1: decrease from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
	'hypothesis 1: no change from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: similar (=no) change from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: decrease from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 
lsmestimate condition*time
	'hypothesis 2: change from baseline in ace-K at time 15 i.e. after preload and test meal' 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: change from baseline in xylitol at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0/ adjdfe=row divisor = 7; 
	/*hypothesis 2: change from baseline (-16=0) after preload until time 15 during the test meal*/
lsmestimate condition*time
	'hypothesis 2: slight increase from baseline in xylitol compared to ace-K at time 15 i.e. after preload and test meal' 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: lower increase from baseline in xylitol compared to sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: slight increase from baseline in xylitol compared to tap water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 / adjdfe=row divisor=7 adjust=bon stepdown joint (label='hypotheses 2');
	/*hypothesis 2: difference between test solutions after preload AND test meal*/

/*-------------------------------------------------------------------------------------*/

/*-----------------------------*/
/* CHECK DISTRIBUTION FULLNESS */
/*-----------------------------*/
proc univariate data=VAS;
var delta_fullness;
where time > -15;
histogram delta_fullness/ normal(mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data VAS;
set VAS;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=VAS maxiter=0 nozeroconstant;
   	model BoxCox(delta_fullness/parameter=5) = identity(z);
run;
/* check lambda in output, in this case 0.75
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data VAS;
set VAS;
bc_delta_fullness = ((delta_fullness+4)**0.75 -1)/0.75;
run;
/* boxcox formula, 0.5 is lambda*/

/* check normality of box-cox transformed variable */
proc univariate data=VAS;
var bc_delta_fullness;
histogram bc_delta_fullness / normal (mu=est sigma=est);
run;


/*--------------------------------------------*/
/*MIXED MODEL FULLNESS NOT ADJUSTED - NOT USED*/
/*--------------------------------------------*/
proc mixed data=VAS;
where time > -15;
class subject condition time;
model delta_fullness = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0,
    'hypothesis 1: no change from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
    'hypothesis 1: decrease from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
	'hypothesis 1: no change from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: similar (=no) change from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: decrease from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 
lsmestimate condition*time
	'hypothesis 2: change from baseline in ace-K at time 15 i.e. after preload and test meal' 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: change from baseline in xylitol at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0/ adjdfe=row divisor = 7; 
	/*hypothesis 2: change from baseline (-16=0) after preload until time 15 during the test meal*/
lsmestimate condition*time
	'hypothesis 2: slight increase from baseline in xylitol compared to ace-K at time 15 i.e. after preload and test meal' 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: lower increase from baseline in xylitol compared to sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: slight increase from baseline in xylitol compared to tap water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 / adjdfe=row divisor=7 adjust=bon stepdown joint (label='hypotheses 2');
	/*hypothesis 2: difference between test solutions after preload AND test meal*/

/*------------------------------------*/
/* MIXED MODEL ADJUSTED FOR NORMALITY */
/*------------------------------------*/
proc mixed data=VAS;
where time > -15;
class subject condition time;
model bc_delta_fullness = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0,
    'hypothesis 1: no change from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
    'hypothesis 1: decrease from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0,
	'hypothesis 1: no change from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: decrease from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: similar (=no) change from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: decrease from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 
lsmestimate condition*time
	'hypothesis 2: change from baseline in ace-K at time 15 i.e. after preload and test meal' 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
    'hypothesis 2: change from baseline in water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: change from baseline in xylitol at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 2: change from baseline (-16=0) after preload until time 15 during the test meal*/
lsmestimate condition*time
	'hypothesis 2: slight increase from baseline in xylitol compared to ace-K at time 15 i.e. after preload and test meal' 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: lower increase from baseline in xylitol compared to sucrose at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0,
	'hypothesis 2: slight increase from baseline in xylitol compared to tap water at time 15 i.e. after preload and test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 / adjdfe=row divisor=1 adjust=bon stepdown joint (label='hypotheses 2');
	/*hypothesis 2: difference between test solutions after preload AND test meal*/

