% 题目2：带通信号数字下变频处理
% (1)建立模拟带通信号的数学模型，信号的中心频率、信号带宽等参数由学生自己选定，设计计算机程序仿真产生模拟带通信号，分别画出信号的时域波形和频谱图；
% (2)根据信号的中心频率和带宽，按照带通信号采样定理选择最佳采样频率fs，并对带通信号进行时域采样，得到离散带通信号x(n)。利用FFT算法分析离散信号的频谱，画出离散带通信号的时域波形和频谱图；
% (3)采用低通滤波法实现数字下变频，设计其中的数字混频器的参数和FIR数字低通滤波器，
% 提出数字低通滤波器的设计指标，要求数字低通滤波器对镜像频率的抑制大于40dB，绘制滤波器的幅频特性和相频特性曲线，验证滤波器的设计结果是否达到设计指标要求；
% (4)采用线性相位FIR数字滤波器结构，画出滤波器网络结构信号流图；
% (5)按照线性相位FIR数字滤波器结构，设计计算机程序计算滤波器的输出响应，
% 以及二次抽样（二次抽样率按照能够使视频信号满足奈奎斯特采样定理选择）后的同相支路信号yI(n)、正交支路信号yQ(n)，画出yI(n)、yQ(n)的时域波形。利用FFT算法分析离散复信号
% y(n)= yI(n)+jyQ(n)的频谱，画出信号的频谱图；
% (6)（学生自选，不做要求）利用实验室的电子信息系统综合实验箱，由DDS产生模拟带通信号，设计FPGA的 A/D采样电路、数字低通滤波器电路和二次抽样电路程序，实现带通信号数字下变频处理；
% (7)分析、总结设计结果，提交课程设计报告。
%% 清空工作区
close all;clear;clc;

%% 参数设定
F=1e3;
A=1;
f0=1e6;  %中频
N=100000;
fa=N*1e2;
Ta=1/fa;
T=4/F;
t=0:Ta:T;

%% 建立带通信号
ta=0:1e-9:T;
s_a=A*cos(2*pi*f0*ta+cos(2*pi*F*ta));   %FM信号的卡森带宽为B=2(mf+1)F
% exp(1j*pi*(2*fo*t+))

figure(1);
subplot(1,2,1);
plot(ta,s_a);

sig=A*cos(2*pi*f0*t+cos(2*pi*F*t));
subplot(1,2,2);
plot(((0:(N-1))-N/2)*fa/N,abs(fftshift(fft(sig,N))));

%% A/D->离散带通信号
m=3;
fs=4*f0/(2*m-1);  %fs>=2B&&fs=4*f0/(2m-1)->中频正交采样定理
N=fix(fs/100);  %保证频率分辨率
nr=0:1/fs:T;

x_n=A*cos(2*pi*f0*nr+cos(2*pi*F*nr));
figure(2);
subplot(2,1,1);
plot(nr,x_n);
xlabel('时间/s');ylabel('幅度');title('离散带通信号的时域波形');
subplot(2,1,2);
plot(((0:(N-1))-N/2)*fs/N,abs(fftshift(fft(x_n,N))));
xlabel('频率/Hz');title('离散带通信号的频谱图');

%% 数字混频/奇偶分离
f_NCO=f0;
nn=0:(length(nr)-1);
x_I=2*x_n.*cos(m*pi*nn-pi/2*nn);
x_Q=-2*x_n.*sin(m*pi*nn-pi/2*nn);

figure(3);
subplot(2,2,1),plot(nr,x_I);
xlabel('时间/s');ylabel('幅度');title('同相支路的时域波形');
subplot(2,2,2),plot(nr,x_Q);
xlabel('时间/s');ylabel('幅度');title('正交支路的时域波形');
subplot(2,2,3);plot(((0:(N-1))-N/2)*fs/N,abs(fftshift(fft(x_I,N))));
xlabel('频率/Hz');title('同相支路的频谱图');
subplot(2,2,4);plot(((0:(N-1))-N/2)*fs/N,abs(fftshift(fft(x_Q,N))));
xlabel('频率/Hz');title('正交支路的频谱图');

%% 镜频滤波
% 镜频滤波->FIR低通滤波 
% w=Omega*Ts
% 指标
wp=2.05e4*2*pi/fs;ws=30e4*2*pi/fs;    %过渡带宽ws-wp
ap=1;as=40;     %通带波纹1dB，阻带最小衰减40dB
% 根据指标，选择hamming窗，计算窗长度n
n=ceil(6.6*pi/(ws-wp));
n=n+mod(n+1,2); %确保阶数为奇数
wc=(wp+ws)/2/pi;
h=fir1(n,wc,hamming(n+1));
[H,w]=freqz(h,1,N);
sysz=tf(h/h(1),1,1)
figure(4);
stem(0:n,h);title('滤波器单位冲激响应');

nr=(0:(4*fs/1e3))/fs;
x_I=[x_I,zeros(1,(n-1)/2)];
x_Q=[x_Q,zeros(1,(n-1)/2)];     %末端补零补偿群延时+(n-1)/2
x_I=filter(h,1,x_I);
x_Q=filter(h,1,x_Q);
x_I=x_I((n-1)/2+1:end);
x_Q=x_Q((n-1)/2+1:end);

figure(5);
subplot(2,1,1);plot(w/2/pi*fs,20*log10(abs(H)));
xlabel('频率/Hz');ylabel('幅度/dB');title('幅频响应');
subplot(2,1,2);plot(w/2/pi*fs,angle(H)*180/pi);
xlabel('频率/Hz');ylabel('角度/°');title('相频响应');

figure(6);
subplot(2,2,1);plot(nr,x_I);
xlabel('时间/s');ylabel('幅度');title('同相支路的时域波形(滤波后)');
subplot(2,2,2);plot(nr,x_Q);
xlabel('时间/s');ylabel('幅度');title('正交支路的时域波形(滤波后)');
subplot(2,2,3);plot(((0:(N-1))-N/2)*fs/N,abs(fftshift(fft(x_I,N))));
xlabel('频率/Hz');title('同相支路的频谱图(滤波后)');
subplot(2,2,4);plot(((0:(N-1))-N/2)*fs/N,abs(fftshift(fft(x_Q,N))));
xlabel('频率/Hz');title('正交支路的频谱图(滤波后)');

%% 二次抽样
D=100;    %抽样间隔
fds=ceil(fs/D);   %fds>=2fc=B(奈奎斯特采样定理)
ndr=nr(1:D:end);
yI=x_I(1:D:end);
yQ=x_Q(1:D:end);
y_o=yI+1j*yQ;

f = figure(7);
subplot(f,3,1,1);stem(ndr,yI);
xlabel('时间/s');ylabel('幅度');title('同相支路的时域波形(抽点后)');
subplot(3,1,2);stem(ndr,yQ);
xlabel('时间/s');ylabel('幅度');title('正交支路的时域波形(抽点后)');
subplot(3,1,3);plot(((0:(N-1))-N/2)*fds/N,abs(fftshift(fft(y_o,N))));
xlabel('频率/Hz');title('抽点后合成信号的频谱图');



f1 = figure(8);

f2 = figure(9);
a(f2)
a(f1)
phased.FMCWWaveform

b = delay(a,0.5)
b = a.delay(0.5)

function a(f)
subplot(f,3,1,2);stem(ndr,yQ);
end