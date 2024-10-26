function [R,v,A_PD] = PulseDoppler(f0,t1,t2,fs,Tp,f_end,PRF,N,R0,vr,options,Nfft,theta)
%PULSEDOPPLER Return x and y axes, and a map of PD.
%   此处显示详细说明
%% Parametric Verification
arguments
    f0  (1,1)
    t1  (1,1)
    t2  (1,1)
    fs  (1,1)
    Tp  (1,1)
    f_end   (1,1)
    PRF (1,1)
    N   (1,1)
    R0  (1,:)
    vr  (1,:)
    options (1,:) char {mustBeMember(options,{'T','F'})} = 'T'
    Nfft    (1,1) = 128
    theta   (1,1) = 0
end
%% PC_Calculate
fc = (f0+f_end)/2;
st = Radarbox.LFM_Wave(f0,t1,t2,fs,Tp,f_end,PRF,N,theta);
sig = st.sigwave;
[t,sig1] = Radarbox.RadarWave.Wave_reshape(sig,fs,PRF,N);

target_number = size(R0,2);
AR = zeros(size(sig1));
for i = 1:target_number
    sr = st.Wave_Rebuild(vr(i));
    sd = sr.sigwave;
    [~,sd] = Radarbox.RadarWave.Wave_reshape(sd,fs,PRF,N);
    AR = AR + Radarbox.RadarWave.Wave_receive(t,sd,fc,PRF,R0(i),vr(i));
end

A_PC = Radarbox.RadarWave.Wave_PC(sig1,AR,Tp,fs);

%% PD_Calculate
A_PD = Radarbox.RadarWave.Wave_PD(A_PC,fs,Nfft)';
YD = (-Nfft/2:Nfft/2-1)*PRF/Nfft;
v = YD/fc*1.5e8;
R = t*1.5e8;
%% Draw
if options == 'T'
    figure;
    % surf(1+abs(A_PD)');
    % hold on;
    contourf(R,v,(abs(A_PD)),255,'LineColor','none');
    xstep = Tp*1.5e8;
    ystep = 50;
    ax = gca;
    set(gca,'xtick',R(1):xstep:R(end));
    grid on
    set(gca,'ytick',v(1)-ystep/2:ystep:v(end)+ystep/2);
    grid on
    ax.GridColor = [210 210 210]/255;
    ax.GridLineWidth = 0.8;
    ax.GridAlpha = 0.8;
    colorbar
    colormap('jet')
end
end

