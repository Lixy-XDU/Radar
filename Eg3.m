close all;clear;clc;
%% 信号的采样与量化
t = 0:1e-4:1;
f = 10;
phi = 0; % 初相
adc_bit = 8; % 量化位数
A = 1;
dV = 3.3*2^(-adc_bit); % 量化间隔
adc_A = -1.65:dV:1.65-dV;
fs = 1e3; % 采样率

s_analog = A*sin(2*pi*f*t+phi);

multiple = 1e4/fs;
t_d = 0:1/fs:1;
s_sample = A*sin(2*pi*f*t_d+phi);

len = length(s_sample);
s_quan = zeros(1,len);
for i = 1:len
    for k = 1:length(adc_A)
        if floor(abs(s_sample(i)-adc_A(k))/dV) == 0
            s_quan(i) = adc_A(k);
        end
    end
end

s_qa = zeros(size(s_analog));
for i = 1:length(s_analog)
    k = ceil(i/multiple);
    s_qa(i) = s_quan(k);
end
figure;
subplot(3,1,1);
plot(t,s_analog);axis([0,1,-1.1,1.1]);
subplot(3,1,2);
stem(t_d,s_quan);axis([0,1,-1.1,1.1]);
subplot(3,1,3);
plot(t,s_qa);axis([0,1,-1.1,1.1]);
%% 计算量化噪声与信噪比
s_error = s_analog - s_qa;
mse = mse(s_error);
E = sum(s_analog.^2)/length(s_analog);
SNR = db(E/mse);
%% 
