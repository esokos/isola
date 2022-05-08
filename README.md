<h1> isola</h1>

ISOLA software package has been developed continually since 2003 and is continually upgraded. 
It is a combination of Matlab graphic user interface (by E. Sokos) and Fortran codes (by J. Zahradník). 
ISOLA is an all-in-one package, intended for a transparent and detailed manual processing of selected events.
It includes instrumental correction of records, calculation of 1D Green functions, inversion of full waveforms for
point source models in terms of centroid position and moment tensor (full, deviatoric, or DC-constrained), 
including the uncertainty analysis. ISOLA is also unique software for regional multiple-point source models useful for revealing source complexity (multi-type faulting),
and for pre-constraining slip inversion in other codes, outside Isola.
Through the years, Isola has been applied to events in a broad magnitude range, Mw from 1 to 8. 
To invert difficult small earthquakes, several “tricks” have been added recently, such as the combined use of waveforms, their envelopes,
and first-motion polarities. The code has been routinely used in several national data centers.
Less transparent, but more suitable for routine processing are the automated versions developed 
by our colleagues (for SeisComp, for Python, e.g. https://github.com/nikosT/Gisola, http://geo.mff.cuni.cz/~vackar/isola-obspy/), not addressed here.


<h1>Reference</h1>
Zahradník, J. & Sokos, E. (2018): ISOLA code for multiple-point source modeling –review. in Moment Tensor Solutions - A Useful Tool for Seismotectonics 1–28 (Springer Natural Hazards, 2018).
doi:10.1007/978-3-319-77359-9


<h1>Download  (check for the latest Isola version, zipped Fortran and GUI codes)</h1>
http://geo.mff.cuni.cz/~jz/for_ISOLAnews/


<h1>Detailed instructions (how to install and use the software)</h1>
http://geo.mff.cuni.cz/~jz/for_Brasilia2020/
(e.g. zipped files eq_example1,2,3 and use guides inside)


<h1>Lectures (from the most recent Isola training course)</h1>
http://geo.mff.cuni.cz/~jz/for_ISOLA_lectures_Gebze/


<h1>Quick installation</h1>
============

Copy the isola *.m, *.fig, *.exe files to your isola installation folder (e.g. c:\isola). Then add this folder to your system path and to your Matlab path. Restart Matlab, change directory (cd) to the folder you want to use for processing an event (so called run folder) and type isola, the GUI will ininitialize in this folder and you can start working with isola.


