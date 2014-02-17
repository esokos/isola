function A = myplresp(zeroesns,polesns,A0ns,station,comp)


%% do calculations
a_ns=zpk(zeroesns,polesns,A0ns);
ev1 = tf(a_ns);
[mag,phase,w]=bode(ev1,{0.001, 1000});

% convert to dB
magdb=reshape(20*log10(mag(1,1,:)),[1 length(mag)]);
% convert to Hz
w=w'*0.159;

%% plot
figure

subplot(2,1,1)
semilogx(w,magdb)
title(['Station ', station ,'       Component  ' comp ])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
grid on

subplot(2,1,2)
semilogx(w,reshape(phase,[1 length(phase)]))
xlabel('Frequency (Hz)')
ylabel('Phase (deg)')

grid on
% scale plot
%axis([0.001 150 -190 190])
A=1;