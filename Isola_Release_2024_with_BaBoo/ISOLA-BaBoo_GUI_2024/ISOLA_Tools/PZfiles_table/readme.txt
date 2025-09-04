Automatic pz file creation

1) Prepare a file like this
AGG	39.0211	22.3360		625	Ag.Georgios		TRIDENT		CMG-3ESP_100sec		2011-04-22	2050-01-01
ALN	40.8957	26.0497		110	Alexandroupoli		TRIDENT		Trillium120P		2010-11-24	2014-05-24
ALN	40.8957	26.0497		110	Alexandroupoli		TRIDENT		CMG-3ESP_100sec		2014-05-29	2050-01-01

2) Prepare one file per sensor and name it with the same name as the sensors above e.g. Trillium120P etc
file should be like this (values should be in rad/sec and velocity response) 

571507691.8
2975
2
0	0
0	0
5
-3.7014E-02	3.7014E-02
-3.7014E-02    -3.7014E-02
-1.1310E+03	0.0000E+00
-1.0053E+03	0.0000E+00
-5.0265E+02	0.0000E+00

firts line is A0
second is sensitivity of sensor in V/m/sec
number of zeroes
zeroes
number of poles
poles

3) In file digitizers.txt add your digitizers gain  in counts/Volt
e.g.
PS6-SC    400000
DR24-SC   266083.62423
TRIDENT16 1000000
TRIDENT40 400000


4) put all files in same folder

5) run e.g. table2pz('NOA3.dat','ANKY','2005-01-01');
to prepare pz file for station ANKY from file NOA3.dat for day 2005-01-01


Comments to esokos@upatras.gr
