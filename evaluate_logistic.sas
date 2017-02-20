FILENAME REFFILE '/folders/myfolders/liver_patients/sample_liver_patients.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=liver_patients;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/folders/myfolders/liver_patients/test_liver_patient.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=test;
	GETNAMES=YES;
RUN;

/*Clean Data*/
data patients;
	set liver_patients;
	if Gender='Female' then GenderGroup=1;
	else GenderGroup=0;
	
run;
/*Clean Data*/
data test_patients;
	set test;
	if Gender='Female' then GenderGroup=1;
	else GenderGroup=0;
	
run;

/*Build Model*/
proc logistic data=patients;
	model Target=Age GenderGroup TB DB Alkphos Sgpt Sgot TP ALB;
run;
quit;


/*Use model to test 'TEST DATA'*/
data test_p;
	set test_patients;
	logit = -2.1391 + 0.0202*Age - 0.0274*GenderGroup + 0.0138*TB + 0.2902*DB + 
	0.00127*Alkphos + 0.00949*Sgpt + 0.00271*Sgot + 0.5096*TP - 0.7185*ALB;
	
	p=exp(logit)/(exp(logit)+1);
	if p < 0.5 then Target_predicted = '2';
	else Target_predicted = '1';
	keep Target p Target_predicted;

run;
/*Use SOCRE statement to get series of 'Sensitivity and Specificity' 
  and ROC for 'TEST DATA' */
proc logistic data=patients;
	title 'ROC';
	model Target=Age GenderGroup TB DB Alkphos Sgpt Sgot TP ALB;
	score data=test_patients outroc=test_patients_roc;
run;
quit;

/*Confusion Matrix*/
proc freq data=test_p;
	title 'Confusion Table';
	tables Target*Target_predicted/nopercent nocol norow;
run;
/*Confusion Matrix*/
proc freq data=test_p;
	title 'Confusion Table';
	tables Target*Target_predicted;
run;

/*Draw ROC*/
ods graphics on;
proc logistic data=patients plots(only)=roc;
	title 'ROC';
	model Target=Age GenderGroup TB DB Alkphos Sgpt Sgot TP ALB;
run;
ods graphics off;





