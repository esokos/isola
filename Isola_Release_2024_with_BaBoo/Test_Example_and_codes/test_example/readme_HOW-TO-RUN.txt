HOW TO RUN the test example in folder test_example
1. Open Matlab command window, make sure you are in folder test_example.
2. Type baboo_weig(33,100). Here 33 = number of components (no. of stations times 3), 100 = number of perturbations.  
3. Two figures appear and the message "All ended OK for nn stations. Weights are in inpinv2.dat"; the latter file are the BaBoo weights.
4. Keep Matlab command window open.
5. Open Windows Command Shell, make sure you are in folder test_example.
6. Type isrand.exe. Parameters appear on screen, followed by the message "Running perturbations 1 to npert". Wait!
7. Final message appears "isorand_main finished" (MT inversion and space-time grid search were performed repeatedly for all perturbations).
8. Still in Windows Command Shell, folder test_example, type isproc.exe.
9. Code requests the NBEST parameter of the paper; for testing, choose 10 [as in Fig. 4 of the paper]. Output file CLVDetcPOST.dat is created.
10. Return to Matlab command window, folder test_example, and type boo_plots. Final message is "All done. Plots in folder Boo_plots".
11. Boo_plots folder contains all results in graphic form and their summary in numeric form: file Median_MT.dat (MT and its uncertainty).

Important remark:
Please note that if complete Isola GUI is installed, all steps 1-11 are automated using 
bootstrapgui.fig and bootstrapgui.m. 
They are included in codes\Matlab_source, but not used in the present example.
Here we presented manual running which does not need previous installation of complete Isola GUI.