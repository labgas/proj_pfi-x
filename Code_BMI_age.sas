/* Generierter Code (IMPORT) */
/* Quelldatei: 2024_04_02_SAS_PFI-X.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PFI-X */
/* Code generiert am: 23.05.24 14:52 */

%web_drop_table(BMI);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PFI-X/2024_04_02_SAS_PFI-X.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=BMI;
	GETNAMES=YES;
	SHEET="Hormones";
RUN;

PROC CONTENTS DATA=BMI; RUN;


%web_open_table(BMI);


/* mean of BMI */
proc means data=BMI mean;
	var BMI_kg_m2;
run;
/* mean = 23.04 */


/* sd of BMI */
proc means data=BMI std;
	var BMI_kg_m2;
run;
/* sd = 1.41 */

/* mean of age */
proc means data=BMI mean;
	var age_yrs;
run;
/* mean = 27.45 */

/* sd of age */
proc means data=BMI std;
	var age_yrs;
run;
/* sd = 7.82 */