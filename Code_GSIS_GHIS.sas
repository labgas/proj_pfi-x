/* Generierter Code (IMPORT) */
/* Quelldatei: 2024_04_02_SAS_PFI-X.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PFI-X */
/* Code generiert am: 02.04.24 13:42 */

%web_drop_table(GSIS_GHIS);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PFI-X/2024_04_02_SAS_PFI-X.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=GSIS_GHIS;
	GETNAMES=YES;
	SHEET="Energy_intake";
RUN;

PROC CONTENTS DATA=GSIS_GHIS; RUN;


%web_open_table(GSIS_GHIS);

/*------------------------------------*/
/*CHECK DISTRIBUTION SWEETNESS PRELOAD*/
/*------------------------------------*/
proc univariate data=GSIS_GHIS;
var sweetness_preload;
histogram sweetness_preload / normal; 
run;
/*Kolmogorov p-value<0.05*/

/* box-cox transformation */
data GSIS_GHIS;
set GSIS_GHIS;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=GSIS_GHIS maxiter=0 nozeroconstant;
   	model BoxCox(sweetness_preload/parameter=1) = identity(z);
run;
/* check lambda in output, in this case 1
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data GSIS_GHIS;
set GSIS_GHIS;
bc_sweetness_preload = (sweetness_preload**1 -1)/1;
run;

/* check normality of box-cox transformed variable */
proc univariate data=GSIS_GHIS;
var bc_sweetness_preload;
histogram bc_sweetness_preload / normal (mu=est sigma=est);
run;


/*---------------------------------------------*/
/*MIXED MODEL SWEETNESS NOT ADJUSTED - NOT USED*/
/*---------------------------------------------*/
proc mixed data=GSIS_GHIS;
class subject condition;
model sweetness_preload = condition / solution influence residual;
repeated condition / subject = subject type=un r rcorr;
lsmeans condition / diff = all adjust=tukey;
run;

/*------------------------------------*/
/* MIXED MODEL ADJUSTED FOR NORMALITY */
/*------------------------------------*/
proc mixed data=GSIS_GHIS;
class subject condition;
model bc_sweetness_preload = condition / solution influence residual;
repeated condition / subject = subject type=un r rcorr;
lsmeans condition / diff = all adjust=tukey;
run;

/*--------------------------------------------------------------------------*/

/*---------------------------------*/
/*CHECK DISTRIBUTION LIKING PRELOAD*/
/*---------------------------------*/
proc univariate data=GSIS_GHIS;
var liking_preload;
histogram liking_preload / normal; 
run;

/* box-cox transformation */
data GSIS_GHIS;
set GSIS_GHIS;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=GSIS_GHIS maxiter=0 nozeroconstant;
   	model BoxCox(liking_preload/parameter=83) = identity(z);
run;
/* check lambda in output, in this case 0.75
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data GSIS_GHIS;
set GSIS_GHIS;
bc_liking_preload = ((liking_preload+83)**0.75 -1)/0.75;
run;
/* boxcox formula, 0.75 is lambda*/

/* check normality of box-cox transformed variable */
proc univariate data=GSIS_GHIS;
var bc_liking_preload;
histogram bc_liking_preload / normal (mu=est sigma=est);
run;

/*------------------------------------------*/
/*MIXED MODEL LIKING NOT ADJUSTED - NOT USED*/
/*------------------------------------------*/
proc mixed data=GSIS_GHIS;
class subject condition;
model liking_preload = condition / solution;
repeated condition / subject = subject type=un r rcorr;
lsmeans condition / diff = all adjust=tukey;
run;

/*------------------------------------*/
/* MIXED MODEL ADJUSTED FOR NORMALITY */
/*------------------------------------*/
proc mixed data=GSIS_GHIS;
class subject condition;
model bc_liking_preload = condition / solution;
repeated condition / subject = subject type=un r rcorr;
lsmeans condition / diff = all adjust=tukey;
run;

/*-----------------------------------------------------------------------------------*/

/*----------------------------------*/
/*CHECK DISTRIBUTION LIKING TESTMEAL*/
/*----------------------------------*/
proc univariate data=GSIS_GHIS;
var liking_testmeal;
histogram liking_testmeal / normal; 
run;
/*Kolmogorov p-value<0.05*/

/* box-cox transformation */
data GSIS_GHIS;
set GSIS_GHIS;
z=0;
run;
/* adds variable z with all zeros, needed in proc transreg */

proc transreg data=GSIS_GHIS maxiter=0 nozeroconstant;
   	model BoxCox(liking_testmeal/parameter=59) = identity(z);
run;
/* check lambda in output, in this case 1.5
parameter is constant to make all values positive if there are negative values, hence parameter = |minimum|, see below */

data GSIS_GHIS;
set GSIS_GHIS;
bc_liking_testmeal = ((liking_preload+59)**1.5 -1)/1.5;
run;

/* check normality of box-cox transformed variable */
proc univariate data=GSIS_GHIS;
var bc_liking_testmeal;
histogram bc_liking_testmeal / normal (mu=est sigma=est);
run;

/*-------------------------------*/
/*MIXED MODEL LIKING NOT ADJUSTED*/
/*-------------------------------*/

proc mixed data=GSIS_GHIS;
class subject condition;
model liking_testmeal = condition / solution influence residual;
repeated condition / subject = subject type=un r rcorr;
lsmeans condition / diff = all adjust=tukey;
run;

/*----------------------------------------------*/
/* MIXED MODEL ADJUSTED FOR NORMALITY - NOT USED*/
/*----------------------------------------------*/
proc mixed data=GSIS_GHIS;
class subject condition;
model bc_liking_testmeal = condition / solution influence residual;
repeated condition / subject = subject type=un r rcorr;
lsmeans condition / diff = all adjust=tukey;
run;
