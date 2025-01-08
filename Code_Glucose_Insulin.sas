/* Generierter Code (IMPORT) */
/* Quelldatei: 2024_04_02_SAS_PFI-X.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PFI-X */
/* Code generiert am: 02.04.24 13:39 */

%web_drop_table(glycemic_control);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PFI-X/2024_04_02_SAS_PFI-X.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=glycemic_control;
	GETNAMES=YES;
	SHEET="Hormones";
RUN;

PROC CONTENTS DATA=glycemic_control; RUN;


%web_open_table(glycemic_control);

/*---------------------------*/
/*CHECK DISTRIBUTIONS Glucose*/
/*---------------------------*/
proc univariate data=glycemic_control;
var delta_glucose;
where time > -15;
histogram delta_glucose / normal(mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;

/* box-cox transformation */
data glycemic_control;
set glycemic_control;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=glycemic_control maxiter=0 nozeroconstant;
   	model BoxCox(delta_glucose/parameter=3) = identity(z);
run;
/* check lambda in output, in this case 0.25
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data glycemic_control;
set glycemic_control;
bc_delta_gluc = ((delta_glucose+3)**0.25 -1)/0.25;
run;
/* boxcox formula, 0.25 is lambda*/

/* check normality of box-cox transformed variable */
proc univariate data=glycemic_control;
var bc_delta_gluc;
histogram bc_delta_gluc / normal (mu=est sigma=est);
run;
	

/*-------------------------------------------*/
/*MIXED MODEL GLUCOSE NOT ADJUSTED - NOT USED*/
/*-------------------------------------------*/
proc mixed data=glycemic_control;
where time > -15;
class subject condition time;
model delta_glucose = condition | time total_energy_intake_kcal/ ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: no increase from -16 baseline in ace-K at time -1 i.e. after preload before test meal' 1 0 0 0 0 0 0 0,
    'hypothesis 1: increase from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
    'hypothesis 1: no increase from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: increase from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: small change from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: small difference from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: small change from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 

/*----------------------------------*/
/*MIXED MODEL ADJUSTED FOR NORMALITY*/
/*----------------------------------*/
proc mixed data=glycemic_control;
where time > -15;
class subject condition time;
model bc_delta_gluc = condition | time total_energy_intake_kcal/ ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: no increase from -16 baseline in ace-K at time -1 i.e. after preload before test meal' 1 0 0 0 0 0 0 0,
    'hypothesis 1: increase from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
    'hypothesis 1: no increase from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: increase from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: small change from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: small difference from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: small change from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
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
	/*hypothesis 2: difference between test solutions after preload until time 15 during the test meal*/
	
/* significant main effect of condition and significant condition*time interaction effect*/
/* significant differences x vs s from -16 to -1, no differences x vs a or w */
/* significant differences x vs s from -1 to 15, no differences x vs a or w */


proc mixed data=glycemic_control;
where time > -1;
class subject condition time;
model delta_delta_glucose = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 3: change from -1 baseline in ace-K at time 180' -7 1 1 1 1 1 1,
	'hypothesis 3: change from -1 baseline in sucrose at time 180' 0 0 0 0 0 0 0 -7 1 1 1 1 1 1,
    'hypothesis 3: change from -1 baseline in tap water at time 180' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -7 1 1 1 1 1 1,
	'hypothesis 3: change from -1 baseline in xylitol at time 180' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -7 1 1 1 1 1 1/ adjdfe=row divisor = 7; 
	/*hypothesis 3: change from -1 baseline (-16=0 and -1=0) to time 180*/
lsmestimate condition*time
	'hypothesis 3: similar increase from -1 baseline in xylitol compared to ace-K at time 180' -7 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 -1 -1 -1 -1 -1 -1,
	'hypothesis 3: stronger or lower increase from -1 baseline in xylitol compared to sucrose at time 180' 0 0 0 0 0 0 0 -7 1 1 1 1 1 1 0 0 0 0 0 0 0 7 -1 -1 -1 -1 -1 -1,
	'hypothesis 3: similar increase from -1 baseline in xylitol compared to tap water at time 180' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -7 1 1 1 1 1 1 7 -1 -1 -1 -1 -1 -1 / adjdfe=row adjust=bon stepdown joint (label='hypothesis 3');
	/*hypothesis 3: difference between test solutions from -1 baseline (-1=0) to time 180*/

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*---------------------------*/
/*CHECK DISTRIBUTIONS Insulin*/
/*---------------------------*/

proc univariate data=glycemic_control;
var delta_insulin;
where time > -15;
histogram delta_insulin / normal(mu=est sigma=est) lognormal (sigma=est theta=est zeta=est);
run;
* transformation needed reg. Shapiro and Kolmogorov;

/* box-cox transformation */
data glycemic_control;
set glycemic_control;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=glycemic_control maxiter=0 nozeroconstant;
   	model BoxCox(delta_insulin/parameter=15) = identity(z);
run;
/* check lambda in output, in this case 0
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data glycemic_control;
set glycemic_control;
bc_delta_insulin = log(delta_insulin);
run;
/* boxcox formula, 0 is lambda*/

/* check normality of box-cox transformed variable */
proc univariate data=glycemic_control;
var bc_delta_insulin;
histogram bc_delta_insulin / normal (mu=est sigma=est);
run;

/*-------------------------------------------*/
/*MIXED MODEL INSULIN NOT ADJUSTED - NOT USED*/
/*-------------------------------------------*/

proc mixed data=glycemic_control;
where time > -15;
class subject condition time;
model delta_insulin = condition | time total_energy_intake_kcal/ ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: no increase from -16 baseline in ace-K at time -1 i.e. after preload before test meal' 1 0 0 0 0 0 0 0,
    'hypothesis 1: increase from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
    'hypothesis 1: no increase from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: increase from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: small change from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: small difference from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: small change from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
	/*hypothesis 1: difference or no difference between test solutions after preload before test meal.*/ 


/*------------------------------------*/
/* MIXED MODEL ADJUSTED FOR NORMALITY */
/*------------------------------------*/

proc mixed data=glycemic_control;
where time > -15;
class subject condition time;
model bc_delta_insulin = condition | time total_energy_intake_kcal/ ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 1: no increase from -16 baseline in ace-K at time -1 i.e. after preload before test meal' 1 0 0 0 0 0 0 0,
    'hypothesis 1: increase from -16 baseline in sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
    'hypothesis 1: no increase from -16 baseline in water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: increase from -16 baseline in xylitol at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0/ adjdfe=row divisor = 1; 
	/*hypothesis 1: change or no change from -16 baseline (-16=0) after preload before test meal*/
lsmestimate condition*time
	'hypothesis 1: small change from -16 baseline in xylitol compared to ace-K at time -1 i.e. after preload before test meal' -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: small difference from -16 baseline in xylitol compared to sucrose at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0,
	'hypothesis 1: small change from -16 baseline in xylitol compared to tap water at time -1 i.e. after preload before test meal' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 / adjdfe=row adjust=bon stepdown joint (label='hypotheses 1');
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
	/*hypothesis 2: difference between test solutions after preload until time 15 during the test meal*/
	
/* significant main effect of condition and significant condition*time interaction effect*/
/* significant differences x vs s from -16 to -1, significant differences x vs a or x vs w */
/* no differences x vs s from -1 to 15 and x vs w , significant differences x vs a */

proc mixed data=glycemic_control;
where time > -1;
class subject condition time;
model delta_delta_insulin = condition | time total_energy_intake_kcal / ddfm=kr2 solution influence residual;
repeated condition time / subject=subject type=un@ar(1) r rcorr;
lsmeans condition / diff=all;
lsmeans condition*time / slice=time;
lsmestimate condition*time
	'hypothesis 3: change from -1 baseline in ace-K at time 180' -7 1 1 1 1 1 1,
	'hypothesis 3: change from -1 baseline in sucrose at time 180' 0 0 0 0 0 0 0 -7 1 1 1 1 1 1,
    'hypothesis 3: change from -1 baseline in tap water at time 180' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -7 1 1 1 1 1 1,
	'hypothesis 3: change from -1 baseline in xylitol at time 180' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -7 1 1 1 1 1 1/ adjdfe=row divisor = 7; 
	/*hypothesis 3: change from -1 baseline (-16=0 and -1=0) to time 180*/
lsmestimate condition*time
	'hypothesis 3: similar increase from -1 baseline in xylitol compared to ace-K at time 180' -7 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 -1 -1 -1 -1 -1 -1,
	'hypothesis 3: stronger or lower increase from -1 baseline in xylitol compared to sucrose at time 180' 0 0 0 0 0 0 0 -7 1 1 1 1 1 1 0 0 0 0 0 0 0 7 -1 -1 -1 -1 -1 -1,
	'hypothesis 3: similar increase from -1 baseline in xylitol compared to tap water at time 180' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -7 1 1 1 1 1 1 7 -1 -1 -1 -1 -1 -1 / adjdfe=row adjust=bon stepdown joint (label='hypothesis 3');
	/*hypothesis 3: difference between test solutions from -1 baseline (-1=0) to time 180*/
	

