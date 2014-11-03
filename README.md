<h1> isola</h1>
=====

ISOLA and ISOLA-GUI are the two parts of ISOLA moment tensor retrieval software package. Fortran code ISOLA to retrieve isolated asperities from regional or local waveforms has been developed since 2003. It is based on multiple-point source representation and iterative deconvolution, similar to Kikuchi and Kanamori (1991), but full wavefield is considered, and Green's functions are calculated by the discrete wavenumber method of Bouchon (1981) and Coutant (1989). Moment tensor of subevents is found by least-square minimization of misfit between observed and synthetic waveforms, while position and time of subevents is optimized through grid search. ISOLA-GUI, is a Graphical User Interface developed in Matlab with purpose to combine processing speed of the ISOLA Fortran code with user-friendly Matlab environment. Significant features of ISOLA-GUI are efficient data handling, interactive control of the inversion process, and wide options of plotting facilities to display the results. The ISOLA web page is here  http://seismo.geology.upatras.gr/isola/.

This is the ISOLA github distribution. Isola code updates will be sent here.


<h1>Installation</h1>
============

Copy the isola *.m, *.fig, *.exe files to your isola installation folder (e.g. c:\isola). Then add this folder to your system path and to your Matlab path. Restart Matlab, change directory (cd) to the folder you want to use for processing an event (so called run folder) and type isola, the GUI will ininitialize in this folder and you can start work with isola.


