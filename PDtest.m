close all;
clear;
clc;

t1 = 0;
t2 = 4e-2;
fs = 1e7;
f0 = 999.5e6;
Tp = 1e-6;
f_end = 1000.5e6;
PRF = 20e3;
N = 128;
theta = 0;

R0 = [1005,1040,1600];
vr = [300,100,-5];

[R,v,A_PD] = Radarbox.PulseDoppler(f0,t1,t2,fs,Tp,f_end,PRF,N,R0,vr,'T',300);
%% 
% figure;
% plot(1:N,real(A_PC(ceil(R0/1.5e8*fs),:)'));
% cp = A_PC(ceil(R0/1.5e8*fs),:)';
% Fcp = fftshift(fft(cp,Nfft));
% figure;
% plot(abs(Fcp));
% % figure;
% % plot(real(AR(:,1)));
% % mesh(1:64,R(rr),real(AR));