/* Generierter Code (IMPORT) */
/* Quelldatei: 2024_07_01_SAS_PFI-X_association.xlsx */
/* Quellpfad: /home/u59615011/sasuser.v94/PFI-X */
/* Code generiert am: 02.07.24 16:17 */

%web_drop_table(asso);


FILENAME REFFILE '/home/u59615011/sasuser.v94/PFI-X/2024_07_01_SAS_PFI-X_association.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=asso;
	GETNAMES=YES;
	SHEET="Associations";
RUN;

PROC CONTENTS DATA=asso; RUN;


%web_open_table(asso);

/*-----------------------------------*/
/* association energy intake and CCK */
/*-----------------------------------*/
proc corr data=asso plots=scatter spearman;
	var EI_X_S CCK_X_S;
run;

proc corr data=asso plots=scatter spearman;
	var EI_X_A CCK_X_A;
run;

proc corr data=asso plots=scatter spearman;
	var EI_X_W CCK_X_W;
run;

/*-------------------------------------*/
/* association energy intake and GLP-1 */
/*-------------------------------------*/
proc corr data=asso plots=scatter spearman;
	var EI_X_S GLP_X_S;
run;

proc corr data=asso plots=scatter spearman;
	var EI_X_A GLP_X_A;
run;

proc corr data=asso plots=scatter spearman;
	var EI_X_W GLP_X_W;
run;