% ISOLA configuration file
% this file will be used for ISOLA defaults 
% e.g. the GMT version the ps file viewer etc.
%
% percent signs (%) denote comments (% sign MUST be in first column )   
% DO NOT change the text before the : sign 
% use a text editor for editing the file e.g. notepad, NOT Word or Wordpad
%
% Give the GMT version you wish to use
% DO not give sub version
% e.g. for version 4.5.16 give just 4
%
GMT version: 6
% other comments
%
% Give the postscript file viewer you wish to use
% this is usually gsview (either 32 or 64). Remember that it must be in your
% system path. For linux you may use e.g. gv or any other ps viewer.
%
%PS FILE VIEWER: evince
PS FILE VIEWER: gsview32
%
%
% The number of samples that will be used in inversion
% ONLY CHOICE for ISOLA 2024 is 1024 
% DO NOT CHANGE THIS NUMBER 
%
NUMBER OF INVERSION SAMPLES: 1024
%
% if you want to use the new code with covariance matrix you need Intel Fortran installed !
% possible choices are NO, YES (in capital!!)
USE COVARIANCE: YES
%
%
% Html folder will be used for storing html reports
% use word null to disable this option
% e.g. HTML FOLDER: null
% 
HTML FOLDER: null
%