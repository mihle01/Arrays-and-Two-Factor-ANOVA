libname HW2 "/home/u60739998/BS 805/Class 2";
filename blood "/home/u60739998/BS 805/Class 2/hw2_f2022_blood.csv";

proc import datafile=blood
	out=hw2_blood
	dbms=csv
	replace;
run;

proc format;
	value compf 0="Not Compliant"
				1="Compliant";
	value drugf 0="placebo"
				1="drug";
run;

data HW2.hw2_saved;
	set hw2_blood;
	
	array wtlb {2} wtlbs1 wtlbs2;
	array wtkg {2} wtkg1 wtkg2;
	do i=1 to 2;
		wtkg{i}= wtlb{i}/2.205;
	end;
	
	array base {2} wtkg1 sbp1;
	array after {2} wtkg2 sbp2;
	array diff {2} wtkg_diff sbp_diff;
	do i=1 to 2;
		diff{i}=base{i}-after{i};
	end;

	if wtkg_diff >= 10 then comp=1;
	else comp=0;
	format comp compf. drug drugf.;
run;
				
proc freq data=HW2.hw2_saved order=formatted;
	tables drug*comp/ nocol nopercent expected chisq measures;
run;

proc ttest data=HW2.hw2_saved order=formatted;
	class drug;
	var sbp_diff;
run;

proc ttest data=HW2.hw2_saved order=formatted;
	class drug;
	var wtkg_diff;
run;

proc ttest data=HW2.hw2_saved order=formatted;
	class comp;
	var sbp_diff;
run;

proc ttest data=HW2.hw2_saved order=formatted;
	class comp;
	var wtkg_diff;
run;

/*check assumptions for linear regression - diagnostic plots*/
proc reg data=HW2.hw2_saved;
	model sbp_diff=wtkg_diff/clb;
run;

proc corr data=HW2.hw2_saved;
	var sbp_diff wtkg_diff;
run;

/*2-factor ANOVA with interaction*/
proc glm data=HW2.hw2_saved;
	class drug comp;
	model sbp_diff=drug comp drug*comp;
run;

/*interaction term was not significant, therefore run without interaction*/
proc glm data=HW2.hw2_saved;
	class drug comp;
	model sbp_diff=drug comp;
	lsmeans drug comp / stderr cl adjust=tukey;
run;

/*check for balance of ANOVA model*/
proc freq data=HW2.hw2_saved;
	table drug*comp;
run;